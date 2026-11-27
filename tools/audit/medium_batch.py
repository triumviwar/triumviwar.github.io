#!/usr/bin/env python3
"""The sprite audit's MEDIUM findings turned into ChatGPT requests like the HIGH ones (R1-R11 in
docs/sprite_hallucination_audit.md): reference pictures in docs/redraw_refs/sm<NN>_*/ (tools/audit/make_refs.py's look)
and one prompt each, printed as JSON strings to <out>/M<NN>.js (one request at a time, at most 3 pictures).

    python3 tools/audit/medium_batch.py /home/claude/sa_prompts
"""
import json
import os
import sys

sys.path.insert(0, os.path.dirname(__file__))
import make_refs as mr  # noqa: E402

COMMON = ("Every frame the same size, the feet on one steady ground line. The game draws west by mirroring east. "
          "AVOID: %s extra or missing limbs, legs, tails, heads or weapons, a different outfit or colour scheme from "
          "the references, floating or detached tools and weapons, two copies of a weapon, a different pixel scale, any "
          "text. Keep every pure bright red area pure bright red (it is the team colour, recoloured by the game). Use "
          "the reference images only to understand the pose, the figure and the style: do not copy their enlargement, "
          "their labels (such as 'e3'), their lighter cell boxes or the small red ground ticks into the answer. Pixel "
          "art for a 16th to 18th century European gunpowder RTS, three-quarter top-down view like a classic RTS. Hard "
          "square pixels with NO anti-aliasing, no blur, no gradients, no glow, no dithering noise; a flat limited "
          "palette with painted soft shading in two or three tones per colour; a dark near-black outline of the same "
          "weight (one game pixel) around every figure; the same pixel scale and palette as the references. "
          "Background: one flat solid dark navy colour, exactly #001630 (RGB 0, 22, 48), everywhere, with NOTHING "
          "else on it: no title, no labels, no numbers, no grid or cell lines, no ground tile, no cast shadow, no "
          "frame borders. Layout: ONE single row (%s only), %d frames left to right, on an image of 1536 by 640 "
          "pixels; every figure the same size, standing on the same invisible ground line, at least 20 px of empty "
          "navy between neighbouring figures, no figure touching, overlapping or cut by the image edge.")

CUI = "the Cuirassier (a heavy cavalryman in a steel morion helmet and breastplate over a white shirt with pure red sleeves and breeches, on a dark grey horse with a pure red saddle cloth)"
HOR = "the Horseman (a light cavalryman in a white shirt and a brown wide-brimmed hat with a pure red plume, on a dark grey horse with a pure red saddle cloth)"
ADR = "the Armoured Dragoon (a mounted musketeer in a steel helmet and a pure red coat, a carbine across his back, on a dark grey horse)"
MUS = "the Musketeer (a soldier in a pure red coat and a dark hat, a long musket with a bayonet)"
GUA = "the Guardsman (a musketeer in a steel morion helmet and breastplate over a pure red coat, a long musket with a bayonet)"

