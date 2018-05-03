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

public Plugin:myinfo = {
	name = "Zethax Attributes Crafting",
	author = "Zethax",
	description = "Attributes made by Zethax specifically for Crafting's servers",
	version = PLUGIN_VERSION,
	url = ""
};

new bool:NoDebuffs[2049];
new bool:NoOverhealActive[2049];
new Float:NoOverhealActive_Threshold[2049];

new bool:FasterReloadKill[2049];
new FasterReloadKill_Stacks[2049];
new FasterReloadKill_MaxStacks[2049];
new Float:FasterReloadKill_Spd[2049];
new bool:LargerMeleeRangeOnKill[2049];
new Float:LargerMeleeRangeOnKill_Range[2049];
new Float:LargerMeleeRangeOnKill_Dur[2049];
new Float:LargerMeleeRangeOnKill_MaxDur[2049];
new Float:LargerMeleeRangeOnKill_Bounds[2049];
new bool:MeleeRangeKillStack[2049];
new MeleeRangeKillStack_Stacks[2049];
new MeleeRangeKillStack_MaxStacks[2049];
new Float:MeleeRangeKillStack_Range[2049];
new Float:MeleeRangeKillStack_Bounds[2049];

new bool:MissingHealthFasterMovement[MAXPLAYERS+1][SLOTS_MAX+1];
new Float:MissingHealthFasterMovement_Mult[MAXPLAYERS+1][SLOTS_MAX+1];
new Float:MissingHealthFasterReload_Mult[2049];
new bool:MissingHealthFasterReload[2049];
new Float:MissingHealthUberBonus_Mult[MAXPLAYERS+1][SLOTS_MAX + 1];
new bool:MissingHealthUberBonus[MAXPLAYERS+1][SLOTS_MAX + 1];
new Float:MissingHealthFasterFire_Mult[2049];
new bool:MissingHealthFasterFire[2049];
new Float:MissingHealthJumpHeight_Mult[MAXPLAYERS+1][SLOTS_MAX + 1];
new bool:MissingHealthJumpHeight[MAXPLAYERS+1][SLOTS_MAX + 1];
new Float:MissingHealthDmgPen_Mult[2049];
new bool:MissingHealthDmgPen[2049];
new bool:MissingHealthCritChance[2049];
new Float:MissingHealthCritChance_Mult[2049];
new bool:MissingHealthDmgBonus[2049];
new Float:MissingHealthDmgBonus_Mult[2049];

new bool:BuffFlagUber[2049];
new bool:MiniUbers[2049];
new Float:MiniUbers_Count[2049];
new Float:MiniUbers_UberUntil[2049];

new bool:HammerMechanic[2049];
new bool:HammerMechanic_Fann[2049];
new HammerMechanic_x10[2049];
new Float:HammerMechanic_Wait[2049];
new Float:HammerMechanic_ProjectileSpeed[2049];
new Float:HammerMechanic_SwitchSpeed[2049];
new Float:HammerMechanic_ProjectilesShatter[2049];
new Float:HammerMechanic_MoveSpeed[2049];
new Float:HammerMechanic_FireRate[2049];
new Float:HammerMechanic_Damage[2049];
new Float:HammerMechanic_ReloadRate[2049];

