#include <sourcemod>
#include <sdktools>

public Plugin:myinfo = 
{
	name = "GetModelProperties",
	author = "Lucas",
	description = "Get render properties of aimed model in console",
	version = "1.3"
};

Handle AddGlowServerSDKCall, EntityMessageBeginCall;
Address EntityMessageBeginAddy = view_as<Address>(0);

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
		
	//CreateTimer(0.5, ChangeWeaponColors, _, TIMER_REPEAT);
	
	StartPrepSDKCall(SDKCall_Static);
	PrepSDKCall_SetFromConf(hConf, SDKConf_Signature, "EntityMessageBegin");
	PrepSDKCall_AddParameter(SDKType_CBaseEntity, SDKPass_Pointer);//CBaseEntity thisptr
	PrepSDKCall_AddParameter(SDKType_PlainOldData, SDKPass_Plain);//m_bReliableMessage?
	PrepSDKCall_SetReturnInfo(SDKType_PlainOldData, SDKPass_Pointer);//bf_write*
	EntityMessageBeginCall = EndPrepSDKCall();
	//if(EntityMessageBeginCall == INVALID_HANDLE)
	//	SetFailState("Failed to create Call for EntityMessageBegin");
	
	EntityMessageBeginAddy = GameConfGetAddress(LoadGameConfigFile("glow"), "GlowAddress");//"EntityMessageBeginAddress");
	
	HookEntityOutput("prop_physics_respawnable", "OnBreak", OnBreak);
}


bool isWindows = false;

Address:OriginalBytes[128];

void NOP_Real_Call()
{
	if(EntityMessageBeginAddy != view_as<Address>(0))
	{
		new OS = LoadFromAddress(EntityMessageBeginAddy + Address:0x1, NumberType_Int8);
		switch(OS)
		{
			case 0x89: //Linux
			{
				//StoreToAddress(EntityMessageBeginAddy + Address:0x39, newvalue, NumberType_Int8);
				isWindows = false;
			} 
			case 0x8B: //Windows
			{
				for(int i = 0;i<8;i++)
					OriginalBytes[i] = LoadFromAddress(EntityMessageBeginAddy + Address:0x1A + view_as<Address>(i), NumberType_Int8);
					
				for(int i = 0;i<8;i++)
					StoreToAddress(EntityMessageBeginAddy + Address:0x1A + view_as<Address>(i), 0x90, NumberType_Int8);
					
				isWindows = true;
			}
			default:
			{
				SetFailState("EntityMessageBeginAddress Signature Incorrect. (0x%.2x)", OS);
			}
		}
	}
	else
	{
		SetFailState("EntityMessageBeginAddress Signature Incorrect (2).");
	}
}

void RestoreOriginalBytes()
{
	if(EntityMessageBeginAddy != view_as<Address>(0))
	{
		new OS = LoadFromAddress(EntityMessageBeginAddy + Address:0x1, NumberType_Int8);
		switch(OS)
		{
			case 0x89: //Linux
			{
				//StoreToAddress(EntityMessageBeginAddy + Address:0x39, newvalue, NumberType_Int8);
				isWindows = false;
			} 
			case 0x8B: //Windows
			{
				for(int i = 0;i<8;i++)
					StoreToAddress(EntityMessageBeginAddy + Address:0x1A + view_as<Address>(i), OriginalBytes[i], NumberType_Int8);
					
				isWindows = true;
			}
			default:
			{
				SetFailState("EntityMessageBeginAddress Signature Incorrect. (0x%.2x)", OS);
			}
		}
	}
	else
	{
		SetFailState("EntityMessageBeginAddress Signature Incorrect (2).");
	}
}


public void EntityMessageBegin(int entity)
{
	SDKCall(EntityMessageBeginCall, entity, 0);
}


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

#define EF_BONEMERGE				(1 << 0)
#define EF_NOSHADOW					(1 << 4)
#define EF_NORECEIVESHADOW			(1 << 6)

int GlowObjectParent[2049] = {-1, ...};

/*public void OnEntityDestroyed(int entity)
{
	PrintToChatAll("-1: %i", entity);
	
	if(entity < 1 && entity > 2049)
		return;
	
	char EntityName[64];
	GetEntityClassname(entity, EntityName, sizeof(EntityName));
	
	PrintToChatAll("0: %s", EntityName);
	
	if(!StrEqual(EntityName, "prop_physics_respawnable", false))
		return;

	PrintToChatAll("1: %i", entity);
	
	if(!IsValidEntity(GlowObjectParent[entity]))
	{
		PrintToChatAll("2: %i %i", entity, GlowObjectParent[entity]);
		GlowObjectParent[entity] = -1;
		return;
	}
	if(!HasEntProp(GlowObjectParent[entity], Prop_Send, "m_hOwnerEntity"))
	{
		PrintToChatAll("3: %i %i", entity, GlowObjectParent[entity]);
		GlowObjectParent[entity] = -1;
		return;
	}
	
	if(GetEntProp(GlowObjectParent[entity], Prop_Send, "m_hOwnerEntity") != entity)
	{
		PrintToChatAll("4: %i %i", entity, GlowObjectParent[entity]);
		GlowObjectParent[entity] = -1;
		return;
	}
	
	char classname[256];
	GetEdictClassname(GlowObjectParent[entity], classname, sizeof(classname));
	PrintToChatAll("5: %i(%s)", entity, classname);
	if(StrEqual(classname, "weapon_bow", false))
	{
		PrintToChatAll("Entity %i(%s) has child %i(%s) Killing..", entity, EntityName, GlowObjectParent[entity], classname);
		AcceptEntityInput(GlowObjectParent[entity], "Kill");
		GlowObjectParent[entity] = -1;
	}
}*/

