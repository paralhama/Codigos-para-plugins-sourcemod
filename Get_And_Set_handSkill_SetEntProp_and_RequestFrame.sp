#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public Plugin:myinfo = 
{
	name = "Modify hand skill",
	author = "paralhama",
	description = "",
	version = "1.1",
	url = ""
}

public OnPluginStart(){
	HookEvent( "player_spawn", Event_PlayerSpawn );
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
    int userid = event.GetInt("userid");
    RequestFrame(Frame_ChangeHandStance, userid);
}

void Frame_ChangeHandStance(int userid)
{
    int client = GetClientOfUserId(userid);
    if (client && IsClientInGame(client) && IsPlayerAlive(client)) 
    {
        SetEntProp(client, Prop_Send, "m_nHandStance", 0);
    }
}