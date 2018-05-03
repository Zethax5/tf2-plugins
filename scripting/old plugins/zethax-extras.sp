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
#define SLOTS_MAX 7
#define ATTRIBUTE_1026_PUSHSCALE                    0.03
#define ATTRIBUTE_1026_PUSHMAX                      3.0
#define ATTRIBUTE_1026_COOLDOWN                     3.5
#define TEAM_SPEC    0
#define TEAM_RED    2
#define TEAM_BLUE   3
#define SOUND_EXPLOSION_BIG                 "ambient/explosions/explode_8.wav"

public Plugin:myinfo =  {
	name = "Zethax Attributes EXTRAS", 
	author = "Zethax", 
	description = "Includes a bunch of attributes I made specifically for community suggested weps", 
	version = PLUGIN_VERSION, 
	url = ""
};

new bool:MeleeKillBoosts[2049];
new MeleeKillBoosts_CondID[2049];
new Float:MeleeKillBoosts_Dur[2049];
new Float:MeleeKillBoosts_MaxDurSecondary[2049];
new Float:MeleeKillBoosts_MaxDurMelee[2049];
new Float:MeleeKillBoosts_MaxDur[2049];
new bool:CritBoostedFromOutside[MAXPLAYERS + 1];
new Handle:MeleeKillBoosts_Display;

new bool:ConchOnTaunt[2049];
new ConchOnTaunt_Drain[2049];
new Float:ConchOnTaunt_Delay[2049];
new bool:HPRegenOnKill[2049];
new HPRegenOnKill_HP[2049];
new Float:HPRegenOnKill_Delay[2049];
new Float:HPRegenOnKill_MaxDur[2049];
new Float:HPRegenOnKill_Dur[2049];

new bool:ElekAssure[2049];
new ElekAssure_MaxCrits[2049];
new ElekAssure_Crits[2049];

new bool:GeneralReserve[2049];
new GeneralReserve_Heal[2049];
new GeneralReserve_Mode[2049];
new Float:GeneralReserve_ImmuneDur[2049];
new Float:GeneralReserve_Dur[2049];

new LastWeaponHurtWith[MAXPLAYERS + 1];
new Handle:hudText_ElekAssure;

new bool:RandomSpellBuff[2049];
new Float:RandomSpellBuff_MaxDMG[2049];
new Float:RandomSpellBuff_Charge[2049];
new RandomSpellBuff_Spell[2049];
new Float:RandomSpellBuff_Dur[2049];
new Float:RandomSpellBuff_BuffDur[2049];
new RandomSpellBuff_Charges[2049];
new RandomSpellBuff_MaxCharges[2049];
new Handle:RandomBuffSpell_Rage;
new Handle:RandomBuffSpell_ChargeCount;

new bool:BattBackupXHP[MAXPLAYERS + 1];
new BattBackupXHP_HP[MAXPLAYERS + 1];

new bool:CursedHeads[2049];
new CursedHeads_MaxHeads[2049];
new Float:CursedHeads_Minicrits[2049];
new Float:CursedHeads_Dur[2049];
new CursedHeads_Heads[2049];
new Handle:CursedHeads_Display;

new bool:BuffDeployed[MAXPLAYERS + 1];

new bool:AmmoBuff[2049];

new bool:BuffedKillsBuffDur[2049];
new Float:BuffedKillsBuffDur_Dur[2049];

new bool:BuffedTKillsBuffDur[2049];
new Float:BuffedTKillsBuffDur_Dur[2049];