new bool:SentryResOnKill[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:SentryResOnKill_Resist[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:SentryResOnKill_KnockRes[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:SentryResOnKill_Dur[2049];

new bool:DMGDrainsMetal[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:DMGDrainsMetal_Mult[MAXPLAYERS + 1][SLOTS_MAX + 1];

new DrinkEffects[2049];
new Float:DrinkEffects_Dur[2049];

new bool:CraftingOnKill[2049];
new Float:CraftingOnKill_Movespd[2049];
new Float:CraftingOnKill_Dmgpen[2049];
new CraftingOnKill_MaxStacks[2049];
new CraftingOnKill_Stacks[2049];
new Handle:CraftingOnKill_Display;

new bool:PrimaryWeaponBonuses[MAXPLAYERS+1][SLOTS_MAX + 1];
new Float:PrimaryWeaponBonuses_ReloadSpd[MAXPLAYERS+1][SLOTS_MAX + 1];
new Float:PrimaryWeaponBonuses_FiringSpd[MAXPLAYERS+1][SLOTS_MAX + 1];

new bool:AimMoveSpdOnKill[2049];
new Float:AimMoveSpdOnKill_Spd[2049];
new Float:AimMoveSpdOnKill_MaxDur[2049];
new Float:AimMoveSpdOnKill_Dur[2049];

new bool:AddcondSpunup[2049];
new AddcondSpunup_ID[2049];

new bool:AddcondCharging[MAXPLAYERS + 1][SLOTS_MAX + 1];
new AddcondCharging_ID[MAXPLAYERS + 1][SLOTS_MAX + 1];
new AddcondCharging_ID2[MAXPLAYERS + 1][SLOTS_MAX + 1];

new bool:BoosterShotUber[2049]; //I mean it's pretty safe to assume wearables can't ubercharge, right?
new Float:BoosterShotUber_HealDelay[2049];
new BoosterShotUber_x10[2049];

new bool:RemoveDebuffsWhileCloaked[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:CloakRemoveStatus[MAXPLAYERS + 1];
new Float:CloakRemoveStatus_Dur[MAXPLAYERS + 1][SLOTS_MAX + 1];

new bool:HealOnDraw[2049];
new Float:HealOnDraw_Mult[2049];
new HealOnDraw_HP[2049];
new Float:HealOnDraw_Cap[2049];
new bool:HealOnSheath[2049];
new Float:HealOnSheath_Mult[2049];
new HealOnSheath_HP[2049];
new Float:HealOnSheath_Cap[2049];
new HealOnSheath_Sheathed[MAXPLAYERS + 1];

new bool:SlownessOnHit[2049];
new Float:SlownessOnHit_MaxDur[2049];
new Float:SlownessOnHit_Dur[MAXPLAYERS + 1];
new Float:SlownessOnHit_Amount[2049];

new bool:UberRateKill[2049];
new Float:UberRateKill_Bonus[2049];
new UberRateKill_MaxStacks[2049];
new UberRateKill_Stacks[2049];
new UberRateKill_Subtract[2049];
new UberRateKill_Hearts[2049];

new bool:MilkOnHit[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:MilkOnHit_Dur[MAXPLAYERS + 1][SLOTS_MAX + 1];

new bool:MilkExplosionOnDeath[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:MilkExplosionOnDeath_Radius[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:MilkExplosionOnDeath_Dur[MAXPLAYERS + 1][SLOTS_MAX + 1];

new bool:m_bReduceDebuffDur[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:m_flReduceDebuffDur[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:m_flReduceDebuffDur_Jarate[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:m_flReduceDebuffDur_Milk[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:m_flReduceDebuffDur_Bleed[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:m_flReduceDebuffDur_Dazed[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:m_flReduceDebuffDur_OnFire[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:m_flReduceDebuffDur_MarkedForDeath[MAXPLAYERS + 1][SLOTS_MAX + 1];

new bool:KillsChargeItems[2049];
new Float:KillsChargeItems_Mult[2049];

new bool:SpeedOnKill[2049];
new Float:SpeedOnKill_Dur[2049];
new Float:SpeedOnKill_MaxDur[2049];
new Float:SpeedOnKill_Mult[2049];

new bool:m_bCondimentCannon[2049];
new Float:m_flCondimentCannon_Dur[2049];
new m_iCondimentCannon_Cond1[2049];
new m_iCondimentCannon_Cond2[2049];
new m_iCondimentCannon_Cond3[2049];
new m_iCondimentCannon_Cond4[2049];
new m_iCondimentCannon_Shot[2049];

new bool:m_bGainCondOnHit[2049];
new Float:m_flGainCondOnHit_Dur[2049];
new m_iGainCondOnHit_Cond[2049];

new bool:m_bSpreadDmg[2049];
new Float:m_flSpreadDmg_Mult[2049] = 1.0;
new Float:m_flSpreadDmg_MultMedic[2049] = 1.0;
new Float:m_flSpreadDmg_MinHealth[2049] = 1.0;

new bool:m_bHealthWhileSpunUp[2049];
new Float:m_flHealthWhileSpunUp_Packs[2049];
new Float:m_flHealthWhileSpunUp_Healers[2049];
new Float:m_flHealthWhileSpunUp_Medics[2049];

new bool:m_bPrimaryDmg[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:m_flPrimaryDmg_Mult[MAXPLAYERS + 1][SLOTS_MAX + 1];

new bool:bCritsOnSapperRemoved[MAXPLAYERS + 1][SLOTS_MAX + 1];
new iCritsOnSapperRemoved_Cap[MAXPLAYERS + 1][SLOTS_MAX + 1];
new iCritsOnSapperRemoved_Type[MAXPLAYERS + 1][SLOTS_MAX + 1];
new iCritsOnSapperRemoved_Crits[MAXPLAYERS + 1][SLOTS_MAX + 1];
new iCritsOnSapperRemoved_Add[MAXPLAYERS + 1][SLOTS_MAX + 1];

new bool:m_bMeleeDmg[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:m_flMeleeDmg_Mult[MAXPLAYERS + 1][SLOTS_MAX + 1];

new bool:AddcondOnBackstab[2049];
new AddcondOnBackstab_ID[2049];
new Float:AddcondOnBackstab_Dur[2049];

new bool:SecondaryKillChargesMelee[2049];
new bool:SecondaryKillChargesMelee_Kill[2049];
new SecondaryKillChargesMelee_CondID[2049];
new Float:SecondaryKillChargesMelee_MaxDur[2049];
new Float:SecondaryKillChargesMelee_Dur[2049];

new bool:MeleeKillChargesSecondary[2049];
new bool:MeleeKillChargesSecondary_Kill[2049];
new MeleeKillChargesSecondary_CondID[2049];
new Float:MeleeKillChargesSecondary_Dur[2049];
new Float:MeleeKillChargesSecondary_MaxDur[2049];

new bool:NoCritBoost[2049];

new bool:AddcondDrink[2049];
new Float:AddcondDrink_Dur1[2049];
new Float:AddcondDrink_Dur2[2049];
new AddcondDrink_ID1[2049];
new AddcondDrink_ID2[2049];

new bool:AddcondOnKill[2049];
new Float:AddcondOnKill_Dur[2049];
new AddcondOnKill_ID1[2049];
new AddcondOnKill_ID2[2049];
new AddcondOnKill_ID3[2049];

new bool:MetalToDmg[2049];
new Float:MetalToDmg_Mult[2049];

new bool:CondOnWearer[MAXPLAYERS + 1][SLOTS_MAX + 1];
new CondOnWearer_ID[MAXPLAYERS + 1][SLOTS_MAX + 1];

new bool:TankGoodness[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:TankGoodness_Charge[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:TankGoodness_ChargeMult[MAXPLAYERS + 1][SLOTS_MAX + 1]; // 1
new Float:TankGoodness_MaxCharge[MAXPLAYERS + 1][SLOTS_MAX + 1]; // 2
new Float:TankGoodness_ChargePerLvl[MAXPLAYERS + 1][SLOTS_MAX + 1]; // 3
new Float:TankGoodness_Level[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:TankGoodness_MaxAmmo[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:TankGoodness_HPOnKill[MAXPLAYERS + 1][SLOTS_MAX + 1]; // 5
new Float:TankGoodness_BonusHealing[MAXPLAYERS + 1][SLOTS_MAX + 1]; // 6
new Float:TankGoodness_KnockbackResist[MAXPLAYERS + 1][SLOTS_MAX + 1]; // 7
new TankGoodness_ChargesIt[MAXPLAYERS + 1][SLOTS_MAX + 1]; // 4
new Float:TankGoodness_MinResistDur[MAXPLAYERS + 1][SLOTS_MAX + 1]; // 8
new Float:TankGoodness_ResistDurPerLvl[MAXPLAYERS + 1][SLOTS_MAX + 1]; // 9
new Handle:TankGoodness_Handle;

new bool:ElectroShock[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:ElectroShock_Charge[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:ElectroShock_MaxCharge[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:ElectroShock_ChargeMult[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:ElectroShock_Dur[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:ElectroShock_MaxDur[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Handle:ElectroShock_Display;

new bool:UncontainableReaction[2049];
new UncontainableReaction_Combo[2049];
new Float:UncontainableReaction_Dur[2049];
new bool:m_bSlotDisabled[MAXPLAYERS + 1];

new bool:UberDamageResistance[2049];
new Float:UberDamageResistance_DmgResist[2049];

new bool:StompDmgMultiplier[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:StompDmgMultiplier_Mult[MAXPLAYERS + 1][SLOTS_MAX + 1];

new bool:FallDmgMult[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:FallDmgMult_Multiplier[MAXPLAYERS + 1][SLOTS_MAX + 1];
new bool:FallDmgMult_Active[MAXPLAYERS + 1][SLOTS_MAX + 1];

new bool:DrainVictimAmmo[2049];
new Float:DrainVictimAmmo_Primary[2049];
new Float:DrainVictimAmmo_Secondary[2049];
new Float:DrainVictimAmmo_Metal[2049];
new Float:DrainVictimAmmo_Rage[2049];
new Float:DrainVictimAmmo_Ubercharge[2049];
new Float:DrainVictimAmmo_Cloak[2049];

new bool:EvasionOnHit[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:EvasionOnHit_Evasion[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:EvasionOnHit_Add[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:EvasionOnHit_Subtract[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:EvasionOnHit_MeleeSubtract[MAXPLAYERS + 1][SLOTS_MAX + 1];
new bool:EvasionOnHit_Active[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Handle:EvasionOnHit_Display;

new bool:EngieHaulSpeed[MAXPLAYERS+1][SLOTS_MAX+1]; //From nergalpak
new Float:EngieHaulSpeed_Mult[MAXPLAYERS+1][SLOTS_MAX+1]; //From nergalpak

new bool:ShellshockAttrib[2049];
new Float:ShellshockAttrib_Max[2049];
new Float:ShellshockAttrib_Amount[2049];
new Float:ShellshockAttrib_Teleports[2049];

new bool:SuperSlidersStomp[MAXPLAYERS + 1][SLOTS_MAX + 1]; //Oh yes, this attribute right here is gonna be my favorite part of this update
new Float:SuperSlidersStomp_JumpHeight[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:SuperSlidersStomp_DamageMult[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:SuperSlidersStomp_Max[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:SuperSlidersStomp_Stacks[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:SuperSlidersStomp_OnGround[MAXPLAYERS + 1][SLOTS_MAX + 1];
new bool:SuperSlidersStomp_Stomp[MAXPLAYERS + 1][SLOTS_MAX + 1];

new bool:IronBoarder[2049];
new Float:IronBoarder_Healing[2049];
new Float:IronBoarder_ReloadRate[2049];
new Float:IronBoarder_ShieldRecharge[2049];

new bool:HeatDecreasesAccuracy[2049];
new HeatDecreasesAccuracy_Max[2049];
new HeatDecreasesAccuracy_Stacks[2049];
new Float:HeatDecreasesAccuracy_Accuracy[2049];
new Float:HeatDecreasesAccuracy_OldAccuracy[2049];
new Float:HeatDecreasesAccuracy_Delay[2049];
new Float:HeatDecreasesAccuracy_MaxDelay[2049];
new Handle:HeatDecreasesAccuracy_Text;

new bool:SpyDetector[2049];
new Float:SpyDetector_Radius[2049];
new Float:SpyDetector_MaxDur[2049];
new Float:SpyDetector_Dur[2049];
new Float:SpyDetector_Vuln[2049];
new SpyDetector_Type[2049];

new bool:RemoveBleed[2049];

new bool:HeadshotsMinicrit[2049];

new LastWeaponHurtWith[MAXPLAYERS + 1];
new MaxClip[2049];
new MaxAmmo[2049];
new bool:AmmoIsMetal[2049];
new Float:MaxEnergy[2049];
new Float:LastTick[MAXPLAYERS + 1];
new Handle:hudText_Client;

public OnPluginStart() {

	HookEvent("player_death", Event_Death);
	HookEvent("player_spawn", Event_Respawn);
	HookEvent("player_chargedeployed", Event_Ubercharge);
	HookEvent("object_destroyed", OnObjectDestroyed);
	HookEvent("object_detonated", OnObjectDetonated);
	HookEvent("player_teleported", OnPlayerTeleport, EventHookMode_Pre);
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i)) continue;
		{
		OnClientPutInServer(i);
		}
	}
	hudText_Client = CreateHudSynchronizer();
	CraftingOnKill_Display = CreateHudSynchronizer();
	TankGoodness_Handle = CreateHudSynchronizer();
	ElectroShock_Display = CreateHudSynchronizer();
	EvasionOnHit_Display = CreateHudSynchronizer();
	HeatDecreasesAccuracy_Text = CreateHudSynchronizer();
}
public OnMapStart() {
	
	PrecacheSound("npc/attack_helicopter/aheli_charge_up.wav", true);
	PrecacheSound("npc/vort/health_charge.wav", true);
	PrecacheSound("vehicles/crane/crane_magnet_release.wav", true);
	PrecacheSound("jar_explode.wav", true);
	PrecacheSound("weapons/vaccinator_charge_tier_01.wav", true);
	PrecacheSound("weapons/vaccinator_charge_tier_02.wav", true);
	PrecacheSound("weapons/vaccinator_charge_tier_03.wav", true);
	PrecacheSound("weapons/vaccinator_charge_tier_04.wav", true);
	PrecacheSound("player/recharged.wav", true);
	PrecacheSound("player/invulnerable_on.wav", true);
	PrecacheSound("ambient/halloween/thunder_04.wav", true);
	PrecacheSound("items/powerup_pickup_haste.wav", true);
}
public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
	SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
	SDKHook(client, SDKHook_WeaponSwitch, OnWeaponSwitch);
	SDKHook(client, SDKHook_PreThink, OnClientPreThink);
	
	LastWeaponHurtWith[client] = 0;
}
stock GetClientSlot(client)
{
	if(!Client_IsValid(client)) return -1;
	if(!IsPlayerAlive(client)) return -1;
	
	new slot = GetWeaponSlot(client, Client_GetActiveWeapon(client));
	return slot;
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

public Action:CW3_OnAddAttribute(slot, client, const String:attrib[], const String:plugin[], const String:value[], bool:whileActive)
{
	if(!StrEqual(plugin, "zethax-ctf2w")) return Plugin_Continue;
	new Action:action;
	new weapon = GetPlayerWeaponSlot(client, slot);
	
	if(StrEqual(attrib, "debuff immunity while spun up"))
	{
		if(weapon == -1) return Plugin_Continue;
		NoDebuffs[weapon] = true;
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "no overheal while active"))
	{
		if(weapon == -1) return Plugin_Continue;
		NoOverhealActive_Threshold[weapon] = StringToFloat(value);
		NoOverhealActive[weapon] = true;
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "faster reload speed on kill"))
	{
		if(weapon == -1) return Plugin_Continue;
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		FasterReloadKill_Spd[weapon] = StringToFloat(values[0]);
		FasterReloadKill_MaxStacks[weapon] = StringToInt(values[1]);
		FasterReloadKill_Stacks[weapon] = 0;
		FasterReloadKill[weapon] = true;
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "increased melee range on kill"))
	{
		if(weapon == -1) return Plugin_Continue;
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		LargerMeleeRangeOnKill_Range[weapon] = StringToFloat(values[0]);
		LargerMeleeRangeOnKill_Bounds[weapon] = StringToFloat(values[1]);
		LargerMeleeRangeOnKill_MaxDur[weapon] = StringToFloat(values[2]);
		LargerMeleeRangeOnKill_Dur[weapon] = 0.0;
		LargerMeleeRangeOnKill[weapon] = true;
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "move speed bonus as health decreases"))
	{
		MissingHealthFasterMovement_Mult[client][slot] = StringToFloat(value);
		MissingHealthFasterMovement[client][slot] = true;
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "reload rate bonus as health decreases"))
	{
		if(weapon == -1) return Plugin_Continue;
		MissingHealthFasterReload_Mult[weapon] = StringToFloat(value);
		MissingHealthFasterReload[weapon] = true;
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "uber rate bonus as health decreases"))
	{
		MissingHealthUberBonus_Mult[client][slot] = StringToFloat(value);
		MissingHealthUberBonus[client][slot] = true;
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "ubercharge is buff flags"))
	{
		if(weapon == -1) return Plugin_Continue;
		BuffFlagUber[weapon] = true;
		TF2Attrib_SetByName(weapon, "medigun charge is crit boost", -1.0);
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "hammer mechanic"))
	{
		if(weapon == -1) return Plugin_Continue;
		new String:values[8][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		HammerMechanic[weapon] = true;
		HammerMechanic_ProjectileSpeed[weapon] = StringToFloat(values[0]);
		HammerMechanic_SwitchSpeed[weapon] = StringToFloat(values[1]);
		HammerMechanic_ProjectilesShatter[weapon] = StringToFloat(values[2]);
		HammerMechanic_MoveSpeed[weapon] = StringToFloat(values[3]);
		HammerMechanic_FireRate[weapon] = StringToFloat(values[4]);
		HammerMechanic_ReloadRate[weapon] = StringToFloat(values[5]);
		HammerMechanic_Damage[weapon] = StringToFloat(values[6]);
		HammerMechanic_x10[weapon] = StringToInt(values[7]);
		HammerMechanic_Fann[weapon] = false;
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "sentry resist on kill"))
	{
		if(weapon == -1) return Plugin_Continue;
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		SentryResOnKill_Resist[client][slot] = StringToFloat(values[0]);
		SentryResOnKill_KnockRes[client][slot] = StringToFloat(values[1]);
		SentryResOnKill_Dur[weapon] = StringToFloat(values[2]);
		
		SentryResOnKill[client][slot] = true;
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "damage taken drains metal"))
	{
		DMGDrainsMetal_Mult[client][slot] = StringToFloat(value);
		DMGDrainsMetal[client][slot] = true;
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "on drink random effect"))
	{
		if(weapon == -1) return Plugin_Continue;
		DrinkEffects_Dur[weapon] = StringToFloat(value);
		DrinkEffects[weapon] = true;
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "fire rate bonus as health decreases"))
	{
		if(weapon == -1) return Plugin_Continue;
		MissingHealthFasterFire_Mult[weapon] = StringToFloat(value);
		MissingHealthFasterFire[weapon] = true;
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "move speed damage penalty on kill"))
	{
		if(weapon == -1) return Plugin_Continue;
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		CraftingOnKill_Movespd[weapon] = StringToFloat(values[0]);
		CraftingOnKill_Dmgpen[weapon] = StringToFloat(values[1]);
		CraftingOnKill_MaxStacks[client] = StringToInt(values[2]);
		CraftingOnKill_Stacks[client] = 0;
		CraftingOnKill[weapon] = true;
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "jump height bonus as health decreases"))
	{
		MissingHealthJumpHeight_Mult[client][slot] = StringToFloat(value);
		MissingHealthJumpHeight[client][slot] = true;
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "damage penalty as health decreases"))
	{
		if(weapon == -1) return Plugin_Continue;
		MissingHealthDmgPen_Mult[weapon] = StringToFloat(value);
		MissingHealthDmgPen[weapon] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "primary weapon bonuses")) {
		
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		PrimaryWeaponBonuses[client][slot] = true;
		PrimaryWeaponBonuses_ReloadSpd[client][slot] = StringToFloat(values[0]);
		PrimaryWeaponBonuses_FiringSpd[client][slot] = StringToFloat(values[1]);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "aiming movespeed increased on kill")) {
		
		if(weapon == -1) return Plugin_Continue;
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		AimMoveSpdOnKill_Spd[weapon] = StringToFloat(values[0]);
		AimMoveSpdOnKill_MaxDur[weapon] = StringToFloat(values[1]);
		AimMoveSpdOnKill[weapon] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "crit chance increase as health decreases")) {
		
		if(weapon == -1) return Plugin_Continue;
		MissingHealthCritChance_Mult[weapon] = StringToFloat(value);
		MissingHealthCritChance[weapon] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "addcond while spun up")) {
		
		if (weapon == -1)return Plugin_Continue;
		AddcondSpunup[weapon] = true;
		AddcondSpunup_ID[weapon] = StringToInt(value);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "addcond while demo charging")) {
		
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		AddcondCharging[client][slot] = true;
		AddcondCharging_ID[client][slot] = StringToInt(values[0]);
		AddcondCharging_ID2[client][slot] = StringToInt(values[1]);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "ubercharge is booster shot")) {
		
		if(weapon == -1) return Plugin_Continue;
		BoosterShotUber_x10[weapon] = StringToInt(value);
		BoosterShotUber[weapon] = true;
		TF2Attrib_SetByName(weapon, "medigun charge is crit boost", -1.0);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "remove negative status while cloaked")) {
			
		RemoveDebuffsWhileCloaked[client][slot] = true;
		CloakRemoveStatus_Dur[client][slot] = StringToFloat(value);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "heal on draw")) {
		
		if (weapon == -1)return Plugin_Continue;
		HealOnDraw[weapon] = true;
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		HealOnDraw_HP[weapon] = StringToInt(values[0]);
		HealOnDraw_Mult[weapon] = StringToFloat(values[1]);
		HealOnDraw_Cap[weapon] = StringToFloat(values[2]);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "heal on sheath")) {
		
		if (weapon == -1)return Plugin_Continue;
		HealOnSheath[weapon] = true;
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		HealOnSheath_HP[weapon] = StringToInt(values[0]);
		HealOnSheath_Mult[weapon] = StringToFloat(values[1]);
		HealOnSheath_Cap[client] = StringToFloat(values[2]);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "melee range on kill stacks")) {
		
		if (weapon == -1)return Plugin_Continue;
		MeleeRangeKillStack[weapon] = true;
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		MeleeRangeKillStack_MaxStacks[weapon] = StringToInt(values[0]);
		MeleeRangeKillStack_Range[weapon] = StringToFloat(values[1]);
		MeleeRangeKillStack_Bounds[weapon] = StringToFloat(values[2]);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "slowness on hit")) {
		
		if (weapon == -1)return Plugin_Continue;
		SlownessOnHit[weapon] = true;
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		SlownessOnHit_MaxDur[weapon] = StringToFloat(values[0]);
		SlownessOnHit_Amount[weapon] = StringToFloat(values[1]);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "hits increase ubercharge rate")) {
	
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		UberRateKill_Bonus[weapon] = StringToFloat(values[0]);
		UberRateKill_MaxStacks[weapon] = StringToInt(values[1]);
		UberRateKill_Subtract[weapon] = StringToInt(values[2]);
		UberRateKill_Stacks[weapon] = 0;
		UberRateKill_Hearts[weapon] = 0;
		new secondary = GetPlayerWeaponSlot(client, 1);
		TF2Attrib_RemoveByName(secondary, "ubercharge rate penalty");
		
		UberRateKill[weapon] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "jarate on hit all")) {
		
		MilkOnHit[client][slot] = true;
		MilkOnHit_Dur[client][slot] = StringToFloat(value);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "jarate explosion on death")) {
		
		MilkExplosionOnDeath[client][slot] = true;
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		MilkExplosionOnDeath_Radius[client][slot] = StringToFloat(values[0]);
		MilkExplosionOnDeath_Dur[client][slot] = StringToFloat(values[1]);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "reduce debuff duration")) {
		
		m_bReduceDebuffDur[client][slot] = true;
		m_flReduceDebuffDur[client][slot] = StringToFloat(value);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "fill recharge bars on hit")) {
		
		if (weapon == -1)return Plugin_Continue;
		KillsChargeItems[weapon] = true;
		KillsChargeItems_Mult[weapon] = StringToFloat(value);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "speed buff on kill")) {
		
		if (weapon == -1)return Plugin_Continue;
		SpeedOnKill[weapon] = true;
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		SpeedOnKill_MaxDur[client] = StringToFloat(values[0]);
		SpeedOnKill_Mult[weapon] = StringToFloat(values[1]);
		SpeedOnKill_Dur[client] = 0.0;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "condiment cannon attrib")) {
		
		if (weapon == -1)return Plugin_Continue;
		m_bCondimentCannon[weapon] = true;
		new String:values[5][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		m_flCondimentCannon_Dur[weapon] = StringToFloat(values[0]);
		m_iCondimentCannon_Cond1[weapon] = StringToInt(values[1]);
		m_iCondimentCannon_Cond2[weapon] = StringToInt(values[2]);
		m_iCondimentCannon_Cond3[weapon] = StringToInt(values[3]);
		m_iCondimentCannon_Cond4[weapon] = StringToInt(values[4]);
		m_iCondimentCannon_Shot[weapon] = GetClip_Weapon(weapon);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "share damage while healing"))
	{
		if (weapon == -1)return Plugin_Continue;
		m_bSpreadDmg[weapon] = true;
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		m_flSpreadDmg_Mult[weapon] = StringToFloat(values[0]);
		m_flSpreadDmg_MultMedic[weapon] = StringToFloat(values[1]);
		m_flSpreadDmg_MinHealth[weapon] = StringToFloat(values[2]);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "gain condition on hit")) {
		
		if (weapon == -1)return Plugin_Continue;
		m_bGainCondOnHit[weapon] = true;
		new String:values[5][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		m_flGainCondOnHit_Dur[weapon] = StringToFloat(values[0]);
		m_iGainCondOnHit_Cond[weapon] = StringToInt(values[1]);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "health from packs and healers while spun up")) {
		
		if (weapon == -1)return Plugin_Continue;
		m_bHealthWhileSpunUp[weapon] = true;
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		m_flHealthWhileSpunUp_Packs[weapon] = StringToFloat(values[0]);
		m_flHealthWhileSpunUp_Healers[weapon] = StringToFloat(values[1]);
		m_flHealthWhileSpunUp_Medics[weapon] = StringToFloat(values[2]);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "primary damage")) {
		
		m_bPrimaryDmg[client][slot] = true;
		m_flPrimaryDmg_Mult[client][slot] = StringToFloat(value);
		new primary = GetPlayerWeaponSlot(client, 0);
		if(primary > 0)
		{
			new String:cls[16];
			GetEdictClassname(primary, cls, sizeof(cls));
			if(!StrContains(cls, "tf_weapon_sniperrifle", false) || !StrContains(cls, "tf_weapon_compound_bow", false))
				TF2Attrib_SetByName(primary, "damage penalty", 1.0 + GetAttributeValueF(client, _, m_bPrimaryDmg, m_flPrimaryDmg_Mult));
			else
			{
				TF2Attrib_SetByName(primary, "dmg penalty vs players", 1.0 + GetAttributeValueF(client, _, m_bPrimaryDmg, m_flPrimaryDmg_Mult));
				TF2Attrib_SetByName(primary, "dmg bonus vs buildings", 1.0 + GetAttributeValueF(client, _, m_bPrimaryDmg, m_flPrimaryDmg_Mult));
			}
		}
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "gain crits on sapper removal")) {
		
		bCritsOnSapperRemoved[client][slot] = true;
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		iCritsOnSapperRemoved_Cap[client][slot] = StringToInt(values[0]);
		iCritsOnSapperRemoved_Add[client][slot] = StringToInt(values[1]);
		iCritsOnSapperRemoved_Type[client][slot] = StringToInt(values[2]);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "melee damage")) {
		
		m_bMeleeDmg[client][slot] = true;
		m_flMeleeDmg_Mult[client][slot] = StringToFloat(value);
		new melee = GetPlayerWeaponSlot(client, 2);
		if(melee > 0)
		{
			TF2Attrib_SetByName(melee, "dmg penalty vs players", GetAttributeValueF(client, _, m_bMeleeDmg, m_flMeleeDmg_Mult));
			TF2Attrib_SetByName(melee, "dmg bonus vs buildings", GetAttributeValueF(client, _, m_bMeleeDmg, m_flMeleeDmg_Mult));
		}
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "addcond on backstab")) {
		
		if (weapon == -1)return Plugin_Continue;
		
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		AddcondOnBackstab[weapon] = true;
		AddcondOnBackstab_ID[weapon] = StringToInt(values[0]);
		AddcondOnBackstab_Dur[weapon] = StringToFloat(values[1]);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "secondary kill charges melee")) {
	
		if (weapon == -1)return Plugin_Continue;
		
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		SecondaryKillChargesMelee[weapon] = true;
		SecondaryKillChargesMelee_CondID[weapon] = StringToInt(values[0]);
		SecondaryKillChargesMelee_MaxDur[weapon] = StringToFloat(values[1]);
		SecondaryKillChargesMelee_Kill[weapon] = false;
		SecondaryKillChargesMelee_Dur[weapon] = 0.0;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "melee kill charges secondary")) {
	
		if (weapon == -1)return Plugin_Continue;
		
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		MeleeKillChargesSecondary[weapon] = true;
		MeleeKillChargesSecondary_CondID[weapon] = StringToInt(values[0]);
		MeleeKillChargesSecondary_MaxDur[weapon] = StringToFloat(values[1]);
		MeleeKillChargesSecondary_Kill[weapon] = false;
		MeleeKillChargesSecondary_Dur[weapon] = 0.0;
		action = Plugin_Handled;
	} else if (StrEqual(attrib, "dmg bonus as health decreases"))
	{
		if(weapon == -1) return Plugin_Continue;
		MissingHealthDmgBonus_Mult[weapon] = StringToFloat(value);
		MissingHealthDmgBonus[weapon] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "no crit or minicrit boost")) {
	
		if (weapon == -1)return Plugin_Continue;
		NoCritBoost[weapon] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "addcond drink start")) {
	
		if (weapon == -1)return Plugin_Continue;
		
		AddcondDrink[weapon] = true;
		
		new String:values[4][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		AddcondDrink_Dur1[weapon] = StringToFloat(values[0]);
		AddcondDrink_ID1[weapon] = StringToInt(values[1]);
		AddcondDrink_Dur2[weapon] = StringToFloat(values[2]);
		AddcondDrink_ID2[weapon] = StringToInt(values[3]);
		
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "addcond on kill")) {
	
		if (weapon == -1)return Plugin_Continue;
		
		AddcondOnKill[weapon] = true;
		
		new String:values[4][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		AddcondOnKill_Dur[weapon] = StringToFloat(values[0]);
		AddcondOnKill_ID1[weapon] = StringToInt(values[1]);
		AddcondOnKill_ID2[weapon] = StringToInt(values[2]);
		AddcondOnKill_ID3[weapon] = StringToInt(values[3]);
		
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "metal to dmg")) {
	
		if (weapon == -1)return Plugin_Continue;
		
		MetalToDmg[weapon] = true;
		MetalToDmg_Mult[weapon] = StringToFloat(value);
		
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "addcond on wearer")) {
	
		CondOnWearer[client][slot] = true;
		CondOnWearer_ID[client][slot] = StringToInt(value);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "tank goodness attrib")) {
	
		new String:values[10][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		TankGoodness[client][slot] = true;
		TankGoodness_ChargeMult[client][slot] = StringToFloat(values[0]);
		TankGoodness_MaxCharge[client][slot] = StringToFloat(values[1]);
		TankGoodness_ChargePerLvl[client][slot] = StringToFloat(values[2]);
		TankGoodness_ChargesIt[client][slot] = StringToFloat(values[3]);
		TankGoodness_MinResistDur[client][slot] = StringToFloat(values[4]);
		TankGoodness_ResistDurPerLvl[client][slot] = StringToFloat(values[5]);
		TankGoodness_MaxAmmo[client][slot] = StringToFloat(values[6]);
		TankGoodness_HPOnKill[client][slot] = StringToFloat(values[7]);
		TankGoodness_BonusHealing[client][slot] = StringToFloat(values[8]);
		TankGoodness_KnockbackResist[client][slot] = StringToFloat(values[9]);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "electroshock attrib")) {
	
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		ElectroShock[client][slot] = true;
		ElectroShock_MaxCharge[client][slot] = StringToFloat(values[0]);
		ElectroShock_ChargeMult[client][slot] = StringToFloat(values[1]);
		ElectroShock_MaxDur[client][slot] = StringToFloat(values[2]);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "uncontainable reaction attrib")) {
	
		if (weapon == -1)return Plugin_Continue;
		
		UncontainableReaction[weapon] = true;
		UncontainableReaction_Dur[weapon] = StringToFloat(value);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "dmg taken applies to uber")) {
	
		if (weapon != GetPlayerWeaponSlot(client, 1))return Plugin_Continue;
		
		UberDamageResistance[weapon] = true;
		UberDamageResistance_DmgResist[weapon] = StringToFloat(value);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "goomba stomp damage multiplier")) {
		
		StompDmgMultiplier[client][slot] = true;
		StompDmgMultiplier_Mult[client][slot] = StringToFloat(value);
		action = Plugin_Handled;
	} else if (StrEqual(attrib, "fall dmg multiplier")) {
	
		FallDmgMult[client][slot] = true;
		FallDmgMult_Multiplier[client][slot] = StringToFloat(value);
		if(whileActive)
		{
			FallDmgMult_Active[client][slot] = true;
		}
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "drain victim ammo")) {
	
		if (weapon == -1)return Plugin_Continue;
		new String:values[6][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		DrainVictimAmmo[weapon] = true;
		DrainVictimAmmo_Primary[weapon] = StringToFloat(values[0]);
		DrainVictimAmmo_Secondary[weapon] = StringToFloat(values[1]);
		DrainVictimAmmo_Metal[weapon] = StringToFloat(values[2]);
		DrainVictimAmmo_Rage[weapon] = StringToFloat(values[3]);
		DrainVictimAmmo_Ubercharge[weapon] = StringToFloat(values[4]);
		DrainVictimAmmo_Cloak[weapon] = StringToFloat(values[5]);
		
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "evasion on hit")) {
	
		if (weapon == -1)return Plugin_Continue;
		
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		EvasionOnHit_Add[client][slot] = StringToFloat(values[0]);
		EvasionOnHit_Subtract[client][slot] = StringToFloat(values[1]);
		EvasionOnHit_MeleeSubtract[client][slot] = StringToFloat(values[2]);
		if (whileActive)EvasionOnHit_Active[client][slot] = true;
		EvasionOnHit[client][slot] = true;
		
		action = Plugin_Handled;
	} else if (StrEqual(attrib, "engineer hauling speed multiplier")) //From nergalpak
	{
		EngieHaulSpeed_Mult[client][slot] = StringToFloat(value);
		EngieHaulSpeed[client][slot] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "shellshock attrib")) {
	
		if (weapon == -1)return Plugin_Continue;
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		ShellshockAttrib[weapon] = true;
		ShellshockAttrib_Amount[weapon] = StringToFloat(values[0]);
		ShellshockAttrib_Max[weapon] = StringToFloat(values[1]);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "super sliders attrib")) {
	
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		SuperSlidersStomp_JumpHeight[client][slot] = StringToFloat(values[0]);
		SuperSlidersStomp_DamageMult[client][slot] = StringToFloat(values[1]);
		SuperSlidersStomp_Max[client][slot] = StringToFloat(values[2]);
		
		SuperSlidersStomp[client][slot] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "iron boarder attrib")) {
	
		if (weapon == -1)return Plugin_Continue;
		
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		IronBoarder_Healing[weapon] = StringToFloat(values[0]);
		IronBoarder_ReloadRate[weapon] = StringToFloat(values[1]);
		IronBoarder_ShieldRecharge[weapon] = StringToFloat(values[2]);
		
		IronBoarder[weapon] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "heat decreases accuracy")) {
	
		if (weapon == -1)return Plugin_Continue;
		new String:values[4][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		HeatDecreasesAccuracy_MaxDelay[weapon] = StringToFloat(values[0]);
		HeatDecreasesAccuracy_Accuracy[weapon] = StringToFloat(values[1]);
		HeatDecreasesAccuracy_Max[weapon] = StringToInt(values[2]);
		HeatDecreasesAccuracy_OldAccuracy[weapon] = StringToFloat(values[3]);
		
		
		HeatDecreasesAccuracy[weapon] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "spy detector attrib")) {
	
		if (weapon == -1)return Plugin_Continue;
		new String:values[4][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		SpyDetector_Radius[weapon] = StringToFloat(values[0]);
		SpyDetector_Vuln[weapon] = StringToFloat(values[1]);
		SpyDetector_MaxDur[weapon] = StringToFloat(values[2]);
		SpyDetector_Type[weapon] = StringToInt(values[3]);
		
		SpyDetector[weapon] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "the bypass")) {
	
		new primary = GetPlayerWeaponSlot(client, 0);
		new secondary = GetPlayerWeaponSlot(client, 1);
		new melee = GetPlayerWeaponSlot(client, 2);
		if(primary > -1)
		{
			TF2Attrib_SetByName(primary, "cannot pick up intelligence", 1.0);
		}
		if(secondary > -1)
		{
			TF2Attrib_SetByName(secondary, "cannot pick up intelligence", 1.0);
		}
		if(melee > -1)
		{
			TF2Attrib_SetByName(melee, "cannot pick up intelligence", 1.0);
		}
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "remove bleed")) {
	
		if (weapon == -1)return Plugin_Continue;
		RemoveBleed[weapon] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "headshots minicrit")) {
	
		if (weapon == -1)return Plugin_Continue;
		HeadshotsMinicrit[weapon] = true;
		action = Plugin_Handled;
	}
	
	if (!m_bHasAttribute[client][slot]) m_bHasAttribute[client][slot] = bool:action;
	return action;
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3], damageCustom)
{
	new Action:action;
	if(victim <= 0) return Plugin_Continue;
	if((damagetype & DMG_FALL) == DMG_FALL && HasAttribute(victim, _, FallDmgMult))
	{
		if(!HasAttribute(victim, _, FallDmgMult_Active))
		{
			damage *= GetAttributeValueF(victim, _, FallDmgMult, FallDmgMult_Multiplier);
			action = Plugin_Changed;
		}
		new slot = GetClientSlot(victim);
		if(FallDmgMult_Active[victim][slot])
		{
			damage *= GetAttributeValueF(victim, _, FallDmgMult, FallDmgMult_Multiplier);
			action = Plugin_Changed;
		}
	}
	if(attacker <= 0) return Plugin_Continue;
	if(Client_IsValid(attacker) && Client_IsValid(victim) && attacker != victim && GetClientTeam(attacker) == GetClientTeam(victim)) return Plugin_Continue;
	new slot = GetWeaponSlot(attacker, weapon);
	new slot2 = GetClientSlot(victim);
	if(weapon > -1)
	{
		LastWeaponHurtWith[attacker] = weapon;
		if(HasAttribute(victim, _, DMGDrainsMetal))
		{
			if(damageCustom != TF_CUSTOM_BACKSTAB && damageCustom != TF_CUSTOM_HEADSHOT)
			{
				new metal = GetEntProp(victim, Prop_Data, "m_iAmmo", 4, 3);
				new Float:metaldrain = (damage * GetAttributeValueF(victim, _, DMGDrainsMetal, DMGDrainsMetal_Mult, 0.0));
				damage *= (1.0 - (metal * GetAttributeValueF(victim, _, DMGDrainsMetal, DMGDrainsMetal_Mult, 0.0)));
				if(damage < 0.0) damage = 0.0;
				SetEntProp(victim, Prop_Data, "m_iAmmo", metal-RoundToFloor(metaldrain), 4, 3);
				if(GetEntProp(victim, Prop_Data, "m_iAmmo", 4, 3) < 0) SetEntProp(victim, Prop_Data, "m_iAmmo", 0, 4, 3);
				action = Plugin_Changed;
			} else if(damageCustom == TF_CUSTOM_BACKSTAB && damageCustom != TF_CUSTOM_HEADSHOT)
			{
				new metal = GetEntProp(victim, Prop_Data, "m_iAmmo", 4, 3);
				damage *= 0.0;
				if(damage < 0.0) damage = 0.0;
				if(metal < 200) damage *= 6.0;
				SetEntProp(victim, Prop_Data, "m_iAmmo", metal-200, 4, 3);
				if(GetEntProp(victim, Prop_Data, "m_iAmmo", 4, 3) < 0) SetEntProp(victim, Prop_Data, "m_iAmmo", 0, 4, 3);
				action = Plugin_Changed;
			} else if(damageCustom != TF_CUSTOM_BACKSTAB && damageCustom == TF_CUSTOM_HEADSHOT)
			{
				new metal = GetEntProp(victim, Prop_Data, "m_iAmmo", 4, 3);
				new Float:metaldrain = ((damage * 3.0) * GetAttributeValueF(victim, _, DMGDrainsMetal, DMGDrainsMetal_Mult, 0.0));
				damage *= (3.0 - (metal * GetAttributeValueF(victim, _, DMGDrainsMetal, DMGDrainsMetal_Mult, 0.0)));
				if(damage < 0.0) damage = 0.0;
				SetEntProp(victim, Prop_Data, "m_iAmmo", metal-RoundToFloor(metaldrain), 4, 3);
				if(GetEntProp(victim, Prop_Data, "m_iAmmo", 4, 3) < 0) SetEntProp(victim, Prop_Data, "m_iAmmo", 0, 4, 3);
				action = Plugin_Changed;
			}
		}
		if(NoCritBoost[weapon])
		{
			damagetype = damagetype - DMG_CRIT;
			action = Plugin_Changed;
		}
		if(SlownessOnHit[weapon])
		{
			SlownessOnHit_Dur[victim] = GetEngineTime();
			SlownessOnHit_MaxDur[victim] = SlownessOnHit_MaxDur[weapon];
			TF2Attrib_SetByName(victim, "move speed penalty", 1.0 - SlownessOnHit_Amount[weapon]);
			TF2_AddCondition(victim, TFCond_SpeedBuffAlly, 0.001);
		}
		if(AddcondOnBackstab[weapon] && damageCustom == TF_CUSTOM_BACKSTAB)
		{
			damage = 3.333;
			if(!TF2_IsPlayerInCondition(victim, TFCond:AddcondOnBackstab_ID[weapon]))
				TF2_AddCondition(victim, TFCond:AddcondOnBackstab_ID[weapon], AddcondOnBackstab_Dur[weapon]);
			action = Plugin_Changed;
		}
		/*
		if(GetAttributeValueF(victim, _, ElectroShock, ElectroShock_Charge) >= GetAttributeValueF(victim, _, ElectroShock, ElectroShock_MaxCharge) && (damagetype & DMG_CRIT) != DMG_CRIT && RoundFloat(damage) >= GetClientHealth(victim) && !TF2_IsPlayerInCondition(victim, TFCond_Slowed))   
		{
			new shocker = GetSlotContainingAttribute(victim, ElectroShock);
			ElectroShock_Dur[victim][shocker] = GetEngineTime();
			ElectroShock_Charge[victim][shocker] = 0.0;
			new melee = GetPlayerWeaponSlot(victim, 2);
			SetEntPropEnt(victim, Prop_Send, "m_hActiveWeapon", melee);
			EmitSoundToAll("vo/heavy_battlecry06.mp3", victim, SNDCHAN_VOICE, SNDLEVEL_SCREAMING);
			//EmitSoundToAll("player/invulnerable_on.wav", victim, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
			EmitSoundToAll("ambient/halloween/thunder_04.wav", victim, SNDCHAN_AUTO, SNDLEVEL_NORMAL);
			damage = 0.0;
			action = Plugin_Changed;
		}
		*/
		if(UncontainableReaction[weapon])
		{
			UncontainableReaction_Combo[weapon]++;
			if(UncontainableReaction_Combo[weapon] == 3)
			{
				MakeSlotSleep(victim, attacker, UncontainableReaction_Dur[weapon]);
				damage = 1.0;
				action = Plugin_Changed;
				UncontainableReaction_Combo[weapon] = 0;
			}
		}
		if(HeadshotsMinicrit[weapon] && damageCustom == TF_CUSTOM_HEADSHOT)
		{
			damagetype &= ~DMG_CRIT;
			TF2_AddCondition(victim, TFCond_MarkedForDeathSilent, 0.01);
			action = Plugin_Changed;
		}
	}
	if(damageCustom == TF_CUSTOM_BOOTS_STOMP)
	{
		if(HasAttribute(attacker, _, StompDmgMultiplier))
		{
			damage *= GetAttributeValueF(attacker, _, StompDmgMultiplier, StompDmgMultiplier_Mult);
			action = Plugin_Changed;
		}
		if(HasAttribute(attacker, _, SuperSlidersStomp))
		{
			new boots = GetSlotContainingAttribute(attacker, SuperSlidersStomp);
			
			damage *= 1.0 + (GetAttributeValueF(attacker, _, SuperSlidersStomp, SuperSlidersStomp_DamageMult) * GetAttributeValueF(attacker, _, SuperSlidersStomp, SuperSlidersStomp_Stacks));
			SuperSlidersStomp_Stacks[attacker][boots]++;
			if(SuperSlidersStomp_Stacks[attacker][boots] > SuperSlidersStomp_Max[attacker][boots]) 
				SuperSlidersStomp_Stacks[attacker][boots] = SuperSlidersStomp_Max[attacker][boots];
			
			SuperSlidersStomp_Stomp[attacker][boots] = true;
			
			action = Plugin_Changed;
		}
	}
	if(slot > -1 && EvasionOnHit[attacker][slot])
	{
		EvasionOnHit_Evasion[attacker][slot] += EvasionOnHit_Add[attacker][slot];
		if (EvasionOnHit_Evasion[attacker][slot] > 1.0)EvasionOnHit_Evasion[attacker][slot] = 1.0;
	}
	if(!(damagetype & DMG_CRUSH) || !(damagetype & TF_DMG_RADIANCE))
	{
		if(HasAttribute(victim, _, EvasionOnHit))
		{
			if(!HasAttribute(victim, _, EvasionOnHit_Active))
			{
				if(GetAttributeValueF(victim, _, EvasionOnHit, EvasionOnHit_Evasion) >= GetRandomFloat(0.0, 1.0))
				{
					new wep = GetSlotContainingAttribute(victim, EvasionOnHit);
					
					new Float:subtract = EvasionOnHit_Subtract[victim][wep];
					if(weapon == GetPlayerWeaponSlot(attacker, 2))subtract = EvasionOnHit_MeleeSubtract[victim][wep];
					EvasionOnHit_Evasion[victim][wep] -= damage / subtract / 100.0;
					
					damage = 0.0;
					if (EvasionOnHit_Evasion[victim][wep] < 0.0)EvasionOnHit_Evasion[victim][wep] = 0.0;
					ShowText(victim, "miss_text");
					action = Plugin_Changed;
				}
			}
			if(EvasionOnHit_Active[victim][slot2])
			{
				if(EvasionOnHit_Evasion[victim][slot2] >= GetRandomFloat(0.0, 1.0))
				{
					new Float:subtract = EvasionOnHit_Subtract[victim][slot2];
					if (weapon == GetPlayerWeaponSlot(attacker, 2))subtract = EvasionOnHit_MeleeSubtract[victim][slot2];
					EvasionOnHit_Evasion[victim][slot2] -= damage / subtract / 100.0;
					
					damage = 0.0;
					if (EvasionOnHit_Evasion[victim][slot2] < 0.0)EvasionOnHit_Evasion[victim][slot2] = 0.0;
					ShowText(victim, "miss_text");
					action = Plugin_Changed;
				}
			}
		}
	}
	if(GetEngineTime() <= SpyDetector_Dur[victim] + SpyDetector_MaxDur[victim])
	{
		damage *= SpyDetector_Vuln[victim] + 1.0;
		action = Plugin_Changed;
	}
	return action;
}

