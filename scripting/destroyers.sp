#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>
#include <tf2items>
#include <tf2attributes>
#include <cw3-attributes>
#include <tf2>
#include <zethax>
#include <smlib>

#define PLUGIN_VERSION "stable release 2"
#define SLOTS_MAX 7

public Plugin:myinfo = {
	name = "Destroyer Pack",
	author = "Zethax",
	description = "An attribute pack containing some of my newer, freelance work",
	version = PLUGIN_VERSION,
	url = ""
};

//The base values for DestroyerAttrib
new bool:DestroyerAttrib[2049];
new Float:DestroyerAttrib_Pct[2049];
//All three of these are values based on damage
new Float:DestroyerAttrib_Dmg[2049];
new Float:DestroyerAttrib_Mult[2049];
new DestroyerAttrib_EnemyHealth[2049];
//Needed to track whether or not the player has fired their power shot yet
new DestroyerAttrib_Shot[2049];
new Float:DestroyerAttrib_Delay[2049];
new Float:DestroyerAttrib_MaxDelay[2049];

//The base values for ReloadBoost
new bool:ReloadBoost[2049];
new Float:ReloadBoost_MaxCharge[2049];
new Float:ReloadBoost_MaxSpeed[2049];
new Float:ReloadBoost_MaxDelay[2049];
new Float:ReloadBoost_DrainRate[2049];
//Tracing values
new Float:ReloadBoost_Charge[2049];
new ReloadBoost_MaxClip[2049];
//Timing based values
new Float:ReloadBoost_Delay[2049];

//The base values for ExplodeOnReload
new bool:ExplodeOnReload[2049];
new Float:ExplodeOnReload_BlastRadius[2049]; //The blast radius for a rocket is 146 I think
new ExplodeOnReload_MaxDamage[2049];
new Float:ExplodeOnReload_MaxFalloff[2049];
new ExplodeOnReload_Mode[2049]; //Used to allow this attribute to tap into the ReloadBoost attribute
//Tracing values
new ExplodeOnReload_MaxClip[2049];
new bool:ExplodeOnReload_Exploded[2049];

//The base values for SteadyShot
new bool:SteadyShot[2049];
new Float:SteadyShot_MaxCharge[2049];
new Float:SteadyShot_MaxAccuracy[2049];
new Float:SteadyShot_Drain[2049];
//Tracing values
new Float:SteadyShot_Charge[2049];
//Other values
new Handle:SteadyShot_Display;

//The base values for GrenadesExplodeOnSurfaces
new bool:GrenadesExplodeOnSurfaces[2049];

//The base values for AttributeOnLastShot
new bool:AttributeOnLastShot[2049];
new Float:AttributeOnLastShot_Value[2049];
new String:AttributeOnLastShot_Attribute[2049][64];

//The base values for RefillClipOnKill
new bool:RefillClipOnKill[2049];
new RefillClipOnKill_MaxClip[2049];

//The base values for AutoMatilda
new bool:AutoMatilda[2049];
new Float:AutoMatilda_MaxCharge[2049];
new Float:AutoMatilda_ReserveCharge[2049];
new Float:AutoMatilda_DamageMultiplier[2049];

//The base values for BonusDmgOnMeleeKill
new bool:BonusDmgOnMeleeKill[2049];
new Float:BonusDmgOnMeleeKill_Mult[2049];
new BonusDmgOnMeleeKill_Shot[2049];

//The base values for BonusDmgWhileRecharging
new bool:BonusDmgWhileRecharging[2049];
new Float:BonusDmgWhileRecharging_Mult[2049];

//The base values for ReloadThisWeaponOnKill
new bool:ReloadThisWeaponOnKill[2049];
new ReloadThisWeaponOnKill_Max[2049];
new ReloadThisWeaponOnKill_Count[2049];

//The base values for SwapSpeedWhileCharged
new bool:SwapSpeedWhileCharged[2049];
new Float:SwapSpeedWhileCharged_Mult[2049];

//A universal identifier for any weapon that carries an attribute that uses the 'over damage' algorithm
new bool:HasOverDamage[2049];

//The base values for FireRateOverDamage
new bool:FireRateOverDamage[2049];
new Float:FireRateOverDamage_MaxMult[2049];
new Float:FireRateOverDamage_Delay[2049];
new Float:FireRateOverDamage_MaxDelay[2049];
new Float:FireRateOverDamage_MaxCharge[2049];
new Float:FireRateOverDamage_Charge[2049];

//The base values for ReloadRateOverDamage
new bool:ReloadRateOverDamage[2049];
new Float:ReloadRateOverDamage_MaxMult[2049];
new Float:ReloadRateOverDamage_Delay[2049];
new Float:ReloadRateOverDamage_MaxDelay[2049];
new Float:ReloadRateOverDamage_MaxCharge[2049];
new Float:ReloadRateOverDamage_Charge[2049];

//The base values for AccuracyOverDamage
new bool:AccuracyOverDamage[2049];
new Float:AccuracyOverDamage_MaxMult[2049];
new Float:AccuracyOverDamage_Delay[2049];
new Float:AccuracyOverDamage_MaxDelay[2049];
new Float:AccuracyOverDamage_MaxCharge[2049];
new Float:AccuracyOverDamage_Charge[2049];

//The base values for MinicritsAirblasted
new bool:MinicritsAirblasted[2049];

//The base values for Noburn
new bool:Noburn[2049];

//The base values for HealPlayersOnExtinguish
new bool:HealPlayersOnExtinguish[2049];
new HealPlayersOnExtinguish_Restore[2049];
new HealPlayersOnExtinguish_VictimRestore[2049];

//The base values for BurningPlayerHealsAttacker
new bool:BurningPlayerHealsAttacker[2049];
new BurningPlayerHealsAttacker_Restore[2049];
new bool:BurningPlayerHealsAttacker_Marked[MAXPLAYERS + 1];

//The base values for CozyMeter
new bool:CozyMeter[2049];
new Float:CozyMeter_Charge[2049];
new Float:CozyMeter_MaxCharge[2049];
new Float:CozyMeter_Duration[2049];
new Float:CozyMeter_Tick[2049];
new Float:CozyMeter_Slow[2049];
new Float:CozyMeter_AmmoDrain[2049]; //Increases ammo consumption from things like airblasts and firing
new bool:CozyMeter_Active[2049];
new Handle:CozyMeter_Display; //This doesn't FUCKING work for some reason

//The base values for BurnVictimsForMoveSpeed
new bool:BurnVictimsForMoveSpeed[2049];
new Float:BurnVictimsForMoveSpeed_Mult[2049];
new BurnVictimsForMoveSpeed_Stacks[2049];

//Introducing, SUB ATTRIBUTES
//Attributes that use the same base values, but won't activate without the base attribute
//Groundbreaking, I know
//Subattribute values for BurnVictimsForMoveSpeed
new bool:BurnVictimsForMoveSpeed_KillForPermaStacks[2049];
new BurnVictimsForMoveSpeed_MinStacks[2049];

new bool:BurnVictimsForMoveSpeed_DoubleStrengthWhileActive[2049];

//The base values for HellfireAttrib
new bool:HellfireAttrib[2049];
new Float:HellfireAttrib_Dur[2049];
new bool:Hellfire[MAXPLAYERS + 1]; //Used for tracking who was lit by Hellfire
new Float:Hellfire_Dur[MAXPLAYERS + 1];
new Hellfire_Igniter[MAXPLAYERS + 1];

//The base values for KnifeEffectsOnKill
new bool:KnifeEffectsOnKill[2049];
new KnifeEffectsOnKill_KnifeID[2049];
new bool:KnifeEffectsOnKill_DisableKnife[2049];

//JOKE ATTRIBUTES
new bool:MannsMeat[2049];
new bool:MannsMeat_DamageMarked[MAXPLAYERS + 1];
new bool:MannsMeat_DeathMarked[MAXPLAYERS + 1];
new bool:MannsMeat_SpeedMarked[MAXPLAYERS + 1];
new bool:MannsMeat_Marked[MAXPLAYERS + 1];
new bool:MannsMeat_Marked2[MAXPLAYERS + 1];
new MannsMeat_SpeedInflictor[MAXPLAYERS + 1];
new MannsMeat_MarkInflictor[MAXPLAYERS + 1];

