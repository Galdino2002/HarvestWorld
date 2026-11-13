# Harvest World

A competitive multiplayer farming simulator for Roblox, built with Luau and Rojo.

## Vision
Harvest World is a colorful cartoon-style open world where players own farms, grow crops, discover rare mutations, trade, compete in weekly global garden championships, and take calculated risks through an opt-in theft-and-defense loop.

## Current status
**Foundation / prototype.** This repository contains the initial game design, Rojo project structure, and a first server-authoritative farming foundation. It is not yet a complete or published game.

## Requirements
- Roblox Studio
- Visual Studio Code (recommended)
- Rojo 7.x
- Git

## Getting started
1. Install Rojo and the Roblox Studio Rojo plugin.
2. Clone this repository.
3. Run `rojo serve default.project.json` in the repository root.
4. Connect the Rojo plugin in Roblox Studio.
5. Use Play to test the server bootstrap and starter farm prototype.

See [docs/SETUP.md](docs/SETUP.md) for details.

## Project structure
- `src/server`: authoritative game services and bootstrap.
- `src/shared`: shared configuration and constants.
- `src/client`: client controllers and UI.
- `docs`: game design and technical documentation.

## Design principles
- The server validates all economy, inventory, planting, harvesting, ownership, and competition actions.
- Cross-platform controls: keyboard/mouse, touch, and gamepad.
- Fair free-to-play progression; paid items must not create unavoidable competitive advantages.
- Protect player data with versioned schemas and resilient save handling.

## License
All rights reserved unless a license is added by the repository owner.
