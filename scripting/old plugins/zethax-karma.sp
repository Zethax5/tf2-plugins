#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>
#include <tf2items>
#include <tf2attributes>
#include <cw3-attributes>
#include <tf2>
#include <smlib>
#include <zethax>

#define PLUGIN_VERSION "beta 0.1"
#define SLOTS_MAX               7

enum
{
	Handle:AfterburnTimerDuration,
	Handle:AfterburnTimerSelfDuration,
	Handle:m_hTimer
};

public Plugin:myinfo = {
	name = "Zethax Karma Charger Attributes",
	author = "Zethax",
	description = "Includes a bunch of attributes I made specifically for Karma Charger",
	version = PLUGIN_VERSION,
	url = ""
};

new Handle:m_hTimers[MAXPLAYERS + 1][m_hTimer];

new bool:OnHitIgnite[2049];
new Float:OnHitIgnite_Dur[2049];
new Float:OnHitIgnite_SelfDur[2049];

new bool:MinicritStunnedPlayers[2049];

new bool:KillsChargeItems[2049];
new Float:KillsChargeItems_Mult[2049];

new bool:DMGDealtHeals[2049];
new Float:DMGDealtHeals_Mult[2049];

new bool:StunSapper[2049];
new Float:StunSapper_Dur[2049];
new Float:StunSapper_Sapped[2049];

new bool:MilkOnHit[2049];
new Float:MilkOnHit_Dur[2049];

new bool:MilkExplosionOnDeath[2049];
new Float:MilkExplosionOnDeath_Radius[2049];
new Float:MilkExplosionOnDeath_Dur[2049];

new bool:AmmoBanner[2049];
new Float:AmmoBanner_Rage[2049];
new Float:AmmoBanner_Delay[2049];

new bool:OneShotNoAmmo[2049];

new bool:m_bUsesCloakForAmmo[2049];
new Float:m_flUsesCloakForAmmo[2049];

new bool:m_bDMGVulnOnHit[2049];
new Float:m_flDMGVulnOnHit[2049];
new m_iDMGVulnOnHit[2049];
new Float:m_flDMGVulnOnHit_Delay[2049];
new Float:m_flDMGVulnOnHit_Drain[2049];
new Float:m_flDMGVulnOnHit_DrainDelay[2049];

new bool:m_bSlowOnHitStacks[2049];
new Float:m_flSlowOnHitStacks[2049];
new m_iSlowOnHitStacks[2049];
new m_iSlowOnHitStacks_Max[2049];
new Float:m_flSlowOnHitStacks_Dur[2049];
new Float:m_flSlowOnHitStacks_Delay[2049];

new LastWeaponHurtWith[MAXPLAYERS + 1];

public OnPluginStart() {
	
	HookEvent("player_death", Event_Death);
	HookEvent("player_sapped_object", Event_Sapped);
	CreateTimer(0.1, UsesCloakForAmmo_FillClip, _, TIMER_REPEAT);
	CreateTimer(0.1, DMGVulnOnHit_Vuln, _, TIMER_REPEAT);
	CreateTimer(0.1, SlowOnHit_Timer, _, TIMER_REPEAT);
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i)) continue;
		{
		OnClientPutInServer(i);
		}
	}
}
public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
	SDKHook(client, SDKHook_OnTakeDamageAlivePost, OnTakeDamageAlivePost);
	SDKHook(client, SDKHook_TraceAttack, OnTraceAttack);
	
	LastWeaponHurtWith[client] = 0;
}

stock GetWeaponSlot(client, weapon)
{
	if(!Client_IsValid(client)) return -1;
	
	for(new i = 0; i < 7; i++)
    {
        if(weapon == GetPlayerWeaponSlot(client, i))
        {
            return i;
        }
    }
	return -1;
}
stock GetClientSlot(client)
{
	if(!Client_IsValid(client)) return -1;
	if(!IsPlayerAlive(client)) return -1;
	
	new slot = GetWeaponSlot(client, Client_GetActiveWeapon(client));
	return slot;
}