//Additional values that might get used later on other attributes
new Float:OriginalDamage[MAXPLAYERS + 1];
new LastWeaponHurtWith[MAXPLAYERS + 1];
new Float:LastTick[MAXPLAYERS + 1];
new Igniter[MAXPLAYERS + 1];

public OnPluginStart() { //2-1

	HookEvent("player_death", Event_Death);
	HookEvent("player_extinguished", PlayerExtinguished_Event);
	HookEvent("player_ignited", PlayerIgnited_Event);
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i)) continue;
		{
		OnClientPutInServer(i);
		}
	}
	
	SteadyShot_Display = CreateHudSynchronizer();
	CozyMeter_Display = CreateHudSynchronizer();
}
public OnMapStart()
{
	PrecacheSound("weapons/minigun_spin.wav", true);
}
public OnClientPutInServer(client) //2-3
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
	SDKHook(client, SDKHook_PreThink, OnClientPreThink);
	
	LastWeaponHurtWith[client] = 0;
}
public OnEntityCreated(entity, const String:classname[])
{
	if(!IsValidEntity(entity)) return;
	
	GrenadesExplodeOnSurfaces_EntityCreated(entity, String:classname);
}

public Action:CW3_OnAddAttribute(slot, client, const String:attrib[], const String:plugin[], const String:value[], bool:whileActive)
{
	if(!StrEqual(plugin, "destroyers") || !StrEqual(plugin, "newzt")) return Plugin_Continue;
	new weapon = GetPlayerWeaponSlot(client, slot);
	new Action:action;
	
	if(StrEqual(attrib, "overkill damage bonus"))
	{
		if (weapon == -1)return Plugin_Continue;
		
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		DestroyerAttrib_Pct[weapon] = StringToFloat(values[0]);
		DestroyerAttrib_MaxDelay[weapon] = StringToFloat(values[1]);
		
		DestroyerAttrib_Dmg[weapon] = 0.0;
		DestroyerAttrib_Shot[weapon] = 0;
		
		DestroyerAttrib[weapon] = true;
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "build reload boost on damage"))
	{
		if (weapon == -1)return Plugin_Continue;
		
		new String:values[4][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		ReloadBoost_MaxCharge[weapon] = StringToFloat(values[0]);
		ReloadBoost_MaxSpeed[weapon] = StringToFloat(values[1]);
		ReloadBoost_MaxDelay[weapon] = StringToFloat(values[2]);
		ReloadBoost_DrainRate[weapon] = StringToFloat(values[3]);
		
		ReloadBoost_Charge[weapon] = 0.0;
		ReloadBoost_MaxClip[weapon] = GetClip_Weapon(weapon);
		
		ReloadBoost[weapon] = true;
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "explode on reload"))
	{
		if (weapon == -1)return Plugin_Continue;
		
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		ExplodeOnReload_MaxDamage[weapon] = StringToInt(values[0]);
		ExplodeOnReload_BlastRadius[weapon] = StringToFloat(values[1]);
		ExplodeOnReload_MaxFalloff[weapon] = StringToFloat(values[2]);
		
		ExplodeOnReload_MaxClip[weapon] = GetClip_Weapon(weapon);
		ExplodeOnReload_Exploded[weapon] = true;
		
		//PrintToChat(client, "Attributes: Explode on Reload");
		
		ExplodeOnReload[weapon] = true;
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "build accuracy boost on damage"))
	{
		if (weapon == -1)return Plugin_Continue;
		
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		SteadyShot_MaxCharge[weapon] = StringToFloat(values[0]);
		SteadyShot_MaxAccuracy[weapon] = StringToFloat(values[1]);
		SteadyShot_Drain[weapon] = StringToFloat(values[2]);
		
		SteadyShot_Charge[weapon] = 0.0;
		
		SteadyShot[weapon] = true;
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "grenades explode on surfaces"))
	{
		if (weapon == -1)return Plugin_Continue;
		
		GrenadesExplodeOnSurfaces[weapon] = true;
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "apply attribute on last shot"))
	{
		if (weapon == -1)return Plugin_Continue;
		
		new String:values[2][10];
		ExplodeString(value, ", ", values, sizeof(values), sizeof(values[]));
		
		AttributeOnLastShot_Value[weapon] = StringToFloat(values[1]);
		AttributeOnLastShot_Attribute[weapon] = values[0];
		
		AttributeOnLastShot[weapon] = true;
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "refill clip on kill"))
	{
		RefillClipOnKill[weapon] = true;
		RefillClipOnKill_MaxClip[weapon] = GetClip_Weapon(weapon);
		
		//PrintToChat(client, "Attributes: Refill Clip on Kill");
		
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "store charge attrib"))
	{
		AutoMatilda[weapon] = true;
		AutoMatilda_ReserveCharge[weapon] = 0.0;
		AutoMatilda_DamageMultiplier[weapon] = 1.0;
		AutoMatilda_MaxCharge[weapon] = StringToFloat(value);
		
		//PrintToChat(client, "Attributes: Auto Matilda");
		
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "damage bonus after melee kill"))
	{
		BonusDmgOnMeleeKill[weapon] = true;
		BonusDmgOnMeleeKill_Mult[weapon] = StringToFloat(value);
		
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "damage bonus while shield is recharging"))
	{
		BonusDmgWhileRecharging[weapon] = true;
		BonusDmgWhileRecharging_Mult[weapon] = StringToFloat(value);
		
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "kills with other weapons reload this weapon"))
	{
		ReloadThisWeaponOnKill[weapon] = true;
		
		ReloadThisWeaponOnKill_Max[weapon] = GetClip_Weapon(weapon);
		ReloadThisWeaponOnKill_Count[weapon] = StringToInt(value);
		
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "switch speed bonus while shield is charged"))
	{
		SwapSpeedWhileCharged[weapon] = true;
		SwapSpeedWhileCharged_Mult[weapon] = StringToFloat(value);
		
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "fire rate increases as damage increases"))
	{
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		FireRateOverDamage[weapon] = true;
		FireRateOverDamage_MaxMult[weapon] = StringToFloat(values[0]);
		FireRateOverDamage_MaxCharge[weapon] = StringToFloat(values[1]);
		FireRateOverDamage_MaxDelay[weapon] = StringToFloat(values[2]);
		
		HasOverDamage[weapon] = true;
		
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "reload rate increases as damage increases"))
	{
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		ReloadRateOverDamage[weapon] = true;
		ReloadRateOverDamage_MaxMult[weapon] = StringToFloat(values[0]);
		ReloadRateOverDamage_MaxCharge[weapon] = StringToFloat(values[1]);
		ReloadRateOverDamage_MaxDelay[weapon] = StringToFloat(values[2]);
		
		HasOverDamage[weapon] = true;
		
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "accuracy decreases as damage increases"))
	{
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		AccuracyOverDamage[weapon] = true;
		AccuracyOverDamage_MaxMult[weapon] = StringToFloat(values[0]);
		AccuracyOverDamage_MaxCharge[weapon] = StringToFloat(values[1]);
		AccuracyOverDamage_MaxDelay[weapon] = StringToFloat(values[2]);
		
		HasOverDamage[weapon] = true;
		
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "mini crits airblasted players"))
	{
		MinicritsAirblasted[weapon] = true;
		
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "does not ignite"))
	{
		Noburn[weapon] = true;
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "extinguishing restores health"))
	{
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		HealPlayersOnExtinguish[weapon] = true;
		HealPlayersOnExtinguish_Restore[weapon] = StringToInt(values[0]);
		HealPlayersOnExtinguish_VictimRestore[weapon] = StringToInt(values[1]);
		
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "burning player heals attacker when killed"))
	{
		BurningPlayerHealsAttacker[weapon] = true;
		BurningPlayerHealsAttacker_Restore[weapon] = StringToInt(value);
		
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "cozy meter attrib"))
	{
		new String:values[4][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		CozyMeter[weapon] = true;
		CozyMeter_MaxCharge[weapon] = StringToFloat(values[0]);
		CozyMeter_Duration[weapon] = StringToFloat(values[1]);
		CozyMeter_Slow[weapon] = StringToFloat(values[2]);
		CozyMeter_AmmoDrain[weapon] = StringToFloat(values[3]);
		
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "burning players increase your movement speed"))
	{
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		BurnVictimsForMoveSpeed[weapon] = true;
		BurnVictimsForMoveSpeed_Mult[weapon] = StringToFloat(values[0]);
		BurnVictimsForMoveSpeed_Stacks[weapon] = 0;
		
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "move speed strength doubled while active"))
	{
		if (!BurnVictimsForMoveSpeed[weapon])return Plugin_Continue;
		BurnVictimsForMoveSpeed_DoubleStrengthWhileActive[weapon] = true;
		
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "kill burning players adds perma stacks"))
	{
		if (!BurnVictimsForMoveSpeed[weapon])return Plugin_Continue;
		BurnVictimsForMoveSpeed_KillForPermaStacks[weapon] = true;
		
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "hellfire"))
	{
		HellfireAttrib[weapon] = true;
		HellfireAttrib_Dur[weapon] = StringToFloat(value);
		
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "gain knife effects on kill"))
	{
		KnifeEffectsOnKill[weapon] = true;
		
		//Can't do that because it spams the server and then the attribute no work
		//Why? Because FUCK YOU that's why
		//if(StringToInt(value) == 1)
		//	TF2_RemoveWeaponSlot(client, 2);
		
		if(StringToInt(value) == 1)
			KnifeEffectsOnKill_DisableKnife[weapon] = true;
		
		KnifeEffectsOnKill_KnifeID[weapon] = GetEntProp(GetPlayerWeaponSlot(client, 2), Prop_Send, "m_iItemDefinitionIndex");
		
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "manns meat attrib"))
	{
		MannsMeat[weapon] = true;
		action = Plugin_Handled;
	}
	
	
	if (!m_bHasAttribute[client][slot]) m_bHasAttribute[client][slot] = bool:action;
	return action;
}

