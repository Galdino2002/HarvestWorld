# Technical Architecture

## Approved product decisions
- Every player owns an individual farm.
- Competition is team-based: farms remain independently owned while players join teams for shared events and team leaderboards.
- Farm owners choose visitor access: Private, Friends, or Public. Safe default: Friends.
- Visiting never grants building, inventory, crop, or ownership permissions.

## Runtime boundaries
- Server owns player data, plot ownership, access permissions, inventory, currency, crop state, teams, and competition results.
- Client renders UI/input and sends requests; it is never trusted for rewards or authoritative state.
- Shared contains immutable configuration and network contracts.

## Services
- PlayerDataService: versioned profile load/save and session lifecycle.
- FarmService: individual plot assignment and ownership checks.
- FarmAccessService: owner-controlled access and server-validated visits.
- PlantService: planting, growth, harvest eligibility.
- EconomyService: validated currency and selling.
- TeamService (next): teams, invitations, membership, roles.
- CompetitionService (next): team registration, submissions, scoring, results.

## Farm ownership and permissions
- One player owns one farm in the initial model.
- AccessMode is server-owned; valid values are Private, Friends, Public.
- Default access is Friends.
- Friends access uses Roblox friendship data and fails closed if lookup errors.
- Visitors can enter through a visit prompt only when server validation passes.
- Visiting grants no edit rights. Future collaborator roles must explicitly define build, plant, harvest, animal, and management permissions.
- Only the owner can change access mode.

## Team competition
- Team membership is separate from farm ownership.
- Each player keeps their own farm, inventory, and progression.
- A team has a stable TeamId, name, captain, member list, and roles.
- Competition entries aggregate eligible server-validated contributions from member farms.
- Leaving a team never transfers farm ownership or personal items.
- Team invitations and membership changes require server validation, rate limits, and confirmation UI.

## Networking and security
Every handler validates player/session state, input types/bounds, ownership, distance, inventory/currency, cooldowns, object state, and rate limits. Never accept client-provided prices, rewards, growth completion, rarity, or scores.

## Persistence
DataStoreService is primary. Use schema versions, protected calls, retries, periodic saves, PlayerRemoving/BindToClose, session locking, and conflict-safe updates. The starter implementation is not production hardened.

## World scaling
The shared world contains public regions and individually assigned farm plots distributed through them. Use StreamingEnabled and region/plot streaming. Avoid excessive permanent part counts.

## Global competition
Use one authoritative schedule, idempotent season finalization, duplicate submission protection, deterministic scoring, and cross-server aggregation. OrderedDataStore can support leaderboard ordering; MemoryStoreService can coordinate temporary cross-server state. Team totals are calculated server-side.


## Greenfields world generation
- The map target is 3.6 km x 3.6 km, with a village, river, lake, several forest clusters, a rocky highland, and meadow details.
- Forest trees use server-side ProximityPrompts and award Wood after three valid chops; stone deposits award Stone and respawn after a cooldown. These prototype resources are leaderstats only until PlayerDataService is implemented.
- Farm plots are enlarged and reserve build pads for a coop, barn, and pasture. Pads are not yet a building or animal system.
- WorldService generates the first region: grassland, forest borders, Harvest River, wooden bridge, village square, and starter buildings.
- FarmService places individual plots south of the river in a spaced layout.
- This is a server-generated blockout. Final terrain sculpting, detailed assets, sound, water effects, and performance QA remain future art tasks.
