extends RefCounted
class_name AICrownStack
## LABOURERS STACKED ON A SITE (crown-build-stack, 2026-11-18; the owner 10:59: "One of the strongest advantages of the
## Crown is stacking multiple labourers to build certain buildings quickly. This compensates for the delayed economy of
## having to wait for Farms."; docs/crown_build_stack.md). Every Labourer on a Crown site adds its full build speed
## (Unit._build: site.add_progress(delta) per builder), so N labourers build it N times faster for the SAME labourer-seconds:
## a Farm is 25 labourer-seconds whether one man works 25 s or five work 5 s. The only real price of a helper is his walk
## there and back (and the harvest he carried). The computer sent ONE labourer to every building (AI._construct), only the
## new Town Hall got three. Now, every think, each of the Crown computer's unfinished sites that matters gets helpers up
## to its kind's count (WANT), from the labourers near enough that the walk pays:
##  - an idle labourer (or one with no free Farm post to go to) costs nothing: he goes if he arrives before the site is done;
##  - a working labourer goes only if his walk is under WALK_SHARE of the work he will do there (the site's labourer-seconds
##    left shared among its builders), URGENT sites (the Barracks / Gate / Cottage under a scouted rush or a seen push, a
##    Cottage while the supply is blocked, the opening's second Farm, a new hall's first Farm, a Town Hall behind the
##    coach's clock) with a longer leash; a Cottage gets helpers only when urgent (or idle ones);
##  - never to a site in danger (AI._unsafe) nor one not begun yet (a ghost: its footprint must be clear to start), never the
##    scout, the escort, a Mill's last hand, a crew of any other building, a labourer leading a horse or on an errand, and
##    not more than BUSY_SHARE of the labourers off the Farms at once.
## Done, a helper goes to the next unfinished site near him or back to a free post (Unit._build: game.next_site / free_site).
## Switch `buildstack:off` (both sides); `buildstack:off1` / `buildstack:off0` turn it off for team 1 / team 0 only (the
## mirror's measure).

const WANT := {
	"farm": 3, "cottage": 1, "barracks": 3, "gate": 3, "foundry": 3, "horse_breeder": 3, "powder_mill": 2,
	"armoury": 2, "church": 2, "town_hall": 4,
}
const URGENT_WANT := {"barracks": 4, "gate": 4, "cottage": 3, "farm": 4, "town_hall": 5}
const WALK_SHARE := 0.34         # a working helper's walk (s) under this share of the work he will do there
const URGENT_SHARE := 0.75       # (an urgent site's)
const IDLE_MARGIN := 2.0         # (s) an idle helper must arrive this long before the site would be done without him
const BUSY_SHARE := 0.25         # at most this share of the labourers building at once (idle helpers not counted)
const SEND_MAX := 4              # helpers sent a think, all sites together
## (test_ai_wall_vs_rush, the owner's extreme rush: a Farm hand pulled to the opening's second Farm at 0:46, with 7
## labourers, put the next harvest a few seconds late, the Barracks' 150 gold missed the 58 s step by 20 gold and waited 40 s
## for the next harvest: Barracks at 98 s, no Musketeer by 2:40, 13 labourers lost. Every harvest counts while one Farm
## pays: below PULL_LABS labourers only idle ones help, and a working hand only at a site a rush or a push makes urgent.)
const PULL_LABS := 14


## (the rule above is for the rush's minutes: against the Brood, and against anyone before our scout's read or while it
## reads a rush; against the Crown and the Clockwork read NORMAL or GREEDY the opening's Farm hands may help, which
## brought the second hall 40 s sooner against the Clockwork in the first batch)
func _early_careful() -> bool:
	if ai._foe_is("brood"):
		return true
	return ai.scout == null or ai.scout.verdict == "pending" or ai.scout.verdict == "rush" or ai.scout.verdict == "uncertain"
const CARRY_PEN := 4.0           # (s) a labourer with a harvest in his hands counts this much more walk

var ai          # the AICrown
var game: Game
var team := 0

var args := OS.get_cmdline_user_args()
var on_switch := not args.has("buildstack:off")

