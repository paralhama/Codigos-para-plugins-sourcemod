#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#undef REQUIRE_EXTENSIONS
#tryinclude <steamworks>

public Plugin:myinfo = 
{
	name = "use weapon",
	author = "paralhama",
	description = "use weapon fix gungame",
	version = "1.1",
	url = ""
}

public OnPluginStart()
{
	RegConsoleCmd("sm_use", Cmd_Use, "use weapon");
}

public Action:Cmd_Use(client, args){
	if(args<1){
		ReplyToCommand(client, "[SM] Usage: sm_use <weapon name>");
		return Plugin_Handled;
	}


	new i;
	for (i = 1; i <= MaxClients; i++)
	{
		if ( i == client && IsClientInGame(i) && IsPlayerAlive(i) )
		{
			decl String:WeaponStr[512];
			decl String:WeaponStr2[512];
			GetCmdArgString(WeaponStr, sizeof(WeaponStr));
			strcopy(WeaponStr2, sizeof(WeaponStr2), WeaponStr);
			StrCat(WeaponStr2, sizeof(WeaponStr2), "2");

			FakeClientCommandEx(client, "use weapon_fists");
			FakeClientCommandEx(client, "use %s", WeaponStr);
			FakeClientCommandEx(client, "use %s", WeaponStr2);

			PrintToChatAll(WeaponStr);
			PrintToChatAll(WeaponStr2);
			PrintToChatAll("%d", client);
		}
	}

	return Plugin_Handled;
}