#include <sourcemod>
#include <sdktools>
#include <topmenus>

#define CHOICE1 "#choice1"
#define CHOICE2 "#choice2"
#define CHOICE3 "#choice3"
#define CHOICE4 "#choice4"

/**
 * Function to clear/kill the timer and set to INVALID_HANDLE if it's still active
 * 
 * @param    timer        Handle of the timer
 * @noreturn
 */
stock ClearTimer(&Handle:timer)
{
    if (timer != INVALID_HANDLE)
    {
        KillTimer(timer);
        timer = INVALID_HANDLE;
    }     
} 
 
public void OnPluginStart()
{
  LoadTranslations("config_fofskins.phrases");
  RegConsoleCmd("sm_config", Command_Menu);
  HookEvent("player_spawn", Event_PlayerSpawn);
}

void Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId( event.GetInt("userid"));
	SetHudTextParams(0.13, 0.96, 1800.0, 254, 221, 0, 0, 0, 0.0, 0.0, 0.0);
	ShowHudText(client, -1, "FAR WEST BRASIL");
}

public OnClientPutInServer(client)
{
	if(IsClientInGame(client) && IsClientConnected(client))
	{
		menu1().Display(client, MENU_TIME_FOREVER);
		ClientCommand(client, "con_enable 1");
		ClientCommand(client, "cl_downloadfilter all");
		ClientCommand(client, "fof_hide_vote_menu 0");
		PrintToChat(client, "%t", "WARNING");
		PrintToChat(client, "%t", "WARNING2");
		SetHudTextParams(0.13, 0.96, 1800.0, 254, 221, 0, 0, 0, 0.0, 0.0, 0.0);
		ShowHudText(client, -1, "FAR WEST BRASIL");
	}
}
 
public int MenuHandler1(Menu menu, MenuAction action, int client, int item)
{
  switch(action)
  {
    case MenuAction_Display:
    {
      char buffer[255];
      Format(buffer, sizeof(buffer), "%T", "Title1", client);
 
      Panel panel = view_as<Panel>(item);
      panel.SetTitle(buffer);
    }
	
	case MenuAction_Select:
    {
      char info[32];
      menu.GetItem(item, info, sizeof(info));
      if (StrEqual(info, CHOICE1))
      {
        menu2().Display(client, MENU_TIME_FOREVER);
      }
      if (StrEqual(info, CHOICE2))
      {
        ClientCommand(client, "sm_skins");
      }
    }
 
    case MenuAction_End:
    {
      delete menu;
    }
 
    case MenuAction_DisplayItem:
    {
      char info[32];
      menu.GetItem(item, info, sizeof(info));
 
      char display[64];
 
      if (StrEqual(info, CHOICE1))
      {
        Format(display, sizeof(display), "%T", "Choice 1", client);
        return RedrawMenuItem(display);
      }
	  
      if (StrEqual(info, CHOICE2))
      {
        Format(display, sizeof(display), "%T", "Choice 2", client);
        return RedrawMenuItem(display);
      }
    }
  }
 
  return 0;
}

public Menu menu1()
{
  Menu menu = new Menu(MenuHandler1, MENU_ACTIONS_ALL);
  menu.SetTitle("%T", "Title1", LANG_SERVER);
  menu.AddItem(CHOICE1, "Choice 1");
  menu.AddItem(CHOICE2, "Choice 2");
  menu.ExitButton = true;
 
  return menu;
}

public int MenuHandler2(Menu menu, MenuAction action, int client, int item)
{
  switch(action)
  {
    case MenuAction_Display:
    {
      char buffer[255];
      Format(buffer, sizeof(buffer), "%T", "Title2", client);
 
      Panel panel = view_as<Panel>(item);
      panel.SetTitle(buffer);
    }
	
	case MenuAction_Select:
    {
      char info[32];
      menu.GetItem(item, info, sizeof(info));
      if (StrEqual(info, CHOICE4))
      {
        menu1().Display(client, MENU_TIME_FOREVER);
      }
      if (StrEqual(info, CHOICE3))
      {
        PrintToConsole(client, "%t", "PRINTCONSOLE1");
        menu2().Display(client, MENU_TIME_FOREVER);
        PrintToConsole(client, "%t", "PRINTCONSOLE2");
        ClientCommand(client, "showconsole");
      }
      
    }
	
	case MenuAction_Cancel:
    {
      menu1().Display(item, MENU_TIME_FOREVER);
    }
 
    case MenuAction_End:
    {
      delete menu;
    }
	
	case MenuAction_DisplayItem:
    {
      char info[32];
      menu.GetItem(item, info, sizeof(info));
 
      char display[64];
 
      if (StrEqual(info, CHOICE3))
      {
        Format(display, sizeof(display), "%T", "Choice 3", client);
        return RedrawMenuItem(display);
      }
      if (StrEqual(info, CHOICE4))
      {
        Format(display, sizeof(display), "%T", "Choice 4", client);
        return RedrawMenuItem(display);
      }
	}
  }
 
  return 0;
}

public Menu menu2()
{
	Menu menu = new Menu(MenuHandler2, MENU_ACTIONS_ALL);
	menu.SetTitle("%T", "Title2", LANG_SERVER);
	menu.AddItem(CHOICE3, "Choice 3");
	menu.AddItem(CHOICE4, "Choice 4");
	menu.ExitBackButton = false;
	menu.ExitButton = true;

	return menu;
}

public Action Command_Menu(int client, int args)
{
  menu1().Display(client, MENU_TIME_FOREVER);
  return Plugin_Handled;
}