# (the report, result.json crown_ai "stack")
var sent := 0                    # helpers sent
var sent_idle := 0               # (of them idle or without a post)
var sent_by := {}                # kind -> helpers
var urgent_n := 0                # helpers to an urgent site
var built: Array = []            # [kind, placed clock, done clock, most builders seen]
var _watch := {}                 # building id -> [Building, most builders seen]


func _init(a) -> void:
	ai = a
	game = a.game
	team = a.team
	if args.has("buildstack:off%d" % team):
		on_switch = false
	if args.has("hallkeep:off%d" % team):
		hall_keep_on = false


func active() -> bool:
	return on_switch and ai.on and ai.difficulty >= 1 and not ai.peaceful


## The builders on a site now.
func builders(b: Building) -> Array:
	var o: Array = []
	for u in game.workers(team):
		if not u.dead and u.order == "build" and u.order_target == b:
			o.append(u)
	return o


func _rush_on() -> bool:
	if ai._defending():
		return true
	if ai.scout != null and ai.scout.verdict == "rush" and game.clock < 420.0:
		return true
	return ai.dfn != null and ai.dfn.alert


func _supply_blocked() -> bool:
	return game.supply_used(team) >= int(game.players[team]["cap"]) - 1


## The helpers a site wants, and whether it is urgent.
func want(b: Building) -> Array:
	var k := b.kind
	if not WANT.has(k):
		return [1, false]
	var n := int(WANT[k])
	var urgent := false
	if (k == "barracks" or k == "gate" or k == "cottage") and _rush_on():
		urgent = true
	elif k == "cottage" and _supply_blocked():
		urgent = true            # (supply blocked now: nothing trains till it stands)
	elif k == "farm" and ai._mine("farm").filter(func(f: Building) -> bool: return f.built and not f.barren()).size() < 2:
		urgent = true            # (the opening's second Farm and a lost Farm: the halls' labourers wait for its posts)
	elif k == "farm" and _hall_farmless(b):
		urgent = true            # (a new hall's first Farm)
	elif k == "town_hall" and ai.coach != null and ai._halls().filter(func(h: Building) -> bool: return h.built).size() < ai.coach.halls_need():
		urgent = true            # (HALLS ON TIME: behind the clock's halls)
	if urgent:
		n = int(URGENT_WANT.get(k, n + 1))
	return [n, urgent]


## A Farm site at a built hall with no built Farm of its own yet.
func _hall_farmless(b: Building) -> bool:
	var h: Building = null
	var hd := INF
	for x in ai._halls():
		if x.built and x.center().distance_to(b.center()) < hd:
			hd = x.center().distance_to(b.center())
			h = x
	if h == null:
		return false
	for f in ai._mine("farm"):
		if f.built and f.center().distance_to(h.center()) < hd + 64.0 and f.center().distance_to(h.center()) < 12.0 * Defs.TILE:
			return false
	return true


## Labourers that may be pulled: free (not building, fighting, scouting, escorting, held, fled, leading or on an errand).
func _free(u: Unit) -> bool:
	if u.dead or u.off_field or u.aboard:
		return false
	if u.order != "idle" and u.order != "gather":
		return false
	if ai._escort.has(u) or (ai.scout != null and ai.scout.is_scout(u)) or ai._held_worker(u) or ai._fled.has(u):
		return false
	if ai._on_errand(u):
		return false
	if u.order == "gather":
		if not (u.order_target is Building):
			return false
		var m: Building = u.order_target
		if m.kind == "powder_mill":
			return m.crew.size() > 1     # (a Mill's last hand stays: the powder)
		return m.kind == "farm"          # (only Farm hands: a Foundry's or a Church's crew keeps working)
	return true


## A labourer with no Farm post to go back to (more labourers than posts): he costs nothing at a site.
func _postless(u: Unit) -> bool:
	if u.order == "idle":
		return true
	if u.order == "gather" and u.order_target is Building:
		var f: Building = u.order_target
		return f.barren() if f.kind == "farm" else false
	return false