# id, unit, strip, frames, who, what (the action and view), view words for the layout, avoid, refs [(name, [(unit, strip)])]
JOBS = [
    (70, "cuirassier", "attack_e", 4, CUI, "striking with his sabre, horse and rider in a side view facing right (east), 4 frames: 1 sabre raised over his head; 2 the cut coming down in front of the horse's neck; 3 the follow-through low; 4 recovering. ONE sabre in his right hand in every frame", "the east view: facing right", "a second blade, a sabre raised and thrust at once,",
     [("1_current_attack_e.png", [("cuirassier", "attack_e")]), ("2_walk_e_model.png", [("cuirassier", "walk_e")])]),
    (71, "cuirassier", "attack_se", 4, CUI, "striking with his sabre, horse and rider in a three-quarter view toward the lower right (south-east), 4 frames: 1 sabre raised over his head; 2 the cut coming down past the horse's neck; 3 the follow-through low; 4 recovering. ONE sabre in his right hand in every frame", "the south-east view: three-quarter toward the lower right", "a second blade, a sabre raised and thrust at once,",
     [("1_current_attack_se.png", [("cuirassier", "attack_se")]), ("2_walk_se_model.png", [("cuirassier", "walk_se")])]),
    (73, "cuirassier", "walk_ne", 8, CUI, "galloping away toward the upper right, seen three-quarter from behind (the horse's rump toward the lower left, its head toward the upper right), 8 frames, a seamless gallop loop, the same angle in every frame", "the north-east view: three-quarter from behind, toward the upper right", "a straight rear view, a side profile, the angle drifting,",
     [("1_walk_n_e_model.png", [("cuirassier", "walk_n"), ("cuirassier", "walk_e")]), ("2_attack_ne_new.png", [("cuirassier", "attack_ne")])]),
    (74, "cuirassier", "walk_s", 8, CUI, "galloping straight toward the viewer (the horse's chest and head toward us), 8 frames, a seamless gallop loop, the same straight front angle in every frame", "the south view: straight toward the viewer", "a three-quarter angle, the angle drifting between frames,",
     [("1_current_walk_s.png", [("cuirassier", "walk_s")]), ("2_walk_se_e_model.png", [("cuirassier", "walk_se"), ("cuirassier", "walk_e")])]),
    (75, "cuirassier", "walk_se", 8, CUI, "galloping three-quarter toward the lower right (south-east), 8 frames, a seamless gallop loop, the same three-quarter angle in every frame", "the south-east view: three-quarter toward the lower right", "a straight front view, the angle drifting between frames,",
     [("1_current_walk_se.png", [("cuirassier", "walk_se")]), ("2_walk_e_model.png", [("cuirassier", "walk_e")])]),
    (79, "horseman", "attack_n", 4, HOR, "striking with his sabre while riding AWAY from the viewer, seen from behind (the horse's rump toward us), 4 frames: 1 sabre raised over his right shoulder; 2 the cut coming down to the right of the horse's neck; 3 the follow-through low at the horse's right side; 4 recovering. ONE steel sabre (grey steel blade, not red) in his RIGHT hand in every frame", "the north view: seen from behind", "a red blade, the sabre in the left hand, the rider's face,",
     [("1_current_attack_n.png", [("horseman", "attack_n")]), ("2_attack_e_model.png", [("horseman", "attack_e")]), ("3_walk_n_back_view.png", [("horseman", "walk_n")])]),
    (80, "horseman", "attack_ne", 4, HOR, "striking with his sabre while riding away toward the upper right, seen three-quarter from behind, 4 frames: 1 sabre raised over his right shoulder; 2 the cut coming down past the horse's right shoulder; 3 the follow-through low; 4 recovering. ONE steel sabre in his right hand, the horse whole with four legs at the same angle in every frame", "the north-east view: three-quarter from behind, toward the upper right", "a side profile, missing horse legs, the horse turning,",
     [("1_current_attack_ne.png", [("horseman", "attack_ne")]), ("2_attack_e_model.png", [("horseman", "attack_e")]), ("3_walk_ne_new.png", [("horseman", "walk_ne")])]),
    (82, "horseman", "walk_s", 10, HOR, "galloping straight toward the viewer (the horse's chest and head toward us), 10 frames, a seamless gallop loop, the same straight front angle in every frame", "the south view: straight toward the viewer", "a three-quarter angle, the angle drifting between frames,",
     [("1_current_walk_s.png", [("horseman", "walk_s")]), ("2_walk_se_e_model.png", [("horseman", "walk_se"), ("horseman", "walk_e")])]),
    (76, "dragoon_armoured", "idle_e", 2, ADR, "standing still in a side view facing right (east), 2 frames of a quiet idle: frame 2 differs only by the horse lowering its head a little. The same side angle in both frames", "the east view: facing right", "the horse turning toward the viewer,",
     [("1_current_idle_e.png", [("dragoon_armoured", "idle_e")]), ("2_walk_e_model.png", [("dragoon_armoured", "walk_e")])]),
    (77, "dragoon_armoured", "walk_n", 10, ADR, "galloping straight AWAY from the viewer, seen from behind (the horse's rump and tail toward us), 10 frames, a seamless gallop loop, the same straight rear angle in every frame", "the north view: seen from behind", "a three-quarter angle, the angle drifting between frames, the rider's face,",
     [("1_current_walk_n.png", [("dragoon_armoured", "walk_n")]), ("2_walk_ne_new.png", [("dragoon_armoured", "walk_ne")])]),
    (63, "musketeer", "idle_s", 2, MUS, "standing still facing the viewer, the musket held upright at his side with its butt on the ground, 2 frames of a quiet breathing idle: frame 2 differs only by a slight rise of the shoulders. The whole musket visible in both frames", "the south view: facing the viewer", "the musket vanishing or shortening between frames,",
     [("1_current_idle_s.png", [("musketeer", "idle_s")]), ("2_idle_se_e_model.png", [("musketeer", "idle_se"), ("musketeer", "idle_e")])]),
    (64, "musketeer", "melee_n", 3, MUS, "thrusting with his bayonet AWAY from the viewer, seen from behind, 3 frames: 1 musket drawn back at the hip, 2 the thrust forward and up, the bayonet ahead of him, 3 recovering. The musket and bayonet clearly visible in every frame, held in both hands", "the north view: seen from behind", "no musket, an empty-handed jab,",
     [("1_current_melee_n.png", [("musketeer", "melee_n")]), ("2_melee_e_model.png", [("musketeer", "melee_e")]), ("3_walk_n_back_view.png", [("musketeer", "walk_n")])]),
    (65, "musketeer", "reload_n", 3, MUS, "reloading his musket, seen from behind, 3 frames: 1 the musket upright before him, butt on the ground, tearing a cartridge; 2 ramming with the ramrod down the barrel; 3 lifting the musket. The musket clearly visible above his shoulder in every frame", "the north view: seen from behind", "the musket hidden or missing,",
     [("1_current_reload_n.png", [("musketeer", "reload_n")]), ("2_reload_e_s_model.png", [("musketeer", "reload_e"), ("musketeer", "reload_s")]), ("3_walk_n_back_view.png", [("musketeer", "walk_n")])]),
    (67, "musketeer_armoured", "melee_n", 3, GUA, "thrusting with his bayonet AWAY from the viewer, seen from behind, 3 frames: 1 musket drawn back at the hip, 2 the thrust forward and up, the bayonet ahead of him, 3 recovering. The musket and bayonet clearly visible in every frame, held in both hands", "the north view: seen from behind", "no musket, an empty-handed jab,",
     [("1_current_melee_n.png", [("musketeer_armoured", "melee_n")]), ("2_melee_e_model.png", [("musketeer_armoured", "melee_e")]), ("3_walk_n_back_view.png", [("musketeer_armoured", "walk_n")])]),
    (68, "musketeer_armoured", "walk_s", 6, GUA, "marching toward the viewer, the musket on his shoulder, 6 frames, a seamless walk loop: left foot forward, passing, right foot forward, passing, and back. Two separate legs and two boots in every frame", "the south view: walking toward the viewer", "one central leg, a different helmet,",
     [("1_current_walk_s.png", [("musketeer_armoured", "walk_s")]), ("2_walk_se_e_model.png", [("musketeer_armoured", "walk_se"), ("musketeer_armoured", "walk_e")])]),
]