///////////////////////////////////////
// COMBAT BASED EVENTS BEGIN BELOW ///
/////////////////////////////////////

//Anything that has to do with firing is put in here
public Action:TF2_CalcIsAttackCritical(client, weapon, String:weaponname[], &bool:result)
{
	if (client < 0 || client > MaxClients)return Plugin_Continue;
	if (weapon <= -1 || weapon >= 2049)return Plugin_Continue;
	
	new Action:action;
	
	//Simply used to trace whether or not the player has shot their power shot yet.
	//Didn't feel the significance to put this into a stock
	if(DestroyerAttrib[weapon])
	{
		if(DestroyerAttrib_Shot[weapon] > 0)
			DestroyerAttrib_Shot[weapon]--;
	}
	
	if(BonusDmgOnMeleeKill[weapon])
	{
		if(BonusDmgOnMeleeKill_Shot[weapon] > 0)
			BonusDmgOnMeleeKill_Shot[weapon]--;
	}
	
	//Reduces charge per shot with the SteadyShot attribute
	if(SteadyShot[weapon])
	{
		SteadyShot_Charge[weapon] -= (SteadyShot_Charge[weapon] * SteadyShot_Drain[weapon]);
		if(SteadyShot_Charge[weapon] < 0.0)
		{
			SteadyShot_Charge[weapon] = 0.0;
		}
	}
	
	//Creates the timer that resets the charge for the auto matilda attribute
	if(AutoMatilda[weapon])
	{
		AutoMatilda_DamageMultiplier[weapon] = (AutoMatilda_ReserveCharge[weapon] / 100) * 3;
		AutoMatilda_ReserveCharge[weapon] = 0.0;
		CreateTimer(0.1, AutoMatilda_ResetCharge, client, TIMER_FLAG_NO_MAPCHANGE);
	}
	return action;
}

//Anything that has to do with modifying damage is placed in here
//If it doesn't multiply damage, it doesn't belong here
public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3])
{
	if (attacker <= 0 || attacker > MaxClients) return Plugin_Continue;
	new Action:action;
	if(weapon > -1)
	{
		LastWeaponHurtWith[attacker] = weapon;
		if(DestroyerAttrib[weapon]) //This section is for calling on the destroyer attribute's stock to increase damage
		{ //It's basically where overkill damage from your last kill is added
			damage = DestroyerAttrib_OnTakeDamage(victim, weapon, damage);
			action = Plugin_Changed;
		}
		if(AutoMatilda[weapon] && AutoMatilda_DamageMultiplier[weapon] > 0.0) //This is where bonus charge from the auto matilda attribute is used
		{ //It basically increases the damage based on the given multiplier, which is calculated based on stored excess charge.
			damage *= AutoMatilda_DamageMultiplier[weapon];
			action = Plugin_Changed;
		}
		//Applies damage multiplier after getting a melee kill, if you didn't miss your first shot
		if(BonusDmgOnMeleeKill[weapon])
		{ 
			if(BonusDmgOnMeleeKill_Shot[weapon] > 0)
			{
				damage *= BonusDmgOnMeleeKill_Mult[weapon]; //This could actually be a damage penalty if you really wanted it to
				action = Plugin_Changed;
			}
		}
		//Applies damage multiplier while demo shield is charging
		if(BonusDmgWhileRecharging[weapon])
		{
			if(GetEntPropFloat(attacker, Prop_Send, "m_flChargeMeter") < 100.0)
			{
				damage *= BonusDmgWhileRecharging_Mult[weapon]; //This could be a damage penalty
				action = Plugin_Changed;
			}
		}
		//Applies minicrit damage if the victim is airblasted
		if(MinicritsAirblasted[weapon] && TF2_IsPlayerInCondition(victim, TFCond:115))
		{
			TF2_AddCondition(victim, TFCond_MarkedForDeathSilent, 0.01);
		}
		//Very simply removes afterburn from a player who's on fire and gets hit with this weapon
		if (Noburn[weapon])
		{
			TF2_RemoveCondition(victim, TFCond_OnFire);
		}
		
		if(MannsMeat_DeathMarked[victim])
		{
			damagetype = TF_DMG_CRIT | damagetype;
			MannsMeat_DeathMarked[victim] = false;
			action = Plugin_Changed;
		}
		if(MannsMeat[weapon])
		{
			new critchances = 1;
			
			if(TF2_IsPlayerInCondition(victim, TFCond:123))
			{
				damage *= 2.0;
				critchances++;
				action = Plugin_Changed;
			}
			if(TF2_IsPlayerInCondition(attacker, TFCond:125))
			{
				damage *= 2.0;
				critchances++;
				action = Plugin_Changed;
			}
			if(MannsMeat_Marked[victim] && MannsMeat_MarkInflictor[victim] == attacker)
			{
				damage *= 2.0;
				critchances++;
				MannsMeat_Marked[victim] = false;
				action = Plugin_Changed;
			}
			if(MannsMeat_Marked2[victim] && MannsMeat_MarkInflictor[victim] == attacker)
			{
				damage *= 2.0;
				critchances++;
				MannsMeat_Marked2[victim] = false;
				action = Plugin_Changed;
			}
			new crit = GetRandomInt(1, 10);
			if(critchances >= crit)
			{
				damagetype = TF_DMG_CRIT | damagetype;
				action = Plugin_Changed;
			}
		}
		if(MannsMeat_DamageMarked[victim])
		{
			TF2_AddCondition(victim, TFCond_MarkedForDeathSilent, 0.1);
			MannsMeat_DamageMarked[victim] = false;
		}
	}
	
	return action;
}

