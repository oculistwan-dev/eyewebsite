#!/usr/bin/env python3
"""
Generate preview thumbnails for slide images.
Creates two sizes per image:
 - preview_small: 400x225
 - preview_med: 800x450
Saves to scripts/previews/<original-name>-small.jpg and -med.jpg
"""
from pathlib import Path
import re
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
CSS = ROOT / 'wp-content' / 'themes' / 'oculistwan' / 'css' / 'style.css'
IMG_DIR = ROOT / 'wp-content' / 'themes' / 'oculistwan' / 'images'
OUT_DIR = ROOT / 'scripts' / 'previews'
OUT_DIR.mkdir(parents=True, exist_ok=True)
PATTERN = re.compile(r"(top-slide[0-9]{2}(?:-[a-z]{2})?\.(?:webp|jpg|jpeg|png))", re.IGNORECASE)

SIZES = {
    'small': (400, 225),
    'med': (800, 450),
}


def list_slide_files():
    text = CSS.read_text(encoding='utf-8')
    found = []
    for m in PATTERN.finditer(text):
        name = m.group(1)
        if name not in found:
            found.append(name)
    return found


def resize_cover(img: Image.Image, target_w: int, target_h: int) -> Image.Image:
    src_w, src_h = img.size
    src_ratio = src_w / src_h
    tgt_ratio = target_w / target_h
    if src_ratio > tgt_ratio:
        scale = target_h / src_h
    else:
        scale = target_w / src_w
    new_w = int(round(src_w * scale))
    new_h = int(round(src_h * scale))
    img_resized = img.resize((new_w, new_h), Image.LANCZOS)
    left = max(0, (new_w - target_w) // 2)
    top = max(0, (new_h - target_h) // 2)
    right = left + target_w
    bottom = top + target_h
    return img_resized.crop((left, top, right, bottom))


if __name__ == '__main__':
    files = list_slide_files()
    if not files:
        print('No slide images found.')
        raise SystemExit(1)
    print('Found files:', files)
    for fname in files:
        p = IMG_DIR / fname
        if not p.exists():
            print('NOT FOUND:', fname)
            continue
        try:
            with Image.open(p) as im:
                im_conv = im.convert('RGB')
                for key, (w, h) in SIZES.items():
                    out = resize_cover(im_conv, w, h)
                    out_name = f"{p.stem}-{key}.jpg"
                    out_path = OUT_DIR / out_name
                    out.save(out_path, format='JPEG', quality=85)
                    print('Saved preview:', out_path)
        except Exception as e:
            print('Error processing', fname, e)
