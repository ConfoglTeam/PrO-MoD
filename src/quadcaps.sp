#include <sourcemod>
#include <l4d2_dominators>

#define DEBUG           0
#define NUM_SI_CLASSES  6

static gCvarDominatorsValue;
static Address:pDominators =  Address_Null;
static Handle:cvarDominators = INVALID_HANDLE;

public Plugin:myinfo = 
{
        name = "Dominators Control",
        author = "vintik",
        description = "Changes bIsDominator flag for infected classes. Allows to have 4 dominators with non-zero no-dominators limit.",
        version = "1.0",
        url = "https://bitbucket.org/vintik/various-plugins"
}

public OnPluginStart()
{
        
        
        decl String:sGame[256];
        GetGameFolderName(sGame, sizeof(sGame));
        if (!StrEqual(sGame, "left4dead2", false))
        {
                SetFailState("Plugin 'Dominators Control' supports Left 4 dead 2 only!");
        }
        new Handle:gConf = LoadGameConfigFile("l4d2_dominators");
        if ((gConf == INVALID_HANDLE)
                || (pDominators = GameConfGetAddress(gConf, "bIsDominator")) == Address_Null)
        {
                SetFailState("Can't find 'bIsDominator' signature!");
        }
        
        #if DEBUG
                PrintToServer("[DEBUG] bIsDominator's signature found. Address: %08x", pDominators);
        #endif
        
        cvarDominators = CreateConVar("sm_dominators", "0",
        "Which infected class is considered as dominator (bitmask: 1 - smoker, 2 - boomer, 4 - hunter, 8 - spitter, 16 - jockey, 32 - charger)",
        FCVAR_PLUGIN | FCVAR_SPONLY);
        
        new newValue = GetConVarInt(cvarDominators);
        if (IsValidCvarValue(newValue))
        {
                gCvarDominatorsValue = newValue;
                SetDominators();
        }
        else
        {
                ResetConVar(cvarDominators);
        }
        HookConVarChange(cvarDominators, OnCvarDominatorsChange);
}

public OnPluginEnd()
{
        ResetConVar(cvarDominators);
        gCvarDominatorsValue = GetConVarInt(cvarDominators);
        SetDominators();
}


public OnCvarDominatorsChange(Handle:cvar, const String:oldVal[], const String:newVal[])
{
        new newValInt = StringToInt(newVal);
        if (newValInt == gCvarDominatorsValue) return;
        if (IsValidCvarValue(newValInt))
        {
                gCvarDominatorsValue = newValInt;
                SetDominators();
        }
        else
        {
                PrintToServer("Incorrect value of 'sm_dominators'! min: 0, max: %d", (1 << NUM_SI_CLASSES) - 1);
                SetConVarString(cvar, oldVal);
        }
}

stock bool:IsValidCvarValue(value)
{
        return ((value >= 0) && (value < (1 << NUM_SI_CLASSES)));
}

stock SetDominators()
{
        #if DEBUG
                PrintToServer("[DEBUG] sm_dominators changed to %d", gCvarDominatorsValue);
        #endif
        new bool:IsDominator;
        for (new i = 0; i < NUM_SI_CLASSES; i++)
        {
                IsDominator = (((1 << i) & gCvarDominatorsValue) != 0);
                #if DEBUG
                        PrintToServer("[DEBUG] Class %d is %sdominator now", i, IsDominator ? "" : "NOT " );
                #endif
                StoreToAddress(pDominators + i, _:IsDominator, NumberType_Int8);
        }
}