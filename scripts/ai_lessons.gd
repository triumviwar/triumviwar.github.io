class_name AILessons
## THE LESSONS OF THE BATTLE TESTS IN THE MAIN COMPUTERS (job ai-lessons, docs/ai_lessons.md). The battle matrices
## (docs/battle_matrix.md, docs/battle_matrix_all.md) and the micro jobs (crown-micro, crown-micro-2, clockwork-micro,
## brood-micro) found what beats what and where the computers fight badly. This file holds the switches of the lessons
## put into the computers, one each:
##   dragoonwave  (a fix) a Dragoon of a wave getting off his horse to fire, or back on, stays in the wave's count: the
##                wave no longer ends and goes home when its Dragoons dismount (AI._army)
##   riderpull    (a fix) the screen's riders pull back from in front of the muskets whenever the wave's muskets are in a
##                fight, not only while the line's state says so (AICrownScreen._screen)
##   cbcomp / ckcomp / kccomp / kbcomp / bcomp: the army mixes by the counter tables (see each file's own notes)
## Switches: `-- ail:off` all off; `-- ail<name>:off` one off; `-- ail<name>:on` one on that is off by default.
const ON_BY_DEFAULT := ["dragoonwave", "riderpull"]

static var _args: PackedStringArray = OS.get_cmdline_user_args()


static func on(name: String) -> bool:
	if _args.has("ail:off") or _args.has("ail%s:off" % name):
		return false
	if _args.has("ail%s:on" % name):
		return true
	return ON_BY_DEFAULT.has(name)


## A Dragoon, mounted or on foot after getting off to fire (his own horse still close by), or getting on or off.
static func dragoon(u: Unit) -> bool:
	if u.kind == "dragoon":
		return true
	return u.kind == "musketeer" and u.auto_mount and u.steed != null and is_instance_valid(u.steed) and not u.steed.dead \
			and u.steed.position.distance_to(u.position) < Unit.STEED_FAR * Defs.TILE
