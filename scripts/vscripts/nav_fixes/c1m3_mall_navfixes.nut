printl("\n[NavFixes] c1m3_mall_navfixes initialized\n")

// Fix 1: "point of no return" in the mall corridor - players can climb back up by pushing
// a scenery prop (chair) and jumping on it, but bots get stuck on the lower side with no
// nav mesh route back to the upper corridor.
//
// Upper/origin area (already reachable normally): #34357
// Lower areas where bots get stuck (need a route back): #20443 (large), #34367 and #34368
// (small, near the door)

local fix1_upperNav = NavMesh.GetNavAreaByID(34357)
local fix1_lower_a = NavMesh.GetNavAreaByID(20443)
local fix1_lower_b = NavMesh.GetNavAreaByID(34367)
local fix1_lower_c = NavMesh.GetNavAreaByID(34368)

if (fix1_upperNav == null || fix1_lower_a == null || fix1_lower_b == null || fix1_lower_c == null)
{
	printl("\n[NavFixes] ERROR: one of Fix 1's areas was not found (IDs may have changed after a nav mesh regeneration)\n")
}
else
{
	// Direction 1 = EAST, calculated from the areas' real positions (the stuck side sits
	// west/southwest of #34357, so heading east gets you back to #34357)
	fix1_lower_a.ConnectTo(fix1_upperNav, 1)
	fix1_lower_b.ConnectTo(fix1_upperNav, 1)
	fix1_lower_c.ConnectTo(fix1_upperNav, 1)

	printl("\n[NavFixes] Fix 1 applied\n")
}
