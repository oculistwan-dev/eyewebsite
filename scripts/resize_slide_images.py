#!/usr/bin/env python3
"""
Resize and crop slide images to a uniform target size using a cover strategy.
- Backs up original files as <name>-orig.<ext>
- Processes only files referenced in style.css matching top-slide*.{webp,jpg,png}
- Overwrites the existing filenames with the new resized images (same format)

Default target: 1280x720 (16:9). You can change TARGET_W / TARGET_H below.
"""
from pathlib import Path
import re
from PIL import Image
import shutil

ROOT = Path(__file__).resolve().parents[1]
CSS = ROOT / 'wp-content' / 'themes' / 'oculistwan' / 'css' / 'style.css'
IMG_DIR = ROOT / 'wp-content' / 'themes' / 'oculistwan' / 'images'
PATTERN = re.compile(r"(top-slide[0-9]{2}(?:-[a-z]{2})?\.(?:webp|jpg|jpeg|png))", re.IGNORECASE)

# Target size (change if you prefer another size)
TARGET_W = 1280
TARGET_H = 720
QUALITY = 85  # for lossy formats


def list_slide_files():
    text = CSS.read_text(encoding='utf-8')
    found = []
    for m in PATTERN.finditer(text):
        name = m.group(1)
        if name not in found:
            found.append(name)
    return found


def ensure_backup(p: Path):
    backup = p.with_name(p.stem + '-orig' + p.suffix)
    if not backup.exists():
        shutil.copy2(p, backup)
        print(f'Backup: {backup.name}')
    else:
        print(f'Backup already exists: {backup.name}')
    return backup


def resize_cover(img: Image.Image, target_w: int, target_h: int) -> Image.Image:
    # Cover behavior: scale to fill then center-crop
    src_w, src_h = img.size
    src_ratio = src_w / src_h
    tgt_ratio = target_w / target_h
    if src_ratio > tgt_ratio:
        # source is wider than target -> fit height, crop sides
        scale = target_h / src_h
    else:
        # source is taller or equal -> fit width, crop top/bottom
        scale = target_w / src_w
    new_w = int(round(src_w * scale))
    new_h = int(round(src_h * scale))
    img_resized = img.resize((new_w, new_h), Image.LANCZOS)
    # center crop
    left = max(0, (new_w - target_w) // 2)
    top = max(0, (new_h - target_h) // 2)
    right = left + target_w
    bottom = top + target_h
    img_cropped = img_resized.crop((left, top, right, bottom))
    return img_cropped


def process_file(name: str):
    p = IMG_DIR / name
    if not p.exists():
        print(f'NOT FOUND: {name}')
        return False
    try:
        backup = ensure_backup(p)
        with Image.open(p) as im:
            # convert animated or other modes to RGB for webp/jpg
            fmt = im.format or p.suffix.replace('.', '').upper()
            mode = im.mode
            # If image has alpha and target format doesn't support it, convert appropriately
            if mode in ('RGBA', 'LA'):
                base = im.convert('RGBA')
            else:
                base = im.convert('RGB')
            out = resize_cover(base, TARGET_W, TARGET_H)
            save_kwargs = {}
            suffix = p.suffix.lower()
            if suffix in ('.jpg', '.jpeg'):
                save_kwargs['quality'] = QUALITY
                out = out.convert('RGB')
                out.save(p, format='JPEG', **save_kwargs)
            elif suffix == '.webp':
                save_kwargs['quality'] = QUALITY
                out.save(p, format='WEBP', **save_kwargs)
            elif suffix == '.png':
                out.save(p, format='PNG', optimize=True)
            else:
                out.save(p)
        print(f'Processed: {name} -> {TARGET_W}x{TARGET_H} ({p.stat().st_size} bytes)')
        return True
    except Exception as e:
        print(f'Error processing {name}: {e}')
        return False


if __name__ == '__main__':
    files = list_slide_files()
    if not files:
        print('No slide images found in style.css matching pattern.')
        raise SystemExit(1)
    print('Target size:', TARGET_W, 'x', TARGET_H)
    print('Found files:', files)
    results = {}
    for f in files:
        ok = process_file(f)
        results[f] = ok
    print('\nSummary:')
    for k, v in results.items():
        print(f'- {k}:', 'OK' if v else 'FAILED')