public Action:OnTakeDamageAlive(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3])
{
	if(victim <= 0) return Plugin_Continue;
	if(attacker <= 0) return Plugin_Continue;
	if(Client_IsValid(attacker) && Client_IsValid(victim) && attacker != victim && GetClientTeam(attacker) == GetClientTeam(victim)) return Plugin_Continue;
	if (!IsValidEdict(weapon))return Plugin_Continue;
	new Action:action;
	new wep = Client_GetActiveWeapon(victim);
	if(wep > -1 && UberDamageResistance[wep] && (damagetype & DMG_CRIT) != DMG_CRIT)
	{
		new Float:ubercharge = GetEntPropFloat(wep, Prop_Send, "m_flChargeLevel");
		new Float:resisteddmg = (damage * UberDamageResistance_DmgResist[wep]);
		if(resisteddmg >= ubercharge * 100.0)
		{
			resisteddmg = ubercharge * 100.0;
			SetEntPropFloat(wep, Prop_Send, "m_flChargeLevel", 0.0);
			damage -= resisteddmg;
		}
		else
		{
			SetEntPropFloat(wep, Prop_Send, "m_flChargeLevel", ubercharge - (resisteddmg / 100.0));
			damage -= resisteddmg;
		}
		action = Plugin_Changed;
	}
	if(GetEntProp(victim, Prop_Send, "m_nNumHealers") > 0)
	{
		for (new i = 1; i <= MaxClients; i++)
		{
			if ((damagetype & DMG_FALL) == DMG_FALL || (damagetype & DMG_CRUSH) == DMG_CRUSH)break;
			if(TF2_GetPlayerClass(attacker) == TFClass_Spy && (damagetype & TF_DMG_MELEE_CRIT == TF_DMG_MELEE_CRIT)) break;
			if (victim == i) continue;
			if (!IsValidClient(i)) continue;
			if (!IsPlayerAlive(i)) continue;
			if (victim != GetMediGunPatient(i))continue;
			new secondary = GetPlayerWeaponSlot(i, 1);
			if (!m_bSpreadDmg[secondary])continue;
			new linkdamage = RoundToFloor(damage * m_flSpreadDmg_Mult[secondary]);
			if (damagetype == TF_DMG_CRIT)linkdamage *= 3;
			new medichealth = GetClientHealth(i) - RoundToFloor(GetClientMaxHealth(i) * m_flSpreadDmg_MinHealth[secondary]);
			new safeguard = linkdamage - medichealth;
			if (safeguard > 0)linkdamage -= safeguard;
			new Float:newdamage = damage * (1.0 - m_flSpreadDmg_Mult[secondary]);
			if (damagetype == TF_DMG_CRIT)newdamage *= 1.666;
			if (safeguard > 0)newdamage += safeguard + RoundToFloor(GetClientMaxHealth(i) * m_flSpreadDmg_MinHealth[secondary]);
			if (damagetype == TF_DMG_CRIT)linkdamage /= 6;
			new String:attackerwep[50];
			GetEdictClassname(weapon, attackerwep, sizeof(attackerwep));
			damage = newdamage;
			Entity_Hurt(i, linkdamage, attacker, damagetype, attackerwep);
			action = Plugin_Changed;
			break;
		}
	}
	if(wep > -1 && m_bSpreadDmg[wep] && GetMediGunPatient(victim) > 0)
	{
		if ((damagetype & DMG_FALL) == DMG_FALL || (damagetype & DMG_CRUSH) == DMG_CRUSH)return Plugin_Continue;
		if(TF2_GetPlayerClass(attacker) == TFClass_Spy && (damagetype & TF_DMG_MELEE_CRIT == TF_DMG_MELEE_CRIT)) return Plugin_Continue;
		new patient = GetMediGunPatient(victim);
		new linkdamage = RoundToFloor(damage * m_flSpreadDmg_MultMedic[wep]);
		if (damagetype == TF_DMG_CRIT)linkdamage *= 3;
		new patienthealth = GetClientHealth(patient) - RoundToFloor(GetClientMaxHealth(patient) * m_flSpreadDmg_MinHealth[wep]);
		new safeguard = linkdamage - patienthealth;
		if (safeguard > 0)linkdamage -= safeguard;
		new Float:newdamage = damage * (1.0 - m_flSpreadDmg_MultMedic[wep]);
		if (damagetype == TF_DMG_CRIT)newdamage *= 1.666;
		if (safeguard > 0)newdamage += safeguard + RoundToFloor(GetClientMaxHealth(patient) * m_flSpreadDmg_MinHealth[wep]);
		if (damagetype == TF_DMG_CRIT)linkdamage /= 6;
		new String:attackerwep[50];
		GetEdictClassname(weapon, attackerwep, sizeof(attackerwep));
		damage = newdamage;
		Entity_Hurt(patient, linkdamage, attacker, damagetype, attackerwep);
		action = Plugin_Changed;
	}
	new slot = GetClientSlot(victim);
	new slot2 = GetClientSlot(attacker);
	if(TankGoodness[victim][slot] && TankGoodness_Level[victim][slot] < 6.0)
	{
		if(TankGoodness_ChargesIt[victim][slot] == 0 || TankGoodness_ChargesIt[victim][slot] == 1)
		{
			TankGoodness_Charge[victim][slot] += (damage * TankGoodness_ChargeMult[victim][slot]);
		}
		
		if(TankGoodness_Charge[victim][slot] >= TankGoodness_MaxCharge[victim][slot] + (TankGoodness_ChargePerLvl[victim][slot] * TankGoodness_Level[victim][slot]))
		{
			TankGoodness_Level[victim][slot]++;
			if(TankGoodness_Level[victim][slot] == 1.0)
			{
				TF2Attrib_SetByName(wep, "maxammo primary increased", TankGoodness_MaxAmmo[victim][slot]);
				EmitSoundToAll("items/powerup_pickup_haste.wav", victim, SNDCHAN_WEAPON, 95);
			}
			if(TankGoodness_Level[victim][slot] == 2.0)
			{
				TF2Attrib_SetByName(wep, "heal on kill", TankGoodness_HPOnKill[victim][slot]);
				EmitSoundToAll("items/powerup_pickup_haste.wav", victim, SNDCHAN_WEAPON, 95);
			}
			if(TankGoodness_Level[victim][slot] == 3.0)
			{
				TF2Attrib_SetByName(wep, "health from healers increased", TankGoodness_BonusHealing[victim][slot]);
				TF2Attrib_SetByName(wep, "health from packs increased", TankGoodness_BonusHealing[victim][slot]);
				EmitSoundToAll("items/powerup_pickup_haste.wav", victim, SNDCHAN_WEAPON, 95);
			}
			if(TankGoodness_Level[victim][slot] == 4.0)
			{
				TF2Attrib_SetByName(wep, "damage force reduction", TankGoodness_KnockbackResist[victim][slot]);
				TF2Attrib_SetByName(wep, "airblast vulnerability multiplier", TankGoodness_KnockbackResist[victim][slot]);
				TF2Attrib_SetByName(wep, "airblast vertical vulnerability multiplier", TankGoodness_KnockbackResist[victim][slot]);
				EmitSoundToAll("items/powerup_pickup_haste.wav", victim, SNDCHAN_WEAPON, 95);
			}
			if(TankGoodness_Level[victim][slot] == 5.0)
			{
				TF2Attrib_SetByName(wep, "attack projectiles", 2.0);
				EmitSoundToAll("items/powerup_pickup_haste.wav", victim, SNDCHAN_WEAPON, 95);
			}
			if(TankGoodness_Level[victim][slot] == 6.0)
			{
				TF2Attrib_SetByName(wep, "generate rage on damage", 3.0);
				EmitSoundToAll("items/powerup_pickup_haste.wav", victim, SNDCHAN_WEAPON, 95);
			}
			TF2_AddCondition(victim, TFCond:45, TankGoodness_MinResistDur[victim][slot] + (TankGoodness_ResistDurPerLvl[victim][slot] * TankGoodness_Level[victim][slot]));
			TankGoodness_Charge[victim][slot] = 0.0;
		}
	}
	if(slot2 > -1 && TankGoodness[attacker][slot2] && TankGoodness_Level[attacker][slot2] < 6.0)
	{
		if(TankGoodness_ChargesIt[attacker][slot2] == 0 || TankGoodness_ChargesIt[attacker][slot2] == 2)
		{
			TankGoodness_Charge[attacker][slot2] += (damage * TankGoodness_ChargeMult[attacker][slot2]);
		}
		
		if(TankGoodness_Charge[attacker][slot2] >= TankGoodness_MaxCharge[attacker][slot2] + (TankGoodness_ChargePerLvl[attacker][slot2] * TankGoodness_Level[attacker][slot2]))
		{
			TankGoodness_Level[attacker][slot2]++;
			if(TankGoodness_Level[attacker][slot2] == 1.0)
			{
				TF2Attrib_SetByName(weapon, "maxammo primary increased", TankGoodness_MaxAmmo[attacker][slot2]);
				EmitSoundToAll("items/powerup_pickup_haste.wav", attacker, SNDCHAN_WEAPON, 95);
			}
			if(TankGoodness_Level[attacker][slot2] == 2.0)
			{
				TF2Attrib_SetByName(weapon, "heal on kill", TankGoodness_HPOnKill[attacker][slot2]);
				EmitSoundToAll("items/powerup_pickup_haste.wav", attacker, SNDCHAN_WEAPON, 95);
			}
			if(TankGoodness_Level[attacker][slot2] == 3.0)
			{
				TF2Attrib_SetByName(weapon, "health from packs increased", TankGoodness_BonusHealing[attacker][slot2]);
				TF2Attrib_SetByName(weapon, "health from healers increased", TankGoodness_BonusHealing[attacker][slot2]);
				EmitSoundToAll("items/powerup_pickup_haste.wav", attacker, SNDCHAN_WEAPON, 95);
			}
			if(TankGoodness_Level[attacker][slot2] == 4.0)
			{
				TF2Attrib_SetByName(weapon, "damage force reduction", TankGoodness_KnockbackResist[attacker][slot2]);
				TF2Attrib_SetByName(weapon, "airblast vulnerability multiplier", TankGoodness_KnockbackResist[attacker][slot2]);
				TF2Attrib_SetByName(weapon, "airblast vertical vulnerability multiplier", TankGoodness_KnockbackResist[attacker][slot2]);
				EmitSoundToAll("items/powerup_pickup_haste.wav", attacker, SNDCHAN_WEAPON, 95);
			}
			if(TankGoodness_Level[attacker][slot2] == 5.0)
			{
				TF2Attrib_SetByName(weapon, "attack projectiles", 2.0);
				EmitSoundToAll("items/powerup_pickup_haste.wav", attacker, SNDCHAN_WEAPON, 95);
			}
			if(TankGoodness_Level[attacker][slot2] == 6.0)
			{
				TF2Attrib_SetByName(weapon, "generate rage on damage", 3.0);
				EmitSoundToAll("items/powerup_pickup_haste.wav", attacker, SNDCHAN_WEAPON, 95);
			}
			TankGoodness_Charge[attacker][slot2] = 0.0;
			TF2_AddCondition(attacker, TFCond:45, TankGoodness_MinResistDur[attacker][slot2] + (TankGoodness_ResistDurPerLvl[attacker][slot2] * TankGoodness_Level[attacker][slot2]));
		}
	}
	/*
	if(HasAttribute(attacker, _, ElectroShock) && GetEngineTime() >= GetAttributeValueF(attacker, _, ElectroShock, ElectroShock_Charge))
	{
		new shocker = GetSlotContainingAttribute(attacker, ElectroShock);
		ElectroShock_Charge[attacker][shocker] += damage;
		if (ElectroShock_Charge[attacker][shocker] > ElectroShock_MaxCharge[attacker][shocker])ElectroShock_Charge[attacker][shocker] = ElectroShock_MaxCharge[attacker][shocker];
	}
	*/
	new sec = GetPlayerWeaponSlot(victim, 1);
	if(weapon > -1 && DrainVictimAmmo[weapon])
	{
		new PrimaryAmmo = GetAmmo(victim, 0);
		new SecondaryAmmo = GetAmmo(victim, 1);
		new Metal = GetClientMetal(victim);
		if(TF2_GetPlayerClass(victim) == TFClass_Spy)
		{
			new Float:Cloak = GetEntPropFloat(victim, Prop_Send, "m_flCloakMeter");
			SetEntPropFloat(victim, Prop_Send, "m_flCloakMeter", (Cloak - (Cloak * (DrainVictimAmmo_Cloak[weapon] * (damage / 100.0)))));
		}
		if(TF2_GetPlayerClass(victim) == TFClass_Medic)
		{
			new Float:Ubercharge = GetEntPropFloat(GetPlayerWeaponSlot(victim, 1), Prop_Send, "m_flChargeLevel");
			SetEntPropFloat(GetPlayerWeaponSlot(victim, 1), Prop_Send, "m_flChargeLevel", (Ubercharge - (Ubercharge * (DrainVictimAmmo_Ubercharge[weapon] * (damage / 100.0)))));
		}
		new Float:Rage = GetEntPropFloat(victim, Prop_Send, "m_flRageMeter");
		SetAmmo(victim, 0, PrimaryAmmo - RoundFloat(PrimaryAmmo * (DrainVictimAmmo_Primary[weapon] * (damage / 100.0))));
		SetAmmo(victim, 1, SecondaryAmmo - RoundFloat(SecondaryAmmo * (DrainVictimAmmo_Secondary[weapon] * (damage / 100.0))));
		SetClientMetal(victim, Metal - RoundFloat(Metal * (DrainVictimAmmo_Metal[weapon] * (damage / 100.0))));
		SetEntPropFloat(victim, Prop_Send, "m_flRageMeter", (Rage - (Rage * (DrainVictimAmmo_Rage[weapon] * (damage / 100.0)))));
	}
	if(IronBoarder[weapon] && GetPlayerWeaponSlot(attacker, 1) == -1)
	{
		new Float:chargemeter = GetEntPropFloat(attacker, Prop_Send, "m_flChargeMeter");
		chargemeter += IronBoarder_ShieldRecharge[weapon];
		if (chargemeter > 100.0)chargemeter = 100.0;
		if (chargemeter < 0.0)chargemeter = 0.0;
		SetEntPropFloat(attacker, Prop_Send, "m_flChargeMeter", chargemeter);
	}
	return action;
}

