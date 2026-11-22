#!/usr/bin/env python3
"""THE WORLD WAR mode's map (docs/world_war_mode.md): campaign/worldwar/regions.json and campaign/worldwar/land.json.

    curl -sSfL -O https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/ne_50m_land.geojson
    python3 tools/worldwar/make_regions.py ne_50m_land.geojson

Needs shapely. Each region is a point (its town) with a biome, a worth (1-3), a port flag and a key flag; its shape is
the land nearer its town than any other town (a Voronoi cell), cut to the coasts and to REACH degrees round the town.
Land neighbours are the regions whose shapes touch (plus the EXTRA pairs, less the CUT ones); sea lanes join ports
within SEA_REACH degrees, plus the LANES (the long trade routes). Natural Earth is public domain."""
import json, math, os, sys
from shapely.geometry import shape, box, Point, Polygon, MultiPolygon, MultiPoint
from shapely.ops import unary_union, voronoi_diagram

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
BOUNDS = (-170, -56, 165, 72)
REACH = 13.0          # degrees round a town its region reaches at most
SEA_REACH = 0.0       # (no automatic lanes: a straight line crosses land; every lane is in LANES)
TOL = 0.12

# id, name, lon, lat, biome, worth, port, key
R = [
    # Europe
    ("rome", "Rome", 12.5, 41.9, "temperate", 3, 1, 1),
    ("naples", "Naples", 15.3, 40.6, "temperate", 2, 1, 0),
    ("milan", "Milan", 9.2, 45.5, "temperate", 2, 0, 0),
    ("lyon", "Lyon", 4.8, 45.8, "temperate", 2, 0, 0),
    ("paris", "Paris", 2.3, 48.9, "temperate", 3, 0, 1),
    ("brittany", "Brittany", -2.8, 47.9, "wet", 1, 1, 0),
    ("low_countries", "Low Countries", 4.9, 51.8, "wet", 2, 1, 0),
    ("rhineland", "Rhineland", 7.4, 50.4, "wet", 2, 0, 0),
    ("nuremberg", "Nuremberg", 11.1, 49.4, "temperate", 3, 0, 1),
    ("saxony", "Saxony", 13.2, 51.6, "temperate", 2, 0, 0),
    ("vienna", "Vienna", 15.6, 47.8, "temperate", 3, 0, 0),
    ("hungary", "Hungary", 20.0, 46.8, "temperate", 2, 0, 0),
    ("poland", "Poland", 20.0, 52.2, "cold", 2, 0, 0),
    ("muscovy", "Muscovy", 37.6, 55.8, "cold", 2, 0, 0),
    ("scandinavia", "Scandinavia", 16.0, 60.5, "cold", 1, 1, 0),
    ("london", "London", -1.2, 52.0, "wet", 3, 1, 0),
    ("scotland", "Scotland", -4.2, 56.8, "cold", 1, 1, 0),
    ("lisbon", "Lisbon", -8.4, 39.6, "temperate", 3, 1, 1),
    ("castile", "Castile", -3.7, 40.4, "desert", 2, 0, 0),
    ("andalusia", "Andalusia", -5.0, 37.4, "desert", 1, 1, 0),
    ("constantinople", "Constantinople", 29.0, 41.0, "temperate", 3, 1, 1),
    # Africa and the Levant
    ("morocco", "Morocco", -6.8, 32.0, "desert", 1, 1, 0),
    ("egypt", "Egypt", 31.2, 29.0, "desert", 2, 1, 1),
    ("sahara", "Sahara", 4.0, 22.0, "desert", 1, 0, 0),
    ("guinea", "Guinea", -2.0, 8.0, "jungle", 1, 1, 0),
    ("kongo", "Kongo", 15.0, -3.5, "jungle", 2, 1, 0),
    ("luanda", "Luanda", 15.5, -11.5, "jungle", 2, 1, 1),
    ("ethiopia", "Ethiopia", 38.7, 9.0, "temperate", 2, 0, 0),
    ("mozambique", "Mozambique", 36.0, -15.0, "jungle", 1, 1, 0),
    ("cape", "The Cape", 21.0, -31.0, "temperate", 2, 1, 1),
    ("arabia", "Arabia", 45.0, 21.0, "desert", 1, 1, 0),
    # Asia
    ("persia", "Persia", 53.0, 32.0, "desert", 2, 0, 0),
    ("goa", "Goa", 75.0, 17.0, "jungle", 3, 1, 1),
    ("bengal", "Bengal", 86.0, 24.0, "wet", 2, 1, 0),
    ("malacca", "Malacca", 102.0, 4.0, "jungle", 2, 1, 0),
    ("canton", "Canton", 112.0, 25.0, "wet", 3, 1, 1),
    ("manila", "Manila", 122.0, 14.6, "jungle", 2, 1, 0),
    ("nagasaki", "Nagasaki", 133.0, 34.5, "temperate", 2, 1, 1),
    ("siberia", "Siberia", 70.0, 58.0, "cold", 1, 0, 0),
    ("tartary", "Tartary", 100.0, 45.0, "cold", 1, 0, 0),
    ("new_holland", "New Holland", 140.0, -26.0, "desert", 1, 1, 0),
    # North America
    ("quebec", "Quebec", -72.0, 48.0, "cold", 1, 1, 0),
    ("new_england", "New England", -72.5, 42.5, "cold", 2, 1, 0),
    ("virginia", "Virginia", -78.5, 37.5, "temperate", 3, 1, 1),
    ("ohio", "Ohio", -85.0, 40.5, "temperate", 1, 0, 0),
    ("louisiana", "Louisiana", -91.0, 32.0, "wet", 2, 1, 0),
    ("great_plains", "Great Plains", -101.0, 40.0, "temperate", 1, 0, 0),
    ("new_spain", "New Spain", -101.0, 22.0, "desert", 3, 1, 1),
    ("california", "California", -119.0, 37.0, "desert", 1, 1, 0),
    ("caribbean", "Caribbean", -80.0, 21.0, "jungle", 2, 1, 0),
    # South America
    ("new_granada", "New Granada", -74.0, 6.0, "jungle", 2, 1, 0),
    ("peru", "Peru", -75.5, -11.0, "cold", 2, 1, 0),
    ("amazon", "The Amazon", -62.0, -3.5, "jungle", 3, 0, 1),
    ("para", "Pará", -50.0, -3.0, "jungle", 2, 1, 0),
    ("bahia", "Bahia", -40.5, -11.5, "wet", 2, 1, 0),
    ("minas", "Minas Gerais", -45.0, -18.5, "temperate", 2, 0, 0),
    ("rio", "Rio de Janeiro", -50.0, -25.0, "temperate", 3, 1, 1),
    ("mato_grosso", "Mato Grosso", -59.0, -13.0, "wet", 1, 0, 0),
    ("plata", "The Plate", -60.5, -32.0, "temperate", 2, 1, 0),
    ("patagonia", "Patagonia", -68.0, -45.0, "cold", 1, 1, 0),
]
# land pairs that touch on the map but have no way through (seas, mountains), and pairs joined though they don't touch
CUT = {("milan", "nuremberg"), ("london", "low_countries"), ("london", "brittany"), ("scotland", "scandinavia"), ("egypt", "arabia"),
       ("morocco", "andalusia"), ("greece", "egypt"), ("canton", "manila"), ("nagasaki", "tartary"), ("nagasaki", "canton"),
       ("caribbean", "new_spain"), ("caribbean", "louisiana"), ("caribbean", "new_granada"), ("caribbean", "virginia"),
       ("london", "paris"), ("rome", "naples_x"), ("scandinavia", "poland"), ("malacca", "manila"), ("goa", "arabia"),
       ("constantinople", "egypt"), ("arabia", "persia_x"), ("bengal", "goa_x"), ("new_holland", "malacca"),
       ("peru", "mato_grosso_x"), ("italy", "x"), ("brittany", "castile"), ("naples", "hungary"), ("naples", "vienna"), ("sahara", "andalusia")}