new bool:DMGResistHauling[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:DMGResistHauling_Mult[MAXPLAYERS + 1][SLOTS_MAX + 1];

new bool:MultipleHitsMinicrit[2049];
new MultipleHitsMinicrit_Hits[2049];
new Float:MultipleHitsMinicrit_Delay[2049];

new bool:PlagueStab[2049];
new Float:PlagueStab_MaxDur[2049];
new Float:PlagueStab_Radius[2049];
new PlagueStab_MarkFD[2049];
new PlagueStab_Infector[MAXPLAYERS + 1] =  { -1, ... };
new Float:PlagueStab_DMGDelay[MAXPLAYERS + 1];
new Float:PlagueStab_Dur[MAXPLAYERS + 1];
new Float:PlagueStab_ImmunityDur[MAXPLAYERS + 1];
new Float:PlagueStab_ImmunityMaxDur[2049];
new Float:PlagueStab_AOEMFDur[2049];

new bool:KillsRefillShurikens[2049];
new KillsRefillShurikens_Count[2049];
new KillsRefillShurikens_Max[2049];

new bool:NinjaSet[2049];
new Float:LungeCooldown[MAXPLAYERS + 1];

new bool:DirectHitBonus[2049];
new Float:DirectHitBonus_SpdDur[2049];
new Float:DirectHitBonus_FireSpd[2049];
new Float:DirectHitBonus_DmgPen[2049];
new DirectHitBonus_MaxStacks[2049];
new DirectHitBonus_Stacks[2049];
new Float:DirectHitBonus_BlastRad[2049];
new Float:DirectHitBonus_ProjSpd[2049];
new Float:DirectHitBonus_Decay[2049];
new Float:DirectHitBonus_Dur[2049];
new Float:DirectHitBonus_StackDecay[2049];
new Handle:StackDisplay;

new bool:RandomSpellKill[MAXPLAYERS + 1][SLOTS_MAX + 1];
new RandomSpellKill_Spell[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Mana[MAXPLAYERS + 1];
new Float:SwitchDelay[MAXPLAYERS + 1];
new Float:SpellDelay[MAXPLAYERS + 1];
new Float:ManaRegen[MAXPLAYERS + 1];
new Float:ManaDisable[MAXPLAYERS + 1];
new Handle:SpellDisplay;
new Handle:ManaDisplay;

new bool:InvisCrouch[MAXPLAYERS + 1][SLOTS_MAX + 1];
new InvisCrouch_Drain[MAXPLAYERS + 1][SLOTS_MAX + 1];
new InvisCrouch_Stamina[MAXPLAYERS + 1];
new Float:InvisCrouch_Delay[MAXPLAYERS + 1];
new Float:InvisCrouch_Regen[MAXPLAYERS + 1];
new Handle:StaminaDisplay;

new bool:Magic[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:Magic_Recharge[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:Magic_Delay[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:Magic_SpellDelay[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Magic_MaxCharges[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Magic_Charges[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:Magic_CastDelay[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Magic_SpellType[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Handle:MagicDisplay;

new bool:SkelyAttrib[2049];
new SkelyAttrib_Charges[2049];
new SkelyAttrib_MaxCharges[2049];
new Float:SkelyAttrib_Cooldown[2049];
new Float:SkelyAttrib_CastDelay[2049];
new Handle:SkelyDisplay;

new bool:Backstab[2049];
new Float:Backstab_BleedDur[2049];
new Float:Backstab_DMG[2049];
new Backstab_Silent[2049];
new Float:Backstab_SilenceDur[2049];

new bool:AltfireDet[2049];

new bool:FatScout[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:FatScout_DMG[MAXPLAYERS + 1][SLOTS_MAX + 1];

new bool:SpdOnDraw[2049];
new Float:SpdOnDraw_Dur[2049];
new Float:SpdOnDraw_SheathDur[2049];

new bool:BleedOnHit[2049];
new Float:BleedOnHit_Dur[2049];
new BleedOnHit_Minicrit[2049];

new bool:m_bBleedDmgBonus[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:m_fBleedDmgBonus_Mult[MAXPLAYERS + 1][SLOTS_MAX + 1];

new bool:m_bDamnedMerasmus[2049];
new Float:m_flDamnedMerasmus[2049];

new bool:m_bAddcondActive[2049];
new m_iAddcondActive1[2049];
new m_iAddcondActive2[2049];
new m_iAddcondActive3[2049];
new m_iAddcondActive4[2049];

new bool:m_bEngiJetpack[MAXPLAYERS + 1][SLOTS_MAX + 1];
new m_iEngiJetpack[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:m_flEngiJetpack[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:m_flEngiJetpack_Delay[MAXPLAYERS + 1];
new Float:m_flEngiJetpack_Spd[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:m_flEngiJetpack_FlightDur[MAXPLAYERS + 1];

new bool:m_bDashAttrib[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:m_flDashAttrib_Cooldown[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:m_flDashAttrib_Delay[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Handle:DashAttribRechargeBar;

new bool:m_bRocketFlamethrower[2049];

new bool:m_bDmgResistOverhealed[2049];
new Float:m_flDmgResistOverhealed[2049] =  { 1.0, ... };

new bool:m_bInvigoratorUber[2049];
new Float:m_flInvigoratorUber_DmgBonus[2049] =  { 1.0, ... };
new Float:m_flInvigoratorUber_MaxDur[2049];
new Float:m_flInvigoratorUber_UberRequired[2049];
new Float:m_flInvigoratorUber_Dur[2049];
new m_iInvigoratorUber_Cond1[2049] =  { -1, ... };
new m_iInvigoratorUber_Cond2[2049] =  { -1, ... };
new Float:m_flInvigoratorUber_Delay[2049];

new bool:m_bFriendlyMittens[2049];

new bool:m_bRingsOnKill[2049];
new Float:m_flRingsOnKill_Dur[2049];
new Float:m_flRingsOnKill_MaxDur[2049];
new m_iRingsOnKill_Rings[2049];
new Handle:m_hRingsOnKill_Display;

new bool:m_bRingsOnKill2[2049];
new Float:m_flRingsOnKill2_Dur[2049];
new Float:m_flRingsOnKill2_MaxDur[2049];
new m_iRingsOnKill2_Rings[2049];
new Handle:m_hRingsOnKill2_Display;

new bool:m_bBuildingUpgrade[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:m_flBuildingUpgrade_MaxCharge[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:m_flBuildingUpgrade_Charge[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:m_flBuildingUpgrade_SentryMult[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Handle:m_hBuildingUpgrade_Display;
new m_iBuilder[2049];

new bool:MinigunRevDownSpeed[2049];
new Float:MinigunRevDownSpeed_Mult[2049];
new bool:MinigunUnrevved[2049];
new bool:Revved[2049];

new bool:AimingMoveSpeedNotFiring[2049];
new Float:AimingMoveSpeedNotFiring_Mult[2049];
new Float:AimingMoveSpeedNotFiring_Dur[2049];

new bool:m_bEarthquake[MAXPLAYERS + 1][SLOTS_MAX + 1];
new bool:m_bEarthquake_Active[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:m_flEarthquake_Range[MAXPLAYERS + 1][SLOTS_MAX + 1];
new g_iExplosionSprite;
new g_iHaloSprite;
new g_iWhite;
new g_iTeamColor[4][4];
new g_iTeamColorSoft[4][4];
new Float:g_flLastTick[MAXPLAYERS + 1];
new bool:IsInSpawn[MAXPLAYERS + 1];

public OnPluginStart() {
	
	HookEvent("player_death", Event_Death);
	HookEvent("deploy_buff_banner", Event_BuffDeployed);
	HookEntityOutput("item_healthkit_small", "OnPlayerTouch", OnTouchHealthKit);
	HookEntityOutput("item_healthkit_medium", "OnPlayerTouch", OnTouchHealthKit);
	HookEntityOutput("item_healthkit_full", "OnPlayerTouch", OnTouchHealthKit);
	HookEvent("player_spawn", Event_Respawn);
	HookEvent("player_builtobject", OnConstructBuilding);
	new iSpawn = -1;
	while ((iSpawn = FindEntityByClassname(iSpawn, "func_respawnroom")) != -1)
	{
		SDKHook(iSpawn, SDKHook_StartTouch, SpawnStartTouch);
		SDKHook(iSpawn, SDKHook_EndTouch, SpawnEndTouch);
	}
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i))continue;
		{
			OnClientPutInServer(i);
		}
	}
	hudText_ElekAssure = CreateHudSynchronizer();
	RandomBuffSpell_Rage = CreateHudSynchronizer();
	CursedHeads_Display = CreateHudSynchronizer();
	SpellDisplay = CreateHudSynchronizer();
	StaminaDisplay = CreateHudSynchronizer();
	MagicDisplay = CreateHudSynchronizer();
	SkelyDisplay = CreateHudSynchronizer();
	ManaDisplay = CreateHudSynchronizer();
	RandomBuffSpell_ChargeCount = CreateHudSynchronizer();
	DashAttribRechargeBar = CreateHudSynchronizer();
	StackDisplay = CreateHudSynchronizer();
	m_hBuildingUpgrade_Display = CreateHudSynchronizer();
	m_hRingsOnKill_Display = CreateHudSynchronizer();
	m_hRingsOnKill2_Display = CreateHudSynchronizer();
	MeleeKillBoosts_Display = CreateHudSynchronizer();
	g_iTeamColor[TEAM_RED][0] = 255;
	g_iTeamColor[TEAM_RED][1] = 0;
	g_iTeamColor[TEAM_RED][2] = 0;
	g_iTeamColor[TEAM_RED][3] = 255;
	g_iTeamColor[TEAM_BLUE][0] = 0;
	g_iTeamColor[TEAM_BLUE][1] = 0;
	g_iTeamColor[TEAM_BLUE][2] = 255;
	g_iTeamColor[TEAM_BLUE][3] = 255;
	
	g_iTeamColorSoft[TEAM_RED][0] = 189;
	g_iTeamColorSoft[TEAM_RED][1] = 59;
	g_iTeamColorSoft[TEAM_RED][2] = 59;
	g_iTeamColorSoft[TEAM_RED][3] = 255;
	g_iTeamColorSoft[TEAM_BLUE][0] = 91;
	g_iTeamColorSoft[TEAM_BLUE][1] = 122;
	g_iTeamColorSoft[TEAM_BLUE][2] = 140;
	g_iTeamColorSoft[TEAM_BLUE][3] = 255;
}
public OnMapStart() {
	
	PrecacheSound("weapons/recharged.wav", true);
	PrecacheSound("player/souls_receive1.wav", true);
	PrecacheSound("misc/halloween/spell_blast_jump.wav", true);
	PrecacheSound("misc/halloween/spell_stealth.wav", true);
	PrecacheSound("misc/halloween/spell_overheal.wav", true);
	PrecacheSound("items/powerup_pickup_plague_infected.wav", true);
	PrecacheSound("items/powerup_pickup_plague_infected_loop.wav", true);
	PrecacheSound("weapons/flame_thrower_loop_crit.wav", true);
	PrecacheSound("weapons/flame_thrower_bb_start.wav", true);
	PrecacheSound("weapons/flame_thrower_bb_end.wav", true);
	PrecacheSound("mvm/mvm_revive.wav", true);
	PrecacheSound("mvm/mvm_used_powerup.wav", true);
	PrecacheSound("weapons/medigun_no_target.wav", true);
	g_iWhite = PrecacheModel("materials/sprites/white.vmt");
	g_iHaloSprite = PrecacheModel("materials/sprites/halo01.vmt");
	g_iExplosionSprite = PrecacheModel("sprites/sprite_fire01.vmt");
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_OnTakeDamageAlivePost, OnTakeDamageAlivePost);
	//SDKHook(client, SDKHook_WeaponSwitch, OnWeaponSwitch);
	SDKHook(client, SDKHook_PreThink, OnClientPreThink);
	
	LastWeaponHurtWith[client] = 0;
}

stock GetWeaponSlot(client, weapon)
{
	if (!Client_IsValid(client))return -1;
	
	for (new i = 0; i < 7; i++)
	{
		if (weapon == GetPlayerWeaponSlot(client, i))
		{
			return i;
		}
	}
	return -1;
}
stock GetClientSlot(client)
{
	if (!Client_IsValid(client))return -1;
	if (!IsPlayerAlive(client))return -1;
	
	new slot = GetWeaponSlot(client, Client_GetActiveWeapon(client));
	return slot;
}

stock GetSlotContainingAttribute(client, const attribute[][] = HasAttribute)
{
	if (!Client_IsValid(client))return false;
	
	for (new i = 0; i < SLOTS_MAX; i++)
	{
		if (m_bHasAttribute[client][i])
		{
			if (attribute[client][i])
			{
				return i;
			}
		}
	}
	
	return -1;
}

public Action:CW3_OnAddAttribute(slot, client, const String:attrib[], const String:plugin[], const String:value[], bool:whileActive)
{
	if (!StrEqual(plugin, "zethax-extras"))return Plugin_Continue;
	new weapon = GetPlayerWeaponSlot(client, slot);
	new Action:action;
	if (StrEqual(attrib, "melee kill boosts this wep"))
	{
		if (weapon == -1)return Plugin_Continue;
		new String:values[4][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		MeleeKillBoosts[weapon] = true;
		MeleeKillBoosts_MaxDurSecondary[weapon] = StringToFloat(values[0]);
		MeleeKillBoosts_MaxDurMelee[weapon] = StringToFloat(values[1]);
		MeleeKillBoosts_MaxDur[weapon] = StringToFloat(values[2]);
		MeleeKillBoosts_CondID[weapon] = StringToInt(values[3]);
		MeleeKillBoosts_Dur[weapon] = 0.0;
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "taunt grants conch effect"))
	{
		if (weapon == -1)return Plugin_Continue;
		ConchOnTaunt[weapon] = true;
		ConchOnTaunt_Drain[weapon] = StringToInt(value);
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "hp regen on kill"))
	{
		if (weapon == -1)return Plugin_Continue;
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		HPRegenOnKill[weapon] = true;
		HPRegenOnKill_HP[weapon] = StringToInt(values[0]);
		HPRegenOnKill_MaxDur[weapon] = StringToFloat(values[1]);
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "elektrical assurance"))
	{
		if (weapon == -1)return Plugin_Continue;
		ElekAssure[weapon] = true;
		ElekAssure_MaxCrits[weapon] = StringToInt(value);
		ElekAssure_Crits[weapon] = 0;
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "mod soldier buff is cleanse"))
	{
		if (weapon == -1)return Plugin_Continue;
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		GeneralReserve_Mode[weapon] = StringToInt(values[0]);
		GeneralReserve_ImmuneDur[weapon] = StringToFloat(values[1]);
		GeneralReserve_Heal[weapon] = StringToInt(values[2]);
		TF2Attrib_SetByName(weapon, "mod soldier buff type", 1.0);
		TF2Attrib_SetByName(weapon, "kill eater score type", 51.0);
		GeneralReserve[weapon] = true;
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "mod soldier buff is random spell")) {
		
		if (weapon == -1)return Plugin_Continue;
		TF2Attrib_SetByName(weapon, "mod soldier buff type", 1.0);
		TF2Attrib_SetByName(weapon, "kill eater score type", 51.0);
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		RandomSpellBuff[weapon] = true;
		RandomSpellBuff_MaxDMG[weapon] = StringToFloat(values[0]);
		RandomSpellBuff_BuffDur[weapon] = StringToFloat(values[1]);
		RandomSpellBuff_MaxCharges[weapon] = StringToInt(values[2]);
		RandomSpellBuff_Charge[weapon] = 0.0;
		RandomSpellBuff_Charges[weapon] = 0;
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "batt backup while at X health"))
	{
		BattBackupXHP[client] = true;
		BattBackupXHP_HP[client] = StringToInt(value);
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "merasmus cursed my heads"))
	{
		if (weapon == -1)return Plugin_Continue;
		CursedHeads[weapon] = true;
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		CursedHeads_MaxHeads[weapon] = StringToInt(values[0]);
		CursedHeads_Minicrits[weapon] = StringToFloat(values[1]);
		CursedHeads_Heads[weapon] = 0;
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "mod soldier buff is fire-reload"))
	{
		if (weapon == -1)return Plugin_Continue;
		AmmoBuff[weapon] = true;
		TF2Attrib_SetByName(weapon, "mod soldier buff type", 1.0);
		TF2Attrib_SetByName(weapon, "kill eater score type", 51.0);
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "buffed kills extend duration"))
	{
		if (weapon == -1)return Plugin_Continue;
		BuffedKillsBuffDur[weapon] = true;
		BuffedKillsBuffDur_Dur[weapon] = StringToFloat(value);
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "buffed team kills extend duration"))
	{
		if (weapon == -1)return Plugin_Continue;
		BuffedTKillsBuffDur[weapon] = true;
		BuffedTKillsBuffDur_Dur[weapon] = StringToFloat(value);
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "dmg resistance while hauling"))
	{
		DMGResistHauling[client][slot] = true;
		DMGResistHauling_Mult[client][slot] = StringToFloat(value);
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "multiple hits minicrit"))
	{
		if (weapon == -1)return Plugin_Continue;
		MultipleHitsMinicrit[weapon] = true;
		MultipleHitsMinicrit_Hits[weapon] = 0;
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "infectous stab"))
	{
		if (weapon == -1)return Plugin_Continue;
		new String:values[5][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		PlagueStab[weapon] = true;
		PlagueStab_MaxDur[weapon] = StringToFloat(values[0]);
		PlagueStab_Radius[weapon] = StringToFloat(values[1]);
		PlagueStab_MarkFD[weapon] = StringToInt(values[2]);
		PlagueStab_AOEMFDur[weapon] = StringToFloat(values[3]);
		PlagueStab_ImmunityMaxDur[weapon] = StringToFloat(values[4]);
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "fill shurikens on kill"))
	{
		if (weapon == -1)return Plugin_Continue;
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		KillsRefillShurikens[weapon] = true;
		KillsRefillShurikens_Count[weapon] = StringToInt(values[0]);
		KillsRefillShurikens_Max[weapon] = StringToInt(values[1]);
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "ninja set bonus"))
	{
		if (weapon == -1)return Plugin_Continue;
		NinjaSet[weapon] = true;
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "direct hit speed boost"))
	{
		if (weapon == -1)return Plugin_Continue;
		new String:values[8][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		DirectHitBonus[weapon] = true;
		DirectHitBonus_SpdDur[weapon] = StringToFloat(values[0]);
		DirectHitBonus_FireSpd[weapon] = StringToFloat(values[1]);
		DirectHitBonus_DmgPen[weapon] = StringToFloat(values[2]);
		DirectHitBonus_BlastRad[weapon] = StringToFloat(values[3]);
		DirectHitBonus_ProjSpd[weapon] = StringToFloat(values[4]);
		DirectHitBonus_MaxStacks[weapon] = StringToInt(values[5]);
		DirectHitBonus_Decay[weapon] = StringToFloat(values[6]);
		DirectHitBonus_StackDecay[weapon] = StringToFloat(values[7]);
		DirectHitBonus_Stacks[client] = 0;
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "random spell on kill"))
	{
		RandomSpellKill[client][slot] = true;
		RandomSpellKill_Spell[client][slot] = 1;
		Mana[client] = 6;
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "invis while crouching"))
	{
		InvisCrouch[client][slot] = true;
		InvisCrouch_Drain[client][slot] = StringToInt(value);
		InvisCrouch_Stamina[client] = 100;
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "magic attrib"))
	{
		new String:values[4][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		Magic[client][slot] = true;
		Magic_SpellType[client][slot] = StringToInt(values[0]);
		Magic_MaxCharges[client][slot] = StringToInt(values[1]);
		Magic_Recharge[client][slot] = StringToFloat(values[2]);
		Magic_CastDelay[client][slot] = StringToFloat(values[3]);
		Magic_Delay[client][slot] = GetEngineTime();
		
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "skeleton attrib"))
	{
		if (weapon == -1)return Plugin_Continue;
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		SkelyAttrib[weapon] = true;
		SkelyAttrib_MaxCharges[weapon] = StringToInt(values[0]);
		SkelyAttrib_CastDelay[weapon] = StringToFloat(values[1]);
		SkelyAttrib_Charges[weapon] = 0;
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "special backstab"))
	{
		if (weapon == -1)return Plugin_Continue;
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		Backstab[weapon] = true;
		TF2Attrib_SetByName(weapon, "crit from behind", 1.0);
		Backstab_DMG[weapon] = StringToFloat(values[0]);
		Backstab_BleedDur[weapon] = StringToFloat(values[1]);
		Backstab_Silent[weapon] = StringToInt(values[2]);
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "alt-fire detonates grenades"))
	{
		if (weapon == -1)return Plugin_Continue;
		AltfireDet[weapon] = true;
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "dmg penalty on all weapons"))
	{
		FatScout[client][slot] = true;
		FatScout_DMG[client][slot] = StringToFloat(value);
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "speed boost on draw"))
	{
		if (weapon == -1)return Plugin_Continue;
		SpdOnDraw[weapon] = true;
		SpdOnDraw_Dur[weapon] = StringToFloat(value);
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "bleed on hit and minicrit"))
	{
		if (weapon == -1)return Plugin_Continue;
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		BleedOnHit[weapon] = true;
		BleedOnHit_Dur[weapon] = StringToFloat(values[0]);
		BleedOnHit_Minicrit[weapon] = StringToInt(values[1]);
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "bleed damage bonus"))
	{
		m_bBleedDmgBonus[client][slot] = true;
		m_fBleedDmgBonus_Mult[client][slot] = StringToFloat(value);
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "earthquake on damaging landing"))
	{
		m_bEarthquake[client][slot] = true;
		if (whileActive)
			m_bEarthquake_Active[client][slot] = true;
		m_flEarthquake_Range[client][slot] = StringToFloat(value);
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "merasmus cursed my gun"))
	{
		if (weapon == -1)return Plugin_Continue;
		m_bDamnedMerasmus[weapon] = true;
		m_flDamnedMerasmus[weapon] = StringToFloat(value);
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "addcond while active"))
	{
		if (weapon == -1)return Plugin_Continue;
		m_bAddcondActive[weapon] = true;
		new String:values[4][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		m_iAddcondActive1[weapon] = StringToInt(values[0]);
		m_iAddcondActive2[weapon] = StringToInt(values[1]);
		m_iAddcondActive3[weapon] = StringToInt(values[2]);
		m_iAddcondActive4[weapon] = StringToInt(values[3]);
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "jetpack attrib"))
	{
		m_bEngiJetpack[client][slot] = true;
		new String:values[3][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		m_iEngiJetpack[client][slot] = StringToInt(values[0]);
		m_flEngiJetpack[client][slot] = StringToFloat(values[1]);
		m_flEngiJetpack_Spd[client][slot] = StringToFloat(values[2]);
		m_flEngiJetpack_FlightDur[client] = 0.0;
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "dash attrib"))
	{
		m_bDashAttrib[client][slot] = true;
		m_flDashAttrib_Cooldown[client][slot] = StringToFloat(value);
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "rocket flamethrower"))
	{
		m_bRocketFlamethrower[weapon] = true;
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "dmg resist on overhealed patients"))
	{
		if (weapon == -1)return Plugin_Continue;
		m_bDmgResistOverhealed[weapon] = true;
		m_flDmgResistOverhealed[weapon] = StringToFloat(value);
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "invigoration uber"))
	{
		if (weapon == -1)return Plugin_Continue;
		new String:values[5][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		m_bInvigoratorUber[weapon] = true;
		m_flInvigoratorUber_DmgBonus[weapon] = StringToFloat(values[0]);
		m_iInvigoratorUber_Cond1[weapon] = StringToInt(values[1]);
		m_iInvigoratorUber_Cond2[weapon] = StringToInt(values[2]);
		m_flInvigoratorUber_MaxDur[weapon] = StringToFloat(values[3]);
		m_flInvigoratorUber_UberRequired[weapon] = StringToFloat(values[4]);
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "friendly attrib"))
	{
		if (weapon == -1)return Plugin_Continue;
		m_bFriendlyMittens[weapon] = true;
		new secondary = GetPlayerWeaponSlot(client, 1);
		TF2Attrib_SetByName(weapon, "move speed bonus", 2.73);
		TF2Attrib_SetByName(weapon, "increase player capture value", -1);
		TF2Attrib_SetByName(weapon, "cannot pick up intelligence", 1);
		TF2Attrib_SetByName(weapon, "deploy time decreased", 0.0);
		TF2Attrib_SetByName(weapon, "cancel falling damage", 1);
		TF2Attrib_SetByName(weapon, "fire rate bonus", 0.1);
		if (secondary > -1)
			TF2Attrib_SetByName(secondary, "effect bar recharge rate increased", 0.0);
		
		TF2_AddCondition(client, TFCond:34);
		TF2Attrib_SetByName(weapon, "mod see enemy health", 1);
		TF2Attrib_SetByName(weapon, "increased jump height", 2.0);
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "rings attrib"))
	{
		if (weapon == -1)return Plugin_Continue;
		m_flRingsOnKill_MaxDur[weapon] = StringToFloat(value);
		m_bRingsOnKill[weapon] = true;
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "rings attrib 2"))
	{
		if (weapon == -1)return Plugin_Continue;
		m_flRingsOnKill2_MaxDur[weapon] = StringToFloat(value);
		m_bRingsOnKill2[weapon] = true;
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "building upgrade attrib"))
	{
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		
		m_bBuildingUpgrade[client][slot] = true;
		m_flBuildingUpgrade_MaxCharge[client][slot] = StringToFloat(values[0]);
		m_flBuildingUpgrade_SentryMult[client][slot] = StringToFloat(values[1]);
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "minigun rev down speed"))
	{
		if (weapon == -1)return Plugin_Continue;
		MinigunRevDownSpeed[weapon] = true;
		MinigunRevDownSpeed_Mult[weapon] = StringToFloat(value);
		action = Plugin_Handled;
	}
	else if (StrEqual(attrib, "aiming move speed while not firing"))
	{
		if (weapon == -1)return Plugin_Continue;
		AimingMoveSpeedNotFiring[weapon] = true;
		AimingMoveSpeedNotFiring_Mult[weapon] = StringToFloat(value);
		action = Plugin_Handled;
	}
	
	if (action == Plugin_Handled)m_bHasAttribute[client][slot] = true;
	else m_bHasAttribute[client][slot] = false;
	return action;
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3], damageCustom)
{
	if (attacker <= 0 || attacker > MaxClients)return Plugin_Continue;
	new Action:action;
	if (weapon > -1)
	{
		LastWeaponHurtWith[attacker] = weapon;
		if (MultipleHitsMinicrit[weapon])
		{
			if (MultipleHitsMinicrit_Hits[victim] == 1)
				TF2_AddCondition(victim, TFCond_MarkedForDeath, 0.01);
		}
		if (PlagueStab[weapon] && damageCustom == TF_CUSTOM_BACKSTAB && !IsInSpawn[victim])
		{
			damage = 3.3334;
			if (PlagueStab_Infector[victim] == -1)
			{
				PlagueStab_Radius[victim] = PlagueStab_Radius[weapon];
				PlagueStab_Infector[victim] = attacker;
				PlagueStab_MarkFD[victim] = PlagueStab_MarkFD[weapon];
				PlagueStab_MaxDur[victim] = PlagueStab_MaxDur[weapon];
				PlagueStab_Dur[victim] = GetEngineTime();
				PlagueStab_ImmunityMaxDur[victim] = PlagueStab_ImmunityMaxDur[weapon];
				EmitSoundToClient(attacker, "items/powerup_pickup_plague_infected.wav");
				EmitSoundToClient(victim, "items/powerup_pickup_plague_infected.wav");
				EmitSoundToClient(victim, "items/powerup_pickup_plague_infected_loop.wav");
			}
			ApplyRadiusEffects(attacker, _, _, PlagueStab_Radius[weapon], 0, _, 30, _, PlagueStab_AOEMFDur[weapon], _, 2, false, _);
			action = Plugin_Changed;
		}
		if (Backstab[weapon] && damagetype & DMG_CRIT == DMG_CRIT)
		{
			damage = (GetClientMaxHealth(victim) * Backstab_DMG[weapon]) * 0.3334;
			TF2_AddCondition(victim, TFCond_Bleeding, Backstab_BleedDur[weapon], attacker);
			if (Backstab_Silent[weapon] == 1)
			{
				TF2Attrib_SetByName(weapon, "silent killer", 1.0);
				Backstab_SilenceDur[weapon] = GetEngineTime();
			}
			action = Plugin_Changed;
		}
		if (HasAttribute(attacker, _, FatScout))
		{
			damage *= 1.0 - GetAttributeValueF(attacker, _, FatScout, FatScout_DMG, false);
			action = Plugin_Changed;
		}
		if (BleedOnHit[weapon] && TF2_IsPlayerInCondition(victim, TFCond_Bleeding) && BleedOnHit_Minicrit[weapon] >= 1)
		{
			TF2_AddCondition(victim, TFCond_MarkedForDeathSilent, 0.05, attacker);
		}
		if (HasAttribute(attacker, _, m_bBleedDmgBonus) && damageCustom == TF_CUSTOM_BLEEDING)
		{
			damage *= GetAttributeValueF(attacker, _, m_bBleedDmgBonus, m_fBleedDmgBonus_Mult);
			action = Plugin_Changed;
		}
		if (GetEngineTime() <= m_flInvigoratorUber_Dur[attacker] + m_flInvigoratorUber_MaxDur[attacker])
		{
			damage *= m_flInvigoratorUber_DmgBonus[attacker];
			action = Plugin_Changed;
		}
	}
	if (m_flDmgResistOverhealed[victim] != 1.0 && GetClientHealth(victim) > GetClientMaxHealth(victim))
	{
		damage *= m_flDmgResistOverhealed[victim];
		action = Plugin_Changed;
	}
	return action;
}

