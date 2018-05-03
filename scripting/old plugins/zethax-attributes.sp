/*
Okay, since this slab of code is so disorganized to the point where I cannot find my way anywhere, I'm going to try now.
I'm gonna add a key to get around here. Here we go:
Attribute Values - *1
	Attribute value sets - 1-X
Hooks, Sounds, Handles... - *2
 	Hooks & Creating Hud Synchronizers - 2-1
 	Precaching Sounds - 2-2
 	SDKHooks - 2-3
Attribute Application - *3
	Individual attributes - 3-X
OnTakeDamage - *4
	Functions inside OnTakeDamage - 4-X
OnTakeDamagePost - *5
	Functions inside OnTakeDamagePost - 5-X
OnTakeDamageAlivePost - *6
	Functions inside OnTakeDamageAlivePost - 6-X
OnPlayerRunCmd - *7
	Functions inside OnPlayerRunCmd - 7-X
Event_Respawn & Event_Death - *8
	Functions inside Event_Respawn & Event_Death - 8-X
Misc - *9
	Functions inside of Miscellanious triggers - 9-X
PreThinks - *10
	Attributes_PreThink - *11
		Functions inside of Attributes_PreThink - *11-X
OnEntityRemoved & CW3_OnWeaponRemoved - *12
	Attribute Value sets - 12-X
Stocks - *13
	Individual stocks - 13-X
*/

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

#define PLUGIN_VERSION "stable release 2"
#define SLOTS_MAX 7

enum
{
	Handle:AfterburnTimerDuration,
	Handle:AfterburnTimerSelfDuration,
	Handle:m_hTimer
};

public Plugin:myinfo = {
	name = "Zethax Attributes",
	author = "Zethax",
	description = "Includes a bunch of attributes usually unique to one weapon",
	version = PLUGIN_VERSION,
	url = ""
};

//Attribute Values start here
//*1
new Handle:m_hTimers[MAXPLAYERS + 1][m_hTimer];

new bool:FullClipOnKill[MAXPLAYERS + 1][SLOTS_MAX + 1]; //1-1
new FullClipOnKill_Clip[MAXPLAYERS + 1][SLOTS_MAX + 1];
new FullClipOnKill_Ammo[MAXPLAYERS + 1][SLOTS_MAX + 1];
new FullClipOnKill_Amount[MAXPLAYERS + 1][SLOTS_MAX + 1];
new bool:AmmoOnKill[MAXPLAYERS + 1][SLOTS_MAX + 1];

