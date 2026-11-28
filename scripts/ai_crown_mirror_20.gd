class_name AICm20
extends RefCounted
## CROWN MIRROR TO 20:00 (job crown-mirror-20, docs/crown_mirror_20.md; the owner said yes 2026-11-28): crown-mirror-coach's
## proposals P2-P4, each behind its own switch, ALL OFF by default (P1 was the measure to 20:00 itself, no switch):
##
##   `cm20guns:on`  P2, THE GUNS' SCREEN. The mirror's bombardment (AICrownMirror rule 7) shells a hall only from a spot out of
##                  every enemy shooter's reach; under a main's cliff line there is none and the wave pulls back home. With P2
##                  the wave's formed line stands IN FRONT of its guns, toward the hall (SCREEN_AHEAD px), and the guns shell the
##                  hall from behind it: a spot under fire is taken when SCREEN_MEN of our armed men stand within SCREEN_R of it.
##   `cm20gates:on` P3, THE PRESSED WAVE GOES PAST THE GATES. crown-mirror-coach's P3 (a new hall's guards take two thirds
##                  of the army) is gone in today's code: the Crown's doctrine clears the guards (AICrown._guard_new_hall). What
##                  holds a pressed wave now are the shared rule's other gates (the regroup, the timing, the kit, round 5, the
##                  wave's worth, the defence's "a push is coming", the screen riders: AICrownMirror._held_by names them). With
##                  P3, while the press finds the side ahead (AICrownMirror.press, the last PRESS_GO s) and the bar is met,
##                  the wave goes past them (AICrownMirror.press_go); not with a force at our buildings, not for the Siege push.
##   `cm20fade:on`  P4, THE DEFENCE FADES (a BALANCE change: measured only, for the owner): from FADE_FROM to FADE_FULL the
##                  damage palisades and gates take rises to FADE_MAX times, for every side.

static var _args := OS.get_cmdline_user_args()
static var guns_on: bool = _args.has("cm20guns:on")
static var gates_on: bool = _args.has("cm20gates:on")
static var fade_on: bool = _args.has("cm20fade:on")

const SCREEN_MEN := 4             # our armed non-gun men within SCREEN_R of a gun's spot: the spot is screened
const SCREEN_R := 230.0           # (px)
const SCREEN_AHEAD := 120.0       # (px) the line stands this far before the guns, toward the hall
const SCREEN_MIN := 6             # men the wave needs to form a screen
const SCREEN_GAP := 30.0          # (px) between the men in the line


const FADE_FROM := 720.0          # 12:00
const FADE_FULL := 960.0          # 16:00
const FADE_MAX := 1.75


## (P4) the damage a palisade or a gate takes, times this.
static func wall_k(game, b) -> float:
	if not fade_on or game == null or b.is_unit() or not b.d.get("line", false):
		return 1.0
	var t: float = clampf((float(game.clock) - FADE_FROM) / (FADE_FULL - FADE_FROM), 0.0, 1.0)
	return 1.0 + (FADE_MAX - 1.0) * t


## (P2) the guns' spots and the line before them when no spot out of reach is left: {gun: spot}, or {} when the wave
## cannot screen (too few men, no spot in range it can walk to). `line` gets the line's points.
static func screen_spots(cm, guns: Array, men: Array, hall, line: PackedVector2Array) -> Dictionary:
	if men.size() < SCREEN_MIN:
		return {}
	var game = cm.game
	var hc: Vector2 = hall.center()
	var half: float = maxf(hall.rect().size.x, hall.rect().size.y) * 0.5
	var spots := {}
	var cen := Vector2.ZERO
	for gu in guns:
		var rng: float = float(gu.d["range"])
		var from: Vector2i = game.cell_of(gu.position)
		var flood: PackedByteArray = cm.ai._flood_from([from], cm.ai.team)
		var best := Vector2.INF
		var bd := INF
		for k in cm.GUN_SPOT_STEP:
			var a: float = TAU * k / cm.GUN_SPOT_STEP
			for r in [rng * 0.85, rng * 0.7]:
				var p: Vector2 = hc + Vector2(cos(a), sin(a)) * (float(r) + half * 0.6)
				var c: Vector2i = game.cell_of(p)
				if not game.in_map(c) or flood[game.idx(c)] != 1:
					continue
				if hall.edge_distance(p) > rng - 16.0 or hall.edge_distance(p) < float(gu.d.get("min_range", 0)) + 16.0:
					continue
				var d: float = p.distance_to(gu.position)
				if d < bd:
					bd = d
					best = game.cell_center(c)
		if best != Vector2.INF:
			spots[gu] = best
			cen += best
	if spots.size() < cm.BOMBARD_GUNS:
		return {}
	cen /= spots.size()
	var dir: Vector2 = (hc - cen).normalized()
	var mid: Vector2 = cen + dir * SCREEN_AHEAD
	if game.level_of(mid) != game.level_of(cen):
		mid = cen + dir * SCREEN_AHEAD * 0.5      # (not up a cliff: the line stands on the guns' ground)
	var side := Vector2(-dir.y, dir.x)
	var w: float = SCREEN_GAP * (men.size() - 1) * 0.5
	line.append(mid - side * w)
	line.append(mid + side * w)
	return spots


## (P2) a gun's spot under fire is still taken when our line screens it.
static func screened(cm, p: Vector2) -> bool:
	var n := 0
	for o in cm.game.units_near(p, SCREEN_R):
		if not o.dead and o.team == cm.ai.team and not o.is_worker() and o.armed() and not cm.GUN_KINDS.has(o.kind) \
				and o.position.distance_to(p) < SCREEN_R:
			n += 1
			if n >= SCREEN_MEN:
				return true
	return false
