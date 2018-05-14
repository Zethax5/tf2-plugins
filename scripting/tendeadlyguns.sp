
/*
henlo
//===============================================================\\
//				  	   	[ DEFINITIONS ]	   	  				     \\
//===============================================================\\
The section where I define all the variables and functions
*/

#pragma semicolon 1
#include <sourcemod>
#include <cw3-attributes>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>
#include <tf2>
#include <tf2attributes>
#include <zethax>
#include <smlib>

#define PLUGIN_NAME "Ten Deadly Guns"
#define PLUGIN_AUTHOR "Zethax"
#define PLUGIN_DESC "An attribute pack containing attributes for some of the deadliest weapons known to Mann."
#define PLUGIN_VERSION "non-public release 1"

//SOUNDS
#define SOUND_PLAGUE					"items/powerup_pickup_plague_infected.wav"
#define SOUND_BOLTHEAL					"weapons/fx/rics/arrow_impact_crossbow_heal.wav"
#define SOUND_DISPENSERHEAL				"weapons/dispenser_heal.wav"
#define SOUND_MAGNETRELEASE				"vehicles/crane/crane_magnet_release.wav"
#define SOUND_HELI					"npc/attack_helicopter/aheli_charge_up.wav"

//PARTICLES
#define PARTICLE_SHIELD					"powerup_supernova_ready"

public Plugin:myinfo = {
	name = PLUGIN_NAME,
	author = PLUGIN_AUTHOR,
	description = PLUGIN_DESC,
	version = PLUGIN_VERSION,
	url = ""
};

/*

	Attributes in this pack:
		-1: "damage builds accuracy"
			Dealing damage builds damage charge on a weapon, which increases its accuracy based on this charge
				*1: Maximum amount of damage required to fill meter
				*2: Amount of damage to drain per shot
				*3: Accuracy value at full charge
		
		-2: "accuracy boosts firing speed"
			Hitting a certain number of pellets on the enemy will multiply the attack delay
				1: Multiplier for next attack 
				2: Number of pellets to hit for attack boost
				3: Base damage for every pellet being fired
			
		-3: "direct hits reload and boost firing speed"
			Direct hits will multiply the attack delay, and can reload shots into the clip
				1: How many shots get reloaded into the clip on direct hit, set to 0 for none
				2: The multiplier for the attack delay
			Note: With this attribute installed grenades will explode on contact with surfaces
				
		-4: "torching increases afterburn dmg"
			Direct damage with a flamethrower will increase afterburn damage to the victim depending on how long they took direct damage
				1: Maximum afterburn damage multiplier
				2: Minimum amount of time required to reach max afterburn damage
				
		-5: "invigoration ubercharge"
			Changes Ubercharge to restore the patient to 200% max health and cast a shield over them
				1: Duration of the shield
				2: % of ubercharge to drain per ubercharge
				
		-6: "damage charges ubercharge"
			Allows damage dealt by both you and your patient to charge your ubercharge meter
				1: % of damage you deal to charge your uber, ranging from 0 to 1
				2: % of damage your patient deals to charge your uber, ranging from 0 to 1
				3: Maximum % of uber loss from dealing damage if damage is dealt within a 0.5s time frame
					This is to prevent Pyros and Heavies from becoming ubercharge generators for any Medic who pockets them
					
		-7: "dispenser ubercharge"
			Changes Ubercharge to create a radial effect that grants nearby allies 25% faster firing and reload speed
			Grants you and your patient exclusively 50% faster firing and reload speed, and a massive speed boost
				1: Radius of the radial effect, in hammer units
				
		-8: "buff ubercharge"
			Changes Ubercharge to grant your patient all 3 buff banner effects for a given length of time
				1: Duration of the effects
				2: % of ubercharge to drain per use

*/

//Values for the attribute "damage builds accuracy"
new bool:DmgBuildsAccuracy[2049];
new Float:DmgBuildsAccuracy_MaxCharge[2049];
new Float:DmgBuildsAccuracy_Charge[2049];
new Float:DmgBuildsAccuracy_Drain[2049];
new Float:DmgBuildsAccuracy_MaxAccuracy[2049];

//Values for the attribute "accuracy boosts firing speed"
new bool:AccuracyBoostSpeed[2049];
new Float:AccuracyBoostSpeed_Mult[2049];
new AccuracyBoostSpeed_Pellets[2049]; //This represents how many pellets you need to hit for the firing bonus to apply
new Float:AccuracyBoostSpeed_Dmg[2049]; //This uses the base damage for each pellet being fired

//Values for the attribute "direct hits reload and boost firing speed"
new bool:DirectHitRewards[2049];
new DirectHitRewards_Reload[2049];
new Float:DirectHitRewards_Mult[2049];
new Float:DirectHitRewards_Dmg[2049]; //Base damage of the weapon, so as to reward the actual direct hits
new DirectHitRewards_MaxClip[2049]; //Stores the weapon's max clip value for later use
new DirectHitRewards_Slot[2049];

