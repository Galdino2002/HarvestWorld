# All-region environmental art pass — 2026-11-13

## Goal
Give every major destination a readable identity while keeping the existing world layout, farm plots, road network and server-authoritative gameplay intact.

## Implemented in code
A new `WorldRegionsArtService` is loaded after the Greenfields art pass. It creates one replaceable folder under `Workspace/HarvestWorldMap/WorldRegionsArt` and adds:

- **Central Village:** market-square fountain, seating, flower planters, pennants and a wayfinding sign.
- **Whispering Woods:** timber trail gateway, forest sign, a small resting nook, mossy stones and mushroom details.
- **Highland Ridge:** a low lookout deck at the start of the mountain route, railings, a wayfinding sign and stone cairns.
- **Seasonal Grounds:** a festival entrance arch, lanterns, flower islands and seating while leaving the center lawn open.
- **Bluewater Lake:** a small pier, railings, a lake sign and shoreline reeds.

The existing Greenfields landmarks, farm district, watermill, ancient tree, cabin and ruins remain in place. The pass is intentionally additive and grouped so it can be replaced without deleting gameplay objects.

## Studio validation still required
- [ ] Pull the latest `main` branch and let Rojo sync.
- [ ] Start a fresh server session; the map is generated on server startup.
- [ ] Walk the village square and confirm the fountain does not block the market route.
- [ ] Inspect the forest gate and resting nook for tree/path intersections.
- [ ] Drive and walk the highland trail; verify the lookout deck is reachable and not floating.
- [ ] Inspect the seasonal arch and confirm the center lawn remains open for events.
- [ ] Check the pier against the actual lake shoreline and confirm it meets the water cleanly.
- [ ] Review every region at player height and from an elevated camera.
- [ ] Test on a lower-end Android device and inspect server/client Output for warnings.

## Quality boundary
This is a code-authored environmental art pass, not a claim that the world is finished. The current map still uses many primitive parts and generated terrain. Exact terrain alignment, visual composition, collision feel, mobile performance and final asset quality require Roblox Studio review and iteration from screenshots or a live test.