func tick() -> void:
	if not ai.on or ai.peaceful:
		return
	_watch_done()
	_note_sites()
	if not active():
		return
	var labs: Array = game.workers(team)
	if labs.is_empty():
		return
	var building_now := 0
	for u in labs:
		if u.order == "build":
			building_now += 1
	var room := maxi(2, int(BUSY_SHARE * labs.size())) - building_now
	var few := labs.size() < PULL_LABS and _early_careful()
	var left := SEND_MAX
	var sites: Array = []
	for b in game.buildings:
		if b.team != team or b.dead or b.built or not WANT.has(b.kind) or (b.kind != "gate" and Defs.BUILDINGS[b.kind].get("line", false)):
			continue
		if b.ghost or ai._unsafe(b.center()):
			continue             # (a site not begun yet: its footprint must be clear to start, helpers standing on it held it
			                     # a ghost until it was swept: the rush's Barracks never stood, Dune Sea v the Brood)
		sites.append(b)
	# urgent sites first, then the dearest
	sites.sort_custom(func(a: Building, c: Building) -> bool:
		var ua: bool = want(a)[1]
		var uc: bool = want(c)[1]
		if ua != uc:
			return ua
		return float(a.d["time"]) > float(c.d["time"]))
	var taken := {}
	for b in sites:
		if left <= 0:
			break
		var w: Array = want(b)
		var n_want: int = w[0]
		var urgent: bool = w[1]
		var on_it := builders(b)
		var id: int = b.get_instance_id()
		if on_it.is_empty() or on_it.size() >= n_want:
			continue             # (nobody on it yet: its own builder walks there first, _finish_sites keeps it worked)
		var work: float = (1.0 - b.progress) * b.build_time()          # labourer-seconds left
		var cand: Array = []
		for u in labs:
			if taken.has(u) or not _free(u):
				continue
			var walk: float = u.position.distance_to(b.center()) / maxf(1.0, u.speed) + (CARRY_PEN if u.carrying > 0 else 0.0)
			cand.append([walk, u])
		cand.sort_custom(func(a: Array, c: Array) -> bool: return a[0] < c[0])
		var n := on_it.size()
		for c in cand:
			if n >= n_want or left <= 0:
				break
			var walk: float = c[0]
			var u: Unit = c[1]
			var share: float = work / float(n + 1)            # what he would build there
			var idle := _postless(u)
			var ok := false
			if idle:
				ok = walk + IDLE_MARGIN < work / float(n)
			else:
				if room <= 0 or (few and not (urgent and _rush_on())):
					continue
				ok = walk < share * (URGENT_SHARE if urgent else WALK_SHARE) and walk < work / float(n)
			if not ok:
				continue
			u.give({"o": "build", "e": b})
			taken[u] = true
			n += 1
			left -= 1
			sent += 1
			sent_by[b.kind] = int(sent_by.get(b.kind, 0)) + 1
			if idle:
				sent_idle += 1
			else:
				room -= 1
			if urgent:
				urgent_n += 1
		if _watch.has(id):
			_watch[id][2] = maxi(int(_watch[id][2]), n)
	if left > 0 and room > 0 and _rush_on():
		_wall_help(labs, taken, mini(left, room))


## THE PALISADE BEFORE A SEEN PUSH: while a rush is read, a push is seen coming or we defend, the unfinished palisade pieces
## nobody works on get up to WALL_HELP more labourers from close by (each walks WALL_WALK s at most); done with his piece a
## labourer goes on to the next unworked site near him (Game.next_site), so the ring closes along. Not under fire.
const WALL_HELP := 4
const WALL_WALK := 8.0