public OnTakeDamagePost(victim, attacker, inflictor, Float:damage, damagetype, weapon, Float:damageForce[3], Float:damagePosition[3], damageCustom)
{
	if (!Client_IsValid(attacker))return;
	if (weapon == -1)return;
	new team = GetClientTeam(attacker);
	if (ElekAssure[weapon] && damagetype & DMG_CRIT && ElekAssure_Crits[weapon] > 0)
	{
		ElekAssure_Crits[weapon]--;
	}
	if (MultipleHitsMinicrit[weapon] && MultipleHitsMinicrit_Hits[victim] < 1)
	{
		MultipleHitsMinicrit_Hits[victim]++;
		MultipleHitsMinicrit_Delay[victim] = GetEngineTime();
	}
	if (HasAttribute(victim, _, Magic))
	{
		new slot = GetSlotContainingAttribute(victim, Magic);
		Magic_Delay[victim][slot] = GetEngineTime();
	}
	if (BleedOnHit[weapon])
	{
		TF2_AddCondition(victim, TFCond:25, BleedOnHit_Dur[weapon], attacker);
		TF2_AddCondition(victim, TFCond_Bleeding, BleedOnHit_Dur[weapon], attacker);
	}
	if (DirectHitBonus[weapon] && GetClientTeam(victim) != team)
	{
		TF2_AddCondition(attacker, TFCond_SpeedBuffAlly, DirectHitBonus_SpdDur[weapon]);
		if (DirectHitBonus_Stacks[attacker] < DirectHitBonus_MaxStacks[weapon])
		{
			DirectHitBonus_Stacks[attacker]++;
		}
		DirectHitBonus_Dur[weapon] = GetEngineTime();
	}
	if (damagetype & DMG_FALL)
	{
		new slot = GetClientSlot(victim);
		if (m_bEarthquake_Active[victim][slot])
		{
			CreateEarthquake(victim, slot);
		}
	}
	if (m_bDamnedMerasmus[weapon] && GetClientTeam(victim) != team && damage >= 1.0)
	{
		new effects[9] =  { 1, 2, 3, 4, 5, 6, 7, 8, 9 };
		new effectchoice = GetRandomInt(0, 8);
		
		if (effects[effectchoice] == 1) //Mini + restricted to melee
		{
			TF2_AddCondition(victim, TFCond:85, m_flDamnedMerasmus[weapon], attacker);
		}
		else if (effects[effectchoice] == 2) //Bumper-car-ed
		{
			TF2_AddCondition(victim, TFCond:82, m_flDamnedMerasmus[weapon], attacker);
		}
		else if (effects[effectchoice] == 3) //Turned into a dispenser
		{
			TF2_AddCondition(victim, TFCond:87, m_flDamnedMerasmus[weapon], attacker);
			TF2_AddCondition(victim, TFCond:49, m_flDamnedMerasmus[weapon], attacker);
		}
		else if (effects[effectchoice] == 4) //Turned into a ghost
		{
			TF2_AddCondition(victim, TFCond:77, m_flDamnedMerasmus[weapon], attacker);
			TF2_AddCondition(victim, TFCond:52, m_flDamnedMerasmus[weapon] + 3.6, attacker);
			TF2_AddCondition(victim, TFCond:32, m_flDamnedMerasmus[weapon] + 3.6, attacker);
			TF2_AddCondition(victim, TFCond:44, m_flDamnedMerasmus[weapon] + 3.6, attacker);
		}
		else if (effects[effectchoice] == 5) //Big headed wanker + swimming in air
		{
			TF2_AddCondition(victim, TFCond:86, m_flDamnedMerasmus[weapon], attacker);
			TF2_AddCondition(victim, TFCond:84, m_flDamnedMerasmus[weapon], attacker);
		}
		else if (effects[effectchoice] == 6) //Minify spell
		{
			TF2_AddCondition(victim, TFCond:72, m_flDamnedMerasmus[weapon], attacker);
			TF2_AddCondition(victim, TFCond:75, m_flDamnedMerasmus[weapon], attacker);
		}
		else if (effects[effectchoice] == 7) //Charge
		{
			TF2_AddCondition(victim, TFCond:17, 2.0, attacker);
			TF2_AddCondition(victim, TFCond:34, 2.0, attacker);
			TF2_AddCondition(victim, TFCond:18, 2.0, attacker);
			TF2_AddCondition(victim, TFCond:41, 2.0, attacker);
		}
		else if (effects[effectchoice] == 8) //Blasted into the air + stun + parachute
		{
			new Float:velocity[3];
			GetEntPropVector(victim, Prop_Data, "m_vecVelocity", velocity);
			velocity[2] += 1000.0;
			
			TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, velocity);
			TF2_AddCondition(victim, TFCond:15, m_flDamnedMerasmus[weapon], attacker);
			TF2_AddCondition(victim, TFCond_Dazed, m_flDamnedMerasmus[weapon], attacker);
			CreateTimer(1.0, ApplyParachute, EntIndexToEntRef(victim), TIMER_FLAG_NO_MAPCHANGE);
		}
		else if (effects[effectchoice] == 9) //Mystery sauce
		{
			TF2_AddCondition(victim, TFCond:24, m_flDamnedMerasmus[weapon], attacker);
			TF2_AddCondition(victim, TFCond:27, m_flDamnedMerasmus[weapon], attacker);
			TF2_AddCondition(victim, TFCond_Bleeding, m_flDamnedMerasmus[weapon], attacker);
		}
	}
}

public OnTakeDamageAlivePost(victim, attacker, inflictor, Float:damage, damagetype, weapon, const Float:damageForce[3], const Float:damagePosition[3])
{
	if (attacker <= 0 || attacker > MaxClients)return Plugin_Continue;
	if (victim <= 0 || victim > MaxClients)return Plugin_Continue;
	if (GetClientTeam(attacker) == GetClientTeam(victim))return Plugin_Continue;
	if (attacker == victim)return Plugin_Continue;
	new secondary = GetPlayerWeaponSlot(attacker, 1);
	if (secondary > -1 && RandomSpellBuff[secondary] && RandomSpellBuff_Charge[secondary] < RandomSpellBuff_MaxDMG[secondary] && damage >= 1.0 && GetEngineTime() >= RandomSpellBuff_Dur[attacker] + RandomSpellBuff_BuffDur[secondary] && attacker != victim)
	{
		RandomSpellBuff_Charge[secondary] += damage;
	}
	if (HasAttribute(attacker, _, m_bBuildingUpgrade))
	{
		new slot = GetSlotContainingAttribute(attacker, m_bBuildingUpgrade);
		new String:class[50];
		if (!IsValidEdict(inflictor))return Plugin_Continue;
		GetEdictClassname(inflictor, class, sizeof(class));
		if (!StrContains(class, "obj_sentrygun") || damagetype == 2359360)
		{
			m_flBuildingUpgrade_Charge[attacker][slot] += damage * m_flBuildingUpgrade_SentryMult[attacker][slot];
		}
		else m_flBuildingUpgrade_Charge[attacker][slot] += damage;
		if (m_flBuildingUpgrade_Charge[attacker][slot] > m_flBuildingUpgrade_MaxCharge[attacker][slot])m_flBuildingUpgrade_Charge[attacker][slot] = m_flBuildingUpgrade_MaxCharge[attacker][slot];
	}
	return Plugin_Continue;
}

public Action:TF2_CalcIsAttackCritical(client, weapon, String:weaponname[], &bool:result)
{
	if (weapon == -1)return Plugin_Continue;
	if (m_bRocketFlamethrower[weapon])
	{
		new Float:pos[3], Float:ang[3];
		GetClientEyePosition(client, pos);
		GetClientEyeAngles(client, ang);
		
		new Float:vel[3];
		GetAngleVectors(ang, vel, NULL_VECTOR, NULL_VECTOR);
		NormalizeVector(vel, vel);
		ScaleVector(vel, 25.0);
		new Float:velocity[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);
		velocity[0] += vel[0];
		velocity[1] += vel[1];
		velocity[2] += vel[2];
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
	}
	if (AimingMoveSpeedNotFiring[weapon])
	{
		TF2Attrib_RemoveByName(weapon, "aiming movespeed increased");
		AimingMoveSpeedNotFiring_Dur[weapon] = GetEngineTime();
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.01);
	}
	return Plugin_Continue;
}

public Action:Event_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if (attacker && attacker != victim)
	{
		new sec = GetPlayerWeaponSlot(attacker, 1);
		new mel = GetPlayerWeaponSlot(attacker, 2);
		new weapon = LastWeaponHurtWith[attacker];
		if (HPRegenOnKill[weapon])
		{
			HPRegenOnKill_Dur[weapon] = GetEngineTime();
		}
		if (CursedHeads[weapon] && CursedHeads_Heads[weapon] < CursedHeads_MaxHeads[weapon] && GetEngineTime() >= CursedHeads_Dur[weapon] + CursedHeads_Minicrits[weapon])
		{
			CursedHeads_Heads[weapon]++;
		}
		new pri = GetPlayerWeaponSlot(attacker, 0);
		if (mel > -1 && pri > -1 && weapon == mel && MeleeKillBoosts[pri])
		{
			MeleeKillBoosts_Dur[pri] += MeleeKillBoosts_MaxDurMelee[pri];
		}
		if (sec > -1 && pri > -1 && weapon == sec && MeleeKillBoosts[pri])
		{
			MeleeKillBoosts_Dur[pri] += MeleeKillBoosts_MaxDurSecondary[pri];
		}
		if (GetEntProp(attacker, Prop_Send, "m_nNumHealers") > 0)
		{
			for (new i = 1; i <= MaxClients; i++)
			{
				if (attacker == i)continue;
				if (!IsValidClient(i))continue;
				if (!IsPlayerAlive(i))continue;
				if (attacker != GetMediGunPatient(i))continue;
				new melee = GetPlayerWeaponSlot(i, 2);
				new secondary = GetPlayerWeaponSlot(i, 1);
				if (!ElekAssure[melee])continue;
				if (!GetEntProp(secondary, Prop_Send, "m_bChargeRelease"))continue;
				ElekAssure_Crits[melee]++;
				break;
			}
		}
		if (mel > -1 && ElekAssure[mel] && !TF2_IsPlayerInCondition(attacker, TFCond_CritCanteen))
		{
			ElekAssure_Crits[mel]++;
		}
		if (BuffDeployed[attacker])
		{
			if (BuffedKillsBuffDur[sec])
			{
				SetEntPropFloat(attacker, Prop_Send, "m_flRageMeter", GetEntPropFloat(attacker, Prop_Send, "m_flRageMeter") + BuffedKillsBuffDur_Dur[sec]);
			}
			if (BuffedKillsBuffDur[weapon])
			{
				SetEntPropFloat(attacker, Prop_Send, "m_flRageMeter", GetEntPropFloat(attacker, Prop_Send, "m_flRageMeter") + BuffedKillsBuffDur_Dur[weapon]);
			}
			if (GetEntPropFloat(attacker, Prop_Send, "m_flRageMeter") > 100.0)
				SetEntPropFloat(attacker, Prop_Send, "m_flRageMeter", 100.0);
		}
		for (new i = 1; i <= MaxClients; i++)
		{
			new team = GetClientTeam(attacker);
			new Float:Pos1[3];
			GetClientAbsOrigin(attacker, Pos1);
			if (IsValidClient(i) && GetClientTeam(i) == team && i != attacker && BuffDeployed[i])
			{
				new Float:Pos2[3];
				GetClientAbsOrigin(i, Pos2);
				new Float:distance = GetVectorDistance(Pos1, Pos2);
				if (distance <= 450.0)
				{
					new buffowner = GetPlayerWeaponSlot(i, 1);
					new buffownerwep = Client_GetActiveWeapon(i);
					if (!BuffedTKillsBuffDur[buffowner] || !BuffedTKillsBuffDur[buffownerwep])continue;
					SetEntPropFloat(i, Prop_Send, "m_flRageMeter", GetEntPropFloat(i, Prop_Send, "m_flRageMeter") + BuffedTKillsBuffDur_Dur[buffowner]);
					SetEntPropFloat(i, Prop_Send, "m_flRageMeter", GetEntPropFloat(i, Prop_Send, "m_flRageMeter") + BuffedTKillsBuffDur_Dur[buffownerwep]);
					if (GetEntPropFloat(i, Prop_Send, "m_flRageMeter") > 100.0)
						SetEntPropFloat(i, Prop_Send, "m_flRageMeter", 100.0);
				}
			}
		}
		if (DirectHitBonus[weapon])
		{
			if (DirectHitBonus_Stacks[attacker] < DirectHitBonus_MaxStacks[weapon])
			{
				DirectHitBonus_Stacks[attacker]++;
				if (DirectHitBonus_Stacks[attacker] > DirectHitBonus_MaxStacks[weapon])DirectHitBonus_Stacks[attacker] = DirectHitBonus_MaxStacks[weapon];
			}
		}
		if (KillsRefillShurikens[weapon] && NinjaSet[sec])
		{
			new clip = GetClip_Weapon(sec);
			new ammo = GetAmmo_Weapon(sec);
			SetClip_Weapon(sec, clip + KillsRefillShurikens_Count[weapon]);
			SetAmmo_Weapon(sec, ammo + KillsRefillShurikens_Count[weapon]);
			new newclip = GetClip_Weapon(sec);
			new newammo = GetAmmo_Weapon(sec);
			if (newclip > KillsRefillShurikens_Max[weapon] || newammo > KillsRefillShurikens_Max[weapon])
			{
				SetClip_Weapon(sec, KillsRefillShurikens_Max[weapon]);
				SetAmmo_Weapon(sec, KillsRefillShurikens_Max[weapon]);
			}
		}
		if (SkelyAttrib[weapon] && SkelyAttrib_Charges[weapon] < SkelyAttrib_MaxCharges[weapon])
		{
			SkelyAttrib_Charges[weapon]++;
		}
		if (SpdOnDraw[weapon])
		{
			TF2_AddCondition(attacker, TFCond_SpeedBuffAlly, SpdOnDraw_Dur[weapon]);
			TF2_AddCondition(attacker, TFCond:41, SpdOnDraw_Dur[weapon]);
			SpdOnDraw_SheathDur[weapon] = GetEngineTime();
		}
		if (m_bDamnedMerasmus[weapon])
		{
			new effects[8] =  { 1, 2, 3, 4, 5, 6, 7, 8 };
			new effectchoice = GetRandomInt(0, 7);
			
			if (effects[effectchoice] == 1)
			{
				TF2_AddCondition(attacker, TFCond:85, m_flDamnedMerasmus[weapon] * 2.0, attacker);
			}
			else if (effects[effectchoice] == 2)
			{
				TF2_AddCondition(attacker, TFCond:82, m_flDamnedMerasmus[weapon] * 2.0, attacker);
			}
			else if (effects[effectchoice] == 3)
			{
				TF2_AddCondition(attacker, TFCond:87, m_flDamnedMerasmus[weapon], attacker);
				TF2_AddCondition(attacker, TFCond:49, m_flDamnedMerasmus[weapon], attacker);
			}
			else if (effects[effectchoice] == 4)
			{
				TF2_AddCondition(attacker, TFCond:77, m_flDamnedMerasmus[weapon] * 2.0, attacker);
				TF2_AddCondition(victim, TFCond:52, m_flDamnedMerasmus[weapon] * 2.0 + 3.6, attacker);
				TF2_AddCondition(victim, TFCond:32, m_flDamnedMerasmus[weapon] * 2.0 + 3.6, attacker);
				TF2_AddCondition(victim, TFCond:44, m_flDamnedMerasmus[weapon] * 2.0 + 3.6, attacker);
			}
			else if (effects[effectchoice] == 5)
			{
				TF2_AddCondition(attacker, TFCond:86, m_flDamnedMerasmus[weapon] * 2.0, attacker);
				TF2_AddCondition(attacker, TFCond:84, m_flDamnedMerasmus[weapon] * 2.0, attacker);
			}
			else if (effects[effectchoice] == 6)
			{
				TF2_AddCondition(attacker, TFCond:72, m_flDamnedMerasmus[weapon] * 2.0, attacker);
				TF2_AddCondition(attacker, TFCond:75, m_flDamnedMerasmus[weapon] * 2.0, attacker);
			}
			else if (effects[effectchoice] == 7)
			{
				new Float:velocity[3];
				GetEntPropVector(attacker, Prop_Data, "m_vecVelocity", velocity);
				velocity[2] += 1000.0;
				
				TeleportEntity(attacker, NULL_VECTOR, NULL_VECTOR, velocity);
				CreateTimer(1.0, ApplyParachute, EntIndexToEntRef(attacker), TIMER_FLAG_NO_MAPCHANGE);
			}
			else if (effects[effectchoice] == 8)
			{
				TF2_AddCondition(attacker, TFCond:24, m_flDamnedMerasmus[weapon], attacker);
				TF2_AddCondition(attacker, TFCond:27, m_flDamnedMerasmus[weapon], attacker);
				TF2_AddCondition(attacker, TFCond_Bleeding, m_flDamnedMerasmus[weapon], attacker);
			}
		}
		if (m_bRingsOnKill[weapon] && m_iRingsOnKill_Rings[weapon] < 5 && GetEngineTime() > m_flRingsOnKill_Dur[weapon] + m_flRingsOnKill_MaxDur[weapon])
		{
			m_iRingsOnKill_Rings[weapon]++;
		}
		if (m_bRingsOnKill2[weapon] && m_iRingsOnKill2_Rings[weapon] < 5 && GetEngineTime() > m_flRingsOnKill2_Dur[weapon] + m_flRingsOnKill2_MaxDur[weapon])
		{
			m_iRingsOnKill2_Rings[weapon]++;
		}
	}
	StopSound(victim, SNDCHAN_AUTO, "items/powerup_pickup_plague_infected_loop.wav");
	PlagueStab_Infector[victim] = -1;
	PlagueStab_Radius[victim] = 0.0;
	PlagueStab_MarkFD[victim] = 0;
	PlagueStab_Dur[victim] = 0.0;
	PlagueStab_MaxDur[victim] = 0.0;
	PlagueStab_ImmunityMaxDur[victim] = 0.0;
}

