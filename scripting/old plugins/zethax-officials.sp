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

#define PLUGIN_VERSION "0.1"
#define SLOTS_MAX 7

public Plugin:myinfo = {
	name = "Zethax Official Weapon Mods",
	author = "Zethax",
	description = "Includes a bunch of attributes used to modify official weapons on cTF2w servers",
	version = PLUGIN_VERSION,
	url = ""
};

new bool:HealBonusWhileCapping[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:HealBonusWhileCapping_Bonus[MAXPLAYERS + 1][SLOTS_MAX + 1];

new bool:SpeedBonusWhileCapping[MAXPLAYERS + 1][SLOTS_MAX + 1];
new Float:SpeedBonusWhileCapping_Bonus[MAXPLAYERS + 1][SLOTS_MAX + 1];

new bool:MultipleHitsIgnite[2049];
new MultipleHitsIgnite_MaxHits[2049];
new MultipleHitsIgnite_Hits[2049];
new Float:MultipleHitsIgnite_Delay[2049];

new bool:BleedExplosion[2049];
new Float:BleedExplosion_Radius[2049];
new Float:BleedExplosion_Duration[2049];
new BleedExplosion_Damage[2049];
new BleedExplosion_Type[2049];

new bool:NewCritacola[MAXPLAYERS + 1][SLOTS_MAX + 1];

new bool:NewBlackbox[2049];
new Float:NewBlackbox_MinHP[2049];
new Float:NewBlackbox_MaxHP[2049];

new Float:TimeBleeding[MAXPLAYERS + 1];
new LastWeaponHurtWith[MAXPLAYERS + 1];
new Float:LastTick[MAXPLAYERS + 1];

public OnPluginStart() {
	
	HookEvent("controlpoint_starttouch", Event_ControlpointStarttouch);
	HookEvent("controlpoint_endtouch", Event_ControlpointEndtouch);
	HookEvent("teamplay_flag_event", Event_TeamplayFlagEvent);
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i)) continue;
		{
		OnClientPutInServer(i);
		}
	}
}
public OnClientPutInServer(client) {
	
	SDKHook(client, SDKHook_OnTakeDamagePost, OnTakeDamagePost);
	SDKHook(client, SDKHook_PreThink, OnClientPreThink);
	
	LastWeaponHurtWith[client] = 0;
}

public Action:CW3_OnAddAttribute(slot, client, const String:attrib[], const String:plugin[], const String:value[], bool:whileActive)
{
	if (!StrEqual(plugin, "zethax-officials"))return Plugin_Continue;
	new Action:action;
	
	new weapon = GetPlayerWeaponSlot(client, slot);
	
	if(StrEqual(attrib, "healing bonus while capping")) {
		
		HealBonusWhileCapping_Bonus[client][slot] = StringToFloat(value);
		HealBonusWhileCapping[client][slot] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "speed bonus while capping")) {
		
		SpeedBonusWhileCapping_Bonus[client][slot] = StringToFloat(value);
		SpeedBonusWhileCapping[client][slot] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "multiple hits ignite")) {
	
		if (weapon == -1)return Plugin_Continue;
		MultipleHitsIgnite[weapon] = true;
		MultipleHitsIgnite_MaxHits[weapon] = StringToInt(value);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "bleeding explosion")) {
	
		if (weapon == -1)return Plugin_Continue;
		new String:values[4][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		BleedExplosion[weapon] = true;
		BleedExplosion_Radius[weapon] = StringToFloat(values[0]);
		BleedExplosion_Duration[weapon] = StringToFloat(values[1]);
		BleedExplosion_Damage[weapon] = StringToInt(values[2]);
		BleedExplosion_Type[weapon] = StringToInt(values[3]);
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "new critacola")) {
	
		NewCritacola[client][slot] = true;
		action = Plugin_Handled;
	} else if(StrEqual(attrib, "rage mult health on hit")) {
	
		if (weapon == -1)return Plugin_Continue;
		new String:values[2][10];
		ExplodeString(value, " ", values, sizeof(values), sizeof(values[]));
		NewBlackbox[weapon] = true;
		NewBlackbox_MinHP[weapon] = StringToFloat(values[0]);
		NewBlackbox_MaxHP[weapon] = StringToFloat(values[1]);
		action = Plugin_Handled;
	}
	if (!m_bHasAttribute[client][slot]) m_bHasAttribute[client][slot] = bool:action;
	return action;
}