new bool:ResistOnKill[MAXPLAYERS + 1][SLOTS_MAX + 1]; //1-2
new Float:ResistOnKill_Bullet[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:ResistOnKill_Blast[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:ResistOnKill_Fire[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:ResistOnKill_Sentry[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:ResistOnKill_Knockback[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:ResistOnKill_Dur[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:ResistOnKill_MaxDur[MAXPLAYERS + 1][SLOTS_MAX + 1];

new bool:MetalOnKill[MAXPLAYERS + 1][SLOTS_MAX + 1]; //1-3
new MetalOnKill_MaxKills[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:MetalOnKill_Metal[MAXPLAYERS + 1][SLOTS_MAX + 1];
new MetalOnKill_Kills[MAXPLAYERS + 1][SLOTS_MAX + 1];
new MetalOnKill_MaxMetal[MAXPLAYERS + 1][SLOTS_MAX + 1];

new bool:FastReloadHeadshot[2049]; //1-4
new Float:FastReloadHeadshot_Headshot[2049];
new Float:FastReloadHeadshot_Bodyshot[2049];
new Float:FastReloadHeadshot_Miss[2049];
new Float:FastReloadHeadshot_RifleCharge[2049];
new FastReloadHeadshot_Bonuses[2049];
new Float:FastReloadHeadshot_Dur[2049];

new bool:StoreCritOnHeadshot[2049]; //1-5
new StoreCritOnHeadshot_Max[2049];
new StoreCritOnHeadshot_Crits[2049];
new StoreCritOnHeadshot_AddCrits[2049];
new StoreCritOnHeadshot_Type[2049];

new bool:BackstabService[MAXPLAYERS + 1][SLOTS_MAX + 1]; //1-6
new Float:BackstabService_CloakSpd[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:BackstabService_DecloakSpd[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:BackstabService_MoveSpd[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:BackstabService_SapperPwr[MAXPLAYERS + 1][SLOTS_MAX + 1];
new BackstabService_MaxStacks[MAXPLAYERS + 1][SLOTS_MAX + 1];
new BackstabService_Stacks[MAXPLAYERS + 1][SLOTS_MAX + 1];

new bool:HammerMechanic[MAXPLAYERS + 1][SLOTS_MAX + 1]; //1-7
new bool:HammerMechanic_Fann[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:HammerMechanic_Wait[MAXPLAYERS + 1][SLOTS_MAX + 1];

new bool:HealRateKill[MAXPLAYERS + 1][SLOTS_MAX + 1]; //1-8
new Float:HealRateKill_Bonus[MAXPLAYERS + 1][SLOTS_MAX + 1];
new HealRateKill_MaxStacks[MAXPLAYERS + 1][SLOTS_MAX + 1];
new HealRateKill_Stacks[MAXPLAYERS + 1][SLOTS_MAX + 1];
new HealRateKill_Subtract[MAXPLAYERS + 1][SLOTS_MAX + 1];
new HealRateKill_Blood[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:HealRateKill_WaitTime[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:HealRateKill_Wait[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:HealRateKill_HealDelay[MAXPLAYERS + 1];
new Float:HealRateKill_Remove[MAXPLAYERS + 1];

new bool:MoonshineAttrib[2049]; //1-9
new Float:MoonshineAttrib_DMGBonus[2049];
new Float:MoonshineAttrib_SwingBonus[2049];
new MoonshineAttrib_MaxStacks[2049];
new Float:MoonshineAttrib_OverhealCap[2049];
new MoonshineAttrib_Stacks[2049];
new Float:MoonshineAttrib_Wait[2049];
new Float:MoonshineAttrib_DMGResist[2049];
new Float:MoonshineAttrib_Dur[2049];

new bool:DispenserMinigunHeal[MAXPLAYERS + 1][SLOTS_MAX + 1]; //1-10
new Float:DispenserMinigunHeal_HealDelay[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:DispenserMinigunHeal_SelfHeal[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:DispenserMinigunHeal_Delay[MAXPLAYERS + 1][SLOTS_MAX + 1];
new bool:DispenserMinigunAmmo[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:DispenserMinigunAmmo_AmmoDelay[MAXPLAYERS + 1][SLOTS_MAX + 1];
new DispenserMinigunAmmo_Ammo[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:DispenserMinigunAmmo_Delay[MAXPLAYERS + 1][SLOTS_MAX + 1];
new bool:DispenserMinigunSpecial[MAXPLAYERS + 1][SLOTS_MAX + 1];
new DispenserMinigunSpecial_ChrgType[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:DispenserMinigunSpecial_MaxChrg[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:DispenserMinigunSpecial_Charge[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:DispenserMinigunSpecial_MaxDur[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:DispenserMinigunSpecial_Dur[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:DispenserMinigunSpecial_MaxFuryDur[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:DispenserMinigunSpecial_FuryDur[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:DispenserMinigunSpecial_Boost[MAXPLAYERS + 1][SLOTS_MAX + 1];
new DispenserMinigunSpecial_Radius[MAXPLAYERS + 1][SLOTS_MAX + 1];

new bool:BrewAttrib[MAXPLAYERS + 1][SLOTS_MAX + 1]; //1-11
new Float:BrewAttrib_MaxDelay[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:BrewAttrib_Delay[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:BrewAttrib_DmgBonus[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:BrewAttrib_DmgResist[MAXPLAYERS + 1][SLOTS_MAX + 1];
new BrewAttrib_Stacks[MAXPLAYERS + 1][SLOTS_MAX + 1];
new BrewAttrib_MaxStacks[MAXPLAYERS + 1][SLOTS_MAX + 1];

new bool:ImpactBlast[MAXPLAYERS + 1][SLOTS_MAX + 1]; //1-12
new Float:ImpactBlast_DMGMult[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:ImpactBlast_Radius[MAXPLAYERS + 1][SLOTS_MAX + 1];

new bool:BoosterShotUber[2049]; //1-13
new Float:BoosterShotUber_OldCap[2049];
new Float:BoosterShotUber_OldDecay[2049];
new Float:BoosterShotUber_OldBuild[2049];

new bool:ReviveUber[2049]; //1-14
new Float:ReviveUber_SelfUber[2049];
new Float:ReviveUber_Uber[2049];
new Float:ReviveUber_PatientHealing[2049];
new Float:ReviveUber_MedicHealing[2049];
new Float:ReviveUber_SelfHealing[2049];
new Float:ReviveUber_PatientHealth[2049];
new Float:ReviveUber_Delay[2049];
new bool:TrackPatientChanges[2049];

new bool:BlitzkriegBuffs[2049]; //1-15
new BlitzkriegBuffs_Buff[2049];
new Float:BlitzkriegBuffs_Delay[2049];
new Float:KralleBuffs_PassHealSpd[2049];
new Float:KralleBuffs_PassFireSpd[2049];
new Float:KralleBuffs_PassReloadSpd[2049];
new Float:KralleBuffs_PassMoveSpd[2049];
new Float:KralleBuffs_UberHealSpd[2049];
new Float:KralleBuffs_UberFireSpd[2049];
new Float:KralleBuffs_UberReloadSpd[2049];
new Float:KralleBuffs_UberMoveSpd[2049];
new Float:KralleBuffs_OldHealSpd[2049];
new Float:KralleBuffs_Delay[MAXPLAYERS + 1];

new bool:AttacksCarryBombs[2049]; //1-16
new Float:AttacksCarryBombs_MaxDur[2049];
new Float:AttacksCarryBombs_ArmTime[2049];
new Float:AttacksCarryBombs_MinDMG[2049];
new Float:AttacksCarryBombs_MaxDMG[2049];
new Float:AttacksCarryBombs_Blast[2049];
new AttacksCarryBombs_MaxBombs[2049];
new AttacksCarryBombs_Bombs[2049];
new bool:CarryingBomb[2049];
new Float:CarryingBomb_DMG[2049];
new Float:CarryingBomb_Dur[2049];
new Float:CarryingBomb_Time[2049];
new Float:CarryingBomb_Min[2049];
new Float:CarryingBomb_Max[2049];
new Float:CarryingBomb_Blast[2049];
new Float:CarryingBomb_ArmTime[2049];
new CarryingBomb_Bomber[MAXPLAYERS + 1];

new bool:HeavyDutyRifle[2049]; //1-17
new Float:HeavyDutyRifle_Mult[2049];
new HeavyDutyRifle_MaxStacks[2049];
new HeavyDutyRifle_Stacks[2049];
new Float:HeavyDutyRifle_Delay[2049];
new Float:HeavyDutyRifle_DecayDur[2049];

new bool:SpookOLanterns[2049]; //1-18
new Float:SpookOLanterns_TotalDMG[2049];

new bool:LeapCloak[MAXPLAYERS + 1][SLOTS_MAX + 1]; //1-19
new Float:LeapCloak_LeapVel[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:LeapCloak_LungeMult[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:LeapCloak_Drain[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:LeapCloak_Leaping[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:LeapCloak_AirControl[MAXPLAYERS + 1][SLOTS_MAX + 1];

new bool:DamageChargesMedigun[MAXPLAYERS + 1][SLOTS_MAX + 1]; //1-20
new Float:DamageChargesMedigun_MedicDmg[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:DamageChargesMedigun_PatientDmg[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:DamageChargesMedigun_UberedMult[MAXPLAYERS + 1][SLOTS_MAX + 1];

new bool:RadiusHealing[MAXPLAYERS + 1][SLOTS_MAX + 1]; //1-21
new Float:RadiusHealing_Radius[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:RadiusHealing_UberedRadius[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:RadiusHealing_Healing[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:RadiusHealing_UberedHealing[MAXPLAYERS + 1][SLOTS_MAX + 1];
new RadiusHealing_Mode[MAXPLAYERS + 1][SLOTS_MAX + 1];
new RadiusHealing_Mode2[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:RadiusHealing_Delay[MAXPLAYERS + 1];

new bool:RadiusUber[MAXPLAYERS + 1][SLOTS_MAX + 1]; //1-22
new RadiusUber_Cond1[MAXPLAYERS + 1][SLOTS_MAX + 1];
new RadiusUber_Cond2[MAXPLAYERS + 1][SLOTS_MAX + 1];
new RadiusUber_ExclusiveCond[MAXPLAYERS + 1][SLOTS_MAX + 1];
new RadiusUber_ExclusiveCond2[MAXPLAYERS + 1][SLOTS_MAX + 1];
new RadiusUber_ExclusiveCond3[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:RadiusUber_Radius[MAXPLAYERS + 1][SLOTS_MAX + 1];
new RadiusUber_Mode[MAXPLAYERS + 1][SLOTS_MAX + 1];

new bool:KnifeGunSpy[2049];
new Float:KnifeGunSpy_FireRate[2049];
new Float:KnifeGunSpy_ReloadRate[2049];
new Float:KnifeGunSpy_SwitchSpeed[2049];
new Float:KnifeGunSpy_MoveSpeed[2049];
new Float:KnifeGunSpy_CloakSpeed[2049];
new Float:KnifeGunSpy_Delay[2049];
new Float:KnifeGunSpy_MaxDelay[2049];
new Float:KnifeGunSpy_Drain[2049];
new KnifeGunSpy_Stacks[2049];
new KnifeGunSpy_MaxStacks[2049];
new bool:KnifeGunSpy_Draining[2049];
new Handle:KnifeGunSpy_Display;

new LastWeaponHurtWith[MAXPLAYERS + 1]; //1-23
new Float:LastTick[MAXPLAYERS + 1];
new LastHealPatient[MAXPLAYERS + 1] = -1;
new MaxClip[2049];
new MaxAmmo[2049];
new bool:AmmoIsMetal[2049];
new Float:MaxEnergy[2049];
new Handle:hudText_PriWeapon;
new Handle:hudText_SecWeapon;
new Handle:hudText_MelWeapon;
new Handle:hudText_PriWearer;
new Handle:hudText_Wearer;

//Hooks, Sounds, Handles... start here
//*2
public OnPluginStart() { //2-1

	HookEvent("player_death", Event_Death);
	HookEntityOutput("item_healthkit_small", "OnPlayerTouch", OnTouchHealthKit);
	HookEntityOutput("item_healthkit_medium", "OnPlayerTouch", OnTouchHealthKit);
	HookEntityOutput("item_healthkit_full", "OnPlayerTouch", OnTouchHealthKit);
	HookEvent("player_spawn", Event_Respawn);
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i)) continue;
		{
		OnClientPutInServer(i);
		}
	}
	hudText_PriWeapon = CreateHudSynchronizer();
	hudText_SecWeapon = CreateHudSynchronizer();
	hudText_MelWeapon = CreateHudSynchronizer();
	hudText_PriWearer = CreateHudSynchronizer();
	hudText_Wearer = CreateHudSynchronizer();
	KnifeGunSpy_Display = CreateHudSynchronizer();
}
public OnMapStart() { //2-2
	
	PrecacheSound("npc/attack_helicopter/aheli_charge_up.wav", true);
	PrecacheSound("npc/vort/health_charge.wav", true);
	PrecacheSound("vehicles/crane/crane_magnet_release.wav", true);
	PrecacheSound("weapons/vaccinator_toggle.wav", true);
	PrecacheSound("weapons/spy_shield_break.wav", true);
	PrecacheSound("weapons/recharged.wav", true);
	PrecacheSound("mvm/mvm_bought_upgrade.wav", true);
	PrecacheSound("mvm/mvm_money_pickup.wav", true);
	PrecacheSound("mvm/mvm_money_vanish.wav", true);
	PrecacheSound("weapons/gunpickup2.wav", true);
	PrecacheSound("weapons/physcannon/physcannon_charge.wav", true);
	PrecacheSound("npc/scanner/cbot_discharge1.wav", true);
	PrecacheSound("mvm/mvm_revive.wav", true);
	PrecacheSound("weapons/stickybomblauncher_det.wav", true);
	PrecacheSound("weapons/drg_wrench_teleport.wav", true);
	PrecacheSound("weapons/teleporter_send.wav", true);
}
public OnClientPutInServer(client) //2-3
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
	SDKHook(client, SDKHook_OnTakeDamageAlivePost, OnTakeDamageAlivePost);
	SDKHook(client, SDKHook_PreThink, OnClientPreThink);
	
	LastWeaponHurtWith[client] = 0;
}

//Attribute Application starts here
//*3
public Action:CW3_OnAddAttribute(slot, client, const String:attrib[], const String:plugin[], const String:value[], bool:whileActive)
{
	if(!StrEqual(plugin, "zethax-attributes")) return Plugin_Continue;
	new weapon = GetPlayerWeaponSlot(client, slot);
	new Action:action;
	if(StrEqual(attrib, "refill clip on kill")) { //3-1
		
		if (weapon == -1)return Plugin_Continue;
		FullClipOnKill_Clip[client][slot] = GetClip_Weapon(weapon);
		
		FullClipOnKill[client][slot] = true;
		
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "ammo on kill")) { //3-2
		
		if (weapon == -1)return Plugin_Continue;
		
		FullClipOnKill_Ammo[client][slot] = GetAmmo_Weapon(weapon);
		FullClipOnKill_Amount[client][slot] = StringToInt(value);
		AmmoOnKill[client][slot] = true;
		action = Plugin_Handled;
		
	} else if(StrEqual(attrib, "gain resist on kill")) { //3-3
	
		new String:values[6][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		ResistOnKill_Bullet[client][slot] = StringToFloat(values[0]);
		ResistOnKill_Blast[client][slot] = StringToFloat(values[1]);
		ResistOnKill_Fire[client][slot] = StringToFloat(values[2]);
		ResistOnKill_Sentry[client][slot] = StringToFloat(values[3]);
		ResistOnKill_Knockback[client][slot] = StringToFloat(values[4]);
		ResistOnKill_MaxDur[client][slot] = StringToFloat(values[5]);
		
		ResistOnKill[client][slot] = true;
		
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "max metal on kill")) { //3-4
	
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		MetalOnKill_Metal[client][slot] = StringToFloat(values[0]);
		MetalOnKill_MaxKills[client][slot] = StringToInt(values[1]);
		MetalOnKill_Kills[client][slot] = 0;
		MetalOnKill_MaxMetal[client][slot] = StringToInt(values[2]);
		
		MetalOnKill[client][slot] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "headshot bonuses")) { //3-5
	
		new String:values[4][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		FastReloadHeadshot_Headshot[weapon] = StringToFloat(values[0]);
		FastReloadHeadshot_Bodyshot[weapon] = StringToFloat(values[1]);
		FastReloadHeadshot_Miss[weapon] = StringToFloat(values[2]);
		FastReloadHeadshot_Bonuses[weapon] = StringToInt(values[3]);
		FastReloadHeadshot_Dur[weapon] = 0.0;
		
		FastReloadHeadshot[weapon] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "store crit on headshot")) { //3-6
		
		if(weapon == -1) return Plugin_Continue;
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		StoreCritOnHeadshot_Max[weapon] = StringToInt(values[0]);
		StoreCritOnHeadshot_AddCrits[weapon] = StringToInt(values[1]);
		StoreCritOnHeadshot_Type[weapon] = StringToInt(values[2]);
		StoreCritOnHeadshot_Crits[weapon] = 0;
		StoreCritOnHeadshot[weapon] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "backstab service")) { //3-7
	
		new String:values[5][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		BackstabService_CloakSpd[client][slot] = StringToFloat(values[0]);
		BackstabService_DecloakSpd[client][slot] = StringToFloat(values[1]);
		BackstabService_MoveSpd[client][slot] = StringToFloat(values[2]);
		BackstabService_SapperPwr[client][slot] = StringToFloat(values[3]);
		BackstabService_MaxStacks[client][slot] = StringToInt(values[4]);
		BackstabService_Stacks[client][slot] = 0;
		BackstabService[client][slot] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "hammer mechanic")) { //3-8
	
		HammerMechanic[client][slot] = true;
		HammerMechanic_Fann[client][slot] = false;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "hits increase healing rate")) { //3-9
	
		new String:values[4][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		HealRateKill_Bonus[client][slot] = StringToFloat(values[0]);
		HealRateKill_MaxStacks[client][slot] = StringToInt(values[1]);
		HealRateKill_Subtract[client][slot] = StringToInt(values[2]);
		HealRateKill_Wait[client][slot] = StringToFloat(values[3]);
		HealRateKill_Stacks[client][slot] = 0;
		HealRateKill_Blood[client][slot] = 0;
		new secondary = GetPlayerWeaponSlot(client, 1);
		TF2Attrib_RemoveByName(secondary, "heal rate penalty");
		
		HealRateKill[client][slot] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "moonshine attrib")) { //3-10
	
		if (weapon == -1)return Plugin_Continue;
		new String:values[5][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		MoonshineAttrib_DMGBonus[weapon] = StringToFloat(values[0]);
		MoonshineAttrib_SwingBonus[weapon] = StringToFloat(values[1]);
		MoonshineAttrib_MaxStacks[weapon] = StringToInt(values[2]);
		MoonshineAttrib_OverhealCap[weapon] = StringToFloat(values[3]);
		MoonshineAttrib_DMGResist[weapon] = StringToFloat(values[4]);
		MoonshineAttrib_Dur[weapon] = 0.0;
		MoonshineAttrib_Stacks[weapon] = 0;
		MoonshineAttrib_Wait[weapon] = 0.0;
		MoonshineAttrib[weapon] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "dispenser minigun heal")){ //3-11
		
		DispenserMinigunHeal_HealDelay[client][slot] = StringToFloat(value);
		DispenserMinigunHeal_SelfHeal[client][slot] = GetEngineTime();
		DispenserMinigunHeal_Delay[client][slot] = GetEngineTime();
		
		DispenserMinigunHeal[client][slot] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "dispenser minigun ammo")){ //3-12
		
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		DispenserMinigunAmmo_AmmoDelay[client][slot] = StringToFloat(values[0]);
		DispenserMinigunAmmo_Ammo[client][slot] = StringToInt(values[1]);
		DispenserMinigunAmmo_Delay[client][slot] = GetEngineTime();
		
		DispenserMinigunAmmo[client][slot] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "dispenser minigun main")){ //3-13
		
		new String:values[6][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		DispenserMinigunSpecial_ChrgType[client][slot] = StringToInt(values[0]);
		DispenserMinigunSpecial_MaxChrg[client][slot] = StringToFloat(values[1]);
		DispenserMinigunSpecial_Charge[client][slot] = 0.0;
		DispenserMinigunSpecial_MaxDur[client][slot] = StringToFloat(values[2]);
		DispenserMinigunSpecial_Dur[client][slot] = 0.0;
		DispenserMinigunSpecial_MaxFuryDur[client][slot] = StringToFloat(values[3]);
		DispenserMinigunSpecial_FuryDur[client][slot] = 0.0;
		DispenserMinigunSpecial_Boost[client][slot] = StringToFloat(values[4]);
		DispenserMinigunSpecial_Radius[client][slot] = StringToInt(values[5]);
		
		DispenserMinigunSpecial[client][slot] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "brew attrib")) { //3-14
		
		new String:values[4][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		BrewAttrib_MaxDelay[client][slot] = StringToFloat(values[0]);
		BrewAttrib_MaxStacks[client][slot] = StringToInt(values[1]);
		BrewAttrib_DmgBonus[client][slot] = StringToFloat(values[2]);
		BrewAttrib_DmgResist[client][slot] = StringToFloat(values[3]);
		BrewAttrib_Delay[client][slot] = GetEngineTime();
		BrewAttrib[client][slot] = true;
		
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "charge impact deals splash damage")) { //3-15
		
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		ImpactBlast_DMGMult[client][slot] = StringToFloat(values[0]);
		ImpactBlast_Radius[client][slot] = StringToFloat(values[1]);
		ImpactBlast[client][slot] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "ubercharge is booster shot")) { //3-16
		
		if(weapon == -1) return Plugin_Continue;
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		BoosterShotUber_OldCap[weapon] = StringToFloat(values[0]);
		BoosterShotUber_OldDecay[weapon] = StringToFloat(values[1]);
		BoosterShotUber_OldBuild[weapon] = StringToFloat(values[2]);
		BoosterShotUber[weapon] = true;
		TF2Attrib_SetByName(weapon, "medigun charge is crit boost", -1.0);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "ubercharge is revive")) { //3-17
		
		if(weapon == -1) return Plugin_Continue;
		new String:values[6][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		ReviveUber_Uber[weapon] = StringToFloat(values[0]);
		ReviveUber_SelfUber[weapon] = StringToFloat(values[1]);
		ReviveUber_PatientHealing[weapon] = StringToFloat(values[2]);
		ReviveUber_MedicHealing[weapon] = StringToFloat(values[3]);
		ReviveUber_SelfHealing[weapon] = StringToFloat(values[4]);
		ReviveUber_PatientHealth[weapon] = StringToFloat(values[5]);
		
		ReviveUber[weapon] = true;
		TF2Attrib_SetByName(weapon, "medigun charge is crit boost", -1.0);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "kralle buff system")) { //3-18
		
		if(weapon == -1) return Plugin_Continue;
		new String:values[9][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		KralleBuffs_PassHealSpd[weapon] = StringToFloat(values[0]);
		KralleBuffs_PassFireSpd[weapon] = StringToFloat(values[1]);
		KralleBuffs_PassReloadSpd[weapon] = StringToFloat(values[2]);
		KralleBuffs_PassMoveSpd[weapon] = StringToFloat(values[3]);
		KralleBuffs_UberHealSpd[weapon] = StringToFloat(values[4]);
		KralleBuffs_UberFireSpd[weapon] = StringToFloat(values[5]);
		KralleBuffs_UberReloadSpd[weapon] = StringToFloat(values[6]);
		KralleBuffs_UberMoveSpd[weapon] = StringToFloat(values[7]);
		KralleBuffs_OldHealSpd[weapon] = StringToFloat(values[8]);
		
		TF2Attrib_SetByName(weapon, "medigun charge is crit boost", -1.0);
		BlitzkriegBuffs[weapon] = true;
		TrackPatientChanges[weapon] = true;
		BlitzkriegBuffs_Buff[weapon] = 1;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "attacks carry bombs")) { //3-19
		
		if(weapon == -1) return Plugin_Continue;
		new String:values[6][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		AttacksCarryBombs[weapon] = true;
		AttacksCarryBombs_MaxDur[weapon] = StringToFloat(values[0]);
		AttacksCarryBombs_ArmTime[weapon] = StringToFloat(values[1]);
		AttacksCarryBombs_MinDMG[weapon] = StringToFloat(values[2]);
		AttacksCarryBombs_MaxDMG[weapon] = StringToFloat(values[3]);
		AttacksCarryBombs_Blast[weapon] = StringToFloat(values[4]);
		AttacksCarryBombs_MaxBombs[weapon] = StringToInt(values[5]);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "headshots increase headshot dmg")) { //3-20
		
		if(weapon == -1) return Plugin_Continue;
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		HeavyDutyRifle_Mult[weapon] = StringToFloat(values[0]);
		HeavyDutyRifle_MaxStacks[weapon] = StringToInt(values[1]);
		HeavyDutyRifle_DecayDur[weapon] = StringToFloat(values[2]);
		HeavyDutyRifle_Stacks[weapon] = 0;
		TF2Attrib_RemoveByName(weapon, "headshot damage increase");
		HeavyDutyRifle[weapon] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "mod bat launches lanterns")) { //3-21
		
		if(weapon == -1) return Plugin_Continue;
		TF2Attrib_SetByName(weapon, "mod bat launches ornaments", 1.0);
		SpookOLanterns_TotalDMG[weapon] = 0.0;
		SpookOLanterns[weapon] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "leap cloak")) { //3-22
		
		new String:values[4][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		LeapCloak[client][slot] = true;
		LeapCloak_LeapVel[client][slot] = StringToFloat(values[0]);
		LeapCloak_LungeMult[client][slot] = StringToFloat(values[1]);
		LeapCloak_Drain[client][slot] = StringToFloat(values[2]);
		LeapCloak_AirControl[client][slot] = StringToFloat(values[3]);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "damage charges medigun")) { //3-23
		
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		DamageChargesMedigun[client][slot] = true;
		DamageChargesMedigun_MedicDmg[client][slot] = StringToFloat(values[0]);
		DamageChargesMedigun_PatientDmg[client][slot] = StringToFloat(values[1]);
		DamageChargesMedigun_UberedMult[client][slot] = StringToFloat(values[2]);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "medigun has radius healing")) { //3-24
	
		new String:values[6][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		RadiusHealing[client][slot] = true;
		RadiusHealing_Radius[client][slot] = StringToFloat(values[0]);
		RadiusHealing_UberedRadius[client][slot] = StringToFloat(values[1]);
		RadiusHealing_Healing[client][slot] = StringToFloat(values[2]);
		RadiusHealing_UberedHealing[client][slot] = StringToFloat(values[3]);
		RadiusHealing_Mode[client][slot] = StringToInt(values[4]);
		RadiusHealing_Mode2[client][slot] = StringToInt(values[4]);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "medigun has radial ubercharge")) { //3-25
	
		new String:values[7][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		RadiusUber[client][slot] = true;
		RadiusUber_Cond1[client][slot] = StringToInt(values[0]);
		RadiusUber_Cond2[client][slot] = StringToInt(values[1]);
		RadiusUber_ExclusiveCond[client][slot] = StringToInt(values[2]);
		RadiusUber_ExclusiveCond2[client][slot] = StringToInt(values[3]);
		RadiusUber_ExclusiveCond3[client][slot] = StringToInt(values[4]);
		RadiusUber_Radius[client][slot] = StringToFloat(values[5]);
		RadiusUber_Mode[client][slot] = StringToInt(values[6]);
		
		new secondary = GetPlayerWeaponSlot(client, 1);
		TF2Attrib_SetByName(secondary, "medigun charge is crit boost", -1.0);
		
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "knife gun spy")) {
	
		if (weapon == -1)return Plugin_Continue;
		
		new String:values[8][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		KnifeGunSpy[weapon] = true;
		KnifeGunSpy_MoveSpeed[weapon] = StringToFloat(values[0]);
		KnifeGunSpy_FireRate[weapon] = StringToFloat(values[1]);
		KnifeGunSpy_ReloadRate[weapon] = StringToFloat(values[2]);
		KnifeGunSpy_SwitchSpeed[weapon] = StringToFloat(values[3]);
		KnifeGunSpy_CloakSpeed[weapon] = StringToFloat(values[4]);
		KnifeGunSpy_MaxStacks[weapon] = StringToInt(values[5]);
		KnifeGunSpy_MaxDelay[weapon] = StringToFloat(values[6]);
		KnifeGunSpy_Drain[weapon] = StringToFloat(values[7]);
		action = Plugin_Handled;
	}
		
	if (!m_bHasAttribute[client][slot]) m_bHasAttribute[client][slot] = bool:action;
	return action;
}

public Action:TF2_CalcIsAttackCritical(client, weapon, String:weaponname[], &bool:result)
{
	new slot = GetClientSlot(client);
	new wep = Client_GetActiveWeapon(client);
	if(slot == -1) return Plugin_Continue;
	if(wep == -1)return Plugin_Continue;
	if (!m_bHasAttribute[client][slot]) return Plugin_Continue;
	if(BrewAttrib[client][slot]) BrewAttrib_Delay[client][slot] = GetEngineTime();
	if(slot == 1 && StoreCritOnHeadshot[wep] && StoreCritOnHeadshot_Crits[wep] > 0)
		StoreCritOnHeadshot_Crits[wep]--;
	return Plugin_Continue;
}

//OnTakeDamage starts here (obviously)
//*4
public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3], damageCustom)
{
	if (attacker <= 0 || attacker > MaxClients) return Plugin_Continue;
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
	new Action:action;
	new wep = GetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon");
	new sec = GetPlayerWeaponSlot(attacker, 1);
	new secondary = GetPlayerWeaponSlot(victim, 1);
	new melee = GetPlayerWeaponSlot(attacker, 2);
	if(sec == -1) sec = 0;
	if(secondary == -1) secondary = 0;
	if(melee == -1) melee = 0;
	if(weapon > -1)
	{
		LastWeaponHurtWith[attacker] = weapon;
		if(slot > -1)
		{
			if(m_bHasAttribute[attacker][slot])
			{
				//4-1
				if(BackstabService[attacker][slot] && damage > 0.0 && damageCustom == TF_CUSTOM_BACKSTAB && BackstabService_Stacks[attacker][slot] < BackstabService_MaxStacks[attacker][slot])
				{
					TF2Attrib_RemoveByName(weapon, "mult cloak rate");
					TF2Attrib_RemoveByName(weapon, "mult decloak rate");
					TF2Attrib_RemoveByName(weapon, "move speed bonus");
					TF2Attrib_RemoveByName(weapon, "SET BONUS: cloak blink time penalty");
					BackstabService_Stacks[attacker][slot]++;
					new Float:cloakspd = (0.0 - (BackstabService_CloakSpd[attacker][slot] * BackstabService_Stacks[attacker][slot]));
					new Float:decloakspd = (1.0 - (BackstabService_DecloakSpd[attacker][slot] * BackstabService_Stacks[attacker][slot]));
					new Float:movespd = (BackstabService_MoveSpd[attacker][slot] * BackstabService_Stacks[attacker][slot] + 1);
					new Float:sapperpwr = (BackstabService_SapperPwr[attacker][slot] * BackstabService_Stacks[attacker][slot] + 1);
					TF2Attrib_SetByName(weapon, "mult cloak rate", cloakspd);
					TF2Attrib_SetByName(weapon, "mult decloak rate", decloakspd);
					TF2Attrib_SetByName(weapon, "move speed bonus", movespd);
					TF2Attrib_SetByName(weapon, "SET BONUS: cloak blink time penalty", sapperpwr);
					TF2_AddCondition(attacker, TFCond_SpeedBuffAlly, 0.001);
				}
				if(sec > -1 && HealRateKill[attacker][slot] && damage > 0.0 && TF2_GetPlayerClass(attacker) == TFClass_Medic) //4-2
				{
					HealRateKill_Stacks[attacker][slot]++;
					if(HealRateKill_Stacks[attacker][slot] > HealRateKill_MaxStacks[attacker][slot]) HealRateKill_Stacks[attacker][slot] = HealRateKill_MaxStacks[attacker][slot];
				}
				if(DispenserMinigunSpecial[attacker][slot] && DispenserMinigunSpecial_ChrgType[attacker][slot] == 2) //4-3
				{
					DispenserMinigunSpecial_Charge[attacker][slot] += damage;
					if(DispenserMinigunSpecial_Charge[attacker][slot] > DispenserMinigunSpecial_MaxChrg[attacker][slot]) DispenserMinigunSpecial_Charge[attacker][slot] = DispenserMinigunSpecial_MaxChrg[attacker][slot];
				}
				if(BrewAttrib[attacker][slot] && damage > 0.0) //4-4
				{
					if(BrewAttrib_Stacks[attacker][slot] > 0) BrewAttrib_Stacks[attacker][slot]--;
					new Float:dmgresist = 1.0 - (BrewAttrib_DmgResist[attacker][slot] * BrewAttrib_Stacks[attacker][slot]);
					new Float:dmgbonus = 1.0 + (BrewAttrib_DmgBonus[attacker][slot] * BrewAttrib_Stacks[attacker][slot]);
					TF2Attrib_RemoveByName(weapon, "dmg taken increased");
					TF2Attrib_RemoveByName(weapon, "damage bonus");
					TF2Attrib_SetByName(weapon, "dmg taken increased", dmgresist);
					TF2Attrib_SetByName(weapon, "damage bonus", dmgbonus);
					BrewAttrib_Delay[attacker][slot] = GetEngineTime();
				}
				if(KnifeGunSpy[weapon] && damageCustom == TF_CUSTOM_BACKSTAB)
				{
					KnifeGunSpy_Stacks[weapon]++;
					if (KnifeGunSpy_Stacks[weapon] > KnifeGunSpy_MaxStacks[weapon])KnifeGunSpy_Stacks[weapon] = KnifeGunSpy_MaxStacks[weapon];
					KnifeGunSpy_Delay[weapon] = GetEngineTime();
					KnifeGunSpy_Draining[weapon] = false;
					damage = 13.333;
					action = Plugin_Changed;
				}
			}
			//4-5
			if((damagetype & DMG_CRIT) && damage > 0.0) if(weapon == melee && StoreCritOnHeadshot[weapon] && StoreCritOnHeadshot_Crits[weapon] > 0) StoreCritOnHeadshot_Crits[weapon]--;
			
			if(BrewAttrib[victim][slot] && TF2_IsPlayerInCondition(victim, TFCond_Slowed)) //4-6
			{
				if(BrewAttrib_Stacks[victim][slot] < BrewAttrib_MaxStacks[victim][slot]) BrewAttrib_Stacks[victim][slot]++;
				new Float:dmgresist = 1.0 - (BrewAttrib_DmgResist[victim][slot] * BrewAttrib_Stacks[victim][slot]);
				new Float:dmgbonus = 1.0 + (BrewAttrib_DmgBonus[victim][slot] * BrewAttrib_Stacks[victim][slot]);
				TF2Attrib_RemoveByName(wep, "dmg taken increased");
				TF2Attrib_RemoveByName(wep, "damage bonus");
				TF2Attrib_SetByName(wep, "dmg taken increased", dmgresist);
				TF2Attrib_SetByName(wep, "damage bonus", dmgbonus);
				BrewAttrib_Delay[victim][slot] = GetEngineTime();
			}
		}
	}
	return action;
}

//OnTakeDamagePost starts here (obviously)
//*5
public OnTakeDamagePost(victim, attacker, inflictor, Float:damage, damagetype, weapon, const Float:damageForce[3], const Float:damagePosition[3], damageCustom)
{
	if (!Client_IsValid(attacker)) return;
	if (!IsValidEdict(weapon))return;
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
	if(slot > -1)
	{
		if(m_bHasAttribute[attacker][slot])
		{
			if(weapon > -1 && AttacksCarryBombs[weapon]) //5-1
			{
				if(AttacksCarryBombs_Bombs[weapon] >= AttacksCarryBombs_MaxBombs[weapon]) return;
				if(CarryingBomb[victim]) return;
				CarryingBomb[victim] = true;
				AttacksCarryBombs_Bombs[weapon] = 0;
				CarryingBomb_Time[victim] = GetEngineTime();
				CarryingBomb_Dur[victim] = GetEngineTime();
				CarryingBomb_DMG[victim] = AttacksCarryBombs_MinDMG[weapon];
				CarryingBomb_Bomber[victim] = attacker;
			}
			if(weapon > -1 && SpookOLanterns[weapon] && damageCustom == 22 && TF2_GetPlayerClass(victim) != TFClass_Pyro) //5-2
			{
				new Float:burndur;
				SpookOLanterns_TotalDMG[weapon] += damage;
				while(SpookOLanterns_TotalDMG[weapon] > 1.5)
				{
					TF2_RemoveCondition(victim, TFCond_Bleeding);
					TF2_RemoveCondition(victim, TFCond_Dazed);
					SpookOLanterns_TotalDMG[weapon] -= 1.5;
					burndur += 1.5;
					if(burndur > 10.0) burndur = 10.0;
				}
				if(SpookOLanterns_TotalDMG[weapon] < 1.5)
				{
					TF2_IgnitePlayer(victim, attacker);
					m_hTimers[victim][AfterburnTimerDuration] = CreateTimer(burndur, SpookOLanterns_BurnDur, victim);
				}
			}
			if(FastReloadHeadshot[weapon]) //5-3
			{
				if(damage >= 1.0 && damageCustom == TF_CUSTOM_HEADSHOT)
				{
					FastReloadHeadshot_Dur[weapon] = GetEngineTime();
					TF2Attrib_RemoveByName(weapon, "faster reload rate");
					TF2Attrib_SetByName(weapon, "faster reload rate", FastReloadHeadshot_Headshot[weapon]);
					if(FastReloadHeadshot_Bonuses[weapon] == 1)
					{
						TF2_AddCondition(attacker, TFCond:46, 0.5, attacker);
						SetEntPropFloat(weapon, Prop_Send, "m_flChargedDamage", FastReloadHeadshot_RifleCharge[weapon]);
					}
				}
				else if(damage >= 1.0 && damageCustom != TF_CUSTOM_HEADSHOT)
				{
					FastReloadHeadshot_Dur[weapon] = GetEngineTime();
					TF2Attrib_RemoveByName(weapon, "faster reload rate");
					TF2Attrib_SetByName(weapon, "faster reload rate", FastReloadHeadshot_Bodyshot[weapon]);
				}
			}
		}
	}
	if(HasAttribute(attacker, _, ImpactBlast) && damageCustom == TF_CUSTOM_CHARGE_IMPACT) //5-4
	{
		new team = GetClientTeam(victim);
		for(new i = 1; i <= MaxClients; i++)
		{
			new Float:Pos1[3];
			GetClientAbsOrigin(attacker, Pos1);
			if(IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == team && i != victim)
			{
				new Float:Pos2[3];
				GetClientAbsOrigin(i, Pos2);
				new Float:distance = GetVectorDistance(Pos1, Pos2);
				if(distance <= GetAttributeValueF(attacker, _, ImpactBlast, ImpactBlast_Radius, 0.0))
				{
					Entity_Hurt(i, RoundToFloor(damage*GetAttributeValueF(attacker, _, ImpactBlast, ImpactBlast_DMGMult, 0.0)), attacker, TF_CUSTOM_BOOTS_STOMP, "tf_wearable_demoshield");
				}
			}
		}
	}
}

//OnTakeDamageAlivePost starts here (obviously)
//*6
public OnTakeDamageAlivePost(victim, attacker, inflictor, Float:damage, damagetype, weapon, const Float:damageForce[3], const Float:damagePosition[3], damageCustom)
{
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
	if(attacker > 0 && slot > -1 && GetClientTeam(attacker) != GetClientTeam(victim))
	{
		new secondary = GetPlayerWeaponSlot(attacker, 1);
		//6-1
		if(HasAttribute(attacker, 1, DamageChargesMedigun) && secondary > -1) //If the attacker's secondary has DamageChargesMedigun set to true and the secondary exists
		{
			new Float:ubercharge = GetEntPropFloat(secondary, Prop_Send, "m_flChargeLevel"); //Gets the user's current ubercharge level
			new Float:charge = (damage * GetAttributeValueF(attacker, _, DamageChargesMedigun, DamageChargesMedigun_MedicDmg) / 100.0); //Calculates how much charge will be gained
			if (GetEntProp(secondary, Prop_Send, "m_bChargeRelease"))charge *= GetAttributeValueF(attacker, _, DamageChargesMedigun, DamageChargesMedigun_UberedMult);
			ubercharge += charge; //Adds the calculated charge gain to the ubercharge value
			if (ubercharge > 1.0)ubercharge = 1.0; //If the ubercharge value is currently over 1.0 (or 100% for the medigun), set it back to 1.0
			SetEntPropFloat(secondary, Prop_Send, "m_flChargeLevel", ubercharge); //Sets the user's ubercharge level to equal the ubercharge value
		}
		//6-2
		if(GetEntProp(attacker, Prop_Send, "m_nNumHealers") > 0) //If the attacker has at least 1 healer
		{
			for (new i = 1; i <= MaxClients; i++) //Creates a value 'i' which increments as long as it's less than or equal to MaxClients
			{
				if (!IsValidClient(i) || !IsPlayerAlive(i))continue; //If the detected client doesn't exist, move to the next client
				if (attacker == i)continue; //If the detected client is the attacker, move to the next client
				if (attacker != GetMediGunPatient(i))continue; //If the attacker is not the detected client's medigun patient, move to the next client
				if (!HasAttribute(i, 1, DamageChargesMedigun))continue; //If the detected client's medigun does not have DamageChargesMedigun set to true, move to the next client
				new sec = GetPlayerWeaponSlot(i, 1); //Get the detected client's secondary
				if (sec < 0)continue; //If the detected client's secondary doesn't exist, move to the next client
				new Float:ubercharge = GetEntPropFloat(sec, Prop_Send, "m_flChargeLevel"); //Get the detected client's current ubercharge level
				new Float:charge = (damage * GetAttributeValueF(i, _, DamageChargesMedigun, DamageChargesMedigun_PatientDmg) / 100.0); //Calculate how much ubercharge the detected client will gain
				if (GetEntProp(sec, Prop_Send, "m_bChargeRelease"))charge *= GetAttributeValueF(i, _, DamageChargesMedigun, DamageChargesMedigun_UberedMult);
				ubercharge += charge; //Add the calculated number onto the ubercharge value
				if (ubercharge > 1.0)ubercharge = 1.0; //If the ubercharge value is greater than 1.0 (or 100% for the medigun), set it back to 1.0
				SetEntPropFloat(sec, Prop_Send, "m_flChargeLevel", ubercharge); //Set the detected client's ubercharge level to equal the ubercharge value
			}
		}
	}
}

public Action:SpookOLanterns_BurnDur(Handle:timer, any:victim)
{
	TF2_RemoveCondition(victim, TFCond_OnFire);
	m_hTimers[victim][AfterburnTimerDuration] = INVALID_HANDLE;
}

//OnPlayerRunCmd starts here (obviously)
//*7
public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:ang[3], &weapon2)
{
	new weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if (weapon <= 0 || weapon > 2048) return Plugin_Continue;
	new slot = GetClientSlot(client);
	if(slot == -1) return Plugin_Continue;
	
	if (!IsValidEdict(slot) || slot == -1 || slot > 2048) return Plugin_Continue;
	if(buttons & IN_ATTACK3) //7-2
	{
		if(HammerMechanic[client][slot])
		{
			if(HammerMechanic_Fann[client][slot] == false && HammerMechanic_Wait[client][slot] <= 0.0)
			{
				HammerMechanic_Fann[client][slot] = true;
				TF2Attrib_SetByName(weapon, "fire rate bonus", 0.67);
				TF2Attrib_SetByName(weapon, "Reload time decreased", 0.85);
				TF2Attrib_SetByName(weapon, "move speed penalty", 0.75);
				TF2Attrib_RemoveByName(weapon, "single wep deploy time decreased");
				TF2Attrib_RemoveByName(weapon, "single wep holster time increased");
				TF2Attrib_RemoveByName(weapon, "Projectile speed increased");
				EmitSoundToClient(client, "weapons/vaccinator_toggle.wav");
				TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
				HammerMechanic_Wait[client][slot] = 0.2;
			}
			else if (HammerMechanic_Fann[client][slot] == true && HammerMechanic_Wait[client][slot] <= 0.0)
			{
				HammerMechanic_Fann[client][slot] = false;
				TF2Attrib_RemoveByName(weapon, "fire rate bonus");
				TF2Attrib_RemoveByName(weapon, "move speed penalty");
				TF2Attrib_RemoveByName(weapon, "Reload time decreased");
				TF2Attrib_SetByName(weapon, "single wep deploy time decreased", 0.75);
				TF2Attrib_SetByName(weapon, "single wep holster time increased", 0.75);
				TF2Attrib_SetByName(weapon, "Projectile speed increased", 1.5);
				EmitSoundToClient(client, "weapons/vaccinator_toggle.wav");
				TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
				HammerMechanic_Wait[client][slot] = 0.2;
			}
		}
	}
	//7-3
	if(DispenserMinigunSpecial[client][slot] && GetAmmo_Weapon(slot) > 0) //Special thanks to CHAWLZ! for helping me out with this one and introducing me to GetEngineTime() !
	{
		if(TF2_IsPlayerInCondition(client, TFCond_Slowed) && DispenserMinigunHeal[client][slot]) //I borrowed from Orion's code for detecting the position of teammates around the user. Thanks!
		{
			new team = GetClientTeam(client);
			TF2_AddCondition(client, TFCond:20, 0.1);
			//7-4
			if(DispenserMinigunSpecial_FuryDur[client][slot] <= 0.0 && DispenserMinigunSpecial_Dur[client][slot] <= 0.0 && GetEngineTime() >= DispenserMinigunHeal_Delay[client][slot] + DispenserMinigunHeal_HealDelay[client][slot])
			{
				for(new i = 1 ; i <= MaxClients ; i++) 
				{
					new Float:Pos1[3];
					GetClientAbsOrigin(client, Pos1);
					if (i != client && IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == team)
					{
						new Float:Pos2[3];
						GetClientAbsOrigin(i, Pos2);
						new Float:distance = GetVectorDistance(Pos1, Pos2);
						if(distance <= DispenserMinigunSpecial_Radius[client][slot])
						{
							TF2_AddCondition(i, TFCond:20, 0.1);
							new teamhealth = GetClientHealth(i);
							if(GetClientHealth(i) < GetEntProp(i, Prop_Data, "m_iMaxHealth")) SetEntityHealth(i, teamhealth+1);
							if(DispenserMinigunSpecial_ChrgType[client][slot] == 1 && GetClientHealth(i) < GetEntProp(i, Prop_Data, "m_iMaxHealth")) DispenserMinigunSpecial_Charge[client][slot]++;
							if(DispenserMinigunSpecial_Charge[client][slot] > DispenserMinigunSpecial_MaxChrg[client][slot]) DispenserMinigunSpecial_Charge[client][slot] = DispenserMinigunSpecial_MaxChrg[client][slot];
							
							DispenserMinigunHeal_Delay[client][slot] = GetEngineTime();
						}
					}
				}
				
			}
			if(DispenserMinigunSpecial_Dur[client][slot] > 0.0 && GetEngineTime() >= DispenserMinigunHeal_Delay[client][slot] + (DispenserMinigunHeal_HealDelay[client][slot] * (1.0 - DispenserMinigunSpecial_Boost[client][slot])))
			{
				for(new i = 1 ; i <= MaxClients ; i++) 
				{
					new Float:Pos1[3];
					GetClientAbsOrigin(client, Pos1);
					if (i != client && IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == team)
					{
						new Float:Pos2[3];
						GetClientAbsOrigin(i, Pos2);
						new Float:distance = GetVectorDistance(Pos1, Pos2);
						if(distance <= DispenserMinigunSpecial_Radius[client][slot])
						{
							TF2_AddCondition(i, TFCond:20, 0.1);
							new teamhealth = GetClientHealth(i);
							if(GetClientHealth(i) < GetEntProp(i, Prop_Data, "m_iMaxHealth")) SetEntityHealth(i, teamhealth+1);
							if(DispenserMinigunSpecial_ChrgType[client][slot] == 1 && GetClientHealth(i) < GetEntProp(i, Prop_Data, "m_iMaxHealth")) DispenserMinigunSpecial_Charge[client][slot]++;
							if(DispenserMinigunSpecial_Charge[client][slot] > DispenserMinigunSpecial_MaxChrg[client][slot]) DispenserMinigunSpecial_Charge[client][slot] = DispenserMinigunSpecial_MaxChrg[client][slot];
						}
					}
				}
				
			}
			if(DispenserMinigunSpecial_FuryDur[client][slot] > 0.0 && GetEngineTime() >= DispenserMinigunHeal_Delay[client][slot] + (DispenserMinigunHeal_HealDelay[client][slot] * (1.0 - (DispenserMinigunSpecial_Boost[client][slot] * 2.0))))
			{
				for(new i = 1 ; i <= MaxClients ; i++) 
				{
					new Float:Pos1[3];
					GetClientAbsOrigin(client, Pos1);
					if (IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == team)
					{
						new Float:Pos2[3];
						GetClientAbsOrigin(i, Pos2);
						new Float:distance = GetVectorDistance(Pos1, Pos2);
						if(distance <= DispenserMinigunSpecial_Radius[client][slot] * 2) 
						{
							TF2_AddCondition(i, TFCond:20, 0.1);
							new teamhealth = GetClientHealth(i);
							if(GetClientHealth(i) < GetEntProp(i, Prop_Data, "m_iMaxHealth")) SetEntityHealth(i, teamhealth+1);
						}
					}
				}
			}
			if(DispenserMinigunSpecial_FuryDur[client][slot] <= 0.0 && DispenserMinigunSpecial_Dur[client][slot] <= 0.0 && GetEngineTime() >= DispenserMinigunHeal_SelfHeal[client][slot] + DispenserMinigunHeal_HealDelay[client][slot])
			{
				new health = GetClientHealth(client);
				if(health < GetEntProp(client, Prop_Data, "m_iMaxHealth")) SetEntityHealth(client, health+1);
				DispenserMinigunHeal_SelfHeal[client][slot] = GetEngineTime();
			}
			if(DispenserMinigunSpecial_Dur[client][slot] > 0.0 && GetEngineTime() >= DispenserMinigunHeal_SelfHeal[client][slot] + (DispenserMinigunHeal_HealDelay[client][slot] * (1.0 - DispenserMinigunSpecial_Boost[client][slot])))
			{
				new health = GetClientHealth(client);
				if(health < GetEntProp(client, Prop_Data, "m_iMaxHealth")) SetEntityHealth(client, health+1);
			}
			else if(DispenserMinigunSpecial_FuryDur[client][slot] > 0.0 && GetEngineTime() >= DispenserMinigunHeal_SelfHeal[client][slot] + (DispenserMinigunHeal_HealDelay[client][slot] * (1.0 - (DispenserMinigunSpecial_Boost[client][slot] * 2.0))))
			{
				new health = GetClientHealth(client);
				if(health < GetEntProp(client, Prop_Data, "m_iMaxHealth")) SetEntityHealth(client, health+1);
			}
		}
		if(DispenserMinigunSpecial_FuryDur[client][slot] > 0.0 && GetEngineTime() >= DispenserMinigunHeal_SelfHeal[client][slot] + (DispenserMinigunHeal_HealDelay[client][slot] * (1.0 - (DispenserMinigunSpecial_Boost[client][slot] * 2.0))))
		{
			DispenserMinigunSpecial_FuryDur[client][slot] -= (DispenserMinigunHeal_HealDelay[client][slot] * (1.0 - (DispenserMinigunSpecial_Boost[client][slot] * 2.0)));
			DispenserMinigunSpecial_Dur[client][slot] = 0.0;
			DispenserMinigunHeal_Delay[client][slot] = GetEngineTime();
			DispenserMinigunHeal_SelfHeal[client][slot] = GetEngineTime();
		}
		else if(DispenserMinigunSpecial_Dur[client][slot] > 0.0 && GetEngineTime() >= DispenserMinigunHeal_SelfHeal[client][slot] + (DispenserMinigunHeal_HealDelay[client][slot] * (1.0 - DispenserMinigunSpecial_Boost[client][slot])))
		{
			DispenserMinigunSpecial_Dur[client][slot] -= (DispenserMinigunHeal_HealDelay[client][slot] * (1.0 - DispenserMinigunSpecial_Boost[client][slot]));
			DispenserMinigunHeal_Delay[client][slot] = GetEngineTime();
			DispenserMinigunHeal_SelfHeal[client][slot] = GetEngineTime();
		}
		//7-5
		if(TF2_IsPlayerInCondition(client, TFCond_Slowed) && DispenserMinigunAmmo[client][slot]) //I borrowed from Orion's code for detecting the position of teammates around the user. Thanks!
		{
			new team = GetClientTeam(client);
			if(DispenserMinigunSpecial_FuryDur[client][slot] <= 0.0 && DispenserMinigunSpecial_Dur[client][slot] <= 0.0 && GetEngineTime() >= DispenserMinigunAmmo_Delay[client][slot] + DispenserMinigunAmmo_AmmoDelay[client][slot])
			{
				for(new i = 1 ; i <= MaxClients ; i++) 
				{
					new Float:Pos1[3];
					GetClientAbsOrigin(client, Pos1);
					if(i != client && IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == team)
					{
						new Float:Pos2[3];
						GetClientAbsOrigin(i, Pos2);
						new Float:distance = GetVectorDistance(Pos1, Pos2);
						if(distance < DispenserMinigunSpecial_Radius[client][slot])
						{
							for(new j = 0; j <= 3; j++)
							{
								new wep = GetPlayerWeaponSlot(i, j);
								if(wep == -1) continue;
								new ammotype = GetEntProp(wep, Prop_Data, "m_iPrimaryAmmoType");
								new ammo = DispenserMinigunAmmo_Ammo[client][slot];
								GivePlayerAmmo(i, ammo, ammotype, false);
								
								DispenserMinigunAmmo_Delay[client][slot] = GetEngineTime();
							}
						}
					}
				}
			}
			if(DispenserMinigunSpecial_Dur[client][slot] > 0.0 && GetEngineTime() >= DispenserMinigunAmmo_Delay[client][slot] + (DispenserMinigunAmmo_AmmoDelay[client][slot] * (1.0 - DispenserMinigunSpecial_Boost[client][slot])))
			{
				for(new i = 1 ; i <= MaxClients ; i++)
				{
					new Float:Pos1[3];
					GetClientAbsOrigin(client, Pos1);
					if(i != client && IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == team)
					{
						new Float:Pos2[3];
						GetClientAbsOrigin(i, Pos2);
						new Float:distance = GetVectorDistance(Pos1, Pos2);
						if(distance < DispenserMinigunSpecial_Radius[client][slot])
						{
							for(new j = 0; j <= 3; j++)
							{
								new wep = GetPlayerWeaponSlot(i, j);
								if(wep == -1) continue;
								new ammotype = GetEntProp(wep, Prop_Data, "m_iPrimaryAmmoType");
								new ammo = DispenserMinigunAmmo_Ammo[client][slot];
								GivePlayerAmmo(i, ammo, ammotype, false);
								
								DispenserMinigunAmmo_Delay[client][slot] = GetEngineTime();
							}
						}
					}
				}
			}
			if(DispenserMinigunSpecial_FuryDur[client][slot] > 0.0 && GetEngineTime() >= DispenserMinigunAmmo_Delay[client][slot] + (DispenserMinigunAmmo_AmmoDelay[client][slot] * (1.0 - (DispenserMinigunSpecial_Boost[client][slot] * 2.0))))
			{
				for(new i = 1 ; i <= MaxClients ; i++) 
				{
					new Float:Pos1[3];
					GetClientAbsOrigin(client, Pos1);
					if(IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == team)
					{
						new Float:Pos2[3];
						GetClientAbsOrigin(i, Pos2);
						new Float:distance = GetVectorDistance(Pos1, Pos2);
						if(distance < DispenserMinigunSpecial_Radius[client][slot] * 2.0)
						{
							for(new j = 0; j <= 3; j++)
							{
								new wep = GetPlayerWeaponSlot(i, j);
								if(wep == -1) continue;
								new ammotype = GetEntProp(wep, Prop_Data, "m_iPrimaryAmmoType");
								new ammo = DispenserMinigunAmmo_Ammo[client][slot];
								GivePlayerAmmo(i, ammo, ammotype, false);
								GivePlayerAmmo(client, ammo, ammotype, false);
								DispenserMinigunAmmo_Delay[client][slot] = GetEngineTime();
							}
						}
					}
				}
			}
		}
		if(buttons & IN_ATTACK3 == IN_ATTACK3 && DispenserMinigunSpecial_Charge[client][slot] >= DispenserMinigunSpecial_MaxChrg[client][slot])
		{
			DispenserMinigunSpecial_FuryDur[client][slot] = DispenserMinigunSpecial_MaxFuryDur[client][slot];
			EmitSoundToClient(client, "npc/scanner/cbot_discharge1.wav");
			EmitSoundToClient(client, "weapons/physcannon/physcannon_charge.wav");
			EmitSoundToClient(client, "npc/attack_helicopter/aheli_charge_up.wav");
			DispenserMinigunSpecial_Charge[client][slot] = 0.0;
		}
	}
	if(BrewAttrib[client][slot]) //7-6
	{
		if(TF2_IsPlayerInCondition(client, TFCond_Slowed) && GetEngineTime() >= BrewAttrib_Delay[client][slot] + BrewAttrib_MaxDelay[client][slot])
		{
			if(BrewAttrib_Stacks[client][slot] < BrewAttrib_MaxStacks[client][slot]) BrewAttrib_Stacks[client][slot]++;
			new Float:dmgresist = 1.0 - (BrewAttrib_DmgResist[client][slot] * BrewAttrib_Stacks[client][slot]);
			new Float:dmgbonus = 1.0 + (BrewAttrib_DmgBonus[client][slot] * BrewAttrib_Stacks[client][slot]);
			TF2Attrib_RemoveByName(weapon, "dmg taken increased");
			TF2Attrib_RemoveByName(weapon, "damage bonus");
			TF2Attrib_SetByName(weapon, "dmg taken increased", dmgresist);
			TF2Attrib_SetByName(weapon, "damage bonus", dmgbonus);
			BrewAttrib_Delay[client][slot] = GetEngineTime();
		}
		if(!TF2_IsPlayerInCondition(client, TFCond_Slowed))
		{
			BrewAttrib_Stacks[client][slot] = 0;
			TF2Attrib_RemoveByName(weapon, "dmg taken increased");
			TF2Attrib_RemoveByName(weapon, "damage bonus");
		}
	}
	if((buttons & IN_RELOAD) == IN_RELOAD) //7-7
	{
		if(BlitzkriegBuffs[weapon]) 
		{
			new patient = GetMediGunPatient(client);
			if(BlitzkriegBuffs_Buff[weapon] == 1 && GetEngineTime() >= BlitzkriegBuffs_Delay[weapon] + 0.2)
			{
				TF2Attrib_RemoveByName(weapon, "heal rate bonus");
				TF2Attrib_SetByName(weapon, "heal rate penalty", 0.75);
				if(patient > -1) patient = -1;
				BlitzkriegBuffs_Buff[weapon]++;
				EmitSoundToClient(client, "weapons/vaccinator_toggle.wav");
				BlitzkriegBuffs_Delay[weapon] = GetEngineTime();
			}
			else if(BlitzkriegBuffs_Buff[weapon] == 2 && GetEngineTime() >= BlitzkriegBuffs_Delay[weapon] + 0.2)
			{
				if(patient > -1) 
				{
					new patientpri = GetPlayerWeaponSlot(patient, 0);
					new patientsec = GetPlayerWeaponSlot(patient, 1);
					new patientmel = GetPlayerWeaponSlot(patient, 2);
					if(patientpri > -1)
					{
						TF2Attrib_RemoveByName(patientpri, "fire rate penalty HIDDEN");
						TF2Attrib_RemoveByName(patientpri, "faster reload rate");
					}
					if(patientsec > -1)
					{
						TF2Attrib_RemoveByName(patientsec, "fire rate penalty HIDDEN");
						TF2Attrib_RemoveByName(patientsec, "faster reload rate");
					}
					if(patientmel > -1)
						TF2Attrib_RemoveByName(patientmel, "fire rate penalty HIDDEN");
					patient = -1;
				}
				BlitzkriegBuffs_Buff[weapon]++;
				EmitSoundToClient(client, "weapons/vaccinator_toggle.wav");
				BlitzkriegBuffs_Delay[weapon] = GetEngineTime();
			}
			else if(BlitzkriegBuffs_Buff[weapon] == 3 && GetEngineTime() >= BlitzkriegBuffs_Delay[weapon] + 0.2)
			{
				TF2Attrib_RemoveByName(client, "move speed bonus");
				TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
				if(patient > -1) 
				{
					TF2Attrib_RemoveByName(patient, "move speed bonus");
					TF2_AddCondition(patient, TFCond_SpeedBuffAlly, 0.001);
					patient = -1;
				}
				BlitzkriegBuffs_Buff[weapon] = 1;
				EmitSoundToClient(client, "weapons/vaccinator_toggle.wav");
				BlitzkriegBuffs_Delay[weapon] = GetEngineTime();
			}
		}
	}
	
	new Action:action;
	return action;
}

//Event_Respawn & Event_Death start here
//*8
public Action:Event_Respawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!Client_IsValid(client)) return;
	CarryingBomb[client] = false;
	CarryingBomb_Blast[client] = 0.0;
	CarryingBomb_Min[client] = 0.0;
	CarryingBomb_Max[client] = 0.0;
	CarryingBomb_Dur[client] = 0.0;
	CarryingBomb_Time[client] = 0.0;
	CarryingBomb_ArmTime[client] = 0.0;
	CarryingBomb_Bomber[client] = -1;
	TF2Attrib_RemoveByName(client, "move speed penalty");
}

public Action:Event_Death(Handle:event, const String:name[], bool:dontBroadcast) //8-1
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new customkill = GetEventInt(event, "customkill");
	new inflictor = GetEventInt(event, "inflictor_entindex");
	new bool:feign = bool:(GetEventInt(event, "death_flags") & TF_DEATHFLAG_DEADRINGER);
	if (attacker && attacker != victim)
	{
		new sec = GetPlayerWeaponSlot(attacker, 1);
		new weapon = LastWeaponHurtWith[attacker];
		new mel = GetPlayerWeaponSlot(attacker, 2);
		new slot = GetClientSlot(attacker);
		if(slot > -1) 
		{
			if (m_bHasAttribute[attacker][slot])
			{
				if (FullClipOnKill[attacker][slot] && !feign) //8-2
				{
					EmitSoundToClient(attacker, "vehicles/crane/crane_magnet_release.wav");
					
					SetClip_Weapon(weapon, FullClipOnKill_Clip[attacker][slot] + 1);
				}
				if(AmmoOnKill[attacker][slot] && !feign) //8-3
				{
					EmitSoundToClient(attacker, "vehicles/crane/crane_magnet_release.wav");
					new restoreammo = FullClipOnKill_Ammo[attacker][slot] * FullClipOnKill_Amount[attacker][slot];
					SetAmmo_Weapon(weapon, GetAmmo_Weapon(weapon) + restoreammo);
				}
				if (ResistOnKill[attacker][slot] && !feign) //8-4
				{
					ResistOnKill_Dur[attacker][slot] = GetEngineTime();
				}
				if(MetalOnKill[attacker][slot]) //8-5
				{
					new String:class[50];
					if (!IsValidEdict(inflictor))return Plugin_Continue;
					GetEdictClassname(inflictor, class, sizeof(class));
					if (!StrContains(class, "obj_sentrygun"))return Plugin_Continue;
					
					TF2Attrib_RemoveByName(weapon, "maxammo metal increased");
					MetalOnKill_Kills[attacker][slot]++;
					if(MetalOnKill_Kills[attacker][slot] > MetalOnKill_MaxKills[attacker][slot]) MetalOnKill_Kills[attacker][slot] = MetalOnKill_MaxKills[attacker][slot];
					new Float:maxmetal = (MetalOnKill_Metal[attacker][slot] * MetalOnKill_Kills[attacker][slot] + 1.0);
					TF2Attrib_SetByName(weapon, "maxammo metal increased", maxmetal);
				}
				if(DispenserMinigunSpecial[attacker][slot] && DispenserMinigunSpecial_ChrgType[attacker][slot] > 0) //8-6
				{
					DispenserMinigunSpecial_Dur[attacker][slot] = DispenserMinigunSpecial_MaxDur[attacker][slot];
					EmitSoundToClient(attacker, "vehicles/crane/crane_magnet_release.wav");
					EmitSoundToClient(attacker, "npc/vort/health_charge.wav", 70);
					EmitSoundToClient(attacker, "npc/attack_helicopter/aheli_charge_up.wav");
				}
			}
		}
		if(customkill == 1 || customkill == TF_CUSTOM_HEADSHOT_DECAPITATION) //8-7
		{
			if(mel > -1 && StoreCritOnHeadshot[mel] && StoreCritOnHeadshot_Crits[mel] < StoreCritOnHeadshot_Max[mel])
			{
				StoreCritOnHeadshot_Crits[mel] += StoreCritOnHeadshot_AddCrits[mel];
			}
			else if(sec > -1 && StoreCritOnHeadshot[sec] && StoreCritOnHeadshot_Crits[sec] < StoreCritOnHeadshot_Max[sec])
			{
				StoreCritOnHeadshot_Crits[sec] += StoreCritOnHeadshot_AddCrits[sec];
			}
			if(m_bHasAttribute[attacker][slot] && HeavyDutyRifle[weapon])
			{
				if(HeavyDutyRifle_Stacks[weapon] < HeavyDutyRifle_MaxStacks[weapon]) 
					HeavyDutyRifle_Stacks[weapon]++;
				new Float:headshotdmg = 1.0 + (HeavyDutyRifle_Mult[weapon] * HeavyDutyRifle_Stacks[weapon]);
				TF2Attrib_SetByName(weapon, "headshot damage increase", headshotdmg);
				HeavyDutyRifle_Delay[weapon] = GetEngineTime();
			}
		}
		if(CarryingBomb[victim]) //8-8
		{
			new team = GetClientTeam(victim);
			for(new i = 1; i <= MaxClients; i++)
			{
				new Float:Pos1[3];
				GetClientAbsOrigin(victim, Pos1);
				
				if (Client_IsValid(i) && IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == team && i != victim)
				{
					new Float:Pos2[3];
					GetClientAbsOrigin(i, Pos2);
					new Float:distance = GetVectorDistance(Pos1, Pos2);
					if(distance <= CarryingBomb_Blast[victim])
					{
						new damage = RoundToFloor(CarryingBomb_DMG[victim]-distance);
						if(damage < CarryingBomb_Max[victim]*0.2) damage = RoundToFloor(CarryingBomb_Max[victim]*0.2);
						Entity_Hurt(i, damage, attacker, TF_CUSTOM_STANDARD_STICKY, "tf_weapon_pipebomblauncher");
						TF2_AddCondition(i, TFCond_Jarated, 8.0, CarryingBomb_Bomber[victim]);
					}
				}
			}
		}
	}
	if(LastHealPatient[victim] > 0) //8-9
	{
		new patient = LastHealPatient[victim];
		for (new j = 0; j <= 2; j++)
		{
			new patientwep = GetPlayerWeaponSlot(patient, j);
			if (patientwep == -1)continue;
			TF2Attrib_RemoveByName(patientwep, "halloween reload time decreased");
			TF2Attrib_RemoveByName(patientwep, "halloween fire rate bonus");
			TF2Attrib_RemoveByName(patient, "move speed bonus");
		}
	}
	return Plugin_Continue;
}

//Misc Triggers start here
//*9
public OnTouchHealthKit(const String:output[], caller, activator, Float:delay)
{
	if(IsValidClient(activator) && IsPlayerAlive(activator))
	{
		new mel = GetPlayerWeaponSlot(activator, 2);
		if(MoonshineAttrib[mel])
		{
			if(MoonshineAttrib_Stacks[mel] < MoonshineAttrib_MaxStacks[mel]) MoonshineAttrib_Stacks[mel]++;
		}
		if(CarryingBomb[activator])
		{
			CarryingBomb[activator] = false;
			CarryingBomb_Blast[activator] = 0.0;
			CarryingBomb_Min[activator] = 0.0;
			CarryingBomb_Max[activator] = 0.0;
			CarryingBomb_Dur[activator] = 0.0;
			CarryingBomb_Time[activator] = 0.0;
			CarryingBomb_ArmTime[activator] = 0.0;
			CarryingBomb_Bomber[activator] = -1;
		}
	}
}

public TF2_OnConditionAdded(client, TFCond:cond) //9-1
{
	if(cond == TFCond_Cloaked)
	{
		if(HasAttribute(client, _, LeapCloak))
		{
			if(GetEntPropFloat(client, Prop_Send, "m_flCloakMeter") >= GetAttributeValueF(client, _, LeapCloak, LeapCloak_Drain))
			{
				new Float:vel[3];
				GetEntPropVector(client, Prop_Data, "m_vecVelocity", vel);
				vel[0] *= GetAttributeValueF(client, _, LeapCloak, LeapCloak_LungeMult);
				vel[2] += GetAttributeValueF(client, _, LeapCloak, LeapCloak_LeapVel);
				vel[1] *= GetAttributeValueF(client, _, LeapCloak, LeapCloak_LungeMult);
				TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vel);
				SetEntPropFloat(client, Prop_Send, "m_flCloakMeter", GetEntPropFloat(client, Prop_Send, "m_flCloakMeter") - GetAttributeValueF(client, _, LeapCloak, LeapCloak_Drain));
				
				TF2_RemoveCondition(client, TFCond_Disguised);
				new cloak = GetSlotContainingAttribute(client, LeapCloak);
				if (cloak == -1)return;
				LeapCloak_Leaping[client][cloak] = GetEngineTime();
				TF2Attrib_SetByName(cloak, "cancel falling damage", 1.0);
			}
			TF2_RemoveCondition(client, TFCond_Cloaked);
		}
	}
}

//Prethinks start here
//*10
public OnClientPreThink(client)
{
	if(GetEngineTime() >= LastTick[client] + 0.1)
	{
		AttacksCarryBombsThink(client); //Tagged as *14
		AttributesThink(client); //Tagged as *11
		LastTick[client] = GetEngineTime();
	}
	if(TF2_GetPlayerClass(client) == TFClass_Medic)
	{
		UberchargeThink(client); //Tagged as *12
		MedigunHealThink(client); //Tagged as *13
	}
}

stock Action:UberchargeThink(client) //*12
{
	if(!IsValidClient(client)) return Plugin_Continue; //If the medic isn't valid what's the point in continuing?
	if (TF2_GetPlayerClass(client) != TFClass_Medic)return Plugin_Continue; //The player isn't a Medic, what's the point in continuing?
	new buttons = GetClientButtons(client); //For detecting what buttons the Medic is pressing. Used for the 'ubercharge is revive' attribute.
	new slot = GetClientSlot(client);
	new wep = GetPlayerWeaponSlot(client, 1);
	if(wep == -1) return Plugin_Continue;
	if(slot == -1 || slot > 3) return Plugin_Continue; //This is unnecessary, as if wep doesn't equal -1, then slot is likely not to as well. Whatever, just in case. ;3
	new sec = GetPlayerWeaponSlot(client, 1);
	if (sec == -1)return Plugin_Continue;
	new patient = GetMediGunPatient(client);
	/* -Yeah, just one of these blocks is gonna be super long because custom ubercharges
	take up a lot of space. This might end up being TTAS_Timer except instead of being
	a bunch of jumbled custom attributes it'll only be custom Ubercharge effects- */
	
	//8-1
	if(BoosterShotUber[wep]) //For the "ubercharge is booster shot" attribute
	{
		if(!GetEntProp(wep, Prop_Send, "m_bChargeRelease")) //If they are not ubercharged, execute this block
		{
			TF2Attrib_RemoveByName(wep, "overheal expert"); //Remove the boasting abilities from the Medigun
			TF2Attrib_SetByName(wep, "overheal penalty", BoosterShotUber_OldCap[wep]);
			TF2Attrib_SetByName(wep, "overheal decay bonus", BoosterShotUber_OldDecay[wep]);
			TF2Attrib_SetByName(wep, "overheal fill rate reduced", BoosterShotUber_OldBuild[wep]);
			TF2Attrib_ClearCache(wep);
			/* -This bit down here isn't necessary unless your
			ubercharge has an AOE effect involving tf2 attributes- */
			for(new i = 1; i <= MaxClients; i++)
			{
				new Float:Pos1[3];
				GetClientAbsOrigin(client, Pos1);
				
				new team = GetClientTeam(client);
				if (Client_IsValid(i) && IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == team && i != client)
				{
					new Float:Pos2[3];
					GetClientAbsOrigin(i, Pos2);
					new Float:distance = GetVectorDistance(Pos1, Pos2);
					if(distance <= 450.0)
					{
						TF2Attrib_RemoveByName(i, "health from healers increased");
					}
				}
			}
		}
		else //They are ubercharged, execute this block
		{
			TF2Attrib_RemoveByName(wep, "overheal penalty");
			TF2Attrib_SetByName(wep, "overheal expert", 4.0);
			TF2Attrib_SetByName(wep, "overheal decay bonus", 10.99);
			TF2Attrib_SetByName(wep, "overheal fill rate reduced", 2.0);
			TF2Attrib_ClearCache(wep);
			//Up there ^ is the boasting ability for this ubercharge
			//You can also make custom effects instead of using tf2 attributes
			for(new i = 1; i <= MaxClients; i++) //This bit isn't necessary unless your ubercharge has an AOE effect
			{
				new Float:Pos1[3];
				GetClientAbsOrigin(client, Pos1); //Gets the position of the Medic
				
				new team = GetClientTeam(client); //Gets the team of the Medic
				if (Client_IsValid(i) && IsPlayerAlive(i) && GetClientTeam(i) == team && i != client) //If i exists and is on the same team as the Medic
				{ //This block will be executed
					new Float:Pos2[3];
					GetClientAbsOrigin(i, Pos2); //Gets the position of i
					new Float:distance = GetVectorDistance(Pos1, Pos2); //Gets the distance between i and the Medic
					if(distance <= 450.0) //If they are in range of your AOE effect, it does this to them
					{
						TF2Attrib_RemoveByName(i, "health from healers increased");
						TF2Attrib_SetByName(i, "health from healers increased", 2.0);
					} else if(distance > 450.0) { //If they aren't, this happens to them
						
						TF2Attrib_RemoveByName(i, "health from healers increased");
					}
				}
			}
		}
	}
	//8-2
	if(ReviveUber[wep]) //This ubercharge is very interesting, but more complicated than above.
	{ //It executes under certain conditions or when the Medic right clicks with enough ubercharge
		new Float:uberlevel = GetEntPropFloat(wep, Prop_Send, "m_flChargeLevel"); //Get the Medic's ubercharge level
		//Interestingly enough ubercharge level is stored in values between 0 and 1. So 0.5 is 50%, 0.25 is 25%, etc.
		new medichealth = GetClientHealth(client); //Get the Medic's health
		new medicmaxhealth = GetEntProp(client, Prop_Data, "m_iMaxHealth"); //Get the Medic's maximum health
		if(patient > -1) //The patient exists. Execute this block
		{
			if(uberlevel >= 0.5) TF2_AddCondition(patient, TFCond:70, 0.1);
			new maxpatienthealth = GetEntProp(patient, Prop_Data, "m_iMaxHealth"); //Get the patient's maximum health
			new patienthealth = GetClientHealth(patient); //Get the patient's health
			//If the medic is using his ubercharge manually with a medigun patient or his patient is at critical condition
			//All of this underneath will be executed
			if(uberlevel >= ReviveUber_Uber[wep] && patienthealth <= RoundFloat(maxpatienthealth * ReviveUber_PatientHealth[wep]))
			{
				SetEntityHealth(patient, patienthealth + RoundFloat(maxpatienthealth * ReviveUber_PatientHealing[wep])); //Adds 50% of your patient's health to their current health
				if(medichealth < medicmaxhealth - RoundFloat(medicmaxhealth * ReviveUber_MedicHealing[wep]))
					SetEntityHealth(client, medichealth + RoundFloat(medicmaxhealth * ReviveUber_MedicHealing[wep]));
				else if(medichealth > medicmaxhealth - RoundFloat(medicmaxhealth * ReviveUber_MedicHealing[wep]) && medichealth < medicmaxhealth)
					SetEntityHealth(client, medicmaxhealth);
				//That little tid-bit ^ up there checks to see if the Medic's health is less than his maximum health
				//If so, it heals one sixth of the Medic's maximum health to the Medic.
				for (new i = 1; i < MaxClients; i++)
				{
					if(IsValidClient(i) && IsClientInGame(i) && IsPlayerAlive(i))
					{
						EmitSoundToClient(i, "mvm/mvm_revive.wav", client);
					}
				}
				EmitSoundToClient(client, "mvm/mvm_revive.wav"); //Plays the revive noise from MvM
				EmitSoundToClient(patient, "mvm/mvm_revive.wav");
				SetEntPropFloat(wep, Prop_Send, "m_flChargeLevel", uberlevel-ReviveUber_Uber[wep]); //Reduces the Medic's ubercharge level.
				ReviveUber_Delay[wep] = GetEngineTime();
			}
		}
		//The medic is manually deploying an ubercharge with no patient. All of this underneath will be executed.
		if(uberlevel >= ReviveUber_SelfUber[wep] && patient == -1 && (buttons & IN_ATTACK2) == IN_ATTACK2 && GetEngineTime() >= ReviveUber_Delay[wep] + 0.5 && medichealth < medicmaxhealth)
		{
			if(medichealth < medicmaxhealth - RoundFloat(medicmaxhealth * ReviveUber_SelfHealing[wep])) 
				SetEntityHealth(client, medichealth + RoundFloat(medicmaxhealth * ReviveUber_SelfHealing[wep]));
			if(medichealth >= medicmaxhealth - RoundFloat(medicmaxhealth * ReviveUber_SelfHealing[wep]) && medichealth < medicmaxhealth)
				SetEntityHealth(client, medicmaxhealth);
			EmitSoundToClient(client, "mvm/mvm_revive.wav");
			SetEntPropFloat(wep, Prop_Send, "m_flChargeLevel", uberlevel-ReviveUber_SelfUber[wep]);
			TF2_AddCondition(client, TFCond:70, 5.0);
			ReviveUber_Delay[wep] = GetEngineTime();
		}
		if(GetEntPropFloat(wep, Prop_Send, "m_flChargeLevel") >= 0.99) SetEntPropFloat(wep, Prop_Send, "m_flChargeLevel", 0.99);
		//That ^ keeps the medigun from reaching 100% ubercharge. Does it fairly well. It slips up during set up time, though.
	}
	//8-3
	if(BlitzkriegBuffs[sec])
	{
		if(GetEntProp(wep, Prop_Send, "m_bChargeRelease"))
		{
			BlitzkriegBuffs_Delay[sec] = GetEngineTime();
			TF2Attrib_RemoveByName(sec, "heal rate penalty");
			TF2Attrib_SetByName(sec, "heal rate bonus", 1.0+KralleBuffs_UberHealSpd[sec]);
			TF2Attrib_SetByName(sec, "move speed bonus", 1.0+KralleBuffs_UberMoveSpd[sec]);
			TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
			TF2_AddCondition(client, TFCond:20, 0.2);
			if(patient > -1) 
			{
				new patientpri = GetPlayerWeaponSlot(patient, 0);
				new patientsec = GetPlayerWeaponSlot(patient, 1);
				new patientmel = GetPlayerWeaponSlot(patient, 2);
				if(patientpri > -1)
				{
					TF2Attrib_SetByName(patientpri, "halloween fire rate bonus", 1.0-KralleBuffs_UberFireSpd[sec]);
					TF2Attrib_SetByName(patientpri, "halloween reload time decreased", 1.0-KralleBuffs_UberReloadSpd[sec]);
				}
				if(patientsec > -1)
				{
					TF2Attrib_SetByName(patientsec, "halloween fire rate bonus", 1.0-KralleBuffs_UberFireSpd[sec]);
					TF2Attrib_SetByName(patientsec, "halloween reload time decreased", 1.0-KralleBuffs_UberReloadSpd[sec]);
				}
				if(patientmel > -1)
					TF2Attrib_SetByName(patientmel, "halloween fire rate bonus", 1.0-KralleBuffs_UberFireSpd[sec]);
					
				TF2Attrib_SetByName(patient, "move speed penalty", 1.0+KralleBuffs_UberMoveSpd[sec]);
				TF2_AddCondition(patient, TFCond_SpeedBuffAlly, 0.001);
				TF2_AddCondition(patient, TFCond:20, 0.2);
				KralleBuffs_Delay[patient] = GetEngineTime();
			}
		}
	}
	//8-4
	if(HasAttribute(client, 1, RadiusUber) && GetEntProp(sec, Prop_Send, "m_bChargeRelease")) //If the client's secondary has the RadiusUber attribute on it AND charge is released
	{ //Execute this block
		if(GetAttributeValueI(client, 1, RadiusUber, RadiusUber_Mode) == 0) //If the mode is set to 0
		{ //Execute this block
			//Here I'm using a stock I made to apply the conditions to players around the Medic. As of recent I do this to reduce the size of the code.
			//See the bottom of the code to see how this works
			ApplyRadiusEffects(client, _, _, GetAttributeValueF(client, 1, RadiusUber, RadiusUber_Radius), GetAttributeValueI(client, 1, RadiusUber, RadiusUber_Cond1), GetAttributeValueI(client, 1, RadiusUber, RadiusUber_Cond2), 0.2, 0.2, 1, false);
			if(patient > -1)
			{
				TF2_AddCondition(patient, TFCond:GetAttributeValueI(client, 1, RadiusUber, RadiusUber_Cond1), 0.2, client);
				TF2_AddCondition(patient, TFCond:GetAttributeValueI(client, 1, RadiusUber, RadiusUber_Cond2), 0.2, client);
				TF2_AddCondition(patient, TFCond:GetAttributeValueI(client, 1, RadiusUber, RadiusUber_ExclusiveCond), 0.2, client);
				TF2_AddCondition(patient, TFCond:GetAttributeValueI(client, 1, RadiusUber, RadiusUber_ExclusiveCond2), 0.2, client);
				TF2_AddCondition(patient, TFCond:GetAttributeValueI(client, 1, RadiusUber, RadiusUber_ExclusiveCond3), 0.2, client);
			}
			TF2_AddCondition(client, TFCond:GetAttributeValueI(client, 1, RadiusUber, RadiusUber_ExclusiveCond), 0.2, client);
			TF2_AddCondition(client, TFCond:GetAttributeValueI(client, 1, RadiusUber, RadiusUber_ExclusiveCond2), 0.2, client);
			TF2_AddCondition(client, TFCond:GetAttributeValueI(client, 1, RadiusUber, RadiusUber_ExclusiveCond3), 0.2, client);
		}
		else if(GetAttributeValueI(client, 1, RadiusUber, RadiusUber_Mode) == 1 && RadiusUber[client][slot]) //If the mode is set to 1 and the medigun is active
		{ //Execute this block
			ApplyRadiusEffects(client, _, _, GetAttributeValueF(client, 1, RadiusUber, RadiusUber_Radius), GetAttributeValueI(client, 1, RadiusUber, RadiusUber_Cond1), GetAttributeValueI(client, 1, RadiusUber, RadiusUber_Cond2), 0.2, 0.2, 1, false);
			if(patient > -1)
			{
				TF2_AddCondition(patient, TFCond:GetAttributeValueI(client, 1, RadiusUber, RadiusUber_Cond1), 0.2, client);
				TF2_AddCondition(patient, TFCond:GetAttributeValueI(client, 1, RadiusUber, RadiusUber_Cond2), 0.2, client);
				TF2_AddCondition(patient, TFCond:GetAttributeValueI(client, 1, RadiusUber, RadiusUber_ExclusiveCond), 0.2, client);
				TF2_AddCondition(patient, TFCond:GetAttributeValueI(client, 1, RadiusUber, RadiusUber_ExclusiveCond2), 0.2, client);
				TF2_AddCondition(patient, TFCond:GetAttributeValueI(client, 1, RadiusUber, RadiusUber_ExclusiveCond3), 0.2, client);
			}
			TF2_AddCondition(client, TFCond:GetAttributeValueI(client, 1, RadiusUber, RadiusUber_ExclusiveCond), 0.2, client);
			TF2_AddCondition(client, TFCond:GetAttributeValueI(client, 1, RadiusUber, RadiusUber_ExclusiveCond2), 0.2, client);
			TF2_AddCondition(client, TFCond:GetAttributeValueI(client, 1, RadiusUber, RadiusUber_ExclusiveCond3), 0.2, client);
		}
	}
	return Plugin_Continue;
}

stock Action:MedigunHealThink(client) //*13
{
	if(!IsValidClient(client)) return Plugin_Continue;
	new slot = GetClientSlot(client);
	new wep = GetPlayerWeaponSlot(client, 1);
	if(wep == -1) return Plugin_Continue;
	if(slot == -1) return Plugin_Continue; //This is unnecessary, as if wep doesn't equal -1, then slot is likely not to as well. Whatever, just in case. ;3
	new pri = GetPlayerWeaponSlot(client, 0);
	new sec = GetPlayerWeaponSlot(client, 1);
	if (sec == -1)return Plugin_Continue;
	new patient = GetMediGunPatient(client);
	//13-1
	if(BlitzkriegBuffs[sec] && !GetEntProp(sec, Prop_Send, "m_bChargeRelease"))
	{
		if(BlitzkriegBuffs_Buff[sec] == 1)
		{
			TF2Attrib_RemoveByName(sec, "move speed bonus");
			TF2Attrib_RemoveByName(sec, "heal rate penalty");
			TF2Attrib_SetByName(sec, "heal rate bonus", 1.0+KralleBuffs_PassHealSpd[sec]);
			if(patient > -1)
			{
				new patientpri = GetPlayerWeaponSlot(patient, 0);
				new patientsec = GetPlayerWeaponSlot(patient, 1);
				new patientmel = GetPlayerWeaponSlot(patient, 2);
				if(patientpri > -1)
				{
					TF2Attrib_RemoveByName(patientpri, "halloween fire rate bonus");
					TF2Attrib_RemoveByName(patientpri, "halloween reload time decreased");
				}
				if(patientsec > -1)
				{
					TF2Attrib_RemoveByName(patientsec, "halloween fire rate bonus");
					TF2Attrib_RemoveByName(patientsec, "halloween reload time decreased");
				}
				if(patientmel > -1)
					TF2Attrib_RemoveByName(patientmel, "halloween fire rate bonus");
				
				patient = -1;
			}
			
			SetHudTextParams(-1.0, 0.7, 0.2, 255,255,255,255);
			ShowSyncHudText(client, hudText_SecWeapon, "Buff Type: Heal Buff");
		}
		else if(BlitzkriegBuffs_Buff[sec] == 2)
		{
			TF2Attrib_RemoveByName(sec, "move speed bonus");
			TF2Attrib_RemoveByName(wep, "heal rate bonus");
			TF2Attrib_SetByName(wep, "heal rate penalty", KralleBuffs_OldHealSpd[wep]);
			if(patient > -1)
			{
				new patientpri = GetPlayerWeaponSlot(patient, 0);
				new patientsec = GetPlayerWeaponSlot(patient, 1);
				new patientmel = GetPlayerWeaponSlot(patient, 2);
				if(patientpri > -1)
				{
					TF2Attrib_SetByName(patientpri, "halloween fire rate bonus", 1.0-KralleBuffs_PassFireSpd[sec]);
					TF2Attrib_SetByName(patientpri, "halloween reload time decreased", 1.0-KralleBuffs_PassReloadSpd[sec]);
				}
				if(patientsec > -1)
				{
					TF2Attrib_SetByName(patientsec, "halloween fire rate bonus", 1.0-KralleBuffs_PassFireSpd[sec]);
					TF2Attrib_SetByName(patientsec, "halloween reload time decreased", 1.0-KralleBuffs_PassReloadSpd[sec]);
				}
				if(patientmel > -1)
					TF2Attrib_SetByName(patientmel, "halloween fire rate bonus", 1.0-KralleBuffs_PassFireSpd[sec]);
			}
			patient = -1;
			
			SetHudTextParams(-1.0, 0.7, 0.2, 255,255,255,255);
			ShowSyncHudText(client, hudText_SecWeapon, "Buff Type: Fire-Reload Buff");
		}
		else if(BlitzkriegBuffs_Buff[sec] == 3)
		{
			TF2Attrib_RemoveByName(wep, "heal rate bonus");
			TF2Attrib_SetByName(wep, "heal rate penalty", KralleBuffs_OldHealSpd[sec]);
			if(patient > -1) 
			{
				TF2Attrib_SetByName(patient, "move speed penalty", 1.0+KralleBuffs_PassMoveSpd[sec]);
				TF2_AddCondition(patient, TFCond_SpeedBuffAlly, 0.001);
				TF2Attrib_SetByName(sec, "move speed bonus", 1.0+KralleBuffs_PassMoveSpd[sec]);
				TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
				new patientpri = GetPlayerWeaponSlot(patient, 0);
				new patientsec = GetPlayerWeaponSlot(patient, 1);
				new patientmel = GetPlayerWeaponSlot(patient, 2);
				if(patientpri > -1)
				{
					TF2Attrib_RemoveByName(patientpri, "halloween fire rate bonus");
					TF2Attrib_RemoveByName(patientpri, "faster reload rate");
				}
				if(patientsec > -1)
				{
					TF2Attrib_RemoveByName(patientsec, "halloween fire rate bonus");
					TF2Attrib_RemoveByName(patientsec, "halloween reload time decreased");
				}
				if(patientmel > -1)
					TF2Attrib_RemoveByName(patientmel, "halloween fire rate bonus");
			}
			patient = -1;
			
			SetHudTextParams(-1.0, 0.7, 0.2, 255,255,255,255);
			ShowSyncHudText(client, hudText_SecWeapon, "Buff Type: Movement Buff");
		}
		if(patient > -1)
		{
			KralleBuffs_Delay[patient] = GetEngineTime();
		}
	}
	//13-2
	if(HasAttribute(client, 1, RadiusHealing)) //If the client's medigun carries the RadiusHealing attribute
	{ 
		if(!GetEntProp(sec, Prop_Send, "m_bChargeRelease")) //If the client's medigun charge is not released (aka they aren't ubercharged)
		{ 
			if(GetAttributeValueI(client, 1, RadiusHealing, RadiusHealing_Mode) == 0) //If the mode is set to 0
			{
				//Here I'm using a stock I made which you can find at the bottom of the code.
				//It basically heals everybody around the designated client. Values can be plugged in for the radius and how much health per second.
				//However, the healing does seem to be slightly off by a few points according to thurough testing from Crafting.
				DealRadiusDamage(client, _, patient, GetAttributeValueF(client, 1, RadiusHealing, RadiusHealing_UberedRadius), _, GetAttributeValueF(client, 1, RadiusHealing, RadiusHealing_UberedHealing) * -1, 0, 1, false);
			}
			else if(GetAttributeValueI(client, 1, RadiusHealing, RadiusHealing_Mode) == 1 && RadiusHealing[client][slot]) //If the mode is set to 1 and the medigun is out
			{
				DealRadiusDamage(client, _, patient, GetAttributeValueF(client, 1, RadiusHealing, RadiusHealing_UberedRadius), _, GetAttributeValueF(client, 1, RadiusHealing, RadiusHealing_UberedHealing) * -1, 0, 1, false);
			}
			else if(GetAttributeValueI(client, 1, RadiusHealing, RadiusHealing_Mode) == 2 && patient > -1) //If the mode is set to 2 and the client has a patient
			{
				DealRadiusDamage(client, _, patient, GetAttributeValueF(client, 1, RadiusHealing, RadiusHealing_UberedRadius), _, GetAttributeValueF(client, 1, RadiusHealing, RadiusHealing_UberedHealing) * -1, 0, 1, false);
			}
		}
		else if(GetEntProp(sec, Prop_Send, "m_bChargeRelease")) //If the client's medigun charge is released (aka they are ubercharged)
		{
			if(GetAttributeValueI(client, 1, RadiusHealing, RadiusHealing_Mode2) == 0) //If the secondary mode is set to 0
			{
				DealRadiusDamage(client, _, patient, GetAttributeValueF(client, 1, RadiusHealing, RadiusHealing_UberedRadius), _, GetAttributeValueF(client, 1, RadiusHealing, RadiusHealing_UberedHealing) * -1, 0, 1, false);
			}
			else if(GetAttributeValueI(client, 1, RadiusHealing, RadiusHealing_Mode2) == 1 && RadiusHealing[client][slot]) //If the secondary mode is set to 1 and they have the medigun out
			{
				DealRadiusDamage(client, _, patient, GetAttributeValueF(client, 1, RadiusHealing, RadiusHealing_UberedRadius), _, GetAttributeValueF(client, 1, RadiusHealing, RadiusHealing_UberedHealing) * -1, 0, 1, false);
			}
			else if(GetAttributeValueI(client, 1, RadiusHealing, RadiusHealing_Mode2) == 2 && patient > -1) //If the secondary mode is set to 2 and the client has a patient
			{
				DealRadiusDamage(client, _, patient, GetAttributeValueF(client, 1, RadiusHealing, RadiusHealing_UberedRadius), _, GetAttributeValueF(client, 1, RadiusHealing, RadiusHealing_UberedHealing) * -1, 0, 1, false);
			}
		}
	}
	
	if(patient > -1 && CarryingBomb[patient]) //If the client's patient is carrying a bomb
	{
		CarryingBomb_Dur[patient] -= 0.2; //Reduces the amount of time the bomb lives for.
	}
	
	/*if(patient > -1 && HasAttribute(client, _, HealRateKill) && GetAttributeValueI(client, _, HealRateKill, HealRateKill_Stacks) > 0)
	{
		new health, removehealth, Float:delay, attrib[16], Float:value[16], index, patientWep, Float:overheal, list[16], Float:removedelay;
		delay = 0.041666;
		removedelay = 0.041666;
		overheal = 1.5;
		health = 1;
		removehealth = 1;
		//Thanks for the help here, Porygon!
		index = GetEntProp(wep, Prop_Send, "m_iItemDefinitionIndex");
		if (TF2Attrib_ListDefIndices(patientWep, list) > 0)
		{
			PrintToChat(client, "Medic is wielding a normal TF2 gun");
			TF2Attrib_GetStaticAttribs(index, attrib, value);
			for (new x = 0; x < sizeof(attrib); x++)
			{
				if(attrib[x] == 8 || attrib[x] == 7)
				{
					delay *= 2.0 - value[x];
				}
				if(attrib[x] == 11 || attrib[x] == 12)
				{
					overheal = (1.0 - overheal) * value[x] + 1.0;
				}
				if(attrib[x] == 482)
				{
					overheal = overheal + (0.25 * value[x]);
				}
			}
		}
		else
		{
			if (TF2Attrib_GetByName(wep, "heal rate bonus"))
			{
				delay *= 2.0 - TF2Attrib_GetValue(TF2Attrib_GetByName(wep, "heal rate bonus"));
				removedelay *= 2.0 - TF2Attrib_GetValue(TF2Attrib_GetByName(wep, "heal rate bonus"));
		 	}
		 	if (TF2Attrib_GetByName(wep, "heal rate penalty"))
			{
				delay *= 2.0 - TF2Attrib_GetValue(TF2Attrib_GetByName(wep, "heal rate penalty"));
				removedelay *= 2.0 - TF2Attrib_GetValue(TF2Attrib_GetByName(wep, "heal rate penalty"));
		 	}
		}
		
		for (new i = 0; i < 3; i++)
		{
			patientWep = GetPlayerWeaponSlot(patient, i);
			if (patientWep < 0)continue;
			index = GetEntProp(patientWep, Prop_Send, "m_iItemDefinitionIndex");
			TF2Attrib_GetStaticAttribs(index, attrib, value);
			if (TF2Attrib_ListDefIndices(patientWep, list) > 0)
			{
				for (new x = 0; x < sizeof(attrib); x++)
				{
					new bool:hasOnActive;
					if (attrib[0] == 128)hasOnActive = true;
					if(!hasOnActive)
					{
						if(attrib[x] == 69 || attrib[x] == 70 || attrib[x] == 740 || attrib[x] == 526)
						{
							delay *= 2.0 - value[x];
						}
					}
					else if(hasOnActive && patientWep == Client_GetActiveWeapon(patient))
					{
						if(attrib[x] == 69 || attrib[x] == 70 || attrib[x] == 740 || attrib[x] == 526)
						{
							delay *= 2.0 - value[x];
						}
					}
				}
			}
			else
			{
				PrintToChat(client, "Patient is wielding a custom weapon");
				if (TF2Attrib_GetByName(patientWep, "healing received bonus"))
				{
					delay *= 0.0 + TF2Attrib_GetValue(TF2Attrib_GetByName(patientWep, "healing received bonus"));
			 	}
				
				if (TF2Attrib_GetByName(patientWep, "health from healers increased"))
				{
					delay *= 0.0 + TF2Attrib_GetValue(TF2Attrib_GetByName(patientWep, "health from healers increased"));
			 	}
				
				if (TF2Attrib_GetByName(patientWep, "healing received penalty"))
				{
					delay *= 0.0 + TF2Attrib_GetValue(TF2Attrib_GetByName(patientWep, "healing received penalty"));
			 	}
				
				if (TF2Attrib_GetByName(patientWep, "health from healers reduced"))
				{
					PrintToChat(client, "Health from healers reduced FOUND!");
					delay *= 0.0 + TF2Attrib_GetValue(TF2Attrib_GetByName(patientWep, "health from healers reduced"));
			 	}
				
				if (TF2Attrib_GetByName(patientWep, "reduced_healing_from_medics"))
				{
					PrintToChat(client, "Reduced healing from medics FOUND!");
					delay *= 0.0 + TF2Attrib_GetValue(TF2Attrib_GetByName(patientWep, "reduced_healing_from_medics"));
			 	}
			}
		}
		
		if(GetEngineTime() <= CombatTime[patient] + 12.5 && GetEngineTime() >= CombatTime[patient] + 15.0)
		{
			health = 2;
			removedelay *= 0.151515;
		}
		else if(GetEngineTime() >= CombatTime[patient] + 15.0)
		{
			health = 3;
			removedelay *= 0.33333;
		}
		if(TF2_IsPlayerInCondition(patient, TFCond:118))
		{
			delay *= 1.75;
		}
		
		if(GetAttributeValueF(client, _, HealRateKill, HealRateKill_Stacks) > 0)
			delay *= GetAttributeValueI(client, _, HealRateKill, HealRateKill_Stacks) * GetAttributeValueF(client, _, HealRateKill, HealRateKill_Bonus);
		
		if(GetEngineTime() >= HealRateKill_HealDelay[patient] + delay)
		{
			HealPlayer(client, patient, health, overheal);
			HealRateKill_HealDelay[patient] = GetEngineTime();
		}
		//if(GetEngineTime() >= HealRateKill_Remove[patient] + removedelay && GetClientHealth(patient) > removehealth)
			//SetEntityHealth(patient, GetClientHealth(patient) - removehealth);
	}
	*/
	return Plugin_Continue;
}

stock Action:AttacksCarryBombsThink(client) //*14
{
	if(!Client_IsValid(client)) return Plugin_Continue;
	if(!IsValidClient(client)) return Plugin_Continue;
	if(!IsPlayerAlive(client)) return Plugin_Continue;
	new wep = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if(wep == -1) return Plugin_Continue;
	if(CarryingBomb[client])
	{
		SetHudTextParams(0.8, 0.6, 0.2, 255, 128, 128, 255);
		ShowSyncHudText(client, hudText_Wearer, "You have a jarate bomb on you!");
		if(CarryingBomb_DMG[client] < CarryingBomb_Max[client] && GetEngineTime() >= CarryingBomb_Time[client] + CarryingBomb_ArmTime[client])
			CarryingBomb_DMG[client] += 0.5;
	}
	if(AttacksCarryBombs[wep])
	{
		for(new i = 1; i <= MaxClients; i++)
		{
			if(Client_IsValid(i) && IsValidClient(i) && IsPlayerAlive(i) && CarryingBomb[i] && GetEngineTime() >= CarryingBomb_Time[i] + CarryingBomb_ArmTime[i] && GetEngineTime() >= CarryingBomb_Dur[i] + AttacksCarryBombs_MaxDur[wep] && CarryingBomb_Bomber[i] == client)
			{
				EmitSoundToClient(client, "weapons/stickybomblauncher_det.wav");
				EmitSoundToClient(i, "weapons/stickybomblauncher_det.wav");
				Entity_Hurt(i, RoundToFloor(CarryingBomb_DMG[i]), client, TF_CUSTOM_STANDARD_STICKY, "tf_weapon_pipebomblauncher");
				TF2_AddCondition(i, TFCond_Jarated, 8.0, client);
				for(new j = 1; j <= MaxClients; j++)
				{
					new Float:Pos1[3];
					GetClientAbsOrigin(i, Pos1);
					
					new team = GetClientTeam(i);
					if (Client_IsValid(j) && IsValidClient(j) && IsPlayerAlive(j) && GetClientTeam(j) == team && j != i)
					{
						new Float:Pos2[3];
						GetClientAbsOrigin(j, Pos2);
						new Float:distance = GetVectorDistance(Pos1, Pos2);
						if(distance <= AttacksCarryBombs_Blast[wep])
						{
							Entity_Hurt(j, CarryingBomb_Max[i], client, TF_CUSTOM_STANDARD_STICKY, "tf_weapon_pipebomblauncher");
							TF2_AddCondition(j, TFCond_Jarated, 8.0, client);
						}
					}
				}
				CarryingBomb[i] = false;
				AttacksCarryBombs_Bombs[wep] = 0;
			}
		}
	}
	return Plugin_Continue;
}

stock Action:AttributesThink(client) //*11
{
	if(client > 0 && client <= MaxClients && IsClientInGame(client) && IsPlayerAlive(client))
	{
		new slot = GetClientSlot(client);
		if(slot == -1 || slot > 3) return Plugin_Continue;
		new primary = GetPlayerWeaponSlot(client, 0);
		new secondary = GetPlayerWeaponSlot(client, 1);
		new melee = GetPlayerWeaponSlot(client, 2);
		new pri = GetWeaponSlot(client, 0);
		new sec = GetWeaponSlot(client, 1);
		new mel = GetWeaponSlot(client, 2);
		new wep = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if (wep < 0)return Plugin_Continue;
		
		//11-1
		if (GetEngineTime() <= GetAttributeValueF(client, _, ResistOnKill, ResistOnKill_Dur) + GetAttributeValueF(client, _, ResistOnKill, ResistOnKill_MaxDur)) 
		{
			TF2Attrib_SetByName(client, "dmg taken from bullets increased", GetAttributeValueF(client, _, ResistOnKill, ResistOnKill_Bullet, 1.0));
			TF2Attrib_SetByName(client, "dmg taken from blast increased", GetAttributeValueF(client, _, ResistOnKill, ResistOnKill_Blast, 1.0));
			TF2Attrib_SetByName(client, "dmg taken from fire increased", GetAttributeValueF(client, _, ResistOnKill, ResistOnKill_Fire, 1.0));
			TF2Attrib_SetByName(client, "SET BONUS: dmg from sentry reduced", GetAttributeValueF(client, _, ResistOnKill, ResistOnKill_Sentry, 1.0));
			TF2Attrib_SetByName(client, "damage force reduction", GetAttributeValueF(client, _, ResistOnKill, ResistOnKill_Knockback, 1.0));
			TF2Attrib_SetByName(client, "airblast vulnerability multiplier", GetAttributeValueF(client, _, ResistOnKill, ResistOnKill_Knockback, 1.0));
			if(GetAttributeValueF(client, _, ResistOnKill, ResistOnKill_Bullet, 1.0) < 1) TF2_AddCondition(client, TFCond:61, 0.11);
			if(GetAttributeValueF(client, _, ResistOnKill, ResistOnKill_Blast, 1.0) < 1) TF2_AddCondition(client, TFCond:62, 0.11);
			if(GetAttributeValueF(client, _, ResistOnKill, ResistOnKill_Fire, 1.0) < 1) TF2_AddCondition(client, TFCond:63, 0.11);
		}
		else if(GetEngineTime() >= GetAttributeValueF(client, _, ResistOnKill, ResistOnKill_Dur) + GetAttributeValueF(client, _, ResistOnKill, ResistOnKill_MaxDur) && GetEngineTime() <= GetAttributeValueF(client, _, ResistOnKill, ResistOnKill_Dur) + GetAttributeValueF(client, _, ResistOnKill, ResistOnKill_MaxDur) + 1.0) 
		{
			TF2Attrib_RemoveByName(client, "dmg taken from bullets increased");
			TF2Attrib_RemoveByName(client, "dmg taken from blast increased");
			TF2Attrib_RemoveByName(client, "dmg taken from fire increased");
			TF2Attrib_RemoveByName(client, "SET BONUS: dmg from sentry reduced");
			TF2Attrib_RemoveByName(client, "damage force reduction");
			TF2Attrib_RemoveByName(client, "airblast vulnerability multiplier");
		}
		
		//11-2
		if(melee > -1 && MoonshineAttrib[melee])
		{
			new maxhealth = GetClientMaxHealth(client);
			new health = GetClientHealth(client);
			new healthrestore = (maxhealth / MoonshineAttrib_MaxStacks[melee]);
			new Float:swingspeed = (MoonshineAttrib_SwingBonus[melee] * MoonshineAttrib_Stacks[melee] + 1.0);
			new Float:dmgbonus = (MoonshineAttrib_DMGBonus[melee] * MoonshineAttrib_Stacks[melee] + 1.0);
			TF2Attrib_RemoveByName(melee, "damage bonus");
			TF2Attrib_RemoveByName(melee, "fire rate penalty");
			TF2Attrib_SetByName(melee, "damage bonus", dmgbonus);
			TF2Attrib_SetByName(melee, "fire rate penalty", swingspeed);
			if(MoonshineAttrib_Wait[melee] > 0.0) MoonshineAttrib_Wait[melee] -= 0.1;
			if(MoonshineAttrib[wep] && TF2_IsPlayerInCondition(client, TFCond_Taunting) && MoonshineAttrib_Stacks[melee] > 0 && MoonshineAttrib_Wait[melee] <= 0.0 && health < RoundToFloor(maxhealth * MoonshineAttrib_OverhealCap[melee]))
			{
				if(health < RoundToFloor(maxhealth * MoonshineAttrib_OverhealCap[melee]) - healthrestore)
					SetEntityHealth(client, health+healthrestore);
				else
					SetEntityHealth(client, RoundToFloor(maxhealth * MoonshineAttrib_OverhealCap[melee]));
				MoonshineAttrib_Stacks[melee] -= 1;
				MoonshineAttrib_Dur[melee] = 0.6;
				TF2Attrib_SetByName(client, "dmg taken increased", MoonshineAttrib_DMGResist[melee]);
				MoonshineAttrib_Wait[melee] = 0.5;
			}
			if(MoonshineAttrib_Dur[melee] > 0.0) MoonshineAttrib_Dur[melee] -= 0.1;
			if(MoonshineAttrib_Dur[melee] <= 0.0) TF2Attrib_RemoveByName(client, "dmg taken increased");
			SetHudTextParams(0.8, 0.7, 0.2, 255, 255, 255, 255);
			ShowSyncHudText(client, hudText_Wearer, "Wine: %i/%i glasses", MoonshineAttrib_Stacks[melee], MoonshineAttrib_MaxStacks[melee]);
		}
		
		//11-3
		if(HammerMechanic[client][slot] && HammerMechanic_Wait[client][slot] > 0.0) HammerMechanic_Wait[client][slot] -= 0.1;
		
		//11-4
		if(HasAttribute(client, _, HealRateKill))
		{
			new weapon = GetSlotContainingAttribute(client, HealRateKill);
			new patient = GetMediGunPatient(client);
			new medigun = GetPlayerWeaponSlot(client, 1);
			if(patient > -1 && patient <= MaxClients && IsPlayerAlive(patient) && GetClientHealth(patient) <= GetEntProp(patient, Prop_Data, "m_iMaxHealth") && GetEngineTime() >= HealRateKill_WaitTime[client][weapon] + HealRateKill_Wait[client][weapon] )
			{
				HealRateKill_Stacks[client][weapon] -= HealRateKill_Subtract[client][weapon];
				HealRateKill_Blood[client][weapon] -= HealRateKill_Subtract[client][weapon];
				HealRateKill_WaitTime[client][weapon] = GetEngineTime();
			}
			TF2Attrib_RemoveByName(medigun, "heal rate penalty");
			TF2Attrib_SetByName(medigun, "heal rate penalty", HealRateKill_Stacks[client][weapon] * HealRateKill_Bonus[client][weapon] + 1.0);
			if(HealRateKill_Stacks[client][weapon] < 0) HealRateKill_Stacks[client][weapon] = 0;
			if(HealRateKill_Blood[client][weapon] < 0) HealRateKill_Blood[client][weapon] = 0;
			
			SetHudTextParams(-0.8, 0.6, 0.2, 255, 255, 255, 255);
			ShowSyncHudText(client, hudText_Wearer, "Bonus Heal Rate: %i%%", RoundToFloor((HealRateKill_Stacks[client][weapon] * HealRateKill_Bonus[client][weapon]) * 100));
		}
		
		//11-5
		if(GetEngineTime() >= KralleBuffs_Delay[client] + 0.5 && GetEngineTime() <= KralleBuffs_Delay[client] + 1.0)
		{
			if(primary > -1)
			{
				TF2Attrib_RemoveByName(primary, "halloween fire rate bonus");
				TF2Attrib_RemoveByName(primary, "halloween reload rate bonus");
			}
			if(secondary > -1)
			{
				TF2Attrib_RemoveByName(secondary, "halloween fire rate bonus");
				TF2Attrib_RemoveByName(secondary, "halloween reload rate bonus");
			}
			if(melee > -1)
			{
				TF2Attrib_RemoveByName(melee, "halloween fire rate bonus");
			}
			TF2Attrib_RemoveByName(client, "move speed penalty");
			TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
		}
		if(melee > -1 && KnifeGunSpy[melee])
		{
			TF2Attrib_SetByName(melee, "fire rate bonus", 1.0 - (KnifeGunSpy_FireRate[melee] * KnifeGunSpy_Stacks[melee]));
			TF2Attrib_SetByName(melee, "move speed bonus", 1.0 - (KnifeGunSpy_MoveSpeed[melee] * KnifeGunSpy_Stacks[melee]));
			TF2Attrib_SetByName(melee, "mult cloak rate", 1.0 - (KnifeGunSpy_CloakSpeed[melee] * KnifeGunSpy_Stacks[melee]));
			TF2Attrib_SetByName(melee, "mult decloak rate", 2.0 - (KnifeGunSpy_CloakSpeed[melee] * KnifeGunSpy_Stacks[melee]));
			TF2Attrib_SetByName(melee, "deploy time decreased", 1.0 - (KnifeGunSpy_CloakSpeed[melee] * KnifeGunSpy_Stacks[melee]));
			if(primary > -1)
			{
				TF2Attrib_SetByName(primary, "fire rate bonus", 1.0 - (KnifeGunSpy_FireRate[melee] * KnifeGunSpy_Stacks[melee]));
				TF2Attrib_SetByName(primary, "Reload time decreased", 1.0 - (KnifeGunSpy_ReloadRate[melee] * KnifeGunSpy_Stacks[melee]));
			}
			if(GetEngineTime() >= KnifeGunSpy_Delay[melee] + KnifeGunSpy_MaxDelay[melee] && KnifeGunSpy_Stacks[melee] > 0 && !KnifeGunSpy_Draining[melee])
			{
				KnifeGunSpy_Draining[melee] = true;
				KnifeGunSpy_Stacks[melee]--;
				KnifeGunSpy_Delay[melee] = GetEngineTime();
			}
			if(GetEngineTime() >= KnifeGunSpy_Delay[melee] + KnifeGunSpy_Drain[melee] && KnifeGunSpy_Stacks[melee] > 0 && KnifeGunSpy_Draining[melee])
			{
				KnifeGunSpy_Stacks[melee]--;
				KnifeGunSpy_Delay[melee] = GetEngineTime();
			}
			SetHudTextParams(-1.0, 0.7, 0.5, 255, 255, 255, 255);
			ShowSyncHudText(client, KnifeGunSpy_Display, "Gun Spy Stacks: %i / %i", KnifeGunSpy_Stacks[melee], KnifeGunSpy_MaxStacks[melee]);
		}
		
		if(HasAttribute(client, _, LeapCloak))
		{
			new cloak = GetPlayerWeaponSlot(client, 4);
			if(GetEngineTime() >= GetAttributeValueF(client, _, LeapCloak, LeapCloak_Leaping) + 5.0)
			{
				TF2Attrib_RemoveByName(cloak, "cancel falling damage");
				TF2Attrib_RemoveByName(cloak, "increased air control");
			}
			else
			{
				TF2Attrib_SetByName(cloak, "cancel falling damage", 1.0);
				TF2Attrib_SetByName(cloak, "increased air control", GetAttributeValueF(client, _, LeapCloak, LeapCloak_AirControl));
			}
		}
		
		if(HasAttribute(client, _, BackstabService))
		{
			SetHudTextParams(0.6, 0.6, 0.2, 255, 255, 255, 255);
			ShowSyncHudText(client, hudText_MelWeapon, "Stacks: %i / %i", GetAttributeValueI(client, _, BackstabService, BackstabService_Stacks), GetAttributeValueI(client, _, BackstabService, BackstabService_MaxStacks));
		}
		
		if (!m_bHasAttribute[client][slot]) return Plugin_Continue; //11-6
		
		//11-7
		if(FastReloadHeadshot[wep])
		{
			if(GetEngineTime() >= FastReloadHeadshot_Dur[wep] + 1.0) 
			{
				TF2Attrib_RemoveByName(wep, "faster reload rate");
				TF2Attrib_SetByName(wep, "faster reload rate", FastReloadHeadshot_Miss[wep]);
			}
			if(FastReloadHeadshot_Bonuses[wep] == 1)
			{
				FastReloadHeadshot_RifleCharge[wep] = GetEntPropFloat(wep, Prop_Send, "m_flChargedDamage");
			}
		}
		
		//11-8
		if(wep > -1 && StoreCritOnHeadshot[wep]) 
		{
			if(StoreCritOnHeadshot_Type[wep] == 1) 
			{
				SetHudTextParams(-1.0, 0.6, 0.2, 255, 255, 255, 255);
				ShowSyncHudText(client, hudText_MelWeapon, "Crits: %i / %i", StoreCritOnHeadshot_Crits[wep], StoreCritOnHeadshot_Max[wep]);
				if(StoreCritOnHeadshot_Crits[wep] > 0)
					TF2_AddCondition(client, TFCond:37, 0.11);
			}
			else if(StoreCritOnHeadshot_Type[wep] == 2) 
			{
				SetHudTextParams(-1.0, 0.6, 0.2, 255, 255, 255, 255);
				ShowSyncHudText(client, hudText_MelWeapon, "Minicrits: %i / %i", StoreCritOnHeadshot_Crits[wep], StoreCritOnHeadshot_Max[wep]);
				if(StoreCritOnHeadshot_Crits[wep] > 0)
					TF2_AddCondition(client, TFCond:16, 0.11);
			}
		}
		
		//11-9
		if(HammerMechanic[client][slot]) //Hammer Mechanic
		{
			if(HammerMechanic_Fann[client][slot] == true)
			{
				SetHudTextParams(-1.0, 0.7, 0.2, 255, 255, 255, 255);
				ShowSyncHudText(client, hudText_PriWeapon, "Firing Mode: Hammer Firing");
			}
			else if(HammerMechanic_Fann[client][slot] == false)
			{
				SetHudTextParams(-1.0, 0.7, 0.2, 255, 255, 255, 255);
				ShowSyncHudText(client, hudText_PriWeapon, "Firing Mode: Trigger Firing");
			}
		}
		
		//11-10
		if(DispenserMinigunSpecial[client][slot] && DispenserMinigunSpecial_ChrgType[client][slot] > 0)
		{
			if(DispenserMinigunSpecial_FuryDur[client][slot] <= 0.0)
			{
				SetHudTextParams(-1.0, 0.7, 0.2, 255,255,255,255);
				ShowSyncHudText(client, hudText_PriWeapon, "Fury Charge: %i/%i", RoundToFloor(DispenserMinigunSpecial_Charge[client][slot]), RoundToFloor(DispenserMinigunSpecial_MaxChrg[client][slot]));
			} else if(DispenserMinigunSpecial_FuryDur[client][slot] > 0.0)
			{
				SetHudTextParams(-1.0, 0.7, 0.2, 255,0,0,255);
				ShowSyncHudText(client, hudText_PriWeapon, "Fury Charge: %i/%i", RoundToFloor(DispenserMinigunSpecial_Charge[client][slot]), RoundToFloor(DispenserMinigunSpecial_MaxChrg[client][slot]));
			}
			if(DispenserMinigunSpecial_Charge[client][slot] >= DispenserMinigunSpecial_MaxChrg[client][slot])
			{
				SetHudTextParams(-1.0, 0.6, 0.2, 200,200,255,255);
				ShowSyncHudText(client, hudText_PriWearer, "Press Special-Attack to activate\n Dispensing Fury!");
			}
		}
		
		//11-11
		if(BrewAttrib[client][slot])
		{
			SetHudTextParams(-1.0, 0.7, 0.2, 255,255,255,255);
			ShowSyncHudText(client, hudText_PriWeapon, "Vodka Brewed: %i/%i pints", BrewAttrib_Stacks[client][slot], BrewAttrib_MaxStacks[client][slot]);
		}
		
		//11-12
		if(HeavyDutyRifle[wep])
		{
			if(GetEngineTime() >= HeavyDutyRifle_Delay[wep] + HeavyDutyRifle_DecayDur[wep])
			{
				if(HeavyDutyRifle_Stacks[wep] > 0) 
					HeavyDutyRifle_Stacks[wep]--;
				new Float:headshotdmg = 1.0 + (HeavyDutyRifle_Mult[wep] * HeavyDutyRifle_Stacks[wep]);
				TF2Attrib_SetByName(wep, "headshot damage increase", headshotdmg);
				HeavyDutyRifle_Delay[wep] = GetEngineTime();
			}
		}
		
		//11-13
		if(MetalOnKill[client][slot])
		{
			SetHudTextParams(0.6, 0.6, 0.2, 255, 255, 255, 255);
			ShowSyncHudText(client, hudText_PriWeapon, "Metal: +%i / +%i", RoundToFloor((MetalOnKill_MaxMetal[client][slot] * MetalOnKill_Metal[client][slot]) * MetalOnKill_Kills[client][slot]), RoundFloat((MetalOnKill_MaxMetal[client][slot] * MetalOnKill_Metal[client][slot]) * MetalOnKill_MaxKills[client][slot]));
		}
		
	}
	return Plugin_Continue;
}

public OnEntityCreated(Ent, const String:cls[])
{
	if (Ent < 0 || Ent > 2048) return;
	if (!StrContains(cls, "tf_weapon_")) CreateTimer(0.3, OnWeaponSpawned, EntIndexToEntRef(Ent));
}

//OnEntityDestroyed & CW3_OnWeaponRemoved start here
//*12
public OnEntityDestroyed(Ent)
{
	if(Ent <= 0 || Ent > 2048) return;
	BoosterShotUber[Ent] = false; //12-1
	BoosterShotUber_OldCap[Ent] = 0.0;
	BoosterShotUber_OldDecay[Ent] = 0.0;
	BoosterShotUber_OldBuild[Ent] = 0.0;
	ReviveUber[Ent] = false; //12-2
	ReviveUber_PatientHealing[Ent] = 0.0;
	ReviveUber_PatientHealth[Ent] = 0.0;
	ReviveUber_MedicHealing[Ent] = 0.0;
	ReviveUber_SelfHealing[Ent] = 0.0;
	ReviveUber_SelfUber[Ent] = 0.0;
	ReviveUber_Uber[Ent] = 0.0;
	StoreCritOnHeadshot[Ent] = false; //12-3
	StoreCritOnHeadshot_Crits[Ent] = 0;
	StoreCritOnHeadshot_Max[Ent] = 0;
	StoreCritOnHeadshot_Type[Ent] = 0;
	StoreCritOnHeadshot_AddCrits[Ent] = 0;
	BlitzkriegBuffs[Ent] = false; //12-4
	BlitzkriegBuffs_Buff[Ent] = 0;
	BlitzkriegBuffs_Delay[Ent] = 0.0;
	KralleBuffs_PassHealSpd[Ent] = 0.0;
	KralleBuffs_PassFireSpd[Ent] = 0.0;
	KralleBuffs_PassReloadSpd[Ent] = 0.0;
	KralleBuffs_PassMoveSpd[Ent] = 0.0;
	KralleBuffs_UberHealSpd[Ent] = 0.0;
	KralleBuffs_UberFireSpd[Ent] = 0.0;
	KralleBuffs_UberReloadSpd[Ent] = 0.0;
	KralleBuffs_UberMoveSpd[Ent] = 0.0;
	KralleBuffs_OldHealSpd[Ent] = 0.0;
	AttacksCarryBombs[Ent] = false; //12-5
	AttacksCarryBombs_Blast[Ent] = 0.0;
	AttacksCarryBombs_Bombs[Ent] = 0;
	AttacksCarryBombs_MinDMG[Ent] = 0.0;
	AttacksCarryBombs_MaxDMG[Ent] = 0.0;
	AttacksCarryBombs_MaxBombs[Ent] = 0;
	AttacksCarryBombs_MaxDur[Ent] = 0.0;
	AttacksCarryBombs_ArmTime[Ent] = 0.0;
	HeavyDutyRifle[Ent] = false; //12-6
	HeavyDutyRifle_Mult[Ent] = 0.0;
	HeavyDutyRifle_MaxStacks[Ent] = 0;
	HeavyDutyRifle_Stacks[Ent] = 0;
	HeavyDutyRifle_DecayDur[Ent] = 0.0;
	HeavyDutyRifle_Delay[Ent] = 0.0;
	SpookOLanterns[Ent] = false; //12-7
	SpookOLanterns_TotalDMG[Ent] = 0.0;
	MoonshineAttrib[Ent] = false; //12-8
	MoonshineAttrib_DMGBonus[Ent] = 0.0;
	MoonshineAttrib_SwingBonus[Ent] = 0.0;
	MoonshineAttrib_MaxStacks[Ent] = 0;
	MoonshineAttrib_Stacks[Ent] = 0;
	MoonshineAttrib_OverhealCap[Ent] = 0.0;
	MoonshineAttrib_Wait[Ent] = 0.0;
	MoonshineAttrib_Dur[Ent] = 0.0;
	MoonshineAttrib_DMGResist[Ent] = 0.0;
	FastReloadHeadshot[Ent] = false; //12-9
	FastReloadHeadshot_Headshot[Ent] = 0.0;
	FastReloadHeadshot_Bodyshot[Ent] = 0.0;
	FastReloadHeadshot_Miss[Ent] = 0.0;
	FastReloadHeadshot_Bonuses[Ent] = 0;
	FastReloadHeadshot_RifleCharge[Ent] = 0.0;
	FastReloadHeadshot_Dur[Ent] = 0.0;
	KnifeGunSpy[Ent] = false;
	KnifeGunSpy_FireRate[Ent] = 0.0;
	KnifeGunSpy_ReloadRate[Ent] = 0.0;
	KnifeGunSpy_MoveSpeed[Ent] = 0.0;
	KnifeGunSpy_SwitchSpeed[Ent] = 0.0;
	KnifeGunSpy_CloakSpeed[Ent] = 0.0;
	KnifeGunSpy_Delay[Ent] = 0.0;
	KnifeGunSpy_MaxDelay[Ent] = 0.0;
	KnifeGunSpy_Drain[Ent] = 0.0;
	KnifeGunSpy_Stacks[Ent] = 0;
	KnifeGunSpy_MaxStacks[Ent] = 0;
	KnifeGunSpy_Draining[Ent] = false;
}

public Action:OnWeaponSpawned(Handle:timer, any:ref)
{
	new Ent = EntRefToEntIndex(ref);
	if (!IsValidEntity(Ent) || Ent == -1) return;
	new owner = GetEntPropEnt(Ent, Prop_Send, "m_hOwnerEntity");
	if (owner == -1) return;
	new String:cls[20];
	GetEdictClassname(Ent, cls, sizeof(cls));
	if (StrEqual(cls, "tf_weapon_wrench", false) && TFClass_Engineer == TF2_GetPlayerClass(owner))
	{
		MaxAmmo[Ent] = 200;
		AmmoIsMetal[Ent] = true;
	}
	else MaxAmmo[Ent] = GetAmmo_Weapon(Ent);
	switch (GetEntProp(Ent, Prop_Send, "m_iItemDefinitionIndex"))
	{
		case 441, 442, 588: MaxEnergy[Ent] = GetEntPropFloat(Ent, Prop_Send, "m_flEnergy");
		default: MaxClip[Ent] = GetClip_Weapon(Ent);
	}
}

public CW3_OnWeaponRemoved(slot, client)
{
	FullClipOnKill[client][slot] = false; //12-10
	FullClipOnKill_Clip[client][slot] = 0;
	FullClipOnKill_Ammo[client][slot] = 0;
	FullClipOnKill_Amount[client][slot] = 0;
	AmmoOnKill[client][slot] = false;
	ResistOnKill[client][slot] = false; //12-11
	ResistOnKill_Bullet[client][slot] = 0.0;
	ResistOnKill_Blast[client][slot] = 0.0;
	ResistOnKill_Fire[client][slot] = 0.0;
	ResistOnKill_Sentry[client][slot] = 0.0;
	ResistOnKill_Knockback[client][slot] = 0.0;
	ResistOnKill_Dur[client][slot] = 0.0;
	ResistOnKill_MaxDur[client][slot] = 0.0;
	MetalOnKill[client][slot] = false; //12-12
	MetalOnKill_Metal[client][slot] = 0.0;
	MetalOnKill_Kills[client][slot] = 0;
	MetalOnKill_MaxKills[client][slot] = 0;
	BackstabService[client][slot] = false; //12-13
	BackstabService_CloakSpd[client][slot] = 0.0;
	BackstabService_DecloakSpd[client][slot] = 0.0;
	BackstabService_MoveSpd[client][slot] = 0.0;
	BackstabService_SapperPwr[client][slot] = 0.0;
	BackstabService_MaxStacks[client][slot] = 0;
	BackstabService_Stacks[client][slot] = 0;
	HammerMechanic[client][slot] = false; //12-14
	HammerMechanic_Fann[client][slot] = false;
	HammerMechanic_Wait[client][slot] = 0.0;
	HealRateKill[client][slot] = false; //12-15
	HealRateKill_Bonus[client][slot] = 0.0;
	HealRateKill_MaxStacks[client][slot] = 0;
	HealRateKill_Stacks[client][slot] = 0;
	HealRateKill_Subtract[client][slot] = 0;
	HealRateKill_Blood[client][slot] = 0;
	HealRateKill_Wait[client][slot] = 0.0;
	DispenserMinigunHeal[client][slot] = false; //12-16
	DispenserMinigunHeal_HealDelay[client][slot] = 0.0;
	DispenserMinigunHeal_SelfHeal[client][slot] = 0.0;
	DispenserMinigunHeal_Delay[client][slot] = 0.0;
	DispenserMinigunAmmo[client][slot] = false;
	DispenserMinigunAmmo_Delay[client][slot] = 0.0;
	DispenserMinigunAmmo_AmmoDelay[client][slot] = 0.0;
	DispenserMinigunAmmo_Ammo[client][slot] = 0;
	DispenserMinigunSpecial[client][slot] = false; //12-17
	DispenserMinigunSpecial_MaxFuryDur[client][slot] = 0.0;
	DispenserMinigunSpecial_FuryDur[client][slot] = 0.0;
	DispenserMinigunSpecial_MaxDur[client][slot] = 0.0;
	DispenserMinigunSpecial_Dur[client][slot] = 0.0;
	DispenserMinigunSpecial_Charge[client][slot] = 0.0;
	DispenserMinigunSpecial_MaxChrg[client][slot] = 0.0;
	DispenserMinigunSpecial_ChrgType[client][slot] = 0;
	DispenserMinigunSpecial_Boost[client][slot] = 0.0;
	DispenserMinigunSpecial_Radius[client][slot] = 0;
	BrewAttrib[client][slot] = false; //12-18
	BrewAttrib_Delay[client][slot] = 0.0;
	BrewAttrib_MaxDelay[client][slot] = 0.0;
	BrewAttrib_Stacks[client][slot] = 0;
	BrewAttrib_MaxStacks[client][slot] = 0;
	BrewAttrib_DmgBonus[client][slot] = 0.0;
	BrewAttrib_DmgResist[client][slot] = 0.0;
	ImpactBlast[client][slot] = false; //12-19
	ImpactBlast_Radius[client][slot] = 0.0;
	ImpactBlast_DMGMult[client][slot] = 0.0;
	LeapCloak[client][slot] = false; //12-20
	LeapCloak_Drain[client][slot] = 0.0;
	LeapCloak_LeapVel[client][slot] = 0.0;
	LeapCloak_LungeMult[client][slot] = 0.0;
	LeapCloak_Leaping[client][slot] = 0.0;
	DamageChargesMedigun[client][slot] = false; //12-21
	DamageChargesMedigun_MedicDmg[client][slot] = 0.0;
	DamageChargesMedigun_PatientDmg[client][slot] = 0.0;
	DamageChargesMedigun_UberedMult[client][slot] = 0.0;
	RadiusHealing[client][slot] = false; //12-22
	RadiusHealing_Mode[client][slot] = 0;
	RadiusHealing_Mode2[client][slot] = 0;
	RadiusHealing_Radius[client][slot] = 0.0;
	RadiusHealing_Healing[client][slot] = 0.0;
	RadiusHealing_UberedRadius[client][slot] = 0.0;
	RadiusHealing_UberedHealing[client][slot] = 0.0;
	RadiusUber[client][slot] = false; //12-23
	RadiusUber_Mode[client][slot] = 0;
	RadiusUber_Cond1[client][slot] = 0;
	RadiusUber_Cond2[client][slot] = 0;
	RadiusUber_Radius[client][slot] = 0.0;
	RadiusUber_ExclusiveCond[client][slot] = 0;
	RadiusUber_ExclusiveCond2[client][slot] = 0;
	RadiusUber_ExclusiveCond3[client][slot] = 0;
}

//Stocks start here
//*13
stock bool:IsEntityBuilding(entity) //13-1
{
	if(entity <= 0) return false;
	if(!IsValidEdict(entity)) return false;
	if(IsClassname(entity, "obj_sentrygun")) return true;
	if(IsClassname(entity, "obj_dispenser")) return true;
	if(IsClassname(entity, "obj_teleporter")) return true;
	return false;
}

stock Action:UpdatePatient(client) //13-3
{
	new wep = GetPlayerWeaponSlot(client, 1);
	if(wep == -1) return Plugin_Continue;
	if(!TrackPatientChanges[wep]) return Plugin_Continue;
	new patient = GetMediGunPatient(client);
	patient = -1;
	CreateTimer(0.1, ProceedUpdatePatient, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
	return Plugin_Continue;
}
//13-4
public Action:ProceedUpdatePatient(Handle:timer, any:ref) //Thanks to Theray for helping me figure out how to update medigun patients!
{
	new client = EntRefToEntIndex(ref);
	new wep = GetPlayerWeaponSlot(client, 1);
	if(wep == -1) return Plugin_Continue;
	if(!TrackPatientChanges[wep]) return Plugin_Continue;
	new patient = GetMediGunPatient(client);
	LastHealPatient[client] = patient;
	return Plugin_Continue;
}
//13-7
stock GetSlotContainingAttribute(client, const attribute[][] = m_bHasAttribute)
{
	if(!Client_IsValid(client)) return false;
	
	for(new i = 0; i < 7; i++)
	{
		if(m_bHasAttribute[client][i])
		{
			if(attribute[client][i])
			{
				return i;
			}
		}
	}
	
	return -1;
}
//13-8
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
//13-9
stock GetClientSlot(client)
{
	if(!Client_IsValid(client)) return -1;
	if(!IsPlayerAlive(client)) return -1;
	
	new slot = GetWeaponSlot(client, Client_GetActiveWeapon(client));
	return slot;
}