RAP = "the Raptor (a slim green reptilian raptor with pure red spines along its back and head, a long tail, two clawed legs)"
BRU = "the Brute (a heavy squat armoured reptile with a bony shell and a frill, olive green with pure red spines)"
TYR = "the Tyrant Sire (a huge crouched green tyrannosaur with pure red spines along its back, a big head, small arms, a long heavy tail)"
TCH = "the Tyrant Challenger (a big green tyrannosaur-like reptile with pure red spines, a big head and a long tail)"
HAT = "the Hatchlings (a little flock of three small green reptile hatchlings with leathery bat-like wings and pure red spines, flying together)"
STC = "the Storm Challenger (a green pterosaur with leathery wings, a long beak and a tall pure red crest, pure red spines along the wing edges)"
LOOK = {"raptor": "creature, its colours and proportions", "brute": "creature, its colours and proportions",
        "tyrannosaur": "creature, its colours and proportions", "tyrant_challenger": "creature, its colours and proportions",
        "hatchlings": "creatures, their colours and proportions", "storm_challenger": "creature, its colours and proportions"}

JOBS += [
    (21, "raptor", "death_e", 5, RAP, "dying, in a side view facing right (east), 5 frames that follow on one from the other: 1 struck, rearing back; 2 falling sideways; 3 hitting the ground on its side; 4 lying on its side, legs folding; 5 still, lying on its side. It falls ONCE and stays down, the same side of the body toward us in every frame", "the east view: facing right", "the body flipping over between frames, lying on its back with legs up,",
     [("1_current_death_e.png", [("raptor", "death_e")]), ("2_walk_e_model.png", [("raptor", "walk_e")])]),
    (13, "brute", "attack_e", 5, BRU, "attacking in a side view facing right (east), 5 frames: 1 head lowered, gathering; 2 lunging forward; 3 the head-butt, frill flared; 4 the impact; 5 pulling back to stand. The same creature and shell in every frame, all four feet on the ground", "the east view: facing right", "a rearing pose, a pale belly patch, a different shell or frill between frames,",
     [("1_current_attack_e.png", [("brute", "attack_e")]), ("2_walk_e_model.png", [("brute", "walk_e")])]),
    (24, "tyrannosaur", "death_se", 6, TYR, "dying, in a three-quarter view toward the lower right (south-east), 6 frames: 1 the crouched pose of the walk, struck, head thrown up; 2 staggering; 3 the legs buckling; 4 crashing down onto its side; 5 lying, the tail falling; 6 still on the ground. It is the SAME crouched creature as the walk from the first frame, its head always visible", "the south-east view: three-quarter toward the lower right", "an upright kaiju pose, a thinner smaller body in the first frames, a missing head,",
     [("1_current_death_se.png", [("tyrannosaur", "death_se")]), ("2_walk_se_model.png", [("tyrannosaur", "walk_se")])]),
    (25, "tyrant_challenger", "death_se", 5, TCH, "dying, in a three-quarter view toward the lower right (south-east), 5 frames: 1 struck, rearing; 2 staggering; 3 falling onto its side; 4 lying, the tail and legs settling; 5 still. ONE head and neck, two legs and one tail in every frame", "the south-east view: three-quarter toward the lower right", "a limb sticking up from the back, a second neck or head,",
     [("1_current_death_se.png", [("tyrant_challenger", "death_se")]), ("2_walk_se_model.png", [("tyrant_challenger", "walk_se")])]),
    (16, "hatchlings", "walk_se", 6, HAT, "flying together toward the lower right (south-east), 6 frames, a seamless wing-beat loop: wings up, half down, fully down, half up, and back. Every hatchling whole in every frame, with exactly two wings, a tail and two hind legs each", "the south-east view: flying toward the lower right", "a truncated body, a missing wing or tail, a third wing,",
     [("1_current_walk_se.png", [("hatchlings", "walk_se")]), ("2_walk_e_model.png", [("hatchlings", "walk_e")])]),
    (23, "storm_challenger", "walk_se", 6, STC, "flying toward the lower right (south-east), 6 frames, a seamless wing-beat loop: wings up, half down, fully down, half up, and back. The whole creature in every frame with exactly two wings", "the south-east view: flying toward the lower right", "a truncated body, a missing wing, a third wing, dark patches between wing and neck,",
     [("1_current_walk_se.png", [("storm_challenger", "walk_se")]), ("2_walk_e_model.png", [("storm_challenger", "walk_e")])]),
    (22, "storm_challenger", "attack_n", 6, STC, "attacking while flying AWAY from the viewer, seen from behind and above (its back and tail toward us, its beak pointing UP the image, away from us), 6 frames: 1 gliding; 2 wings raised; 3 diving forward and up the image; 4 the beak strike; 5 pulling up; 6 gliding again. The beak points up the image in EVERY frame", "the north view: flying away, seen from behind", "the beak pointing down toward the viewer, the head flipping round between frames,",
     [("1_current_attack_n.png", [("storm_challenger", "attack_n")]), ("2_walk_n_model.png", [("storm_challenger", "walk_n")])]),
]

