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
