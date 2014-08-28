#pragma semicolon 1
#include <sourcemod>


enum AddonResult {
	AR_NoResult=-1,
	AR_Disabled,
	AR_Enabled,
	AR_Error
};

public OnPluginStart()
{
	RegConsoleCmd("sm_addoncheck", CheckAddonsCmd, "Check which players have addons enabled/disabled");
}

new bool:g_bCheckInProgress;
new AddonResult:g_iClientAddons[MAXPLAYERS +1];
new replyClient;
new clientCnt;
new numChecked;

public Action:CheckAddonsCmd(client, args)
{
	if(g_bCheckInProgress)
	{
		ReplyToCommand(client, "Check currently in progress... Please wait");
		return Plugin_Handled;
	}
	
	g_bCheckInProgress = true;
	replyClient = client;
	CheckClientAddons();
	return Plugin_Handled;
}

CheckClientAddons()
{
	numChecked = 0;
	for(new i = 1; i < MaxClients+1; i++)
	{
		g_iClientAddons[i] = AR_NoResult;
		if(IsClientInGame(i) && !IsFakeClient(i))
		{
			clientCnt++;
			QueryClientConVar(i, "addons_eclipse_content", QueryCb);
		}
	}
	CreateTimer(5.0, ClientCheckTimeout);
}

public Action:ClientCheckTimeout(Handle:timer)
{
	EndAddonsCheck();
	return Plugin_Handled;
}

EndAddonsCheck()
{
	for(new i = 1; i < MaxClients+1; i++)
	{
		if(IsClientInGame(i) && !IsFakeClient(i))
		{
			switch(g_iClientAddons[i])
			{
				case AR_NoResult:
				{
					PrintToConsole(replyClient, "%L : No Reply!");
				}
				case AR_Disabled:
				{
					PrintToConsole(replyClient, "%L : Disabled");
				}
				case AR_Enabled:
				{
					PrintToConsole(replyClient, "%L : Enabled");
				}
				case AR_Error:
				{
					PrintToConsole(replyClient, "%L : ERROR!");
				}
				default:
				{
					PrintToConsole(replyClient, "%L : Plugin failure :V");
				}
			}
		}
	}
	g_bCheckInProgress = false;
}

public QueryCb(QueryCookie:cookie, client, ConVarQueryResult:result, const String:cvarName[], const String:cvarValue[])
{
	if(result != ConVarQuery_Okay)
	{
		g_iClientAddons[client] = AR_Error;
	}
	else if(cvarValue[0] == '0' && cvarValue[1] == '\0')
	{
		g_iClientAddons[client] = AR_Enabled;
	}
	else if(cvarValue[0] == '1' && cvarValue[1] == '\0')
	{
		g_iClientAddons[client] = AR_Disabled;
	}
	else
	{
		g_iClientAddons[client] = AR_Error;
	}
	numChecked++;
	if(numChecked == clientCnt) EndAddonsCheck();
}