MIS = "the Missionary (a priest in a long black cassock and a black wide-brimmed hat, a pure red stole hanging from his shoulders, a brown leather satchel at his hip)"
LOOK["missionary"] = "man, outfit and colours"
JOBS += [
    (90, "missionary", "walk_n", 4, MIS, "walking AWAY from the viewer, seen from BEHIND: we see the back of his hat, the back of his cassock and the satchel strap across his back, NO face, NO front of the stole; 4 frames, a seamless walk loop: left foot forward, passing, right foot forward, passing", "the north view: seen from behind", "his face, the front of his stole, a front view,",
     [("1_current_walk_n.png", [("missionary", "walk_n")]), ("2_walk_e_s_model.png", [("missionary", "walk_e"), ("missionary", "walk_s")])]),
    (91, "missionary", "idle_n", 2, MIS, "standing still with his BACK to the viewer, seen from BEHIND: the back of his hat, the back of his cassock, the satchel strap across his back, NO face; 2 frames of a quiet idle: frame 2 differs only by a slight rise of the shoulders", "the north view: seen from behind", "his face, the front of his stole, a front view,",
     [("1_current_idle_n.png", [("missionary", "idle_n")]), ("2_idle_s_e_model.png", [("missionary", "idle_s"), ("missionary", "idle_e")])]),
]

OFF = "the Officer on foot (a brown tricorne hat with a small pure red plume, a white coat with pure red cuffs and sash, pure red breeches, brown boots, a flintlock pistol in his right hand, a sabre at his left hip)"
_OFF_VIEW = {"s": ("facing the viewer (toward the bottom of the image), his face and chest toward us, the pistol held straight out TOWARD the viewer so it is seen end-on, foreshortened", "the south view: facing the viewer"),
             "se": ("facing three-quarter toward the lower right, the pistol arm pointing down-right toward the lower right corner", "the south-east view: three-quarter toward the lower right"),
             "ne": ("facing three-quarter AWAY toward the upper right, his back half turned to us, the pistol arm pointing up-right toward the upper right corner", "the north-east view: three-quarter from behind, toward the upper right"),
             "n": ("facing straight AWAY from the viewer (toward the top of the image), his back to us, NO face, the pistol arm pointing up the image away from us", "the north view: seen from behind")}
for _n, _d in ((92, "s"), (93, "se"), (94, "ne"), (95, "n")):
    JOBS.append((_n, "dismounted", "aimfire_" + _d, 3, OFF, "%s; 3 frames: 1 AIMING, the arm raised and steady; 2 FIRING, a small bright muzzle flash and a puff of white smoke at the pistol's mouth; 3 the recoil, the arm kicked up a little, the smoke drifting. The SAME facing in all three frames, ONE pistol in ONE hand" % _OFF_VIEW[_d][0], _OFF_VIEW[_d][1], "a side profile facing right, a second pistol, the pistol in the left hand,",
                 [("1_aim_fire_e_pose.png", [("dismounted", "aim_e"), ("dismounted", "fire_e")]), ("2_walk_%s_view.png" % _d, [("dismounted", "walk_" + _d)])]))