//Values for the attribute "torching increases afterburn dmg"
new bool:TorchingMultAfterburn[2049];
new Float:TorchingMultAfterburn_Counter[MAXPLAYERS + 1]; //Used for the very hackish way I'm gonna go about this
new Float:TorchingMultAfterburn_Delay[2049];

//Values for the attribute "curse players on kill"
new bool:CurseOnkill[2049];
new Float:CurseOnkill_Radius[2049];
new Float:CurseOnkill_Dur[2049];
new Float:CurseOnkill_Restore[2049];
new Float:CurseOnkill_Delay[2049];
new Float:CurseOnkill_Charge[2049];
new Float:CurseOnkill_MaxCharge[2049];
new bool:Cursed[MAXPLAYERS + 1];
new Float:Cursed_DmgTaken[MAXPLAYERS + 1];
new Cursed_Slot[MAXPLAYERS + 1];

//Values for the attribute "invigoration ubercharge"
new bool:Invig[2049];
new Float:Invig_Drain[2049];
new Float:Invig_Dur[2049];
new Float:Invig_Delay[2049];
new Invig_Particle[MAXPLAYERS + 1];

//Values for the attribute "damage charges ubercharge"
new bool:DamageChargesUber[2049];
new Float:DamageChargesUber_Self[2049];
new Float:DamageChargesUber_Patient[2049];
new Float:DamageChargesUber_Minimum[2049]; //Used to define the maximum amount of uber loss for prolonged damage dealing
new Float:DamageChargesUber_Counter[2049]; //Used to track how many times one has dealt damage in the past 0.5s
new Float:DamageChargesUber_Delay[2049];

//Values for the attribute "dispenser ubercharge"
new bool:DispenserUbercharge[2049];
new Float:DispenserUbercharge_Radius[2049];
new bool:DispenserUbercharge_Ubered[2049];

//Values for the attribute "buff ubercharge"
new bool:BuffUber[2049];
new Float:BuffUber_Drain[2049];
new Float:BuffUber_Dur[2049];

new Float:LastTick[MAXPLAYERS + 1];

public OnPluginStart() { //2-1

	HookEvent("player_death", Event_Death);
	HookEvent("projectile_direct_hit", DirectHitRewards_OnDirectHit);
	
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
	SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
	SDKHook(client, SDKHook_PreThink, OnClientPreThink);
}

public OnMapStart()
{
	PrecacheSound(SOUND_BOLTHEAL, true);
	PrecacheSound(SOUND_PLAGUE, true);
	PrecacheSound(SOUND_DISPENSERHEAL, true);
	PrecacheSound(SOUND_MAGNETRELEASE, true);
	PrecacheSound(SOUND_HELI, true);
	PrecacheParticle(PARTICLE_SHIELD);
}

/*
//===============================================================\\
//						  [ ALGORITHMS ]						 \\
//===============================================================\\
You know, the things that do all the actual work in the plugin
*/

///////////////////////////////////////////////////////////////////
//Stuff for the "damage builds accuracy" attribute
static DmgBuildsAccuracy_OnTakeDamageAlive(client, weapon, Float:damage)
{
	new slot = GetPlayerWeaponSlot(client, 0);
	if (slot < 0 || !DmgBuildsAccuracy[slot])
		slot = GetPlayerWeaponSlot(client, 1);
	if(slot < 0 || !DmgBuildsAccuracy[slot])
		return;
		
	if (DmgBuildsAccuracy[weapon])return;
	
	DmgBuildsAccuracy_Charge[slot] += damage;
	if(DmgBuildsAccuracy_Charge[slot] > DmgBuildsAccuracy_MaxCharge[slot]) 
		DmgBuildsAccuracy_Charge[slot] = DmgBuildsAccuracy_MaxCharge[slot];
	
	TF2Attrib_SetByName(slot, "weapon spread bonus", 1.0 - (DmgBuildsAccuracy_MaxAccuracy[slot] * (DmgBuildsAccuracy_Charge[slot] / DmgBuildsAccuracy_MaxCharge[slot])));
}



///////////////////////////////////////////////////////////////////
//Stuff for the "accuracy boosts firing speed" attribute
static AccuracyBoostSpeed_OnTakeDamage(weapon, Float:damage)
{
	if (!AccuracyBoostSpeed[weapon])return;
	
	//Thanks to OnTakeDamage using uncalculated damage, and just base damage, stuff like this is possible
	//If the damage dealt, when divided by the base damage of each pellet, is greater than or equal to the minimum number of pellets required
	if((damage / AccuracyBoostSpeed_Dmg[weapon]) >= AccuracyBoostSpeed_Pellets[weapon])
		TF2Attrib_SetByName(weapon, "fire rate bonus", AccuracyBoostSpeed_Mult[weapon]);
		//Multiply the attack delay by the weapon boost
}



