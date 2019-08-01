/**
 * A custom status HUD for plugins to add text content to for consistency.
 */
#pragma semicolon 1
#include <sourcemod>

#include <clientprefs>

#pragma newdecls required

#define PLUGIN_VERSION "1.0.0"
public Plugin myinfo = {
	name = "Custom Status HUD",
	author = "nosoop",
	description = "An API that exposes a multiline text HUD that multiple plugins can write to",
	version = PLUGIN_VERSION,
	url = "https://github.com/nosoop/SM-CustomStatusHUD"
}

Handle g_HUDUpdateForward;
Handle g_SyncDisplay;

Handle g_PrefHudXPos, g_PrefHudYPos, g_PrefHudColor;

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int maxlen) {
	RegPluginLibrary("custom_status_hud");
	return APLRes_Success;
}

public void OnPluginStart() {
	g_SyncDisplay = CreateHudSynchronizer();
	g_HUDUpdateForward = CreateGlobalForward("OnCustomStatusHUDUpdate", ET_Event, Param_Cell,
			Param_Cell);
	
	g_PrefHudXPos = RegClientCookie("statushud_xpos",
			"Preferred X position for the Custom Status HUD", CookieAccess_Public);
	g_PrefHudYPos = RegClientCookie("statushud_ypos",
			"Preferred Y position for the Custom Status HUD", CookieAccess_Public);
	g_PrefHudColor = RegClientCookie("statushud_color",
			"Preferred color for the Custom Status HUD", CookieAccess_Public);
}

public void OnMapStart() {
	CreateTimer(1.0, RequestHUDUpdate, .flags = TIMER_REPEAT | TIMER_FLAG_NO_MAPCHANGE);
}

public Action RequestHUDUpdate(Handle timer) {
	for (int i = 1; i <= MaxClients; i++) {
		if (IsClientInGame(i)) {
			ProcessHUDUpdate(i);
		}
	}
}

void ProcessHUDUpdate(int client) {
	StringMap entries = new StringMap();
	
	Action result;
	Call_StartForward(g_HUDUpdateForward);
	Call_PushCell(client);
	Call_PushCell(entries);
	Call_Finish(result);
	
	if (result == Plugin_Continue || !entries.Size) {
		delete entries;
		return;
	}
	
	char value[256], buffer[256];
	int nBufLen;
	
	StringMapSnapshot keys = entries.Snapshot();
	for (int i; i < keys.Length; i++) {
		char key[32];
		keys.GetKey(i, key, sizeof(key));
		entries.GetString(key, value, sizeof(value));
		
		nBufLen += StrCat(buffer[i], sizeof(buffer) - nBufLen, value);
		nBufLen += StrCat(buffer[i], sizeof(buffer) - nBufLen, "\n");
	}
	delete keys;
	
	float x, y;
	int color;
	GetClientHudTextParams(client, x, y, color);
	
	SetHudTextParams(x, y, 1.0,
			(color >> 24) & 0xFF, (color >> 16) & 0xFF, (color >> 8) & 0xFF, color & 0xFF);
	
	ShowSyncHudText(client, g_SyncDisplay, "%s", buffer);
	
	delete entries;
}

void GetClientHudTextParams(int client, float &x, float &y, int &color) {
	char buffer[64];
	GetClientCookie(client, g_PrefHudXPos, buffer, sizeof(buffer));
	x = buffer[0]? StringToFloat(buffer) : -0.2;
	
	GetClientCookie(client, g_PrefHudYPos, buffer, sizeof(buffer));
	y = buffer[0]? StringToFloat(buffer) : -0.005;
	
	GetClientCookie(client, g_PrefHudColor, buffer, sizeof(buffer));
	
	if (buffer[0]) {
		StringToIntEx(buffer, color, 16);
	} else {
		color = 0xFFFF00FF;
	}
}