LOOK["dismounted"] = "man, outfit and colours"

_OFF_MEL = {"s": "facing the viewer (toward the bottom of the image), his face and chest toward us, the cut coming down toward the viewer",
            "se": "facing three-quarter toward the lower right, the cut coming down toward the lower right",
            "ne": "facing three-quarter AWAY toward the upper right, his back half turned to us, the cut going up-right away from us",
            "n": "facing straight AWAY from the viewer (toward the top of the image), his back to us, NO face, the cut going up the image away from us"}
for _n, _d in ((96, "s"), (97, "se"), (98, "ne"), (99, "n")):
    JOBS.append((_n, "dismounted", "melee_" + _d, 4, OFF, "slashing with his sabre in his right hand (the pistol put away), %s; 4 frames: 1 the sabre raised over his right shoulder; 2 the cut coming down, a short pale swoosh along the blade's path; 3 the follow-through low across his body; 4 recovering, the sabre back up. The SAME facing in all four frames, ONE sabre" % _OFF_MEL[_d], _OFF_VIEW[_d][1], "a side profile facing right, the body turning between frames, a second blade,",
                 [("1_melee_e_pose.png", [("dismounted", "melee_e")]), ("2_walk_%s_view.png" % _d, [("dismounted", "walk_" + _d)])]))

NET = "the Netter (a Clockwork automaton: a brass barrel body with pure red bands and a dark glass window, standing on four short jointed brass and red legs, a brass net launcher on top)"
LOOK["netter"] = "machine, its colours and proportions"
_NS = "seen from the FRONT, end-on: the barrel points straight at the viewer so we see its ROUND front end (a big brass disc with a red rim) in the middle, the four legs spread round it, the net launcher's round mouth on top facing us, like reference 2 but from the front instead of the back"
JOBS += [
    (100, "netter", "walk_s", 8, NET, "walking toward the viewer, %s; 8 frames, a seamless walk loop, the legs stepping in turn, the body bobbing a little" % _NS, "the south view: walking toward the viewer", "a side view of the barrel, the barrel lying crosswise, its long side toward us,",
     [("1_current_walk_s.png", [("netter", "walk_s")]), ("2_walk_n_endon.png", [("netter", "walk_n")]), ("3_walk_se_model.png", [("netter", "walk_se")])]),
    (101, "netter", "attack_s", 6, NET, "firing its net toward the viewer, %s; 6 frames: 1 standing braced; 2 the launcher tilting down at us; 3 the recoil, a puff of steam; 4 the launcher back up; 5 a click of the reloading net; 6 standing braced" % _NS, "the south view: facing the viewer", "a side view of the barrel, the barrel lying crosswise, its long side toward us,",
     [("1_current_attack_s.png", [("netter", "attack_s")]), ("2_walk_n_endon.png", [("netter", "walk_n")]), ("3_attack_se_model.png", [("netter", "attack_se")])]),
    (102, "netter", "death_s", 5, NET, "breaking down, %s; 5 frames: 1 struck, sparks; 2 a leg buckling, the body tilting; 3 collapsing, a puff of steam; 4 lying broken, a band sprung loose; 5 still, a wisp of steam" % _NS, "the south view: facing the viewer", "a side view of the barrel, the barrel lying crosswise, its long side toward us,",
     [("1_current_death_s.png", [("netter", "death_s")]), ("2_walk_n_endon.png", [("netter", "walk_n")]), ("3_death_se_model.png", [("netter", "death_se")])]),
]

_OFF_DIE = {"s": "facing the viewer (toward the bottom of the image), his face toward us, falling backward away from the viewer",
            "se": "facing three-quarter toward the lower right, falling backward toward the upper left",
            "ne": "facing three-quarter AWAY toward the upper right, his back half turned to us, falling forward toward the upper right",
            "n": "facing straight AWAY from the viewer (toward the top of the image), his back to us, NO face, falling forward up the image away from us"}
for _n, _d in ((103, "s"), (104, "se"), (105, "ne"), (106, "n")):
    JOBS.append((_n, "dismounted", "death_" + _d, 5, OFF, "shot and dying, %s; 5 frames: 1 hit, staggering, the pistol dropping; 2 the knees buckling; 3 falling; 4 hitting the ground; 5 lying still, the pistol and his tricorne on the ground beside him. The SAME facing as frame 1 throughout" % _OFF_DIE[_d], _OFF_VIEW[_d][1], "a side profile facing right, falling sideways to the right, a second pistol,",
                 [("1_death_e_pose.png", [("dismounted", "death_e")]), ("2_walk_%s_view.png" % _d, [("dismounted", "walk_" + _d)])]))

