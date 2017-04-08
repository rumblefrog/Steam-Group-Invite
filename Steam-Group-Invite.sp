/*
MIT License

Copyright (c) 2017 RumbleFrog

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/

#pragma semicolon 1

#define PLUGIN_AUTHOR "Fishy"
#define PLUGIN_VERSION "1.0.1"

#include <sourcemod>
#include <SteamWorks>
#include <steamcore>
#include <morecolors>
#include <bigint>

#pragma newdecls required

ConVar cGroupID;
Handle InCoolDown;
char GroupID[64];
char GroupID32[64];
bool InGroup[MAXPLAYERS + 1];

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
	
	cGroupID = CreateConVar("sgi_groupid", "0", "Group ID | Ex: 103582791457828777", 0, true, 0.0);
	
	cGroupID.GetString(GroupID, sizeof GroupID);
		
	RegConsoleCmd("sm_invite", InviteCmd, "Invites the client to desired Steam group");
	RegConsoleCmd("sm_ingroup", InGroupCmd, "Checks if the client is in desired Steam group");
	
	InCoolDown = CreateArray();
	
	int IntArray[1024], IntArraySub[1024], Int32[1024];
	
	hexString2BigInt(GroupID, IntArray, sizeof IntArray);
	hexString2BigInt("103582791429521408", IntArraySub, sizeof IntArraySub);
	
	subBigInt(IntArray, IntArraySub, 16, Int32, sizeof Int32);
	
	bigInt2HexString(Int32, GroupID32, sizeof GroupID32);
}

public Action InviteCmd(int client, int args)
{
	int AccountID = GetSteamAccountID(client);
	
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

public Action InGroupCmd(int client, int args)
{
	if (InGroup[client])
		CPrintToChat(client, "{lightseagreen}[SGI] {grey}You are currently in the Steam group.");
	else
		CPrintToChat(client, "{lightseagreen}[SGI] {grey}You are currently not in the Steam group. %s", GroupID32);
		
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

public void OnClientPostAdminCheck(int iClient)
{
	if (!StrEqual(GroupID32, "0") && !StrEqual(GroupID32, "0.0"))
	{
		if (!SteamWorks_GetUserGroupStatus(iClient, StringToInt(GroupID32)))
		{
			CPrintToChat(iClient, "{lightseagreen}[SGI] {grey}Request overflow. Please try again later.");
			return;
		}
		
		CPrintToChat(iClient, "{lightseagreen}[SGI] {grey}Requesting...");
	}
}

public int SteamWorks_OnClientGroupStatus(int authid, int groupid, bool isMember, bool isOfficer)
{
	CPrintToChatAll("{lightseagreen}[SGI] {grey}Received Request. %i", groupid);
	
	if (groupid != StringToInt(GroupID32))
		return;
	
	int iClient = GetUserFromAuthID(authid);	
	
	if (iClient == -1)
		return;
		
	if (!isMember && !isOfficer)
	{
		CPrintToChat(iClient, "{lightseagreen}[SGI] {grey}Consider joining our group using !invite.");
		return;
	}
	
	if (isMember || isOfficer)
	{
		CPrintToChat(iClient, "{lightseagreen}[SGI] {grey}You are in our group, hurray!");
		InGroup[iClient] = true;
		return;
	}
	
}

public int GetUserFromAuthID(int authid)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if(IsClientInGame(i)) {
            char charauth[64];
            GetClientAuthId(i, AuthId_Steam3, charauth, sizeof(charauth));
               
            char charauth2[64];
            IntToString(authid, charauth2, sizeof(charauth2));
           
            if(StrContains(charauth, charauth2, false) > -1)
            {
                return i;
            }
        }
    }
    return -1;
}