///////////////////////////////////////////////////////////////////
//Stuff for the "direct hit reloads and boosts firing speed" attribute
//My God that is a long ass name

//This shit just straight up don't work
/*
public DirectHitRewards_StartTouch(entity, other)
{
	new owner = ReturnOwner(entity);
	if (!IsValidClient(owner))return;
	
	new weapon = GetPlayerWeaponSlot(owner, 0);
	if (weapon < 0 || !DirectHitRewards[weapon])return;
	
	if(IsValidClient(other))
	{
		TF2Attrib_SetByName(weapon, "fire rate bonus", DirectHitRewards_Mult[weapon]);
		
		if(DirectHitRewards_Reload[weapon] > 0)
		{
			new clip = GetClip_Weapon(weapon); //This chunk adds the extra shots to the weapon's clip, and makes sure it doesn't overload
			clip += DirectHitRewards_Reload[weapon];
			if(clip > DirectHitRewards_MaxClip[weapon])
				clip = DirectHitRewards_MaxClip[weapon];
					
			SetClip_Weapon(weapon, clip); //This actually sets the clip
		}
	}
}
*/

//FINALLY A METHOD THAT FUCKING WORKS
public Action:DirectHitRewards_OnDirectHit(Handle:event, const String:name[], bool:dontBroadcast)
{
	//PrintToChatAll("yeah, a projectile hit someone");
	new attacker = GetEventInt(event, "attacker");
	if (!IsValidClient(attacker))return Plugin_Continue;
	
	//PrintToChat(attacker, "attacker identified");
	
	new weapon = GetActiveWeapon(attacker);
	if (weapon < 0)return Plugin_Continue;
	
	//PrintToChat(attacker, "weapon identified");
	
	if(DirectHitRewards[weapon])
	{
		//PrintToChat(attacker, "weapon check complete");
		TF2Attrib_SetByName(weapon, "fire rate bonus", DirectHitRewards_Mult[weapon]);
		
		if(DirectHitRewards_Reload[weapon] > 0)
		{
			//PrintToChat(attacker, "reloading shot");
			new clip = GetClip_Weapon(weapon); //This chunk adds the extra shots to the weapon's clip, and makes sure it doesn't overload
			clip += DirectHitRewards_Reload[weapon];
			if(clip > DirectHitRewards_MaxClip[weapon])
				clip = DirectHitRewards_MaxClip[weapon];
					
			SetClip_Weapon(weapon, clip); //This actually sets the clip
		}
	}
	//PrintToChat(attacker, "process finished");
	return Plugin_Continue;
}

//This doesn't work on enemies with fucking damage resistances FUCK'
/*
static DirectHitRewards_OnTakeDamage(weapon, Float:damage, damagetype)
{
	if (!DirectHitRewards[weapon])return;
	
	new Float:flDmg = damage; //This little chunk is just to decipher if the damage dealt is critical
	if((damagetype & DMG_CRIT) == DMG_CRIT)
		flDmg *= 1 / 3;
		
	if(flDmg >= DirectHitRewards_Dmg[weapon]) //If the damage dealt is at least equal with the stated base damage of the weapon
	{
		if(DirectHitRewards_Reload[weapon] > 0) //If the attribute says the weapon reloads on direct hits
		{
			new clip = GetClip_Weapon(weapon); //This chunk adds the extra shots to the weapon's clip, and makes sure it doesn't overload
			clip += DirectHitRewards_Reload[weapon];
			if(clip > DirectHitRewards_MaxClip[weapon])
				clip = DirectHitRewards_MaxClip[weapon];
				
			SetClip_Weapon(weapon, clip); //This actually sets the clip
		}
		
		//Multiplies the attack delay by the weapon boost
		SetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack", GetEntPropFloat(weapon, Prop_Send, "m_flNextPrimaryAttack") * DirectHitRewards_Mult[weapon]);
	}
}
*/



///////////////////////////////////////////////////////////////////
//Stuff for the attribute "torching increases afterburn dmg"

static TorchingMultAfterburn_OnTakeDamage(weapon, victim, damagetype)
{
	if (weapon < 0 || weapon > 2048)return;
	
	if (!TorchingMultAfterburn[weapon])return;
	if (damagetype != 16779264)return;
	
	if(GetEngineTime() >= TorchingMultAfterburn_Delay[victim] + 1.0)
		TorchingMultAfterburn_Counter[victim] = 0.0;
	
	TorchingMultAfterburn_Counter[victim]++;
	if(TorchingMultAfterburn_Counter[victim] > 20.0)
		TorchingMultAfterburn_Counter[victim] = 20.0;
		
	TorchingMultAfterburn_Delay[victim] = GetEngineTime();
}



