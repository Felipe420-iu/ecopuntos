"""
Genera íconos PNG para PWA usando PIL
"""
from PIL import Image, ImageDraw, ImageFont
import os

def create_icon_png(size):
    """Crea un ícono PNG para EcoPuntos"""
    # Crear imagen con fondo verde
    img = Image.new('RGB', (size, size), '#4CAF50')
    draw = ImageDraw.Draw(img)
    
    # Calcular proporciones
    padding = size // 4
    center = size // 2
    circle_radius = size // 3
    
    # Dibujar círculo blanco central
    draw.ellipse(
        [center - circle_radius, center - circle_radius,
         center + circle_radius, center + circle_radius],
        fill='white'
    )
    
    # Dibujar símbolo de reciclaje simplificado
    # (Tres flechas en círculo)
    inner_radius = circle_radius // 2
    
    # Dibujar triángulo verde en el centro
    points = []
    for i in range(3):
        angle = i * 120 - 90
        import math
        x = center + inner_radius * math.cos(math.radians(angle))
        y = center + inner_radius * math.sin(math.radians(angle))
        points.append((x, y))
    
    draw.polygon(points, fill='#4CAF50')
    
    # Guardar
    return img

# Crear los íconos
sizes = [72, 96, 128, 144, 152, 192, 384, 512]

icon_dir = 'static/pwa/icons'
os.makedirs(icon_dir, exist_ok=True)

for size in sizes:
    img = create_icon_png(size)
    filename = f'{icon_dir}/icon-{size}x{size}.png'
    img.save(filename, 'PNG')
    print(f'✓ Creado {filename}')

print('\n✓ Íconos PNG creados exitosamente')
