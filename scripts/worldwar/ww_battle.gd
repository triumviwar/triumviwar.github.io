class_name WWBattle
extends RefCounted
## FIGHT IT (docs/world_war_mode.md): a world-war battle played as a skirmish. The map is one of the skirmish's 1v1
## maps of the region's kind of land; each side starts with its usual camp (hall and workers, the Brood's Mother) and,
## beside it, exactly the army it brought from the world map; the region's holder gets more gold for its walls
## (HOLDER_GOLD). When the match ends the survivors of each army are counted on the field and carried back to the map
## (WWWar.apply_fought). Leaving the battle (QUIT) counts as a lost battle for the player's side.

const HOLDER_GOLD := 300
## The skirmish maps for each kind of land (1v1 maps; the first that exists is used, by the battle's own dice).
const MAPS := {
	"temperate": ["greenhold", "twin_fords", "ashford_crossing", "amberfall_vale", "highmoor", "kestrel_rise"],
	"cold": ["frostfang", "frostmere", "border_march", "thornwood_maze"],
	"desert": ["dune_sea", "redrock_canyon", "red_coast"],
	"jungle": ["mirewood", "hollowfen", "glimmerdeep"],
	"wet": ["mirewood", "hollowfen", "saltmarsh_isles", "twin_fords"],
}

var war: WWWar
var battle := {}
var me := ""                       # the player's side in this battle
var slot_side := {}                # slot index -> "att" / "def"
var brought := {}                  # "att" / "def" -> the units each side brought
var done := false


static func map_for(biome: String, seed: int) -> String:
	var ok: Array = (MAPS.get(biome, MAPS["temperate"]) as Array).filter(func(id: String) -> bool: return MapGen.all_ids().has(id))
	if ok.is_empty():
		return "greenhold"
	return String(ok[absi(seed) % ok.size()])


## The match setup for a battle (the player against the side's own computer at the war's level, Hard by default).
func make_cfg() -> Dictionary:
	var af := String(battle["att_f"])
	var df := String(battle["def_f"])
	me = af if war.is_human(af) else df
	var foe := df if me == af else af
	var lvl := war.who(foe)
	if not ["easy", "normal", "hard"].has(lvl):
		lvl = "hard"
	var seed := war.rng.randi()
	var slots: Array = [
		{"who": "you", "faction": me, "colour": _colour(me), "side": 0},
		{"who": lvl, "faction": foe, "colour": _colour(foe), "side": 1, "strategy": "balanced"}]
	slot_side = {0: "att" if me == af else "def", 1: "def" if me == af else "att"}
	brought["att"] = war.army(String(battle["att"]))["units"].duplicate()
	var du := {}
	for did in battle.get("defs", []):
		for k in war.army(String(did))["units"]:
			du[k] = int(du.get(k, 0)) + int(war.army(String(did))["units"][k])
	brought["def"] = du
	return {"map": map_for(war.biome_now(String(battle["region"])), seed), "slots": slots, "seed": seed, "worldwar": true}


static func _colour(f: String) -> int:
	return {"crown": 4, "clockwork": 1, "brood": 2}.get(f, Defs.COLOUR_RANDOM)      # (purple, red, green: Defs.PALETTE)


## Start the battle (the war is saved first: a battle left by closing the game finds the war as it was).
func begin(main: Node) -> void:
	war.d["fighting"] = battle.duplicate(true)
	war.save()
	var cfg := make_cfg()
	main.ww_battle = self
	main.start(cfg)
	if main.game:
		place_armies(main.game)


## The armies on the field: beside each side's start, a little toward the middle.
func place_armies(g: Game) -> void:
	var mid := Vector2(g.W, g.H) * Game.T * 0.5
	for t in 2:
		var units: Dictionary = brought[slot_side[t]]
		var base := g.cell_center(g.starts[t])
		var dir := (mid - base).normalized()
		var at := base + dir * 7.0 * Game.T
		var i := 0
		for k in units:
			for _n in int(units[k]):
				var row := i / 8
				var col := i % 8
				var side := Vector2(-dir.y, dir.x)
				var p := at + side * (col - 3.5) * 26.0 - dir * row * 26.0
				var u := g._add_unit(String(k), t, g.on_map(p))
				if Defs.ammo_full(u.kind) > 0:
					u.set_ammo(Defs.ammo_full(u.kind))
				u.set_meta("ww", true)
				i += 1
		if String(slot_side[t]) == "def" and war.owner(String(battle["region"])) == String(battle["def_f"]):
			g.players[t]["gold"] = int(g.players[t]["gold"]) + HOLDER_GOLD


## The survivors on the field: each side's units of the kinds it brought (WWWar._cap_kinds caps the new ones).
static func survivors(g: Game, t: int) -> Dictionary:
	var out := {}
	for u in g.units:
		if u.team == t and not u.dead and WWRules.UNIT_VALUE.has(u.kind):
			out[u.kind] = int(out.get(u.kind, 0)) + 1
	return out


## The match is over (main._on_end): the result onto the world map. `winner` is the slot that won (-1 none).
func finish(g: Game, winner: int) -> Dictionary:
	if done:
		return {}
	done = true
	var by := {}
	for t in 2:
		by[slot_side[t]] = survivors(g, t)
	var att_won := winner >= 0 and String(slot_side.get(winner, "")) == "att"
	war.d.erase("fighting")
	var res := war.apply_fought(battle, att_won, by["att"], by["def"])
	war.save()
	return res


## The player left the battle: it is lost for the player's side (its army takes a beaten army's losses).
func leave() -> Dictionary:
	if done:
		return {}
	done = true
	war.d.erase("fighting")
	var me_att := me == String(battle["att_f"])
	var res := war.apply_result(battle, not me_att, 0.1, WWRules.LOSER_LOSS)
	war.save()
	return res
