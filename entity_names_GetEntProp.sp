#include <sourcemod>
#include <colors>
public Plugin:myinfo = 
{
	name = "get value entity",
	author = "paralhama",
	description = "",
	version = "1.1",
	url = ""
}

public OnPluginStart(){
	RegAdminCmd("sm_ent", Cmd_Ent, ADMFLAG_CHAT, "Show entity value");
}

public Action:Cmd_Ent(client, args){
	if(args<1){
		ReplyToCommand(client, "[SM] Usage: sm_ent <entity>");
		return Plugin_Handled;
	}
	decl String:entityStr[512];
	GetCmdArgString(entityStr, sizeof(entityStr));

	new entity = GetEntProp(client, Prop_Send, entityStr);
	
	new String:entstr[64];
	Format(entstr, sizeof(entstr), "%d", entity);
	
	CPrintToChatAll(entstr);
	return Plugin_Handled;
}
