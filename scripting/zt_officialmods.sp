#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <tf2_stocks>
#include <zethax>
#include <tf2attributes>

#define PLUGIN_NAME "Zethax's weapon mods"
#define PLUGIN_AUTHOR "Zethax"
#define PLUGIN_DESCRIPTION "Contains a list of mods to stock weapons, some of which are custom."
#define PLUGIN_VERSION "alpha 1"

new Float:LastTick[MAXPLAYERS + 1];

/*

List of the current weapons this plugin mods and in what form:
	-All Miniguns
		-Gain 20% damage resistance while spun up. This is reduced by half while overhealed or while being healed.
		
	-Brass Beast
		-Gain 25% damage resistance while spun up, regardless of conditions listed above
	
	-Buffalo Steak Sandvich
		-User can now pull out minigun while under the effects, but ends the effects right there
		
	-Phlogistinator
		-Is now the only flamethrower that inflicts the healing debuff
		-Phlog crits replaced with instant health restoration and temporary damage resistance
		
	-Enforcer
		-Now deals bonus damage based on cloak meter, up to 30% more damage at full meter
		-Dealing damage drains little bits of cloak depending on bonus damage dealt
		-On kill: Cloak lost is restored completely
		-Firing stops cloak regen for 1s
		-Still retains slower firing speed
		
	-L'Etranger
		-50% of damage dealt is returned as cloak
		-This feature makes cloak restoration range between 8% and 24%, allowing for more overall cloak restoration.
		
*/

public Plugin myinfo = {
    name = PLUGIN_NAME,
    author = PLUGIN_AUTHOR,
    description = PLUGIN_DESCRIPTION,
    version = PLUGIN_VERSION,
    url = ""
};

public OnPluginStart() {
	
	for (new i = 1; i <= MaxClients; i++)
	{
		if (!IsValidClient(i)) continue;
		{
		OnClientPutInServer(i);
		}
	}
}

public void OnClientPutInServer(client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
	SDKHook(client, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive);
	SDKHook(client, SDKHook_PreThink, OnClientPreThink);
}

public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype, &weapon, Float:damageForce[3], Float:damagePosition[3])
{
	if (!IsValidClient(attacker))return Plugin_Continue;
	if (!IsValidClient(victim))return Plugin_Continue;
	
	Action action;
	
	//This big piece right here controls Heavy damage resistance while spun up
	if(TF2_GetPlayerClass(victim) == TFClass_Heavy) //If the victim is a heavy
	{
		if(TF2_IsPlayerInCondition(victim, TFCond:0)) //If said heavy has their minigun revved 
		{
			if(GetEntProp(GetPlayerWeaponSlot(victim, 0), Prop_Send, "m_iItemDefinitionIndex") == 312) //Brass Beast
			{
				damage *= 0.75; //Reduce damage taken by 25%
				action = Plugin_Changed;
			}
			else if(GetClientHealth(victim) <= GetClientMaxHealth(victim) && GetEntProp(victim, Prop_Send, "m_nNumHealers") == 0) //If the heavy is not overhealed and is not being healed
			{
				damage *= 0.8; //Reduce damage taken by 20%
				action = Plugin_Changed; //Tells the plugin damage has changed
			}
			else if(GetClientHealth(victim) > GetClientMaxHealth(victim) || GetEntProp(victim, Prop_Send, "m_nNumHealers") > 0) //If the heavy is overhealed or has a healer
			{
				damage *= 0.9; //Reduce damage taken by 10%
				action = Plugin_Changed;
			}
			else if(GetClientHealth(victim) > GetClientMaxHealth(victim) && GetEntProp(victim, Prop_Send, "m_nNumHealers") > 0) //If the heavy is overhealed and has a healer
			{
				action = Plugin_Continue; //Do not change the damage
			}
		}
	}
	
	//This little chunk right here just makes it so the Phlogistinator is the only flamethrower that inflicts the healing debuff
	if(TF2_IsPlayerInCondition(victim, TFCond:118)) //If the victim is affected by the healing debuff
	{
		if(GetEntProp(weapon, Prop_Send, "m_iItemDefinitionIndex") != 594) //If the weapon is NOT the Phlogistinator
		{
			TF2_RemoveCondition(victim, TFCond:118); //Remove the healing debuff
		}
	}
	return action;
}

public OnTakeDamageAlive(victim, attacker, inflictor, Float:damage, damagetype, weapon)
{
	if(TF2_GetPlayerClass(attacker) == TFClass_Spy)
	{
		if(GetWeaponIndex(weapon) == 224) //L'Etranger
		{
			new Float:cloak = GetEntPropFloat(attacker, Prop_Send, "m_flCloakMeter");
			cloak += damage * 0.5;
			if(cloak > 100.0) cloak = 100.0;
			SetEntPropFloat(attacker, Prop_Send, "m_flCloakMeter", cloak);
		}
	}
}

public Action:OnClientPreThink(client)
{
	Action action;
	
	if(GetEngineTime() >= LastTick[client] + 0.1) //If 1/10th of a second has passed
	{
		if(TF2_GetPlayerClass(client) == TFClass_Heavy) //If the client is a Heavy
		{
			//If cvarBuffaloEffects is set up and the player is under the effects of the Buffalo Steak
			if(TF2_IsPlayerInCondition(client, TFCond:19))
			{
				//If the client's active weapon is their minigun
				if(GetActiveWeapon(client) == GetPlayerWeaponSlot(client, 0))
				{
					TF2_RemoveCondition(client, TFCond:19); //Remove the buffalo steak minicrits
				}
				
				/*
				if(TF2_IsPlayerInCondition(client, TFCond:0)) //If the player is spun up with their minigun
				{
					TF2_AddCondition(client, TFCond_MarkedForDeathSilent, 0.2); //Mark them for death
				}
				*/
				
				TF2_RemoveCondition(client, TFCond:41); //Removes the 'bound to melee' effect
			}
		}
		
		if(TF2_GetPlayerClass(client) == TFClass_Pyro)
		{
			if(TF2_IsPlayerInCondition(client, TFCond:52)) //If Phlog crits are added to the client
			{
				SetEntityHealth(client, GetClientMaxHealth(client)); //Fills the player's health to full
				TF2_AddCondition(client, TFCond:45, 10.0); //Gives the player some temporary damage resistance
			}
		}
		
		LastTick[client] = GetEngineTime(); //Resets the delay
	}
	
	return action;
}

public TF2_OnConditionAdded(client, TFCond:cond)
{
	if(cond == TFCond:44)
	{
		TF2_RemoveCondition(client, TFCond:44);
	}
}

//Checks if the client is connected, alive, and a valid client
//@param client			The target client
//@param replaycheck	Check if the target is SourceTV or Replay
stock bool:IsValidClient(client, bool:replaycheck = true)
{
    if(client <= 0 || client > MaxClients) return false;
    if(!IsClientInGame(client)) return false;
    if(!IsClientConnected(client)) return false;
    if(GetEntProp(client, Prop_Send, "m_bIsCoaching")) return false;
    if(replaycheck)
    {
        if(IsClientSourceTV(client) || IsClientReplay(client)) return false;
    }
    return true;
}