EXTRA = {("siberia", "muscovy"), ("siberia", "tartary"), ("london", "scotland"), ("ohio", "louisiana"), ("great_plains", "louisiana"), ("egypt", "arabia")}
EXTRA -= {("egypt", "arabia")}
EXTRA |= {("egypt", "arabia")}   # (Suez: by land)
CUT.discard(("egypt", "arabia"))
# the long trade routes (both ways), besides the short hops SEA_REACH gives
LANES = [("lisbon", "rio"), ("lisbon", "luanda"), ("lisbon", "guinea"), ("lisbon", "caribbean"), ("lisbon", "virginia"),
         ("london", "new_england"), ("london", "virginia"), ("brittany", "quebec"), ("andalusia", "caribbean"),
         ("guinea", "bahia"), ("luanda", "bahia"), ("luanda", "cape"), ("cape", "mozambique"), ("mozambique", "goa"),
         ("arabia", "goa"), ("goa", "malacca"), ("malacca", "canton"), ("malacca", "manila"), ("manila", "nagasaki"),
         ("manila", "new_spain"), ("canton", "nagasaki"), ("rio", "cape"), ("plata", "cape"), ("peru", "new_spain"),
         ("california", "nagasaki"), ("malacca", "new_holland"), ("new_holland", "cape"), ("caribbean", "virginia"),
         ("caribbean", "louisiana"), ("caribbean", "new_granada"), ("caribbean", "para"), ("rome", "lisbon"),
         ("constantinople", "egypt"), ("morocco", "andalusia"), ("bengal", "malacca"), ("peru", "patagonia"),
         ("rio", "plata"), ("bahia", "para"), ("new_england", "virginia"), ("low_countries", "london"),
         ("scandinavia", "low_countries"), ("scandinavia", "scotland"), ("london", "brittany"), ("lisbon", "brittany"),
         ("naples", "constantinople"), ("lisbon", "morocco"), ("canton", "manila"), ("caribbean", "new_spain"), ("bahia", "rio"), ("guinea", "kongo"), ("kongo", "bahia"), ("guinea", "morocco"), ("rome", "andalusia"), ("goa", "bengal"), ("egypt", "naples")]
SEA_OK = {("louisiana", "new_spain"), ("caribbean", "new_spain")}


