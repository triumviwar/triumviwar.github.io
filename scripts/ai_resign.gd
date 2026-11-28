class_name AIResign
## When a computer says "gg": its position is hopeless, judged from what it HAS and what it has
## SEEN (no cheating: the enemy army is what its units can see, remembered a little while).
## SURRENDER (the owner 2026-11-28: "I want the ai to surrender more, currently it basically doesn't. Nobody plays until
## all buildings are destroyed"): it says "gg" and LEAVES the match LEAVE_AFTER seconds later, as a person would; the
## player's "gg" in that time ends it at once ("gg wp"). It used to wait for the player's gg and play on without one.
## "outclassed" (new) gives up a beaten-down side that still has a hall and a Barracks: it has lost halls or most of its
## workers, its army is a small share of the one it sees, and it has no bank to turn it round.
## Never in a campaign mission or a lesson (their sides are written), never between computers only (studies).
## Every number is a constant here, to tune.
## The rule is a pure function of a "view" (AI.gg_view builds it from the game), so it is easy to test.
##
## view: {clock, halls, halls_peak, workers, workers_peak, army (own value), enemy_army (seen),
##        production (finished buildings that train soldiers), gold, hall_cost}

const MIN_CLOCK := 300.0         # never resign before 5:00 ...
const SUSTAIN := 45.0            # the position must be hopeless this long, without a break (was 60)
const SUSTAIN_WIPED := 15.0      # ... except with no hall and no workers at all
const ARMY_FRAC := 0.10          # "no army": worth at most this share of the enemy army seen
const ARMY_FRAC_NO_HALL := 0.5   # with no hall: at most this share (it cannot rebuild by the hall either)
const MIN_ENEMY_ARMY := 300.0    # an enemy army seen smaller than this never makes it hopeless
const WORKER_FRAC := 0.5         # "losing workers": at most this share of its peak count
const BANK := 400                # gold in hand that still lets it rebuild an army (with a way to spend it)
const MEMORY_SECS := 60.0        # a seen enemy army is forgotten over this long once out of sight
const REPLY_WINDOW := 60.0       # a player's gg counts this long after the computer's
const REPEAT_AFTER := 240.0      # a second gg, at the earliest, this long after the first
const MAX_SAYS := 2              # at most two gg in a match (since it leaves after the first, in practice one)
const LEAVE_AFTER := 10.0        # it leaves this long after its gg (the player's gg ends it at once)
const OUTCLASS_CLOCK := 420.0    # "outclassed" only from 7:00
const OUTCLASS_FRAC := 0.25      # its army at most this share of the enemy army seen
const OUTCLASS_ENEMY := 800.0    # ... and the enemy army seen at least this big
const OUTCLASS_WORKERS := 0.6    # "beaten down": a hall lost, or workers at most this share of its peak
const OUTCLASS_BANK := 700       # gold in hand that still lets it fight on
const CHECK_EVERY := 3.0         # the rule is looked at this often (game seconds)


## "" (not hopeless) or why: "wiped" (no hall, no workers, no army), "no_hall", "broken".
static func verdict(v: Dictionary) -> String:
	var halls := int(v["halls"])
	var workers := int(v["workers"])
	var army := float(v["army"])
	var enemy := float(v["enemy_army"])
	if halls == 0 and workers == 0 and army < MIN_ENEMY_ARMY:
		return "wiped"
	if float(v["clock"]) < MIN_CLOCK or enemy < MIN_ENEMY_ARMY:
		return ""
	var gold := int(v["gold"])
	var production := int(v["production"])
	var income := halls > 0 and workers > 0
	var can_rebuild := (production > 0 and income) or (gold >= BANK and (production > 0 or income))
	if halls == 0 and not (workers > 0 and gold >= int(v["hall_cost"])) and army <= ARMY_FRAC_NO_HALL * enemy:
		return "no_hall"
	var losing := halls < int(v["halls_peak"]) or float(workers) <= WORKER_FRAC * float(v["workers_peak"])
	if army <= ARMY_FRAC * enemy and not can_rebuild and losing:
		return "broken"
	var beaten := halls < int(v["halls_peak"]) or float(workers) <= OUTCLASS_WORKERS * float(v["workers_peak"])
	if float(v["clock"]) >= OUTCLASS_CLOCK and enemy >= OUTCLASS_ENEMY and army <= OUTCLASS_FRAC * enemy and beaten and gold < OUTCLASS_BANK:
		return "outclassed"
	return ""


static func sustain_for(reason: String) -> float:
	return SUSTAIN_WIPED if reason == "wiped" else SUSTAIN