public Action:CW3_OnAddAttribute(slot, client, const String:attrib[], const String:plugin[], const String:value[])
{
	if(!StrEqual(plugin, "zethax-karma")) return Plugin_Continue;
	new weapon = GetPlayerWeaponSlot(client, slot);
	new Action:action;
	
	if(StrEqual(attrib, "on hit ignite"))
	{
		if (weapon == -1)return Plugin_Continue;
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		OnHitIgnite_Dur[weapon] = StringToFloat(values[0]);
		OnHitIgnite_SelfDur[weapon] = StringToFloat(values[1]);
		OnHitIgnite[weapon] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "minicrit vs stunned players")) {
		
		if (weapon == -1)return Plugin_Continue;
		MinicritStunnedPlayers[weapon] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "fill recharge bars on kill")) {
		
		if (weapon == -1)return Plugin_Continue;
		KillsChargeItems[weapon] = true;
		KillsChargeItems_Mult[weapon] = StringToFloat(value);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "damage dealt return health")) {
		
		if (weapon == -1)return Plugin_Continue;
		DMGDealtHeals_Mult[weapon] = StringToFloat(value);
		DMGDealtHeals[weapon] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "sapper stun after removed")) {
		
		if (weapon == -1)return Plugin_Continue;
		StunSapper[weapon] = true;
		StunSapper_Dur[weapon] = StringToFloat(value);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "milk on hit all")) {
		
		MilkOnHit[weapon] = true;
		MilkOnHit_Dur[weapon] = StringToFloat(value);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "milk explosion on death")) {
		
		MilkExplosionOnDeath[weapon] = true;
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		MilkExplosionOnDeath_Radius[weapon] = StringToFloat(values[0]);
		MilkExplosionOnDeath_Dur[weapon] = StringToFloat(values[1]);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "ammo banner")) {
		
		AmmoBanner[weapon] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "uses cloak as ammo")) {
		
		if (weapon == -1)return Plugin_Continue;
		m_bUsesCloakForAmmo[weapon] = true;
		m_flUsesCloakForAmmo[weapon] = StringToFloat(value);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "dmg vuln per bullet hit")) {
		
		if (weapon == -1)return Plugin_Continue;
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		m_bDMGVulnOnHit[weapon] = true;
		m_flDMGVulnOnHit[weapon] = StringToFloat(values[0]);
		m_flDMGVulnOnHit_Drain[weapon] = StringToFloat(values[1]);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "slowness on hit stacks")) {
		
		if (weapon == -1)return Plugin_Continue;
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		m_bSlowOnHitStacks[weapon] = true;
		m_flSlowOnHitStacks[weapon] = StringToFloat(values[0]);
		m_iSlowOnHitStacks_Max[weapon] = StringToInt(values[1]);
		m_flSlowOnHitStacks_Dur[weapon] = StringToFloat(values[2]);
		action = Plugin_Handled;
	}
	
	if (!m_bHasAttribute[client][slot])m_bHasAttribute[client][slot] = bool:action;
	return action;
}

public Action:TF2_CalcIsAttackCritical(client, weapon, String:weaponname[], &bool:result)
{
	new wep = Client_GetActiveWeapon(client);
	if (wep == -1) return Plugin_Continue;
	if(m_bUsesCloakForAmmo[weapon] && GetEntPropFloat(client, Prop_Send, "m_flCloakMeter") >= m_flUsesCloakForAmmo[weapon])
	{
		SetEntPropFloat(client, Prop_Send, "m_flCloakMeter", GetEntPropFloat(client, Prop_Send, "m_flCloakMeter") - m_flUsesCloakForAmmo[weapon]);
	}
	return Plugin_Continue;
}