public OnBreak(const String:output[], entity, activator, Float:Any)
{
    //PrintToChatAll("-1: %i", entity);
	if(entity < 1 && entity > 2049)
		return;
	
	char EntityName[64];
	GetEntityClassname(entity, EntityName, sizeof(EntityName));
	
	//PrintToChatAll("0: %s", EntityName);
	
	if(!StrEqual(EntityName, "prop_physics_respawnable", false))
		return;

	//PrintToChatAll("1: %i", entity);
	
	if(!IsValidEntity(GlowObjectParent[entity]))
	{
		//PrintToChatAll("2: %i %i", entity, GlowObjectParent[entity]);
		GlowObjectParent[entity] = -1;
		return;
	}
	/*if(!HasEntProp(GlowObjectParent[entity], Prop_Send, "m_hOwnerEntity"))
	{
		PrintToChatAll("3: %i %i", entity, GlowObjectParent[entity]);
		GlowObjectParent[entity] = -1;
		return;
	}
	
	if(GetEntProp(GlowObjectParent[entity], Prop_Send, "m_hOwnerEntity") != entity)
	{
		PrintToChatAll("4: %i %i", entity, GlowObjectParent[entity]);
		GlowObjectParent[entity] = -1;
		return;
	}*/
	
	char classname[256];
	GetEdictClassname(GlowObjectParent[entity], classname, sizeof(classname));
	//PrintToChatAll("5: %i(%s)", entity, classname);
	if(StrEqual(classname, "weapon_bow", false))
	{
		PrintToChatAll("Entity %i(%s) has child %i(%s) Killing..", entity, EntityName, GlowObjectParent[entity], classname);
		AcceptEntityInput(GlowObjectParent[entity], "Kill");
		GlowObjectParent[entity] = -1;
	}
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
	/*changevalue(4);
	
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
	SetEntData(target, ammocountoffset, ammocount, 4, true);*/
	
	//PrintToChat(client, "inc: %i", increment);
	
		
	decl String:m_ModelName[PLATFORM_MAX_PATH];
	GetEntPropString(target, Prop_Data, "m_ModelName", m_ModelName, sizeof(m_ModelName));
		
	int ent = CreateEntityByName("weapon_bow");
	
	GlowObjectParent[target] = ent;
	
	DispatchKeyValue(ent, "model", m_ModelName);
	SetEntPropEnt(ent, Prop_Send, "m_hOwnerEntity", target);
	DispatchKeyValue(ent, "solid", "0");
	DispatchKeyValue(ent, "spawnflags", "256");

	SetEntProp(ent, Prop_Send, "m_CollisionGroup", 0);
	
	DispatchSpawn(ent);	
	
	SetEntityModel(ent, m_ModelName);
	SetEntProp(ent, Prop_Send, "m_nModelIndex", GetEntProp(target, Prop_Send, "m_nModelIndex"));
	SetEntProp(ent, Prop_Send, "m_iWorldModelIndex", GetEntProp(target, Prop_Send, "m_nModelIndex"));
	
	AcceptEntityInput(ent, "TurnOn", ent, ent, 0);
	
	AcceptEntityInput(ent, "DisableMotion");
	
	SetEntityRenderMode(ent, RENDER_TRANSALPHA);
	SetEntityRenderColor(ent, 0, 0, 0, 0);

	SetEntProp(ent, Prop_Send, "m_fEffects", EF_BONEMERGE|EF_NOSHADOW|EF_NORECEIVESHADOW);

	DataPack pack = new DataPack();
	pack.WriteCell(EntRefToEntIndex(target));
	pack.WriteCell(EntIndexToEntRef(ent));
	RequestFrame(Frame_SetParent, pack);
	
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
	
	//NOP_Real_Call();
	//EntityMessageBegin(target);
	AddGlowServer(target);
	//RestoreOriginalBytes();
	
	//PrintToServer("\n\n");
	//for(int i = 0;i<8;i++)
	//	PrintToServer("%X ", OriginalBytes[i]);
	//PrintToServer("\n\n");
	
	//AddGlowServer(target);
	
	//restore ammo
	SetEntData(target, ammocountoffset, ammocount, 4, true);
}

int CurrentColor[2049] = {0}; 

public Action ChangeWeaponColors(Handle:timer, any:iGrenade)
{
	for(int i = MaxClients+1;i < 250;i++)//GetMaxEntities();i++)
	{
		if(IsValidEntity(i) && IsValidEdict(i))
		{
			/*if(!HasEntProp(i, Prop_Send, "m_hOwnerEntity"))
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
			}*/
			AddGlowServer(i);
		}
	}
	
	return Plugin_Continue;
}

public void Frame_SetParent(DataPack pack)
{
	pack.Reset();
	int weapon = EntRefToEntIndex(pack.ReadCell());
	int skin = EntRefToEntIndex(pack.ReadCell());
	delete pack;

	if (IsValidEntity(skin) && IsValidEntity(weapon))
	{
		SetVariantString("!activator");
		AcceptEntityInput(skin, "SetParent", weapon, skin);
		
		//SetEntityModel(skin, "models/weapons/backwards/w_bananna_bunch.mdl");
		//SetEntProp(skin, Prop_Send, "m_nModelIndex", m_nModelIndex);
		//m_iWorldModelIndex
		
		SetWeaponGlowColor(skin, GetRandomInt(1,5));
	}
}
