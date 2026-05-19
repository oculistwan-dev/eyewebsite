#!/usr/bin/env python3
import re
import os
from pathlib import Path

root = Path(__file__).resolve().parents[1]
css = root / 'wp-content' / 'themes' / 'oculistwan' / 'css' / 'style.css'
images_dir = root / 'wp-content' / 'themes' / 'oculistwan' / 'images'

pattern = re.compile(r"top-slide[0-9]{2}(?:-[a-z]{2})?\.(?:webp|jpg|jpeg|png)")
found = set()

with css.open('r', encoding='utf-8') as f:
    text = f.read()
    for m in pattern.finditer(text):
        found.add(m.group(0))

if not found:
    print('未在 style.css 中找到 top-slide* 图片引用。')
    exit(0)

print('Found slide files:')
for name in sorted(found):
    p = images_dir / name
    if not p.exists():
        print(f'- {name}: NOT FOUND at {p}')
        continue
    size = p.stat().st_size
    info = f'- {name}: {size} bytes'
    try:
        from PIL import Image
        with Image.open(p) as im:
            info += f', {im.width}x{im.height} px, mode={im.mode}, format={im.format}'
    except ImportError:
        info += ' (Pillow not installed — run: pip install pillow to get pixel dimensions)'
    except Exception as e:
        info += f' (error reading image: {e})'
    print(info)

print('\nIf you want, I can help copy/resize images to a uniform size. Tell me the desired target (e.g. 1280x720).')
