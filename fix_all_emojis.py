#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Script COMPLETO para detectar y corregir TODOS los emojis mal codificados
"""

def find_and_fix_all_emojis():
    """Encuentra y corrige todos los emojis mal codificados"""
    file_path = 'core/templates/core/index.html'
    
    # Mapeo completo de TODOS los emojis mal codificados encontrados
    emoji_map = {
        # Primera ronda (ya corregidos)
        'âœ¨': '✨',  # Sparkles
        'ðŸš€': '🚀',  # Rocket
        'ðŸŒŸ': '🌟',  # Glowing star
        'â­': '⭐',  # Star
        'ðŸ'«': '💫',  # Dizzy
        'â™»ï¸': '♻️',  # Recycle
        'ðŸŒ¿': '🌿',  # Herb
        'ðŸŒ±': '🌱',  # Seedling
        'ðŸ"': '📍',  # Pushpin
        'âš¡': '⚡',  # Lightning
        'ðŸ'°': '💰',  # Money bag
        'ðŸ†': '🏆',  # Trophy
        'ðŸ'Ž': '💎',  # Gem
        'ðŸ"ˆ': '📈',  # Chart increasing
        'ðŸŽ': '🎁',  # Gift
        'ðŸŽ‰': '🎉',  # Party popper
        'ðŸ'': '👍',  # Thumbs up
        'ðŸ'¡': '💡',  # Light bulb
        'ðŸ›ï¸': '🛍️',  # Shopping bags
        'ðŸŽŠ': '🎊',  # Confetti ball
        'ðŸ'ª': '💪',  # Flexed biceps
        'ðŸŒ': '🌍',  # Globe
        'ðŸ"„': '🔄',  # Counterclockwise arrows
        'ðŸŒ³': '🌳',  # Deciduous tree
        'ðŸ'¤': '👤',  # Bust in silhouette
        'ðŸ"°': '📰',  # Newspaper
        'ðŸ¤': '🤝',  # Handshake
        'ðŸŽ¯': '🎯',  # Bullseye
        'ðŸ"'': '🔒',  # Locked
        
        # Adicionales que pueden existir
        'ðŸŽ"': '🎓',  # Graduation cap
        'ðŸ"±': '📱',  # Mobile phone
        'ðŸ–¥': '🖥️',  # Desktop computer
        'ðŸ"§': '📧',  # Email
        'ðŸ"¢': '📢',  # Loudspeaker
        'ðŸ"£': '📣',  # Megaphone
        'â¤ï¸': '❤️',  # Red heart
        'ðŸ'š': '💚',  # Green heart
        'ðŸ'™': '💙',  # Blue heart
        'ðŸ'›': '💛',  # Yellow heart
        'ðŸ§¡': '🧡',  # Orange heart
        'ðŸ'œ': '💜',  # Purple heart
        'ðŸ–¤': '🖤',  # Black heart
        'ðŸ¤': '🤍',  # White heart
        'ðŸ¤Ž': '🤎',  # Brown heart
        'âœ"': '✓',  # Check mark
        'âœ"ï¸': '✔️',  # Check mark button
        'âœ…': '✅',  # Check mark button
        'â†'': '↑',  # Up arrow
        'â†"': '↓',  # Down arrow
        'â†�': '←',  # Left arrow
        'â†'': '→',  # Right arrow
        'âž¡': '➡️',  # Right arrow
        'âž¡ï¸': '➡️',  # Right arrow (with variation selector)
        'â„¢': '™',  # Trademark
        'Â®': '®',  # Registered trademark
    }
    
    try:
        # Leer archivo
        with open(file_path, 'r', encoding='utf-8', errors='replace') as f:
            content = f.read()
        
        original_content = content
        total_changes = 0
        changes_detail = {}
        
        # Aplicar todas las correcciones
        for bad, good in emoji_map.items():
            count = content.count(bad)
            if count > 0:
                content = content.replace(bad, good)
                total_changes += count
                changes_detail[bad] = (good, count)
        
        # Guardar si hubo cambios
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            
            print(f"{'='*60}")
            print(f"CORRECCION COMPLETADA")
            print(f"{'='*60}")
            for bad, (good, count) in sorted(changes_detail.items(), key=lambda x: x[1][1], reverse=True):
                print(f"  '{bad}' -> '{good}' ({count} {'vez' if count == 1 else 'veces'})")
            print(f"{'='*60}")
            print(f"TOTAL: {total_changes} emojis corregidos")
            print(f"{'='*60}")
        else:
            print("No se encontraron emojis mal codificados.")
        
        # Verificar si quedan emojis mal codificados
        bad_patterns = ['ðŸ', 'â', 'Ã']
        remaining = sum(content.count(p) for p in bad_patterns)
        
        if remaining > 0:
            print(f"\nADVERTENCIA: Aun quedan {remaining} caracteres sospechosos")
            print("Buscando patrones no identificados...")
            
            lines_with_issues = []
            for i, line in enumerate(content.split('\n'), 1):
                if any(p in line for p in bad_patterns):
                    # Filtrar líneas con patrones legítimos
                    if 'área' not in line.lower() and 'categoría' not in line.lower():
                        lines_with_issues.append((i, line[:100]))
            
            if lines_with_issues:
                print(f"\nLineas con posibles problemas ({len(lines_with_issues)}):")
                for line_num, line_text in lines_with_issues[:5]:
                    print(f"  Linea {line_num}: {line_text}...")
        else:
            print("\nTODO CORREGIDO!")
        
        return total_changes
        
    except Exception as e:
        print(f"ERROR: {e}")
        import traceback
        traceback.print_exc()
        return 0

if __name__ == '__main__':
    find_and_fix_all_emojis()
