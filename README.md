# L4D2 Nav Mesh Fixes

A collection of nav mesh fixes for Left 4 Dead 2, targeting specific map spots where **bots (survivors and infected) get stuck with no route back** — usually locations that are only reversible by human players using techniques like pushing a scenery prop (e.g. a chair) and climbing it.

Each fix is a [VScript](https://developer.valvesoftware.com/wiki/VScript) file that creates new connections between nav mesh areas at runtime, using `NavMesh.GetNavAreaByID()` and `area.ConnectTo()`. No fix modifies the map's `.nav` file — everything is applied dynamically on every map load, so nothing here conflicts with the original nav mesh or with other modifications.

## Why this exists

L4D2's bot navigation is entirely based on the nav mesh: if two areas have no registered connection, there is no possible route between them, no matter the distance. Several maps (official and custom) have intentional "no return" spots for human players, which rely on the physics engine (pushing/climbing props) to bypass — something bot AI has no concept of. The result: bots get stuck at these spots indefinitely.

This repository documents and fixes these spots, map by map, by manually adding the missing nav mesh connections.

## Repository structure

```
l4d2-nav-fixes/
├── scripts/
│   └── vscripts/
│       └── nav_fixes/
│           └── <map>_navfixes.nut      # one script per fixed map
└── cfg/
    └── stripper/
        └── maps/
            └── <map>.cfg                # injects the logic_auto that runs the script above
```

## Installation (server with SourceMod/Metamod + Stripper:Source)

1. Copy the contents of `scripts/vscripts/` into your server's `left4dead2/scripts/vscripts/`.
2. Copy the contents of `cfg/stripper/maps/` into your Stripper:Source config's `maps/` folder (by default `addons/stripper/maps/`; if you run Stripper with multiple named configs, adjust to `addons/stripper/<your_config>/maps/`).
3. Restart the map or the server. The injected `logic_auto` fires `RunScriptFile` on the `director` entity ~20 seconds after map spawn, applying the connections.
4. Check the server console/log for `[NavFixes] <map>_navfixes initialized` followed by `Fix N applied`.

## Testing locally (no SourceMod/Stripper)

The scripts also run through the game's native console, no extensions required:

```
sv_cheats 1
map <map> coop
script_execute nav_fixes/<map>_navfixes
```

Since no fix is ever saved to the `.nav` file (we never call `nav_save`), reloading the map without running `script_execute` always reverts to the original state — useful for comparing before/after behavior.

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
7. Create `cfg/stripper/maps/<map>.cfg` to automate loading it in production.

## Fixed maps

| Map | Spot description | Before/after video |
|---|---|---|
| `c1m3_mall` | Mall corridor — bots got stuck after passing through a one-way spot, unable to find a route back to the group | [docs/comparisons.md](docs/comparisons.md#c1m3_mall) |

See [docs/comparisons.md](docs/comparisons.md) for the full before/after video comparisons.

## Known limitations

- The fix resolves **pathfinding** (the bot now considers the route and tries to use it), not necessarily physical **traversal** of large height gaps. Whether a bot can actually walk/step across depends on the specific geometry at that spot.

## License

_TBD._
