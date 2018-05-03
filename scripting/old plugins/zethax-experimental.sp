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

public Plugin:myinfo = {
	name = "Zethax's EXPERIMENTAL Attributes",
	author = "Zethax",
	description = "Includes experimental versions of attributes I've already made",
	version = PLUGIN_VERSION,
	url = ""
};

new bool:CursedHeads[2049];
new CursedHeads_MaxHeads[2049];
new Float:CursedHeads_Minicrits[2049];
new Float:CursedHeads_Dur[2049];
new CursedHeads_Heads[2049];
new Handle:CursedHeads_Display;

new bool:m_bMSBPBP[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:m_flMSBPBP_Mult[MAXPLAYERS + 1][SLOTS_MAX + 1];
new m_iMSBPBP_Cap[MAXPLAYERS + 1][SLOTS_MAX + 1];
new bool:m_bIsBurning[MAXPLAYERS + 1];
new m_iIgniter[MAXPLAYERS + 1] = -1;

new bool:DirectHitBonus[2049];
new Float:DirectHitBonus_FireRate[2049];
new Float:DirectHitBonus_Dur[2049];
new Float:DirectHitBonus_MaxDur[2049];

new Float:g_flLastTick[MAXPLAYERS + 1];
new LastWeaponHurtWith[MAXPLAYERS + 1];

public OnPluginStart() {
	
	HookEvent("player_death", Event_Death);
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i)) continue;
		{
		OnClientPutInServer(i);
		}
	}
	CursedHeads_Display = CreateHudSynchronizer();
}
public OnMapStart() {
	
	PrecacheSound("player/souls_receive1.wav", true);
}

public OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_OnTakeDamageAlivePost, OnTakeDamageAlivePost);
	SDKHook(client, SDKHook_PreThink, OnClientPreThink);
	
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

stock GetSlotContainingAttribute(client, const attribute[][] = HasAttribute)
{
	if(!Client_IsValid(client)) return false;
	
	for(new i = 0; i < SLOTS_MAX; i++)
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
	if(!StrEqual(plugin, "zethax-experimental")) return Plugin_Continue;
	new weapon = GetPlayerWeaponSlot(client, slot);
	new Action:action;
	if(StrEqual(attrib, "collect cursed heads on kill"))
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
	else if(StrEqual(attrib, "move speed bonus per burning player"))
	{
		m_bMSBPBP[client][slot] = true;
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		m_flMSBPBP_Mult[client][slot] = StringToFloat(values[0]);
		m_iMSBPBP_Cap[client][slot] = StringToInt(values[1]);
		action = Plugin_Handled;
	}
	else if(StrEqual(attrib, "direct hit bonus"))
	{
		if (weapon == -1)return Plugin_Continue;
		DirectHitBonus[weapon] = true;
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		DirectHitBonus_FireRate[weapon] = StringToFloat(values[0]);
		DirectHitBonus_MaxDur[weapon] = StringToFloat(values[1]);
		TF2Attrib_SetByName(weapon, "rocket specialist", 1.0);
		action = Plugin_Handled;
	}
	
	if (action == Plugin_Handled)m_bHasAttribute[client][slot] = true;
	else m_bHasAttribute[client][slot] = false;
	return action;
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3], damageCustom)
{
	if (attacker <= 0 || attacker > MaxClients) return Plugin_Continue;
	new Action:action;
	if(weapon > -1)
	{
		LastWeaponHurtWith[attacker] = weapon;
	}
	return action;
}

public OnTakeDamageAlivePost(victim, attacker, inflictor, Float:damage, damagetype, weapon, const Float:damageForce[3], const Float:damagePosition[3])
{
	if (attacker <= 0 || attacker > MaxClients) return Plugin_Continue;
	new Action:action;
	if(weapon > -1)
	{
		if(HasAttribute(attacker, _, m_bMSBPBP))
		{
			m_iIgniter[victim] = attacker;
		}
		if(DirectHitBonus[weapon] && damage >= 90.0)
		{
			TF2_AddCondition(attacker, TFCond_SpeedBuffAlly, DirectHitBonus_MaxDur[weapon], attacker);
			DirectHitBonus_Dur[weapon] = GetEngineTime();
			TF2Attrib_SetByName(weapon, "fire rate bonus HIDDEN", 1.0 - DirectHitBonus_FireRate[weapon]);
			SetClip_Weapon(weapon, GetClip_Weapon(weapon) + 1);
			SetAmmo_Weapon(weapon, GetAmmo_Weapon(weapon) - 1);
			TF2_RemoveCondition(victim, TFCond:15);
		}
	}
	return action;
}

public Action:Event_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
	new victim = GetClientOfUserId(GetEventInt(event, "userid"));
	new attacker = GetClientOfUserId(GetEventInt(event, "attacker"));
	if (attacker && attacker != victim)
	{
		new weapon = LastWeaponHurtWith[attacker];
		if(CursedHeads[weapon])
		{
			if(CursedHeads_Heads[weapon] < CursedHeads_MaxHeads[weapon] && GetEngineTime() >= CursedHeads_Dur[weapon] + CursedHeads_Minicrits[weapon])
				CursedHeads_Heads[weapon]++;
				
			SetEntProp(attacker, Prop_Data, "m_iMaxHealth", GetClientMaxHealth(attacker) + (CursedHeads_Heads[weapon] * 25));
		}
	}
}