public Action:ApplyParachute(Handle:timer, any:ref)
{
	new client = EntRefToEntIndex(ref);
	if (!Client_IsValid(client) && !IsPlayerAlive(client))return Plugin_Stop;
	TF2_AddCondition(client, TFCond:80, TFCondDuration_Infinite, client);
	return Plugin_Stop;
}

public Action:Event_Respawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (!Client_IsValid(client))return;
	if (GetEngineTime() <= PlagueStab_Dur[client] + PlagueStab_MaxDur[client] || PlagueStab_Infector[client] > -1)
	{
		StopSound(client, SNDCHAN_AUTO, "items/powerup_pickup_plague_infected_loop.wav");
		PlagueStab_Infector[client] = -1;
		PlagueStab_Radius[client] = 0.0;
		PlagueStab_MarkFD[client] = 0;
		PlagueStab_Dur[client] = PlagueStab_MaxDur[client];
		PlagueStab_ImmunityDur[client] = GetEngineTime();
	}
}

public Action:OnConstructBuilding(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	new building = GetEventInt(event, "index");
	m_iBuilder[building] = client;
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:ang[3], &weapon2)
{
	if (!IsValidClient(client))return Plugin_Continue;
	new weapon = GetEntPropEnt(client, Prop_Send, "m_hActiveWeapon");
	if (weapon <= 0 || weapon > 2048)return Plugin_Continue;
	
	if (NinjaSet[weapon] && (buttons & IN_ATTACK3) == IN_ATTACK3 && GetEngineTime() >= LungeCooldown[client] + 5.0)
	{
		TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, NULL_VECTOR);
		LungeCooldown[client] = GetEngineTime();
	}
	if (HasAttribute(client, _, InvisCrouch, false) && GetEngineTime() >= InvisCrouch_Delay[client] + (1.0 / GetAttributeValueI(client, _, InvisCrouch, InvisCrouch_Drain, false)) && (buttons & IN_DUCK) == IN_DUCK)
	{
		if (InvisCrouch_Stamina[client] > 0)
		{
			TF2_AddCondition(client, TFCond:66, 0.2);
			InvisCrouch_Stamina[client]--;
		}
		InvisCrouch_Delay[client] = GetEngineTime();
		InvisCrouch_Regen[client] = GetEngineTime() - 1.0;
	}
	if (HasAttribute(client, _, RandomSpellKill))
	{
		new slot = GetSlotContainingAttribute(client, RandomSpellKill);
		SetHudTextParams(0.6, 0.6, 0.2, 255, 255, 255, 255);
		ShowSyncHudText(client, ManaDisplay, "Mana: %i / 6", Mana[client]);
		new manacost;
		if (RandomSpellKill_Spell[client][slot] == 1)
		{
			SetHudTextParams(-1.0, 0.6, 0.2, 255, 255, 255, 255);
			ShowSyncHudText(client, SpellDisplay, "Current spell: Uber Heal\nCosts 6 Mana");
			manacost = 6;
			if (buttons & IN_RELOAD == IN_RELOAD && GetEngineTime() >= SwitchDelay[client] + 0.25)
			{
				RandomSpellKill_Spell[client][slot]++;
				SwitchDelay[client] = GetEngineTime();
			}
		}
		else if (RandomSpellKill_Spell[client][slot] == 2)
		{
			SetHudTextParams(-1.0, 0.6, 0.2, 255, 255, 255, 255);
			ShowSyncHudText(client, SpellDisplay, "Current spell: Super Jump\nCosts 2 Mana");
			manacost = 2;
			if (buttons & IN_RELOAD == IN_RELOAD && GetEngineTime() >= SwitchDelay[client] + 0.25)
			{
				RandomSpellKill_Spell[client][slot]++;
				SwitchDelay[client] = GetEngineTime();
			}
		}
		else if (RandomSpellKill_Spell[client][slot] == 3)
		{
			SetHudTextParams(-1.0, 0.6, 0.2, 255, 255, 255, 255);
			ShowSyncHudText(client, SpellDisplay, "Current spell: Invisibility\nCosts 4 Mana");
			manacost = 4;
			if (buttons & IN_RELOAD == IN_RELOAD && GetEngineTime() >= SwitchDelay[client] + 0.25)
			{
				RandomSpellKill_Spell[client][slot] = 1;
				SwitchDelay[client] = GetEngineTime();
			}
		}
		if (buttons & IN_ATTACK2 == IN_ATTACK2 && Mana[client] >= manacost && GetEngineTime() >= SpellDelay[client] + 1.5)
		{
			new team = GetClientTeam(client);
			for (new i = 1; i <= MaxClients; i++)
			{
				new Float:Pos1[3];
				GetClientAbsOrigin(client, Pos1);
				if (IsValidClient(i) && GetClientTeam(i) == team)
				{
					new Float:Pos2[3];
					GetClientAbsOrigin(i, Pos2);
					new Float:distance = GetVectorDistance(Pos1, Pos2);
					if (distance <= 225.0)
					{
						if (RandomSpellKill_Spell[client][slot] == 1)
						{
							TF2_AddCondition(i, TFCond_UberchargedCanteen, 1.5, client);
							TF2_AddCondition(i, TFCond:73, 3.0, client);
							EmitSoundToClient(i, "misc/halloween/spell_overheal.wav", client);
							Mana[client] -= manacost;
							ManaDisable[client] = GetEngineTime();
						}
						else if (RandomSpellKill_Spell[client][slot] == 2)
						{
							new Float:velocity[3];
							GetEntPropVector(i, Prop_Data, "m_vecVelocity", velocity);
							velocity[2] += 900.0;
							
							TeleportEntity(i, NULL_VECTOR, NULL_VECTOR, velocity);
							EmitSoundToClient(i, "misc/halloween/spell_blast_jump.wav", client);
							Mana[client] -= manacost;
							ManaDisable[client] = GetEngineTime();
						}
						else if (RandomSpellKill_Spell[client][slot] == 3)
						{
							TF2_AddCondition(i, TFCond:66, 8.0, client);
							EmitSoundToClient(i, "misc/halloween/spell_stealth.wav", client);
							Mana[client] -= manacost;
							ManaDisable[client] = GetEngineTime();
						}
					}
				}
				if (i >= MaxClients)SpellDelay[client] = GetEngineTime();
			}
		}
		if (Mana[client] < 6 && GetEngineTime() >= ManaRegen[client] + 1.5 && GetEngineTime() >= ManaDisable[client] + 5.0)
		{
			Mana[client]++;
			ManaRegen[client] = GetEngineTime();
		}
	}
	if (HasAttribute(client, _, Magic))
	{
		new slot = GetSlotContainingAttribute(client, Magic);
		if (GetEngineTime() >= Magic_Delay[client][slot] + Magic_Recharge[client][slot])
		{
			Magic_Charges[client][slot]++;
			Magic_Delay[client][slot] = GetEngineTime();
		}
		if (Magic_Charges[client][slot] == Magic_MaxCharges[client][slot])
		{
			Magic_Delay[client][slot] = GetEngineTime();
		}
		if (Magic_Charges[client][slot] > 0 && buttons & IN_ATTACK2 == IN_ATTACK2 && GetEngineTime() >= Magic_SpellDelay[client][slot] + Magic_CastDelay[client][slot])
		{
			new Handle:hWeapon = TF2Items_CreateItem(OVERRIDE_ALL);
			TF2Items_SetClassname(hWeapon, "tf_weapon_spellbook");
			TF2Items_SetItemIndex(hWeapon, 1069);
			TF2Items_SetLevel(hWeapon, 1);
			TF2Items_SetQuality(hWeapon, 0);
			TF2Items_SetNumAttributes(hWeapon, 0);
			
			new entity = TF2Items_GiveNamedItem(client, hWeapon);
			CloseHandle(hWeapon);
			EquipPlayerWeapon(client, entity);
			
			SetEntProp(entity, Prop_Send, "m_iSelectedSpellIndex", Magic_SpellType[client][slot]);
			SetEntProp(entity, Prop_Send, "m_iSpellCharges", 1);
			new spellbook = GetPlayerWeaponSlot(client, 5);
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", spellbook);
			
			CreateTimer(1.25, Timer_RemoveEnt, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(1.25, Timer_SwitchBack, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
			
			Magic_Charges[client][slot]--;
			Magic_Delay[client][slot] = GetEngineTime();
			Magic_SpellDelay[client][slot] = GetEngineTime();
		}
		SetHudTextParams(-1.0, 0.6, 0.2, 255, 255, 255, 255);
		ShowSyncHudText(client, MagicDisplay, "Spell Charges: %i / %i", Magic_Charges[client][slot], Magic_MaxCharges[client][slot]);
	}
	if (SkelyAttrib[weapon])
	{
		SetHudTextParams(-1.0, 0.7, 0.2, 255, 255, 255, 255);
		ShowSyncHudText(client, SkelyDisplay, "Souls: %i / %i", SkelyAttrib_Charges[weapon], SkelyAttrib_MaxCharges[weapon]);
		if (SkelyAttrib_Charges[weapon] > 0 && GetEngineTime() >= SkelyAttrib_Cooldown[weapon] + SkelyAttrib_CastDelay[weapon] && buttons & IN_ATTACK3 == IN_ATTACK3)
		{
			new Handle:hWeapon = TF2Items_CreateItem(OVERRIDE_ALL);
			TF2Items_SetClassname(hWeapon, "tf_weapon_spellbook");
			TF2Items_SetItemIndex(hWeapon, 1069);
			TF2Items_SetLevel(hWeapon, 1);
			TF2Items_SetQuality(hWeapon, 0);
			TF2Items_SetNumAttributes(hWeapon, 0);
			
			new entity = TF2Items_GiveNamedItem(client, hWeapon);
			CloseHandle(hWeapon);
			EquipPlayerWeapon(client, entity);
			
			SetEntProp(entity, Prop_Send, "m_iSelectedSpellIndex", 11);
			SetEntProp(entity, Prop_Send, "m_iSpellCharges", 1);
			new spellbook = GetPlayerWeaponSlot(client, 5);
			SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", spellbook);
			
			CreateTimer(1.25, Timer_RemoveEnt, EntIndexToEntRef(entity), TIMER_FLAG_NO_MAPCHANGE);
			CreateTimer(1.25, Timer_SwitchBack, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
			
			SkelyAttrib_Charges[weapon]--;
			SkelyAttrib_Cooldown[weapon] = GetEngineTime();
		}
	}
	if (AltfireDet[weapon])
	{
		if ((buttons & IN_ATTACK2) == IN_ATTACK2)
			TF2Attrib_SetByName(weapon, "fuse bonus", 0.1);
		else
			TF2Attrib_RemoveByName(weapon, "fuse bonus");
	}
	if (TF2_IsPlayerInCondition(client, TFCond:49) && TF2_IsPlayerInCondition(client, TFCond:87))
	{
		buttons = IN_DUCK;
		return Plugin_Changed;
	}
	if (HasAttribute(client, _, m_bDashAttrib))
	{
		new Float:velocity[3];
		GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);
		new slot = GetSlotContainingAttribute(client, m_bDashAttrib);
		if ((buttons & IN_ATTACK3) == IN_ATTACK3 && GetEngineTime() >= GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Delay) + GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Cooldown))
		{
			new Float:pos[3], Float:angles[3];
			GetClientEyePosition(client, pos);
			GetClientEyeAngles(client, angles);
			
			new Float:vec[3];
			GetAngleVectors(angles, vec, NULL_VECTOR, NULL_VECTOR);
			NormalizeVector(vec, vec);
			ScaleVector(vec, 500.0);
			if (velocity[2] == 0.0)vec[2] = 300.0;
			else vec[2] = 0.0;
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vec);
			TF2_AddCondition(client, TFCond:79, 1.0);
			TF2_AddCondition(client, TFCond_SpeedBuffAlly, 1.0);
			m_flDashAttrib_Delay[client][slot] = GetEngineTime();
		}
		if (GetEngineTime() >= GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Delay) + GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Cooldown) && GetEngineTime() <= GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Delay) + (GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Cooldown) + 0.01))
		{
			EmitSoundToClient(client, "weapons/recharged.wav");
		}
		if (GetEngineTime() <= GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Delay) + (GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Cooldown) * 0.1))
		{
			SetHudTextParams(-1.0, 0.65, 0.2, 255, 32, 32, 255);
			ShowSyncHudText(client, DashAttribRechargeBar, "==========");
		}
		else if (GetEngineTime() >= GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Delay) + (GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Cooldown) * 0.1) && GetEngineTime() <= GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Delay) + (GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Cooldown) * 0.2))
		{
			SetHudTextParams(-1.0, 0.65, 0.2, 255, 32, 32, 255);
			ShowSyncHudText(client, DashAttribRechargeBar, "[]=========");
		}
		else if (GetEngineTime() >= GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Delay) + (GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Cooldown) * 0.2) && GetEngineTime() <= GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Delay) + (GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Cooldown) * 0.3))
		{
			SetHudTextParams(-1.0, 0.65, 0.2, 255, 64, 64, 255);
			ShowSyncHudText(client, DashAttribRechargeBar, "[=]========");
		}
		else if (GetEngineTime() >= GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Delay) + (GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Cooldown) * 0.3) && GetEngineTime() <= GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Delay) + (GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Cooldown) * 0.4))
		{
			SetHudTextParams(-1.0, 0.65, 0.2, 255, 128, 128, 255);
			ShowSyncHudText(client, DashAttribRechargeBar, "[==]=======");
		}
		else if (GetEngineTime() >= GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Delay) + (GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Cooldown) * 0.4) && GetEngineTime() <= GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Delay) + (GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Cooldown) * 0.5))
		{
			SetHudTextParams(-1.0, 0.65, 0.2, 64, 64, 0, 255);
			ShowSyncHudText(client, DashAttribRechargeBar, "[===]======");
		}
		else if (GetEngineTime() >= GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Delay) + (GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Cooldown) * 0.5) && GetEngineTime() <= GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Delay) + (GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Cooldown) * 0.6))
		{
			SetHudTextParams(-1.0, 0.65, 0.2, 128, 128, 0, 255);
			ShowSyncHudText(client, DashAttribRechargeBar, "[====]=====");
		}
		else if (GetEngineTime() >= GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Delay) + (GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Cooldown) * 0.6) && GetEngineTime() <= GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Delay) + (GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Cooldown) * 0.7))
		{
			SetHudTextParams(-1.0, 0.65, 0.2, 255, 255, 0, 255);
			ShowSyncHudText(client, DashAttribRechargeBar, "[=====]====");
		}
		else if (GetEngineTime() >= GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Delay) + (GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Cooldown) * 0.7) && GetEngineTime() <= GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Delay) + (GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Cooldown) * 0.8))
		{
			SetHudTextParams(-1.0, 0.65, 0.2, 192, 255, 192, 255);
			ShowSyncHudText(client, DashAttribRechargeBar, "[======]===");
		}
		else if (GetEngineTime() >= GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Delay) + (GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Cooldown) * 0.8) && GetEngineTime() <= GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Delay) + (GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Cooldown) * 0.9))
		{
			SetHudTextParams(-1.0, 0.65, 0.2, 128, 255, 128, 255);
			ShowSyncHudText(client, DashAttribRechargeBar, "[=======]==");
		}
		else if (GetEngineTime() >= GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Delay) + (GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Cooldown) * 0.9) && GetEngineTime() <= GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Delay) + GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Cooldown))
		{
			SetHudTextParams(-1.0, 0.65, 0.2, 64, 255, 64, 255);
			ShowSyncHudText(client, DashAttribRechargeBar, "[========]=");
		}
		else if (GetEngineTime() >= GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Delay) + GetAttributeValueF(client, _, m_bDashAttrib, m_flDashAttrib_Cooldown))
		{
			SetHudTextParams(-1.0, 0.65, 0.2, 0, 255, 0, 255);
			ShowSyncHudText(client, DashAttribRechargeBar, "[=========]");
		}
	}
	if (HasAttribute(client, _, m_bBuildingUpgrade))
	{
		new slot = GetSlotContainingAttribute(client, m_bBuildingUpgrade);
		if (m_flBuildingUpgrade_Charge[client][slot] >= m_flBuildingUpgrade_MaxCharge[client][slot] && (buttons & IN_ATTACK3) == IN_ATTACK3)
		{
			for (new i = 1; i < 2048; i++)
			{
				new String:class[50];
				if (!IsValidEdict(i))continue;
				GetEdictClassname(i, class, sizeof(class));
				if (!StrContains(class, "obj_sentrygun") || !StrContains(class, "obj_dispenser") || !StrContains(class, "obj_teleporter"))
				{
					if (m_iBuilder[i] == client)
					{
						if (!StrContains(class, "obj_sentrygun"))
						{
							if (GetEntProp(i, Prop_Send, "m_iHighestUpgradeLevel") < 3)PrintToChat(client, "Your SENTRY was upgraded!");
							else if (GetEntProp(i, Prop_Send, "m_iHighestUpgradeLevel") == 3 && GetEntProp(i, Prop_Data, "m_iHealth") < GetEntProp(i, Prop_Data, "m_iMaxHealth"))PrintToChat(client, "Your SENTRY was healed!");
						}
						if (!StrContains(class, "obj_dispenser"))
						{
							if (GetEntProp(i, Prop_Send, "m_iHighestUpgradeLevel") < 3)PrintToChat(client, "Your DISPENSER was upgraded!");
							else if (GetEntProp(i, Prop_Send, "m_iHighestUpgradeLevel") == 3 && GetEntProp(i, Prop_Data, "m_iHealth") < GetEntProp(i, Prop_Data, "m_iMaxHealth"))PrintToChat(client, "Your DISPENSER was healed!");
						}
						if (!StrContains(class, "obj_teleporter"))
						{
							if (GetEntProp(i, Prop_Send, "m_iHighestUpgradeLevel") < 3)PrintToChat(client, "Your TELEPORTER was upgraded!");
							else if (GetEntProp(i, Prop_Send, "m_iHighestUpgradeLevel") == 3 && GetEntProp(i, Prop_Data, "m_iHealth") < GetEntProp(i, Prop_Data, "m_iMaxHealth"))PrintToChat(client, "Your TELEPORTER was healed!");
						}
						SetEntProp(i, Prop_Send, "m_iHighestUpgradeLevel", 3);
						SetEntityHealth(i, GetEntProp(i, Prop_Data, "m_iMaxHealth"));
					}
				}
			}
			EmitSoundToClient(client, "mvm/mvm_used_powerup.wav");
			m_flBuildingUpgrade_Charge[client][slot] = 0.0;
		}
	}
	return Plugin_Continue;
}

