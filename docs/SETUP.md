# Development Setup

## Install
1. Install Roblox Studio from the official Roblox Creator Hub.
2. Install Visual Studio Code.
3. Install Git.
4. Install Rojo 7.x using the official Rojo installation instructions.
5. Install the Rojo plugin in Roblox Studio.

## Clone
```bash
git clone https://github.com/Galdino2002/HarvestWorld.git
cd HarvestWorld
```

## Start synchronization
From the repository root:
```bash
rojo serve default.project.json
``
In Roblox Studio, open a place and connect the Rojo plugin to the local server. Sync the project tree.

## Test
Use Studio's Test/Play mode. Check Output for server bootstrap messages. Test with multiple clients before validating multiplayer behavior.

## Important
- Do not commit API keys, private tokens, or credentials.
- Enable Studio API access only in a separate test experience when testing DataStores.
- Publish to a private test experience before any public release.
- Never test exploit-sensitive economy or theft logic in a live production server.