///////////////////////////////////////////////////////////////////
//Stuff for the attribute "curse players on kill"
static CurseOnkill_OnKill(attacker, victim, weapon)
{
	if(CurseOnkill[weapon] && CurseOnkill_Charge[weapon] >= CurseOnkill_MaxCharge[weapon])
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			new Float:Pos1[3];
			GetClientAbsOrigin(victim, Pos1);
			if(IsValidClient(i) && GetClientTeam(i) == GetClientTeam(victim) && i != victim)
			{
				new Float:Pos2[3];
				GetClientAbsOrigin(i, Pos2);
				
				new Float:distance = GetVectorDistance(Pos1, Pos2);
				
				if(distance <= CurseOnkill_Radius[weapon])
				{
					Cursed[i] = true;
					CurseOnkill_Restore[i] = CurseOnkill_Restore[weapon];
					CurseOnkill_Dur[i] = CurseOnkill_Dur[weapon];
					CurseOnkill_Delay[i] = GetEngineTime();
					Cursed_Slot[i] = GetActiveWeapon(i);
					TF2Attrib_SetByName(GetActiveWeapon(i), "health from healers reduced", 0.0);
					TF2Attrib_SetByName(GetActiveWeapon(i), "health from packs decreased", 0.0);
					EmitSoundToClient(i, SOUND_PLAGUE);
					CurseOnkill_Charge[weapon] = 0.0;
				}
			}
		}
	}
	if(Cursed[victim])
	{
		if(CurseOnkill[weapon])
			HealPlayer(attacker, attacker, RoundFloat(GetClientMaxHealth(attacker) * CurseOnkill_Restore[victim]), 1.0);
		else
			HealPlayer(attacker, attacker, RoundFloat(GetClientMaxHealth(attacker) * (CurseOnkill_Restore[victim] / 2.0)), 1.0);
		Cursed[victim] = false;
		CurseOnkill_Restore[victim] = 0.0;
		CurseOnkill_Dur[victim] = 0.0;
		CurseOnkill_Delay[victim] = 0.0;
		Cursed_DmgTaken[victim] = 0.0;
		Cursed_Slot[victim] = -1;
	}
	if(Cursed[attacker])
	{
		CurseOnkill_Dur[attacker] = 0.0;
		CurseOnkill_Delay[attacker] = 0.0;
	}
}



//////////////////////////////////////////////////////////////////////
//Stuff for the Invigorator Ubercharge attribute
static Invig_PreThink(client)
{
	if (!IsValidClient(client))return;
	
	new weapon = GetActiveWeapon(client);
	if (weapon < 0)return;
	
	if (!Invig[weapon])return;
	
	new buttons = GetClientButtons(client);
	new Float:ubercharge = GetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel");
	
	if((buttons & IN_ATTACK2) == IN_ATTACK2)
	{
		new patient = GetMediGunPatient(client);
		if(ubercharge >= Invig_Drain[weapon])
		{
			if(IsValidClient(patient) && Invig_Dur[patient] == 0.0)
			{
				SetEntityHealth(patient, GetClientMaxHealth(patient) * 2);
				Invig_Dur[patient] = Invig_Dur[weapon];
				Invig_Delay[patient] = GetEngineTime();
				Invig_Particle[patient] = AttachParticle(patient, PARTICLE_SHIELD, -1.0);
				EmitSoundToAll(SOUND_BOLTHEAL, patient);
				ubercharge -= 0.25;
				SetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel", ubercharge);
			}
			else if(Invig_Dur[client] == 0.0)
			{
				SetEntityHealth(client, GetClientMaxHealth(client) * 2);
				Invig_Dur[client] = Invig_Dur[weapon];
				Invig_Delay[client] = GetEngineTime();
				Invig_Particle[client] = AttachParticle(client, PARTICLE_SHIELD, -1.0);
				EmitSoundToAll(SOUND_BOLTHEAL, client);
				ubercharge -= 0.25;
				SetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel", ubercharge);
			}
		}
	}
	if(ubercharge >= 0.99)
			SetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel", 0.99);
}



