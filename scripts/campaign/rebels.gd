class_name Rebels
extends RefCounted
## THE FREE ASSEMBLY (campaign mission 1, docs/campaign_m1_build.md): a minor, non-playable side, GREEN AND BLACK.
## Until the owner's own rebel art arrives, its men are STAND-INS: Crown units in the rebels' team colour, given a ROLE
## here. Everything the rebels are is in this one table, so the real sprites can replace the stand-ins without touching
## the mission:
##   - a mission's "units" entry or "spawn" action says "as": "<role>" (and its "kind" is the role's own kind);
##   - MissionRun.apply_role puts the role on the unit: its sprites (ART, if the folder is in), its name over the bar,
##     its torch.
## To drop in the owner's sprites for a role: put the strips in assets/units/<art>/ (<anim>_<dir>.png, the same
## animation names as the stand-in's kind: a militiaman needs a Musketeer's idle/walk/aim/fire/reload/melee/death),
## and add the art's cell, anchor and frame counts to RebelArt.ART (scripts/campaign/rebel_art.gd). The role then
## wears them; nothing else changes.

## role -> {kind: the Defs unit it plays as, art: its own sprites (used once listed in ART), name: shown over its bar,
## torch: burns enemy buildings it stands at}
const ROLES := {
	"militia": {"kind": "musketeer", "art": "rebel_militia", "about": "Free Assembly militia: a musket and a green cockade."},
	"torch": {"kind": "labourer", "art": "rebel_torch", "torch": true, "about": "A torch-bearer: sets barns and houses alight."},
	"pikeman": {"kind": "pikeman", "art": "rebel_pikeman", "about": "A pike from the farm armouries."},
	"varenne": {"kind": "dismounted", "art": "rebel_varenne", "name": "Etienne Varenne", "about": "The Free Assembly's orator."},
	# CAMPAIGN PEOPLE beyond the rebels (the Clockwork prologue, docs/campaign_c01_build.md): this table is the campaign's
	# roles in general now. People are stand-ins until drawn (their "art" folder named here, used once it is in).
	"citizen": {"kind": "labourer", "art": "c_citizen", "about": "A townsman of Nuremberg."},
	"hollweg": {"kind": "missionary", "art": "c_hollweg", "name": "Meister Hollweg", "hp": 260, "about": "Master of the Guild of the Escapement."},
	"jakob": {"kind": "labourer", "art": "c_jakob", "name": "Jakob", "hp": 120, "about": "Hollweg's journeyman."},
	"ferrer": {"kind": "missionary", "art": "c_ferrer", "name": "Father Ferrer", "about": "A Jesuit astronomer and engineer."},
	# THE BROOD PROLOGUE (docs/campaign_b01_build.md): the station's people, the garrison's, and LINNEA, a Brood Mother's
	# kind drawn at a third of her size ("scale") until her own art exists
	"lindqvist": {"kind": "musketeer", "art": "b_lindqvist", "name": "Dr. Lindqvist", "hp": 320, "about": "The Academy's naturalist, with a fowling piece."},
	"valadares": {"kind": "dismounted", "art": "b_valadares", "name": "Valadares", "hp": 320, "about": "The Crown's mapmaker: pistol and machete."},
	"pieter": {"kind": "labourer", "art": "b_pieter", "name": "Pieter", "hp": 110, "about": "Lindqvist's young preparator."},
	"teles": {"kind": "dismounted", "art": "b_teles", "name": "Lieutenant Teles", "hp": 160, "about": "Commands the fort at São Gabriel."},
	"joaquim": {"kind": "missionary", "art": "b_joaquim", "name": "Frei Joaquim", "about": "The Carmelite of the mission village."},
	"villager": {"kind": "labourer", "art": "b_villager", "about": "A villager of Nossa Senhora de Nazaré."},
	"benedito": {"kind": "labourer", "art": "b_benedito", "name": "Benedito", "hp": 120, "about": "The river trader with the canoes."},
	"linnea": {"kind": "brood_mother", "art": "b_linnea", "name": "Linnea", "hp": 900, "scale": 0.3, "about": "Specimen One."},
	# (a03_plateau, three months on: she has grown, drawn at half the Mother's size among her own)
	"linnea_grown": {"kind": "brood_mother", "art": "b_linnea", "name": "Linnea", "hp": 1400, "scale": 0.5, "about": "Specimen One, grown."},
	# (a03_plateau: a man of Nazaré who knows the paths up the cloud mountain)
	"guide": {"kind": "labourer", "art": "b_villager", "name": "Guide", "hp": 90, "about": "A man of Nazaré who knows the mountain's paths."},
	# Act 1's a01_presses (Lyon, spring 2768): the young priest, the garrison's captain, the Assembly's runners and its
	# master printer, the silk-weavers of the Croix-Rousse (stand-ins until drawn)
	"tomasz": {"kind": "missionary", "art": "a_tomasz", "name": "Father Tomasz", "hp": 360, "about": "A young priest of a Lyon parish, ordained this spring."},
	"delorme": {"kind": "dismounted", "art": "a_delorme", "name": "Captain Delorme", "hp": 220, "about": "Captain of the Crown's garrison at Lyon."},
	"runner": {"kind": "labourer", "art": "a_runner", "about": "A runner of the Free Assembly with a bundle of pamphlets."},
	"printer": {"kind": "labourer", "art": "a_printer", "name": "Master Rouvière", "hp": 300, "about": "The master printer of the great press under the hill."},
	"weaver": {"kind": "labourer", "art": "c_citizen", "about": "A silk-weaver of the Croix-Rousse."},
	# Act 1's a06_barricades (Paris, July 2769): the field marshal, the captain of the guns, the Virginia volunteers, the
	# Lyon men at the barricades, Varenne in his hall (harder to kill than in Virginia: he is to be taken alive)
	"fairleigh": {"kind": "dismounted", "art": "a_fairleigh", "name": "Field Marshal Fairleigh", "hp": 320, "about": "Lord Edmund Fairleigh, once Governor of Virginia, now the King's field marshal."},
	"ruggieri": {"kind": "dismounted", "art": "a_ruggieri", "name": "Colonel Ruggieri", "hp": 220, "about": "Matteo Ruggieri, the guns' colonel since Virginia."},
	"volunteer": {"kind": "musketeer", "art": "a_volunteer", "about": "A Virginia volunteer: one of the families saved at the Hollins farm."},
	"lyon_man": {"kind": "musketeer", "art": "rebel_militia", "about": "A Lyon weaver come to the barricades of Paris."},
	"varenne_hall": {"kind": "dismounted", "art": "rebel_varenne", "name": "Etienne Varenne", "hp": 260, "about": "The Free Assembly's orator, in his hall."},
}