public OnTakeDamagePost(victim, attacker, inflictor, Float:damage, damagetype, weapon, const Float:damageForce[3], const Float:damagePosition[3], damageCustom)
{
	if (!Client_IsValid(attacker))return;
	if (!Client_IsValid(victim))return;
	if(weapon > -1)
	{
		if(MultipleHitsIgnite[weapon])
		{
			if (GetEngineTime() >= MultipleHitsIgnite_Delay[victim] + 1.0)
				MultipleHitsIgnite_Hits[victim] = 0;
			
			MultipleHitsIgnite_Hits[victim]++;
			MultipleHitsIgnite_Delay[victim] = GetEngineTime();
			if(MultipleHitsIgnite_Hits[victim] >= MultipleHitsIgnite_MaxHits[weapon])
			{
				MultipleHitsIgnite_Hits[victim] = 0;
				TF2_IgnitePlayer(victim, attacker);
			}
		}
		if(BleedExplosion[weapon])
		{
			if(BleedExplosion_Type[weapon] == 0 || BleedExplosion_Type[weapon] == 2)
			{
				if(damageCustom == 22 && TimeBleeding[victim] >= 0.2)
				{
					DealExplosion(victim, attacker, weapon, 25, BleedExplosion_Duration[weapon], BleedExplosion_Damage[weapon], BleedExplosion_Radius[weapon], 1);
				}
			}
			if(BleedExplosion_Type[weapon] == 0 || BleedExplosion_Type[weapon] == 1)
			{
				if(damagetype & DMG_CLUB == DMG_CLUB && TimeBleeding[victim] >= 0.2)
				{
					DealExplosion(victim, attacker, weapon, 25, BleedExplosion_Duration[weapon], BleedExplosion_Damage[weapon], BleedExplosion_Radius[weapon], 1);
				}
			}
		}
	}
}

public OnClientPreThink(client)
{
	if(GetEngineTime() >= LastTick[client] + 0.1)
	{
		if(TF2_IsPlayerInCondition(client, TFCond_Bleeding))
		{
			TimeBleeding[client] += 0.1;
			//PrintToChatAll("Time %N has been bleeding: %i seconds", client, RoundFloat(TimeBleeding[client]));
		}
		if(!TF2_IsPlayerInCondition(client, TFCond_Bleeding))
			TimeBleeding[client] = 0.0;
		Attributes_PreThink(client);
		LastTick[client] = GetEngineTime();
	}
}

public TF2_OnConditionAdded(client, TFCond:cond)
{
	if(cond == TFCond:19)
	{
		if(HasAttribute(client, _, NewCritacola))
		{
			TF2_AddCondition(client, TFCond_Buffed, 8.0);
			TF2_RemoveCondition(client, TFCond:19);
		}
	}
}
public TF2_OnConditionRemoved(client, TFCond:cond)
{
	if(cond == TFCond:78)
	{
		if(HasAttribute(client, _, NewCritacola))
		{
			CreateTimer(0.1, RemoveMFD, EntIndexToEntRef(client), TIMER_FLAG_NO_MAPCHANGE);
		}
	}
}
public Action:RemoveMFD(Handle:timer, any:ref)
{
	new client = EntRefToEntIndex(ref);
	TF2_RemoveCondition(client, TFCond_MarkedForDeath);
	TF2_RemoveCondition(client, TFCond_MarkedForDeathSilent);
}

public Action:Event_ControlpointStarttouch(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetEventInt(event, "player", -1);
	if(client > 0)
	{
		if(HasAttribute(client, _, HealBonusWhileCapping))
		{
			new wep = GetPlayerWeaponSlot(client, GetSlotContainingAttribute(client, HealBonusWhileCapping));
			TF2Attrib_SetByName(wep, "health from healers increased", GetAttributeValueF(client, _, HealBonusWhileCapping, HealBonusWhileCapping_Bonus));
			TF2Attrib_SetByName(wep, "health from packs increased", GetAttributeValueF(client, _, HealBonusWhileCapping, HealBonusWhileCapping_Bonus));
			TF2Attrib_SetByName(wep, "reduced_healing_from_medics", GetAttributeValueF(client, _, HealBonusWhileCapping, HealBonusWhileCapping_Bonus));
		}
		if(HasAttribute(client, _, SpeedBonusWhileCapping))
		{
			new wep = GetPlayerWeaponSlot(client, GetSlotContainingAttribute(client, SpeedBonusWhileCapping));
			TF2Attrib_SetByName(wep, "move speed bonus", GetAttributeValueF(client, _, SpeedBonusWhileCapping, SpeedBonusWhileCapping_Bonus));
			TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
		}
	}
	return Plugin_Continue;
}