def rings(geom):
    polys = [geom] if isinstance(geom, Polygon) else list(geom.geoms) if hasattr(geom, "geoms") else []
    out = []
    for p in polys:
        if not isinstance(p, Polygon) or p.area < 0.2:
            continue
        s = p.simplify(TOL, preserve_topology=True)
        for q in ([s] if isinstance(s, Polygon) else list(getattr(s, "geoms", []))):
            if isinstance(q, Polygon) and q.area >= 0.2:
                c = list(q.exterior.coords)[:-1]
                if len(c) >= 3:
                    out.append([round(v, 2) for xy in c for v in xy])
    return out


def main(land_path):
    gj = json.load(open(land_path))
    view = box(*BOUNDS)
    land = unary_union([shape(f["geometry"]) for f in gj["features"]]).intersection(view)
    land = land.buffer(0)
    # the coasts for the map (a bit coarser than the war map's)
    big = [p for p in (land.geoms if hasattr(land, "geoms") else [land]) if p.area >= 0.6]
    land_out = []
    for p in big:
        land_out += rings(p.simplify(0.08, preserve_topology=True))
    json.dump({"source": "Natural Earth 1:50m (public domain), cut by tools/worldwar/make_regions.py", "bounds": BOUNDS,
               "land": land_out}, open(os.path.join(ROOT, "campaign/worldwar/land.json"), "w"), separators=(",", ":"))
    pts = MultiPoint([Point(r[2], r[3]) for r in R])
    vor = voronoi_diagram(pts, envelope=box(-200, -90, 200, 90))
    cells = {}
    for cell in vor.geoms:
        for r in R:
            if cell.contains(Point(r[2], r[3])):
                cells[r[0]] = cell
    shapes = {}
    for r in R:
        reach = Point(r[2], r[3]).buffer(REACH)
        sh = cells[r[0]].intersection(reach).intersection(land)
        # keep only the land pieces that hold the town or touch the piece that does (no far-off islands)
        parts = list(sh.geoms) if hasattr(sh, "geoms") else [sh]
        main_p = min(parts, key=lambda p: p.distance(Point(r[2], r[3])))
        keep = [p for p in parts if p is main_p or (p.area > 1.0 and p.distance(main_p) < 2.5)]
        shapes[r[0]] = unary_union(keep)
    ids = [r[0] for r in R]
    nb = {i: set() for i in ids}
    for a in ids:
        for b in ids:
            if a < b and shapes[a].buffer(0.05).intersects(shapes[b].buffer(0.05)):
                inter = shapes[a].buffer(0.05).intersection(shapes[b].buffer(0.05))
                if inter.area > 0.02 and (a, b) not in CUT and (b, a) not in CUT:
                    nb[a].add(b); nb[b].add(a)
    for a, b in EXTRA:
        nb[a].add(b); nb[b].add(a)
    port = {r[0]: bool(r[6]) for r in R}
    pos = {r[0]: (r[2], r[3]) for r in R}
    sea = {i: set() for i in ids}
    for a in ids:
        for b in ids:
            if a < b and port[a] and port[b] and b not in nb[a]:
                d = math.dist(pos[a], pos[b])
                if d < SEA_REACH and not (a in ("new_spain", "louisiana") and b in ("caribbean",) and False):
                    sea[a].add(b); sea[b].add(a)
    for a, b in LANES:
        assert port[a] and port[b], (a, b)
        if b not in nb[a]:
            sea[a].add(b); sea[b].add(a)
    # a few short hops across land that the distance found wrongly (two coasts of one continent)
    for a, b in [("california", "new_spain"), ("peru", "new_granada"), ("peru", "rio"), ("peru", "plata"),
                 ("california", "louisiana"), ("new_spain", "louisiana"), ("cape", "mozambique_x"),
                 ("persia", "x"), ("arabia", "mozambique"), ("goa", "bengal_x"), ("canton", "malacca_x"),
                 ]:
        if b in sea.get(a, set()):
            sea[a].discard(b); sea[b].discard(a)
    out = []
    for r in R:
        i = r[0]
        polys = rings(shapes[i])
        out.append({"id": i, "name": r[1], "at": [r[2], r[3]], "biome": r[4], "worth": r[5], "port": bool(r[6]),
                    "key": bool(r[7]), "land": sorted(nb[i]), "sea": sorted(sea[i]), "shape": polys})
    lonely = [o["id"] for o in out if not o["land"] and not o["sea"]]
    assert not lonely, lonely
    data = {"about": "THE WORLD WAR mode's regions (docs/world_war_mode.md), written by tools/worldwar/make_regions.py",
            "bounds": BOUNDS, "y_scale": 1.3, "regions": out}
    json.dump(data, open(os.path.join(ROOT, "campaign/worldwar/regions.json"), "w"), indent=1)
    for o in out:
        print("%-15s %-9s w%d %s land=%s sea=%s" % (o["id"], o["biome"], o["worth"], "P" if o["port"] else " ",
                                                    ",".join(o["land"]), ",".join(o["sea"])))
    print(len(out), "regions")


if __name__ == "__main__":
    main(sys.argv[1])
