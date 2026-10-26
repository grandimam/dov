#!/usr/bin/env python3
"""Build the standalone mascot banner: python3 tools/build-readme-hero.py.

Requires Pillow. Embeds the existing mascot so GitHub need not load an external
image from inside the SVG. No fonts, scripts, or remote resources are required.
"""
import base64
from io import BytesIO
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
mascot = Image.open(ROOT / "assets/faz.png").convert("RGBA")
mascot = mascot.crop(mascot.getbbox())
mascot.thumbnail((900, 960), Image.Resampling.LANCZOS)
buffer = BytesIO()
mascot.save(buffer, format="PNG", optimize=True)
encoded = base64.b64encode(buffer.getvalue()).decode("ascii")

svg = f'''<svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" width="1200" height="540" viewBox="0 0 1200 540" role="img" aria-labelledby="title desc">
  <title id="title">Meet Faz. Small language. Big ideas. Tiny paws.</title>
  <desc id="desc">Faz, a curious orange fox with a big fluffy tail, welcomes you to the Faz programming language. Readable code. Native executables.</desc>
  <defs>
    <linearGradient id="bg" x2="1" y2="1"><stop stop-color="#141c2b"/><stop offset="1" stop-color="#292332"/></linearGradient>
    <radialGradient id="glow"><stop stop-color="#d98145" stop-opacity=".24"/><stop offset="1" stop-color="#d98145" stop-opacity="0"/></radialGradient>
    <pattern id="grid" width="48" height="48" patternUnits="userSpaceOnUse"><path d="M48 0H0V48" fill="none" stroke="#fff" stroke-opacity=".025"/></pattern>
  </defs>
  <rect width="1200" height="540" rx="24" fill="url(#bg)"/>
  <rect width="1200" height="540" rx="24" fill="url(#grid)"/>
  <ellipse cx="907" cy="269" rx="290" ry="265" fill="url(#glow)"/>
  <circle cx="917" cy="266" r="208" fill="none" stroke="#f6b17e" stroke-opacity=".12"/>
  <circle cx="917" cy="266" r="232" fill="none" stroke="#f6b17e" stroke-opacity=".06" stroke-dasharray="3 12"/>
  <g font-family="Verdana, sans-serif">
    <text x="64" y="68" fill="#f6b17e" font-size="12" letter-spacing="3">MEET YOUR NEXT SIDE PROJECT</text>
    <text x="57" y="189" fill="#fff7ed" font-size="110" font-weight="bold" letter-spacing="-6">Faz<tspan fill="#f6b17e">.</tspan></text>
    <g font-size="39" font-weight="bold" letter-spacing="-1">
      <text x="64" y="263" fill="#fff7ed">Small language.</text>
      <text x="64" y="314" fill="#fff7ed">Big ideas.</text>
      <text x="64" y="365" fill="#f6b17e">Tiny paws.</text>
    </g>
    <text x="65" y="413" fill="#c5c0cc" font-size="17">Readable code. Native executables.</text>
    <text x="65" y="493" fill="#9f9bac" font-size="11" letter-spacing="2">EXPERIMENTAL / OPEN SOURCE / SELF-HOSTED</text>
  </g>
  <ellipse cx="913" cy="501" rx="168" ry="13" fill="#080c16" opacity=".35"/>
  <image x="695" y="27" width="445" height="478" preserveAspectRatio="xMidYMid meet" xlink:href="data:image/png;base64,{encoded}"/>
</svg>
'''
(ROOT / "assets/readme-hero.svg").write_text(svg)
print("Built assets/readme-hero.svg")