const TORCH_DPS := 6.0               # a torch-bearer's fire on a building he stands at, per second (armour ignored)
const TORCH_REACH := 26.0            # how close to a building's edge he must be
const TORCH_SEEK := 3.0              # seconds between a scripted torch-bearer's looks for the next building


static func role(r: String) -> Dictionary:
	return ROLES.get(r, {})


## A unit becomes a rebel of this role (its art if drawn, its name, its torch).
static func apply(u: Unit, r: String) -> void:
	var ro := role(r)
	if ro.is_empty() or u == null:
		return
	u.set_meta("rebel_role", r)
	var a := String(ro.get("art", ""))
	if a != "" and ArtData.UNITS.has(a):      # (RebelArt.ART lists the sprite sets that are in)
		u.art = a
		if u.sprite:
			u._set_anim(u.anim if u.anim != "" else "idle", true)
	if ro.has("name"):
		u.set_meta("mission_name", String(ro["name"]))
	if bool(ro.get("torch", false)):
		u.set_meta("torch", true)
	if ro.has("scale"):
		u.set_meta("role_scale", float(ro["scale"]))      # (drawn smaller: BroodNew's Mother picture reads it)
		u.d = u.d.duplicate()                               # (its own: the sprite's scale comes from its "art_scale")
		u.d["art_scale"] = float(u.d.get("art_scale", 1.0)) * float(ro["scale"])
		if u.sprite:
			u._set_anim(u.anim if u.anim != "" else "idle", true)
		u.radius = maxf(8.0, u.radius * float(ro["scale"]))
	if ro.has("hp"):
		u.max_hp = float(ro["hp"])     # (a hero of the story: harder to kill than the stand-in he plays)
		u.hp = u.max_hp
	u.queue_redraw()


## Every tick (MissionRun): torch-bearers burn the enemy building they stand at; the scripted ones (no person plays
## them) walk on to the nearest enemy building when they have nothing to burn.
static func tick(run: MissionRun, dt: float) -> void:
	var g := run.game
	for u in g.units:
		if u.dead or not u.has_meta("torch"):
			continue
		var best: Building = null
		var bd := INF
		for b in g.buildings:
			if b.dead or b.ghost or not g.hostile(b.team, u.team):
				continue
			var dd: float = b.edge_distance(u.position)
			if dd < bd:
				bd = dd
				best = b
		if best == null:
			if u.has_meta("torch_burning"):
				u.remove_meta("torch_burning")
			continue
		if bd <= TORCH_REACH:
			u.set_meta("torch_burning", true)       # (Unit._anim_name: he plays his setting-fire strip)
			best.take_damage(TORCH_DPS * dt + maxf(float(best.armor), 0.0), u)      # (armour ignored: Entity.take_damage takes it off)
			if randf() < dt * 0.8:
				g.spawn_effect("fire", best.center() + Vector2(randf_range(-30, 30), randf_range(-20, 20)), 0.8)
			continue
		if u.has_meta("torch_burning"):
			u.remove_meta("torch_burning")
		if run.player_teams.has(u.team):
			continue
		var t := float(u.get_meta("torch_t", 0.0)) - dt
		if t <= 0.0 and (u.velocity.length() < 5.0 or u.order != "move"):
			t = TORCH_SEEK
			# (to the near edge of the building, not its middle: he must stand at it)
			var half := float(maxi(best.size.x, best.size.y)) * Defs.TILE * 0.5
			var p: Vector2 = best.center() + (u.position - best.center()).normalized() * (half * 0.75 + 4.0)
			g.group_move([u], p, false)
		u.set_meta("torch_t", t)
