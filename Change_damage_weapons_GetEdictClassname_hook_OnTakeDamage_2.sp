//Pragma
#pragma semicolon 1
#pragma newdecls required

//Sourcemod Includes
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>

public void OnPluginStart()
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
        {
            OnClientPutInServer(i);
        }
    }
}

public void OnClientPutInServer(int client)
{
    SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
    if (attacker == 0 || attacker > MaxClients)
    {
        return Plugin_Continue;
    }

    int active = GetEntPropEnt(attacker, Prop_Send, "m_hActiveWeapon");

    if (!IsValidEntity(active))
    {
        return Plugin_Continue;
    }

    char sClassname1[32];
    GetEntityClassname(active, sClassname1, sizeof(sClassname1));

    if (StrContains(sClassname1, "weapon_sawedoff_shotgun") != -1)
    {
        damage *= 1.5;
        return Plugin_Changed;
    }

    return Plugin_Continue;
}