//Anything that requires exact damage numbers, such as building charge for a meter based attribute, goes here
//Or basically anything that doesn't modify damage but still uses it goes in here
public Action:OnTakeDamageAlive(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3])
{
	new Action:action;
	
	if(weapon > -1)
	{
		DestroyerAttrib_OnTakeDamageAlive(weapon, attacker, damage); //Destroyer Attribute
		SteadyShot_OnTakeDamageAlive(weapon, attacker, damage); //Steady shot attribute
		if(ReloadBoost[weapon])
		{
			ReloadBoost_Charge[weapon] += damage;
			if(ReloadBoost_Charge[weapon] > ReloadBoost_MaxCharge[weapon])
				ReloadBoost_Charge[weapon] = ReloadBoost_MaxCharge[weapon];
				
			//PrintToChat(attacker, "adding charge to weapon");
			
			ReloadBoost_Delay[weapon] = GetEngineTime();
		}
		if(FireRateOverDamage[weapon]) //fire rate bonus as damage increases
		{
			if(FireRateOverDamage_Charge[weapon] < FireRateOverDamage_MaxCharge[weapon])
			{
				FireRateOverDamage_Charge[weapon] += damage; //Adds damage to the charge meter
				if (FireRateOverDamage_Charge[weapon] > FireRateOverDamage_MaxCharge[weapon])FireRateOverDamage_Charge[weapon] = FireRateOverDamage_MaxCharge[weapon];
				//^ makes sure the charge doesn't go over
			}
			FireRateOverDamage_Delay[weapon] = GetEngineTime(); //Reset the decay time
		}
		if(ReloadRateOverDamage[weapon]) //reload rate bonus as damage increases
		{
			if(ReloadRateOverDamage_Charge[weapon] < ReloadRateOverDamage_MaxCharge[weapon])
			{
				ReloadRateOverDamage_Charge[weapon] += damage; //Adds damage to the charge meter
				if (ReloadRateOverDamage_Charge[weapon] > ReloadRateOverDamage_MaxCharge[weapon])ReloadRateOverDamage_Charge[weapon] = ReloadRateOverDamage_MaxCharge[weapon];
				//^ makes sure the charge doesn't go over
			}
			ReloadRateOverDamage_Delay[weapon] = GetEngineTime(); //Reset the decay time
		}
		if(AccuracyOverDamage[weapon]) //accuracy decreases as damage increases
		{
			if(AccuracyOverDamage_Charge[weapon] < AccuracyOverDamage_MaxCharge[weapon])
			{
				AccuracyOverDamage_Charge[weapon] += damage; //Adds damage to the charge meter
				if (AccuracyOverDamage_Charge[weapon] > AccuracyOverDamage_MaxCharge[weapon])AccuracyOverDamage_Charge[weapon] = AccuracyOverDamage_MaxCharge[weapon];
				//^ makes sure the charge doesn't go over
			}
			AccuracyOverDamage_Delay[weapon] = GetEngineTime(); //Reset the decay time
		}
		
		//Marks player with a special attribute when hit
		//Only works with flamethrowers
		if(BurningPlayerHealsAttacker[weapon])
		{
			BurningPlayerHealsAttacker_Marked[victim] = true;
			BurningPlayerHealsAttacker_Restore[victim] = BurningPlayerHealsAttacker_Restore[weapon];
		}
		
		//Adds damage to the Cozy meter charge
		if(CozyMeter[weapon])
		{
			CozyMeter_Charge[weapon] += damage;
			if (CozyMeter_Charge[weapon] > CozyMeter_MaxCharge[weapon])CozyMeter_Charge[weapon] = CozyMeter_MaxCharge[weapon];
		}
		
		//JOKE ATTRIBUTE
		if(MannsMeat[GetPlayerWeaponSlot(victim, 2)])
		{
			MannsMeat_DamageMarked[attacker] = true;
		}
		if(MannsMeat[GetPlayerWeaponSlot(attacker, 2)] && weapon == GetPlayerWeaponSlot(attacker, 0))
		{
			MannsMeat_Marked[victim] = true;
			MannsMeat_MarkInflictor[victim] = attacker;
		}
		if(MannsMeat[GetPlayerWeaponSlot(attacker, 2)] && weapon == GetPlayerWeaponSlot(attacker, 1))
		{
			MannsMeat_Marked2[attacker] = true;
			MannsMeat_MarkInflictor[victim] = attacker;
		}
		if(MannsMeat[weapon])
		{
			MannsMeat_SpeedMarked[victim] = true;
			MannsMeat_SpeedInflictor[victim] = attacker;
		}
	}
	return action;
} 

//Anything that triggers an effect on kill goes here
public Action:Event_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new weapon = LastWeaponHurtWith[attacker];
	if (attacker && attacker != victim)
	{
		//All this does is charges the power shot
		//I didn't feel the significance to put this into a stock
		if(DestroyerAttrib[weapon])
		{
			DestroyerAttrib_Mult[weapon] = ((OriginalDamage[attacker] - DestroyerAttrib_EnemyHealth[weapon]) / OriginalDamage[attacker]) * DestroyerAttrib_Pct[weapon] + 1.0;
			DestroyerAttrib_Shot[weapon] = 2;
			
			DestroyerAttrib_Delay[weapon] = GetEngineTime();
			//PrintToChat(attacker, "Destroyer shot charged");
		}
		if(RefillClipOnKill[weapon])
		{
			CreateTimer(0.1, RefillClipOnKill_Func, attacker, TIMER_FLAG_NO_MAPCHANGE);
			//PrintToChat(attacker, "Proceeding to begin clip refill process...");
		}
		if(BonusDmgOnMeleeKill[GetPlayerWeaponSlot(attacker, 0)] || BonusDmgOnMeleeKill[GetPlayerWeaponSlot(attacker, 1)])
		{
			new slot = GetPlayerWeaponSlot(attacker, 0);
			if(GetPlayerWeaponSlot(attacker, 0) < 0 || !BonusDmgOnMeleeKill[slot])
				slot = GetPlayerWeaponSlot(attacker, 1);
			
			if(weapon == GetPlayerWeaponSlot(attacker, 2))
			{
				BonusDmgOnMeleeKill_Shot[slot] = 2;
			}
		}
		if(ReloadThisWeaponOnKill[GetPlayerWeaponSlot(attacker, 0)] || ReloadThisWeaponOnKill[GetPlayerWeaponSlot(attacker, 1)])
		{
			new slot = GetPlayerWeaponSlot(attacker, 0);
			if(GetPlayerWeaponSlot(attacker, 0) < 0 || !ReloadThisWeaponOnKill[GetPlayerWeaponSlot(attacker, 0)])
				slot = GetPlayerWeaponSlot(attacker, 1);
			
			if(weapon != slot)
			{
				new clip = GetClip_Weapon(slot) + ReloadThisWeaponOnKill_Count[slot];
				if(clip > ReloadThisWeaponOnKill_Max[slot])	
					clip = ReloadThisWeaponOnKill_Max[slot];
					
				SetClip_Weapon(slot, clip);
			}
		}
		
		//Restores health to the attacker if the victim is under a 'health burn'
		if(BurningPlayerHealsAttacker_Marked[victim])
		{
			HealPlayer(attacker, attacker, BurningPlayerHealsAttacker_Restore[victim], 1.0);
			BurningPlayerHealsAttacker_Marked[victim] = false;
			BurningPlayerHealsAttacker_Restore[victim] = 0;
		}
		
		//If the attacker is using a weapon that supports BurnVictimsForMoveSpeed and its perma stack ability
		//and the attacker ignited the victim
		if(BurnVictimsForMoveSpeed_KillForPermaStacks[weapon] && Igniter[victim] == attacker)
		{
			BurnVictimsForMoveSpeed_MinStacks[weapon]++; //Increase the number of minimum stacks
		}
		
		//Removes hellfire when a player dies
		if(Hellfire[victim])
		{
			HellfireAttrib_Dur[victim] = 0.0;
			Hellfire_Igniter[victim] = -1;
			Hellfire[victim] = false;
		}
		
		if(MannsMeat[GetPlayerWeaponSlot(victim, 2)])
		{
			MannsMeat_DeathMarked[attacker] = true;
		}
		
		if(KnifeEffectsOnKill[weapon])
		{
			if(GetPlayerWeaponSlot(attacker, 2) > -1)
			{
				new iItemIndex = KnifeEffectsOnKill_KnifeID[weapon];
				
				if(iItemIndex == 225 || iItemIndex == 574) //Your Eternal Reward/Wanga Prick
				{
					//Oh god, I didn't expect this to take so long
					
					//Starts the disguise process
					TF2_DisguisePlayer(attacker, TFTeam:TF2_GetClientTeam(victim), TFClassType:TF2_GetPlayerClass(victim), victim);
					
					//Sets ALL of the variables needed to disguise the attacker
					SetEntProp(attacker, Prop_Send, "m_nMaskClass", TF2_GetPlayerClass(victim));
					SetEntProp(attacker, Prop_Send, "m_nDisguiseClass", TF2_GetPlayerClass(victim));
					SetEntProp(attacker, Prop_Send, "m_nDesiredDisguiseClass", TF2_GetPlayerClass(victim));
					SetEntProp(attacker, Prop_Send, "m_nDisguiseTeam", TF2_GetClientTeam(victim));
					SetEntProp(attacker, Prop_Send, "m_iDisguiseTargetIndex", victim);
					SetEntProp(attacker, Prop_Send, "m_iDisguiseHealth", GetClientHealth(attacker));
					
					//Finishes it all up
					TF2_AddCondition(attacker, TFCond_Disguised);
				}
				else if(iItemIndex == 356) //Conniver's Kunai
				{
					//Unfortunately I can't replicate the effect of the Conniver's Kunai exactly, otherwise you would get very little HP per kill
					//So instead I'm taking half the victim's max health and healing the Spy with it
					new health = GetClientHealth(attacker) + (GetClientMaxHealth(victim) / 2);
					if (health > 200)health = 210;
					SetEntityHealth(attacker, health);
					
					//Remove fire and bleed
					TF2_RemoveCondition(attacker, TFCond_Bleeding);
					TF2_RemoveCondition(attacker, TFCond_OnFire);
				}
				else if(iItemIndex == 461) //The Big Earner
				{
					TF2_AddCondition(attacker, TFCond_SpeedBuffAlly, 3.0);
					
					//Adds 30% cloak to the attacker.
					new Float:cloak = GetEntPropFloat(attacker, Prop_Send, "m_flCloakMeter") + 30.0;
					if (cloak > 100.0)cloak = 100.0;
					SetEntPropFloat(attacker, Prop_Send, "m_flCloakMeter", cloak);
				}
				else if(iItemIndex == 649) //Spy-cicle
				{
					//Oh boy, how am I going to implement this one?
					//Maybe just give the Spy the fire resistance on kill
					
					//Afterburn Immunity
					TF2_AddCondition(attacker, TFCond:102, 5.0);
					//Fire damage immunity
					TF2_AddCondition(attacker, TFCond:69, 1.0);
				}
			}
		}
		
		MannsMeat_SpeedMarked[victim] = false;
		MannsMeat_SpeedInflictor[victim] = -1;
		MannsMeat_DeathMarked[victim] = false;
		MannsMeat_DamageMarked[victim] = false;
		MannsMeat_Marked[victim] = false;
		MannsMeat_Marked2[victim] = false;
		MannsMeat_MarkInflictor[victim] = -1;
	}
}

