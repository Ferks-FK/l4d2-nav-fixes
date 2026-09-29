printl("\n[NavChanges] c1m1_hotel_navchanges initialized\n")

// Burning corridor: the map blocks the fires for bots, so they take a long detour around them.
// This removes each fire's nav blocker and trigger_hurt, and recreates the damage from here,
// so bots walk through the fire and still get hurt.
//
// The fires only spawn when players get close, so we wait for each one to show up.

const NAVCHANGES_DMG_GENERIC = 0
const NAVCHANGES_DMG_BURN = 8
const NAVCHANGES_HURT_INTERVAL = 0.5
const NAVCHANGES_POLL_INTERVAL = 1.0

::NavChanges_C1M1_Fires <- [
	// Change 1: fire16 - areas #101655, #89375, #101651
	{ change = "Change 1", hurt = "fire16_hurt", navblock = "fire16_navblock" },
	// Change 2: fire14 - areas #89369, #89366
	{ change = "Change 2", hurt = "fire14_hurt", navblock = "fire14_navblock" }
]

foreach (fire in ::NavChanges_C1M1_Fires)
{
	fire.applied <- false
	fire.mins <- null
	fire.maxs <- null
	fire.damage <- 0.0
}

::NavChanges_C1M1_FireTick <- function()
{
	foreach (fire in ::NavChanges_C1M1_Fires)
	{
		if (!fire.applied)
			continue

		foreach (classname in ["player", "infected", "witch"])
		{
			local ent = null
			while ((ent = Entities.FindByClassname(ent, classname)) != null)
			{
				if (ent.GetHealth() <= 0)
					continue

				local pos = ent.GetOrigin()
				if (pos.x + 16 < fire.mins.x || pos.x - 16 > fire.maxs.x ||
					pos.y + 16 < fire.mins.y || pos.y - 16 > fire.maxs.y ||
					pos.z + 72 < fire.mins.z || pos.z > fire.maxs.z)
					continue

				// burn damage makes survivor bots try to run from the fire
				local isSurvivor = classname == "player" && ent.IsSurvivor()
				ent.TakeDamage(fire.damage * NAVCHANGES_HURT_INTERVAL, isSurvivor ? NAVCHANGES_DMG_GENERIC : NAVCHANGES_DMG_BURN, null)
			}
		}
	}
}

::NavChanges_C1M1_ApplyFire <- function(fire, hurt, navblock)
{
	local origin = hurt.GetOrigin()

	try
	{
		fire.mins = origin + NetProps.GetPropVector(hurt, "m_Collision.m_vecMins")
		fire.maxs = origin + NetProps.GetPropVector(hurt, "m_Collision.m_vecMaxs")
	}
	catch (e)
	{
		printl("[NavChanges] ERROR reading " + fire.hurt + " box: " + e)
	}

	try
	{
		// damage per second
		fire.damage = NetProps.GetPropFloat(hurt, "m_flDamage")
	}
	catch (e)
	{
		printl("[NavChanges] ERROR reading " + fire.hurt + " damage: " + e)
	}

	printl("[NavChanges] " + fire.hurt + " origin: " + origin + " | box: " + fire.mins + " -> " + fire.maxs + " | damage/s: " + fire.damage)

	if (fire.mins == null || fire.maxs == null || fire.damage <= 0)
	{
		printl("\n[NavChanges] ERROR: " + fire.change + " not applied (could not recreate " + fire.hurt + "'s damage)\n")
		return false
	}

	navblock.Kill()
	hurt.Kill()
	fire.applied = true

	printl("\n[NavChanges] " + fire.change + " applied\n")
	return true
}

::NavChanges_C1M1_FirePoll <- function()
{
	local pending = 0

	foreach (fire in ::NavChanges_C1M1_Fires)
	{
		if (fire.applied || fire.rawin("failed"))
			continue

		local hurt = Entities.FindByName(null, fire.hurt)
		local navblock = Entities.FindByName(null, fire.navblock)

		if (hurt == null || navblock == null)
		{
			pending++
			continue
		}

		if (!::NavChanges_C1M1_ApplyFire(fire, hurt, navblock))
			fire.failed <- true
	}

	if (pending == 0)
		EntFire("navchanges_c1m1_fire_poll", "Kill")
}

SpawnEntityFromTable("logic_timer", {
	targetname = "navchanges_c1m1_fire_poll"
	RefireTime = NAVCHANGES_POLL_INTERVAL
	OnTimer = "!self,RunScriptCode,NavChanges_C1M1_FirePoll(),0,-1"
})

SpawnEntityFromTable("logic_timer", {
	targetname = "navchanges_c1m1_fire_damage"
	RefireTime = NAVCHANGES_HURT_INTERVAL
	OnTimer = "!self,RunScriptCode,NavChanges_C1M1_FireTick(),0,-1"
})
