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
    HookEvent( "player_shoot", Event_PlayerShoot );
}

public Event_PlayerShoot( Handle:hEvent, const String:szEventName[], bool:bDontBroadcast )
{
	new iUserID = GetEventInt( hEvent, "userid" );
	new iClient = GetClientOfUserId( iUserID );
	new hClientWeapon = GetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon");
	new hClientWeapon2 = GetEntPropEnt(iClient, Prop_Send, "m_hActiveWeapon2");

	if ( hClientWeapon != -1 )
	{
		SetEntProp(hClientWeapon, Prop_Send, "m_iClip1", 100);
	}

	if ( hClientWeapon2 != -1 )
	{
		SetEntProp(hClientWeapon2, Prop_Send, "m_iClip1", 100);
	}
}