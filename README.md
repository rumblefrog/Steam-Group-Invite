# Steam-Group-Invite [![Build Status](https://travis-ci.org/RumbleFrog/Steam-Group-Invite.svg?branch=master)](https://travis-ci.org/RumbleFrog/Steam-Group-Invite)
A simple plugin that invites the player to the desired group on command trigger

# Convars

- **sc_username** (Steam account username)
- **sc_password** (Steam account password)
- **sgi_groupid** ([Group ID64](#find-your-group-id64)) 

# Prerequisite

- [SteamWorks Extension](https://users.alliedmods.net/~kyles/builds/SteamWorks/)
- [SteamCore Plugin](https://github.com/polvora/SteamCore/releases)

# Find Your Group ID64

1. Goto https://steamcommunity.com/groups/<GroupName>/memberslistxml/ (Replace <GroupName> with your group name)
2. Search for numbers encased in <groupID64> (Ex: <groupID64>103582791457828777</groupID64>)
3. Use that number in [**sgi_groupid**](#convars)

# Note

- There might be a server freeze for about **0.5** second while it's performing RSA calculation which only occurs once per session
- Steam username/password must be <= 32 characters
- Steam only allows 64-bit group ID

# Download 

Download the latest version from the [release](https://github.com/RumbleFrog/Steam-Group-Invite/releases) page

# License

MIT