public OnClientPreThink(client)
{
	new Float:flTime = GetEngineTime();
	if(flTime > g_flLastTick[client] + 0.1)
	{
		Attributes_PreThink(client);
		g_flLastTick[client] = flTime;
	}
}

stock Action:Attributes_PreThink(client)
{
	if (!Client_IsValid(client)) return Plugin_Continue;
	if (!IsValidClient(client)) return Plugin_Continue;
	if (!IsPlayerAlive(client)) return Plugin_Continue;
	new wep = Client_GetActiveWeapon(client);
	if (wep == -1)return Plugin_Continue;
	new slot = GetClientSlot(client);
	if (slot == -1 || slot > 3)return Plugin_Continue;
	new mel = GetPlayerWeaponSlot(client, 2);
	
	if(mel > -1 && CursedHeads[mel])
	{
		if(CursedHeads_Heads[mel] > 0 && GetEngineTime() >= CursedHeads_Dur[mel] + CursedHeads_Minicrits[mel]) TF2_AddCondition(client, TFCond:70, 0.2);
		
		if(GetClientHealth(client) <= GetClientMaxHealth(client) / 4 && CursedHeads_Heads[mel] > 0 && GetEngineTime() >= CursedHeads_Dur[mel] + CursedHeads_Minicrits[mel])
		{
			SetEntityHealth(client, GetClientMaxHealth(client));
			CursedHeads_Heads[mel]--;
			CursedHeads_Dur[mel] = GetEngineTime();
			EmitSoundToClient(client, "player/souls_receive1.wav");
			SetEntProp(client, Prop_Data, "m_iMaxHealth", GetClientMaxHealth(client) + (CursedHeads_Heads[mel] * 25));
			SetEntProp(client, Prop_Send, "m_iMaxHealth", GetClientMaxHealth(client) + (CursedHeads_Heads[mel] * 25));
		}
		if(GetEngineTime() < CursedHeads_Dur[mel] + CursedHeads_Minicrits[mel]) 
		{
			TF2_AddCondition(client, TFCond_MarkedForDeathSilent, 0.2);
		}
		
		SetHudTextParams(-1.0, 0.7, 0.2, 255, 255, 255, 255);
		ShowSyncHudText(client, CursedHeads_Display, "Heads: %i/%i", CursedHeads_Heads[mel], CursedHeads_MaxHeads[mel]);
	}
	if(TF2_IsPlayerInCondition(client, TFCond_OnFire) && !m_bIsBurning[client])
	{
		m_bIsBurning[client] = true;
	}
	else if(!TF2_IsPlayerInCondition(client, TFCond_OnFire) && m_bIsBurning[client])
	{
		m_bIsBurning[client] = false;
		if (m_iIgniter[client] > -1)m_iIgniter[client] = -1;
	}
	if(HasAttribute(client, _, m_bMSBPBP))
	{ 
		new targetslot = GetSlotContainingAttribute(client, m_bMSBPBP);
		new counter;
		new cap = GetAttributeValueI(client, _, m_bMSBPBP, m_iMSBPBP_Cap);
		for (new i = 1; i <= MaxClients; i++)
		{
			if (IsValidClient(i) && IsClientInGame(i) && IsPlayerAlive(i) && m_bIsBurning[i] && m_iIgniter[i] == client)
			{
				counter++;
			}
			continue;
		}
		TF2Attrib_RemoveByName(targetslot, "move speed bonus");
		if (counter > cap)counter = cap;
		TF2Attrib_SetByName(targetslot, "move speed bonus", GetAttributeValueF(client, _, m_bMSBPBP, m_flMSBPBP_Mult) * counter + 1.0);
		TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
	}
	if(DirectHitBonus[wep])
	{
		if(GetEngineTime() >= DirectHitBonus_Dur[wep] + DirectHitBonus_MaxDur[wep])
		{
			TF2Attrib_RemoveByName(wep, "fire rate bonus HIDDEN");
		}
	}
	return Plugin_Continue;
}

public OnEntityDestroyed(ent)
{
	if (ent < 0 || ent > 2048) return;
	CursedHeads[ent] = false;
	CursedHeads_Heads[ent] = 0;
	CursedHeads_Minicrits[ent] = 0.0;
	CursedHeads_MaxHeads[ent] = 0;
	DirectHitBonus[ent] = false;
	DirectHitBonus_FireRate[ent] = 0.0;
	DirectHitBonus_MaxDur[ent] = 0.0;
	DirectHitBonus_Dur[ent] = 0.0;
}
public CW3_OnWeaponRemoved(slot, client)
{
	m_bHasAttribute[client][slot] = false;
	m_bMSBPBP[client][slot] = false;
	m_iMSBPBP_Cap[client][slot] = 0;
	m_flMSBPBP_Mult[client][slot] = 0.0;
}