_MIS_DIE = {"se": ("facing three-quarter toward the lower right, falling backward toward the upper left", "the south-east view: three-quarter toward the lower right", 4),
            "e": ("facing right (east) in profile, falling backward to the left", "the east view: facing right", 3)}
for _n, _d in ((107, "se"), (108, "e")):
    _v = _MIS_DIE[_d]
    JOBS.append((_n, "missionary", "death_" + _d, _v[2], MIS, "struck down and dying, %s; %d frames in order: he staggers, his knees buckle, he falls%s, and the LAST frame shows him lying still full length on the ground, his hat beside him. He stays the SAME size in every frame, nothing tangled" % (_v[0], _v[2], "" if _v[2] == 3 else ", he hits the ground"), _v[1], "a tangled shape, a smaller or bigger man between frames, standing up again after falling,",
                 [("1_current_death_%s.png" % _d, [("missionary", "death_" + _d)]), ("2_walk_%s_view.png" % _d, [("missionary", "walk_" + _d)])]))

MMIS = "the mounted Missionary (a priest in a long black cassock and a black wide-brimmed hat, a pure red stole, a brown leather satchel, carrying a tall wooden processional cross upright in his right hand) on a grey horse with a pure red saddle cloth"
LOOK["missionary_mounted"] = "man, horse, outfit and colours"
JOBS += [
    (109, "missionary_mounted", "walk_e", 9, MMIS, "riding to the right (east), the horse seen side-on in profile walking right; 9 frames, a seamless walk loop of the horse's legs; the processional cross held upright in EVERY frame, the same cross, never missing", "the east view: facing right", "a missing or half-drawn cross, a loose dark fragment beside the horse,",
     [("1_current_walk_e.png", [("missionary_mounted", "walk_e")]), ("2_idle_e_model.png", [("missionary_mounted", "idle_e")])]),
    (110, "missionary_mounted", "walk_s", 9, MMIS, "riding TOWARD the viewer (toward the bottom of the image): the horse seen head-on from the front, its head and chest toward us, its legs stepping toward us, the rider's face and the front of his stole toward us, like reference 2 but walking; 9 frames, a seamless walk loop; the processional cross held upright in every frame", "the south view: coming toward the viewer", "a side view of the horse, the horse walking to the right,",
     [("1_current_walk_s.png", [("missionary_mounted", "walk_s")]), ("2_idle_s_front.png", [("missionary_mounted", "idle_s")]), ("3_walk_n_model.png", [("missionary_mounted", "walk_n")])]),
]

MOR = "the Mortar team (two crewmen in pure red coats, grey breeches, brown boots and steel morion helmets, with a short black-iron and bronze mortar on its wooden bed, carried on a small two-wheeled cart pulled by a GREY horse)"
LOOK["mortar"] = "men, horse, cart, mortar and colours"
_MOR_V = {"s": ("facing the viewer, the cart and horse pointing toward the bottom of the image", "the south view: facing the viewer"),
          "se": ("three-quarter toward the lower right, the horse in front at the lower right", "the south-east view: three-quarter toward the lower right"),
          "e": ("side-on, the horse in front to the right", "the east view: facing right"),
          "ne": ("three-quarter AWAY toward the upper right, the horse in front at the upper right", "the north-east view: three-quarter from behind, toward the upper right"),
          "n": ("seen from behind, the horse in front toward the top of the image", "the north view: seen from behind")}
for _n, _d in ((111, "s"), (112, "se"), (113, "e"), (114, "ne"), (115, "n")):
    JOBS.append((_n, "mortar", "deploy_" + _d, 6, MOR, "setting up to fire, %s; 6 frames: 1 the cart halted, the grey horse still hitched, a crewman at each side; 2 one crewman unhitches the horse; 3 he leads the horse a step away to the side; 4 the two crewmen lift the mortar off the cart; 5 they set it down on its bed on the ground; 6 the mortar set up on the ground, the two crewmen standing either side of it, exactly like reference 2 (the cart and horse gone). The SAME grey horse, the SAME two men and the SAME mortar size in every frame" % _MOR_V[_d][0], _MOR_V[_d][1], "a brown horse, a rearing horse, a third crewman, the mortar changing size, a different facing between frames,",
                 [("1_walk_%s_cart.png" % _d, [("mortar", "walk_" + _d)]), ("2_idle_%s_set_up.png" % _d, [("mortar", "idle_" + _d)])]))

