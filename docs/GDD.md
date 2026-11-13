# Harvest World — Game Design Document

**Version:** 0.3 (initial repository baseline)  
**Status:** Pre-production / playable foundation  
**Genre:** Farming / simulation / social multiplayer  
**Platform:** Roblox (PC, mobile, console)  
**Visual direction:** Bright, friendly cartoon 3D  
**World structure:** Shared open world with individually owned plots distributed across regions

## 1. High concept
Harvest World is a competitive farming world. Players claim a plot, plant and nurture crops, harvest and sell produce, expand their farm, collect rare plant variants, visit other farms, and compete in a weekly worldwide Garden Champions event.

The game takes inspiration from popular farming and collection loops while establishing original art direction, progression, economy, characters, content, and rules. Do not copy another game's assets, code, branding, or distinctive presentation.

## 2. Core player loop
1. Obtain seeds.
2. Prepare a free plot slot and plant.
3. Wait for crop growth while exploring, socializing, or completing tasks.
4. Harvest crops.
5. Sell produce or preserve exceptional specimens for display/competition.
6. Reinvest earnings in seeds, tools, decorations, animals, and plot upgrades.
7. Discover mutations and improve the farm.
8. Enter weekly competitions and climb seasonal leaderboards.

## 3. World
Initial planned regions:
- **Greenfields:** beginner farms and starter crops.
- **Central Village:** seed shop, market, tutorial NPCs, social hub.
- **Whispering Woods:** exploration and uncommon resources.
- **Highland Ridge:** advanced crops and weather challenges.
- **Seasonal Grounds:** rotating event content.

Plots are individually owned and assigned by the server. Each player develops a separate property in a shared open world. Farm owners choose Private, Friends, or Public access; visiting does not grant editing rights. The world will distribute plots across regions rather than present a row of isolated plots.

## 4. Farming
Crop lifecycle: Seed → Growing → Mature → Harvested.
- Crop definitions live in shared configuration.
- Growth timestamps are stored as server time, not client timers.
- The server checks plot ownership, slot availability, seed inventory, and maturity.
- Future systems: watering, soil quality, seasons, weather, crop quality, multi-harvest plants.

## 5. Rarity and mutations
Planned rarity tiers: Common, Uncommon, Rare, Epic, Legendary, Mythic.
Mutations are special crop variants caused by gameplay conditions (weather, soil, events, genetics). Each mutation must have a defined visual identity and balanced sell value.
Do not make competition outcomes depend solely on paid boosts or random spending.

## 6. Garden Champions — weekly global competition
**Approved direction:** automatic weekly competition with a global leaderboard.
- Players submit eligible specimens during the competition window.
- Submissions lock the specimen to prevent transfer/duplication exploits.
- The server validates ownership and eligibility.
- A deterministic scoring formula evaluates rarity (40%), visual traits/beauty (35%), and size/mutations (25%) as an initial design target.
- Beauty must be measured from authored traits (palette, shape, visual effects, decoration context), not client claims or unmoderated votes.
- At the weekly cutoff, the server finalizes results and publishes winners.
- The champion receives a **3x crop production and sale-value boost until the next competition**.
- Proposed secondary rewards: second place 2x, third place 1.5x, top 10 cosmetics/titles. These are tuning proposals, not locked requirements.
- No stacking of seasonal champion multipliers. The new season replaces the previous champion benefit.
- Global ranking requires robust cross-server aggregation, tie-break rules, and abuse monitoring. A prototype leaderboard is not production-ready.

## 7. Theft & protection
Planned feature: opt-in, bounded farm raids focused on eligible harvest-ready crops.
- No theft of Robux, premium currency, plot ownership, or entire inventories.
- New-player protection and per-farm cooldowns.
- Owners can build defenses (fences, alarms, companion animals, later security devices).
- Competition-submitted specimens are locked and cannot be stolen.
- Clear alerts and an understandable risk/reward loop.
- Server validates distance, access, cooldowns, target state, ownership, and inventory capacity.
- Theft rules must be tested for griefing and exploit resistance before release.
- Do not punish players for being offline; offline raids are not part of the initial design.

## 8. Economy and monetization
Currencies and item values are server-authoritative. Initial prototype currency is soft currency only.
Potential monetization: cosmetics, farm themes, emotes, convenience features with careful balance, and optional passes. Avoid pay-to-win competition advantages and deceptive purchase flows. Robux purchases must use Roblox MarketplaceService and follow Roblox policies.

## 9. Social and cooperative play
- Individual properties: every player owns and progresses their own farm.
- Owner-controlled visits: each owner chooses Private, Friends, or Public access. Friends is the safe default. Visiting does not grant editing rights.
- Teams: players can form teams while keeping separate farms, inventories, and progression.
- Team competition: events aggregate server-validated contributions from member farms. Team membership never transfers farm ownership.
- Cooperative tasks, seasonal events, and trading (later). Trading needs confirmation UI, server escrow/state validation, and anti-scam protections.

## 10. Accessibility and controls
- PC: keyboard/mouse.
- Mobile: touch-first UI with large targets.
- Console: gamepad navigation and contextual prompts.
Critical actions must not depend on hover or precise mouse-only input.

## 11. MVP scope
1. Rojo project bootstrapped.
2. Basic world and one assigned farm plot per player.
3. Starter seed inventory.
4. Server-validated planting and crop growth.
5. Harvest and sell loop.
6. Persistent player data with schema versioning.
7. Basic cross-platform UI.
8. Playtests on PC and mobile before adding complex systems.

## 12. Post-MVP roadmap
- More crop families and mutations.
- Inventory and seed shop UI.
- Farm expansion and decorations.
- Animals and production.
- Weekly competition and global ranking.
- Theft and protection.
- Social trading and events.
- Optimization and console QA.

## 13. Success criteria
A new player can understand planting, harvest at least one crop, sell it, and understand how to expand within the first session. Server validation prevents client-side currency/item fabrication. The experience remains usable on low-to-mid-range mobile devices.
