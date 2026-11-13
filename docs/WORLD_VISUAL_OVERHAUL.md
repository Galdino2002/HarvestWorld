# Harvest World — visual overhaul pass

Date: 2026-11-13

This pass improves the world as a connected playable space rather than adding more gameplay systems.

## Changes committed to main

### 1. Region-specific landscape dressing
New `src/server/Services/WorldLandscapeService.lua` is loaded by `Bootstrap.server.lua` after the map and region art are generated.

- Frames the valley with broken tree groups instead of a continuous wall.
- Adds broadleaf groves around the forest and village approaches.
- Adds pine groups and rock clusters around the Highland Ridge.
- Adds irregular tree groups, flowers and shoreline rocks around Bluewater Lake.
- Adds flower clearings and perimeter planting around Seasonal Grounds.
- Keeps the main event lawn, farm pads, landmark structures and major routes intentionally open.

### 2. Farm identity and detail
`FarmService.lua` now gives the twelve farm houses four rotating wall/roof/trim palettes and matching mailbox colors. Houses also gain shutters, flower boxes, window blooms, a porch awning with supports and a chimney cap. Each farm receives a small front garden positioned away from the reserved coop, barn and pasture construction pads.

### 3. Explorer vehicle placement
`VehicleService.lua` moves the explorer car out of the middle of a farm plot and into a roadside parking bay near the farm district approach. The chassis is lowered so the decorative wheels sit closer to the ground. Network ownership is assigned after the vehicle assembly has been built.

### 4. Existing regional art retained
The Greenfields landmarks, village square, forest entrance, ridge lookout, seasonal arch, lake pier and discovery signs remain separate from gameplay folders so their visual layers can be replaced without deleting gameplay state.

## Files changed
- `src/server/Services/WorldLandscapeService.lua` (new)
- `src/server/Services/FarmService.lua`
- `src/server/Services/VehicleService.lua`
- `src/server/Bootstrap.server.lua`

## Studio validation required

This work has been committed to GitHub, but cannot be declared visually finished until the generated world is inspected in Roblox Studio.

- [ ] Pull `main` and let Rojo sync all files.
- [ ] Start a fresh Play session (the map is generated at server startup).
- [ ] Inspect Greenfields from the farm gate and from an elevated camera.
- [ ] Confirm the front gardens do not overlap the three reserved build pads.
- [ ] Confirm the explorer car rests on its parking bay, can be entered and does not block the farm road.
- [ ] Drive the car through the farm lanes, village approach, forest trail and lake approach.
- [ ] Inspect forest and mountain trees for terrain intersections and blocked trails.
- [ ] Confirm the lake pier meets the shoreline and the event lawn remains open.
- [ ] Inspect server and client Output for errors.
- [ ] Profile with StreamingEnabled and a lower-end Android device; the additional decorative parts must be measured, not assumed to be free.

## Known limitations

- The generated terrain still has a large, intentionally open farm district because players need room to build.
- Some scenery uses Parts rather than custom meshes. This is a deliberate prototype-friendly approach, not the final asset-quality target.
- Terrain height is currently authored around a nominal ground level of Y=0. The new decorative placements need checking against the actual terrain surface in Studio.
- There has been no Studio screenshot review, multiplayer test, mobile performance profile or automated Luau test for this pass.
- The car is still a simple prototype vehicle with decorative wheels and direct velocity control, not a suspension-based production vehicle.

## Next quality loop

Use Studio screenshots from each region to fix actual overlaps, floating pieces, empty sightlines and path readability. Then replace the most visible primitive hero assets (farmhouse, mill, village buildings, forest gate, mountain lookout and vehicle) with cohesive low-poly models before adding more map clutter.