RPK = "the rebel Pikeman of the Free Assembly (a black tricorne, a dark brown coat over a dull green waistcoat, brown breeches and boots, holding a long wooden pike with a steel head in both hands)"
LOOK["rebel_pikeman"] = "man, outfit and colours"
JOBS += [
    (116, "rebel_pikeman", "pike_se", 4, RPK, "facing three-quarter toward the lower right, the pike LEVELLED at waist height pointing toward the lower right corner, its steel head well out in front of him; 4 frames: 1 BRACED, feet apart, the pike held level and steady; 2 drawing the pike back; 3 the THRUST, the pike driven forward toward the lower right, the arms extended; 4 recovering to the braced stance. ONE pike, always level, never pointing at the ground", "the south-east view: three-quarter toward the lower right", "the pike pointing down at the ground, the pike head below his feet,",
     [("1_current_attack_se.png", [("rebel_pikeman", "attack_se"), ("rebel_pikeman", "brace_se")]), ("2_attack_e_pose.png", [("rebel_pikeman", "attack_e"), ("rebel_pikeman", "brace_e")]), ("3_idle_s_figure.png", [("rebel_pikeman", "idle_s")])]),
    (117, "rebel_pikeman", "pike_s", 4, RPK, "facing the viewer (toward the bottom of the image), his face toward us, the pike LEVELLED and pointing straight at the viewer so it is seen end-on, foreshortened: the steel head toward us in front of his chest, the shaft going back behind him; 4 frames: 1 BRACED, feet apart, the pike level; 2 drawing the pike back; 3 the THRUST toward the viewer, the arms extended; 4 recovering to the braced stance. ONE pike, level, never pointing at the ground", "the south view: facing the viewer", "the pike pointing down at the ground, the pike head below his feet, a side profile,",
     [("1_current_attack_s.png", [("rebel_pikeman", "attack_s"), ("rebel_pikeman", "brace_s")]), ("2_attack_e_pose.png", [("rebel_pikeman", "attack_e"), ("rebel_pikeman", "brace_e")]), ("3_idle_s_figure.png", [("rebel_pikeman", "idle_s")])]),
    (118, "rebel_pikeman", "attack_n", 3, RPK, "facing straight AWAY from the viewer (toward the top of the image), his back to us, NO face, the pike levelled and pointing up the image away from us at the same angle in every frame; 3 frames: 1 the pike drawn back; 2 the THRUST away from us, the arms extended; 3 recovering. ONE pike, always at the same slant, never standing straight up", "the north view: seen from behind", "the pike standing straight up, a different pike angle in each frame,",
     [("1_current_attack_n.png", [("rebel_pikeman", "attack_n")]), ("2_attack_e_pose.png", [("rebel_pikeman", "attack_e")]), ("3_walk_n_view.png", [("rebel_pikeman", "walk_n")])]),
]

VCH = "the Venom Challenger (a two-legged olive-green reptile, lean like a dilophosaurus, with a pure red frill round its neck and a row of pure red spines down its back and long tail)"
LOOK["venom_challenger"] = "creature, its colours and proportions"
_DIE = "5 frames: 1 struck, rearing; 2 staggering; 3 falling; 4 lying, the tail and legs settling; 5 still. ONE head and neck, two legs and one tail in every frame, the SAME facing as the first frame throughout"
JOBS += [
    (119, "tyrant_challenger", "death_s", 5, TCH, "dying, facing the viewer (toward the bottom of the image), its head and chest toward us, falling backward away from the viewer; " + _DIE, "the south view: facing the viewer", "a side view, the body turned to the right,",
     [("1_current_death_s.png", [("tyrant_challenger", "death_s")]), ("2_walk_s_model.png", [("tyrant_challenger", "walk_s")])]),
    (120, "venom_challenger", "death_s", 5, VCH, "dying, facing the viewer (toward the bottom of the image), its head and frill toward us, falling backward away from the viewer; " + _DIE, "the south view: facing the viewer", "a side view, the body turned to the right,",
     [("1_current_death_s.png", [("venom_challenger", "death_s")]), ("2_walk_s_model.png", [("venom_challenger", "walk_s")])]),
    (121, "venom_challenger", "death_ne", 5, VCH, "dying, facing three-quarter AWAY toward the upper right, its back half turned to us, falling forward toward the upper right; " + _DIE, "the north-east view: three-quarter from behind, toward the upper right", "a side view, the body turned to the right, its face toward us,",
     [("1_current_death_ne.png", [("venom_challenger", "death_ne")]), ("2_walk_ne_model.png", [("venom_challenger", "walk_ne")])]),
    (122, "venom_challenger", "death_n", 5, VCH, "dying, facing straight AWAY from the viewer (toward the top of the image), its back and tail toward us, NO face, falling forward away from us; " + _DIE, "the north view: seen from behind", "a side view, the body turned to the right, its face toward us,",
     [("1_current_death_n.png", [("venom_challenger", "death_n")]), ("2_walk_n_model.png", [("venom_challenger", "walk_n")])]),
]