///////////////////////////////////////////////////////////////
//////////// TIMING BASED EVENTS BEGIN DOWN BELOW ////////////
/////////////////////////////////////////////////////////////

//Simply performs the function of refilling the clip of any weapon that carries the 'refill clip on kill' attribute
public Action:RefillClipOnKill_Func(Handle:timer, any:attacker)
{
	if(Client_IsValid(attacker))
	{
		new weapon = Client_GetActiveWeapon(attacker);
	
		if(weapon > -1 && RefillClipOnKill[weapon])
		{
			SetClip_Weapon(weapon, RefillClipOnKill_MaxClip[weapon]);
			//PrintToChat(attacker, "Clip refilled");
		}
	}
}

//Performs the simple action of reseting reserve charge after firing a weapon with the auto matilda attribute
public Action:AutoMatilda_ResetCharge(Handle:timer, any:client)
{
	if(Client_IsValid(client))
	{
		new weapon = Client_GetActiveWeapon(client);
		if(weapon > -1)
		{
			AutoMatilda_DamageMultiplier[weapon] = 0.0;
		}
	}
}

//This right here runs pretty much everything that has to constantly run

public Action:OnClientPreThink(client)
{
	new weapon = Client_GetActiveWeapon(client);
	if (weapon < 0)return;
	if (!Client_IsValid(client))return;
	
	//Anything inside this block right here executes 10 times per second
	if(GetEngineTime() >= LastTick[client] + 0.1)
	{
		ReloadBoost_PreThink(client, weapon); //Prethink for reload boost based on damage attribute
		ExplodeOnReload_PreThink(client, weapon);
		SteadyShot_PreThink(client, weapon);
		AttributeOnLastShot_PreThink(weapon);
		DestroyerAttrib_PreThink(weapon);
		SwapSpeedWhileCharged_PreThink(client, weapon);
		OverDamageAttribs_PreThink(weapon); //Prethink for any attributes that use the "over damage" algorithm
		CozyMeter_PreThink(client, weapon); //Prethink for the Cozy meter attribute
		MannsMeat_PreThink(client, weapon);
		DisableKnife(client, weapon);
		
		if(TF2_GetPlayerClass(client) == TFClass_Pyro)
		{
			BurnVictimsForMoveSpeed_PreThink(client, weapon); 
		}
		
		if(BurningPlayerHealsAttacker_Marked[client])
		{
			BurningPlayerHealsAttacker_PreThink(client); //Prethink for disabling the 'heal burn' effect after burn wears off
		}
		if(Hellfire[client])
		{
			Hellfire_PreThink(client); //Used to reignite the victim if their burn technically hasn't ended
		}
		
		if(!TF2_IsPlayerInCondition(client, TFCond_OnFire) && Igniter[client] > -1)
		{
			Igniter[client] = -1;
		}
		
		LastTick[client] = GetEngineTime();
	}
	//Anything below this point will run every game frame
	//Usually not a good idea to put much down here. Only stuff that requires delicate timing
	AutoMatilda_PreThink(client, weapon);
	
	return;
}

//////////////////////////////////////////
//// MISCELLANEOUS EVENTS START HERE ////
////////////////////////////////////////

//I honestly don't know what this was used for lol
//This was made in the beginnings of this little pack
//Like 3-4 months before this was written on April 14th, 2018
public Action:ProjectileStartTouch(entity, other)
{
	new owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	if(owner <= 0 || owner > MaxClients) return Plugin_Continue;
	
	new Action:action = Plugin_Continue;
	
	action = ActionApply(action, GrenadesExplodeOnSurfaces_StartTouch(entity));
	
	return action;
}

//Fired any time a player is extinguished
//Whether it be by a Pyro or a Medic
public Action PlayerExtinguished_Event(Handle event, const char[] name, bool dontBroadcast)
{
	new victim = GetEventInt(event, "victim");
	new healer = GetEventInt(event, "healer");
	
	new Action:action;
	
	if (!Client_IsValid(healer))return action;
	if (!Client_IsValid(victim))return action;
	
	new weapon = Client_GetActiveWeapon(healer);
	if (weapon < 0)return action;
	
	//PrintToChat(healer, "extinguished player");
	
	if(HealPlayersOnExtinguish[weapon])
	{
		//HealPlayer is a stock I've created in zethax.inc
		//It essentially restores health, but with more visuals
		HealPlayer(healer, victim, HealPlayersOnExtinguish_VictimRestore[weapon], 1.5);
		HealPlayer(healer, healer, HealPlayersOnExtinguish_Restore[weapon], 1.5);
	}
	return action;
}

//Fired any time a player is ignited
//Useful for allowing the plugin to track who did the igniting
public Action PlayerIgnited_Event(Handle event, const char[] name, bool dontBroadcast)
{
	new victim = GetEventInt(event, "victim_entindex");
	new attacker = GetEventInt(event, "pyro_entindex");
	
	new Action:action;
	
	if (!Client_IsValid(attacker))return action;
	if (!Client_IsValid(victim))return action;
	
	new weapon = Client_GetActiveWeapon(attacker);
	if (weapon < 0)return action;
	
	Igniter[victim] = attacker;
	if(HellfireAttrib[weapon])
	{
		Hellfire[victim] = true;
		Hellfire_Dur[victim] = HellfireAttrib_Dur[weapon];
		Hellfire_Igniter[victim] = attacker;
	}
	
	return action;
}

