# Как пересобрать DotGothic16Pip-Regular.ttf из оригинального DotGothic16-Regular.ttf (Google Fonts, OFL):
#   pip install fonttools && python3 shared/fonts/narrow_cyrillic.py DotGothic16-Regular.ttf shared/fonts/DotGothic16Pip-Regular.ttf
# Оригинал: ~/Documents/memory-backups/fonts/DotGothic16-Regular.ttf
"""Сужает клетки кириллицы (и «…») в DotGothic16: ширина = чернила + зазор, форма букв не меняется."""
import sys
from fontTools.ttLib import TTFont

SRC, DST = sys.argv[1], sys.argv[2]
SIDE = 31  # отступ слева и справа, ~полпикселя сетки 16px (62.5 ед.)
GRID = 31.25

f = TTFont(SRC)
cmap = f.getBestCmap()
glyf = f["glyf"]
hmtx = f["hmtx"]
targets = {cmap[c] for c in cmap if 0x400 <= c <= 0x4FF}
targets.add(cmap[ord("…")])
for name in sorted(targets):
    g = glyf[name]
    g.recalcBounds(glyf)
    if g.numberOfContours == 0:
        continue
    dx = SIDE - g.xMin
    coords = g.coordinates
    for i in range(len(coords)):
        x, y = coords[i]
        coords[i] = (x + dx, y)
    g.recalcBounds(glyf)
    ink = g.xMax - g.xMin
    adv = int(round(((ink + 2 * SIDE) / GRID)) * GRID)
    hmtx[name] = (adv, g.xMin)
# «…» в японском шрифте висит посередине строки — опускаем точки на уровень обычной точки.
ell = glyf[cmap[ord("…")]]
dot = glyf[cmap[ord(".")]]
dot.recalcBounds(glyf)
ell.recalcBounds(glyf)
dy = dot.yMin - ell.yMin
coords = ell.coordinates
for i in range(len(coords)):
    x, y = coords[i]
    coords[i] = (x, y + dy)
ell.recalcBounds(glyf)
for rec in f["name"].names:
    if rec.nameID in (1, 3, 4, 6, 16):
        s = rec.toUnicode()
        if rec.nameID == 6:
            s = s.replace("DotGothic16", "DotGothic16Pip")
        else:
            s = s.replace("DotGothic16", "DotGothic16 Pip")
        rec.string = s
f.save(DST)
print("narrowed", len(targets), "glyphs")