# 2026-11-27 (owner: "All of it"): the Brood Mother's stage-2 south walk (finding 12), the Crown campaign Pikeman's
# south and south-east walk (34), the Cuirassier's pistol in every facing without the plume he has nowhere else (72)
BM2 = "the Brood Mother (a large heavy green reptile walking on four thick legs, a broad head with a pure red crest, pure red spines along her back and a long heavy tail, a swollen belly)"
LOOK["brood_mother_2"] = "creature, its colours and proportions"
PIK = "the Pikeman (a Crown foot soldier in a steel morion helmet and a breastplate over a pure red coat, carrying a very long pike)"
LOOK["pikeman"] = "man, outfit and colours"
JOBS += [
    (123, "brood_mother_2", "walk_s", 6, BM2, "walking straight toward the viewer (toward the bottom of the image), her head and chest toward us, the tail behind her out of sight or just showing over her back, 6 frames, a seamless walk loop, the legs stepping in turn, the same straight front angle in every frame", "the south view: straight toward the viewer", "a three-quarter or side view, the head turned to the lower right, the angle drifting between frames,",
     [("1_current_walk_s.png", [("brood_mother_2", "walk_s")]), ("2_attack_s_front.png", [("brood_mother_2", "attack_s")]), ("3_walk_e_model.png", [("brood_mother_2", "walk_e")])]),
    (124, "pikeman", "walk_s", 4, PIK, "walking straight toward the viewer (toward the bottom of the image), his face and chest toward us, the pike held upright at his right side, 4 frames, a seamless walk loop, the legs stepping in turn", "the south view: facing the viewer", "a side profile, the pike carried level, skating feet,",
     [("1_current_walk_s.png", [("pikeman", "walk_s")]), ("2_walk_e_model.png", [("pikeman", "walk_e")]), ("3_idle_s_view.png", [("pikeman", "idle_s")])]),
    (125, "pikeman", "walk_se", 4, PIK, "walking three-quarter toward the lower right (south-east), the pike held upright at his right side, 4 frames, a seamless walk loop, the legs stepping in turn", "the south-east view: three-quarter toward the lower right", "a side profile, the pike carried level, skating feet,",
     [("1_current_walk_se.png", [("pikeman", "walk_se")]), ("2_walk_e_model.png", [("pikeman", "walk_e")]), ("3_idle_se_view.png", [("pikeman", "idle_se")])]),
]
_CP = {"e": ("in a side view facing right (east), the pistol pointing right", "the east view: facing right"),
       "se": ("three-quarter toward the lower right (south-east), the pistol pointing down-right", "the south-east view: three-quarter toward the lower right"),
       "s": ("facing the viewer (the horse's chest and head toward us), the pistol pointing straight at the viewer, foreshortened", "the south view: straight toward the viewer"),
       "ne": ("three-quarter from behind toward the upper right, the pistol pointing up-right away from us", "the north-east view: three-quarter from behind, toward the upper right"),
       "n": ("seen from behind (the horse's rump toward us), NO face, the pistol pointing up the image away from us", "the north view: seen from behind")}
for _n, _d in ((126, "e"), (127, "se"), (128, "s"), (129, "ne"), (130, "n")):
    JOBS.append((_n, "cuirassier", "pistol_" + _d, 4, CUI, "firing his pistol from the saddle, the horse standing, %s; 4 frames: 1 aiming, the arm out; 2 FIRING, a small bright muzzle flash and a puff of white smoke; 3 the recoil, the arm kicked up; 4 lowering the pistol. His helmet is a PLAIN steel morion with NO plume and NO feather, exactly as in the walk reference. ONE pistol in his right hand, the SAME facing in all four frames" % _CP[_d][0], _CP[_d][1], "a plume or feather on the helmet, a second pistol, the horse turning,",
                 [("1_current_pistol_%s.png" % _d, [("cuirassier", "pistol_" + _d)]), ("2_walk_%s_model.png" % _d, [("cuirassier", "walk_" + _d)])]))


def main():
    out = sys.argv[1] if len(sys.argv) > 1 else "."
    os.makedirs(out, exist_ok=True)
    only = set(int(x) for x in sys.argv[2].split(",")) if len(sys.argv) > 2 else None
    for n, unit, strip, frames, who, what, view, avoid, refs in JOBS:
        if only and n not in only:
            continue
        pid = "sm%02d_%s_%s" % (n, unit, strip)
        dd = os.path.join(mr.ROOT, "docs/redraw_refs", pid)
        os.makedirs(dd, exist_ok=True)
        for name, rows in refs:
            mr.render(rows, os.path.join(dd, name))
        text = ("Make ONE row only. Draw %s %s. The %s of the references. "  % (who, what, LOOK.get(unit, "man, horse, outfit and colours"))
                + COMMON % (avoid, view, frames))
        json.dump({"pid": pid, "unit": unit, "strip": strip, "frames": frames, "text": text,
                   "refs": [os.path.join(dd, r[0]) for r in refs]}, open(os.path.join(out, "M%02d.json" % n), "w"))
        print(pid, len(text))


if __name__ == "__main__":
    main()