public Action:UsesCloakForAmmo_FillClip(Handle:timer)
{
	for (new client = 1; client <= MaxClients; client++)
	{
		if (!IsValidClient(client))continue;
		if (!IsPlayerAlive(client))continue;
		new weapon = GetPlayerWeaponSlot(client, 0);
		if (weapon == -1)continue;
		if(m_bUsesCloakForAmmo[weapon] && GetEntPropFloat(client, Prop_Send, "m_flCloakMeter") >= m_flUsesCloakForAmmo[weapon])
			SetClip_Weapon(weapon, 1);
		if(m_bUsesCloakForAmmo[weapon] && GetEntPropFloat(client, Prop_Send, "m_flCloakMeter") < m_flUsesCloakForAmmo[weapon])
			SetClip_Weapon(weapon, 0);
	}
}
public Action:DMGVulnOnHit_Vuln(Handle:timer)
{
	for (new client = 1; client <= MaxClients; client++)
	{
		if (!IsValidClient(client))continue;
		if (!IsPlayerAlive(client))continue;
		if(m_iDMGVulnOnHit[client] > 0)
		{
			TF2Attrib_RemoveByName(client, "dmg taken increased");
			if(GetEngineTime() >= m_flDMGVulnOnHit_Delay[client] + m_flDMGVulnOnHit_Drain[client] && GetEngineTime() >= m_flDMGVulnOnHit_DrainDelay[client] + 0.5)
			{
				m_iDMGVulnOnHit[client]--;
				m_flDMGVulnOnHit_DrainDelay[client] = GetEngineTime();
			}
			TF2Attrib_SetByName(client, "dmg taken increased", 1.0 + (m_flDMGVulnOnHit[client] * m_iDMGVulnOnHit[client]));
		}
	}
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3], damageCustom)
{
	if (attacker <= 0 || attacker > MaxClients) return Plugin_Continue;
	new Action:action;
	new slot = GetClientSlot(attacker);
	if(weapon > 0 && IsValidEdict(weapon))
	{
		slot = GetWeaponSlot(attacker, weapon);
	} else
	{
		if(inflictor > 0 && !Client_IsValid(inflictor) && IsValidEdict(inflictor))
		{
			slot = GetWeaponSlot(attacker, inflictor);
		}
	}
	if(weapon > -1)
	{
		LastWeaponHurtWith[attacker] = weapon;
		if(m_bHasAttribute[attacker][slot])
		{
			if(OnHitIgnite[weapon] && !TF2_IsPlayerInCondition(victim, TFCond_OnFire))
			{
				if(attacker != victim && TF2_GetPlayerClass(victim) != TFClass_Pyro)
				{
					TF2_IgnitePlayer(victim, attacker);
					m_hTimers[victim][AfterburnTimerDuration] = CreateTimer(OnHitIgnite_Dur[weapon], OnHitIgnite_AfterburnDur, victim);
				} else if(attacker == victim) {
					
					TF2_IgnitePlayer(victim, victim);
					m_hTimers[victim][AfterburnTimerDuration] = CreateTimer(OnHitIgnite_SelfDur[weapon], OnHitIgnite_AfterburnSelfDur, victim);
				}
			}
			if(MinicritStunnedPlayers[weapon] && TF2_IsPlayerInCondition(victim, TFCond:15))
			{
				TF2_AddCondition(victim, TFCond:30, 0.01);
			}
			if(m_bDMGVulnOnHit[weapon] && damage >= 6.0)
			{
				m_iDMGVulnOnHit[victim] = RoundToFloor(damage / 6.0);
				m_flDMGVulnOnHit[victim] = m_flDMGVulnOnHit[weapon];
				m_flDMGVulnOnHit_Drain[victim] = m_flDMGVulnOnHit_Drain[weapon];
				m_flDMGVulnOnHit_Delay[victim] = GetEngineTime();
				m_flDMGVulnOnHit_DrainDelay[victim] = GetEngineTime();
			}
		}
	}
	return action;
}
public OnTakeDamagePost(victim, attacker, inflictor, Float:damage, damagetype, weapon, const Float:damageForce[3], const Float:damagePosition[3])
{
	if(attacker <= 0 || attacker > MaxClients) return;
	new slot = GetClientSlot(attacker);
	if(weapon > 0 && IsValidEdict(weapon))
	{
		slot = GetWeaponSlot(attacker, weapon);
	} else
	{
		if(inflictor > 0 && !Client_IsValid(inflictor) && IsValidEdict(inflictor))
		{
			slot = GetWeaponSlot(attacker, inflictor);
		}
	}
	if(weapon > -1)
	{
		if(m_bHasAttribute[attacker][slot])
		{
			if(DMGDealtHeals[weapon])
			{
				if(GetClientHealth(attacker) < GetEntProp(attacker, Prop_Data, "m_iMaxHealth") - (damage * DMGDealtHeals_Mult[weapon]))
					SetEntityHealth(attacker, GetClientHealth(attacker)+RoundToFloor(damage*DMGDealtHeals_Mult[weapon]));
				if(GetClientHealth(attacker) >= GetEntProp(attacker, Prop_Data, "m_iMaxHealth") - (damage * DMGDealtHeals_Mult[weapon]))
					SetEntityHealth(attacker, GetEntProp(attacker, Prop_Data, "m_iMaxHealth"));
			}
			if(m_bSlowOnHitStacks[weapon] && m_iSlowOnHitStacks[victim] < m_iSlowOnHitStacks_Max[weapon])
			{
				m_iSlowOnHitStacks[victim]++;
				m_flSlowOnHitStacks[victim] = m_flSlowOnHitStacks[weapon];
				m_flSlowOnHitStacks_Dur[victim] = m_flSlowOnHitStacks_Dur[weapon];
				m_flSlowOnHitStacks_Delay[victim] = GetEngineTime();
			}
		}
		new primary = GetPlayerWeaponSlot(attacker, 0);
		if(MilkOnHit[primary])
		{
			TF2_AddCondition(victim, TFCond_Milked, MilkOnHit_Dur[primary], attacker);
		}
	}
}