///////////////////////////////////////////////////////////////////
//Stuff for the attribute "damage charges ubercharge"
static DamageChargesUber_OnTakeDamageAlive(attacker, Float:damage)
{
	if (!IsValidClient(attacker))return;
	
	if (GetEntProp(attacker, Prop_Send, "m_nNumHealers") > 0) //If the attacker is being healed by a medic with this damage charging attribute
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if (!IsValidClient(i))continue;
			if (GetMediGunPatient(i) != attacker)continue;
			
			new medigun = GetActiveWeapon(i);
			if (!DamageChargesUber[medigun])continue;
			
			if(GetEngineTime() >= DamageChargesUber_Delay[medigun] + 0.5)
				DamageChargesUber_Counter[medigun] = 0.0;
			
			new Float:ubercharge = GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");
			ubercharge += (damage / 100.0) * (DamageChargesUber_Patient[medigun] * (1.0 - (DamageChargesUber_Minimum[medigun] * DamageChargesUber_Counter[medigun])));
			if(ubercharge > 1.0)
				ubercharge = 1.0;
			SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", ubercharge);
			
			DamageChargesUber_Counter[medigun] += 0.1;
			DamageChargesUber_Delay[medigun] = GetEngineTime();
			
			break;
		}
	}
	//At this point we can assume the attacker is not being healed, and that the attacker is the medic himself
	//Gotta add some extra checks just in case though
	new medigun = GetPlayerWeaponSlot(attacker, 1);
	if (medigun < 0 || medigun > 2048)return;
	if (!DamageChargesUber[medigun])return;
	
	if(GetEngineTime() >= DamageChargesUber_Delay[medigun] + 0.5)
			DamageChargesUber_Counter[medigun] = 0.0;
	
	new Float:ubercharge = GetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel");
	new Float:gain = (damage / 100.0) * (DamageChargesUber_Self[medigun] * (1.0 - (DamageChargesUber_Minimum[medigun] * DamageChargesUber_Counter[medigun])));
	if(gain < 0.0) gain = 0.0
	ubercharge += gain;
	if(ubercharge > 1.0)
		ubercharge = 1.0;
	SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", ubercharge);
	
	DamageChargesUber_Counter[medigun] += 0.1;
	DamageChargesUber_Delay[medigun] = GetEngineTime();
}



///////////////////////////////////////////////////////////////////
//Stuff for the attribute "dispenser ubercharge"
static DispenserUbercharge_PreThink(client)
{
	if (!IsValidClient(client))return;
	
	if(DispenserUbercharge_Ubered[client] && GetEntProp(client, Prop_Send, "m_nNumHealers") == 0)
		DispenserUbercharge_Ubered[client] = false;
	
	new medigun = GetPlayerWeaponSlot(client, 1);
	if (medigun < 0 || medigun > 2048)return;
	if (!DispenserUbercharge[medigun])return;
	
	new patient = GetMediGunPatient(client);
	
	if(GetEntProp(medigun, Prop_Send, "m_bChargeRelease"))
	{
		if(IsValidClient(patient))
		{
			TF2_AddCondition(patient, TFCond_RuneHaste, 1.0);
			if(!DispenserUbercharge_Ubered[patient])
			{
				DispenserUbercharge_Ubered[patient] = true;
				EmitSoundToAll(SOUND_MAGNETRELEASE, client);
				EmitSoundToAll(SOUND_HELI, client);
			}
		}
			
		ApplyRadiusEffects(client, client, patient, DispenserUbercharge_Radius[medigun], 113, 20, 1.0, 1.0, 1, true);
		
		if(GetActiveWeapon(client) == medigun)
			TF2_AddCondition(client, TFCond_RuneHaste, 1.0);
		
		if(!DispenserUbercharge_Ubered[medigun])
		{
			EmitSoundToAll(SOUND_MAGNETRELEASE, client);
			EmitSoundToAll(SOUND_DISPENSERHEAL, client);
			DispenserUbercharge_Ubered[medigun] = true;
		}
	}
	if(DispenserUbercharge_Ubered[medigun] && !GetEntProp(medigun, Prop_Send, "m_bChargeRelease"))
		DispenserUbercharge_Ubered[medigun] = false;
		
	if(IsValidClient(patient) && DispenserUbercharge_Ubered[patient] && !GetEntProp(medigun, Prop_Send, "m_bChargeRelease"))
		DispenserUbercharge_Ubered[patient] = false;
}



