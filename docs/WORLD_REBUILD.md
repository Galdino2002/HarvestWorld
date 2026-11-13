# Harvest World — world building pass

This pass restructures the generated world around five readable destinations while keeping `WorldService` as the existing map entry point and `FarmService` as the owner of player plots. It remains procedural Roblox geometry: a stronger environment foundation, not a claim of final bespoke asset art.

## Geography and layout

- The continuous landmass remains 3,600 × 3,600 studs, with the playable valley framed by rolling foothills and a taller rocky ridge.
- `src/shared/Config/WorldRegions.lua` is the shared coordinate source for region anchors and the twelve farm plot positions. Keep roads, landmarks, and plot changes aligned to this configuration.
- Greenfields contains twelve spacious farms in three rows. Their south gates meet the farm lanes, which connect toward the village bridge.
- Central Village remains north of the river and reads as the built focal point. The existing village, bridge, river, and lake remain in `WorldService`.
- Whispering Woods retains mixed broadleaf and pine clusters and now has a cabin destination. Highland Ridge has a larger layered terrain silhouette, a winding trail, and a stepped hidden cascade. Seasonal Grounds has a framed open lawn and pavilion footprint, separated from the lake.
- The Elder Tree, old watermill, and stone ruins add distinct silhouettes for navigation.

## Runtime and compatibility

- `WorldService.Init()` owns `HarvestWorldMap`, terrain, environment, and map landmarks. `FarmService.Init()` owns `PlayerFarms`; the map service no longer deletes that folder.
- Farm count, spacing, and centers come from the shared region configuration. Plot names, ownership attributes, garden beds, reserved building pads, access prompts, and spawn positioning are preserved.
- `default.project.json` enables Workspace streaming with a 64-stud minimum and 256-stud target radius. Check the live place settings after Rojo sync because Roblox Studio uses the place configuration at runtime.
- Map props are anchored. Keep collisions on walkable surfaces, trunks, structural supports, and bridges; disable collision on decorative foliage and water where safe. Avoid per-instance lights or continuously simulated decoration across the full map.
- Terrain is created at server startup; water, roads, and buildings remain generated Parts. Profile this prototype scale before release.

## Roblox Studio validation checklist

1. Sync with Rojo and confirm `Workspace.StreamingEnabled`, `StreamingMinRadius`, and `StreamingTargetRadius` in the live place.
2. Start a server and inspect terrain bounds, region folders, river-to-bridge crossing, lake shore, waterfall steps, village foundations, and mountain skyline from ground level and a high camera.
3. Walk every farm row. Confirm all twelve plots sit flush on the valley floor, each gate meets its driveway, crop beds/pads/fences remain clear, and spawn points land inside their own plot.
4. Check landmarks for intersections and silhouette readability: watermill wheel, Elder Tree canopy/ring, cabin approach, ruin lintel, pavilion, and cascade.
5. Move between each region and inspect transitions, hidden approach paths, terrain seams, water edges, and floating or buried objects.
6. Use Start Server with several clients to confirm plot assignment, release/reassignment, visit prompts, and farm rendering remain compatible.
7. Review default zoom, close third person, and maximum practical zoom on PC and console. Repeat on a low-end Android profile with streaming enabled; record memory, visible instance count, frame rate, pop-in, and travel hitches.
8. Inspect mobile readability and check that distant tree clumps stream without abrupt canopy disappearance.

## Current limits

- Terrain height is formed from overlapping Roblox Terrain volumes and needs visual sculpt review in Studio; the generator alone cannot establish camera-quality sign-off.
- The river and waterfall use generated water pieces, not a fully sculpted riverbed or animated waterfall asset. Confirm seams and shore contact in Studio.
- Houses, rocks, and foliage use reusable Parts rather than a finished asset library. Replace or consolidate visible hero assets after composition review.
- Streaming is enabled, but distance readability and mobile performance still require measurement.
- Playtesting, multiplayer checks, and device profiling remain outstanding. This is the test plan, not a claim that those tests have passed.