public OnTakeDamageAlivePost(victim, attacker, inflictor, Float:damage, damagetype, weapon, const Float:damageForce[3], const Float:damagePosition[3])
{
	new secondary = GetPlayerWeaponSlot(attacker, 1);
	if(secondary > -1 && AmmoBanner[secondary] && damage >= 1.0 && GetClientTeam(attacker) != GetClientTeam(victim))
	{
		AmmoBanner_Rage[secondary] += damage;
		if (AmmoBanner_Rage[secondary] > 600.0)AmmoBanner_Rage = 600.0;
	}
}

public Action:SlowOnHit_Timer(Handle:timer)
{
	for (new client = 1; client <= MaxClients; client++)
	{
		if (!IsValidClient(client))continue;
		if (!IsPlayerAlive(client))continue;
		if(m_iSlowOnHitStacks[client] > 0)
		{
			TF2Attrib_SetByName(client, "move speed penalty", 1.0 - (m_flSlowOnHitStacks[client] * m_iSlowOnHitStacks[client]));
			if(GetEngineTime() >= m_flSlowOnHitStacks_Delay[client] + m_flSlowOnHitStacks_Dur[client])
			{
				m_iSlowOnHitStacks[client]--;
				if(m_iSlowOnHitStacks[client] == 0)
				{
					m_flSlowOnHitStacks_Delay[client] = 0.0;
					m_flSlowOnHitStacks_Dur[client] = 0.0;
					m_flSlowOnHitStacks[client] = 0.0;
					TF2Attrib_RemoveByName(client, "move speed penalty");
				}
				m_flSlowOnHitStacks_Delay[client] = GetEngineTime();
			}
		}
	}
}

public Action:OnTraceAttack(victim, &attacker, &inflictor, &Float:damage, &damagetype, &ammotype, hitbox, hitgroup)
{
	if (attacker <= 0 || attacker > MaxClients) return Plugin_Continue;
	new weapon = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");
	
	new slot = GetClientSlot(attacker); // Get the slot as a backup in case the following fails.
	if(weapon > 0 && IsValidEdict(weapon)) // If a weapon id is over 0 and it's a valid edict,
	{
		slot = GetWeaponSlot(attacker, weapon); // Get the slot from the attackers weapon.
	} else // Otherwise
	{
		if (inflictor > 0 && (inflictor > 0 || inflictor <= MaxClients) && IsValidEdict(inflictor)) // If the inflictor id is over 0 and it's not a client AND it's a valid edict,
		{
			slot = GetWeaponSlot(attacker, inflictor); // Get the slot from the inflictor, as it might be a sentry gun.
		}
	}
	if (slot == -1) return Plugin_Continue;
	new pri = GetPlayerWeaponSlot(victim, 0);
	new melee = GetPlayerWeaponSlot(attacker, 2);
	new secondary = GetPlayerWeaponSlot(attacker, 1);
	if(MeleeHitRecharge[pri] && GetClientTeam(victim) == GetClientTeam(attacker) && TF2_GetPlayerClass(attacker) == TFClass_Scout && weapon == melee)
	{
		SetEntPropFloat(secondary, Prop_Send, "m_flEffectBarRegenTime", 0.0);
	}
	return Plugin_Continue;
}