///////////////////////////////////////////////////////////////////
//Stuff for the attribute "buff ubercharge"
static BuffUber_PreThink(client)
{
	if (!IsValidClient(client))return;
	
	new weapon = GetActiveWeapon(client);
	if (weapon < 0 || weapon > 2048)return;
	if (!BuffUber[weapon])return;
	
	new Float:ubercharge = GetEntPropFloat(weapon, Prop_Send, "m_flChargeLevel");
	new buttons = GetClientButtons(client);
	
	if((buttons & IN_ATTACK2) == IN_ATTACK2 && ubercharge >= BuffUber_Drain[weapon])
	{
		new patient = GetMediGunPatient(client);
		if(IsValidClient(patient))
		{
			if(!TF2_IsPlayerInCondition(patient, TFCond_Buffed)
				TF2_AddCondition(patient, TFCond_Buffed, BuffUber_Dur[weapon]);
			if(!TF2_IsPlayerInCondition(patient, TFCond:26)
				TF2_AddCondition(patient, TFCond:26, BuffUber_Dur[weapon]);
			if(!TF2_IsPlayerInCondition(patient, TFCond:29)
				TF2_AddCondition(patient, TFCond:29, BuffUber_Dur[weapon]);
		}
		else
		{
			if(!TF2_IsPlayerInCondition(client, TFCond_Buffed)
				TF2_AddCondition(client, TFCond_Buffed, BuffUber_Dur[weapon]);
			if(!TF2_IsPlayerInCondition(client, TFCond:26)
				TF2_AddCondition(client, TFCond:26, BuffUber_Dur[weapon]);
			if(!TF2_IsPlayerInCondition(client, TFCond:29)
				TF2_AddCondition(client, TFCond:29, BuffUber_Dur[weapon]);
		}
		ubercharge -= BuffUber_Drain[weapon];
		SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", ubercharge);
	}
	
	if(ubercharge >= 0.99)
		SetEntPropFloat(medigun, Prop_Send, "m_flChargeLevel", 0.99);
}

/*
//===============================================================\\
//						[ CORE FUNCTIONS ]						 \\
//===============================================================\\
The things that tell the algorithms to get off their asses
*/

  ////////////////////////////////////
 //////// ATTACK BASED EVENTS ///////
////////////////////////////////////


public Action:TF2_CalcIsAttackCritical(client, weapon, String:weaponname[], &bool:result)
{
	new Action:action;
	
	if (!IsValidClient(client))return action;
	if (weapon < 0 || weapon > 2048)return action;
	
	//If the weapon firing has the "damage builds accuracy" attribute AND its damage is greater than 0
	if(DmgBuildsAccuracy[weapon] && DmgBuildsAccuracy_Charge[weapon] > 0.0)
		CreateTimer(0.0, DmgBuildsAccuracy_DrainDelay, EntIndexToEntRef(weapon), TIMER_FLAG_NO_MAPCHANGE);
		
	if(AccuracyBoostSpeed[weapon] || DirectHitRewards[weapon])
		CreateTimer(0.0, RemoveFireRateBonus, EntIndexToEntRef(weapon), TIMER_FLAG_NO_MAPCHANGE);
	
	return action;
}

public Action:Event_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new weapon = LastWeaponHurtWith[attacker];
	
	new Action:action;
	
	if (!IsValidClient(attacker))return action;
	if (!IsValidClient(victim))return action;
	
	CurseOnkill_OnKill(attacker, victim, weapon);
	
	if(Invig_Dur[victim] > 0.0)
	{
		CreateTimer(0.0, RemoveParticle, Invig_Particle[victim]);
		Invig_Particle[victim] = 0;
		Invig_Dur[victim] = 0.0;
	}
	
	return action;
}

  ////////////////////////////////////
 //////// DAMAGE BASED EVENTS ///////
////////////////////////////////////

//OnTakeDamage, a place where I put attributes that modify damage.
//However, you may find the occasional attribute in here that's based on accuracy
//OnTakeDamage is great for something like that, because the only damage value you get is the base damage
public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3])
{
	new Action:action;
	
	if (!IsValidClient(attacker))return action;
	if (!IsValidClient(victim))return action;
	if (weapon < 0 || weapon > 2048)return action;
	
	AccuracyBoostSpeed_OnTakeDamage(weapon, damage);
	TorchingMultAfterburn_OnTakeDamage(weapon, victim, damagetype);
	
	if(TorchingMultAfterburn_Counter[victim] > 0.0 && damagetype == 2056)
	{
		//PrintToChat(attacker, "%i", RoundFloat(TorchingMultAfterburn_Counter[victim]));
		new Float:bonus = TorchingMultAfterburn_Counter[victim] / 20.0;
		damage *= 1.0 + bonus;
		action = Plugin_Changed;
	}
	if(Invig_Dur[victim] > 0.0 && GetClientHealth(victim) > GetClientMaxHealth(victim))
	{
		damage *= 0.65;
		action = Plugin_Changed;
	}
	
	//DirectHitRewards_OnTakeDamage(weapon, damage, damagetype);
	
	LastWeaponHurtWith[attacker] = weapon;
	
	return action;
}

//OnTakeDamageAlive, a place where I put pretty much anything that doesn't modify damage
//Also useful for attributes that need precise numbers, such as anything that builds charge through dealing damage, as this calculates that
public Action:OnTakeDamageAlive(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3])
{
	new Action:action;
	
	if (!IsValidClient(attacker))return action;
	if (!IsValidClient(victim))return action;
	if (weapon < 0 || weapon > 2048)return action;
	
	DmgBuildsAccuracy_OnTakeDamageAlive(attacker, weapon, damage);
	DamageChargesUber_OnTakeDamageAlive(attacker, damage);
	
	if(Cursed[victim])
		Cursed_DmgTaken[victim] += damage;
		
	if(CurseOnkill[weapon] && CurseOnkill_Charge[weapon] < CurseOnkill_MaxCharge[weapon])
		CurseOnkill_Charge[weapon] += damage;
	if(CurseOnkill[GetActiveWeapon(victim)] && CurseOnkill_Charge[GetActiveWeapon(victim)] < CurseOnkill_MaxCharge[GetActiveWeapon(victim)])
		CurseOnkill_Charge[GetActiveWeapon(victim)] += damage;
	
	return action;	
}

  ////////////////////////////////////
 ///////// TIME BASED EVENTS ////////
////////////////////////////////////

public OnClientPreThink(client)
{
	if (!IsValidClient(client))return;
	new weapon = GetActiveWeapon(client);
	
	if(GetEngineTime() >= LastTick[client] + 0.1)
	{
		Invig_PreThink(client);
		DispenserUbercharge_PreThink(client);
		
		if(CurseOnkill[weapon] && CurseOnkill_Charge[weapon] < CurseOnkill_MaxCharge[weapon])
			CurseOnkill_Charge[weapon]++;
		
		LastTick[client] = GetEngineTime();
	}
	
	if(Cursed[client])
	{
		if(GetEngineTime() >= CurseOnkill_Delay[client] + CurseOnkill_Dur[client])
		{
			HealPlayer(client, client, RoundFloat(Cursed_DmgTaken[client]), 1.0);
			TF2Attrib_RemoveByName(Cursed_Slot[client], "health from healers reduced");
			TF2Attrib_RemoveByName(Cursed_Slot[client], "health from packs decreased");
			EmitSoundToClient(client, SOUND_BOLTHEAL);
			
			Cursed[client] = false;
			CurseOnkill_Restore[client] = 0.0;
			Cursed_DmgTaken[client] = 0.0;
			CurseOnkill_Dur[client] = 0.0;
			Cursed_Slot[client] = -1;
		}
	}
	
	if(Invig_Dur[client] > 0.0 && GetClientHealth(client) < GetClientMaxHealth(client) + 1)
	{
		CreateTimer(0.0, RemoveParticle, Invig_Particle[client]);
		Invig_Particle[client] = 0;
		Invig_Dur[client] = 0.0;
	}
}

public Action:RemoveParticle(Handle:timer, any:particle) //Chawlz' code
{
	if(particle >= 0 && IsValidEntity(particle))
	{
		new String:classname[32];
		GetEdictClassname(particle, classname, sizeof(classname));
		if(StrEqual(classname, "info_particle_system", false))
		{
			AcceptEntityInput(particle, "Stop");
			AcceptEntityInput(particle, "Kill");
			AcceptEntityInput(particle, "Deactivate");
			particle = -1;
		}
	}
}

//Drains the accuracy charge on weapons with the "damage builds accuracy" attribute
public Action:DmgBuildsAccuracy_DrainDelay(Handle:timer, any:data)
{
	new weapon = EntRefToEntIndex(data); //Gets the weapon
	
	DmgBuildsAccuracy_Charge[weapon] -= DmgBuildsAccuracy_Drain[weapon];
	if(DmgBuildsAccuracy_Charge[weapon] < 0.0)
		DmgBuildsAccuracy_Charge[weapon] = 0.0;
	
	TF2Attrib_SetByName(weapon, "weapon spread bonus", 1.0 - (DmgBuildsAccuracy_MaxAccuracy[weapon] * (DmgBuildsAccuracy_Charge[weapon] / DmgBuildsAccuracy_MaxCharge[weapon])));
	
	return;
}

public Action:RemoveFireRateBonus(Handle:timer, any:data)
{
	new weapon = EntRefToEntIndex(data);
	
	TF2Attrib_RemoveByName(weapon, "fire rate bonus");
	
	return;
}


  ////////////////////////////////////
 //////// MISCELLANEOUS EVENTS //////
////////////////////////////////////

//OnAddAttribute, the event that does all the custom weapon stuff
//It's the very event that makes this entire thing work
public Action:CW3_OnAddAttribute(slot, client, const String:attrib[], const String:plugin[], const String:value[], bool:whileActive)
{
	if (!StrEqual(plugin, "tendeadlyguns"))return Plugin_Continue;
	new weapon = GetPlayerWeaponSlot(client, slot);
	new Action:action;
	
	if(StrEqual(attrib, "damage builds accuracy"))
	{
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		DmgBuildsAccuracy_MaxCharge[weapon] = StringToFloat(values[0]);
		DmgBuildsAccuracy_Drain[weapon] = StringToFloat(values[1]);
		DmgBuildsAccuracy_MaxAccuracy[weapon] = StringToFloat(values[2]);
		
		DmgBuildsAccuracy[weapon] = true;
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "accuracy boosts firing speed"))
	{
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		AccuracyBoostSpeed_Mult[weapon] = StringToFloat(values[0]);
		AccuracyBoostSpeed_Pellets[weapon] = StringToInt(values[1]);
		AccuracyBoostSpeed_Dmg[weapon] = StringToFloat(values[2]);
		
		AccuracyBoostSpeed[weapon] = true;
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "direct hits reload and boost firing speed"))
	{
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		DirectHitRewards_Reload[weapon] = StringToInt(values[0]);
		DirectHitRewards_Mult[weapon] = StringToFloat(values[1]);
		//DirectHitRewards_Dmg[weapon] = StringToFloat(values[2]);
		
		DirectHitRewards_MaxClip[weapon] = GetClip_Weapon(weapon);
		
		DirectHitRewards[weapon] = true;
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "torching increases afterburn dmg"))
	{
		TorchingMultAfterburn[weapon] = true;
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "curse players on kill"))
	{
		new String:values[4][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		CurseOnkill_Dur[weapon] = StringToFloat(values[0]);
		CurseOnkill_MaxCharge[weapon] = StringToFloat(values[1]);
		CurseOnkill_Radius[weapon] = StringToFloat(values[2]);
		CurseOnkill_Restore[weapon] = StringToFloat(values[3]);
		
		CurseOnkill[weapon] = true;
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "invigoration ubercharge"))
	{
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		Invig_Drain[weapon] = StringToFloat(values[0]);
		Invig_Dur[weapon] = StringToFloat(values[1]);
		
		Invig[weapon] = true;
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "damage charges ubercharge"))
	{
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		DamageChargesUber_Self[weapon] = StringToFloat(values[0]);
		DamageChargesUber_Patient[weapon] = StringToFloat(values[1]);
		DamageChargesUber_Minimum[weapon] = StringToFloat(values[2]);
		
		DamageChargesUber[weapon] = true;
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "dispenser ubercharge"))
	{
		DispenserUbercharge_Radius[weapon] = StringToFloat(value);
		
		TF2Attrib_SetByName(weapon, "medigun charge is crit boost", -1.0);
		
		DispenserUbercharge[weapon] = true;
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "buff ubercharge"))
	{
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		BuffUber_Drain[weapon] = StringToFloat(values[0]);
		BuffUber_Dur[weapon] = StringToFloat(values[1]);
		
		BuffUber[weapon] = true;
		action = Plugin_Handled;
	}
	
	return action;
}

