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


# ------------------------------------------------------------------ the cleaned set (crown-rule-cleanup)

## THE CLEANED SET (crown-rule-cleanup, docs/crown_rule_cleanup.md): the coaching rule groups measured as not helping on top
## of the ones kept, by the Crown computer's enemy, are left out. Each entry is the study switch that turned that rule off
## when it was measured (the switch still works on its own, in every matchup). The mirror keeps the whole stack (its rules
## cannot be measured one side at a time: both Crowns get them). `-- crclean:off` plays today's whole stack everywhere.
const DROP := {
	"brood": ["labsfirst:off", "hallsontime:off", "farmfirst:off", "cbaecon:off",                          # econ
		"crownarmy:off", "armyfloor:off", "cba:off", "cvb:off", "screenfirst:off",                         # army
		"gunscoach:off", "gunsfirst:off", "line:off", "screen:off", "cavmicro:off", "defence:off",        # fight
		"hold:off"],                                                                                      # home
	"clockwork": ["crownarmy:off", "armyfloor:off", "screenfirst:off",                                     # army (not cvc dry)
		"gunscoach:off", "gunsfirst:off", "line:off", "screen:off", "cavmicro:off", "defence:off",        # fight
		"hold:off"],                                                                                      # home
}

static var _args: PackedStringArray = OS.get_cmdline_user_args()
## (tests of a single rule: true plays today's whole stack, as `-- crclean:off`)
static var whole := false


## Is the rule whose study switch is `sw` (e.g. "line:off") off for the Crown computer `ai`: the switch given, or left out
## of the cleaned set against `ai`'s enemy? (false while the enemy is not known yet)
static func dropped(ai, sw: String) -> bool:
	if _args.has(sw):
		return true
	if whole or _args.has("crclean:off") or ai == null:
		return false
	var f := foe_faction(ai)
	return f != "" and (DROP.get(f, []) as Array).has(sw)


## The enemy's faction of a Crown computer (cached once known).
static func foe_faction(ai) -> String:
	if ai.has_meta("crc_foe"):
		return String(ai.get_meta("crc_foe"))
	var g = ai.get("game")
	if g == null or not ai.has_method("_foe"):
		return ""
	var fo: int = ai._foe()
	if fo < 0:
		return ""
	var f := String(g.faction_of(fo))
	ai.set_meta("crc_foe", f)
	return f
