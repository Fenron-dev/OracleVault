#!/usr/bin/env python3
"""OracleVault app icon generator.
Motif: an oracle's all-seeing eye set in a faceted gem (vault of random tables),
in the app's teal-green brand palette."""
import json, math, os
from PIL import Image, ImageDraw

ROOT = "/Users/dennis/Documents/AI/claude-code/OracleVault/oracle_vault"
F = 4                       # supersample: work at 1024*4 = 4096
S = 1024 * F
C = S / 2

# brand palette
TOP    = (0x16, 0x8A, 0x71)   # lighter teal (top of gradient)
BOT    = (0x09, 0x42, 0x37)   # deep green (bottom)
CREAM  = (0xF4, 0xF0, 0xE8)
IRIS   = (0x0A, 0x3B, 0x30)


def gradient_bg():
    img = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    px = img.load()
    for y in range(S):
        t = y / (S - 1)
        r = int(TOP[0] + (BOT[0] - TOP[0]) * t)
        g = int(TOP[1] + (BOT[1] - TOP[1]) * t)
        b = int(TOP[2] + (BOT[2] - TOP[2]) * t)
        for x in range(S):
            px[x, y] = (r, g, b, 255)
    # soft top-left glow
    glow = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    gd = ImageDraw.Draw(glow)
    gd.ellipse([-S * 0.25, -S * 0.30, S * 0.75, S * 0.55], fill=(255, 255, 255, 26))
    img = Image.alpha_composite(img, glow)
    return img


def draw_emblem(img):
    d = ImageDraw.Draw(img)
    sc = F  # scale factor for base-1024 coordinates

    # --- faceted gem: pointy-top hexagon frame ---
    R = 348 * sc
    hexpts = []
    for k in range(6):
        a = math.radians(-90 + 60 * k)
        hexpts.append((C + R * math.cos(a), C + R * math.sin(a)))
    d.line(hexpts + [hexpts[0]], fill=CREAM, width=int(34 * sc), joint="curve")
    # round the corners
    rr = int(17 * sc)
    for (x, y) in hexpts:
        d.ellipse([x - rr, y - rr, x + rr, y + rr], fill=CREAM)

    # --- oracle eye (vesica lens) ---
    W = 182 * sc
    r = 216.75 * sc
    s = 120.75 * sc
    n = 200
    top, bot = [], []
    for i in range(n + 1):
        x = -W + (2 * W) * i / n
        yt = -s + math.sqrt(max(0.0, r * r - x * x))   # math-y up
        yb = s - math.sqrt(max(0.0, r * r - x * x))
        top.append((C + x, C - yt))
        bot.append((C + x, C - yb))
    eye = top + bot[::-1]
    d.polygon(eye, fill=CREAM)

    # --- iris + pupil + highlight ---
    ir = 66 * sc
    d.ellipse([C - ir, C - ir, C + ir, C + ir], fill=IRIS)
    pr = 30 * sc
    d.ellipse([C - pr, C - pr, C + pr, C + pr], fill=(5, 28, 23, 255))
    hr = 17 * sc
    hx, hy = C + 22 * sc, C - 24 * sc
    d.ellipse([hx - hr, hy - hr, hx + hr, hy + hr], fill=CREAM)


def master_full():
    img = gradient_bg()
    draw_emblem(img)
    return img


def rounded_mask(side, radius):
    m = Image.new("L", (side, side), 0)
    ImageDraw.Draw(m).rounded_rectangle([0, 0, side - 1, side - 1], radius=radius, fill=255)
    return m


def save(img, path, size, opaque=False, bg=BOT):
    out = img.resize((size, size), Image.LANCZOS)
    if opaque:
        flat = Image.new("RGB", (size, size), bg)
        flat.paste(out, (0, 0), out)
        flat.save(path)
    else:
        out.save(path)


FULL = master_full()

# macOS variant: inset ~6% with rounded (squircle-ish) corners, transparent margin
def mac_variant():
    inset = int(S * 0.055)
    inner = S - 2 * inset
    art = FULL.resize((inner, inner), Image.LANCZOS)
    radius = int(inner * 0.2237)
    mask = rounded_mask(inner, radius)
    canvas = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    canvas.paste(art, (inset, inset), mask)
    return canvas

MAC = mac_variant()

# ---- macOS ----
macset = f"{ROOT}/macos/Runner/Assets.xcassets/AppIcon.appiconset"
for px in (16, 32, 64, 128, 256, 512, 1024):
    save(MAC, f"{macset}/app_icon_{px}.png", px, opaque=False)

# ---- iOS (must be opaque, no alpha) ----
iosset = f"{ROOT}/ios/Runner/Assets.xcassets/AppIcon.appiconset"
ic = json.load(open(f"{iosset}/Contents.json"))
done = set()
for i in ic["images"]:
    base = float(i["size"].split("x")[0])
    scale = int(i["scale"].replace("x", ""))
    px = int(round(base * scale))
    fn = i["filename"]
    if fn in done:
        continue
    done.add(fn)
    save(FULL, f"{iosset}/{fn}", px, opaque=True)

# ---- Android legacy mipmaps ----
andmap = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
for dpi, px in andmap.items():
    save(FULL, f"{ROOT}/android/app/src/main/res/mipmap-{dpi}/ic_launcher.png", px, opaque=True)

# preview master
FULL.resize((512, 512), Image.LANCZOS).save("/tmp/oraclevault_icon_preview.png")
MAC.resize((512, 512), Image.LANCZOS).save("/tmp/oraclevault_icon_mac_preview.png")
print("Icons generated.")