///////////////////////////////////////////////////////////////////
//OnEntityDestroyed, the event that clears custom attributes when a weapon is destroyed
//Without it, custom attributes would probably carry over to other weapons
public OnEntityDestroyed(Ent)
{
	if (Ent < 0 || Ent > 2048)return;
	
	DmgBuildsAccuracy[Ent] = false;
	DmgBuildsAccuracy_Drain[Ent] = 0.0;
	DmgBuildsAccuracy_Charge[Ent] = 0.0;
	DmgBuildsAccuracy_MaxCharge[Ent] = 0.0;
	DmgBuildsAccuracy_MaxAccuracy[Ent] = 0.0;
	
	AccuracyBoostSpeed[Ent] = false;
	AccuracyBoostSpeed_Dmg[Ent] = 0.0;
	AccuracyBoostSpeed_Mult[Ent] = 0.0;
	AccuracyBoostSpeed_Pellets[Ent] = 0;
	
	DirectHitRewards[Ent] = false;
	DirectHitRewards_Dmg[Ent] = 0.0;
	DirectHitRewards_Mult[Ent] = 0.0;
	DirectHitRewards_Reload[Ent] = 0;
	DirectHitRewards_MaxClip[Ent] = 0;
	DirectHitRewards_Slot[Ent] = 0;
	
	TorchingMultAfterburn[Ent] = false;
	
	CurseOnkill[Ent] = false;
	CurseOnkill_Dur[Ent] = 0.0;
	CurseOnkill_MaxCharge[Ent] = 0.0;
	CurseOnkill_Charge[Ent] = 0.0;
	CurseOnkill_Restore[Ent] = 0.0;
	CurseOnkill_Radius[Ent] = 0.0;
	
	Invig[Ent] = false;
	Invig_Drain[Ent] = 0.0;
	Invig_Dur[Ent] = 0.0;
	Invig_Delay[Ent] = 0.0;
	
	DamageChargesUber[Ent] = false;
	DamageChargesUber_Self[Ent] = 0.0;
	DamageChargesUber_Patient[Ent] = 0.0;
	DamageChargesUber_Minimum[Ent] = 0.0;
	DamageChargesUber_Counter[Ent] = 0.0;
	
	DispenserUbercharge[Ent] = false;
	DispenserUbercharge_Radius[Ent] = 0.0;
	
	BuffUber[Ent] = false;
	BuffUber_Drain[Ent] = 0.0;
	BuffUber_Dur[Ent] = 0.0;
}

public TF2_OnConditionAdded(client, TFCond:cond)
{
	if(GetEngineTime() <= Invig_Delay[client] + Invig_Dur[client])
	{
		if(cond == TFCond_Jarated)
			TF2_RemoveCondition(client, TFCond_Jarated);
		if(cond == TFCond_Milked)
			TF2_RemoveCondition(client, TFCond_Milked);
		if(cond == TFCond_MarkedForDeath)
			TF2_RemoveCondition(client, TFCond_MarkedForDeath);
		if(cond == TFCond_Bleeding)
			TF2_RemoveCondition(client, TFCond_Bleeding);
		if(cond == TFCond_OnFire)
			TF2_RemoveCondition(client, TFCond_OnFire);
		if(cond == TFCond_Dazed)
			TF2_RemoveCondition(client, TFCond_Dazed);
	}
}