public OnTakeDamagePost(victim, attacker, inflictor, Float:damage, damagetype, weapon, const Float:damageForce[3], const Float:damagePosition[3], damageCustom)
{
	if (attacker <= 0 || attacker > MaxClients)return;
	if (victim <= 0 || victim > MaxClients)return;
	if (weapon <= 0 || weapon > 2049)return;
	new secondary = GetPlayerWeaponSlot(attacker, 1);
	new melee = GetPlayerWeaponSlot(attacker, 2);
	if(secondary > -1 && weapon > -1 && UberRateKill[weapon] && TF2_GetPlayerClass(attacker) == TFClass_Medic)
	{
		TF2Attrib_RemoveByName(secondary, "ubercharge rate penalty");
		UberRateKill_Stacks[weapon]++;
		UberRateKill_Hearts[weapon]++;
		if(UberRateKill_Stacks[weapon] > UberRateKill_MaxStacks[weapon]) UberRateKill_Stacks[weapon] = UberRateKill_MaxStacks[weapon];
		new Float:uberbonus = ((UberRateKill_Bonus[weapon] * UberRateKill_Stacks[weapon]) + 1.0);
		TF2Attrib_SetByName(secondary, "ubercharge rate penalty", uberbonus);
	}
	if(attacker > 0 && victim > 0 && HasAttribute(attacker, _, MilkOnHit))
	{
		if(!TF2_IsPlayerInCondition(victim, TFCond_Jarated)) 
			EmitSoundToClient(victim, "jar_explode.wav", victim);
		TF2_AddCondition(victim, TFCond_Jarated, GetAttributeValueF(attacker, _, MilkOnHit, MilkOnHit_Dur), attacker);
	}
	if(KillsChargeItems[weapon])
	{
		new Float:meter1, Float:meter2;
		if(secondary > -1)
			meter1 = GetEntPropFloat(secondary, Prop_Send, "m_flEffectBarRegenTime");
			
		if(melee > -1)
			meter2 = GetEntPropFloat(melee, Prop_Send, "m_flEffectBarRegenTime");
			
		new Float:recharge = KillsChargeItems_Mult[weapon] * ((damage / 6.0) / 10.0);
		SetEntPropFloat(secondary, Prop_Send, "m_flEffectBarRegenTime", meter1 - recharge); 
		SetEntPropFloat(melee, Prop_Send, "m_flEffectBarRegenTime", meter2 - recharge); 
		if(GetEntPropFloat(secondary, Prop_Send, "m_flEffectBarRegenTime") < 0.0) SetEntPropFloat(secondary, Prop_Send, "m_flEffectBarRegenTime", 0.0);
		if(GetEntPropFloat(melee, Prop_Send, "m_flEffectBarRegenTime") < 0.0) SetEntPropFloat(melee, Prop_Send, "m_flEffectBarRegenTime", 0.0);
	}
	if(m_bCondimentCannon[weapon])
	{
		if (GetClip_Weapon(weapon) == 4)TF2_AddCondition(victim, TFCond:m_iCondimentCannon_Cond1[weapon], m_flCondimentCannon_Dur[weapon]);
		if (GetClip_Weapon(weapon) == 3)TF2_MakeBleed(victim, attacker, m_flCondimentCannon_Dur[weapon]);
		if (GetClip_Weapon(weapon) == 2)TF2_AddCondition(victim, TFCond:m_iCondimentCannon_Cond3[weapon], m_flCondimentCannon_Dur[weapon]);
		if (GetClip_Weapon(weapon) == 1)TF2_IgnitePlayer(victim, attacker);
	}
	if(m_bGainCondOnHit[weapon])
	{
		TF2_AddCondition(attacker, TFCond:m_iGainCondOnHit_Cond[weapon], m_flGainCondOnHit_Dur[weapon]);
	}
	if(HasAttribute(attacker, _, bCritsOnSapperRemoved))
	{
		new slot2 = GetSlotContainingAttribute(attacker, bCritsOnSapperRemoved);
		if(iCritsOnSapperRemoved_Crits[attacker][slot2] > 0)
			iCritsOnSapperRemoved_Crits[attacker][slot2]--;
	}
	if(RemoveBleed[victim])
	{
		TF2_RemoveCondition(victim, TFCond_Bleeding);
		RemoveBleed[victim] = false;
	}
	
	CombatTime[victim] = GetEngineTime();
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:ang[3], &weapon2)
{
	new weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if (weapon <= 0 || weapon > 2048) return Plugin_Continue;
	new slot = GetClientSlot(client);
	if(!IsValidEdict(slot) || slot < 0 || slot > 2048) return Plugin_Continue;
	if(HammerMechanic[weapon])
	{
		if((buttons & IN_ATTACK3) == IN_ATTACK3)
		{
			if(HammerMechanic_Fann[weapon] == false && GetEngineTime() >= HammerMechanic_Wait[weapon] + 1.0)
			{
				HammerMechanic_Fann[weapon] = true;
				if(HammerMechanic_x10[weapon] == 0)
				{
					TF2Attrib_SetByName(weapon, "fire rate bonus", 1.0 - HammerMechanic_FireRate[weapon]);
					TF2Attrib_SetByName(weapon, "Reload time decreased", 1.0 - HammerMechanic_ReloadRate[weapon]);
					TF2Attrib_SetByName(weapon, "move speed penalty", 1.0 -HammerMechanic_MoveSpeed[weapon]);
					TF2Attrib_SetByName(weapon, "damage penalty", 1.0 -HammerMechanic_Damage[weapon]);
				}
				if(HammerMechanic_x10[weapon] == 1)
				{
					TF2Attrib_SetByName(weapon, "fire rate bonus", 1.0 - HammerMechanic_FireRate[weapon] * 2);
					TF2Attrib_SetByName(weapon, "Reload time decreased", 1.0 - HammerMechanic_ReloadRate[weapon] * 2);
					TF2Attrib_SetByName(weapon, "move speed penalty", 1.0 - HammerMechanic_MoveSpeed[weapon] * 2);
					TF2Attrib_SetByName(weapon, "damage penalty", 1.0 - HammerMechanic_Damage[weapon] * 2);
				}
				TF2Attrib_RemoveByName(weapon, "Projectile speed increased");
				TF2Attrib_RemoveByName(weapon, "single wep deploy time decreased");
				TF2Attrib_RemoveByName(weapon, "switch from wep deploy time decreased");
				TF2Attrib_RemoveByName(weapon, "sticky air burst mode");
				EmitSoundToClient(client, "weapons/vaccinator_toggle.wav");
				TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
				HammerMechanic_Wait[weapon] = GetEngineTime();
			}
			else if(HammerMechanic_Fann[weapon] == true && GetEngineTime() >= HammerMechanic_Wait[weapon] + 1.0)
			{
				HammerMechanic_Fann[weapon] = false;
				TF2Attrib_RemoveByName(weapon, "fire rate bonus");
				TF2Attrib_RemoveByName(weapon, "move speed penalty");
				TF2Attrib_RemoveByName(weapon, "damage penalty");
				if(HammerMechanic_x10[weapon] == 0)
				{
					TF2Attrib_SetByName(weapon, "single wep deploy time decreased", 1.0 - HammerMechanic_SwitchSpeed[weapon]);
					TF2Attrib_SetByName(weapon, "switch from wep deploy time decreased", 1.0 - HammerMechanic_SwitchSpeed[weapon]);
					TF2Attrib_SetByName(weapon, "Projectile speed increased", 1.0 + HammerMechanic_ProjectileSpeed[weapon]);
					TF2Attrib_SetByName(weapon, "sticky air burst mode", HammerMechanic_ProjectilesShatter[weapon]);
				}
				if(HammerMechanic_x10[weapon] == 1)
				{
					TF2Attrib_SetByName(weapon, "single wep deploy time decreased", 1.0 - HammerMechanic_SwitchSpeed[weapon] * 2);
					TF2Attrib_SetByName(weapon, "switch from wep deploy time decreased", 1.0 - HammerMechanic_SwitchSpeed[weapon] * 2);
					TF2Attrib_SetByName(weapon, "Projectile speed increased", 1.0 + HammerMechanic_ProjectileSpeed[weapon] * 2);
					TF2Attrib_SetByName(weapon, "sticky air burst mode", HammerMechanic_ProjectilesShatter[weapon]);
				}
				EmitSoundToClient(client, "weapons/vaccinator_toggle.wav");
				TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
				HammerMechanic_Wait[weapon] = GetEngineTime();
			}
		}
		if(HammerMechanic_Fann[weapon] == true)
		{
			SetHudTextParams(-1.0, 0.7, 0.2, 255, 255, 255, 255);
			ShowSyncHudText(client, hudText_Client, "Firing Mode: Hammer");
		}
		else if(HammerMechanic_Fann[weapon] == false)
		{
			SetHudTextParams(-1.0, 0.7, 0.2, 255, 255, 255, 255);
			ShowSyncHudText(client, hudText_Client, "Firing Mode: Trigger");
		}
	}
	if(BoosterShotUber[weapon] && GetEntProp(weapon, Prop_Send, "m_bChargeRelease") && GetClientHealth(client) < GetClientMaxHealth(client) * 2.5 && GetEngineTime() >= BoosterShotUber_HealDelay[weapon] + 0.0303030303)
	{
		if(BoosterShotUber_x10[weapon] == 0)
		{
			SetEntityHealth(client, GetClientHealth(client) + 1);
			BoosterShotUber_HealDelay[weapon] = GetEngineTime();
		}
		else if(BoosterShotUber_x10[weapon] == 1)
		{
			SetEntityHealth(client, GetClientHealth(client) + 2);
			BoosterShotUber_HealDelay[weapon] = GetEngineTime();
		}
	}
	
	new Action:action;
	return action;
}

