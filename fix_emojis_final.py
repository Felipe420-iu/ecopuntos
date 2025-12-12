#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Script para corregir emojis mal codificados en index.html
"""

# Diccionario de emojis mal codificados → emojis correctos
EMOJI_FIXES = {
    'âœ¨': '✨',
    'ðŸš€': '🚀',
    'ðŸŒŸ': '🌟',
    'â­': '⭐',
    'ðŸ'«': '💫',
    'â™»ï¸': '♻️',
    'ðŸŒ¿': '🌿',
    'ðŸŒ±': '🌱',
    'ðŸ"': '📍',
    'âš¡': '⚡',
    'ðŸ'°': '💰',
    'ðŸ†': '🏆',
    'ðŸ'Ž': '💎',
    'ðŸ"ˆ': '📈',
    'ðŸŽ': '🎁',
    'ðŸŽ‰': '🎉',
    'ðŸ'': '👍',
    'ðŸ'¡': '💡',
    'ðŸ›ï¸': '🛍️',
    'ðŸŽŠ': '🎊',
    'ðŸ'ª': '💪',
    'ðŸŒ': '🌍',
    'ðŸ"„': '🔄',
    'ðŸŒ³': '🌳',
    'ðŸ'¤': '👤',
    'ðŸ"°': '📰',
    'ðŸ¤': '🤝',
    'ðŸŽ¯': '🎯',
    'ðŸ"'': '🔒',
}

def fix_emojis():
    """Corrige todos los emojis mal codificados en index.html"""
    file_path = 'core/templates/core/index.html'
    
    try:
        # Leer el archivo con encoding UTF-8
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Contar correcciones
        total_fixes = 0
        
        # Aplicar cada corrección
        for bad_emoji, good_emoji in EMOJI_FIXES.items():
            count = content.count(bad_emoji)
            if count > 0:
                content = content.replace(bad_emoji, good_emoji)
                total_fixes += count
                print(f"✓ Corregido '{bad_emoji}' → '{good_emoji}' ({count} veces)")
        
        # Guardar el archivo corregido
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        
        print(f"\n✅ COMPLETADO: {total_fixes} emojis corregidos en {file_path}")
        return True
        
    except Exception as e:
        print(f"❌ ERROR: {str(e)}")
        return False

if __name__ == '__main__':
    fix_emojis()
