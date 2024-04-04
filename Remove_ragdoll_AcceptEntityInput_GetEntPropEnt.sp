#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public Plugin:myinfo = 
{
	name = "Remove ragdoll",
	author = "paralhama",
	description = "",
	version = "1.1",
	url = ""
}

public OnPluginStart(){
    HookEvent( "player_death", Event_PlayerDeath );
}

public Event_PlayerDeath( Handle:hEvent, const String:szEventName[], bool:bDontBroadcast )
{
	new iUserID = GetEventInt( hEvent, "userid" );
	new iClient = GetClientOfUserId( iUserID );
	int BodyRagdoll = GetEntPropEnt(iClient, Prop_Send, "m_hRagdoll");
	if(IsValidEdict(BodyRagdoll))
	{
		AcceptEntityInput(BodyRagdoll, "kill");
	}
}