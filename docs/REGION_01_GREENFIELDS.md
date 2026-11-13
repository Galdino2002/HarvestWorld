# Region 01 — Greenfields

Greenfields is the first region to receive a dedicated exploration loop.

## Player fantasy
A welcoming farming valley where a new player can orient themselves, learn the shape of the world, follow paths, find landmarks, and earn a small reward for curiosity.

## Current exploration loop
1. Spawn near the farm district and follow the main lane toward the valley.
2. Find wooden discovery signs at four landmarks.
3. Use the Explore prompt to register each landmark once per server session.
4. Earn a small coin reward and increase the Discoveries leaderboard stat.
5. Continue along the secondary trails toward the mill, ancient tree, cabin, and ruins.

## Implemented landmarks
- Elder Tree — 25 coins
- Old Watermill — 35 coins
- Whisper Cabin — 40 coins
- Old Ruins — 50 coins

Discovery state currently uses player attributes and is session-scoped. It is intentionally not represented as permanent progression until the player DataStore layer is implemented.

## Region boundaries
This pass only adds the first exploration layer to Greenfields. Central Village, Whispering Woods, Highland Ridge, and Seasonal Grounds remain separate region passes.

## Studio acceptance checklist
- Confirm all four signs are on walkable ground and visible from their trail approaches.
- Trigger each Explore prompt and verify Coins and Discoveries increase once.
- Trigger the same prompt again and verify no duplicate reward.
- Test prompt visibility and hold interaction on keyboard, touch, and gamepad.
- Check that sign boards face the approaching path; rotate SurfaceGui face if needed.
- Confirm no sign blocks roads, farm entrances, or player movement.
- Profile on a low-end mobile device.

## Next region pass
After Greenfields has been visually validated in Studio, continue with Central Village: a readable town center, connected alleys, social gathering spots, and useful landmarks.
