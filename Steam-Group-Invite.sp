#pragma semicolon 1

#define PLUGIN_AUTHOR "Fishy"
#define PLUGIN_VERSION "1.00"

#include <sourcemod>
#include <steamworks>
#include <steamcore>
#include <morecolors>

#pragma newdecls required

ConVar cGroupID;
Handle InCoolDown;

public Plugin myinfo = 
{
	name = "Steam Group Invite",
	author = PLUGIN_AUTHOR,
	description = "A simple plugin that invites the player to the desired group on command trigger",
	version = PLUGIN_VERSION,
	url = "https://keybase.io/rumblefrog"
};

public void OnPluginStart()
{
	CreateConVar("sgi_version", PLUGIN_VERSION, "Steam Group Invite", FCVAR_SPONLY | FCVAR_REPLICATED | FCVAR_NOTIFY);
	
	cGroupID = CreateConVar("sgi_groupid", "0", "Group ID | Ex: 103582791455186986", 0, true, 0.0);
	
	RegConsoleCmd("sm_invite", InviteCmd, "Invites the client to desired Steam group");
	
	InCoolDown = CreateArray();
	
}

public Action InviteCmd(int client, int args)
{
	char GroupID[64];
	int AccountID = GetSteamAccountID(client);
	cGroupID.GetString(GroupID, sizeof GroupID);
	
	if (StrEqual(GroupID, "0") || StrEqual(GroupID, "0.0"))
	{
		CPrintToChat(client, "{lightseagreen}[SGI] {grey}Group ID Convar not setup.");
		return Plugin_Handled;
	}
	
	if (FindValueInArray(InCoolDown, AccountID) != -1)
	{
		CPrintToChat(client, "{lightseagreen}[SGI] {grey}Please wait 4 minutes between requests.");
		return Plugin_Handled;
	}
	
	char SteamID64[32];
	
	GetClientAuthId(client, AuthId_SteamID64, SteamID64, sizeof SteamID64);
	SteamGroupInvite(client, SteamID64, GroupID, SteamCore_CallBack);
	
	PushArrayCell(InCoolDown, AccountID);
	CreateTimer(240.0, Core_Cooldown, AccountID);

	return Plugin_Handled;
}

public Action Core_Cooldown(Handle timer, any data)
{
	int i;
	
	if ((i = FindValueInArray(InCoolDown, data)) != -1)
		RemoveFromArray(InCoolDown, i);
}

public void SteamCore_CallBack(int iClient, bool bSuccess, int iErrorCode, any data)
{
	if (iClient != 0 && !IsClientInGame(iClient)) return;
	
	
	if (bSuccess) CPrintToChat(iClient, "{lightseagreen}[SGI] {grey}The group invite has been sent.");
	else
	{
		if (iErrorCode < 0x10 || iErrorCode == 0x23)
		{
			int i;
	
			if ((i = FindValueInArray(InCoolDown, data)) != -1)
				RemoveFromArray(InCoolDown, i);
		}
		switch(iErrorCode)
		{
			case 0x01: CPrintToChat(iClient, "{lightseagreen}[SGI] {grey}Request overflow. Please try again later.");
			case 0x02: CPrintToChat(iClient, "{lightseagreen}[SGI] {grey}Your request took too long. Please try again.");
			case 0x27: CPrintToChat(iClient, "{lightseagreen}[SGI] {grey}You're already been invited or is already in the group.");
			default:   CPrintToChat(iClient, "{lightseagreen}[SGI] {grey}A fatal error has occured: {chartreuse}%i{grey}. Please try again later.", iErrorCode);
		}
	}
}
