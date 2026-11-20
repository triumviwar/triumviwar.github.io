class_name GunCrewArt
## The Gun Crewman's stand-in strips (tools/make_gun_crew_art.py: the Labourer's with a gunner's steel helmet), merged into
## ArtData.UNITS. Kept apart, with no other class in it, so ArtData can read it while the game loads.

const ART := {
	"gun_crew": {"cell": Vector2i(42, 35), "anchor": Vector2(21, 33), "frames": {
		"idle_s": 2, "idle_se": 2, "idle_e": 2, "idle_ne": 2, "idle_n": 2,
		"walk_s": 6, "walk_se": 6, "walk_e": 6, "walk_ne": 6, "walk_n": 6,
		"death_s": 3, "death_se": 3, "death_e": 3, "death_ne": 3, "death_n": 3,
	}},
}
