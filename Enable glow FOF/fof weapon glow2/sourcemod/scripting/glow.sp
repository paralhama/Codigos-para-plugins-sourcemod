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
		
	CreateTimer(0.5, ChangeWeaponColors, _, TIMER_REPEAT);
}

bool isWindows = false;

Address:addy = view_as<Address>(0);

void changevalue(int newvalue)
{
	Address:addy = GameConfGetAddress(LoadGameConfigFile("glow"), "GlowAddress");

	if(addy != view_as<Address>(0))
	{
		new OS = LoadFromAddress(addy, NumberType_Int8);
		switch(OS)
		{
			case 0x55: //Linux
			{
				StoreToAddress(addy + Address:0x39, newvalue, NumberType_Int8);
				isWindows = false;
			} 
			case 0x56: //Windows
			{
				StoreToAddress(addy + Address:0x23, newvalue, NumberType_Int8);
				isWindows = true;
			}
			default:
			{
				SetFailState("glow Signature Incorrect. (0x%.2x)", OS);
			}
		}
	}
	else
	{
		SetFailState("glow Signature Incorrect (2).");
	}
}

public void AddGlowServer(int entity)
{
	SDKCall(AddGlowServerSDKCall, entity);
}

enum WeaponColor
{
	white = 1,
	blue = 2,
	red = 3,
	yellow = 4,
	green = 5
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
	
	//char arg[32];
   // GetCmdArg(1, arg, sizeof(arg));
	
   // if(args == 1)
	//    changevalue(StringToInt(arg));

	//static int increment = 0;
	//increment = increment + 1;
	//if(increment > 255)
	//	increment = 0;

	//changevalue(increment);
	
	// set to 4 color mode.
	changevalue(4);
	
	int ammocount, ammocountoffset = 0;
	
	if(isWindows)
		ammocountoffset = 1200;
	else
		ammocountoffset = 305;

	ammocount = GetEntData(target, ammocountoffset, 4);
	
	// all 5 colors you can set
	SetEntData(target, ammocountoffset, white, 4, true);
	SetEntData(target, ammocountoffset, red, 4, true);
	SetEntData(target, ammocountoffset, green, 4, true);
	SetEntData(target, ammocountoffset, blue, 4, true);
	SetEntData(target, ammocountoffset, yellow, 4, true);
	
	AddGlowServer(target);
	
	//restore ammo
	SetEntData(target, ammocountoffset, ammocount, 4, true);
	
	//PrintToChat(client, "inc: %i", increment);
	
	return Plugin_Handled;
}

void SetWeaponGlowColor(target, int color)
{
	//color code mode
	changevalue(4);
	
	int ammocount, ammocountoffset = 0;
	
	if(isWindows)
		ammocountoffset = 1200;
	else
		ammocountoffset = 305;

	ammocount = GetEntData(target, ammocountoffset, 4);
	
	SetEntData(target, ammocountoffset, color, 4, true);
	
	AddGlowServer(target);
	
	//restore ammo
	SetEntData(target, ammocountoffset, ammocount, 4, true);
}

int CurrentColor[2049] = {0}; 

public Action ChangeWeaponColors(Handle:timer, any:iGrenade)
{
	for(int i = MaxClients+1;i < GetMaxEntities();i++)
	{
		if(IsValidEntity(i) && IsValidEdict(i))
		{
			if(!HasEntProp(i, Prop_Send, "m_hOwnerEntity"))
				continue;
			
			if(GetEntProp(i, Prop_Send, "m_hOwnerEntity") != -1)
				continue;
			
			char sClassname[32];
			GetEdictClassname(i, sClassname, sizeof sClassname);
			
			if(StrContains(sClassname, "weapon_", false) != -1)
			{
				int newrandomcolor = GetRandomInt(1,5);
				while(CurrentColor[i] == newrandomcolor)
					newrandomcolor = GetRandomInt(1,5);
					
				SetWeaponGlowColor(i, newrandomcolor);
			}
		}
	}
	
	return Plugin_Continue;
}