public Action:Event_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	new bool:feign = bool:(GetEventInt(event, "death_flags") & TF_DEATHFLAG_DEADRINGER);
	if (attacker)
	{
		new melee = GetPlayerWeaponSlot(attacker, 2);
		new secondary = GetPlayerWeaponSlot(attacker, 1);
		new weapon = LastWeaponHurtWith[attacker];
		new slot = GetClientSlot(attacker);
		if (slot > -1 && m_bHasAttribute[attacker][slot])
		{
			if(FasterReloadKill[weapon] && attacker != victim && !feign)
			{
				TF2Attrib_RemoveByName(weapon, "faster reload rate");
				FasterReloadKill_Stacks[weapon]++;
				if(FasterReloadKill_Stacks[weapon] > FasterReloadKill_MaxStacks[weapon]) FasterReloadKill_Stacks[weapon] = FasterReloadKill_MaxStacks[weapon];
				new Float:reloadrate = (FasterReloadKill_Spd[weapon] * FasterReloadKill_Stacks[weapon] + 1);
				TF2Attrib_SetByName(weapon, "faster reload rate", reloadrate);
			}
			if(LargerMeleeRangeOnKill[weapon] && attacker != victim && !feign)
			{
				TF2Attrib_RemoveByName(melee, "melee range multiplier");
				TF2Attrib_RemoveByName(melee, "melee bounds multiplier");
				LargerMeleeRangeOnKill_Dur[attacker] = LargerMeleeRangeOnKill_MaxDur[weapon];
				TF2Attrib_SetByName(melee, "melee range multiplier", LargerMeleeRangeOnKill_Range[weapon]);
				TF2Attrib_SetByName(melee, "melee bounds multiplier", LargerMeleeRangeOnKill_Bounds[weapon]);
			}
			if (SentryResOnKill[attacker][slot] && attacker != victim && !feign)
			{
				SentryResOnKill_Dur[attacker] = SentryResOnKill_Dur[weapon];
			}
			if(CraftingOnKill[weapon] && attacker != victim && !feign)
			{
				TF2Attrib_RemoveByName(weapon, "move speed bonus");
				TF2Attrib_RemoveByName(weapon, "damage penalty");
				CraftingOnKill_Stacks[attacker]++;
				if(CraftingOnKill_Stacks[attacker] > CraftingOnKill_MaxStacks[attacker]) CraftingOnKill_Stacks[attacker] = CraftingOnKill_MaxStacks[attacker];
				new Float:movespd = (1.0 + (CraftingOnKill_Movespd[weapon] * CraftingOnKill_Stacks[attacker]));
				new Float:dmgpen = (1.0 - (CraftingOnKill_Dmgpen[weapon] * CraftingOnKill_Stacks[attacker]));
				TF2Attrib_SetByName(weapon, "move speed bonus", movespd);
				TF2Attrib_SetByName(weapon, "damage penalty", dmgpen);
				TF2_AddCondition(attacker, TFCond_SpeedBuffAlly, 0.001);
			}
			if(AimMoveSpdOnKill[weapon] && attacker != victim && !feign)
			{
				AimMoveSpdOnKill_Dur[weapon] = GetEngineTime();
			}
			if(MeleeRangeKillStack[weapon] && attacker != victim && MeleeRangeKillStack_Stacks[weapon] < MeleeRangeKillStack_MaxStacks[weapon])
			{
				MeleeRangeKillStack_Stacks[weapon]++;
				new Float:meleerange = MeleeRangeKillStack_Range[weapon] * MeleeRangeKillStack_Stacks[weapon] + 1.0;
				new Float:meleebounds = MeleeRangeKillStack_Bounds[weapon] * MeleeRangeKillStack_Stacks[weapon] + 1.0;
				TF2Attrib_SetByName(weapon, "melee range multiplier", meleerange);
				TF2Attrib_SetByName(weapon, "melee bounds multiplier", meleebounds);
			}
			if(SpeedOnKill[weapon])
			{
				TF2Attrib_RemoveByName(weapon, "CARD: move speed bonus");
				TF2Attrib_SetByName(weapon, "CARD: move speed bonus", 1.0 + SpeedOnKill_Mult[weapon]);
				SpeedOnKill_Dur[attacker] = GetEngineTime();
				TF2_AddCondition(attacker, TFCond_SpeedBuffAlly, 0.001);
			}
			if(secondary > -1 && SecondaryKillChargesMelee[secondary] && weapon == secondary)
			{
				SecondaryKillChargesMelee_Kill[secondary] = true;
			}
			if(melee > -1 && MeleeKillChargesSecondary[melee] && weapon == melee)
			{
				MeleeKillChargesSecondary_Kill[melee] = true;
			}
			if(AddcondOnKill[weapon])
			{
				TF2_AddCondition(attacker, TFCond:AddcondOnKill_ID1[weapon], AddcondOnKill_Dur[weapon]);
				TF2_AddCondition(attacker, TFCond:AddcondOnKill_ID2[weapon], AddcondOnKill_Dur[weapon]);
				TF2_AddCondition(attacker, TFCond:AddcondOnKill_ID3[weapon], AddcondOnKill_Dur[weapon]);
			}
		}
	}
	if(HasAttribute(victim, _, MilkExplosionOnDeath))
	{
		ApplyRadiusEffects(victim, _, _, GetAttributeValueF(victim, _, MilkExplosionOnDeath, MilkExplosionOnDeath_Radius), _, _, 24, _, GetAttributeValueF(victim, _, MilkExplosionOnDeath, MilkExplosionOnDeath_Dur), _, 2, _, "peejar_impact");  
	}
	TF2Attrib_RemoveByName(victim, "halloween increased jump height");
}

public Action:OnObjectDestroyed(Handle:event, const String:name[], bool:dontBroadcast)
{
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	new owner = GetClientOfUserId(GetEventInt(event, "userid"));
	new buildingType = GetEventInt(event, "objecttype");
	if(HasAttribute(attacker, _, bCritsOnSapperRemoved) && buildingType == 3)
	{
		new slot = GetSlotContainingAttribute(attacker, bCritsOnSapperRemoved);
		iCritsOnSapperRemoved_Crits[attacker][slot] += iCritsOnSapperRemoved_Add[attacker][slot];
		if(iCritsOnSapperRemoved_Crits[attacker][slot] > iCritsOnSapperRemoved_Cap[attacker][slot])
			iCritsOnSapperRemoved_Crits[attacker][slot] = iCritsOnSapperRemoved_Cap[attacker][slot];
	}
	if(buildingType == 1)
	{
		if (owner <= 0 || owner > MaxClients || !IsClientInGame(owner) || !IsPlayerAlive(owner))return;
		new weapon;
		for (new i = 0; i < 3; i++)
		{
			weapon = GetPlayerWeaponSlot(owner, i);
			if (weapon > -1 && ShellshockAttrib[weapon])break;
		}
		ShellshockAttrib_Teleports[weapon] = 0.0;
		TF2Attrib_RemoveByName(weapon, "fire rate bonus");
	}
}
public Action:OnObjectDetonated(Handle:event, const String:name[], bool:dontBroadcast)
{
	new owner = GetClientOfUserId(GetEventInt(event, "userid"));
	new building = GetEventInt(event, "userid");
	new buildingType = GetEventInt(event, "objecttype");
	if(buildingType == 1)
	{
		if (owner <= 0 || owner > MaxClients || !IsClientInGame(owner) || !IsPlayerAlive(owner))return;
		new weapon;
		for (new i = 0; i < 3; i++)
		{
			weapon = GetPlayerWeaponSlot(owner, i);
			if (weapon > -1 && ShellshockAttrib[weapon])break;
		}
		ShellshockAttrib_Teleports[weapon] = 0.0;
		TF2Attrib_RemoveByName(weapon, "fire rate bonus");
	}
}

public Action:OnPlayerTeleport(Handle:hEvent, const String:strName[], bool:bDontBroadcast)
{
	new owner = GetClientOfUserId(GetEventInt(hEvent, "builderid"));
	if (owner <= 0 || owner > MaxClients || !IsClientInGame(owner) || !IsPlayerAlive(owner))return;
	new weapon;
	for (new i = 0; i < 3; i++)
	{
		weapon = GetPlayerWeaponSlot(owner, i);
		if (weapon > -1 && ShellshockAttrib[weapon])break;
	}
	if(weapon > -1)
	{
		ShellshockAttrib_Teleports[weapon]++;
		if(ShellshockAttrib_Teleports[weapon] > ShellshockAttrib_Max[weapon]) 
			ShellshockAttrib_Teleports[weapon] = ShellshockAttrib_Max[weapon];
		TF2Attrib_SetByName(weapon, "fire rate bonus", ShellshockAttrib_Teleports[weapon] * ShellshockAttrib_Amount[weapon] + 1.0);
	}
	return;
}

public Action:Event_Respawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!Client_IsValid(client)) return;
	SpeedOnKill_MaxDur[client] = 0.0;
	SpeedOnKill_Dur[client] = 0.0;
	TF2Attrib_RemoveByName(client, "halloween increased jump height");
}

public TF2_OnConditionAdded(client, TFCond:cond)
{
	if(cond == TFCond_Cloaked)
	{
		if(HasAttribute(client, _, RemoveDebuffsWhileCloaked))
		{
			CloakRemoveStatus[client] = GetEngineTime();
		}
	}
	if(HasAttribute(client, _, m_bReduceDebuffDur))
	{
		new slot = GetSlotContainingAttribute(client, m_bReduceDebuffDur);
		if(cond == TFCond_Jarated)
			m_flReduceDebuffDur_Jarate[client][slot] = GetEngineTime();
		if(cond == TFCond_Milked)
			m_flReduceDebuffDur_Milk[client][slot] = GetEngineTime();
		if (cond == TFCond_Bleeding)
			m_flReduceDebuffDur_Bleed[client][slot] = GetEngineTime();
		if(cond == TFCond_Dazed)
			m_flReduceDebuffDur_Dazed[client][slot] = GetEngineTime();
		if(cond == TFCond_OnFire)
			m_flReduceDebuffDur_OnFire[client][slot] = GetEngineTime();
		if(cond == TFCond_MarkedForDeath)
			m_flReduceDebuffDur_MarkedForDeath[client][slot] = GetEngineTime();
	}
}

public Action:Event_Ubercharge(Handle:event, const String:name[], bool:dontBroadcast)
{
	new medic = GetClientOfUserId(GetEventInt(event, "userid"));
	new medigun = GetPlayerWeaponSlot(medic, 1);
	new primary = GetPlayerWeaponSlot(medic, 0);
	new melee = GetPlayerWeaponSlot(medic, 2);
	if(TF2_GetPlayerClass(medic) == TFClass_Medic) {
	
		if(UberRateKill[primary] || UberRateKill[melee])
		{
			new item;
			if (UberRateKill[primary])item = GetPlayerWeaponSlot(medic, 0);
			if (UberRateKill[melee])item = GetPlayerWeaponSlot(medic, 2);
			UberRateKill_Stacks[item] -= UberRateKill_Subtract[item];
			UberRateKill_Hearts[item] -= UberRateKill_Subtract[item];
			if(UberRateKill_Stacks[item] < 0) UberRateKill_Stacks[item] = 0;
			if(UberRateKill_Hearts[item] < 0) UberRateKill_Hearts[item] = 0;
			TF2Attrib_RemoveByName(item, "ubercharge rate penalty");
			TF2Attrib_SetByName(medigun, "ubercharge rate penalty", ((UberRateKill_Bonus[item] * UberRateKill_Stacks[item]) + 1.0));
		}
	}
}

public Action:OnWeaponSwitch(client, weapon)
{
	if (!IsValidClient(client))return Plugin_Continue;
	if (weapon <= 0)return Plugin_Continue;
	
	new health = GetClientHealth(client);
	if(HealOnSheath_Sheathed[client] != 0 && !HealOnSheath[weapon])
	{
		SetEntityHealth(client, health + HealOnSheath_Sheathed[client]);
		if(HealOnSheath_Cap[client] >= 1.0 && GetClientHealth(client) > GetClientMaxHealth(client) * HealOnSheath_Cap[client])
			SetEntityHealth(client, RoundToFloor(GetClientMaxHealth(client) * HealOnSheath_Cap[client]));
		if(GetClientHealth(client) <= 0)
			AcceptEntityInput(client, "Kill");
		
		HealOnSheath_Sheathed[client] = 0;
	}
	if(HealOnSheath[weapon])
	{
		if (HealOnSheath_HP[weapon] != 0)HealOnSheath_Sheathed[client] = HealOnSheath_HP[weapon];
		else if (HealOnSheath_Mult[weapon] != 0.0)HealOnSheath_Sheathed[client] = RoundToFloor(health * HealOnSheath_Mult[weapon]);
	}
	
	if(HealOnDraw[weapon])
	{
		if(HealOnDraw_HP[weapon] < 0 || HealOnDraw_Mult[weapon] < 0.0)
		{
			if(HealOnDraw_HP[weapon] != 0)
				Entity_Hurt(client, HealOnDraw_HP[weapon], client, DMG_CLUB);
			if(HealOnDraw_Mult[weapon] != 0.0)
				Entity_Hurt(client, RoundToFloor(health + (GetClientMaxHealth(client) * HealOnDraw_Mult[weapon])), client, DMG_CLUB);
		}
		else
		{
			if(HealOnDraw_HP[weapon] != 0)
				SetEntityHealth(client, health + HealOnDraw_HP[weapon]);
			if(HealOnDraw_Mult[weapon] != 0.0)
				SetEntityHealth(client, RoundToFloor(health + (GetClientMaxHealth(client) * HealOnDraw_Mult[weapon])));
			if(HealOnDraw_Cap[client] >= 1.0 && GetClientHealth(client) > GetClientMaxHealth(client) * HealOnDraw_Cap[client])
				SetEntityHealth(client, RoundToFloor(GetClientMaxHealth(client) * HealOnDraw_Cap[client]));
		}
	}
	return Plugin_Continue;
}

