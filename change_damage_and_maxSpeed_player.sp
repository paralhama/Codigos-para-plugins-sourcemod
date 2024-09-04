#include <sourcemod>
#include <sdkhooks>

public OnClientPutInServer(client) {
    SDKHook(client, SDKHook_TraceAttack, Infected_Damage_Filter);
}

public void OnPluginStart()
{
    HookEvent("player_hurt", OnPlayerHurt, EventHookMode_Post);
}

public Action Infected_Damage_Filter(int victim, int &attacker, int &inflictor, float &damage, int &damagetype, int &ammotype, int hitbox, int hitgroup)
{
    // Reduzir o dano se não for um tiro na cabeça
    if (hitgroup != 1)
    {
        damage *= 0.45;
    }
    return Plugin_Changed;
}

// Função chamada quando o evento player_hurt é acionado
public Action OnPlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
	char weapon[64];
	GetEventString(event, "weapon", weapon, sizeof(weapon));
	int victim = GetClientOfUserId(GetEventInt(event, "userid"));

	// Verificar se a arma não contém as strings específicas
	if (StrContains(weapon, "fists", false) == -1 &&
	StrContains(weapon, "worldspawn", false) == -1 &&
	StrContains(weapon, "kick", false) == -1 &&
	StrContains(weapon, "physics", false) == -1 &&
	StrContains(weapon, "blast", false) == -1 &&
	StrContains(weapon, "dynamite", false) == -1 &&
	StrContains(weapon, "x_arrow", false) == -1 &&
	StrContains(weapon, "thrown", false) == -1 &&
	StrContains(weapon, "knife", false) == -1 &&
	StrContains(weapon, "axe", false) == -1 &&
	StrContains(weapon, "machete", false) == -1)
	{
		// Se nenhuma dessas palavras estiver presente, altere a velocidade máxima do jogador para 100.0
		SetEntPropFloat(victim, Prop_Data, "m_flMaxspeed", 100.0);

		// Iniciar um temporizador para restaurar a velocidade após 0.5 segundos
		CreateTimer(0.5, ResetPlayerSpeed, victim);		
	}

	return Plugin_Continue;
}

// Função para restaurar a velocidade do jogador para 300.0
public Action:ResetPlayerSpeed(Handle:timer, any:client)
{
	if (IsClientInGame(client))
	{
		SetEntPropFloat(client, Prop_Data, "m_flMaxspeed", 300.0);
	}
	return Plugin_Stop;
}