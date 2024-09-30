#include <sourcemod>
#include <sdktools>

public Plugin:myinfo = 
{
    name = "GetModelProperties",
    author = "Lucas",
    description = "Get render properties of aimed model in console",
    version = "1.3"
};

Handle AddGlowServerSDKCall;

// Registro do comando "get"
public OnPluginStart()
{
    RegConsoleCmd("sm_get", Command_GetProperties);

	Handle hConf = LoadGameConfigFile("glow");
	
	if (hConf == null)
		SetFailState("hConf == null");
		
	StartPrepSDKCall(SDKCall_Entity); //SDKCall_Raw
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "Glow");
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Plain);
	AddGlowServerSDKCall = EndPrepSDKCall();
	if(AddGlowServerSDKCall == INVALID_HANDLE)
		SetFailState("Failed to create Call for AddGlowServer");
}

public void AddGlowServer(int entity)
{
	SDKCall(AddGlowServerSDKCall, entity);
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

	PrintToChat(client, "item: %s", classname);
	//SetEntProp(target, Prop_Send, "m_bGlowEnabled", 0);
    //PrintToConsole(client, "m_nRenderFX: %d", GetEntProp(target, Prop_Send, "m_nRenderFX"));
    //PrintToConsole(client, "m_nRenderMode: %d", GetEntProp(target, Prop_Send, "m_nRenderMode"));
    //PrintToConsole(client, "m_fEffects: %d", GetEntProp(target, Prop_Send, "m_fEffects"));
    //PrintToConsole(client, "m_clrRender: %d", GetEntProp(target, Prop_Send, "m_clrRender"));

	//SetEntProp(target, Prop_Send, "m_fEffects", 384)
	AddGlowServer(target);

    return Plugin_Handled;
}