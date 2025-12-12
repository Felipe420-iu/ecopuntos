#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Script para corregir TODOS los emojis corruptos y errores ortográficos en index.html
"""

import os

def fix_all_emojis():
    file_path = 'core/templates/core/index.html'
    
    print("🔍 Leyendo archivo...")
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # Lista completa de correcciones (emojis + ortografía)
    corrections = [
        # Emojis corruptos → Emojis correctos
        ('ðŸ'«', '💫'),  # Estrellas brillantes
        ('ðŸŽ¯', '🎯'),  # Diana
        ('ðŸ"'', '🔒'),  # Candado
        ('â™»ï¸', '♻️'),  # Reciclaje
        ('ðŸ"', '📍'),  # Pin de ubicación
        ('ðŸ'°', '💰'),  # Bolsa de dinero
        ('ðŸ†', '🏆'),  # Trofeo
        ('ðŸ'Ž', '💎'),  # Diamante
        ('ðŸ"ˆ', '📈'),  # Gráfico creciente
        ('ðŸŽ', '🎁'),  # Regalo
        ('ðŸŽ‰', '🎉'),  # Confeti
        ('ðŸ'', '👍'),  # Pulgar arriba
        ('ðŸ›ï¸', '🛍️'),  # Bolsas de compras
        ('ðŸŽŠ', '🎊'),  # Bola de confeti
        ('ðŸš€', '🚀'),  # Cohete
        ('ðŸ'¡', '💡'),  # Bombilla
        ('ðŸ'ª', '💪'),  # Brazo fuerte
        ('ðŸ"„', '🔄'),  # Flechas en círculo
        ('ðŸ"°', '📰'),  # Periódico
        ('ðŸ'¤', '👤'),  # Busto silueta
        ('🌍³', '🌳'),  # Árbol (era globo + superíndice 3)
        
        # Errores ortográficos
        ('Írboles', 'Árboles'),  # I-acute → A-acute
        ('Íreas', 'Áreas'),      # I-acute → A-acute
    ]
    
    # Aplicar todas las correcciones
    corrections_count = 0
    for old, new in corrections:
        occurrences = content.count(old)
        if occurrences > 0:
            content = content.replace(old, new)
            corrections_count += occurrences
            print(f"  ✓ '{old}' → '{new}' ({occurrences} veces)")
    
    # Guardar archivo corregido
    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"\n✅ ¡Archivo corregido exitosamente!")
        print(f"📝 Total de correcciones aplicadas: {corrections_count}")
        print(f"📄 Archivo: {file_path}")
    else:
        print("\n⚠️  No se encontraron errores para corregir")
    
    return corrections_count

if __name__ == '__main__':
    try:
        count = fix_all_emojis()
        if count > 0:
            print(f"\n🎉 ¡Proceso completado! Se corrigieron {count} instancias.")
        else:
            print("\n✨ El archivo ya está perfecto")
    except Exception as e:
        print(f"\n❌ Error: {e}")
        import traceback
        traceback.print_exc()
