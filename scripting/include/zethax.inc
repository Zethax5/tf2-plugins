//Damage stuff
#define TF_DMG_BULLET                       (1 << 1)
#define TF_DMG_BLAST                        (1 << 6)
#define TF_DMG_CRIT                         (1 << 20)
#define TF_DMG_MELEE                        (1 << 27) | (1 << 12) | (1 << 7)
#define TF_DMG_MELEE_CRIT                   TF_DMG_MELEE | TF_DMG_CRIT
#define TF_DMG_RADIANCE                     (1 << 8)
#define DMG_FALL   (1 << 5)
#define SLOTS_MAX 7

new Float:CombatTime[MAXPLAYERS + 1];

//Returns the medigun patient of the client
//@param client					Target client
stock GetMediGunPatient(client)
{
	new wep = GetPlayerWeaponSlot(client, 1);
	if (wep == -1 || wep != GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon")) return -1;
	new String:class[15];
	GetEdictClassname(wep, class, sizeof(class));
	if (StrContains(class, "tf_weapon_med", false)) return -1;
	return GetEntProp(wep, Prop_Send, "m_bHealing") ? GetEntPropEnt(wep, Prop_Send, "m_hHealingTarget") : -1;
}

//Returns the maximum health of a client
//@param client					Target client
stock GetClientMaxHealth(client)
{
	if(client == -1) return 0;
	return GetEntProp(client, Prop_Data, "m_iMaxHealth");
}

//Checks if the client is connected, alive, and a valid client
//@param client			The target client
stock bool:IsValidClient(client)
{
	if (!IsClientInGame(client))return false;
	if (!IsPlayerAlive(client))return false;
	if (client > MaxClients || client < 1)return false;
	return true;
}

//Returns the client's active weapon
//@param client				The client you want to get the weapon of
stock GetActiveWeapon(client)
{
	if (!IsValidClient(client))return -1;
	if(GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon") > -1)
	{
		return GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	}
	else return -1;
}

//Returns the definition index of the client's weapon
//@param client				The target client
//@param weapon				The target weapon you wish to get the definition index of
stock GetWeaponIndex(client, weapon)
{
	if (!IsValidClient(client))return -1;
	if (weapon < 0 || weapon > 2049)return -1;
	return GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex");
}

/*
Spawns an entity on a certain team and teleports them to a designated postition
@param entity				Name of the entity
@param spawn				Spawn position of the entity
@param team 				The team to spawn it on.
		Some entities don't work with teams, such as the Skeleton King
*/
stock SpawnEntity(String:entity[32]="", spawn, team)
{
    new ent = CreateEntityByName(entity);
    if (IsValidEntity(ent))
    {
        DispatchSpawn(ent);
	
        if (StrEqual(entity, "tf_zombie_spawner")) {
            SetEntProp(ent, Prop_Data, "m_nSkeletonType", 1);
            AcceptEntityInput(ent, "Enable");
        }
        else if (StrEqual(entity, "tf_zombie")) {
            if (team == 2) DispatchKeyValue(ent, "skin", "0");
            else if (team == 3) DispatchKeyValue(ent, "skin", "1");
            SetEntProp(ent, Prop_Send, "m_iTeamNum", team);
        }
        else if (StrEqual(entity, "eyeball_boss")) SetEntProp(ent, Prop_Data, "m_iTeamNum", 5);

        new Float:POSi[3];
        GetClientAbsOrigin(victim, POSi);
        TeleportEntity(ent, POSi, NULL_VECTOR, NULL_VECTOR);
    }
}
//
////
//////
///////
// Ammo related stuff
///////
//////
////
//

//Gets the clip of a weapon and returns it
stock GetClip_Weapon(weapon)
{
	if (weapon == -1)return 0;
	new iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
	return GetEntData(weapon, iAmmoTable, 4);
}

//Gets the ammo of a weapon and returns it
stock GetAmmo_Weapon(weapon)
{
	if (weapon == -1) return 0;
	new owner = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
	if (owner == -1) return 0;
	return GetEntProp(owner, Prop_Data, "m_iAmmo", 4, 3);
}

//Sets the clip of a weapon
stock SetClip_Weapon(weapon, newClip)
{
	if (weapon == -1)return;
	new iAmmoTable = FindSendPropInfo("CTFWeaponBase", "m_iClip1");
	SetEntData(weapon, iAmmoTable, newClip, 4, true);
}

//Sets the ammo of a weapon.
stock SetAmmo_Weapon(weapon, newAmmo)
{
	new owner = GetEntPropEnt(weapon, Prop_Send, "m_hOwnerEntity");
	if (owner == -1) return;
	if (weapon == -1)return;
	SetEntProp(owner, Prop_Data, "m_iAmmo", newAmmo, 4, 3);
}
/*
Deals damage to a specific client through the use of "point_hurt" entities.
I basically stole this from Orion, who might have stolen it from smlib.
@param victim				The player the damage is being dealt to
@param damage				The amount of damage being dealt, using an integer value.
@param attacker				The player dealing the damage.
@param dmg_type				The type of damage being dealt. Defaults to DMG_GENERIC
@param logname				How it displays in the server log/player console
*/
stock DealDamage(victim, damage, attacker=0, dmg_type=DMG_GENERIC ,String:logname[]="")
{
    if(victim>0 && IsValidEdict(victim) && IsClientInGame(victim) && IsPlayerAlive(victim) && damage>0)
    {
        new String:dmg_str[16];
        IntToString(damage,dmg_str,16);
        new String:dmg_type_str[32];
        IntToString(dmg_type,dmg_type_str,32);
        new pointHurt=CreateEntityByName("point_hurt");
        if(pointHurt)
        {
            DispatchKeyValue(victim,"targetname","war3_hurtme");
            DispatchKeyValue(pointHurt,"DamageTarget","war3_hurtme");
            DispatchKeyValue(pointHurt,"Damage",dmg_str);
            DispatchKeyValue(pointHurt,"DamageType",dmg_type_str);
            if(!StrEqual(logname,""))
            {
                DispatchKeyValue(pointHurt,"classname",logname);
            }
            DispatchSpawn(pointHurt);
            AcceptEntityInput(pointHurt,"Hurt",(attacker>0)?attacker:-1);
            DispatchKeyValue(pointHurt,"classname","point_hurt");
            DispatchKeyValue(victim,"targetname","war3_donthurtme");
            RemoveEdict(pointHurt);
        }
    }
}

/*
Induces a fake healing effect because Sourcemod does not come with that
@param healer				The client doing the healing
@param patient				The patient to recieve the healing
@param amount				The amount to heal patients by per impulse
@param overheal				Maximum amount of overheal your patients are allowed to have
*/
stock HealPlayer(healer, patient, amount, Float:overheal)
{
	if (healer <= 0 || healer > MaxClients)return;
	if (patient <= 0 || patient > MaxClients)return;
	new health = GetClientHealth(patient);
	new maxhealth = GetClientMaxHealth(patient);
	if(amount > 0)
	{
		if(health < maxhealth * overheal)
		{
			SetEntityHealth(patient, health + amount);
			new Handle:healevent = CreateEvent("player_healonhit", true);
			SetEventInt(healevent, "entindex", patient);
			SetEventInt(healevent, "amount", amount);
			FireEvent(healevent);
		}
	}
}

/*
Spawns a particle effect. Thanks to Orion for lending me the code for this.
@param client				The client creating the particle
@param particle				The name of the particle being spawned
*/
stock SpawnParticle(client, String:particleName[]="")
{
	if (client <= 0 || client > MaxClients)return;
	new particle = CreateEntityByName( "info_particle_system" );
	new Float:m_flPosition[3];
	GetClientAbsOrigin(client, m_flPosition);
	if ( IsValidEntity( particle ) )
	{
		TeleportEntity( particle, m_flPosition, NULL_VECTOR, NULL_VECTOR );
		DispatchKeyValue( particle, "effect_name", particleName );
		DispatchSpawn( particle );
		ActivateEntity( particle );
		AcceptEntityInput( particle, "start" );
		SetVariantString( "OnUser1 !self:Kill::8:-1" );
		AcceptEntityInput( particle, "AddOutput" );
		AcceptEntityInput( particle, "FireUser1" );
	}
}

/*
Applies healing or damage to players in a specific radius
@param client				The client defining the origin point of the explosion
@param inflictor			The client inflicting the explosion. Defaults to the client
@param exception			A client you don't want to be affected by the explosion, for whatever reason
@param radius				Radius for the explosion.
@param falloff 				Maximum damage falloff multiplier for the damage
@param amount				Amount of damage/healing to be dealt to qualifying players in the radius
@param dmgtype 				The type of damage being dealt, if damage is being dealt at all.
@param team					Which teams will be affected by this explosion. 0 = All teams, 1 = Same team, 2 = Opposing team
@param clientIsAffected		Determines whether or not the client is affected by the explosion.
*/
stock DealRadiusDamage(iClient, iAttacker=-1, iException=-1, Float:flRadius=0.0, Float:flFalloff=1.0, iAmount=0, iDmgType=0, iTeam=2, bool:bClientIsAffected=false)
{
	if (iClient <= 0 || iClient > MaxClients)return;
	for (new i = 1; i <= MaxClients; i++)
	{
		new Float:flPos1[3];
		GetClientAbsOrigin(iClient, flPos1); 
		
		if(IsValidClient(i) && IsClientInGame(i) && IsPlayerAlive(i))
		{ 
			if (!bClientIsAffected && i == iClient)continue;
			if (iException > 0 && i == iException)continue;
			if (iTeam == 1 && GetClientTeam(i) != GetClientTeam(iClient))continue;
			if (iTeam == 2 && GetClientTeam(i) == GetClientTeam(iClient))continue;
			
			new Float:flPos2[3];
			GetClientAbsOrigin(i, flPos2);
			new Float:flDistance = GetVectorDistance(flPos1, flPos2);
			if(flDistance <= flRadius)
			{
				new iInflictor;
				if (iAttacker > 0)iInflictor = iAttacker;
				else iInflictor = iClient;
				if(iAmount < 0)
				{
					SetEntityHealth(i, GetClientHealth(i) + iAmount);
					new Handle:healevent = CreateEvent("player_healonhit", true);
					SetEventInt(healevent, "entindex", iInflictor);
					SetEventInt(healevent, "amount", iAmount);
					FireEvent(healevent);
				}
				else if(iAmount > 0)
				{
					new damage;
					damage = RoundToFloor(iAmount * (1.0 - ((flDistance / flRadius) * flFalloff)));
					if (damage < RoundFloat(iAmount * flFalloff))damage = RoundFloat(iAmount * flFalloff);
					DealDamage(i, damage, iInflictor, iDmgType, "");
				}
			}
		}
	}
}

/*
Applies conditions to players in a radius.
@param client				The client defining the origin point of the explosion
@param inflictor			The client inflicting the explosion. Defaults to the client
@param exception			A client you don't want to be affected by the explosion, for whatever reason
@param radius				Radius for the explosion.
@param cond1				First condition to apply to qualifying players in the radius.
@param cond2				Second condition to apply to qualifying players in the radius.
@param dur1					Duration to apply condition 1 for.
@param dur2					Duration to apply condition 2 for.
@param team					Which teams will be affected by this explosion. 0 = All teams, 1 = Same team, 2 = Opposing team
@param clientIsAffected		Determines whether or not the client is affected by the explosion.
*/
stock ApplyRadiusEffects(iClient, iAttacker=-1, iException=-1, Float:flRadius=0.0, iCond1=-1, iCond2=-1, Float:flDur1=0.0, Float:flDur2=0.0, iTeam=0, bool:bClientIsAffected=false)
{
	if (iClient <= 0 || iClient > MaxClients)return;
	for (new i = 1; i <= MaxClients; i++)
	{
		new Float:flPos1[3];
		GetClientAbsOrigin(iClient, flPos1); 
		
		if(IsValidClient(i) && IsClientInGame(i) && IsPlayerAlive(i))
		{ 
			if (!bClientIsAffected && i == iClient)continue;
			if (iException > 0 && i == iException)continue;
			if (iTeam == 1 && GetClientTeam(i) != GetClientTeam(iClient))continue;
			if (iTeam == 2 && GetClientTeam(i) == GetClientTeam(iClient))continue;
			new Float:flPos2[3];
			GetClientAbsOrigin(i, flPos2);
			new Float:flDistance = GetVectorDistance(flPos1, flPos2);
			if(flDistance <= flRadius)
			{
				new iInflictor;
				if (iAttacker >= 1)iInflictor = iAttacker;
				else iInflictor = iClient;
				if(iCond1 > 0)
				{
					TF2_AddCondition(i, TFCond:iCond1, flDur1, iInflictor);
				}
				if(iCond2 > 0)
				{
					TF2_AddCondition(i, TFCond:iCond2, flDur2, iInflictor);
				}
			}
		}
	}
}

stock Action:ActionApply(Action:aPrevious, Action:aNew)
{
	if(aNew != Plugin_Continue) aPrevious = aNew;
	return aPrevious;
}