//Resets all the values used in custom attributes
public OnEntityDestroyed(Ent)
{
	if(Ent <= 0 || Ent > 2048) return;
	
	DestroyerAttrib[Ent] = false;
	DestroyerAttrib_Dmg[Ent] = 0.0;
	DestroyerAttrib_Pct[Ent] = 0.0;
	DestroyerAttrib_Mult[Ent] = 0.0;
	DestroyerAttrib_Shot[Ent] = 0;
	DestroyerAttrib_EnemyHealth[Ent] = 0;
	DestroyerAttrib_MaxDelay[Ent] = 0.0;
	
	ReloadBoost[Ent] = false;
	ReloadBoost_MaxCharge[Ent] = 0.0;
	ReloadBoost_Charge[Ent] = 0.0;
	ReloadBoost_MaxSpeed[Ent] = 0.0;
	ReloadBoost_MaxClip[Ent] = 0;
	ReloadBoost_DrainRate[Ent] = 0.0;
	ReloadBoost_Delay[Ent] = 0.0;
	ReloadBoost_MaxDelay[Ent] = 0.0;
	
	ExplodeOnReload[Ent] = false;
	ExplodeOnReload_MaxDamage[Ent] = 0;
	ExplodeOnReload_BlastRadius[Ent] = 0.0;
	ExplodeOnReload_MaxFalloff[Ent] = 0.0;
	ExplodeOnReload_MaxClip[Ent] = 0;
	ExplodeOnReload_Exploded[Ent] = false;
	ExplodeOnReload_Mode[Ent] = -1;
	
	SteadyShot[Ent] = false;
	SteadyShot_Charge[Ent] = 0.0;
	SteadyShot_MaxCharge[Ent] = 0.0;
	SteadyShot_MaxAccuracy[Ent] = 0.0;
	SteadyShot_Drain[Ent] = 0.0;
	
	GrenadesExplodeOnSurfaces[Ent] = false;
	
	AttributeOnLastShot[Ent] = false;
	AttributeOnLastShot_Value[Ent] = 0.0;
	AttributeOnLastShot_Attribute[Ent] = "";
	
	RefillClipOnKill[Ent] = false;
	RefillClipOnKill_MaxClip[Ent] = -1;
	
	AutoMatilda[Ent] = false;
	AutoMatilda_MaxCharge[Ent] = 0.0;
	AutoMatilda_ReserveCharge[Ent] = 0.0;
	AutoMatilda_DamageMultiplier[Ent] = 0.0;
	
	BonusDmgOnMeleeKill[Ent] = false;
	BonusDmgOnMeleeKill_Mult[Ent] = 0.0;
	BonusDmgOnMeleeKill_Shot[Ent] = 0;
	
	BonusDmgWhileRecharging[Ent] = false;
	BonusDmgWhileRecharging_Mult[Ent] = 0.0;
	
	ReloadThisWeaponOnKill[Ent] = false;
	ReloadThisWeaponOnKill_Count[Ent] = 0;
	ReloadThisWeaponOnKill_Max[Ent] = 0;
	
	SwapSpeedWhileCharged[Ent] = false;
	SwapSpeedWhileCharged_Mult[Ent] = 0.0;
	
	FireRateOverDamage[Ent] = false;
	FireRateOverDamage_MaxMult[Ent] = 0.0;
	FireRateOverDamage_Charge[Ent] = 0.0;
	FireRateOverDamage_MaxCharge[Ent] = 0.0;
	FireRateOverDamage_Delay[Ent] = 0.0;
	FireRateOverDamage_MaxDelay[Ent] = 0.0;
	
	ReloadRateOverDamage[Ent] = false;
	ReloadRateOverDamage_MaxMult[Ent] = 0.0;
	ReloadRateOverDamage_Charge[Ent] = 0.0;
	ReloadRateOverDamage_MaxCharge[Ent] = 0.0;
	ReloadRateOverDamage_Delay[Ent] = 0.0;
	ReloadRateOverDamage_MaxDelay[Ent] = 0.0;
	
	AccuracyOverDamage[Ent] = false;
	AccuracyOverDamage_MaxMult[Ent] = 0.0;
	AccuracyOverDamage_Charge[Ent] = 0.0;
	AccuracyOverDamage_MaxCharge[Ent] = 0.0;
	AccuracyOverDamage_Delay[Ent] = 0.0;
	AccuracyOverDamage_MaxDelay[Ent] = 0.0;
	
	HasOverDamage[Ent] = false;
	
	MinicritsAirblasted[Ent] = false;
	
	Noburn[Ent] = false;
	
	HealPlayersOnExtinguish[Ent] = false;
	HealPlayersOnExtinguish_Restore[Ent] = 0;
	HealPlayersOnExtinguish_VictimRestore[Ent] = 0;
	
	BurningPlayerHealsAttacker[Ent] = false;
	BurningPlayerHealsAttacker_Restore[Ent] = 0;
	
	CozyMeter[Ent] = false;
	CozyMeter_Charge[Ent] = 0.0;
	CozyMeter_MaxCharge[Ent] = 0.0;
	CozyMeter_Duration[Ent] = 0.0;
	CozyMeter_Tick[Ent] = 0.0;
	CozyMeter_Slow[Ent] = 0.0;
	CozyMeter_AmmoDrain[Ent] = 0.0;
	CozyMeter_Active[Ent] = false;
	
	BurnVictimsForMoveSpeed[Ent] = false;
	BurnVictimsForMoveSpeed_Mult[Ent] = 0.0;
	BurnVictimsForMoveSpeed_Stacks[Ent] = 0;
	
	BurnVictimsForMoveSpeed_KillForPermaStacks[Ent] = false;
	BurnVictimsForMoveSpeed_MinStacks[Ent] = 0;
	
	BurnVictimsForMoveSpeed_DoubleStrengthWhileActive[Ent] = false;
	
	HellfireAttrib[Ent] = false;
	HellfireAttrib_Dur[Ent] = 0.0;
	
	KnifeEffectsOnKill[Ent] = false;
	KnifeEffectsOnKill_KnifeID[Ent] = 0;
	KnifeEffectsOnKill_DisableKnife[Ent] = false;
	
	MannsMeat[Ent] = false;
}

////////////////////////////////////////////////////////////////////////////////

//Destroyer Stuff
Float:DestroyerAttrib_OnTakeDamage(victim, weapon, Float:damage)
{
	if (!DestroyerAttrib[weapon])return damage;
	
	if(DestroyerAttrib_Shot[weapon] > 0)
	{
		damage *= DestroyerAttrib_Mult[weapon];
	}
	DestroyerAttrib_EnemyHealth[weapon] = GetClientHealth(victim);
	return damage;
}
DestroyerAttrib_OnTakeDamageAlive(weapon, attacker, Float:damage)
{
	if (weapon < 0)return;
	
	if (!DestroyerAttrib[weapon])return;
	
	if(DestroyerAttrib_Mult[weapon] > 1.0)
	{
		OriginalDamage[attacker] = damage / (DestroyerAttrib_Mult[weapon] - 1.0);
		DestroyerAttrib_Mult[weapon] = 0.0;
	}
	else OriginalDamage[attacker] = damage;
	DestroyerAttrib_Dmg[weapon] = OriginalDamage[attacker];
}
static DestroyerAttrib_PreThink(weapon)
{
	if (!DestroyerAttrib[weapon]) return;
	
	if (GetEngineTime() >= DestroyerAttrib_Delay[weapon] + DestroyerAttrib_MaxDelay[weapon])DestroyerAttrib_Shot[weapon] = 0;
}

///////////////////////////////////////////////////////////////////////////////

//Reload Boost stuff
stock ReloadBoost_PreThink(client, weapon)
{
	if (!ReloadBoost[weapon])return;
	
	TF2Attrib_SetByName(weapon, "Reload time decreased", 1.0 - (ReloadBoost_MaxSpeed[weapon] * (ReloadBoost_Charge[weapon] / ReloadBoost_MaxCharge[weapon])));
	
	if(GetClip_Weapon(weapon) == ReloadBoost_MaxClip[weapon])
		ReloadBoost_Charge[weapon] = 0.0;
	
	if(GetEngineTime() >= ReloadBoost_Delay[weapon] + ReloadBoost_MaxDelay[weapon])
	{
		if(ReloadBoost_Charge[weapon] > 0.0)
		{
			ReloadBoost_Charge[weapon] -= (ReloadBoost_MaxCharge[weapon] * 
											ReloadBoost_DrainRate[weapon]);
		}
		if(ReloadBoost_Charge[weapon] < 0.0)
			ReloadBoost_Charge[weapon] = 0.0;
			
		ReloadBoost_Delay[weapon] = GetEngineTime() + (ReloadBoost_MaxDelay[weapon] - 1.0);
	}
	
	SetHudTextParams(-1.0, 0.5, 0.2, 255, 255, 255, 255);
	ShowSyncHudText(client, CozyMeter_Display, "Boost: [%i%%] / [100%]", (ReloadBoost_Charge[weapon] / ReloadBoost_MaxCharge[weapon]) * 100.0);
}