public Action:Event_ControlpointEndtouch(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetEventInt(event, "player", -1);
	if(client > 0)
	{
		if(HasAttribute(client, _, HealBonusWhileCapping))
		{
			new wep = GetPlayerWeaponSlot(client, GetSlotContainingAttribute(client, HealBonusWhileCapping));
			TF2Attrib_RemoveByName(wep, "health from healers increased");
			TF2Attrib_RemoveByName(wep, "health from packs increased");
			TF2Attrib_RemoveByName(wep, "reduced_healing_from_medics");
		}
		if(HasAttribute(client, _, SpeedBonusWhileCapping))
		{
			new wep = GetPlayerWeaponSlot(client, GetSlotContainingAttribute(client, SpeedBonusWhileCapping));
			TF2Attrib_RemoveByName(wep, "move speed bonus");
			TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
		}
	}
}

public Action:Event_TeamplayFlagEvent(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetEventInt(event, "player", -1);
	new eventtype = GetEventInt(event, "eventtype", 0);
	if(client > 0)
	{
		switch(eventtype)
		{
			case 1:
			{
				if(HasAttribute(client, _, HealBonusWhileCapping))
				{
					new wep = GetPlayerWeaponSlot(client, GetSlotContainingAttribute(client, HealBonusWhileCapping));
					TF2Attrib_SetByName(wep, "health from healers increased", GetAttributeValueF(client, _, HealBonusWhileCapping, HealBonusWhileCapping_Bonus));
					TF2Attrib_SetByName(wep, "health from packs increased", GetAttributeValueF(client, _, HealBonusWhileCapping, HealBonusWhileCapping_Bonus));
					TF2Attrib_SetByName(wep, "reduced_healing_from_medics", GetAttributeValueF(client, _, HealBonusWhileCapping, HealBonusWhileCapping_Bonus));
				}
				if(HasAttribute(client, _, SpeedBonusWhileCapping))
				{
					new wep = GetPlayerWeaponSlot(client, GetSlotContainingAttribute(client, SpeedBonusWhileCapping));
					TF2Attrib_SetByName(wep, "move speed bonus", GetAttributeValueF(client, _, SpeedBonusWhileCapping, SpeedBonusWhileCapping_Bonus));
					TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
				}
			}
			case 4:
			{
				if(HasAttribute(client, _, HealBonusWhileCapping))
				{
					new wep = GetPlayerWeaponSlot(client, GetSlotContainingAttribute(client, HealBonusWhileCapping));
					TF2Attrib_RemoveByName(wep, "health from healers increased");
					TF2Attrib_RemoveByName(wep, "health from packs increased");
					TF2Attrib_RemoveByName(wep, "reduced_healing_from_medics");
				}
				if(HasAttribute(client, _, SpeedBonusWhileCapping))
				{
					new wep = GetPlayerWeaponSlot(client, GetSlotContainingAttribute(client, SpeedBonusWhileCapping));
					TF2Attrib_RemoveByName(wep, "move speed bonus");
					TF2_AddCondition(client, TFCond_SpeedBuffAlly, 0.001);
				}
			}
		}
	}
	return Plugin_Continue;
}

stock Attributes_PreThink(client)
{
	if (!IsValidClient(client) || !IsClientInGame(client) || !IsPlayerAlive(client))return;
	new weapon = Client_GetActiveWeapon(client);
	if (weapon <= 0)return;
	if(NewBlackbox[weapon])
	{
		new healing = (NewBlackbox_MinHP[weapon] - NewBlackbox_MaxHP[weapon]) * (GetEntPropFloat(client, Prop_Send, "m_flRageMeter") / 100.0) + NewBlackbox_MinHP[weapon];
		TF2Attrib_SetByName(weapon, "health on radius damage", healing);
	}
}