/*
public Action:OnWeaponSwitch(client, wep)
{
	if (!IsValidClient(client))return Plugin_Continue;
	
	if (SpdOnDraw[wep])
	{
		if (GetEngineTime() > SpdOnDraw_SheathDur[wep] + (SpdOnDraw_Dur[wep] * 2.0))
		{
			TF2_AddCondition(client, TFCond_SpeedBuffAlly, SpdOnDraw_Dur[wep]);
			TF2_AddCondition(client, TFCond:41, SpdOnDraw_Dur[wep]);
			SpdOnDraw_SheathDur[wep] = GetEngineTime();
		}
	}
	return Plugin_Continue;
}
*/

public OnClientPreThink(client)
{
	new Float:flTime = GetEngineTime();
	if (flTime > g_flLastTick[client] + 0.1 && IsClientInGame(client) && IsPlayerAlive(client))
	{
		Attributes_PreThink(client);
		EngiShit_Think(client);
		if(GetEngineTime() <= PlagueStab_Dur[client] + PlagueStab_MaxDur[client] + 1.0)
			PlagueSpread_Think(client);
		
		CustomHealEffects_Think(client);
		CustomUberEffects_Think(client);
		g_flLastTick[client] = flTime;
	}
	CustomBuffBanners_Think(client);
}

