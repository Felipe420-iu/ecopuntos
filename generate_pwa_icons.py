"""
Script para generar íconos PWA de EcoPuntos
Crea íconos SVG que se pueden convertir a PNG si necesitas
"""

def create_icon_svg(size):
    """Crea un ícono SVG para EcoPuntos"""
    svg_content = f'''<svg width="{size}" height="{size}" viewBox="0 0 512 512" xmlns="http://www.w3.org/2000/svg">
  <!-- Fondo verde -->
  <rect width="512" height="512" fill="#4CAF50" rx="128"/>
  
  <!-- Círculo blanco de fondo -->
  <circle cx="256" cy="256" r="180" fill="white"/>
  
  <!-- Símbolo de reciclaje -->
  <g transform="translate(256, 256)">
    <!-- Flecha 1 -->
    <path d="M 0,-100 L -30,-140 L 30,-140 Z M 0,-100 L 0,-60" 
          fill="#4CAF50" stroke="#4CAF50" stroke-width="8"/>
    
    <!-- Flecha 2 (rotada 120 grados) -->
    <g transform="rotate(120)">
      <path d="M 0,-100 L -30,-140 L 30,-140 Z M 0,-100 L 0,-60" 
            fill="#4CAF50" stroke="#4CAF50" stroke-width="8"/>
    </g>
    
    <!-- Flecha 3 (rotada 240 grados) -->
    <g transform="rotate(240)">
      <path d="M 0,-100 L -30,-140 L 30,-140 Z M 0,-100 L 0,-60" 
            fill="#4CAF50" stroke="#4CAF50" stroke-width="8"/>
    </g>
    
    <!-- Círculo central -->
    <circle cx="0" cy="0" r="40" fill="#4CAF50"/>
    
    <!-- Letra E en el centro -->
    <text x="0" y="15" font-family="Arial, sans-serif" font-size="50" 
          font-weight="bold" fill="white" text-anchor="middle">E</text>
  </g>
  
  <!-- Texto "Eco" en la parte inferior -->
  <text x="256" y="440" font-family="Arial, sans-serif" font-size="60" 
        font-weight="bold" fill="white" text-anchor="middle">ECO</text>
</svg>'''
    return svg_content

# Crear los íconos
sizes = [72, 96, 128, 144, 152, 192, 384, 512]

import os

icon_dir = 'static/pwa/icons'
os.makedirs(icon_dir, exist_ok=True)

for size in sizes:
    svg_content = create_icon_svg(size)
    filename = f'{icon_dir}/icon-{size}x{size}.svg'
    with open(filename, 'w', encoding='utf-8') as f:
        f.write(svg_content)
    print(f'✓ Creado {filename}')

print('\n✓ Íconos SVG creados exitosamente')
print('Para convertir a PNG, usa: https://www.iloveimg.com/es/convertir-a-jpg/svg-a-jpg')
print('O instala imagemagick y ejecuta: convert icon.svg -resize 512x512 icon.png')
