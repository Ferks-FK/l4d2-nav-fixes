# L4D2 Nav Mesh Fixes

A collection of nav mesh fixes and changes for Left 4 Dead 2, targeting specific map spots where bots (survivors and infected) behave poorly because of the map's nav mesh.

Everything here is a [VScript](https://developer.valvesoftware.com/wiki/VScript) file applied at runtime — for example, creating new connections between nav mesh areas (`NavMesh.GetNavAreaByID()` and `area.ConnectTo()`), or removing map entities that make bots avoid a route. Nothing modifies the map's `.nav` file — everything is applied dynamically on every map load, so nothing here conflicts with the original nav mesh or with other modifications.

## Fixes vs. changes

Scripts are split into two categories:

- **Nav fixes** (`nav_fixes/`) correct **defects** in the map: spots where bots get stuck with no possible route — usually locations that are only reversible by human players using techniques like pushing a scenery prop (e.g. a chair) and climbing it. L4D2's bot navigation is entirely based on the nav mesh: if two areas have no registered connection, there is no possible route between them, no matter the distance. Fixes add the missing connections.
- **Nav changes** (`nav_changes/`) override **intentional design choices** of the map that make bots behave worse than they could — for example, a route the mapper deliberately blocked for bots. These are opinionated and **optional**: install them only if you want that behavior.

## Repository structure

```
l4d2-nav-fixes/
├── scripts/
│   └── vscripts/
│       ├── nav_fixes/
│       │   └── <map>_navfixes.nut       # defect fixes for a map
│       └── nav_changes/
│           └── <map>_navchanges.nut     # optional behavior changes for a map
└── cfg/
    └── stripper/
        └── maps/
            └── <map>.cfg                 # injects the logic_auto(s) that run the scripts above
```

## Installation (server with SourceMod/Metamod + Stripper:Source)

1. Copy the contents of `scripts/vscripts/` into your server's `left4dead2/scripts/vscripts/`.
2. Copy the contents of `cfg/stripper/maps/` into your Stripper:Source config's `maps/` folder (by default `addons/stripper/maps/`; if you run Stripper with multiple named configs, adjust to `addons/stripper/<your_config>/maps/`).
3. **Optional:** to skip a map's nav changes, remove the `logic_auto` block that runs its `nav_changes/...` script from that map's `.cfg` (each block is commented).
4. Restart the map or the server. Each injected `logic_auto` fires `RunScriptFile` on the `director` entity ~20 seconds after map spawn.
5. Check the server console/log for `[NavFixes] <map>_navfixes initialized` / `Fix N applied`, or `[NavChanges] <map>_navchanges initialized` / `Change N applied`.

## Testing locally (no SourceMod/Stripper)

The scripts also run through the game's native console, no extensions required:

```
sv_cheats 1
map <map> coop
script_execute nav_fixes/<map>_navfixes
script_execute nav_changes/<map>_navchanges
```

Nothing is ever saved to the `.nav` file (we never call `nav_save`), so reloading the map without running `script_execute` always reverts to the original state — useful for comparing before/after behavior.

## Adding a new fix

1. Identify the spot where bots get stuck.
2. In local testing, with `sv_cheats 1` and `map <map> coop`, enter nav mesh edit mode:
   ```
   nav_edit 1
   ```
3. Aim at the "origin" area (the side bots come from, already reachable) and at the "stuck" area(s) (where bots get stuck). For each one:
   ```
   nav_toggle_in_selected_set     (default bind: Z) — selects the area under the crosshair
   nav_show_area_info 5           — shows the area's ID and attributes for 5 seconds
   ```
4. Note down the ID and position (`pos`) of each area — the position difference between origin and stuck side determines the connection direction (`0`=NORTH, `1`=EAST, `2`=SOUTH, `3`=WEST).
5. Create `scripts/vscripts/nav_fixes/<map>_navfixes.nut`, connecting the stuck-side area(s) back to the origin area with `.ConnectTo(origin, direction)`.
6. Test with `script_execute nav_fixes/<map>_navfixes` and confirm a bot can find its way back.
7. Create (or extend) `cfg/stripper/maps/<map>.cfg` to automate loading it in production.

## Fixed maps

| Map | Spot description | Before/after video |
|---|---|---|
| `c1m3_mall` | Mall corridor — bots got stuck after passing through a one-way spot, unable to find a route back to the group | [docs/comparisons.md](docs/comparisons.md#c1m3_mall) |

## Changed behavior (optional)

| Map | Spot description | Before/after video |
|---|---|---|
| `c1m1_hotel` | Burning corridor — the map blocks it for bots, so they took a much longer, more dangerous route around the fire; they now run through it (still taking the fire's damage) | [docs/comparisons.md](docs/comparisons.md#c1m1_hotel) |

See [docs/comparisons.md](docs/comparisons.md) for the full before/after video comparisons.

## Known limitations

- Connection fixes resolve **pathfinding** (the bot now considers the route and tries to use it), not necessarily physical **traversal** of large height gaps. Whether a bot can actually walk/step across depends on the specific geometry at that spot.