stock Action:Attributes_PreThink(client)
{
	if (!Client_IsValid(client))return Plugin_Continue;
	if (!IsValidClient(client))return Plugin_Continue;
	if (!IsPlayerAlive(client))return Plugin_Continue;
	new wep = Client_GetActiveWeapon(client);
	if (wep == -1)return Plugin_Continue;
	new slot = GetClientSlot(client);
	if (slot == -1 || slot > 3)return Plugin_Continue;
	new pri = GetPlayerWeaponSlot(client, 0);
	new sec = GetPlayerWeaponSlot(client, 1);
	new mel = GetPlayerWeaponSlot(client, 2);
	new buttons = GetClientButtons(client);
	
	if (GetClientHealth(client) <= GetClientMaxHealth(client) && m_flDmgResistOverhealed[client] < 1.0)
	{
		m_flDmgResistOverhealed[client] = 1.0;
	}
	if (GetEngineTime() > m_flInvigoratorUber_Dur[client] + m_flInvigoratorUber_MaxDur[client] && GetEngineTime() > m_flInvigoratorUber_Dur[client] + m_flInvigoratorUber_MaxDur[client] + 0.2)
	{
		m_flInvigoratorUber_DmgBonus[client] = 1.0;
	}
	if (GetEngineTime() < GeneralReserve_Dur[client] + GeneralReserve_ImmuneDur[client])
	{
		TF2_RemoveCondition(client, TFCond_OnFire);
		TF2_RemoveCondition(client, TFCond_Milked);
		TF2_RemoveCondition(client, TFCond_Jarated);
		TF2_RemoveCondition(client, TFCond_MarkedForDeath);
		TF2_RemoveCondition(client, TFCond_Bleeding);
		TF2_RemoveCondition(client, TFCond_Dazed);
		TF2_RemoveCondition(client, TFCond_Buffed);
		TF2_RemoveCondition(client, TFCond:26);
		TF2_RemoveCondition(client, TFCond:29);
	}
	if (CursedHeads[wep] && mel > -1)
	{
		if (GetClientHealth(client) <= GetClientMaxHealth(client) / 3 && CursedHeads_Heads[mel] > 0 && GetEngineTime() >= CursedHeads_Dur[mel] + CursedHeads_Minicrits[mel])
		{
			SetEntityHealth(client, GetClientMaxHealth(client));
			CursedHeads_Heads[mel]--;
			CursedHeads_Dur[mel] = GetEngineTime();
			EmitSoundToClient(client, "player/souls_receive1.wav");
		}
		if (GetEngineTime() < CursedHeads_Dur[mel] + CursedHeads_Minicrits[mel])
		{
			TF2_AddCondition(client, TFCond_MarkedForDeathSilent, 0.2);
			TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.2);
			TF2_AddCondition(client, TFCond:41, 0.2);
			TF2Attrib_SetByName(wep, "damage penalty", 0.0);
		}
		else
		{
			TF2Attrib_RemoveByName(wep, "damage penalty");
		}
		
		SetHudTextParams(0.8, 0.7, 0.2, 255, 255, 255, 255);
		ShowSyncHudText(client, CursedHeads_Display, "Heads: %i/%i", CursedHeads_Heads[mel], CursedHeads_MaxHeads[mel]);
	}
	
	if (TF2_IsPlayerInCondition(client, TFCond_Slowed) && MeleeKillBoosts[wep] && MeleeKillBoosts_Dur[wep] >= 0.1 && !CritBoostedFromOutside[client])
	{
		MeleeKillBoosts_Dur[wep] -= 0.1;
	}
	if (pri > -1 && MeleeKillBoosts[pri])
	{
		if (MeleeKillBoosts[wep])
		{
			SetHudTextParams(-1.0, 0.6, 0.2, 255, 255, 255, 255);
			ShowSyncHudText(client, MeleeKillBoosts_Display, "Buff duration: %is", RoundFloat(MeleeKillBoosts_Dur[wep]));
			if (MeleeKillBoosts_Dur[wep] >= 0.1)
				TF2_AddCondition(client, TFCond:MeleeKillBoosts_CondID[wep], 0.2);
		}
		if (MeleeKillBoosts_Dur[pri] > MeleeKillBoosts_MaxDur[pri])
			MeleeKillBoosts_Dur[pri] = MeleeKillBoosts_MaxDur[pri];
	}
	
	if(GetEngineTime() <= PlagueStab_ImmunityDur[client] + PlagueStab_ImmunityMaxDur[client] || IsInSpawn[client])
	{
		StopSound(client, SNDCHAN_AUTO, "items/powerup_pickup_plague_infected_loop.wav");
		PlagueStab_Infector[client] = -1;
		PlagueStab_Radius[client] = 0.0;
		PlagueStab_MarkFD[client] = 0;
		PlagueStab_Dur[client] = 0.0;
		PlagueStab_MaxDur[client] = 0.0;
	}
	
	if (!m_bHasAttribute[client][slot])return Plugin_Continue;
	
	if (TF2_IsPlayerInCondition(client, TFCond_CritCanteen) || 
		TF2_IsPlayerInCondition(client, TFCond_CritOnFirstBlood) || 
		TF2_IsPlayerInCondition(client, TFCond_CritOnFlagCapture) || 
		TF2_IsPlayerInCondition(client, TFCond_CritOnKill) || 
		TF2_IsPlayerInCondition(client, TFCond_CritRuneTemp))
	{
		CritBoostedFromOutside[client] = true;
	}
	else
	{
		CritBoostedFromOutside[client] = false;
	}
	if (MultipleHitsMinicrit_Hits[client] > 0 && GetEngineTime() >= MultipleHitsMinicrit_Delay[client] + 3.0)
	{
		MultipleHitsMinicrit_Hits[client] = 0;
	}
	if (HasAttribute(client, _, DMGResistHauling, false))
	{
		new toolbox = GetPlayerWeaponSlot(client, 5);
		if (wep == toolbox)
		{
			TF2Attrib_SetByName(client, "dmg taken increased", 1.0 - GetAttributeValueF(client, _, DMGResistHauling, DMGResistHauling_Mult, 0.0));
		}
		else
		{
			TF2Attrib_RemoveByName(client, "dmg taken increased");
		}
	}
	if (sec > -1 && mel > -1 && NinjaSet[mel] && NinjaSet[sec])
	{
		TF2Attrib_SetByName(mel, "silent killer", 1.0);
		TF2Attrib_SetByName(sec, "silent killer", 1.0);
	}
	if (HasAttribute(client, _, InvisCrouch, false))
	{
		if (InvisCrouch_Stamina[client] < 100 && GetEngineTime() >= InvisCrouch_Regen[client] + 0.1)
		{
			InvisCrouch_Stamina[client]++;
			InvisCrouch_Regen[client] = GetEngineTime();
		}
		SetHudTextParams(0.6, 0.7, 0.2, 255, 255, 255, 255);
		ShowSyncHudText(client, StaminaDisplay, "Stamina: %i / 100", InvisCrouch_Stamina[client]);
	}
	if (Backstab[wep] && GetEngineTime() >= Backstab_SilenceDur[wep] + 1.0)
	{
		TF2Attrib_RemoveByName(wep, "silent killer");
	}
	if (SpdOnDraw[wep] && GetEngineTime() <= SpdOnDraw_SheathDur[wep] + (SpdOnDraw_Dur[wep] * 3.0) && !TF2_IsPlayerInCondition(client, TFCond_SpeedBuffAlly))
	{
		new prevwep = GetPlayerWeaponSlot(client, 0);
		if (prevwep == -1)prevwep = GetPlayerWeaponSlot(client, 1);
		SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", prevwep);
	}
	if (m_bAddcondActive[wep])
	{
		TF2_AddCondition(client, TFCond:m_iAddcondActive1[wep], 0.2);
		TF2_AddCondition(client, TFCond:m_iAddcondActive2[wep], 0.2);
		TF2_AddCondition(client, TFCond:m_iAddcondActive3[wep], 0.2);
		TF2_AddCondition(client, TFCond:m_iAddcondActive4[wep], 0.2);
	}
	if (ConchOnTaunt[wep])
	{
		if (TF2_IsPlayerInCondition(client, TFCond_Taunting))
		{
			new team = GetClientTeam(client);
			for (new i = 1; i <= MaxClients; i++)
			{
				new Float:Pos1[3];
				GetClientAbsOrigin(client, Pos1);
				if (IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == team && i != client)
				{
					new Float:Pos2[3];
					GetClientAbsOrigin(i, Pos2);
					new Float:distance = GetVectorDistance(Pos1, Pos2);
					if (distance < 450.0)
					{
						TF2_AddCondition(i, TFCond_SpeedBuffAlly, 5.0);
					}
				}
			}
		}
	}
	if (GetEngineTime() < HPRegenOnKill_Dur[wep] + HPRegenOnKill_MaxDur[wep])
	{
		if (GetEngineTime() >= HPRegenOnKill_Delay[wep] + (1.0 / HPRegenOnKill_HP[wep]))
		{
			SetEntityHealth(client, GetClientHealth(client) + 1);
			HPRegenOnKill_Delay[wep] = GetEngineTime();
		}
	}
	if (ElekAssure[wep])
	{
		SetHudTextParams(-1.0, 0.7, 0.2, 255, 255, 255, 255);
		ShowSyncHudText(client, hudText_ElekAssure, "Crits: %i/%i", ElekAssure_Crits[wep], ElekAssure_MaxCrits[wep]);
		if (ElekAssure_Crits[wep] > ElekAssure_MaxCrits[wep])ElekAssure_Crits[wep] = ElekAssure_MaxCrits[wep];
		if (ElekAssure_Crits[wep] > 0)TF2_AddCondition(client, TFCond_CritCanteen, 0.2);
	}
	if (DirectHitBonus[wep])
	{
		if (GetEngineTime() > DirectHitBonus_Dur[wep] + DirectHitBonus_Decay[wep] + DirectHitBonus_StackDecay[wep])
		{
			DirectHitBonus_Stacks[client]--;
			if (DirectHitBonus_Stacks[client] < 0)DirectHitBonus_Stacks[client] = 0;
			DirectHitBonus_Dur[wep] += DirectHitBonus_StackDecay[wep];
		}
		TF2Attrib_RemoveByName(wep, "fire rate bonus");
		TF2Attrib_RemoveByName(wep, "Reload time decreased");
		TF2Attrib_RemoveByName(wep, "Projectile speed increased");
		TF2Attrib_RemoveByName(wep, "Blast radius increased");
		TF2Attrib_SetByName(wep, "fire rate bonus", 1.0 - (DirectHitBonus_FireSpd[wep] * DirectHitBonus_Stacks[client]));
		TF2Attrib_SetByName(wep, "Reload time decreased", 1.0 - (DirectHitBonus_DmgPen[wep] * DirectHitBonus_Stacks[client]));
		TF2Attrib_SetByName(wep, "Projectile speed increased", 1.0 + (DirectHitBonus_ProjSpd[wep] * DirectHitBonus_Stacks[client]));
		TF2Attrib_SetByName(wep, "Blast radius increased", 1.0 + (DirectHitBonus_BlastRad[wep] * DirectHitBonus_Stacks[client]));
		SetHudTextParams(0.7, 0.65, 0.2, 255, 255, 255, 255);
		ShowSyncHudText(client, StackDisplay, "Stacks: %i / %i", DirectHitBonus_Stacks[client], DirectHitBonus_MaxStacks[wep]);
	}
	if (pri > -1 && m_bFriendlyMittens[pri] || sec > -1 && m_bFriendlyMittens[sec] || mel > -1 && m_bFriendlyMittens[mel])
	{
		TF2_RemoveCondition(client, TFCond_Jarated);
		TF2_RemoveCondition(client, TFCond_Milked);
		TF2_RemoveCondition(client, TFCond_Bleeding);
		TF2_RemoveCondition(client, TFCond_Slowed);
		TF2_RemoveCondition(client, TFCond_Dazed);
		TF2_RemoveCondition(client, TFCond_MarkedForDeath);
		TF2_RemoveCondition(client, TFCond_MarkedForDeathSilent);
		TF2_RemoveCondition(client, TFCond_OnFire);
	}
	if (m_bRingsOnKill[wep])
	{
		SetHudTextParams(0.6, 0.5, 0.2, 255, 255, 255, 255);
		ShowSyncHudText(client, m_hRingsOnKill_Display, "Rings: %i / 5", m_iRingsOnKill_Rings[wep]);
		if ((buttons & IN_ATTACK3) == IN_ATTACK3)
		{
			if (m_iRingsOnKill_Rings[wep] == 0)
				EmitSoundToClient(client, "weapons/medigun_no_target.wav");
			if (m_iRingsOnKill_Rings[wep] > 0)
			{
				if (m_iRingsOnKill_Rings[wep] >= 1)
				{
					TF2Attrib_SetByName(wep, "minigun spinup time decreased", 0.85);
				}
				if (m_iRingsOnKill_Rings[wep] >= 2)
				{
					TF2Attrib_SetByName(wep, "fire rate bonus", 0.85);
				}
				if (m_iRingsOnKill_Rings[wep] >= 3)
				{
					TF2Attrib_SetByName(wep, "minigun spinup time decreased", 0.7);
					TF2Attrib_SetByName(wep, "fire rate bonus", 0.7);
				}
				if (m_iRingsOnKill_Rings[wep] >= 4)
				{
					TF2Attrib_SetByName(wep, "move speed bonus", 0.85);
					TF2Attrib_SetByName(wep, "aiming movespeed increased", 1.25);
					TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.01);
				}
				if (m_iRingsOnKill_Rings[wep] >= 5)
				{
					TF2Attrib_SetByName(wep, "move speed bonus", 0.7);
					TF2Attrib_SetByName(wep, "aiming movespeed increased", 1.5);
					TF2_AddCondition(client, TFCond_SpeedBuffAlly, m_flRingsOnKill_MaxDur[wep]);
				}
				m_flRingsOnKill_Dur[wep] = GetEngineTime();
				m_iRingsOnKill_Rings[wep] = 0;
			}
		}
		if (GetEngineTime() > m_flRingsOnKill_Dur[wep] + m_flRingsOnKill_MaxDur[wep] && GetEngineTime() <= m_flRingsOnKill_Dur[wep] + m_flRingsOnKill_MaxDur[wep] + 0.2)
		{
			TF2Attrib_RemoveByName(wep, "minigun spinup time decreased");
			TF2Attrib_RemoveByName(wep, "fire rate bonus");
			TF2Attrib_RemoveByName(wep, "move speed bonus");
			TF2Attrib_RemoveByName(wep, "aiming movespeed increased");
		}
	}
	if (m_bRingsOnKill2[wep])
	{
		SetHudTextParams(0.6, 0.5, 0.2, 255, 255, 255, 255);
		ShowSyncHudText(client, m_hRingsOnKill2_Display, "Rings: %i / 5", m_iRingsOnKill2_Rings[wep]);
		if ((buttons & IN_ATTACK3) == IN_ATTACK3)
		{
			if (m_iRingsOnKill2_Rings[wep] == 0)
				EmitSoundToClient(client, "weapons/medigun_no_target.wav");
			if (m_iRingsOnKill2_Rings[wep] > 0)
			{
				if (m_iRingsOnKill2_Rings[wep] >= 1)
				{
					TF2Attrib_SetByName(wep, "dmg taken from crit reduced", 0.75);
					TF2Attrib_SetByName(wep, "dmg from ranged reduced", 0.9);
				}
				if (m_iRingsOnKill2_Rings[wep] >= 2)
				{
					TF2Attrib_SetByName(wep, "health regen", 2.0);
					TF2Attrib_SetByName(wep, "dmg from ranged reduced", 0.85);
				}
				if (m_iRingsOnKill2_Rings[wep] >= 3)
				{
					TF2Attrib_SetByName(wep, "dmg taken from crit reduced", 0.5);
					TF2Attrib_SetByName(wep, "dmg from ranged reduced", 0.8);
					TF2Attrib_SetByName(wep, "health regen", 4.0);
				}
				if (m_iRingsOnKill2_Rings[wep] >= 4)
				{
					TF2Attrib_SetByName(wep, "dmg from ranged reduced", 0.75);
					TF2Attrib_SetByName(wep, "health regen", 6.0);
				}
				if (m_iRingsOnKill2_Rings[wep] >= 5)
				{
					TF2Attrib_SetByName(wep, "dmg taken from crit reduced", 0.25);
					TF2Attrib_SetByName(wep, "health regen", 8.0);
					TF2_AddCondition(client, TFCond:28, m_flRingsOnKill2_MaxDur[wep]);
				}
				m_flRingsOnKill2_Dur[wep] = GetEngineTime();
				m_iRingsOnKill2_Rings[wep] = 0;
			}
		}
		if (GetEngineTime() > m_flRingsOnKill2_Dur[wep] + m_flRingsOnKill2_MaxDur[wep] && GetEngineTime() <= m_flRingsOnKill2_Dur[wep] + m_flRingsOnKill2_MaxDur[wep] + 0.2)
		{
			TF2Attrib_RemoveByName(wep, "dmg from ranged reduced");
			TF2Attrib_RemoveByName(wep, "dmg taken from crit reduced");
			TF2Attrib_RemoveByName(wep, "move speed bonus");
			TF2Attrib_RemoveByName(wep, "aiming movespeed increased");
		}
	}
	if (TF2_GetPlayerClass(client) == TFClass_Heavy && wep == pri && TF2_IsPlayerInCondition(client, TFCond_Slowed) && Revved[wep] == false)
	{
		Revved[wep] = true;
		if (MinigunRevDownSpeed[wep])MinigunUnrevved[wep] = false;
	}
	else if (TF2_GetPlayerClass(client) == TFClass_Heavy && wep == pri && !TF2_IsPlayerInCondition(client, TFCond_Slowed) && Revved[wep] == true)
	{
		Revved[wep] = false;
	}
	if (MinigunRevDownSpeed[wep] && Revved[wep] == false && MinigunUnrevved[wep] == false)
	{
		SetEntPropFloat(wep, Prop_Send, "m_flTimeWeaponIdle", GetEntPropFloat(wep, Prop_Send, "m_flTimeWeaponIdle") * MinigunRevDownSpeed_Mult[wep]);
		MinigunUnrevved[wep] = true;
	}
	if (AimingMoveSpeedNotFiring[wep] && GetEngineTime() >= AimingMoveSpeedNotFiring_Dur[wep] + 0.2)
	{
		TF2Attrib_SetByName(wep, "aiming movespeed increased", AimingMoveSpeedNotFiring_Mult[wep]);
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.01);
	}
	
	return Plugin_Continue;
}

stock Action:CustomHealEffects_Think(client)
{
	if (!Client_IsValid(client))return Plugin_Continue;
	if (!IsValidClient(client))return Plugin_Continue;
	if (!IsPlayerAlive(client))return Plugin_Continue;
	if (TF2_GetPlayerClass(client) != TFClass_Medic)return Plugin_Continue;
	new wep = Client_GetActiveWeapon(client);
	if (wep == -1)return Plugin_Continue;
	new slot = GetClientSlot(client);
	if (slot == -1)return Plugin_Continue;
	new patient = GetMediGunPatient(client);
	if (patient <= 0 || patient > MaxClients)return Plugin_Continue;
	
	if (m_bDmgResistOverhealed[wep] && GetClientHealth(patient) > GetClientMaxHealth(patient))
	{
		m_flDmgResistOverhealed[patient] = m_flDmgResistOverhealed[patient];
	}
	
	return Plugin_Continue;
}
stock Action:CustomUberEffects_Think(client)
{
	if (!Client_IsValid(client))return Plugin_Continue;
	if (!IsValidClient(client))return Plugin_Continue;
	if (!IsPlayerAlive(client))return Plugin_Continue;
	if (TF2_GetPlayerClass(client) != TFClass_Medic)return Plugin_Continue;
	new wep = Client_GetActiveWeapon(client);
	if (wep == -1)return Plugin_Continue;
	new slot = GetClientSlot(client);
	if (slot == -1)return Plugin_Continue;
	new patient = GetMediGunPatient(client);
	new buttons = GetClientButtons(client);
	
	if (m_bInvigoratorUber[wep])
	{
		new Float:flUber = GetEntPropFloat(wep, Prop_Send, "m_flChargeLevel");
		if (flUber > 0.99)SetEntPropFloat(wep, Prop_Send, "m_flChargeLevel", 0.99);
		if (flUber > m_flInvigoratorUber_UberRequired[wep] && GetEngineTime() >= m_flInvigoratorUber_Delay[wep] + 0.5 && (buttons & IN_ATTACK2) == IN_ATTACK2)
		{
			SetEntPropFloat(wep, Prop_Send, "m_flChargeLevel", flUber - m_flInvigoratorUber_UberRequired[wep]);
			if (patient > -1)
			{
				TF2_AddCondition(patient, TFCond:m_iInvigoratorUber_Cond1[wep], m_flInvigoratorUber_MaxDur[wep], client);
				TF2_AddCondition(patient, TFCond:m_iInvigoratorUber_Cond2[wep], m_flInvigoratorUber_MaxDur[wep], client);
				m_flInvigoratorUber_DmgBonus[patient] = m_flInvigoratorUber_DmgBonus[wep];
				m_flInvigoratorUber_Dur[patient] = GetEngineTime();
				m_flInvigoratorUber_MaxDur[patient] = m_flInvigoratorUber_MaxDur[wep];
			}
			TF2_AddCondition(client, TFCond:m_iInvigoratorUber_Cond1[wep], m_flInvigoratorUber_MaxDur[wep], client);
			TF2_AddCondition(client, TFCond:m_iInvigoratorUber_Cond2[wep], m_flInvigoratorUber_MaxDur[wep], client);
			m_flInvigoratorUber_Delay[wep] = GetEngineTime();
		}
	}
	
	return Plugin_Continue;
}

public OnTouchHealthKit(const String:output[], caller, client, Float:delay)
{
	if (GetEngineTime() <= PlagueStab_Dur[client] + PlagueStab_MaxDur[client] || PlagueStab_Infector[client] > -1)
	{
		StopSound(client, SNDCHAN_AUTO, "items/powerup_pickup_plague_infected_loop.wav");
		PlagueStab_Infector[client] = -1;
		PlagueStab_Radius[client] = 0.0;
		PlagueStab_MarkFD[client] = 0;
		PlagueStab_Dur[client] = 0.0;
		PlagueStab_MaxDur[client] = 0.0;
		PlagueStab_ImmunityDur[client] = GetEngineTime();
		TF2_RemoveCondition(client, TFCond_MarkedForDeath);
	}
}
public SpawnStartTouch(spawn, client)
{
	if (client <= 0 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client))return;
	IsInSpawn[client] = true;
}
public SpawnEndTouch(spawn, client)
{
	if (client <= 0 || client > MaxClients || !IsClientInGame(client) || !IsPlayerAlive(client))return;
	IsInSpawn[client] = false;
}