public Action:Event_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new bool:feign = bool:(GetEventInt(event, "death_flags") & TF_DEATHFLAG_DEADRINGER);
	if (attacker && attacker != victim)
	{
		new weapon = LastWeaponHurtWith[attacker];
		new slot = GetWeaponSlot(attacker, weapon);
		if (m_bHasAttribute[attacker][slot])
		{
			if(KillsChargeItems[weapon] && !feign)
			{
				new secondary = GetPlayerWeaponSlot(attacker, 1);
				new melee = GetPlayerWeaponSlot(attacker, 2);
				new Float:secrecharge = GetEntPropFloat(secondary, Prop_Send, "m_flEffectBarRegenTime");
				new Float:melrecharge = GetEntPropFloat(melee, Prop_Send, "m_flEffectBarRegenTime");
				SetEntPropFloat(secondary, Prop_Send, "m_flEffectBarRegenTime", secrecharge-(24.0*KillsChargeItems_Mult[weapon])); 
				SetEntPropFloat(melee, Prop_Send, "m_flEffectBarRegenTime", melrecharge-(15.0*KillsChargeItems_Mult[weapon])); 
				if(GetEntPropFloat(secondary, Prop_Send, "m_flEffectBarRegenTime") < 0.0) SetEntPropFloat(secondary, Prop_Send, "m_flEffectBarRegenTime", 0.0);
				if(GetEntPropFloat(melee, Prop_Send, "m_flEffectBarRegenTime") < 0.0) SetEntPropFloat(melee, Prop_Send, "m_flEffectBarRegenTime", 0.0);
			}
		}
	}
	new primary = GetPlayerWeaponSlot(victim, 0);
	if(MilkExplosionOnDeath[primary])
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			new Float:Pos1[3];
			GetClientAbsOrigin(victim, Pos1);
			new team = GetClientTeam(victim);
			if(IsValidClient(i) && GetClientTeam(i) != team)
			{
				new Float:Pos2[3];
				GetClientAbsOrigin(i, Pos2);
				new Float:distance = GetVectorDistance(Pos1, Pos2);
				if(distance <= MilkExplosionOnDeath_Radius[primary])
				{
					TF2_AddCondition(i, TFCond_Milked, MilkExplosionOnDeath_Dur[primary], victim);
				}
			}
		}
		//Thanks Orion!
		new particle = CreateEntityByName( "info_particle_system" );
		new Float:m_flPosition[3];
		GetClientAbsOrigin(victim, m_flPosition);
		if ( IsValidEntity( particle ) )
		{
			TeleportEntity( particle, m_flPosition, NULL_VECTOR, NULL_VECTOR );
			DispatchKeyValue( particle, "effect_name", "peejar_impact_milk" );
			DispatchSpawn( particle );
			ActivateEntity( particle );
			AcceptEntityInput( particle, "start" );
			SetVariantString( "OnUser1 !self:Kill::8:-1" );
			AcceptEntityInput( particle, "AddOutput" );
			AcceptEntityInput( particle, "FireUser1" );
		}
	}
	if(m_iSlowOnHitStacks[victim] > 0)
	{
		m_flSlowOnHitStacks_Delay[victim] = 0.0;
		m_flSlowOnHitStacks_Dur[victim] = 0.0;
		m_flSlowOnHitStacks[victim] = 0.0;
		m_iSlowOnHitStacks[victim] = 0;
		TF2Attrib_RemoveByName(victim, "move speed penalty");
	}
}

public Action:OnHitIgnite_AfterburnDur(Handle:timer, any:victim)
{
	TF2_RemoveCondition(victim, TFCond_OnFire);
	m_hTimers[victim][AfterburnTimerDuration] = INVALID_HANDLE;
}
public Action:OnHitIgnite_AfterburnSelfDur(Handle:timer, any:victim)
{
	TF2_RemoveCondition(victim, TFCond_OnFire);
	m_hTimers[victim][AfterburnTimerSelfDuration] = INVALID_HANDLE;
}

