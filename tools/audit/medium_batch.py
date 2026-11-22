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
