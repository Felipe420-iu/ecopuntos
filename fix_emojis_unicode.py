#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Script para corregir TODOS los emojis corruptos y errores ortográficos en index.html
Usa códigos Unicode para evitar problemas de codificación
"""

def fix_all_emojis():
    file_path = 'core/templates/core/index.html'
    
    print("Leyendo archivo...")
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original_content = content
    
    # Usar búsqueda y reemplazo de patrones corruptos específicos
    # Estos son los bytes corruptos que aparecen en el archivo
    corrections = [
        # Emojis corruptos (bytes UTF-8 mal interpretados)
        ('\u00f0\u0178\u2018\u00ab', '\U0001F4AB'),  # 💫 Estrellas
        ('\u00f0\u0178\u017d\u00af', '\U0001F3AF'),  # 🎯 Diana
        ('\u00f0\u0178\u201d\u2018', '\U0001F512'),  # 🔒 Candado
        ('\u00e2\u2122\u00bb\u00ef\u00b8\u008f', '\u267B\uFE0F'),  # ♻️ Reciclaje
        ('\u00f0\u0178\u201c', '\U0001F4CD'),  # 📍 Pin
        ('\u00f0\u0178\u2019\u00b0', '\U0001F4B0'),  # 💰 Dinero
        ('\u00f0\u0178\u2020', '\U0001F3C6'),  # 🏆 Trofeo
        ('\u00f0\u0178\u2019\u017d', '\U0001F48E'),  # 💎 Diamante
        ('\u00f0\u0178\u201c\u02c6', '\U0001F4C8'),  # 📈 Gráfico
        ('\u00f0\u0178\u017d', '\U0001F381'),  # 🎁 Regalo
        ('\u00f0\u0178\u017d\u2030', '\U0001F389'),  # 🎉 Confeti
        ('\u00f0\u0178\u2019', '\U0001F44D'),  # 👍 Pulgar
        ('\u00f0\u0178\u203a\u00ef\u00b8\u008f', '\U0001F6CD\uFE0F'),  # 🛍️ Bolsas
        ('\u00f0\u0178\u017d\u0160', '\U0001F38A'),  # 🎊 Bola
        ('\u00f0\u0178\u161a\u20ac', '\U0001F680'),  # 🚀 Cohete
        ('\u00f0\u0178\u2019\u00a1', '\U0001F4A1'),  # 💡 Bombilla
        ('\u00f0\u0178\u2019\u00aa', '\U0001F4AA'),  # 💪 Brazo
        ('\u00f0\u0178\u201c\u201e', '\U0001F504'),  # 🔄 Círculo
        ('\u00f0\u0178\u201c\u00b0', '\U0001F4F0'),  # 📰 Periódico
        ('\u00f0\u0178\u2019\u00a4', '\U0001F464'),  # 👤 Silueta
        ('\U0001F30D\u00b3', '\U0001F333'),  # 🌳 Árbol (globo+³ → árbol)
        
        # Errores ortográficos
        ('\u00cdrboles', 'Árboles'),  # Írboles → Árboles
        ('\u00cdreas', 'Áreas'),      # Íreas → Áreas
    ]
    
    # Aplicar correcciones
    corrections_count = 0
    for old, new in corrections:
        count = content.count(old)
        if count > 0:
            content = content.replace(old, new)
            corrections_count += count
            print(f"  Corregido: {count} instancias")
    
    # Guardar
    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"\nArchivo corregido exitosamente!")
        print(f"Total de correcciones: {corrections_count}")
    else:
        print("\nNo se encontraron errores")
    
    return corrections_count

if __name__ == '__main__':
    fix_all_emojis()
