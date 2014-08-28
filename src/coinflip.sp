#include <sourcemod>
#include <sdktools>

public Plugin:myinfo =
{
        name = "Coinflip",
        author = "Fig + Jacob",
        description = "Flips a coin",
        version = "0.0.0.1",
        url = "http://www.l4dnation.com"
}

public OnPluginStart()
{
    RegConsoleCmd("sm_coinflip", Command_Coinflip);
}

public Action:Command_Coinflip(client, args){
new random = GetRandomInt(1, 2);
        
        if (random == 1)
	{
                PrintToChatAll("A coin has been flipped! Heads!")
        }
        if (random == 2)
        {
                PrintToChatAll("A coin has been flipped! Tails!")
        }
}