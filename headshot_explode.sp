#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <emitsoundany>
#pragma newdecls required

#define PLUGIN_VERSION	"1.1.1"
#define EXPLODE_SOUND	"ambient/explosions/explode_8.mp3"

Handle gPluginEnabled;
int g_ExplosionSprite;
int g_SmokeSprite;
float iNormal[3] = { 0.0, 0.0, 1.0 };

public Plugin myinfo = 
{
	name = "[CS:GO] HeadShot Explode",
	author = "tuty & Neoxx",
	description = "Explode enemy's body on Headshot.",
	version = PLUGIN_VERSION,
	url = "https://forums.alliedmods.net/showthread.php?p=2322854"
};

public void OnPluginStart()
{
	HookEvent("player_death", Event_PlayerDeath);
	CreateConVar("sm_headshot_explode", PLUGIN_VERSION, "HeadShot Explode", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);
	gPluginEnabled = CreateConVar("sm_headshot_explode", "1");
}

public void OnMapStart() 
{
	PrecacheSoundAny(EXPLODE_SOUND, true);
	AddFileToDownloadsTable("sound/ambient/explosions/explode_8.mp3");
	g_ExplosionSprite = PrecacheModel("sprites/blueglow2.vmt");
	AddFileToDownloadsTable("materials/sprites/blueglow2.vtf");
	AddFileToDownloadsTable("materials/sprites/blueglow2.vmt");
	g_SmokeSprite = PrecacheModel("sprites/steam2.vmt");
	AddFileToDownloadsTable("materials/sprites/steam2.vtf");
	AddFileToDownloadsTable("materials/sprites/steam2.vmt");
}

public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	if(GetConVarInt(gPluginEnabled) == 1)
	{
		int victim = GetClientOfUserId(event.GetInt("userid"));
		int attacker = GetClientOfUserId(event.GetInt("attacker"));

		if(victim == attacker)
			return Plugin_Handled;
		
		float iVec[3];
		GetClientAbsOrigin(victim, iVec);
		
		if(GetEventBool(event, "headshot"))
		{
			TE_SetupExplosion(iVec, g_ExplosionSprite, 5.0, 1, 0, 50, 40, iNormal);
			TE_SendToAll();
			
			TE_SetupSmoke(iVec, g_SmokeSprite, 10.0, 3);
			TE_SendToAll();
	
			EmitAmbientSoundAny(EXPLODE_SOUND, iVec, victim, SNDLEVEL_NORMAL);
		}
	}
	return Plugin_Continue;
}