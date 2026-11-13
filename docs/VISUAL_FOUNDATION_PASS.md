# Visual and gameplay foundation pass — 2026-11-13

This pass addresses structural issues discovered while reviewing the running prototype. It is not a claim that the game is finished or visually final.

## Changes committed

- Fixed malformed literal newline sequences in the client HUD's blueberry button callback.
- Replaced the giant grass-material terrain surface with a stable Ground terrain material and a muted green terrain material color. This avoids relying on the distance-sensitive grass decoration layer.
- Added rolling foothills around the outer valley to break up the flat horizon.
- Added warm daylight post-processing: subtle bloom, color correction, sun rays, and clouds.
- Reorganized each farm: the farmhouse now faces the entrance path; the crop beds have wooden borders; coop, barn, and pasture pads occupy separate zones; orchard trees and yard lights no longer overlap the pasture.
- Replaced the narrow disconnected farm path with a longer cobblestone walkway from the entrance toward the house.
- Improved coop and barn silhouettes with pitched roofs, framed doors, windows, and a pasture with two levels of rails.
- Added visible crop growth stages: seedlings, growing plants, and mature produce.

## What still needs a real Studio playtest

- Confirm terrain material coloring and cloud rendering in Roblox Studio.
- Inspect the new farm layout from player height and aerial camera; adjust if any parts intersect or float.
- Plant all three crops and verify their visual stages and harvest timing.
- Build the coop, barn, and pasture; verify all pieces fit inside their pads and that animals remain inside the intended area.
- Test with two players and check farm assignment, access modes, and visit prompts.
- Test touch controls and performance on a lower-end Android device.

## Still not implemented

- Persistent profiles and farm state across sessions.
- Free placement/rotation/grid snapping for buildings.
- Animal care, feeding, happiness, egg/milk collection, and breeding.
- Seed shop, crop inventory UI, crop selling interface, and balanced economy.
- Team system and seasonal team competition.
- Final authored art, animation, sound design, NPC dialogue, weather simulation, and polished onboarding.

## Quality gate

Do not label a milestone complete until it passes Studio playtests, including a two-player test and mobile viewport review. The project is still a playable prototype foundation.
