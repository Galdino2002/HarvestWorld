# Product Decisions and Implementation Roadmap

## Approved decisions
1. Farms are individually owned.
2. Competition is team-based.
3. Each owner chooses who can visit: Private, Friends, or Public.

## Implemented in this milestone
- WorldService generates the Greenfields blockout with grassland, forest borders, Harvest River, bridge, village square, and five starter buildings.
- Farm plots are spaced across the fields south of the river rather than in the original tight grid.
- Farm plots carry an AccessMode attribute, defaulting to Friends.
- The owner can cycle access from the farm HUD.
- Farm signs include a visit prompt.
- The server validates visitor access; friendship lookup errors fail closed.
- Visiting moves the visitor to the farm but grants no edit permissions.

## Next milestones
1. Art pass: sculpted terrain, improved building facades, road details, sound, lighting, and environmental effects.
2. TeamService: create teams, invite/accept, leave, captain role, member limits.
3. Team competition: weekly events, server-calculated totals, anti-duplication.
4. Explicit collaborator permissions, separate from visitor access.
5. Persistence for farms, access settings, teams, and progression.
6. PC/mobile/console playtests and streaming/part-count optimization.

## Prototype limitations
- Team creation and team competition are designed but not implemented yet.
- Farm access controls visits only, not collaborator editing.
- The current farm layout is still a prototype grid.
- Persistence is not implemented; coins and seed inventory currently reset.
