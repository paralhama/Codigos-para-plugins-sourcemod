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
    description = "All players drop a pumpkin head explosive upon death.",
    url = ""
};

#define PUMPKIN_EXPLOSIVE "models/props/halloween/explosive_pumpkin.mdl"

new PumpkinExplosive[MAXPLAYERS];
new bool:g_bPrecached = false;

public OnPluginStart()
{
	CreateConVar("sm_pumpkin_head_version", PLUGIN_VERSION, PLUGIN_NAME,
            FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY | FCVAR_DONTRECORD);

	HookEvent("player_death", Event_PlayerDeath);

}

public OnMapStart()
{
	g_bPrecached = false;

	AddFileToDownloadsTable(PUMPKIN_EXPLOSIVE);

	if(!PrecacheModel(PUMPKIN_EXPLOSIVE)) {
		LogMessage("Cannot precache %s", PUMPKIN_EXPLOSIVE);
		return;
	}

	g_bPrecached = true;
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

	return Plugin_Continue;
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