stock Action:EngiShit_Think(client)
{
	if (!IsValidClient(client))return Plugin_Continue;
	if (!IsPlayerAlive(client))
	{
		StopSound(client, SNDCHAN_AUTO, "weapons/flame_thrower_loop_crit.wav");
		m_flEngiJetpack_FlightDur[client] = 0.0;
		return Plugin_Continue;
	}
	if (TF2_GetPlayerClass(client) != TFClass_Engineer)return Plugin_Continue;
	new buttons = GetClientButtons(client);
	if (HasAttribute(client, _, m_bEngiJetpack))
	{
		new metal = GetEntProp(client, Prop_Data, "m_iAmmo", 4, 3);
		if ((buttons & IN_JUMP) == IN_JUMP && metal >= 1)
		{
			new Float:velocity[3];
			GetEntPropVector(client, Prop_Data, "m_vecVelocity", velocity);
			if (velocity[2] > 0.0)velocity[2] += GetAttributeValueF(client, _, m_bEngiJetpack, m_flEngiJetpack);
			if (velocity[2] < 0.0)velocity[2] += GetAttributeValueF(client, _, m_bEngiJetpack, m_flEngiJetpack) * 2.0;
			new Float:pos[3], Float:angles[3];
			GetClientEyePosition(client, pos);
			GetClientEyeAngles(client, angles);
			
			new Float:vec[3];
			GetAngleVectors(angles, vec, NULL_VECTOR, NULL_VECTOR);
			NormalizeVector(vec, vec);
			ScaleVector(vec, GetAttributeValueF(client, _, m_bEngiJetpack, m_flEngiJetpack_Spd));
			vec[2] = 0.0;
			velocity[0] += vec[0];
			velocity[1] += vec[1];
			velocity[2] += vec[2];
			if (velocity[0] > 750.0)velocity[0] = 750.0;
			if (velocity[0] < -750.0)velocity[0] = -750.0;
			if (velocity[1] > 750.0)velocity[1] = 750.0;
			if (velocity[1] < -750.0)velocity[1] = -750.0;
			TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, velocity);
			m_flEngiJetpack_FlightDur[client] += 1.0;
			if (m_flEngiJetpack_FlightDur[client] == 1.0)
			{
				for (new i = 1; i <= MaxClients; i++)
				{
					new Float:Pos1[3];
					GetClientAbsOrigin(client, Pos1);
					if (IsValidClient(i))
					{
						new Float:Pos2[3];
						GetClientAbsOrigin(i, Pos2);
						new Float:distance = GetVectorDistance(Pos1, Pos2);
						if (distance <= 900.0)
						{
							EmitSoundToClient(i, "weapons/flame_thrower_bb_start.wav", client);
						}
					}
				}
			}
			if (m_flEngiJetpack_FlightDur[client] == 264.0)
			{
				for (new i = 1; i <= MaxClients; i++)
				{
					new Float:Pos1[3];
					GetClientAbsOrigin(client, Pos1);
					if (IsValidClient(i))
					{
						new Float:Pos2[3];
						GetClientAbsOrigin(i, Pos2);
						new Float:distance = GetVectorDistance(Pos1, Pos2);
						if (distance <= 900.0)
						{
							StopSound(client, SNDCHAN_AUTO, "weapons/flame_thrower_bb_start.wav");
							EmitSoundToClient(client, "weapons/flame_thrower_bb_loop_crit.wav");
						}
					}
				}
			}
			if (m_flEngiJetpack_FlightDur[client] >= 328.0)m_flEngiJetpack_FlightDur[client] = 263.0;
			if (GetEngineTime() >= m_flEngiJetpack_Delay[client] + (1.0 / GetAttributeValueI(client, _, m_bEngiJetpack, m_iEngiJetpack)))
			{
				metal -= 1;
				SetEntProp(client, Prop_Data, "m_iAmmo", metal, 4, 3);
				m_flEngiJetpack_Delay[client] = GetEngineTime();
			}
		}
		if ((buttons & IN_JUMP) != IN_JUMP && m_flEngiJetpack_FlightDur[client] > 0.0 || metal == 0)
		{
			StopSound(client, SNDCHAN_AUTO, "weapons/flame_thrower_bb_loop_crit.wav");
			StopSound(client, SNDCHAN_AUTO, "weapons/flame_thrower_bb_start.wav");
			EmitSoundToClient(client, "weapons/flame_thrower_bb_end.wav");
			m_flEngiJetpack_FlightDur[client] = 0.0;
		}
	}
	if (HasAttribute(client, _, m_bBuildingUpgrade))
	{
		new slot = GetSlotContainingAttribute(client, m_bBuildingUpgrade);
		if (m_flBuildingUpgrade_Charge[client][slot] < m_flBuildingUpgrade_MaxCharge[client][slot])
		{
			SetHudTextParams(-1.0, 0.6, 0.2, 255, 255, 255, 255);
			ShowSyncHudText(client, m_hBuildingUpgrade_Display, "Building Upgrade:\n%i / %i", RoundToFloor(m_flBuildingUpgrade_Charge[client][slot]), RoundToFloor(m_flBuildingUpgrade_MaxCharge[client][slot]));
		}
		else if (m_flBuildingUpgrade_Charge[client][slot] >= m_flBuildingUpgrade_MaxCharge[client][slot])
		{
			SetHudTextParams(-1.0, 0.6, 0.2, 192, 192, 255, 255);
			ShowSyncHudText(client, m_hBuildingUpgrade_Display, "Building Upgrade:\n%i / %i\nPress your Special-Attack key to use!", RoundToFloor(m_flBuildingUpgrade_Charge[client][slot]), RoundToFloor(m_flBuildingUpgrade_MaxCharge[client][slot]));
		}
	}
	return Plugin_Continue;
}

stock Action:CustomBuffBanners_Think(client)
{
	if (!Client_IsValid(client))return Plugin_Continue;
	if (!IsValidClient(client))return Plugin_Continue;
	if (!IsPlayerAlive(client))return Plugin_Continue;
	new secondary = GetPlayerWeaponSlot(client, 1);
	if (secondary < 0)return Plugin_Continue;
	if (TF2_GetPlayerClass(client) != TFClass_Soldier)return Plugin_Continue;
	new String:class[25];
	GetEdictClassname(secondary, class, sizeof(class));
	if (StrContains(class, "tf_weapon_buff_item", false))return Plugin_Continue;
	if (GeneralReserve[secondary])
	{
		if (GeneralReserve_Mode[secondary] == 1)
		{
			if (BuffDeployed[client])
			{
				TF2_AddCondition(client, TFCond:55, 0.2, client);
				for (new i = 1; i <= MaxClients; i++)
				{
					new team = GetClientTeam(client);
					new Float:Pos1[3];
					GetClientAbsOrigin(client, Pos1);
					if (Client_IsValid(i) && IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == team)
					{
						new Float:Pos2[3];
						GetClientAbsOrigin(i, Pos2);
						new Float:distance = GetVectorDistance(Pos1, Pos2);
						if (distance <= 450.0)
						{
							TF2_RemoveCondition(client, TFCond_OnFire);
							TF2_RemoveCondition(client, TFCond_Milked);
							TF2_RemoveCondition(client, TFCond_Jarated);
							TF2_RemoveCondition(client, TFCond_MarkedForDeath);
							TF2_RemoveCondition(client, TFCond_Bleeding);
							TF2_RemoveCondition(client, TFCond_Dazed);
							TF2_RemoveCondition(client, TFCond_Buffed);
							TF2_RemoveCondition(client, TFCond:26);
							TF2_RemoveCondition(client, TFCond:29);
						}
					}
				}
			}
		}
		if (GeneralReserve_Mode[secondary] == 2)
		{
			if (BuffDeployed[client])
			{
				new counter = 0;
				for (new i = 1; i <= MaxClients; i++)
				{
					new team = GetClientTeam(client);
					new Float:Pos1[3];
					GetClientAbsOrigin(client, Pos1);
					if (Client_IsValid(i) && IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == team)
					{
						new Float:Pos2[3];
						GetClientAbsOrigin(i, Pos2);
						new Float:distance = GetVectorDistance(Pos1, Pos2);
						if (distance <= 450.0)
						{
							TF2_RemoveCondition(client, TFCond_OnFire);
							TF2_RemoveCondition(client, TFCond_Milked);
							TF2_RemoveCondition(client, TFCond_Jarated);
							TF2_RemoveCondition(client, TFCond_MarkedForDeath);
							TF2_RemoveCondition(client, TFCond_Bleeding);
							TF2_RemoveCondition(client, TFCond_Dazed);
							TF2_RemoveCondition(client, TFCond_Buffed);
							TF2_RemoveCondition(client, TFCond:26);
							TF2_RemoveCondition(client, TFCond:29);
							GeneralReserve_ImmuneDur[i] = GeneralReserve_ImmuneDur[secondary];
							GeneralReserve_Dur[i] = GetEngineTime();
							counter++;
						}
					}
				}
				SetEntityHealth(client, GetClientHealth(client) + (GeneralReserve_Heal[secondary] * counter));
				if (GetClientHealth(client) > RoundToFloor(GetClientMaxHealth(client) * 1.5))
					SetEntityHealth(client, RoundToFloor(GetClientMaxHealth(client) * 1.5));
				
				SetEntPropFloat(client, Prop_Send, "m_flRageMeter", 1.0);
			}
		}
	}
	if (RandomSpellBuff[secondary])
	{
		if (RandomSpellBuff_Charges[secondary] == 0 || GetEngineTime() <= RandomSpellBuff_Dur[client] + RandomSpellBuff_BuffDur[secondary])
		{
			SetEntPropFloat(client, Prop_Send, "m_flRageMeter", 0.0);
		}
		else
		{ SetEntPropFloat(client, Prop_Send, "m_flRageMeter", 100.0); }
		
		if (RandomSpellBuff_Charges[secondary] < 3)
		{
			SetHudTextParams(-1.0, 0.7, 0.2, 255, 255, 255, 255);
			ShowSyncHudText(client, RandomBuffSpell_Rage, "Rage: %i/%i", RoundToFloor(RandomSpellBuff_Charge[secondary]), RoundToFloor(RandomSpellBuff_MaxDMG[secondary]));
		}
		if (RandomSpellBuff_Charges[secondary] >= 3)
			RandomSpellBuff_Charge[secondary] = 0.0;
		SetHudTextParams(-1.0, 0.6, 0.2, 255, 255, 255, 255);
		ShowSyncHudText(client, RandomBuffSpell_ChargeCount, "Powerups: %i / %i", RandomSpellBuff_Charges[secondary], RandomSpellBuff_MaxCharges[secondary]);
		if (RandomSpellBuff_Charge[secondary] >= RandomSpellBuff_MaxDMG[secondary] && RandomSpellBuff_Charges[secondary] < RandomSpellBuff_MaxCharges[secondary])
		{
			RandomSpellBuff_Charges[secondary]++;
			RandomSpellBuff_Charge[secondary] -= RandomSpellBuff_MaxDMG[secondary];
		}
		if (RandomSpellBuff_Charge[secondary] > RandomSpellBuff_MaxDMG[secondary])
		{
			RandomSpellBuff_Charge[secondary] = RandomSpellBuff_MaxDMG[secondary];
		}
	}
	if (BattBackupXHP[client])
	{
		if (GetClientHealth(client) <= BattBackupXHP_HP[client])
		{
			TF2_AddCondition(client, TFCond:26, 0.2);
		}
	}
	if (AmmoBuff[secondary])
	{
		new team = GetClientTeam(client);
		for (new i = 1; i <= MaxClients; i++)
		{
			new Float:Pos1[3];
			GetClientAbsOrigin(client, Pos1);
			if (Client_IsValid(i) && IsValidClient(i) && IsPlayerAlive(i) && GetClientTeam(i) == team)
			{
				new Float:Pos2[3];
				GetClientAbsOrigin(i, Pos2);
				new Float:distance = GetVectorDistance(Pos1, Pos2);
				if (distance <= 450.0 && BuffDeployed[client])
				{
					TF2_RemoveCondition(i, TFCond:16);
					TF2_RemoveCondition(i, TFCond:26);
					TF2_RemoveCondition(i, TFCond:29);
					TF2_AddCondition(i, TFCond:113, 0.2, client);
				}
			}
		}
	}
	if (GetEntPropFloat(client, Prop_Send, "m_flRageMeter") <= 1.0)
	{
		BuffDeployed[client] = false;
	}
	if (GetEngineTime() >= RandomSpellBuff_Dur[client] + 9.9 && GetEngineTime() <= RandomSpellBuff_Dur[client] + 10.1)
	{
		TF2Attrib_RemoveByName(client, "move speed bonus");
		TF2Attrib_RemoveByName(client, "increased jump height");
		TF2Attrib_RemoveByName(client, "cancel falling damage");
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
	}
	return Plugin_Continue;
}

public Event_BuffDeployed(Handle:event, const String:strname[], bool:DontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "buff_owner"));
	if (Client_IsValid(client) && IsValidClient(client) && IsPlayerAlive(client))
	{
		new buff = GetPlayerWeaponSlot(client, 1);
		if (buff > -1)
		{
			if (RandomSpellBuff[buff])
			{
				new effects[8] =  { 90, 91, 93, 94, 96, 97, 103, 109 };
				new effectchoice = GetRandomInt(0, 7);
				TF2_AddCondition(client, TFCond:effects[effectchoice], RandomSpellBuff_BuffDur[buff], client);
				SetEntPropFloat(client, Prop_Send, "m_flRageMeter", 0.0);
				RandomSpellBuff_Charges[buff]--;
			}
			BuffDeployed[client] = true;
			RandomSpellBuff_Dur[client] = GetEngineTime();
		}
	}
}

stock Action:PlagueSpread_Think(client)
{
	if (!IsValidClient(client))return Plugin_Continue;
	if (PlagueStab_Infector[client] == -1)return Plugin_Continue;
	if (GetEngineTime() <= PlagueStab_Dur[client] + PlagueStab_MaxDur[client])
	{
		new infector = PlagueStab_Infector[client];
		if (!IsValidClient(infector))return Plugin_Continue;
		for (new i = 1; i <= MaxClients; i++)
		{
			new team = GetClientTeam(client);
			new Float:Pos1[3];
			GetClientAbsOrigin(client, Pos1);
			if (IsValidClient(i) && IsPlayerAlive(i) && i != client && i != infector && PlagueStab_Infector[i] == -1)
			{
				new Float:Pos2[3];
				GetClientAbsOrigin(i, Pos2);
				new Float:distance = GetVectorDistance(Pos1, Pos2);
				if (distance <= 50.0 && GetClientTeam(i) == team)
				{
					EmitSoundToClient(i, "items/powerup_plague_infected.wav");
					PlagueStab_Radius[i] = PlagueStab_Radius[client];
					PlagueStab_Infector[i] = infector;
					PlagueStab_MarkFD[i] = PlagueStab_MarkFD[client];
					PlagueStab_Dur[i] = GetEngineTime();
					PlagueStab_MaxDur[i] = PlagueStab_MaxDur[client];
					EmitSoundToClient(i, "items/powerup_pickup_plague_infected.wav");
					EmitSoundToClient(i, "items/powerup_pickup_plague_infected_loop.wav");
				}
			}
		}
		if (GetEngineTime() >= PlagueStab_DMGDelay[client] + 0.5)
		{
			if (PlagueStab_MarkFD[client] == 1)
				TF2_AddCondition(client, TFCond_MarkedForDeathSilent, 1.0, infector);
			Entity_Hurt(client, RoundToFloor(GetClientMaxHealth(client) * 0.05), infector, DMG_POISON);
			PlagueStab_DMGDelay[client] = GetEngineTime();
		}
	}
	if (PlagueStab_Infector[client] > -1 && GetEngineTime() >= PlagueStab_Dur[client] + PlagueStab_MaxDur[client])
	{
		StopSound(client, SNDCHAN_AUTO, "items/powerup_pickup_plague_infected_loop.wav");
		PlagueStab_Radius[client] = 0.0;
		PlagueStab_Infector[client] = -1;
		PlagueStab_MarkFD[client] = 0;
		PlagueStab_ImmunityMaxDur[client] = 0.0;
		TF2_RemoveCondition(client, TFCond_MarkedForDeath);
	}
	if (PlagueStab_Infector[client] > -1 && GetEntProp(client, Prop_Send, "m_nNumHealers") > 0)
	{
		PlagueStab_Dur[client] += 0.5;
		if(GetEngineTime() >= PlagueStab_Dur[client] + PlagueStab_MaxDur[client])
			PlagueStab_ImmunityDur[client] = GetEngineTime();
	}
	return Plugin_Continue;
}

