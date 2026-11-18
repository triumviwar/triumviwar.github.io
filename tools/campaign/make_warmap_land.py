#!/usr/bin/env python3
"""THE WAR MAP's land (docs/war_map_v1.md): coasts, lakes and a few rivers for campaign/warmap_land.json, cut to the
war map's view and simplified, from Natural Earth's 1:50m data (public domain, naturalearthdata.com).

    curl -sSfL -O https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/ne_50m_land.geojson
    curl -sSfL -O https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/ne_50m_lakes.geojson
    curl -sSfL -O https://raw.githubusercontent.com/nvkelso/natural-earth-vector/master/geojson/ne_50m_rivers_lake_centerlines.geojson
    python3 tools/campaign/make_warmap_land.py ne_50m_land.geojson ne_50m_lakes.geojson ne_50m_rivers_lake_centerlines.geojson

Needs shapely (pip install shapely). The view (lon/lat) is campaign/warmap.json's "bounds", so the land and the map's
own data always agree. Output: {"land": [[lon, lat, lon, lat, ...], ...], "lakes": [...], "rivers": [[...]]}, each
ring a flat list of numbers rounded to 2 decimals (about 1 km)."""
import json, os, sys
from shapely.geometry import shape, box, Polygon, MultiPolygon, LineString, MultiLineString

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
RIVERS = {"Amazonas", "Negro", "Rhine", "Rhein", "Rhône", "Seine", "Danube", "Donau", "Loire", "Po", "Potomac",
          "Ohio", "Mississippi", "Tejo", "Elbe", "Orinoco"}
TOL = 0.05          # simplification (degrees)
MIN_AREA = 0.15     # smaller islands left out (square degrees)


def rings(geom):
    polys = [geom] if isinstance(geom, Polygon) else list(geom.geoms) if isinstance(geom, MultiPolygon) else []
    out = []
    for p in polys:
        if p.area < MIN_AREA:
            continue
        s = p.simplify(TOL, preserve_topology=True)
        if s.is_empty:
            continue
        for q in ([s] if isinstance(s, Polygon) else list(getattr(s, "geoms", []))):
            if not isinstance(q, Polygon) or q.area < MIN_AREA:
                continue
            c = list(q.exterior.coords)[:-1]
            if len(c) >= 3:
                out.append([round(v, 2) for xy in c for v in xy])
    return out


def lines(geom):
    ls = [geom] if isinstance(geom, LineString) else list(geom.geoms) if isinstance(geom, MultiLineString) else []
    out = []
    for l in ls:
        s = l.simplify(TOL)
        c = list(s.coords)
        if len(c) >= 2:
            out.append([round(v, 2) for xy in c for v in xy])
    return out


def main():
    land_p, lakes_p, rivers_p = sys.argv[1:4]
    wm = json.load(open(os.path.join(ROOT, "campaign/warmap.json"), encoding="utf-8"))
    b = wm["bounds"]          # [lon0, lat0, lon1, lat1]
    view = box(b[0] - 2, b[1] - 2, b[2] + 2, b[3] + 2)
    out = {"source": "Natural Earth 1:50m (public domain), cut by tools/campaign/make_warmap_land.py", "land": [], "lakes": [], "rivers": []}
    for key, path in (("land", land_p), ("lakes", lakes_p)):
        for f in json.load(open(path, encoding="utf-8"))["features"]:
            g = shape(f["geometry"]).buffer(0).intersection(view)
            if not g.is_empty:
                out[key] += rings(g)
    for f in json.load(open(rivers_p, encoding="utf-8"))["features"]:
        if f["properties"].get("name") not in RIVERS:
            continue
        g = shape(f["geometry"]).intersection(view)
        if not g.is_empty:
            out["rivers"] += lines(g)
    dst = os.path.join(ROOT, "campaign/warmap_land.json")
    with open(dst, "w", encoding="utf-8") as fh:
        json.dump(out, fh, separators=(",", ":"))
    print("%s: %d land rings, %d lakes, %d rivers, %d KB" % (dst, len(out["land"]), len(out["lakes"]), len(out["rivers"]),
          os.path.getsize(dst) // 1024))


if __name__ == "__main__":
    main()
