#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Script final para corregir TODOS los emojis restantes
"""

def fix_remaining_emojis():
    file_path = 'core/templates/core/index.html'
    
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    
    # Patrones adicionales que pueden haber quedado
    additional_fixes = [
        # Buscar cualquier variación de bytes corruptos
        ('ðŸ'«', '💫'),
        ('ðŸŽ¯', '🎯'),
        ('ðŸ"'', '🔒'),
        ('â™»ï¸', '♻️'),
        ('ðŸ"', '📍'),
        ('ðŸ'°', '💰'),
        ('ðŸ†', '🏆'),
        ('ðŸ'Ž', '💎'),
        ('ðŸ"ˆ', '📈'),
        ('ðŸŽ', '🎁'),
        ('ðŸŽ‰', '🎉'),
        ('ðŸ'', '👍'),
        ('ðŸ›ï¸', '🛍️'),
        ('ðŸŽŠ', '🎊'),
        ('ðŸš€', '🚀'),
        ('ðŸ'¡', '💡'),
        ('ðŸ'ª', '💪'),
        ('ðŸ"„', '🔄'),
        ('ðŸ"°', '📰'),
        ('ðŸ'¤', '👤'),
        ('Írboles', 'Árboles'),
        ('Íreas', 'Áreas'),
    ]
    
    count = 0
    for old, new in additional_fixes:
        n = content.count(old)
        if n > 0:
            content = content.replace(old, new)
            count += n
            print(f"  {old} -> {new}: {n} veces")
    
    if content != original:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"\nTotal adicional corregido: {count}")
    else:
        print("\nNo hay correcciones adicionales necesarias")
    
    # Verificar errores restantes
    print("\n=== VERIFICACIÓN FINAL ===")
    errors_found = []
    
    # Buscar patrones de bytes corruptos
    corrupt_patterns = ['ðŸ', 'â™', 'Í']
    for pattern in corrupt_patterns:
        if pattern in content:
            errors_found.append(f"Patrón '{pattern}' aún presente")
    
    if errors_found:
        print("⚠️  Errores restantes:")
        for error in errors_found:
            print(f"  - {error}")
    else:
        print("✅ ¡TODO CORREGIDO! No se encontraron más errores")
    
    return count

if __name__ == '__main__':
    fix_remaining_emojis()