public Action:Timer_SwitchBack(Handle:timer, any:ref)
{
	new client = EntRefToEntIndex(ref);
	if (!IsValidClient(client))return;
	new melee = GetPlayerWeaponSlot(client, 2);
	SetEntPropEnt(client, Prop_Send, "m_hActiveWeapon", melee);
}

public Action:Timer_RemoveEnt(Handle:timer, any:ref)
{
	new ent = EntRefToEntIndex(ref);
	if (ent <= MaxClients)return;
	AcceptEntityInput(ent, "Kill");
}

public OnEntityCreated(Ent, const String:classname[])
{
	if (StrEqual(classname, "func_respawnroom", false))	// This is the earliest we can catch this
	{
		SDKHook(Ent, SDKHook_StartTouch, SpawnStartTouch);
		SDKHook(Ent, SDKHook_EndTouch, SpawnEndTouch);
	}
}

public OnEntityDestroyed(ent)
{
	if (ent < 0 || ent > 2048)return;
	MeleeKillBoosts[ent] = false;
	MeleeKillBoosts_Dur[ent] = 0.0;
	MeleeKillBoosts_CondID[ent] = 0;
	MeleeKillBoosts_MaxDurSecondary[ent] = 0.0;
	MeleeKillBoosts_MaxDurMelee[ent] = 0.0;
	MeleeKillBoosts_MaxDur[ent] = 0.0;
	ConchOnTaunt[ent] = false;
	ConchOnTaunt_Drain[ent] = 0;
	ConchOnTaunt_Delay[ent] = 0.0;
	HPRegenOnKill[ent] = false;
	HPRegenOnKill_Delay[ent] = 0.0;
	HPRegenOnKill_Dur[ent] = 0.0;
	HPRegenOnKill_MaxDur[ent] = 0.0;
	HPRegenOnKill_HP[ent] = 0;
	ElekAssure[ent] = false;
	ElekAssure_Crits[ent] = 0;
	ElekAssure_MaxCrits[ent] = 0;
	GeneralReserve[ent] = false;
	GeneralReserve_Heal[ent] = 0;
	GeneralReserve_Mode[ent] = 0;
	GeneralReserve_ImmuneDur[ent] = 0.0;
	RandomSpellBuff[ent] = false;
	RandomSpellBuff_Spell[ent] = 0;
	RandomSpellBuff_Charge[ent] = 0.0;
	RandomSpellBuff_Charges[ent] = 0;
	RandomSpellBuff_MaxCharges[ent] = 0;
	RandomSpellBuff_MaxDMG[ent] = 0.0;
	RandomSpellBuff_BuffDur[ent] = 0.0;
	CursedHeads[ent] = false;
	CursedHeads_Heads[ent] = 0;
	CursedHeads_Minicrits[ent] = 0.0;
	CursedHeads_MaxHeads[ent] = 0;
	AmmoBuff[ent] = false;
	BuffedKillsBuffDur[ent] = false;
	BuffedKillsBuffDur_Dur[ent] = 0.0;
	BuffedTKillsBuffDur[ent] = false;
	BuffedTKillsBuffDur_Dur[ent] = 0.0;
	MultipleHitsMinicrit[ent] = false;
	MultipleHitsMinicrit_Hits[ent] = 0;
	PlagueStab[ent] = false;
	PlagueStab_MaxDur[ent] = 0.0;
	PlagueStab_MarkFD[ent] = 0;
	PlagueStab_Radius[ent] = 0.0;
	KillsRefillShurikens[ent] = false;
	KillsRefillShurikens_Count[ent] = 0;
	KillsRefillShurikens_Max[ent] = 0;
	NinjaSet[ent] = false;
	DirectHitBonus[ent] = false;
	DirectHitBonus_MaxStacks[ent] = 0;
	DirectHitBonus_SpdDur[ent] = 0.0;
	DirectHitBonus_FireSpd[ent] = 0.0;
	DirectHitBonus_DmgPen[ent] = 0.0;
	DirectHitBonus_ProjSpd[ent] = 0.0;
	DirectHitBonus_BlastRad[ent] = 0.0;
	DirectHitBonus_Decay[ent] = 0.0;
	DirectHitBonus_StackDecay[ent] = 0.0;
	SkelyAttrib[ent] = false;
	SkelyAttrib_Charges[ent] = 0;
	SkelyAttrib_MaxCharges[ent] = 0;
	SkelyAttrib_CastDelay[ent] = 0.0;
	SkelyAttrib_Cooldown[ent] = 0.0;
	Backstab[ent] = false;
	Backstab_BleedDur[ent] = 0.0;
	Backstab_DMG[ent] = 0.0;
	Backstab_Silent[ent] = 0;
	Backstab_SilenceDur[ent] = 0.0;
	AltfireDet[ent] = false;
	SpdOnDraw[ent] = false;
	SpdOnDraw_Dur[ent] = 0.0;
	SpdOnDraw_SheathDur[ent] = 0.0;
	BleedOnHit[ent] = false;
	BleedOnHit_Dur[ent] = 0.0;
	BleedOnHit_Minicrit[ent] = 0;
	m_bDamnedMerasmus[ent] = false;
	m_flDamnedMerasmus[ent] = 0.0;
	m_bAddcondActive[ent] = false;
	m_iAddcondActive1[ent] = 0;
	m_iAddcondActive2[ent] = 0;
	m_iAddcondActive3[ent] = 0;
	m_iAddcondActive4[ent] = 0;
	m_bRocketFlamethrower[ent] = false;
	m_bDmgResistOverhealed[ent] = false;
	m_flDmgResistOverhealed[ent] = 1.0;
	m_bInvigoratorUber[ent] = false;
	m_flInvigoratorUber_MaxDur[ent] = 0.0;
	m_flInvigoratorUber_UberRequired[ent] = 0.0;
	m_flInvigoratorUber_DmgBonus[ent] = 1.0;
	m_iInvigoratorUber_Cond1[ent] = -1;
	m_iInvigoratorUber_Cond2[ent] = -1;
	m_bFriendlyMittens[ent] = false;
	m_bRingsOnKill[ent] = false;
	m_flRingsOnKill_MaxDur[ent] = 0.0;
	m_flRingsOnKill_Dur[ent] = 0.0;
	m_iRingsOnKill_Rings[ent] = 0;
	m_bRingsOnKill2[ent] = false;
	m_flRingsOnKill2_MaxDur[ent] = 0.0;
	m_flRingsOnKill2_Dur[ent] = 0.0;
	m_iRingsOnKill2_Rings[ent] = 0;
	MinigunRevDownSpeed[ent] = false;
	MinigunRevDownSpeed_Mult[ent] = 0.0;
	AimingMoveSpeedNotFiring[ent] = false;
	AimingMoveSpeedNotFiring_Mult[ent] = 0.0;
	AimingMoveSpeedNotFiring_Dur[ent] = 0.0;
}
public CW3_OnWeaponRemoved(slot, client)
{
	m_bHasAttribute[client][slot] = false;
	BattBackupXHP[client] = false;
	BattBackupXHP_HP[client] = 0;
	DMGResistHauling[client][slot] = false;
	DMGResistHauling_Mult[client][slot] = 0.0;
	InvisCrouch[client][slot] = false;
	InvisCrouch_Drain[client][slot] = 0;
	Magic[client][slot] = false;
	Magic_SpellType[client][slot] = -1;
	Magic_SpellDelay[client][slot] = 0.0;
	Magic_CastDelay[client][slot] = 0.0;
	Magic_MaxCharges[client][slot] = 0;
	Magic_Charges[client][slot] = 0;
	Magic_Recharge[client][slot] = 0.0;
	Magic_Delay[client][slot] = 0.0;
	RandomSpellKill[client][slot] = false;
	RandomSpellKill_Spell[client][slot] = 0;
	FatScout[client][slot] = false;
	FatScout_DMG[client][slot] = 0.0;
	m_bBleedDmgBonus[client][slot] = false;
	m_fBleedDmgBonus_Mult[client][slot] = 0.0;
	m_bEarthquake[client][slot] = false;
	m_flEarthquake_Range[client][slot] = 0.0;
	m_bEarthquake_Active[client][slot] = false;
	m_bEngiJetpack[client][slot] = false;
	m_iEngiJetpack[client][slot] = 0;
	m_flEngiJetpack[client][slot] = 0.0;
	m_flEngiJetpack_Spd[client][slot] = 0.0;
	m_bDashAttrib[client][slot] = false;
	m_flDashAttrib_Cooldown[client][slot] = 0.0;
	m_flDashAttrib_Delay[client][slot] = 0.0;
	m_bBuildingUpgrade[client][slot] = false;
	m_flBuildingUpgrade_Charge[client][slot] = 0.0;
	m_flBuildingUpgrade_MaxCharge[client][slot] = 0.0;
	m_flBuildingUpgrade_SentryMult[client][slot] = 0.0;
}

stock Shake(client)
{
	new flags = GetCommandFlags("shake") & (~FCVAR_CHEAT);
	SetCommandFlags("shake", flags);
	
	FakeClientCommand(client, "shake");
	
	flags = GetCommandFlags("shake") | (FCVAR_CHEAT);
	SetCommandFlags("shake", flags);
}

stock bool:OnGround(client)
{
	return (GetEntityFlags(client) & FL_ONGROUND == FL_ONGROUND);
}

stock EmitSoundFromOrigin(const String:sound[], const Float:orig[3])
{
	EmitSoundToAll(sound, SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, orig, NULL_VECTOR, true, 0.0);
}
new Float:g_f1026LastLand[MAXPLAYERS + 1] = 0.0;
stock CreateEarthquake(client, slot) //This is entirely Theray's code for the earthquakes.
{
	if (GetEngineTime() <= g_f1026LastLand[client] + ATTRIBUTE_1026_COOLDOWN)return;
	
	if (m_bEarthquake_Active[client][slot])
	{
		new Float:fPushMax = ATTRIBUTE_1026_PUSHMAX;
		
		new Float:fDistance;
		
		decl Float:vClientPos[3];
		Entity_GetAbsOrigin(client, vClientPos);
		decl Float:vVictimPos[3];
		decl Float:vPush[3];
		
		new team = GetClientTeam(client);
		
		EmitSoundFromOrigin(SOUND_EXPLOSION_BIG, vClientPos);
		TE_SetupExplosion(vClientPos, g_iExplosionSprite, 10.0, 1, 0, 0, 750);
		TE_SendToAll();
		TE_SetupBeamRingPoint(vClientPos, 10.0, GetAttributeValueF(client, _, m_bEarthquake, m_flEarthquake_Range, 600.0), g_iWhite, g_iHaloSprite, 0, 10, 0.2, 10.0, 0.5, g_iTeamColorSoft[team], 50, 0);
		TE_SendToAll();
		
		Shake(client);
		
		for (new victim = 0; victim <= MaxClients; victim++)
		{
			if (Client_IsValid(victim) && IsClientInGame(victim) && IsPlayerAlive(victim) && team != GetClientTeam(victim) && OnGround(victim))
			{
				Entity_GetAbsOrigin(victim, vVictimPos);
				fDistance = GetVectorDistance(vVictimPos, vClientPos);
				if (fDistance <= GetAttributeValueF(client, _, m_bEarthquake, m_flEarthquake_Range, 600.0))
				{
					SubtractVectors(vVictimPos, vClientPos, vPush);
					new Float:fPushScale = (GetAttributeValueF(client, _, m_bEarthquake, m_flEarthquake_Range, 600.0) - fDistance) * ATTRIBUTE_1026_PUSHSCALE;
					if (fPushScale > fPushMax)fPushScale = fPushMax;
					ScaleVector(vPush, fPushScale);
					Shake(victim);
					if (vPush[2] < 400.0)vPush[2] = 400.0;
					TeleportEntity(victim, NULL_VECTOR, NULL_VECTOR, vPush);
					g_f1026LastLand[client] = GetEngineTime();
				}
			}
		}
	}
}

stock FindEntityByClassname2(startEnt, const String:classname[])
{
	while (startEnt > -1 && !IsValidEntity(startEnt))
	{
		startEnt--;
	}
	return FindEntityByClassname(startEnt, classname);
}

stock GetPlayerWeaponSlot_Wearable(client, slot)
{
	new edict = MaxClients + 1;
	if (slot == TFWeaponSlot_Secondary)
	{
		while ((edict = FindEntityByClassname2(edict, "tf_wearable_demoshield")) != -1)
		{
			new idx = GetEntProp(edict, Prop_Send, "m_iItemDefinitionIndex");
			if ((idx == 131 || idx == 406) && GetEntPropEnt(edict, Prop_Send, "m_hOwnerEntity") == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				return edict;
			}
		}
	}
	
	edict = MaxClients + 1;
	while ((edict = FindEntityByClassname2(edict, "tf_wearable")) != -1)
	{
		new String:netclass[32];
		if (GetEntityNetClass(edict, netclass, sizeof(netclass)) && StrEqual(netclass, "CTFWearable"))
		{
			new idx = GetEntProp(edict, Prop_Send, "m_iItemDefinitionIndex");
			if (((slot == TFWeaponSlot_Primary && (idx == 405 || idx == 608))
					 || (slot == TFWeaponSlot_Secondary && (idx == 57 || idx == 133 || idx == 231 || idx == 444 || idx == 642)))
				 && GetEntPropEnt(edict, Prop_Send, "m_hOwnerEntity") == client && !GetEntProp(edict, Prop_Send, "m_bDisguiseWearable"))
			{
				return edict;
			}
		}
	}
	return -1;
}

// Finds if the said client has no weapon with the backstab shield attribute on it
// returns true if a weapon is found, returns false otherwise.
// Thanks, Theray!
stock bool:GetHasBackstabShield(client)
{
	for (int i = 0; i < SLOTS_MAX; i++)
	{
		new weapon = GetPlayerWeaponSlot(client, i);
		
		if (weapon != -1 && TF2Attrib_GetByName(weapon, "backstab shield") != Address_Null)
		{
			return true;
		}
	}
	
	for (new i = 0; i < 7; i++)
	{
		new wearable = GetPlayerWeaponSlot_Wearable(client, i);
		
		if (wearable != -1 && TF2Attrib_GetByName(wearable, "backstab shield") != Address_Null)
		{
			return true;
		}
	}
	
	return false;
} 