public OnClientPreThink(client)
{
	if(GetEngineTime() >= LastTick[client] + 0.1)
	{
		Attributes_Prethink(client);
		LastTick[client] = GetEngineTime();
	}
	Ubercharge_Prethink(client);
}

stock Attributes_Prethink(client)
{
	if (IsValidClient(client) && IsPlayerAlive(client))
	{
		new slot = GetClientSlot(client);
		new primary = GetPlayerWeaponSlot(client, 0);
		new secondary = GetPlayerWeaponSlot(client, 1);
		new melee = GetPlayerWeaponSlot(client, 2);
		new wep = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
		if(wep == -1) return;
		
		if (SentryResOnKill_Dur[client] >= 0.1)
		{
			new Float:sentres = GetAttributeValueF(client, _, SentryResOnKill, SentryResOnKill_Resist, 1.0);
			new Float:knockres = GetAttributeValueF(client, _, SentryResOnKill, SentryResOnKill_KnockRes, 1.0);
			TF2Attrib_SetByName(client, "SET BONUS: dmg from sentry reduced", sentres);
			TF2Attrib_SetByName(client, "damage force reduction", knockres);
			TF2Attrib_SetByName(client, "airblast vulnerability multiplier", knockres);
			if(sentres < 1) TF2_AddCondition(client, TFCond:61, 0.2);
			SentryResOnKill_Dur[client] -= 0.1;
		}
		else
		{
			TF2Attrib_RemoveByName(client, "SET BONUS: dmg from sentry reduced");
			TF2Attrib_RemoveByName(client, "damage force reduction");
			TF2Attrib_RemoveByName(client, "airblast vulnerability multiplier");
		}
		if(HasAttribute(client, _, MissingHealthJumpHeight) && GetClientHealth(client) <= GetClientMaxHealth(client)) {
			
			TF2Attrib_RemoveByName(client, "halloween increased jump height");
			new Float:jumpheight = 1.0 + ((GetClientMaxHealth(client) - GetClientHealth(client)) * GetAttributeValueF(client, _, MissingHealthJumpHeight, MissingHealthJumpHeight_Mult, 0.0) / 100.0);
			TF2Attrib_SetByName(client, "halloween increased jump height", jumpheight);
		}
		if(HasAttribute(client, _, MissingHealthUberBonus) && GetClientHealth(client) <= GetClientMaxHealth(client) && TF2_GetPlayerClass(client) == TFClass_Medic) {
			new sec = GetPlayerWeaponSlot(client, 1);
			TF2Attrib_RemoveByName(sec, "ubercharge rate bonus");
			new Float:uberrate = 1.0 + ((GetClientMaxHealth(client) - GetClientHealth(client)) * GetAttributeValueF(client, _, MissingHealthUberBonus, MissingHealthUberBonus_Mult, 0.0) / 100.0);
			TF2Attrib_SetByName(sec, "ubercharge rate bonus", uberrate);
		}
		if(MissingHealthFasterMovement[client][slot] && GetClientHealth(client) <= GetClientMaxHealth(client)) 
		{
			TF2Attrib_RemoveByName(wep, "move speed bonus");
			new Float:movespd = 1.0 + ((GetClientMaxHealth(client) - GetClientHealth(client)) * GetAttributeValueF(client, _, MissingHealthFasterMovement, MissingHealthFasterMovement_Mult) / 100.0);
			TF2Attrib_SetByName(wep, "move speed bonus", movespd);
			TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
		}
		if(HasAttribute(client, _, AddcondCharging) && TF2_IsPlayerInCondition(client, TFCond_Charging))
		{
			TF2_AddCondition(client, TFCond:GetAttributeValueF(client, _, AddcondCharging, AddcondCharging_ID, 0), 0.2);
			TF2_AddCondition(client, TFCond:GetAttributeValueF(client, _, AddcondCharging, AddcondCharging_ID2, 0), 0.2);
		}
		if(HasAttribute(client, _, RemoveDebuffsWhileCloaked) && GetEngineTime() < CloakRemoveStatus[client] + GetAttributeValueF(client, _, RemoveDebuffsWhileCloaked, CloakRemoveStatus_Dur, 0.0))
		{
			TF2_RemoveCondition(client, TFCond_OnFire);
			TF2_RemoveCondition(client, TFCond_MarkedForDeath);
			TF2_RemoveCondition(client, TFCond_Bleeding);
			TF2_RemoveCondition(client, TFCond_Slowed);
			TF2_RemoveCondition(client, TFCond_Dazed);
			TF2_RemoveCondition(client, TFCond_Jarated);
			TF2_RemoveCondition(client, TFCond_Milked);
		}
		if(GetEngineTime() >= SlownessOnHit_Dur[client] + SlownessOnHit_MaxDur[client])
		{
			TF2Attrib_RemoveByName(client, "move speed penalty");
			SlownessOnHit_Dur[client] = 0.0;
			SlownessOnHit_MaxDur[client] = 0.0;
			TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
		}
		if(melee > -1 && LargerMeleeRangeOnKill_Dur[client] > 0.0)
		{
			LargerMeleeRangeOnKill_Dur[client] -= 0.1;
		}
		else if(melee > -1 && wep == melee && LargerMeleeRangeOnKill_Dur[client] <= 0.0)
		{
			TF2Attrib_RemoveByName(wep, "melee range multiplier");
			TF2Attrib_RemoveByName(wep, "melee bounds multiplier");
		}
		if(HasAttribute(client, _, PrimaryWeaponBonuses) && primary > -1)
		{
			new Float:reloadrate = GetAttributeValueF(client, _, PrimaryWeaponBonuses, PrimaryWeaponBonuses_ReloadSpd, 0.0);
			new Float:firerate = GetAttributeValueF(client, _, PrimaryWeaponBonuses, PrimaryWeaponBonuses_FiringSpd, 0.0);
			TF2Attrib_SetByName(primary, "fire rate penalty", 1.0-reloadrate);
			TF2Attrib_SetByName(primary, "Reload time increased", 1.0-firerate);
		}
		
		if(primary > -1 && UberRateKill[primary] || melee > -1 && UberRateKill[melee])
		{
			new item;
			if (primary > -1 && UberRateKill[primary])item = GetPlayerWeaponSlot(client, 0);
			if (melee > -1 && UberRateKill[melee])item = GetPlayerWeaponSlot(client, 2);
			SetHudTextParams(0.8, -1.0, 0.2, 255, 255, 255, 255);
			ShowSyncHudText(client, hudText_Client, "Stacks: %i / %i", UberRateKill_Stacks[item], UberRateKill_MaxStacks[item]);
		}
		if(HasAttribute(client, _, m_bReduceDebuffDur))
		{
			if(GetEngineTime() >= GetAttributeValueF(client, _, m_bReduceDebuffDur, m_flReduceDebuffDur_Jarate) + (10.0 * GetAttributeValueF(client, _, m_bReduceDebuffDur, m_flReduceDebuffDur)))
				TF2_RemoveCondition(client, TFCond_Jarated);
			
			if(GetEngineTime() >= GetAttributeValueF(client, _, m_bReduceDebuffDur, m_flReduceDebuffDur_Milk) + (10.0 * GetAttributeValueF(client, _, m_bReduceDebuffDur, m_flReduceDebuffDur)))
				TF2_RemoveCondition(client, TFCond_Milked);
			
			if(GetEngineTime() >= GetAttributeValueF(client, _, m_bReduceDebuffDur, m_flReduceDebuffDur_Bleed) + (6.0 * GetAttributeValueF(client, _, m_bReduceDebuffDur, m_flReduceDebuffDur)))
				TF2_RemoveCondition(client, TFCond_Bleeding);
			
			if(GetEngineTime() >= GetAttributeValueF(client, _, m_bReduceDebuffDur, m_flReduceDebuffDur_OnFire) + (10.0 * GetAttributeValueF(client, _, m_bReduceDebuffDur, m_flReduceDebuffDur)))
				TF2_RemoveCondition(client, TFCond_OnFire);
			
			if(GetEngineTime() >= GetAttributeValueF(client, _, m_bReduceDebuffDur, m_flReduceDebuffDur_Dazed) + (7.0 * GetAttributeValueF(client, _, m_bReduceDebuffDur, m_flReduceDebuffDur)))
				TF2_RemoveCondition(client, TFCond_Dazed);
			
			if(GetEngineTime() >= GetAttributeValueF(client, _, m_bReduceDebuffDur, m_flReduceDebuffDur_MarkedForDeath) + (15.0 * GetAttributeValueF(client, _, m_bReduceDebuffDur, m_flReduceDebuffDur)))
				TF2_RemoveCondition(client, TFCond_MarkedForDeath);
		}
		if(GetEngineTime() >= SpeedOnKill_Dur[client] + SpeedOnKill_MaxDur[client] && GetEngineTime() <= SpeedOnKill_Dur[client] + SpeedOnKill_MaxDur[client] + 0.2)
		{
			TF2Attrib_RemoveByName(primary, "CARD: move speed bonus");
			TF2Attrib_RemoveByName(secondary, "CARD: move speed bonus");
			TF2Attrib_RemoveByName(melee, "CARD: move speed bonus");
			TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
		}
		if(HasAttribute(client, _, bCritsOnSapperRemoved))
		{
			new item = GetSlotContainingAttribute(client, bCritsOnSapperRemoved);
			if(iCritsOnSapperRemoved_Type[client][item] == 0)
			{
				SetHudTextParams(0.6, 0.8, 0.2, 255, 255, 255, 255);
				ShowSyncHudText(client, hudText_Client, "Crits: %i / %i", iCritsOnSapperRemoved_Crits[client][item], iCritsOnSapperRemoved_Cap[client][item]);
				if(bCritsOnSapperRemoved[client][slot] && iCritsOnSapperRemoved_Crits[client][slot] > 0)
					TF2_AddCondition(client, TFCond_CritCanteen, 0.2, client);
			}
			else if(iCritsOnSapperRemoved_Type[client][item] == 1)
			{
				SetHudTextParams(0.6, 0.8, 0.2, 255, 255, 255, 255);
				ShowSyncHudText(client, hudText_Client, "Mini-Crits: %i / %i", iCritsOnSapperRemoved_Crits[client][item], iCritsOnSapperRemoved_Cap[client][item]);
				if(bCritsOnSapperRemoved[client][slot] && iCritsOnSapperRemoved_Crits[client][slot] > 0)
					TF2_AddCondition(client, TFCond:16, 0.2, client);
			}
		}
		
		if (HasAttribute(client, _, CondOnWearer))
		{
			TF2_AddCondition(client, TFCond:GetAttributeValueI(client, _, CondOnWearer, CondOnWearer_ID), 0.2);
		}
		/*
		if(HasAttribute(client, _, ElectroShock))
		{
			new shocker = GetSlotContainingAttribute(client, ElectroShock);
			SetHudTextParams(-0.6, 0.6, 0.2, 255, 255, 255, 255);
			ShowSyncHudText(client, ElectroShock_Display, "[%i%%] / [100%%] Charge", RoundFloat(ElectroShock_Charge[client][shocker] / ElectroShock_MaxCharge[client][shocker] * 100.0));
			if(GetEngineTime() <= ElectroShock_Dur[client][shocker] + ElectroShock_MaxDur[client][shocker])
			{
				TF2_AddCondition(client, TFCond:52, 0.2);
				TF2_AddCondition(client, TFCond:31, 0.2);
				TF2_AddCondition(client, TFCond:41, 0.2);
				TF2Attrib_SetByName(melee, "mod weapon blocks healing", 1.0);
				SetEntityHealth(client, 1);
				SetAmmo(client, 0, 0);
				SetAmmo(client, 1, 0);
				ElectroShock_Charge[client][shocker] = 0.0;
			}
			else
			{
				TF2Attrib_RemoveByName(melee, "mod weapon blocks healing");
			}
		}
		*/
		
		if (HasAttribute(client, _, EvasionOnHit) && !HasAttribute(client, _, EvasionOnHit_Active))
		{
			SetHudTextParams(-1.0, 0.5, 0.2, 255, 255, 255, 255);
			ShowSyncHudText(client, EvasionOnHit_Display, "Evasiveness: %i%% / 100%%", RoundFloat(GetAttributeValueF(client, _, EvasionOnHit, EvasionOnHit_Evasion) * 100.0));
		}
		if (HasAttribute(client, _, EngieHaulSpeed))
		{
			new wepslot = GetSlotContainingAttribute(client, EngieHaulSpeed);
			if (!m_bHasAttribute[client][wepslot])return;
			if(GetEntProp(client, Prop_Send, "m_bCarryingObject"))
			{
				TF2Attrib_SetByName(client, "move speed bonus", GetAttributeValueF(client, _, EngieHaulSpeed, EngieHaulSpeed_Mult));
				TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
			}
			else
			{
				TF2Attrib_RemoveByName(client, "move speed bonus");
				TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
			}
		}
		
		if(HasAttribute(client, _, SuperSlidersStomp))
		{
			new boots = GetSlotContainingAttribute(client, SuperSlidersStomp);
			if(GetEntityFlags(client) & FL_ONGROUND == FL_ONGROUND)
			{
				SuperSlidersStomp_OnGround[client][boots] += 0.1;
				if(SuperSlidersStomp_OnGround[client][boots] >= 0.5)
				{
					SuperSlidersStomp_Stacks[client][boots] = 0.0;
				}
			}
			else if(GetEntityFlags(client) & FL_ONGROUND != FL_ONGROUND)
				SuperSlidersStomp_OnGround[client][boots] = 0.0;
				
			SetHudTextParams(0.6, 0.6, 0.2, 255, 255, 255, 255);
			ShowSyncHudText(client, TankGoodness_Handle, "Stacks: %i / %i", RoundFloat(GetAttributeValueF(client, _, SuperSlidersStomp, SuperSlidersStomp_Stacks)), RoundFloat(GetAttributeValueF(client, _, SuperSlidersStomp, SuperSlidersStomp_Max)));
			if(SuperSlidersStomp_Stomp[client][boots])
			{
				new Float:velocity[3];
				GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);
				velocity[2] = GetAttributeValueF(client, _, SuperSlidersStomp, SuperSlidersStomp_JumpHeight);
				TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
				SuperSlidersStomp_Stomp[client][boots] = false;
			}
		}
		
		if(GetEngineTime() <= SpyDetector_Dur[client] + SpyDetector_MaxDur[client])
		{
			SetHudTextParams(0.5, 0.5, 0.2, 255, 255, 255, 255);
			ShowSyncHudText(client, hudText_Client, "%i%% damage vulnerability on wearer", RoundFloat(SpyDetector_Vuln[client] * 100.0));
		}
		
		if(melee > -1 && secondary > -1 && MeleeKillChargesSecondary[melee] && wep == secondary)
		{
			if(MeleeKillChargesSecondary_Kill[melee])
			{
				MeleeKillChargesSecondary_Dur[melee] = GetEngineTime();
				MeleeKillChargesSecondary_Kill[melee] = false;
			}
				
			if(GetEngineTime() <= MeleeKillChargesSecondary_Dur[melee] + MeleeKillChargesSecondary_MaxDur[melee])
				TF2_AddCondition(client, TFCond:MeleeKillChargesSecondary_CondID[melee], 0.2);
		}
		if(melee > -1 && secondary > -1 && SecondaryKillChargesMelee[secondary] && wep == melee)
		{
			if(SecondaryKillChargesMelee_Kill[secondary])
			{	
				SecondaryKillChargesMelee_Dur[secondary] = GetEngineTime();
				SecondaryKillChargesMelee_Kill[secondary] = false;
			}
				
			if(GetEngineTime() <= SecondaryKillChargesMelee_Dur[secondary] + SecondaryKillChargesMelee_MaxDur[secondary])
				TF2_AddCondition(client, TFCond:SecondaryKillChargesMelee_CondID[secondary], 0.2);
		}
		
		if(slot > -1 && slot < 3 && !m_bHasAttribute[client][slot]) return;
		
		if(AddcondDrink[wep] && GetEntPropFloat(secondary, Prop_Send, "m_flEffectBarRegenTime") >= 1.0)
		{
			TF2_AddCondition(client, TFCond:AddcondDrink_ID1[wep], AddcondDrink_Dur1[wep]);
			TF2_AddCondition(client, TFCond:AddcondDrink_ID2[wep], AddcondDrink_Dur2[wep]);
		}
		if(NoOverhealActive[wep])
		{
			if(GetClientHealth(client) >= (GetEntProp(client, Prop_Data, "m_iMaxHealth") * NoOverhealActive_Threshold[wep])) 
			{
				TF2Attrib_SetByName(wep, "mod weapon blocks healing", 1.0);
			}
			else
			{
				TF2Attrib_RemoveByName(wep, "mod weapon blocks healing");
			}
		}
		if(m_bHealthWhileSpunUp[wep])
		{
			if(TF2_IsPlayerInCondition(client, TFCond_Slowed))
			{
				TF2Attrib_SetByName(wep, "health from packs decreased", m_flHealthWhileSpunUp_Packs[wep]);
				TF2Attrib_SetByName(wep, "health from healers reduced", m_flHealthWhileSpunUp_Healers[wep]);
				TF2Attrib_SetByName(wep, "reduced_healing_from_medics", m_flHealthWhileSpunUp_Medics[wep]);
			}
			else
			{
				TF2Attrib_RemoveByName(wep, "health from packs decreased");
				TF2Attrib_RemoveByName(wep, "health from healers reduced");
				TF2Attrib_RemoveByName(wep, "reduced_healing_from_medics");
			}
		}
		if(NoDebuffs[wep] && TF2_IsPlayerInCondition(client, TFCond_Slowed))
		{
			TF2_RemoveCondition(client, TFCond_OnFire);
			TF2_RemoveCondition(client, TFCond:24);
			TF2_RemoveCondition(client, TFCond:27);
			TF2_RemoveCondition(client, TFCond:30);
			TF2_RemoveCondition(client, TFCond:25);
		}
		if(MissingHealthFasterReload[wep] && GetClientHealth(client) <= GetClientMaxHealth(client)) {
			TF2Attrib_RemoveByName(wep, "faster reload rate");
			new Float:reloadrate = 1.0 - ((GetClientMaxHealth(client) - GetClientHealth(client)) * MissingHealthFasterReload_Mult[wep] / 100.0);
			TF2Attrib_SetByName(wep, "faster reload rate", reloadrate);
		}
		if(MissingHealthFasterFire[wep] && GetClientHealth(client) <= GetClientMaxHealth(client)) {
			TF2Attrib_RemoveByName(wep, "fire rate bonus");
			new Float:firerate = 1.0 - ((GetClientMaxHealth(client) - GetClientHealth(client)) * MissingHealthFasterFire_Mult[wep] / 100.0);
			TF2Attrib_SetByName(wep, "fire rate bonus", firerate);
		}
		if(MissingHealthDmgPen[wep] && GetClientHealth(client) <= GetClientMaxHealth(client)) {
			TF2Attrib_RemoveByName(wep, "damage penalty");
			new Float:dmgpen = 1.0 - ((GetClientMaxHealth(client) - GetClientHealth(client)) * MissingHealthDmgPen_Mult[wep] / 100.0);
			if(dmgpen > 1.0) dmgpen = 1.0;
			TF2Attrib_SetByName(wep, "damage penalty", dmgpen);
		}
		if(MissingHealthDmgBonus[wep] && GetClientHealth(client) <= GetClientMaxHealth(client)) {
			TF2Attrib_RemoveByName(wep, "dmg penalty vs players");
			TF2Attrib_RemoveByName(wep, "dmg bonus vs buildings");
			new Float:dmgbonus = 1.0 + ((GetClientMaxHealth(client) - GetClientHealth(client)) * MissingHealthDmgBonus_Mult[wep] / 100.0);
			if(dmgbonus < 1.0) dmgbonus = 1.0;
			TF2Attrib_SetByName(wep, "dmg penalty vs players", dmgbonus);
			TF2Attrib_SetByName(wep, "dmg bonus vs buildings", dmgbonus);
		}
		if(MissingHealthCritChance[wep] && GetClientHealth(client) <= GetClientMaxHealth(client))
		{
			TF2Attrib_RemoveByName(wep, "crit mod disabled");
			new Float:critchance = (MissingHealthCritChance_Mult[wep] * ((GetClientMaxHealth(client) - GetClientHealth(client)) / GetClientMaxHealth(client)) * 100.0);
			if(critchance > 100.0) critchance = 100.0;
			if(critchance < 0.0) critchance = 0.0;
			TF2Attrib_SetByName(wep, "crit mod disabled", critchance);
		}
		if(MetalToDmg[wep])
		{
			new metal = GetEntProp(client, Prop_Data, "m_iAmmo", 4, 3);
			new Float:dmgbonus = 1.0 + ((metal / 2) * MetalToDmg_Mult[wep] / 100.0);
			TF2Attrib_SetByName(wep, "dmg penalty vs players", dmgbonus);
			TF2Attrib_SetByName(wep, "dmg bonus vs buildings", dmgbonus);
		}
		if(BuffFlagUber[wep] && GetEntProp(wep, Prop_Send, "m_bChargeRelease"))
		{
			TF2_AddCondition(client, TFCond:16, 0.2);
			TF2_AddCondition(client, TFCond:26, 0.2);
			TF2_AddCondition(client, TFCond:29, 0.2);
			new patient = GetMediGunPatient(client);
			if(patient > -1 && patient <= MaxClients && IsPlayerAlive(patient))
			{
				TF2_AddCondition(patient, TFCond:16, 0.2);
				TF2_AddCondition(patient, TFCond:26, 0.2);
				TF2_AddCondition(patient, TFCond:29, 0.2);
			}
		}
		if(AimMoveSpdOnKill[wep])
		{
			if(GetEngineTime() <= AimMoveSpdOnKill_Dur[wep] + AimMoveSpdOnKill_MaxDur[wep])
			{
				TF2Attrib_SetByName(wep, "aiming movespeed increased", 1.0+AimMoveSpdOnKill_Spd[wep]);
				TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
			}
			else
			{
				TF2Attrib_RemoveByName(wep, "aiming movespeed increased");
				TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
			}
		}
		if(AddcondSpunup[wep] && TF2_IsPlayerInCondition(client, TFCond_Slowed))
		{
			TF2_AddCondition(client, TFCond:AddcondSpunup_ID[wep], 0.2);
		}
		if(secondary > -1 && DrinkEffects[secondary] && TF2_IsPlayerInCondition(client, TFCond_Bonked))
		{
			//Now begins the rather inefficient way to do this. >.<
			new effects[3] = { 1, 2, 3 };
			new effectchoice = GetRandomInt(0, 2);
			if(effects[effectchoice] == 1)
			{
				new goodeffect[8] = { 37, 16, 26, 29, 28, 45, 66, 72 };
				new goodchoice = GetRandomInt(0, 7);
				TF2_AddCondition(client, TFCond:goodeffect[goodchoice], DrinkEffects_Dur[secondary]);
				TF2_RemoveCondition(client, TFCond_Bonked);
			}
			else if(effects[effectchoice] == 2 || effects[effectchoice] == 3)
			{
				new badeffect[5] =  { 114, 84, 86, 48, 27 };
				new badchoice = GetRandomInt(0, 4);
				TF2_AddCondition(client, TFCond:badeffect[badchoice], DrinkEffects_Dur[secondary]);
				TF2_RemoveCondition(client, TFCond_Bonked);
			}
			TF2_RemoveCondition(client, TFCond_Bonked);
		}
		if(CraftingOnKill[wep])
		{
			SetHudTextParams(-0.6, 0.6, 0.2, 255, 255, 255, 255);
			ShowSyncHudText(client, CraftingOnKill_Display, "Stacks: %i / %i", CraftingOnKill_Stacks[client], CraftingOnKill_MaxStacks[client]);
		}
		if(TankGoodness[client][slot])
		{
			SetHudTextParams(0.6, 0.6, 0.2, 255, 255, 255, 255);
			if(TankGoodness_Level[client][slot] >= 6)TankGoodness_Charge[client][slot] = TankGoodness_MaxCharge[client][slot] + (TankGoodness_ChargePerLvl[client][slot] * TankGoodness_Level[client][slot]);
			ShowSyncHudText(client, TankGoodness_Handle, "[%i%%] / [100%] <:Upgrade progress\nLevel:> [%i] [6]", RoundFloat(TankGoodness_Charge[client][slot] / (TankGoodness_MaxCharge[client][slot] + TankGoodness_ChargePerLvl[client][slot] * TankGoodness_Level[client][slot]) * 100.0), RoundFloat(TankGoodness_Level[client][slot]));   
		}
		if(UncontainableReaction[wep])
		{
			SetHudTextParams(0.6, 0.6, 0.2, 255, 255, 255, 255);
			ShowSyncHudText(client, TankGoodness_Handle, "Combo: [%i] / [3]", UncontainableReaction_Combo[wep]); 
		}
		if (EvasionOnHit[client][slot] && HasAttribute(client, _, EvasionOnHit_Active))
		{
			SetHudTextParams(-1.0, 0.5, 0.2, 255, 255, 255, 255);
			ShowSyncHudText(client, EvasionOnHit_Display, "Evasiveness: %i%% / 100%%", RoundFloat(EvasionOnHit_Evasion[client][slot] * 100.0));
		}
		if(ShellshockAttrib[wep])
		{
			SetHudTextParams(0.5, 0.5, 0.2, 255, 255, 255, 255);
			ShowSyncHudText(client, EvasionOnHit_Display, "Fire rate: [%i%%] / [%i%%]", RoundFloat(ShellshockAttrib_Amount[wep] * ShellshockAttrib_Teleports[wep] * 100.0), RoundFloat(ShellshockAttrib_Amount[wep] * ShellshockAttrib_Max[wep] * 100.0));
		}
		if(IronBoarder[wep])
		{
			if(GetPlayerWeaponSlot(client, 1) > -1)
			{
				TF2Attrib_SetByName(wep, "health on radius damage", IronBoarder_Healing[wep]);
				TF2Attrib_SetByName(wep, "faster reload rate", 1.0 + IronBoarder_ReloadRate[wep]);
			}
			else if(GetPlayerWeaponSlot(client, 1) == -1)
			{
				TF2Attrib_RemoveByName(wep, "health on radius damage");
			}
		}
		if(HeatDecreasesAccuracy[wep])
		{
			SetHudTextParams(-1.0, 0.75, 0.2, 255, 255, 255, 255);
			ShowSyncHudText(client, HeatDecreasesAccuracy_Text, "Stack(s) %i/%i", HeatDecreasesAccuracy_Stacks[wep], HeatDecreasesAccuracy_Max[wep]);
			if(TF2_IsPlayerInCondition(client, TFCond_Slowed) && GetEngineTime() >= HeatDecreasesAccuracy_Delay[wep] + HeatDecreasesAccuracy_MaxDelay[wep] && HeatDecreasesAccuracy_Stacks[wep] < HeatDecreasesAccuracy_Max[wep])
			{
				HeatDecreasesAccuracy_Stacks[wep]++;
				HeatDecreasesAccuracy_Delay[wep] = GetEngineTime();
				if (HeatDecreasesAccuracy_Stacks[wep] > HeatDecreasesAccuracy_Max[wep])HeatDecreasesAccuracy_Stacks[wep] = HeatDecreasesAccuracy_Max[wep];
				TF2Attrib_SetByName(wep, "spread penalty", 1.0 + (HeatDecreasesAccuracy_Accuracy[wep] * HeatDecreasesAccuracy_Stacks[wep]));
			}
			else if(!TF2_IsPlayerInCondition(client, TFCond_Slowed) || GetAmmo(client, 0) <= 0)
			{
				HeatDecreasesAccuracy_Stacks[wep] = 0;
				TF2Attrib_SetByName(wep, "spread penalty", HeatDecreasesAccuracy_OldAccuracy[wep]);
				HeatDecreasesAccuracy_Delay[wep] = GetEngineTime();
			}
		}
		if(SpyDetector[wep])
		{
			for (new i = 1; i <= MaxClients; i++)
			{
				new Float:flPos1[3];
				GetClientAbsOrigin(client, flPos1); 
				if(IsValidClient(i) && IsClientInGame(i) && IsPlayerAlive(i) && i != client && GetClientTeam(i) != GetClientTeam(client))
				{
					new Float:flPos2[3];
					GetClientAbsOrigin(i, flPos2);
					new Float:flDistance = GetVectorDistance(flPos1, flPos2);
					if(flDistance <= SpyDetector_Radius[wep])
					{
						if(SpyDetector_Type[wep] == 1 || SpyDetector_Type[wep] == 3) TF2_RemoveCondition(i, TFCond_Cloaked);
						if(SpyDetector_Type[wep] == 2 || SpyDetector_Type[wep] == 3) TF2_RemoveCondition(i, TFCond_Disguised);
						SpyDetector_Vuln[i] = SpyDetector_Vuln[wep];
						SpyDetector_MaxDur[i] = SpyDetector_MaxDur[wep];
						SpyDetector_Dur[i] = GetEngineTime();
					}
				}
			}
		}
	}
}

