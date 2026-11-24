# The city generator (job a01-presses, 0.38.57)

Step 5 of Act 1's build order (docs/campaign_act1_plan.md): one script that makes a town for a campaign map, written for
Lyon (a01_presses) and meant for Paris (a06), Rome (a07) and any later town. It is `tools/campaign/city_gen.py`, a
small Python library with no game code in it; a MAP SCRIPT calls it (Lyon's is `tools/campaign/make_lyon_map.py`) and
writes an ordinary map editor map into `campaign/maps/<name>.json`. Nothing about it is new to the game: the town is
cells and props like every other map, and opens in the MAP EDITOR.

## What it makes

- RIVERS: water along a line of points, so many cells wide.
- BRIDGES: fords across a river at a row (a river running north-south) or a column (east-west), with the banks at both
  ends kept clear so a street reaches them.
- HILLS and their STAIRS: high ground over a rectangle (a cliff all round) and ramps (a town's stairs) up it.
- A HILL TOWN (Act 2's d01_minas, Vila Rica; tools/campaign/make_vila_rica_map.py): `hill_blob(name, cx, cy, rx, ry)`
  raises a rounded hill (an ellipse with a gentle wobble, the same every time from the same numbers), so a town on two
  hills and a ridge is not all ruler-straight edges; `stairs(name, at, way, width)` walks from a cell on the high ground
  to the hill's edge in that way (n, s, e, w) and puts a stair there, squaring the ragged edge off first so the ramp
  meets a straight cliff. The engine has two heights only (low and high), so a hill town is high ground with stairs
  down every side, and the squares and streets on top.
- DISTRICTS: a grid of streets and house BLOCKS over a rectangle (block sizes and street widths given; every third
  street a cell wider); a block that crosses a hill's edge is cut there.
- SQUARES and STREETS cut through the blocks: kept free of houses, each an area the mission can name.
- HOUSES, last: every block cell not kept free gets a house's foot (cottages and sheds, two cells wide, rows staggered,
  a well or oven where a single cell is left), so a block is SOLID and the streets are the only ways through.
- TRABOULES: Lyon's covered passages, one cell wide, through a block (a shortcut between two streets, or into a yard).
  Each has a DOOR cell in its middle where a mission may shut it.
- COURTYARDS: a block of its own (kept off the districts) with a hidden yard inside it, reached only by traboules.
- LOTS: free spots for a mission's own buildings (a 2 x 2 cottage by default, any size), at a block's corner on one
  height, with the free ring round them the engine's placement wants; or exactly where asked (in a yard, on a square).
- WALLS: a town wall of rock along a line, gates left open.
- A FRAME of trees round the map's edge.

Every call that makes something worth naming gives it an AREA (in the engine's [x, y, w, h]): the squares, the
bridges, the stairs, the districts, the traboules, the yards, the lots. A mission script imports the map script and
reads them from the same build, so the map and the mission never disagree, and there is no file next to the map.

## Same seed, same town

Everything random comes from `random.Random(seed)`, used in the order of the calls: the same calls with the same seed
give the same town to the byte (tools/test_city_gen.gd builds its demo town twice and once with another seed). Change
a call, and the town after it moves: that is why the map file is always rebuilt from its script (the test fails when
`campaign/maps/lyon_presses.json` is not what `make_lyon_map.py` writes now).

## Checks

- `City.check(start)`: every square, bridge and lot (or the areas named) can be walked to from `start` (four ways; low
  and high ground meet only on a ramp; house feet block). A map script refuses to write a town that fails it.
- `City.ascii()`: a text picture (`#` houses) to look at while writing a map script (`make_lyon_map.py --ascii`).
- The generator's rules for a house's foot are the map loader's (MapGen.place_props: not on water, ramps, fords or
  another foot; GDScript's integer division for the foot's cells): tools/test_city_gen.gd checks the loader puts down
  every house of Lyon.

## Writing a town

```python
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from city_gen import City

def build():
    c = City("paris_barricades", 128, 96, seed=1769, biome="grass")
    c.frame(2, "t")
    c.river("seine", [(0, 50), (40, 46), (90, 52), (128, 48)], 6)
    c.hill("montmartre", [60, 2, 90, 14]); c.ramp("stair", [70, 14, 74, 15])
    c.block("yard_block", [20, 20, 34, 31], "yard")            # (before the districts)
    c.district("left_bank", [3, 56, 125, 93], block=(6, 10), street=2)
    c.district("right_bank", [3, 16, 125, 44], block=(6, 10), street=2)
    c.square("place_de_greve", [50, 38, 60, 44])
    c.bridge("pont_neuf", "seine", x=40)
    c.courtyard("yard", [23, 23, 31, 28]); c.traboule("into_yard", [27, 30], "n")
    c.lot("barricade_1", "right_bank", near=(64, 30))
    c.houses()                                                 # (last)
    return c

if __name__ == "__main__":
    c = build(); assert not c.check((10, 20)); c.save()
```

`tools/campaign/city_gen.py --demo <seed> --out <file> [--ascii]` writes the demo town (every call in it), the test's
and a starting point.

## What it does not do (yet)

- No diagonal streets or round squares (a grid with jitter): enough for Lyon's Presqu'île; Paris's boulevards and
  Rome's piazzas may want a `street` along a polyline.
- Houses are the props there are (cottage, shed, well, oven): a town of its own look waits for town-house props.
- Bridges are fords (walkable water), as the engine has no bridge pieces.
- One biome for the whole town (the map format's).
