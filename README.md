# NO LONGER WORK; PATCHED https://steamcommunity.com/discussions/forum/0/1471967529575843900/

# Steam-Group-Invite [![Build Status](https://travis-ci.org/RumbleFrog/Steam-Group-Invite.svg?branch=master)](https://travis-ci.org/RumbleFrog/Steam-Group-Invite)
A simple plugin that invites the player to the desired group on command trigger

# Usage

- sm_invite
- sm_ingroup

# Convars

- **sc_username** (Steam account username)
- **sc_password** (Steam account password)
- **sgi_groupid** ([Group ID64](#find-your-group-id64)) 

# Prerequisite

- [SteamWorks Extension](https://users.alliedmods.net/~kyles/builds/SteamWorks/)
- [SteamCore Plugin](https://github.com/polvora/SteamCore/releases)

# Installing

1. Download and extract SteamWorks to **addons/sourcemod/extensions**
2. Download and extract SteamCore to **addons/sourcemod/plugins**
3. Edit server.cfg and add the listed [convars](#convars)

# Find Your Group ID64

1. Goto https://steamcommunity.com/groups/MaxDBNET/memberslistxml/ (Replace **MaxDBNET** with your group name)
2. Search for numbers encased in `<groupID64>*</groupID64>` (Ex: <groupID64>103582791457828777</groupID64>)
3. Use that number in [**sgi_groupid**](#convars)

# Note

- There might be a server freeze for about **0.5** second while it's performing RSA calculation which only occurs once per session
- Steam username/password must be <= 32 characters
- Steam only allows 64-bit group ID

# Download 

Download the latest version from the [release](https://github.com/RumbleFrog/Steam-Group-Invite/releases) page

# License

MIT