func _wall_help(labs: Array, taken: Dictionary, n: int) -> void:
	var on_wall := 0
	for u in labs:
		if u.order == "build" and u.order_target is Building and (u.order_target as Building).kind == "wall":
			on_wall += 1
	if on_wall >= WALL_HELP * 2:
		return
	var pieces: Array = []
	for b in game.buildings:
		if b.team == team and not b.dead and not b.built and not b.ghost and b.kind == "wall" and not ai._unsafe(b.center()) and builders(b).is_empty():
			pieces.append(b)
	if pieces.is_empty():
		return
	var sent_now := 0
	for u in labs:
		if sent_now >= mini(n, WALL_HELP) or taken.has(u) or not _free(u):
			continue
		var best: Building = null
		var bd := INF
		for p in pieces:
			var dd: float = u.position.distance_to(p.center())
			if dd < bd:
				bd = dd
				best = p
		if best == null or bd / maxf(1.0, u.speed) > WALL_WALK:
			continue
		u.give({"o": "build", "e": best})
		pieces.erase(best)
		taken[u] = true
		sent_now += 1
		sent += 1
		urgent_n += 1
		sent_by["wall"] = int(sent_by.get("wall", 0)) + 1
		if pieces.is_empty():
			return


## Every site of a WANT kind is watched (both arms: the report's build times).
func _note_sites() -> void:
	for b in game.buildings:
		if b.team != team or b.dead or b.built or not WANT.has(b.kind):
			continue
		var id: int = b.get_instance_id()
		if not _watch.has(id):
			_watch[id] = [b, b.placed_clk, 0]
		_watch[id][2] = maxi(int(_watch[id][2]), builders(b).size())


## The sites watched: their build time when done (the report).
func _watch_done() -> void:
	for id in _watch.keys():
		var e: Array = _watch[id]
		var b = e[0]
		if not is_instance_valid(b) or b.dead:
			_watch.erase(id)
			continue
		if b.built:
			built.append([b.kind, snappedf(float(e[1]), 0.1), snappedf(game.clock, 0.1), int(e[2])])
			_watch.erase(id)


# ------------------------------------------------------------------ THE HALL STEP KEEPS ITS GOLD

## (crown-build-stack, part 2: why the Crown's labourers stall; docs/crown_build_stack.md) Against the Clockwork the Crown had
## 34 labourers at 8:00 to the Clockwork's 47 (docs/winrate_2026_11_17.md). Traced second by second
## (tools/crown_econ_trace.gd): from ~3:00 the main's 16 Farm posts are full and the labourers stop at 16-18 until the second
## hall's Farms stand (5:30-6:00); the opening's Town Hall step waited 90 s for its 400 gold, because the army clock
## (AICrownArmy, behind until 6:30 against the Clockwork's usual army) let a Musketeer's price per idle Barracks out of
## the held step every think (AICrown stage 2, step_release). So while the held step is the Town Hall, the main's Farm
## posts are full (one free or none) and no armed enemy is at our buildings, no rush is read and no push is seen, the
## step keeps its gold until HALL_KEEP_T; the stacked labourers then build it in a quarter of the time. Not against the
## Brood (the economy rules measured worse there: AICrownCoach rule 7). Switch `hallkeep:off` (and per team).
const HALL_KEEP_T := 330.0
var hall_keep_on := not args.has("hallkeep:off")
var hall_kept_t := 0.0          # (the report) seconds the hall step's gold was kept from the soldiers
var _hk_last := -1.0


func hall_keeps() -> bool:
	if not hall_keep_on or not ai.on or ai.difficulty < 1 or ai.peaceful or ai.bo_done:
		return false
	if game.clock > HALL_KEEP_T or ai.vb() != null or ai._foe_is("brood"):
		return false
	if ai.bo_i >= ai._bo_plan.size() or String(ai._bo_plan[ai.bo_i].get("do", "")) != "hall":
		return false
	if ai._defending() or (ai.dfn != null and ai.dfn.alert) or (ai.scout != null and ai.scout.verdict == "rush"):
		return false
	if ai.coach == null or ai.coach._threat_now() or ai.coach.free_posts() > 1:
		return false
	if _hk_last >= 0.0 and game.clock - _hk_last < 2.0:
		hall_kept_t += game.clock - _hk_last
	_hk_last = game.clock
	return true


func counters() -> Dictionary:
	return {"on": on_switch, "sent": sent, "sent_idle": sent_idle, "urgent": urgent_n, "by": sent_by, "built": built,
		"hall_keep": hall_keep_on, "hall_kept_t": snappedf(hall_kept_t, 0.1), "pending_kept": ai.pending_kept}