///////////////////////////////////////////////////////////////////////////////

//ExplodeOnReload stuff
ExplodeOnReload_PreThink(client, weapon)
{
	if (!ExplodeOnReload[weapon])return;
	
	if(GetClip_Weapon(weapon) < ExplodeOnReload_MaxClip[weapon])
	{
		ExplodeOnReload_Exploded[weapon] = false;
		//PrintToChat(client, "Weapon is primed");
	}
	
	if(GetClip_Weapon(weapon) == ExplodeOnReload_MaxClip[weapon] && !ExplodeOnReload_Exploded[weapon])
	{
		DealRadiusDamage(client, _, _, ExplodeOnReload_BlastRadius[weapon], ExplodeOnReload_MaxFalloff[weapon], ExplodeOnReload_MaxDamage[weapon], DMG_BLAST, 2, false);
		SpawnParticle(client, "particles/explode");
		//PrintToChat(client, "Dealing explosion...");
		ExplodeOnReload_Exploded[weapon] = true;
		//PrintToChat(client, "Weapon unprimed");
	}
}

/////////////////////////////////////////////////////////////////////////////////

//SteadyShot stuff
SteadyShot_OnTakeDamageAlive(weapon, client, Float:damage)
{
	new secondary = GetPlayerWeaponSlot(client, 1);
	if (secondary < 0)return;
	if (!SteadyShot[secondary])return;
	
	if(SteadyShot_Charge[secondary] < SteadyShot_MaxCharge[secondary] && weapon != secondary)
	{
		damage += SteadyShot_Charge[secondary];
		if(SteadyShot_Charge[secondary] > SteadyShot_MaxCharge[secondary])
			SteadyShot_Charge[secondary] = SteadyShot_MaxCharge[secondary];
	}
	
}
SteadyShot_PreThink(client, weapon)
{
	new secondary = GetPlayerWeaponSlot(client, 1);
	if (secondary < 0)return;
	if (!SteadyShot[secondary])return;
	
	if(SteadyShot[weapon])
	{
		SetHudTextParams(0.5, 0.5, 0.2, 255, 255, 255, 255);
		ShowSyncHudText(client, SteadyShot_Display, "Boost: [%i%%] / [100%]", (SteadyShot_Charge[weapon] / SteadyShot_MaxCharge[weapon]) * 100.0);
	}
	
	TF2Attrib_SetByName(secondary, "weapon spread bonus", 1.0 - 
														(SteadyShot_MaxAccuracy[secondary] * 
														(SteadyShot_Charge[secondary] / SteadyShot_MaxCharge[secondary])));
}

///////////////////////////////////////////////////////////////////////////////

//GrenadesExplodeOnSurfaces stuff

static Action:GrenadesExplodeOnSurfaces_EntityCreated(entity, const String:classname[])
{
	if(entity <= 0) return Plugin_Continue;
	if(!IsValidEdict(entity)) return Plugin_Continue;
	new owner = GetEntPropEnt(entity, Prop_Data, "m_hOwnerEntity");
	
	if (owner < 0 || owner > MaxClients)return Plugin_Continue;
	
	if(StrEqual(classname, "tf_projectile_pipe", false))
	{
		SDKHook(entity, SDKHook_StartTouch, ProjectileStartTouch);
		if(GrenadesExplodeOnSurfaces[GetEntPropEnt(owner, Prop_Send, "m_hActiveWeapon")])
		{
			GrenadesExplodeOnSurfaces[entity] = true;
		}
	}
	return Plugin_Continue;
}

static Action:GrenadesExplodeOnSurfaces_StartTouch(entity)
{
	if (entity <= 0)return Plugin_Continue;
	if (!GrenadesExplodeOnSurfaces[entity])return Plugin_Continue;
	
	SetEntPropFloat(entity, Prop_Data, "m_flDetonateTime", 0.0);
	
	return Plugin_Changed;
}

///////////////////////////////////////////////////////////////////////////////

//AttributeOnLastShot stuff

static AttributeOnLastShot_PreThink(weapon)
{
	if (weapon < 0)return;
	
	if (!AttributeOnLastShot[weapon])return;
	
	if(GetClip_Weapon(weapon) == 1)
	{
		TF2Attrib_SetByName(weapon, AttributeOnLastShot_Attribute[weapon], AttributeOnLastShot_Value[weapon]);
	}
	else
	{
		TF2Attrib_RemoveByName(weapon, AttributeOnLastShot_Attribute[weapon]);
	}
}

//////////////////////////////////////////////////////////////////////////////

//AutoMatilda stuff