public Action:Event_Sapped(Handle:event, const String:name[], bool:dontBroadcast)
{
	new ent = GetEventInt(event, "object");
	new spy = GetClientOfUserId(GetEventInt(event, "userid"));
	if(ent > 0 && IsValidEdict(ent))
	{
		new wep = Client_GetActiveWeapon(spy);
		if(StunSapper[wep])
		{
			StunSapper[ent] = true;
			StunSapper_Dur[ent] = StunSapper_Dur[wep];
			//And thus begins the probably really inefficient way to do this
			CreateTimer(0.1, Timer_CheckIsSapped, EntIndexToEntRef(ent), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
		}
	}
	return Plugin_Continue;
}
public Action:Timer_CheckIsSapped(Handle:timer, any:ref)
{
	new ent = EntRefToEntIndex(ref);
	if (ent > 0 && IsValidEntity(ent) && StunSapper[ent])
    {
        if (GetEntProp(ent, Prop_Send, "m_bHasSapper"))
        	return Plugin_Continue;
        else
        {
        	SetEntProp(ent, Prop_Data, "m_bDisabled", true);
        	//Continuing on the probably really inefficient way to do this
        	CreateTimer(0.1, Timer_RemoveStun, EntIndexToEntRef(ent), TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
        	StunSapper_Sapped[ent] = GetEngineTime();
       	}
    }
	return Plugin_Stop;
}
//Yes, I have to create two timers just to handle one attribute, and yes it's a crudy way to do this, I know.
//But it's really the one way I know I can do it
public Action:Timer_RemoveStun(Handle:timer, any:ref)
{
	new ent = EntRefToEntIndex(ref);
	if(ent > 0 && ent < 2049 && IsValidEntity(ent) && GetEngineTime() <= StunSapper_Sapped[ent] + StunSapper_Dur[ent])
	{
		SetEntProp(ent, Prop_Data, "m_bDisabled", true);
		StunSapper[ent] = false;
	}
	if(GetEngineTime() >= StunSapper_Sapped[ent] + StunSapper_Dur[ent])
	{
		SetEntProp(ent, Prop_Data, "m_bDisabled", false);
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public OnEntityDestroyed(Ent)
{
	if (Ent <= 0 || Ent > 2048) return;
	
	OnHitIgnite[Ent] = false;
	OnHitIgnite_Dur[Ent] = 0.0;
	OnHitIgnite_SelfDur[Ent] = 0.0;
	MinicritStunnedPlayers[Ent] = false;
	KillsChargeItems[Ent] = false;
	KillsChargeItems_Mult[Ent] = 0.0;
	DMGDealtHeals[Ent] = false;
	DMGDealtHeals_Mult[Ent] = 0.0;
	StunSapper[Ent] = false;
	StunSapper_Dur[Ent] = 0.0;
	MilkExplosionOnDeath[Ent] = false;
	MilkExplosionOnDeath_Radius[Ent] = 0.0;
	MilkExplosionOnDeath_Dur[Ent] = 0.0;
	MilkOnHit[Ent] = false;
	MilkOnHit_Dur[Ent] = 0.0;
	MeleeHitRecharge[Ent] = false;
	OneShotNoAmmo[Ent] = false;
	m_bUsesCloakForAmmo[Ent] = false;
	m_flUsesCloakForAmmo[Ent] = 0.0;
	m_bDMGVulnOnHit[Ent] = false;
	m_flDMGVulnOnHit[Ent] = 0.0;
	m_flDMGVulnOnHit_Drain[Ent] = 0.0;
	m_bSlowOnHitStacks[Ent] = false;
	m_flSlowOnHitStacks[Ent] = 0.0;
	m_iSlowOnHitStacks_Max[Ent] = 0;
	m_flSlowOnHitStacks_Dur[Ent] = 0.0;
}
public CW3_OnWeaponRemoved(slot, client)
{
	m_bHasAttribute[client][slot] = false;
}