stock Ubercharge_Prethink(client)
{
	if (IsValidClient(client) && IsPlayerAlive(client))
	{
		new wep = Client_GetActiveWeapon(client);
		if (!IsValidEdict(wep) || wep < 0 || wep > 2048)return;
		new patient = GetMediGunPatient(client);
		if (patient <= 0 || patient > MaxClients || !IsPlayerAlive(patient))return;
		if(BoosterShotUber[wep]) //For the "ubercharge is booster shot" attribute
		{
			if(GetEntProp(wep, Prop_Send, "m_bChargeRelease"))
			{
				new Float:overheal, healing;
				
				if(BoosterShotUber_x10[wep] == 0)
				{
					TF2Attrib_SetByName(wep, "overheal decay bonus", 5.0);
					overheal = 2.0;
				}
				else
				{
					TF2Attrib_SetByName(wep, "overheal decay bonus", 9.0);
					overheal = 3.0;
				}
				
				healing = 1;
				if(GetEngineTime() >= CombatTime[patient] + 12.5 && GetEngineTime() <= CombatTime[patient] + 15.0)
					healing = 2;
				if(GetEngineTime() >= CombatTime[patient] + 15.0)
					healing = 3;
				
				if(BoosterShotUber_x10[wep] == 0 && GetEngineTime() >= BoosterShotUber_HealDelay[patient] + 0.0416666666)
				{
					HealPlayer(client, patient, healing, overheal);
					BoosterShotUber_HealDelay[patient] = GetEngineTime();
				}
				else if(BoosterShotUber_x10[wep] == 1 && GetEngineTime() >= BoosterShotUber_HealDelay[patient] + 0.0208333333)
				{
					HealPlayer(client, patient, healing, overheal);
					BoosterShotUber_HealDelay[patient] = GetEngineTime();
				}
			}
			else
			{
				if(BoosterShotUber_x10[wep] == 0)TF2Attrib_SetByName(wep, "overheal decay bonus", 3.0);
				if(BoosterShotUber_x10[wep] == 1)TF2Attrib_SetByName(wep, "overheal decay bonus", 5.0);
			}
		}
		if(BuffFlagUber[wep] && GetEntProp(wep, Prop_Send, "m_bChargeRelease"))
		{
			TF2_AddCondition(client, TFCond:16, 0.2);
			TF2_AddCondition(client, TFCond:26, 0.2);
			TF2_AddCondition(client, TFCond:29, 0.2);
			if(patient > -1 && patient <= MaxClients && IsPlayerAlive(patient))
			{
				TF2_AddCondition(patient, TFCond:16, 0.2);
				TF2_AddCondition(patient, TFCond:26, 0.2);
				TF2_AddCondition(patient, TFCond:29, 0.2);
			}
		}
	}
}

public OnCleaverTouch(ent, client)
{
	if (client <= 0 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client))return;
	if(RemoveBleed[ent])
		RemoveBleed[client] = true;
}

public OnEntityCreated(Ent, const String:cls[])
{
	if (Ent < 0 || Ent > 2048) return;
	if (!StrContains(cls, "tf_weapon_")) CreateTimer(0.3, OnWeaponSpawned, EntIndexToEntRef(Ent));
	if(!StrContains(cls, "tf_projectile_cleaver"))
	{
		new owner = GetEntPropEnt(Ent, Prop_Send, "m_hOwnerEntity");
		if (owner <= 0 || owner > MaxClients)return;
		new weapon = Client_GetActiveWeapon(owner);
		if(RemoveBleed[weapon])
			RemoveBleed[Ent] = true;
		
		SDKHook(Ent, SDKHook_StartTouch, OnCleaverTouch);
	}
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
	m_bHasAttribute[client][slot] = false;
	MissingHealthJumpHeight[client][slot] = false;
	MissingHealthJumpHeight_Mult[client][slot] = 0.0;
	MissingHealthUberBonus[client][slot] = false;
	MissingHealthUberBonus_Mult[client][slot] = 0.0;
	MissingHealthFasterMovement[client][slot] = false;
	MissingHealthFasterMovement_Mult[client][slot] = 0.0;
	PrimaryWeaponBonuses[client][slot] = false;
	PrimaryWeaponBonuses_ReloadSpd[client][slot] = 0.0;
	PrimaryWeaponBonuses_FiringSpd[client][slot] = 0.0;
	DMGDrainsMetal[client][slot] = false;
	DMGDrainsMetal_Mult[client][slot] = 0.0;
	SentryResOnKill_Resist[client][slot] = 0.0;
	SentryResOnKill_KnockRes[client][slot] = 0.0;
	SentryResOnKill[client][slot] = false;
	AddcondCharging[client][slot] = false;
	AddcondCharging_ID[client][slot] = 0;
	AddcondCharging_ID2[client][slot] = 0;
	RemoveDebuffsWhileCloaked[client][slot] = false;
	CloakRemoveStatus[client] = 0.0;
	CloakRemoveStatus_Dur[client][slot] = 0.0;
	MilkExplosionOnDeath[client][slot] = false;
	MilkExplosionOnDeath_Radius[client][slot] = 0.0;
	MilkExplosionOnDeath_Dur[client][slot] = 0.0;
	MilkOnHit[client][slot] = false;
	MilkOnHit_Dur[client][slot] = 0.0;
	m_bReduceDebuffDur[client][slot] = false;
	m_bPrimaryDmg[client][slot] = false;
	m_flPrimaryDmg_Mult[client][slot] = 0.0;
	bCritsOnSapperRemoved[client][slot] = false;
	iCritsOnSapperRemoved_Cap[client][slot] = 0;
	iCritsOnSapperRemoved_Add[client][slot] = 0;
	iCritsOnSapperRemoved_Type[client][slot] = 0;
	iCritsOnSapperRemoved_Crits[client][slot] = 0;
	m_bMeleeDmg[client][slot] = false;
	m_flMeleeDmg_Mult[client][slot] = 0.0;
	CondOnWearer[client][slot] = false;
	CondOnWearer_ID[client][slot] = -1;
	TankGoodness[client][slot] = false;
	TankGoodness_ChargeMult[client][slot] = 0.0;
	TankGoodness_Charge[client][slot] = 0.0;
	TankGoodness_MaxCharge[client][slot] = 0.0;
	TankGoodness_ChargePerLvl[client][slot] = 0.0;
	TankGoodness_MinResistDur[client][slot] = 0.0;
	TankGoodness_ResistDurPerLvl[client][slot] = 0.0;
	TankGoodness_HPOnKill[client][slot] = 0;
	TankGoodness_BonusHealing[client][slot] = 0.0;
	TankGoodness_KnockbackResist[client][slot] = 0.0;
	TankGoodness_Level[client][slot] = 0.0;
	TankGoodness_ChargesIt[client][slot] = 0.0;
	ElectroShock[client][slot] = false;
	ElectroShock_Charge[client][slot] = 0.0;
	ElectroShock_MaxCharge[client][slot] = 0.0;
	ElectroShock_MaxDur[client][slot] = 0.0;
	ElectroShock_Dur[client][slot] = 0.0;
	ElectroShock_ChargeMult[client][slot] = 0.0;
	StompDmgMultiplier[client][slot] = false;
	StompDmgMultiplier_Mult[client][slot] = 0.0;
	FallDmgMult[client][slot] = false;
	FallDmgMult_Active[client][slot] = false;
	FallDmgMult_Multiplier[client][slot] = 0.0;
	EvasionOnHit[client][slot] = false;
	EvasionOnHit_Add[client][slot] = 0.0;
	EvasionOnHit_Subtract[client][slot] = 0.0;
	EvasionOnHit_MeleeSubtract[client][slot] = 0.0;
	EvasionOnHit_Evasion[client][slot] = 0.0;
	EngieHaulSpeed[client][slot] = false;
	EngieHaulSpeed_Mult[client][slot] = 0.0;
	SuperSlidersStomp[client][slot] = false;
	SuperSlidersStomp_JumpHeight[client][slot] = 0.0;
	SuperSlidersStomp_DamageMult[client][slot] = 0.0;
	SuperSlidersStomp_Stacks[client][slot] = 0.0;
	SuperSlidersStomp_Max[client][slot] = 0.0;
}

