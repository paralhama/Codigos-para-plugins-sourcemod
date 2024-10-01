// Nome do Plugin: GetModelProperties
// Descrição: Mostra as propriedades de renderização do modelo mirado no console.
// Atualmente não faz nada mas coisas legais podem ser feitas :D

#include <sourcemod>
#include <sdktools>

#define EF_BONEMERGE	(1 << 0)
#define EF_NOSHADOW		16
#define EF_NOINTERP		8

public Plugin:myinfo = 
{
    name = "GetModelProperties",
    author = "Lucas",
    description = "Get render properties of aimed model in console",
    version = "1.3"
};

// Registro do comando "get"
public OnPluginStart()
{
    RegConsoleCmd("sm_get", Command_GetProperties);
}

// Função para verificar quando um jogador executa o comando "get"
public Action:Command_GetProperties(client, args)
{
    if (!IsClientInGame(client) || !IsPlayerAlive(client))
    {
        return Plugin_Handled;
    }

    new target = GetClientAimTarget(client, false);
    if (target == -1 || !IsValidEntity(target))
    {
        PrintToConsole(client, "Você não está mirando em um modelo válido.");
        return Plugin_Handled;
    }

    new String:classname[256];
    GetEdictClassname(target, classname, sizeof(classname));
    PrintToConsole(client, "                                   ");
    PrintToConsole(client, "WEAPON:");
    PrintToConsole(client, "Nome da Entidade: %s", classname);
    PrintToConsole(client, "Entidade ID: %d", target);
    PrintToConsole(client, "m_iHealth: %d", GetEntProp(target, Prop_Data, "m_iHealth"));
    PrintToConsole(client, "m_iMaxHealth: %d", GetEntProp(target, Prop_Data, "m_iMaxHealth"));
    PrintToConsole(client, "m_lifeState: %d", GetEntProp(target, Prop_Data, "m_lifeState"));
    PrintToConsole(client, "m_hEffectEntity: %d", GetEntProp(target, Prop_Send, "m_hEffectEntity"));
    PrintToConsole(client, "m_fEffects: %d", GetEntProp(target, Prop_Send, "m_fEffects"));
    PrintToConsole(client, "m_hEffectEntity: %d", GetEntProp(target, Prop_Send, "m_hEffectEntity"));
    PrintToConsole(client, "m_nRenderFX: %d", GetEntProp(target, Prop_Data, "m_nRenderFX"));

    //SetEntProp(target, Prop_Send, "m_fEffects", RENDER_GLOW);
    //SetEntProp(target, Prop_Data, "m_fEffects", RENDER_GLOW);
	SetEntityRenderMode(target , RENDER_GLOW); 

    PrintToConsole(client, "                                   ");
    return Plugin_Handled;
}
