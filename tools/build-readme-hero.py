#!/usr/bin/env python3
"""Build the README's mascot banner with Pillow.

Run: python3 tools/build-readme-hero.py
Optional: FAZ_FONT_REGULAR and FAZ_FONT_BOLD select TrueType font files.
"""
import os
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[1]
SCALE = 2
WIDTH, HEIGHT = 1200, 540


def font(size, bold=False):
    override = os.environ.get("FAZ_FONT_BOLD" if bold else "FAZ_FONT_REGULAR")
    candidates = [override] if override else []
    candidates += [
        "/System/Library/Fonts/Supplemental/Verdana" + (" Bold" if bold else "") + ".ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans" + ("-Bold" if bold else "") + ".ttf",
    ]
    for path in candidates:
        if Path(path).is_file():
            return ImageFont.truetype(path, size * SCALE)
    raise SystemExit("Set FAZ_FONT_REGULAR and FAZ_FONT_BOLD to TrueType font paths.")


# Warm paper, with a subtle peach glow behind the fox rather than a hard frame.
image = Image.new("RGB", (WIDTH * SCALE, HEIGHT * SCALE))
pixels = image.load()
for y in range(image.height):
    for x in range(image.width):
        distance = ((x / SCALE - 920) / 620) ** 2 + ((y / SCALE - 280) / 450) ** 2
        glow = max(0, 1 - distance) * 0.65
        pixels[x, y] = tuple(round(a + (b - a) * glow) for a, b in zip((255, 249, 239), (249, 216, 183)))
image = image.convert("RGBA")
shadow = Image.new("RGBA", image.size)
ImageDraw.Draw(shadow).ellipse((755*SCALE, 483*SCALE, 1095*SCALE, 507*SCALE), fill=(126, 70, 33, 42))
image = Image.alpha_composite(image, shadow.filter(ImageFilter.GaussianBlur(12*SCALE)))

mascot = Image.open(ROOT / "assets/faz.png").convert("RGBA")
mascot = mascot.crop(mascot.getbbox())
mascot.thumbnail((440*SCALE, 472*SCALE), Image.Resampling.LANCZOS)
image.alpha_composite(mascot, (int(916*SCALE - mascot.width/2), 499*SCALE - mascot.height))

draw = ImageDraw.Draw(image)

def text(x, y, value, size, color, bold=False):
    draw.text((x*SCALE, y*SCALE), value, font=font(size, bold), fill=color, anchor="lt")


text(65, 51, "MEET YOUR NEXT SIDE PROJECT", 12, "#916247")
text(58, 104, "Faz.", 100, "#432b23", True)
text(65, 241, "Small language.", 37, "#432b23", True)
text(65, 292, "Big ideas.", 37, "#432b23", True)
text(65, 343, "Tiny paws.", 37, "#bd572d", True)
text(66, 414, "Readable code. Native executables.", 17, "#795e50")
text(66, 491, "EXPERIMENTAL  /  OPEN SOURCE  /  SELF-HOSTED", 10, "#916f5c")

output = ROOT / "assets/faz-mascot-hero.png"
image.convert("RGB").save(output, optimize=True)
print(f"Built {output.relative_to(ROOT)}")
