"""
Genera iconos PNG para la PWA a partir de `eco.jpg` ubicado en `static/pwa/icons/eco.jpg`.

Uso:
  - Instala Pillow: `pip install Pillow`
  - Ejecuta desde la raíz del proyecto:
      python static/pwa/generate_icons_from_eco.py

Esto generará los archivos `icon-<size>x<size>.png` en `static/pwa/icons/`.
"""
from PIL import Image
import os

ICON_DIR = os.path.join('static', 'pwa', 'icons')
SOURCE = os.path.join(ICON_DIR, 'eco.jpg')
SIZES = [72, 96, 128, 144, 152, 192, 384, 512]

def crop_center_square(img: Image.Image) -> Image.Image:
    w, h = img.size
    side = min(w, h)
    left = (w - side) // 2
    top = (h - side) // 2
    return img.crop((left, top, left + side, top + side))

def ensure_dir(path):
    os.makedirs(path, exist_ok=True)

def main():
    if not os.path.exists(SOURCE):
        print(f"ERROR: no se encontró {SOURCE}. Coloca tu logo como {SOURCE} y vuelve a intentar.")
        return

    ensure_dir(ICON_DIR)

    with Image.open(SOURCE) as img:
        img = img.convert('RGBA')
        base = crop_center_square(img)

        for size in SIZES:
            icon = base.resize((size, size), Image.LANCZOS)
            out_path = os.path.join(ICON_DIR, f'icon-{size}x{size}.png')
            icon.save(out_path, format='PNG')
            print(f'✓ Generado {out_path}')

    print('\n✓ Todos los iconos generados correctamente en', ICON_DIR)

if __name__ == '__main__':
    main()
