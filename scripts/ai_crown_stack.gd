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
##    supply block's Cottage, a new hall's first Farm) with a longer leash;
##  - never to a site in danger (AI._unsafe), never the scout, the escort, a Mill's last hand, a labourer leading a horse or
##    on an errand, and not more than BUSY_SHARE of the labourers off the Farms at once.
## Done, a helper goes to the next unfinished site near him or back to a free post (Unit._build: game.next_site / free_site).
## Switch `buildstack:off` (both sides); `buildstack:off1` / `buildstack:off0` turn it off for team 1 / team 0 only (the
## mirror's measure).

const WANT := {
	"farm": 3, "cottage": 2, "barracks": 3, "gate": 3, "foundry": 3, "horse_breeder": 3, "powder_mill": 2,
	"armoury": 2, "church": 2, "town_hall": 4,
}
const URGENT_WANT := {"barracks": 4, "gate": 4, "cottage": 3, "farm": 4, "town_hall": 5}
const WALK_SHARE := 0.34         # a working helper's walk (s) under this share of the work he will do there
const URGENT_SHARE := 0.75       # (an urgent site's)
const IDLE_MARGIN := 2.0         # (s) an idle helper must arrive this long before the site would be done without him
const BUSY_SHARE := 0.25         # at most this share of the labourers building at once (idle helpers not counted)
const SEND_MAX := 4              # helpers sent a think, all sites together
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
	return game.supply_used(team) >= int(game.players[team]["cap"]) - 2


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
		urgent = true
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
	if u.order == "gather" and u.order_target is Building and (u.order_target as Building).kind == "powder_mill":
		var m: Building = u.order_target
		if m.crew.size() <= 1:
			return false         # (a Mill's last hand stays: the powder)
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
	var left := SEND_MAX
	var sites: Array = []
	for b in game.buildings:
		if b.team != team or b.dead or b.built or not WANT.has(b.kind) or Defs.BUILDINGS[b.kind].get("line", false):
			continue
		if ai._unsafe(b.center()):
			continue
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
				if room <= 0:
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


func counters() -> Dictionary:
	return {"on": on_switch, "sent": sent, "sent_idle": sent_idle, "urgent": urgent_n, "by": sent_by, "built": built}
