#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

#pragma semicolon 1

#define PLUGIN_VERSION "1.0"
#define PLUGIN_NAME "[FoF] Explosive Pumpkin Heads"

public Plugin myinfo =
{
    name = PLUGIN_NAME,
    author = "Paralhama",
    version = PLUGIN_VERSION,
    description = "All Players has pumpkin head explosive",
    url = "https://farwest.com.br/"
};

#define PUMPKIN_HEAD "models/props/halloween/normal_pumpkin.mdl"
#define PUMPKIN_EXPLOSIVE "models/props/halloween/explosive_pumpkin.mdl"

new PumpkinExplosive[MAXPLAYERS];
new bool:g_bPrecached = false;
int g_Models[MAXPLAYERS + 1] = {-1, ...};

public OnPluginStart()
{
	CreateConVar("sm_pumpkin_head_version", PLUGIN_VERSION, PLUGIN_NAME,
            FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_DONTRECORD);

	HookEvent("player_spawn", Event_PlayerSpawn);
	HookEvent("player_death", Event_PlayerDeath);
	HookEvent("player_team", Event_PlayerTeam);

}

public OnMapStart()
{
	g_bPrecached = false;

	AddFileToDownloadsTable(PUMPKIN_HEAD);
	AddFileToDownloadsTable(PUMPKIN_EXPLOSIVE);

	if(!PrecacheModel(PUMPKIN_HEAD)) {
		LogMessage("Cannot precache %s", PUMPKIN_HEAD);
		return;
	}

	if(!PrecacheModel(PUMPKIN_EXPLOSIVE)) {
		LogMessage("Cannot precache %s", PUMPKIN_HEAD);
		return;
	}

	g_bPrecached = true;
}

public Action:Event_PlayerSpawn(Handle:event, const String:name[], bool:dontbroadcast)
{
	if(!g_bPrecached)    return Plugin_Continue;

	new client = GetClientOfUserId(GetEventInt(event, "userid"));	

	SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.5 );  

	if(IsClientInGame(client) && IsPlayerAlive(client)) {
			CreateTimer(0.1, Create_Model, GetClientSerial(client));
		}

	return Plugin_Continue;
}

public Action:Event_PlayerDeath(Handle:event, const String:name[], bool:dontbroadcast)
{
	if(!g_bPrecached)    return Plugin_Continue;

	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	SetEntProp(client, Prop_Data, "m_nBody", 1);

	new victim = GetEventInt(event, "userid");
	new attacker = GetEventInt(event, "attacker");
	if(victim != attacker || attacker == 0)
	{
		SpawnPumpkinExplosive(client);
	}
	

	SafeDelete(g_Models[client]);
	g_Models[client] = -1;

	return Plugin_Continue;
}

public Action:Event_PlayerTeam(Handle:event, const String:name[], bool:dontbroadcast)
{
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
	g_Models[client] = CreatePumpkinHead();
	SDKHook(g_Models[client], SDKHook_SetTransmit, hide_pumpkin);
	PlaceAndBindIcon(client, g_Models[client]);
}

CreatePumpkinHead()
{
	new model = CreateEntityByName("prop_dynamic_override");

	if(model == -1)    return -1;

	DispatchKeyValue(model, "classname", "prop_dynamic_override");
	DispatchKeyValue(model, "spawnflags", "1");
	DispatchKeyValue(model, "disableshadows", "1");
	DispatchKeyValue(model, "solid", "0");
	DispatchKeyValue(model, "rendercolor", "255 255 255");
	DispatchKeyValue(model, "model", PUMPKIN_HEAD);
	if(DispatchSpawn(model))    return model;

	return -1;
}

PlaceAndBindIcon(client, entity)
{
	if(IsValidEntity(entity)) {
		SetVariantString("!activator");
		AcceptEntityInput(entity, "SetParent", client);
		SetVariantString("anim_attachment_head");
		AcceptEntityInput(entity, "SetParentAttachment", client);
		AcceptEntityInput(entity, "ClearParent", client);

		//                       ←     ↑ front/back
		//                       |     |     |
		TeleportEntity(entity, {0.0, -2.0, -1.0}, {90.0, 90.0, 0.0}, NULL_VECTOR);
		SetEntProp(client, Prop_Data, "m_nBody", 0);
	}
}

public Action hide_pumpkin( int entity, int client )
{
	//this is to not hide from others except me
	//if (entity == g_Models[client])
	//{
	//	return Plugin_Handled;
	//}

	//this is to hide pumpkin when spactate players in firstperson
	if (GetEntProp(client, PropType:0, "m_iObserverMode", 4, 0) == 4 && entity == g_Models[GetEntPropEnt(client, Prop_Send, "m_hObserverTarget")])
	{
		return Plugin_Handled;
	}


	return Plugin_Continue;//this is for actual user to hide from itself
}

SafeDelete(entity)
{
    if(IsValidEntity(entity)) {
        AcceptEntityInput(entity, "Break");
        AcceptEntityInput(entity, "Kill");
    }
} 

// ################################## Pumpkin Explosive Code ######################################################

public SpawnPumpkinExplosive(client)
{
	new Float:pos[3];
	GetClientAbsOrigin(client, pos);
	pos[2] += 60.0;

	new Float:ang[3];
	GetClientAbsAngles(client, ang);
	ang[1] = ang[1] + 90.0;

	PumpkinExplosive[client] = CreateEntityByName("prop_physics");

	if (PumpkinExplosive[client] == -1) { ReplyToCommand(client, "item failed to create."); return; }

	DispatchKeyValue(PumpkinExplosive[client], "model", PUMPKIN_EXPLOSIVE);
	DispatchKeyValue(PumpkinExplosive[client], "disableshadows", "1");
	DispatchSpawn(PumpkinExplosive[client]);
	TeleportEntity(PumpkinExplosive[client], pos, ang, NULL_VECTOR);
	AcceptEntityInput(PumpkinExplosive[client], "Ignite");
}

// ################################################################################################################