public CW3_OnWeaponRemoved(slot, client)
{
	HealBonusWhileCapping[client][slot] = false;
	HealBonusWhileCapping_Bonus[client][slot] = 0.0;
	SpeedBonusWhileCapping[client][slot] = false;
	SpeedBonusWhileCapping_Bonus[client][slot] = 0.0;
	NewCritacola[client][slot] = false;
}

public OnEntityDestroyed(Ent)
{
	if(Ent <= 0 || Ent > 2048) return;
	MultipleHitsIgnite[Ent] = false;
	MultipleHitsIgnite_Hits[Ent] = 0;
	MultipleHitsIgnite_MaxHits[Ent] = 0;
	MultipleHitsIgnite_Delay[Ent] = 0.0;
	BleedExplosion[Ent] = false;
	BleedExplosion_Damage[Ent] = 0;
	BleedExplosion_Duration[Ent] = 0.0;
	BleedExplosion_Radius[Ent] = 0.0;
	BleedExplosion_Type[Ent] = 0;
	NewBlackbox[Ent] = false;
	NewBlackbox_MinHP[Ent] = 0.0;
	NewBlackbox_MaxHP[Ent] = 0.0;
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

stock DealExplosion(victim, attacker, weapon, condition, Float:conddur, damage, Float:radius, situation)
{
	for (new i = 1; i <= MaxClients; i++)
	{
		new Float:Pos1[3];
		GetClientAbsOrigin(victim, Pos1);
		if(Client_IsValid(i) && IsClientInGame(i) && IsPlayerAlive(i))
		{
			new Float:Pos2[3];
			GetClientAbsOrigin(i, Pos2);
			new Float:distance = GetVectorDistance(Pos1, Pos2);
			if(situation == 0)
			{
				if(distance <= radius)
				{
					if(damage > 0)
						Entity_Hurt(i, BleedExplosion_Damage[weapon], attacker, DMG_GENERIC);
					if(damage < 0)
					{
						SetEntityHealth(i, GetClientHealth(i) + damage)
						new Handle:healevent = CreateEvent("player_healed", true);
						SetEventInt(healevent, "patient", i);
						SetEventInt(healevent, "healer", attacker);
						SetEventInt(healevent, "amount", damage);
						FireEvent(healevent);
					}
					
					if(conddur > 0.0 && condition > 0)
						TF2_AddCondition(i, TFCond:condition, conddur, attacker);
					
					if(condition == 25)
						TF2_MakeBleed(i, attacker, conddur);
					
					if(condition == 22)
						TF2_IgnitePlayer(i, attacker);
				}
			}
			if(situation == 1 && GetClientTeam(i) == GetClientTeam(victim) && i != victim)
			{
				if(distance <= radius)
				{
					if(damage > 0)
						Entity_Hurt(i, BleedExplosion_Damage[weapon], attacker, DMG_GENERIC);
					if(damage < 0)
					{
						SetEntityHealth(i, GetClientHealth(i) + damage)
						new Handle:healevent = CreateEvent("player_healed", true);
						SetEventInt(healevent, "patient", i);
						SetEventInt(healevent, "healer", attacker);
						SetEventInt(healevent, "amount", damage);
						FireEvent(healevent);
					}
					
					if(conddur > 0.0 && condition > 0)
						TF2_AddCondition(i, TFCond:condition, conddur, attacker);
					
					if(condition == 25)
						TF2_MakeBleed(i, attacker, conddur);
					
					if(condition == 22)
						TF2_IgnitePlayer(i, attacker);
				}
			}
			if(situation == 2 && GetClientTeam(i) == GetClientTeam(attacker) && i != attacker)
			{
				if(distance <= radius)
				{
					if(damage > 0)
						Entity_Hurt(i, BleedExplosion_Damage[weapon], attacker, DMG_GENERIC);
					if(damage < 0)
					{
						SetEntityHealth(i, GetClientHealth(i) + damage)
						new Handle:healevent = CreateEvent("player_healed", true);
						SetEventInt(healevent, "patient", i);
						SetEventInt(healevent, "healer", attacker);
						SetEventInt(healevent, "amount", damage);
						FireEvent(healevent);
					}
					
					if(conddur > 0.0 && condition > 0)
						TF2_AddCondition(i, TFCond:condition, conddur, attacker);
					
					if(condition == 25)
						TF2_MakeBleed(i, attacker, conddur);
					
					if(condition == 22)
						TF2_IgnitePlayer(i, attacker);
				}
			}
		}
	}
	return;
}