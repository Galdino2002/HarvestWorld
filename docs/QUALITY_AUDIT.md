# Project quality pass — November 2026

This document separates implemented prototype behavior from work that is still required. A successful Rojo sync is not the same as a tested or production-ready game.

## Design direction

Harvest World is a cozy, social farming and life-simulation game. Players own separate farms, choose who can visit, and join teams for shared competitions. The world should reward cooperation and friendly rivalry without making another player's farm feel disposable.

## Changes in this quality pass

- Added a small farmhouse, porch, chimney, mailbox, yard lights, water trough, hay bales, and orchard trees to every individual plot.
- Reworked the plot fence to create a visible front gate instead of a fully closed perimeter.
- Moved the visit interaction to the entrance gate so the intended visit flow is discoverable.
- Reduced owner sign size and viewing distance to reduce overlapping floating labels.
- Connected crop planting to the actual visible GardenBed_1..9 parts. Previously the server generated hidden planting slots at a different position from the visible beds.
- Added server-side distance checks for planting and harvesting.
- Added a short server-side request throttle and cleanup of temporary crop inventory when a player leaves.
- Added a responsive scale to the HUD, a blueberry planting action, and live Wood/Stone counters.
- Made player setup idempotent to avoid creating duplicate leaderstats if a player is initialized twice.

## Current playable prototype

- Rojo project maps Shared, Server, and Client folders into Roblox services.
- Individual farm plots are generated and assigned on join.
- Farm access modes are Private, Friends, and Public.
- Players can gather wood from trees and stone from deposits.
- Players can plant Carrot, Tomato, and Blueberry in nine visible beds and harvest mature crops.
- Build prompts can create a starter coop, barn, and pasture at fixed pads.
- Coop and barn prototypes spawn simple wandering animal models.

## Known limitations — do not treat these as complete systems

1. **Persistence:** coins, wood, stone, seeds, planted crops, buildings, and ownership are not saved between sessions. Player stats currently reset on join.
2. **Construction:** buildings use fixed pads and prompts. There is no placement preview, rotation, grid snapping, collision validation, relocation, upgrade, or demolition flow.
3. **Animals:** the current animals are visual prototypes. There is no feeding, water, happiness, growth, breeding, product collection, or animal inventory.
4. **Farming economy:** seed counts are temporary in-memory values; there is no seed shop, selling interface, crop quality, storage, or economy balancing.
5. **Teams and competition:** the approved direction is team-based competition, but teams, invitations, seasonal events, score calculation, and leaderboards are not implemented yet.
6. **Visits:** the access mode and gate prompt exist, but the complete visitor experience, clear feedback for denied access, and mobile/console interaction QA remain.
7. **World art:** the world is still a procedural blockout made mostly from Parts and Terrain. It needs authored terrain contours, coherent biomes, better roads/landmarks, ambient audio, VFX, and final art assets.
8. **Performance:** the world generator needs profiling on low-end Android devices. Use StreamingEnabled and measure instance count, memory, and frame rate before adding more decoration.
9. **Testing:** no automated Luau test suite or Studio multiplayer/device test has been completed for this pass.

## Next milestones, in order

### P0 — Make the core loop reliable
- Add persistent player profiles with schema versioning, safe retries, session protection, autosave, and BindToClose.
- Persist farm ownership-independent state: resources, seeds, buildings, crops and crop maturity timestamps.
- Add clear feedback for insufficient resources, occupied beds, immature crops, denied visits, and successful actions.
- Test two players in Studio: private/friends/public visits, plot isolation, planting distance, harvest distance, leaving and rejoining.

### P1 — Build the farm together
- Add collaborator permissions separate from visitor access (owner, trusted builder, visitor).
- Add a construction catalogue with placement ghost, rotation, grid snapping, server-side bounds/collision checks, and cancel/confirm controls.
- Add fences, gates, paths, decorations, animal pens and modular building upgrades.
- Add a shared-farm session/party flow so two friends can work on one farm without sharing account ownership.

### P2 — Give animals meaningful gameplay
- Add animal data, feed/water needs, care actions, product timers, collection and storage.
- Add chickens/eggs and cows/milk first; keep animal simulation server-authoritative and lightweight.
- Add readable animal status UI and sound/animation feedback.

### P3 — Make the world worth exploring
- Sculpt distinct regions and readable routes from the village to farms, forest, lake and highlands.
- Add landmarks, NPC shopkeepers, resource gathering tools, ambient sound, weather and a day/night cycle.
- Replace repeated primitive visuals with cohesive low-poly assets and use LOD/streaming-friendly decoration.

### P4 — Social competition
- Implement teams, invitations, roles and a seasonal team competition.
- Score server-validated farm achievements and cooperative objectives; avoid pay-to-win rewards.
- Add leaderboards, season recap, cosmetics and team identity.

## Acceptance checklist for each milestone

- [ ] Rojo sync completes without errors.
- [ ] Server and client Output have no new errors or warnings.
- [ ] Two-player Studio test passes.
- [ ] Touch controls are usable on a phone-sized viewport.
- [ ] Server validates ownership, distance, state, costs and cooldowns.
- [ ] No progression is lost after a leave/rejoin test (once persistence ships).
- [ ] Performance is measured before expanding instance counts.
