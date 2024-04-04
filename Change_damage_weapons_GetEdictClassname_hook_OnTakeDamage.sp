/**
 * Instant Kills.sp - (c) 2010 atom0s
 * SourceMod plugin for SourceMod v1.3.1 or higher.
 * This plugin requires SDKHooks.
 */
#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

/**
 * Plugin Version
 */
#define PLUGIN_VERSION "1.0.0"

/**
 * Plugin Infomation Struct
 */
public Plugin:myinfo = {
    name         = "Instant Kills",
    author         = "atom0s",
    description = "Implements one hit kills for non-bot players.",
    version     = PLUGIN_VERSION,
    url         = "N/A"
};

/**
 * Plugin Start Event
 */
public OnPluginStart( )
{
    // Create Version Cvar
    CreateConVar( "doubledamage_version", PLUGIN_VERSION, "Double Damage Bullets (by atom0s) version.", FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD );
}

/**
 * Player Load Event
 */
public OnClientPutInServer(client)
{
    if (!IsClientInGame(client) || !IsPlayerAlive(client))
    {
        SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
    }
}

/**
 * Player Hurt Event
 */
public Action:OnTakeDamage(victim, &attacker, &inflictor, &Float:damage, &damagetype)
{
    decl String:sWeapon[32];
    GetEdictClassname(inflictor, sWeapon, sizeof(sWeapon));
    
    if(StrEqual(sWeapon, "arrow"))
    {
        damage *= 3.0;
        return Plugin_Changed;
    }
    
    return Plugin_Continue;
} 