static AutoMatilda_PreThink(client, weapon)
{
	if (weapon < 0)return;
	
	if (!AutoMatilda[weapon])return;
	
	if (!Client_IsValid(client))return;
	
	new buttons = GetClientButtons(client);
	
	if((buttons & IN_ATTACK3) == IN_ATTACK3 && AutoMatilda_ReserveCharge[weapon] < 100.0)
	{
		AutoMatilda_ReserveCharge[weapon] += RoundToFloor(GetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage")) * 0.6666666666;
		if (AutoMatilda_ReserveCharge[weapon] > 100.0)AutoMatilda_ReserveCharge[weapon] = 100.0;
		SetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage", 0.0);
	}
	
	TF2Attrib_SetByName(weapon, "sniper charge per sec", 1.0 + (AutoMatilda_MaxCharge[weapon] - (AutoMatilda_MaxCharge[weapon] * (AutoMatilda_ReserveCharge[weapon] / 100.0) * 1.5)));
}

//SwapSpeedWhileCharged stuff

static SwapSpeedWhileCharged_PreThink(client, weapon)
{
	if (client < 0 || client > MaxClients)return;
	if (weapon < 0)return;
	if (!SwapSpeedWhileCharged[weapon])return;
	
	if(GetEntPropFloat(client, Prop_Send, "m_flChargeMeter") > 99.0)
	{
		TF2Attrib_SetByName(weapon, "switch from wep deploy time decreased", SwapSpeedWhileCharged_Mult[weapon]);
		TF2Attrib_SetByName(weapon, "single wep deploy time decreased", SwapSpeedWhileCharged_Mult[weapon]);
	}
	else
	{
		TF2Attrib_RemoveByName(weapon, "switch from wep deploy time decreased");
		TF2Attrib_RemoveByName(weapon, "single wep deploy time decreased");
	}
}

//BurningPlayerHealsAttacker stuff
static BurningPlayerHealsAttacker_PreThink(client)
{
	if (!Client_IsValid(client))return;
	
	if(!TF2_IsPlayerInCondition(client, TFCond_OnFire))
	{
		BurningPlayerHealsAttacker_Marked[client] = false;
		BurningPlayerHealsAttacker_Restore[client] = 0;
	}
}

//CozyMeter stuff
stock CozyMeter_PreThink(client, weapon)
{
	if (!CozyMeter[weapon])return;
	
	new buttons = GetClientButtons(client);
	
	if(CozyMeter_Charge[weapon] < CozyMeter_MaxCharge[weapon])
	{
		SetHudTextParams(-1.0, 0.6, 1.0, 255, 255, 255, 255);
		ShowSyncHudText(client, CozyMeter_Display, "Cozy: [%i%%] / [100%]", RoundFloat(CozyMeter_Charge[weapon] / CozyMeter_MaxCharge[weapon] * 100.0));
	}
	else
	{
		SetHudTextParams(-1.0, 0.6, 0.2, 255, 255, 255, 255);
		ShowSyncHudText(client, CozyMeter_Display, "Cozy: [100%] / [100%]\nPress Special-Attack to activate Cozy Campfire!");
		
		if((buttons & IN_ATTACK3) == IN_ATTACK3)
		{
			CozyMeter_Active[weapon] = true;
		}
	}
	
	if (CozyMeter_Active[weapon])
	{
		TF2_AddCondition(client, TFCond:55, 0.2);
		TF2Attrib_SetByName(weapon, "move speed penalty", CozyMeter_Slow[weapon]);
		TF2Attrib_SetByName(weapon, "airblast cost increased", CozyMeter_AmmoDrain[weapon]);
		TF2Attrib_SetByName(weapon, "flame ammopersec increased", CozyMeter_AmmoDrain[weapon]);
		CozyMeter_Charge[weapon] -= (CozyMeter_MaxCharge[weapon] / CozyMeter_Duration[weapon] / 10.0);
		
		if(CozyMeter_Charge[weapon] <= 0.0)
		{
			CozyMeter_Charge[weapon] = 0.0;
			CozyMeter_Active[weapon] = false;
			TF2Attrib_RemoveByName(weapon, "move speed penalty");
			TF2Attrib_RemoveByName(weapon, "airblast cost increased");
			TF2Attrib_RemoveByName(weapon, "flame ammopersec increased");
			TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
		}
	}
}

//BurnVictimsForMoveSpeed stuff
static BurnVictimsForMoveSpeed_PreThink(client, weapon)
{
	new slot;
	slot = GetPlayerWeaponSlot(client, 0);
	if(slot < 0 || !BurnVictimsForMoveSpeed[slot])
		slot = GetPlayerWeaponSlot(client, 1);
	if(slot < 0 || !BurnVictimsForMoveSpeed[slot])
		slot = GetPlayerWeaponSlot(client, 2);
	if(slot < 0 || !BurnVictimsForMoveSpeed[slot])
		return;
	
	BurnVictimsForMoveSpeed_Stacks[slot] = BurnVictimsForMoveSpeed_MinStacks[slot]; //Resets the number of stacks the player has before the checking procedure
	for (new i = 1; i <= MaxClients; i++)
	{
		if(Client_IsValid(i) && Igniter[i] == client) //Checks for victims the client has lit on fire
		{
			BurnVictimsForMoveSpeed_Stacks[slot]++;
		}
	}
	TF2Attrib_SetByName(slot, "move speed bonus", 1.0 + BurnVictimsForMoveSpeed_Mult[slot] * BurnVictimsForMoveSpeed_Stacks[slot]); //Sets movement speed bonus based on burning players
	
	if(BurnVictimsForMoveSpeed_DoubleStrengthWhileActive[slot] && BurnVictimsForMoveSpeed[weapon])
	{
		TF2Attrib_SetByName(weapon, "move speed bonus", 1.0 + (BurnVictimsForMoveSpeed_Mult[slot] * 2.0) * BurnVictimsForMoveSpeed_Stacks[slot]); //Doubles the above bonus
	}
	
	TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001); //Updates the player's movement speed
}

//Hellfire stuff
static Hellfire_PreThink(client)
{
	if(!TF2_IsPlayerInCondition(client, TFCond_OnFire) && Hellfire_Dur[client] > 0.0)
		TF2_IgnitePlayer(client, Hellfire_Igniter[client]); //Reignites the client if their afterburn technically hasn't ended
	
	Hellfire_Dur[client] -= 0.1; //Reduces the hellfire duration by 1/10th of a second.
	//PrintToChat(Hellfire_Igniter[client], "Burn time remaining: %i", RoundFloat(Hellfire_Dur[client]));
	if(Hellfire_Dur[client] <= 0.0)
	{
		//Extinguishes the client when Hellfire duration reaches 0
		//Resets the Hellfire values on them as well
		TF2_RemoveCondition(client, TFCond_OnFire);
		Hellfire[client] = false;
		Hellfire_Igniter[client] = -1;
	}
	
}

//KnifeEffectsOnKill stuff
static DisableKnife(client, weapon)
{
	new slot = GetPlayerWeaponSlot(client, 0);
	if (slot < 0)return;
	if (!KnifeEffectsOnKill[slot])return;
	
	if (!KnifeEffectsOnKill_DisableKnife[slot])return;
	
	//If the player tries to pull out their melee weapon
	if(weapon == GetPlayerWeaponSlot(client, 2))
	{
		//Switches the player back to their primary
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", GetPlayerWeaponSlot(client, 0));
	}
}

//MannsMeat
//JOKE ATTRIBUTE
static MannsMeat_PreThink(client, weapon)
{
	if (!MannsMeat[GetPlayerWeaponSlot(client, 2)])return;
	
	if(MannsMeat[weapon]) //If the active weapon is the Manns Meat
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			new Float:fPos1[3];
			GetClientAbsOrigin(client, fPos1);
			
			if(IsValidClient(i) && GetClientTeam(i) != GetClientTeam(client) && MannsMeat_SpeedMarked[i] && MannsMeat_SpeedInflictor[i] == client)
			{
				new Float:fPos2[3];
				GetClientAbsOrigin(i, fPos2);
				
				new Float:fDistance = GetVectorDistance(fPos1, fPos2);
				if(fDistance <= 450)
				{
					TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.2);
				}
			}
		}		
	}
}

//OverDamage attribute prethink
//This is where a copy-pasted algorithm of "deal damage to increase this, but it resets after so long" goes
//I'm not making a hundred different prethinks for the same algorithm.

static OverDamageAttribs_PreThink(weapon)
{
	if (weapon < 0)return;
	
	if (!HasOverDamage[weapon])return;
	
	if(FireRateOverDamage[weapon])
	{
		TF2Attrib_SetByName(weapon, "fire rate bonus", 1.0 - (FireRateOverDamage_MaxMult[weapon] * (FireRateOverDamage_Charge[weapon] / FireRateOverDamage_MaxCharge[weapon])));
		
		if(GetEngineTime() >= FireRateOverDamage_Delay[weapon] + FireRateOverDamage_MaxDelay[weapon])
		{
			FireRateOverDamage_Charge[weapon] -= FireRateOverDamage_MaxCharge[weapon] * (1.0 / ReloadRateOverDamage_MaxDelay[weapon]);
			if (FireRateOverDamage_Charge[weapon] < 0.0)FireRateOverDamage_Charge[weapon] = 0.0;
		}
	}
	if(ReloadRateOverDamage[weapon])
	{
		TF2Attrib_SetByName(weapon, "Reload time decreased", 1.0 - (ReloadRateOverDamage_MaxMult[weapon] * (ReloadRateOverDamage_Charge[weapon] / ReloadRateOverDamage_MaxCharge[weapon])));
		
		if(GetEngineTime() >= ReloadRateOverDamage_Delay[weapon] + ReloadRateOverDamage_MaxDelay[weapon])
		{
			ReloadRateOverDamage_Charge[weapon] -= ReloadRateOverDamage_MaxCharge[weapon] * (1.0 / ReloadRateOverDamage_MaxDelay[weapon]);
			if (ReloadRateOverDamage_Charge[weapon] < 0.0)ReloadRateOverDamage_Charge[weapon] = 0.0;
		}
	}
	if(AccuracyOverDamage[weapon])
	{
		TF2Attrib_SetByName(weapon, "spread penalty", 1.0 + (AccuracyOverDamage_MaxMult[weapon] * (AccuracyOverDamage_Charge[weapon] / AccuracyOverDamage_MaxCharge[weapon])));
		
		if(GetEngineTime() >= AccuracyOverDamage_Delay[weapon] + AccuracyOverDamage_MaxDelay[weapon])
		{
			AccuracyOverDamage_Charge[weapon] -= AccuracyOverDamage_MaxCharge[weapon] * (1.0 / AccuracyOverDamage_MaxDelay[weapon]);
			if (AccuracyOverDamage_Charge[weapon] < 0.0)AccuracyOverDamage_Charge[weapon] = 0.0;
		}
	}
}

/////////////////////////////////////////////////////////////////
//////////////// STOCKS /////////////////////////////////////////
/////////////////////////////////////////////////////////////////

//this section empty lol