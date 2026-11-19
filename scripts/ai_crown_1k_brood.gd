class_name AICrown1kBrood
extends RefCounted
## THE CROWN 1000, THE BROOD HALF (crown-1000-brood, the owner 2026-11-19 07:26: "The Crown's computer is the weak one... We
## need a complete job of 1000 crown games, every 10 games changing something to see if crown gets better";
## docs/crown_1000_brood.md). Blocks of 10 Hard OPTIMAL v Hard OPTIMAL games against the Brood to 20:00, one change a block,
## kept only when the block beat the best so far. Every change here runs only when the Crown computer faces a Brood
## (AICrown.vb()), so the sister job against the Clockwork (crown-1000-clockwork) merges beside it. Each change has its own
## switch: `-- c1kb<name>:on` / `:off`; `-- c1kb:off` plays the matchup as before this job. The changes KEPT are on by default
## (KEPT); the rest were measured and not kept (the doc says what each did).

const KEPT: Array[String] = ["lean"]   # (block 2, kept after block 5)

static var _args: PackedStringArray = OS.get_cmdline_user_args()


## Is change `name` on (against the Brood; the caller checks the matchup)?
static func on(name: String) -> bool:
	if _args.has("c1kb:off"):
		return false
	if _args.has("c1kb%s:off" % name):
		return false
	return KEPT.has(name) or _args.has("c1kb%s:on" % name)
