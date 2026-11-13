# Technical Architecture

## Runtime boundaries
- **Server:** owns player data, plot ownership, inventory, currency, crop state, growth calculations, harvest validation, and competition results.
- **Client:** renders UI, input, camera feedback, animations, and sends requests. It is never trusted for rewards or authoritative state.
- **Shared:** immutable configuration, constants, and network contract definitions.

## Initial services
- PlayerDataService: versioned profile load/save and session lifecycle.
- FarmService: plot assignment and ownership checks.
- PlantService: planting, growth state, harvest eligibility.
- EconomyService: validated currency changes and selling.
- Later: InventoryService, TheftService, ProtectionService, CompetitionService, RankingService.

## Networking
RemoteEvents/RemoteFunctions are requests, not proof. Every server handler validates:
1. Player/session state.
2. Input type and bounds.
3. Ownership and distance.
4. Inventory/currency availability.
5. Cooldowns and current object state.
6. Rate limits.

Never accept a client-provided price, reward, growth completion, rarity, or score.

## Persistence
DataStoreService is the primary persistence layer. Use schema versions, protected calls, retry/backoff, periodic saves, and PlayerRemoving/BindToClose handling. Production persistence needs session locking and conflict-safe updates; the starter implementation is intentionally small and must be hardened before public launch.

## World scaling
Use StreamingEnabled and region/plot streaming for a large map. Avoid one permanent high-part-count model per player. Use server-side registries and spatially bounded interactions.

## Global competition
A weekly event needs a single authoritative schedule, idempotent season finalization, duplicate submission protection, deterministic scoring, and cross-server aggregation. OrderedDataStore can support leaderboard ordering; MemoryStoreService can coordinate short-lived cross-server state. Do not rely on one server's in-memory table for global results.

## Security
Server-side validation is mandatory. Add rate limiting, sanity checks, anti-duplication safeguards, and audit logs for valuable actions. Test exploit scenarios before enabling trading or theft.
