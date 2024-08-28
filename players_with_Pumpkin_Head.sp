#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma semicolon 1


#define OVERLAY "models/props/halloween/pumpkin05.mdl"  //replace the name of file you going to use here

new bool:g_bPrecached = false;
int g_Models[MAXPLAYERS + 1] = {-1, ...};

public OnPluginStart()
{
    HookEvent("player_spawn", Event_PlayerSpawn);
    HookEvent("player_death", Event_PlayerDeath);
    HookEvent("round_end", Event_PlayerDeath);
}

public OnMapStart()
{
    g_bPrecached = false;
    
    AddFileToDownloadsTable(OVERLAY);
    
    if(!PrecacheModel(OVERLAY)) {
        LogMessage("Cannot precache %s", OVERLAY);
        return;
    }
    
    g_bPrecached = true;
}

public Action:Event_PlayerSpawn(Handle:event, const String:name[], bool:dontbroadcast)
{
	if(!g_bPrecached)    return Plugin_Continue;

	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if(GetClientTeam(client) > -1) {
		if(IsClientInGame(client) && IsPlayerAlive(client)) {
			CreateTimer(0.1, Create_Model, GetClientSerial(client));
		}
	}

	return Plugin_Continue;
}

public Action:Event_PlayerDeath(Handle:event, const String:name[], bool:dontbroadcast)
{
    if(!g_bPrecached)    return Plugin_Continue;
    
    new client = GetClientOfUserId(GetEventInt(event, "userid"));
    
    SafeDelete(g_Models[client]);
    g_Models[client] = -1;
    
    return Plugin_Continue;
}

public Action:Create_Model(Handle:iTimer, any:serial)
{
	new client = GetClientFromSerial(serial);

	if (!client)
	{
	return;
	}

	SafeDelete(g_Models[client]);
	g_Models[client] = CreateIcon();
	SDKHook(g_Models[client], SDKHook_SetTransmit, DESPERADOS);
	PlaceAndBindIcon(client, g_Models[client]);
	SetEntProp(client, Prop_Data, "m_nBody", 1);
}

CreateIcon()
{
	new model = CreateEntityByName("prop_dynamic");

	if(model == -1)    return -1;

	DispatchKeyValue(model, "classname", "prop_dynamic");
	DispatchKeyValue(model, "spawnflags", "1");
	DispatchKeyValue(model, "modelscale", "0.36");
	DispatchKeyValue(model, "disableshadows", "1");
	DispatchKeyValue(model, "rendermode", "1");
	DispatchKeyValue(model, "solid", "0");
	DispatchKeyValue(model, "rendercolor", "255 255 255");
	DispatchKeyValue(model, "model", OVERLAY);
	if(DispatchSpawn(model))    return model;

	return -1;
}

PlaceAndBindIcon(client, entity)
{
	if(IsValidEntity(entity)) {
		SetVariantString("!activator");
		AcceptEntityInput(entity, "SetParent", client);
		SetVariantString("forward");
		AcceptEntityInput(entity, "SetParentAttachment", client);
		TeleportEntity(entity, {-2.5, 0.0, -2.9}, {10.0, 8.0, 0.0}, NULL_VECTOR);
		SetEntProp(client, Prop_Data, "m_nBody", 1);
	}
}

public Action DESPERADOS( int entity, int client )
{
    if (entity == g_Models[client])
    {
        return Plugin_Handled;//this is to not hide from others except me
    }
    
    //if (GetClientTeam(client) != 2)
    //{
    //    return Plugin_Handled;//this is to hide for team if team not survivor hide for infected in my case
    //}
    
    return Plugin_Continue;//this is for actual user to hide from itself
}

SafeDelete(entity)
{
    if(IsValidEntity(entity)) {
        AcceptEntityInput(entity, "Break");
        AcceptEntityInput(entity, "Kill");
    }
} 
