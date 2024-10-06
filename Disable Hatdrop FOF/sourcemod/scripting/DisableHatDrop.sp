#include <sdktools>
#include <sdkhooks>

public OnPluginStart()
{
	HookEvent("hatshot", OnHatShot, EventHookMode_Pre);
	HookEvent("player_spawn", Event_PlayerSpawn);
}

public Action OnHatShot(Handle:event, const String:name[], bool:dontBroadcast)
{
	SetEventBroadcast(event, true);
	return Plugin_Changed;
}

public void OnClientPutInServer(int client)
{
	SDKHook(client, SDKHook_TraceAttack, DisableHatHitGroup);
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	CreateTimer(0.5, RemoveHatTimer, _, TIMER_REPEAT);
}

public Action DisableHatHitGroup(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &ammotype, int hitbox, int hitgroup)
{
	if (hitgroup == 8)
	{
		PrintToChatAll("tiro no chapéu");
		damage = 0.0;
	}

	return Plugin_Changed;
}

stock GetSO()
{
     new Handle:conf = LoadGameConfigFile("DisableHatDrop");
     new WindowsOrLinux = GameConfGetOffset(conf, "WindowsOrLinux");
     CloseHandle(conf);
     return WindowsOrLinux; // 1 para Windows; 2 para Linux
}

public Action RemoveHatTimer(Handle:timer, any:iGrenade)
{
	for(int i = 0 + 1;i < MaxClients+1;i++)
	{
		if(IsValidEntity(i) && IsValidEdict(i))
		{
			if(IsPlayerAlive(i))
				RemoveHat(i);
		}
	}
	
	return Plugin_Continue;
}

void RemoveHat(int client)
{
	new SO = GetSO();

	int hatlessOffset = 0;
	
	// Verifica se o sistema é Windows ou Linux
	if (SO == 1)
		hatlessOffset = 4980;
	else
		hatlessOffset = 5000;
		
	SetEntData(client, hatlessOffset, 0, 4, true);
	SetEntProp(client, Prop_Data, "m_nBody", 1);
	SetEntProp(client, Prop_Send, "m_nHitboxSet", 1);
}