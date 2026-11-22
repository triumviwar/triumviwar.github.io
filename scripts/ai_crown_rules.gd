class_name AICrownRules
## THE CROWN'S RULE COUNTERS (crown-rule-cleanup, docs/crown_rule_cleanup.md): how often each coaching rule of the Crown
## computer ACTED in a match (not how often it was asked), read at the end into result.json "crown_ai" "rules" by
## tools/qa_match.gd. Read only: counting changes nothing in the play. One call at each rule's action point:
## `AICrownRules.fire(ai, "name")` (ai = the AICrown, or anything with set_meta).


static func fire(ai, name: String) -> void:
	if ai == null:
		return
	var d: Dictionary = ai.get_meta("rules", {})
	d[name] = int(d.get(name, 0)) + 1
	ai.set_meta("rules", d)


## `v` passed through, counted under `name` when true (for a rule that decides by returning true).
static func t(ai, name: String, v: bool) -> bool:
	if v:
		fire(ai, name)
	return v


## THE CLEANUP'S CUTS (crown-rule-cleanup, docs/crown_rule_cleanup.md): coaching rules switched OFF by default against one
## enemy faction, because the job measured them as harm there on top of the rules kept (the doc's log has each block).
## Each name is the rule's own study switch without ":off" (`-- crownarmy:off` and the cut do the same). The mirror keeps
## every rule. `-- crc:off` plays today's full stack as before the cleanup; `-- crc<name>:on` brings one rule back.
const CUT := {
	"clockwork": ["crownarmy", "armyfloor", "gunscoach", "gunsfirst", "line", "screen", "cavmicro", "defence", "hold"],
	"brood": [],
}

static var _args: PackedStringArray = OS.get_cmdline_user_args()


## Is rule `name` cut for the Crown computer `ai` (its enemy now)?
static func cut(ai, name: String) -> bool:
	if ai == null or ai.game == null or _args.has("crc:off") or _args.has("crc%s:on" % name):
		return false
	var f: int = ai._foe()
	if f < 0 or ai.game.faction_of(ai.team) != "crown":
		return false
	if ai.game.faction_of(f) == "crown":
		return AIWr1000CrownMirror.cut(name)      # (wr1000-crown-mirror: its mirror experiments, docs/wr1000_crown_mirror.md)
	return (CUT.get(ai.game.faction_of(f), []) as Array).has(name)
