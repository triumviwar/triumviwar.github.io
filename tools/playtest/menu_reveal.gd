extends RefCounted
## menu-groups (docs/menu_groups.md): the main menu's TUTORIAL, CAMPAIGN, SKIRMISH, WORLD WAR (under OFFLINE) and
## PLAY ONLINE, TOURNAMENTS (under ONLINE) are a level down. The playtest drivers look buttons up by name or label;
## before they look, this opens the group holding the one they want (only while the main menu is on screen), as a
## player would. Main.menu_reveal does the work.
##   const MenuReveal := preload("res://tools/playtest/menu_reveal.gd")
##   MenuReveal.reveal(<any node in the tree, or the root>, "CAMPAIGN")


static func reveal(from: Node, what: String) -> bool:
	if from == null or not from.is_inside_tree():
		return false
	var m := from.get_tree().root.get_node_or_null("Main")
	if m == null or not m.has_method("menu_reveal"):
		return false
	return m.menu_reveal(what)