public OnEntityDestroyed(Ent)
{
	if (Ent <= 0 || Ent > 2048) return;
	
	NoDebuffs[Ent] = false;
	NoOverhealActive[Ent] = false;
	NoOverhealActive_Threshold[Ent] = 1.0;
	FasterReloadKill[Ent] = false;
	FasterReloadKill_Spd[Ent] = 0.0;
	FasterReloadKill_Stacks[Ent] = 0;
	FasterReloadKill_MaxStacks[Ent] = 0;
	LargerMeleeRangeOnKill[Ent] = false;
	LargerMeleeRangeOnKill_Range[Ent] = 0.0;
	LargerMeleeRangeOnKill_Dur[Ent] = 0.0;
	LargerMeleeRangeOnKill_MaxDur[Ent] = 0.0;
	LargerMeleeRangeOnKill_Bounds[Ent] = 0.0;
	MissingHealthFasterReload[Ent] = false;
	MissingHealthFasterReload_Mult[Ent] = 0.0;
	MissingHealthFasterFire[Ent] = false;
	MissingHealthFasterFire_Mult[Ent] = 0.0;
	MissingHealthDmgPen[Ent] = false;
	MissingHealthDmgPen_Mult[Ent] = 0.0;
	MissingHealthDmgBonus[Ent] = false;
	MissingHealthDmgBonus_Mult[Ent] = 0.0;
	MissingHealthCritChance[Ent] = false;
	MissingHealthCritChance_Mult[Ent] = 0.0;
	BuffFlagUber[Ent] = false;
	MiniUbers[Ent] = false;
	MiniUbers_Count[Ent] = 0.0;
	MiniUbers_UberUntil[Ent] = 0.0;
	HammerMechanic[Ent] = false;
	HammerMechanic_Fann[Ent] = false;
	HammerMechanic_Wait[Ent] = 0.0;
	HammerMechanic_x10[Ent] = 0;
	SentryResOnKill_Dur[Ent] = 0.0;
	DrinkEffects[Ent] = false;
	DrinkEffects_Dur[Ent] = 0.0;
	CraftingOnKill[Ent] = false;
	CraftingOnKill_Movespd[Ent] = 0.0;
	CraftingOnKill_Dmgpen[Ent] = 0.0;
	CraftingOnKill_Stacks[Ent] = 0;
	CraftingOnKill_MaxStacks[Ent] = 0;
	AimMoveSpdOnKill[Ent] = false;
	AimMoveSpdOnKill_Dur[Ent] = 0.0;
	AimMoveSpdOnKill_MaxDur[Ent] = 0.0;
	AimMoveSpdOnKill_Spd[Ent] = 0.0;
	AddcondSpunup[Ent] = false;
	AddcondSpunup_ID[Ent] = 0;
	BoosterShotUber[Ent] = false;
	BoosterShotUber_HealDelay[Ent] = 0.0;
	BoosterShotUber_x10[Ent] = 0;
	HealOnDraw[Ent] = false;
	HealOnDraw_HP[Ent] = 0;
	HealOnDraw_Mult[Ent] = 0.0;
	HealOnDraw_Cap[Ent] = 1.0;
	HealOnSheath[Ent] = false;
	HealOnSheath_HP[Ent] = 0;
	HealOnSheath_Mult[Ent] = 0.0;
	HealOnSheath_Cap[Ent] = 0.0;
	MeleeRangeKillStack[Ent] = false;
	MeleeRangeKillStack_Stacks[Ent] = 0;
	MeleeRangeKillStack_MaxStacks[Ent] = 0;
	MeleeRangeKillStack_Range[Ent] = 0.0;
	MeleeRangeKillStack_Bounds[Ent] = 0.0;
	SlownessOnHit[Ent] = false;
	SlownessOnHit_MaxDur[Ent] = 0.0;
	SlownessOnHit_Amount[Ent] = 0.0;
	UberRateKill[Ent] = false;
	UberRateKill_Bonus[Ent] = 0.0;
	UberRateKill_MaxStacks[Ent] = 0;
	UberRateKill_Stacks[Ent] = 0;
	UberRateKill_Subtract[Ent] = 0;
	UberRateKill_Hearts[Ent] = 0;
	KillsChargeItems[Ent] = false;
	KillsChargeItems_Mult[Ent] = 0.0;
	SpeedOnKill[Ent] = false;
	SpeedOnKill_Mult[Ent] = 0.0;
	m_bCondimentCannon[Ent] = false;
	m_flCondimentCannon_Dur[Ent] = 0.0;
	m_iCondimentCannon_Cond1[Ent] = 0;
	m_iCondimentCannon_Cond2[Ent] = 0;
	m_iCondimentCannon_Cond3[Ent] = 0;
	m_iCondimentCannon_Cond4[Ent] = 0;
	m_iCondimentCannon_Shot[Ent] = 0;
	m_bSpreadDmg[Ent] = false;
	m_flSpreadDmg_Mult[Ent] = 0.0;
	m_flSpreadDmg_MultMedic[Ent] = 0.0;
	m_flSpreadDmg_MinHealth[Ent] = 0.0;
	m_bGainCondOnHit[Ent] = false;
	m_flGainCondOnHit_Dur[Ent] = 0.0;
	m_iGainCondOnHit_Cond[Ent] = 0;
	m_bHealthWhileSpunUp[Ent] = false;
	m_flHealthWhileSpunUp_Packs[Ent] = 0.0;
	m_flHealthWhileSpunUp_Medics[Ent] = 0.0;
	m_flHealthWhileSpunUp_Healers[Ent] = 0.0;
	AddcondOnBackstab[Ent] = false;
	AddcondOnBackstab_ID[Ent] = -1;
	AddcondOnBackstab_Dur[Ent] = 0.0;
	SecondaryKillChargesMelee[Ent] = false;
	SecondaryKillChargesMelee_Kill[Ent] = false;
	SecondaryKillChargesMelee_CondID[Ent] = 0;
	SecondaryKillChargesMelee_MaxDur[Ent] = 0.0;
	SecondaryKillChargesMelee_Dur[Ent] = 0.0;
	MeleeKillChargesSecondary[Ent] = false;
	MeleeKillChargesSecondary_Kill[Ent] = false;
	MeleeKillChargesSecondary_CondID[Ent] = 0;
	MeleeKillChargesSecondary_MaxDur[Ent] = 0.0;
	MeleeKillChargesSecondary_Dur[Ent] = 0.0;
	NoCritBoost[Ent] = false;
	AddcondDrink[Ent] = false;
	AddcondDrink_ID1[Ent] = 0;
	AddcondDrink_ID2[Ent] = 0;
	AddcondDrink_Dur1[Ent] = 0.0;
	AddcondDrink_Dur2[Ent] = 0.0;
	AddcondOnKill[Ent] = false;
	AddcondOnKill_Dur[Ent] = 0.0;
	AddcondOnKill_ID1[Ent] = 0;
	AddcondOnKill_ID2[Ent] = 0;
	AddcondOnKill_ID3[Ent] = 0;
	MetalToDmg[Ent] = false;
	MetalToDmg_Mult[Ent] = 0.0;
	UberDamageResistance[Ent] = false;
	UberDamageResistance_DmgResist[Ent] = 0.0;
	DrainVictimAmmo[Ent] = false;
	DrainVictimAmmo_Primary[Ent] = 0.0;
	DrainVictimAmmo_Secondary[Ent] = 0.0;
	DrainVictimAmmo_Metal[Ent] = 0.0;
	DrainVictimAmmo_Rage[Ent] = 0.0;
	DrainVictimAmmo_Cloak[Ent] = 0.0;
	DrainVictimAmmo_Ubercharge[Ent] = 0.0;
	ShellshockAttrib[Ent] = false;
	ShellshockAttrib_Amount[Ent] = 0.0;
	ShellshockAttrib_Teleports[Ent] = 0.0;
	ShellshockAttrib_Max[Ent] = 0;
	IronBoarder[Ent] = false;
	IronBoarder_Healing[Ent] = 0.0;
	IronBoarder_ReloadRate[Ent] = 0.0;
	IronBoarder_ShieldRecharge[Ent] = 0.0;
	HeatDecreasesAccuracy[Ent] = false;
	HeatDecreasesAccuracy_Accuracy[Ent] = 0.0;
	HeatDecreasesAccuracy_Stacks[Ent] = 0;
	HeatDecreasesAccuracy_Max[Ent] = 0;
	HeatDecreasesAccuracy_MaxDelay[Ent] = 0.0;
	HeatDecreasesAccuracy_OldAccuracy[Ent] = 0.0;
	SpyDetector[Ent] = false;
	SpyDetector_Vuln[Ent] = 0.0;
	SpyDetector_Dur[Ent] = 0.0;
	SpyDetector_Type[Ent] = 0.0;
	SpyDetector_MaxDur[Ent] = 0.0;
	RemoveBleed[Ent] = false;
	HeadshotsMinicrit[Ent] = false;
}

//From customweaponstf_orionstock
stock bool:MakeSlotSleep(m_iClient, m_iAttacker, Float:m_flTime = 1.0, bool:m_bSwitch = true, String:m_strWakeSound[] = "player/recharged.wav")
{
    if (!IsValidClient(m_iClient)) return false;
    if (!IsPlayerAlive(m_iClient)) return false;
    if (!IsValidClient(m_iAttacker)) return false;
    if (m_flTime <= 0.0) return false;
    
    new m_iPrimary = GetPlayerWeaponSlot(m_iClient, 0);
    new m_iSecondary = GetPlayerWeaponSlot(m_iClient, 1);
   	if(m_iPrimary > -1)
    {
    	new m_iLoweredPrimary = GetEntProp(m_iPrimary, Prop_Send, "m_bLowered");
    	if(m_iLoweredPrimary <= 0)SetEntProp(m_iPrimary, Prop_Send, "m_bLowered", 10000);
    }
    if(m_iSecondary > -1)
    {
    	new m_iLoweredSecondary = GetEntProp(m_iSecondary, Prop_Send, "m_bLowered");
    	if(m_iLoweredSecondary <= 0)SetEntProp(m_iSecondary, Prop_Send, "m_bLowered", 10000);
    }
        
    m_bSlotDisabled[m_iClient] = true;
			
    SetClientSlot(m_iClient, 2);
            
    PrintHintText(m_iClient, "Custom: Your weapons are disabled for %.0f seconds !", m_flTime);
        
    new Handle:m_hData03 = CreateDataPack();
    WritePackCell(m_hData03, m_iClient);
    WritePackCell(m_hData03, m_iPrimary);
    WritePackCell(m_hData03, m_iSecondary);
    WritePackString(m_hData03, m_strWakeSound);
    CreateTimer(m_flTime, m_tWakeUpSlot_TimerDuration, m_hData03);
            
    return true;
}
stock SetClientSlot(client, slot)
{
    if (!IsValidClient(client)) return;
    if (!IsPlayerAlive(client)) return;

    new weapon = GetPlayerWeaponSlot(client, slot);

    SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", weapon);
    
    TF2_RemoveCondition(client, TFCond_Slowed);
    TF2_RemoveCondition(client, TFCond_Zoomed);
}
public Action:m_tWakeUpSlot_TimerDuration(Handle:timer, Handle:m_hData03)
{
    ResetPack(m_hData03);

    decl String:m_strWakeSound[PLATFORM_MAX_PATH];
    new m_iClient, m_iPrimary, m_iSecondary;
    m_iClient = ReadPackCell(m_hData03);
    m_iPrimary = ReadPackCell(m_hData03);
    m_iSecondary = ReadPackCell(m_hData03);
    ReadPackString(m_hData03, m_strWakeSound, sizeof(m_strWakeSound));
    CloseHandle(m_hData03);

    if (IsValidClient(m_iClient)) {

        m_bSlotDisabled[m_iClient] = false;
        
       	if(m_iPrimary > -1)
       	{
       		new m_iPrimaryLowered = GetEntProp(m_iPrimary, Prop_Send, "m_bLowered");
       		if(m_iPrimaryLowered != 0)SetEntProp(m_iPrimary, Prop_Send, "m_bLowered", 0);
       	}
       	if(m_iSecondary > -1)
       	{
       		new m_iSecondaryLowered = GetEntProp(m_iSecondary, Prop_Send, "m_bLowered");
       		if(m_iSecondaryLowered != 0)SetEntProp(m_iSecondary, Prop_Send, "m_bLowered", 0);
       	}
        if (IsPlayerAlive(m_iClient) && !StrEqual(m_strWakeSound, ""))
        {
            EmitSoundToAll(m_strWakeSound, m_iClient, SNDCHAN_WEAPON);
            EmitSoundToClient(m_iClient, m_strWakeSound);
       	}


        EmitSoundToClient(m_iClient, "player/recharged.wav");
        PrintHintText(m_iClient, "Custom: Your weapons are back !");
    }
}
stock SetWeaponAmmo(client, slot, ammo = -1, ammo2 = -1) {
    new weapon = GetPlayerWeaponSlot(client, slot);
    if(IsValidEntity(weapon)) {
        if (ammo >= 0) SetEntData(client,FindSendPropOffs("CTFPlayer", "m_iAmmo")+4,ammo);
        if (ammo2 >= 0) SetEntData(weapon,FindSendPropOffs("CBaseCombatWeapon", "m_iClip1"),ammo2,4);
    }
}

stock GetAmmo(client, slot)
{
	if (!IsValidClient(client)) return 0;
	new weapon = GetPlayerWeaponSlot(client, slot);
	if (IsValidEntity(weapon))
	{
		new iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		new iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		return GetEntData(client, iAmmoTable+iOffset);
	}
	return 0;
}
stock SetAmmo(client, slot, ammo)
{
	new weapon = GetPlayerWeaponSlot(client, slot);
	if (IsValidEntity(weapon))
	{
		new iOffset = GetEntProp(weapon, Prop_Send, "m_iPrimaryAmmoType", 1)*4;
		new iAmmoTable = FindSendPropInfo("CTFPlayer", "m_iAmmo");
		SetEntData(client, iAmmoTable+iOffset, ammo, 4, true);
	}
}

stock GetClientMetal(client) // Thx Nergal.
{
    return GetEntProp(client, Prop_Data, "m_iAmmo", 4, 3);
}
stock SetClientMetal(client, NewMetal) // Thx Nergal.
{
    if (NewMetal < 0) NewMetal = 0;
    if (NewMetal > 200) NewMetal = 200;
    SetEntProp(client, Prop_Data, "m_iAmmo", NewMetal, 4, 3);
}

stock ShowText(client, String:text[]="") {
    decl Float:vOrigin[3];
    GetClientEyePosition(client, vOrigin);
    vOrigin[2] += 2.0;

    new particle = CreateEntityByName("info_particle_system");
    if (IsValidEntity(particle))
    {
        TeleportEntity(particle, vOrigin, NULL_VECTOR, NULL_VECTOR);
        DispatchKeyValue(particle, "effect_name", text);
        DispatchSpawn(particle);
        ActivateEntity(particle);
        AcceptEntityInput(particle, "start");
        SetVariantString("OnUser1 !self:Kill::8:-1");
        AcceptEntityInput(particle, "AddOutput");
        AcceptEntityInput(particle, "FireUser1");
    }
}
