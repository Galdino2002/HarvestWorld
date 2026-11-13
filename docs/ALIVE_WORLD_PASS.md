# Living world art pass — 2026-11-13

This pass adds another focused layer of map art without changing the farm ownership, crop, building, or competition systems.

## Implemented

- Added a dedicated `WorldLifeService` that runs after the generated map and farm plots exist.
- Added finished post caps, diagonal corner braces, a timber gate crest, warm entrance lanterns, and a short flower border to each generated farm fence.
- Kept the farm gate opening clear; decorative pieces are non-collidable.
- Added faceted rock shoulders and mossy ledges to create a more layered Highland Ridge silhouette.
- Added irregular groups of trees along the lower mountain slopes, plus ferns, wildflowers, and boulders at the ridge foot.
- Uses downward raycasts to place mountain foliage and boulders against the actual generated ground height instead of assuming every position is at Y=0.
- Keeps decorative foliage non-collidable and limits the new art pass to a few hundred parts across the world.

## Runtime order

`Bootstrap.server.lua` initializes `WorldService`, then `FarmService`, then `WorldLifeService`. This ensures the mountain folder and all twelve farm models exist before decoration is applied.

## Studio validation still required

1. Sync the project with Rojo and restart the server session so the world regenerates.
2. Inspect all four corners and the front gate of a farm from player height.
3. Confirm the entrance remains open and the flower border does not cover the gate.
4. Walk the Highland Ridge slopes and confirm trees, ferns, and boulders sit on the terrain rather than floating or being buried.
5. Inspect the ridge silhouette from the village, river bridge, and farm district.
6. Check server Output for errors and profile memory/frame rate on a low-end Android device.

This is a committed visual improvement pass, not a claim that the environment is finished or that Studio/device testing has passed.
