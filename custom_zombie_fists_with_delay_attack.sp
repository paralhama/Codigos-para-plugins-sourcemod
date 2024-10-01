/**
 * vim: set ts=4 :
 * ===========================================================================================
 * This plugin change the weapon_fists by a custom view model to players on the infected team
 * The attack speed has been degrease for prevent animations bug on the custom view model
 * ===========================================================================================
 *
 */
#include <sourcemod>
#include <sdkhooks> 
#include <sdktools>

#define TEAM_ZOMBIE 3  // Desperados
#define COOLDOWN_TIME 0.6 // 1 segundo de cooldown

new Float:g_flLastAttack[MAXPLAYERS+1]; // Armazena o tempo do último ataque primário
new Float:g_flLastAttack2[MAXPLAYERS+1]; // Armazena o tempo do último ataque secundário
new bool:g_SoundAttack[MAXPLAYERS+1] = {false, ...};
new Float:currentTime;

new g_PVMid[MAXPLAYERS+1]; // Predicted ViewModel ID's
new g_iClawModel;    // Custom ViewModel index

public OnPluginStart()
{
	HookEvent("player_spawn", Event_PlayerSpawn);
	AddNormalSoundHook(SoundCallback);
}

public OnConfigsExecuted()
{
    g_iClawModel = PrecacheModel("models/fof_skins/players/infected/arms/infected_fists.mdl"); // Custom model
}

public OnClientPostAdminCheck(client){
    SDKHook(client, SDKHook_WeaponSwitchPost, OnClientWeaponSwitchPost);    
}

public OnClientWeaponSwitchPost(client, wpnid)
{
    
    decl String:szWpn[64];
    GetEntityClassname(wpnid,szWpn,sizeof(szWpn));
    
    if(StrEqual(szWpn, "weapon_fists")  && IsZombie(client) && IsClientInGame(client) && IsPlayerAlive(client))
	{
        SetEntProp(wpnid, Prop_Send, "m_nModelIndex", 0);
        SetEntProp(g_PVMid[client], Prop_Send, "m_nModelIndex", g_iClawModel);
    }
}

public Event_PlayerSpawn(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(IsZombie(client))
	{
		g_PVMid[client] = Weapon_GetViewModelIndex2(client, -1);
    }
} 

// Thanks to gubka for these 2 functions below.

// Get model index and prevent server from crash
Weapon_GetViewModelIndex2(client, sIndex)
{
	if(IsZombie(client))
	{
		while ((sIndex = FindEntityByClassname2(sIndex, "predicted_viewmodel")) != -1)
		{
			new Owner = GetEntPropEnt(sIndex, Prop_Send, "m_hOwner");
			
			if (Owner != client)
				continue;
			
			return sIndex;
		}
	}
	return -1;
}
// Get entity name
FindEntityByClassname2(sStartEnt, String:szClassname[])
{
    while (sStartEnt > -1 && !IsValidEntity(sStartEnt)) sStartEnt--;
    return FindEntityByClassname(sStartEnt, szClassname);
}

bool IsZombie(int client)
{
    return GetClientTeam(client) == TEAM_ZOMBIE;
}

Action SoundCallback(int clients[MAXPLAYERS], int &numClients,
        char sample[PLATFORM_MAX_PATH], int &entity, int &channel,
        float &volume, int &level, int &pitch, int &flags,
        char soundEntry[PLATFORM_MAX_PATH], int &seed)
{
    if (0 < entity <= MaxClients)
    {
        // change the voice of zombie players
        if (IsZombie(entity))
        {
            // change to zombie footsteps
            if (StrContains(sample, "player/footsteps") == 0)
            {
				Format(sample, sizeof(sample), "npc/zombie/foot%d.wav", GetRandomInt(1, 3));
				return Plugin_Changed;
            }

            // change zombie punching
            if (StrContains(sample, "weapons/fists/fists_punch") == 0)
            {
				g_SoundAttack[entity] = true;
				Format(sample, sizeof(sample), "npc/zombie/claw_strike%d.wav", GetRandomInt(1, 3));
				return Plugin_Changed;
            }
			else
			{
				g_SoundAttack[entity] = false;
			}

            // change zombie punch missing
            if (StrContains(sample, "weapons/fists/fists_miss") == 0)
            {
				g_SoundAttack[entity] = true;
				Format(sample, sizeof(sample), "npc/zombie/claw_miss%d.wav", GetRandomInt(1, 2));
				return Plugin_Changed;
            }
			else
			{
				g_SoundAttack[entity] = false;
			}

            // change zombie death sound
            if (StrContains(sample, "player/voice/pain/pl_death") == 0 ||
                    StrContains(sample, "player/voice2/pain/pl_death") == 0 ||
                    StrContains(sample, "player/voice4/pain/pl_death") == 0 ||
                    StrContains(sample, "npc/mexican/death") == 0)
            {
				Format(sample, sizeof(sample), "npc/zombie/zombie_die%d.wav", GetRandomInt(1, 3));
				return Plugin_Changed;
            }

            if (StrContains(sample, "player/voice") == 0 ||
                    StrContains(sample, "npc/mexican") == 0)
            {
				Format(sample, sizeof(sample), "npc/zombie/moan-%02d.wav", GetRandomInt(1, 14));
				return Plugin_Changed;
            }
        }
    }
    return Plugin_Continue;
}

public Action:OnPlayerRunCmd(client, &buttons, &impulse, Float:vel[3], Float:angles[3], &weapon)
{
    // Pega o tempo atual do jogo (Declara a variável Float no escopo correto)
    currentTime = GetGameTime();

    // Verifica o ataque primário (IN_ATTACK)
    if (buttons & IN_ATTACK && IsZombie(client) && IsClientInGame(client) && IsPlayerAlive(client))
    {
        // Se o tempo desde o último ataque for menor que o cooldown, cancela o ataque
        if (currentTime - g_flLastAttack[client] < COOLDOWN_TIME)
        {
			buttons &= ~IN_ATTACK; // Desativa o ataque
			g_flLastAttack2[client] = currentTime;
        }
        else
        {
			// Se já passou o tempo de cooldown, atualiza o tempo do último ataque
			g_flLastAttack[client] = currentTime;
			if (g_SoundAttack[client])
			{
				SetEntProp(g_PVMid[client], Prop_Send, "m_nSequence", 5);
			}
			else
			{
				SetEntProp(g_PVMid[client], Prop_Send, "m_nSequence", 0);
			}
        }
    }

    // Verifica o ataque secundário (IN_ATTACK2)
    if (buttons & IN_ATTACK2 && IsZombie(client) && IsClientInGame(client) && IsPlayerAlive(client))
    {
        // Se o tempo desde o último ataque secundário for menor que o cooldown, cancela o ataque
        if (currentTime - g_flLastAttack2[client] < COOLDOWN_TIME)
        {
			buttons &= ~IN_ATTACK2; // Desativa o ataque secundário
			g_flLastAttack[client] = currentTime;
        }
        else
        {
			// Se já passou o tempo de cooldown, atualiza o tempo do último ataque secundário
			g_flLastAttack2[client] = currentTime;
			if (g_SoundAttack[client])
			{
				SetEntProp(g_PVMid[client], Prop_Send, "m_nSequence", 4);
			}
			else
			{
				SetEntProp(g_PVMid[client], Prop_Send, "m_nSequence", 0);
			}
        }
    }

    return Plugin_Continue;
}