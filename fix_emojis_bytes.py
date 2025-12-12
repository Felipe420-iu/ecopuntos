#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Script para corregir emojis mal codificados usando bytes
"""
import codecs

def fix_emojis():
    """Corrige emojis mal codificados leyendo como bytes"""
    file_path = 'core/templates/core/index.html'
    
    # Pares de bytes mal codificados -> emoji correcto (como bytes UTF-8)
    fixes = [
        (b'\xc3\xa2\xc5\x93\xc2\xa8', '✨'.encode('utf-8')),  # âœ¨ -> ✨
        (b'\xc3\xb0\xc5\xb8\xc5\xa1\xc2\x80', '🚀'.encode('utf-8')),  # ðŸš€ -> 🚀
        (b'\xc3\xb0\xc5\xb8\xc5\x92\xc5\xb8', '🌟'.encode('utf-8')),  # ðŸŒŸ -> 🌟
        (b'\xc3\xa2\xc2\xad', '⭐'.encode('utf-8')),  # â­ -> ⭐
        (b'\xc3\xb0\xc5\xb8\xc2\x92\xc2\xab', '💫'.encode('utf-8')),  # ðŸ'« -> 💫
        (b'\xc3\xa2\xc2\x99\xc2\xbb\xc3\xaf\xc2\xb8', '♻️'.encode('utf-8')),  # â™»ï¸ -> ♻️
        (b'\xc3\xb0\xc5\xb8\xc5\x92\xc2\xbf', '🌿'.encode('utf-8')),  # ðŸŒ¿ -> 🌿
        (b'\xc3\xb0\xc5\xb8\xc5\x92\xc2\xb1', '🌱'.encode('utf-8')),  # ðŸŒ± -> 🌱
        (b'\xc3\xb0\xc5\xb8\xc2\x93', '📍'.encode('utf-8')),  # ðŸ" -> 📍
        (b'\xc3\xa2\xc5\xa1\xc2\xa1', '⚡'.encode('utf-8')),  # âš¡ -> ⚡
        (b'\xc3\xb0\xc5\xb8\xc2\x92\xc2\xb0', '💰'.encode('utf-8')),  # ðŸ'° -> 💰
        (b'\xc3\xb0\xc5\xb8\xc2\x86', '🏆'.encode('utf-8')),  # ðŸ† -> 🏆
        (b'\xc3\xb0\xc5\xb8\xc2\x92\xc2\x8e', '💎'.encode('utf-8')),  # ðŸ'Ž -> 💎
        (b'\xc3\xb0\xc5\xb8\xc2\x93\xcb\x86', '📈'.encode('utf-8')),  # ðŸ"ˆ -> 📈
        (b'\xc3\xb0\xc5\xb8\xc2\x8e', '🎁'.encode('utf-8')),  # ðŸŽ -> 🎁
        (b'\xc3\xb0\xc5\xb8\xc2\x8e\xc2\x89', '🎉'.encode('utf-8')),  # ðŸŽ‰ -> 🎉
        (b'\xc3\xb0\xc5\xb8\xc2\x92', '👍'.encode('utf-8')),  # ðŸ' -> 👍
        (b'\xc3\xb0\xc5\xb8\xc2\x92\xc2\xa1', '💡'.encode('utf-8')),  # ðŸ'¡ -> 💡
        (b'\xc3\xb0\xc5\xb8\xc2\x9b\xc3\xaf\xc2\xb8', '🛍️'.encode('utf-8')),  # ðŸ›ï¸ -> 🛍️
        (b'\xc3\xb0\xc5\xb8\xc2\x8e\xc5\xa0', '🎊'.encode('utf-8')),  # ðŸŽŠ -> 🎊
        (b'\xc3\xb0\xc5\xb8\xc2\x92\xc2\xaa', '💪'.encode('utf-8')),  # ðŸ'ª -> 💪
        (b'\xc3\xb0\xc5\xb8\xc5\x92', '🌍'.encode('utf-8')),  # ðŸŒ -> 🌍
        (b'\xc3\xb0\xc5\xb8\xc2\x93\xc2\x84', '🔄'.encode('utf-8')),  # ðŸ"„ -> 🔄
        (b'\xc3\xb0\xc5\xb8\xc5\x92\xc2\xb3', '🌳'.encode('utf-8')),  # ðŸŒ³ -> 🌳
        (b'\xc3\xb0\xc5\xb8\xc2\x92\xc2\xa4', '👤'.encode('utf-8')),  # ðŸ'¤ -> 👤
        (b'\xc3\xb0\xc5\xb8\xc2\x93\xc2\xb0', '📰'.encode('utf-8')),  # ðŸ"° -> 📰
        (b'\xc3\xb0\xc5\xb8\xc2\xa4', '🤝'.encode('utf-8')),  # ðŸ¤ -> 🤝
        (b'\xc3\xb0\xc5\xb8\xc2\x8e\xc2\xaf', '🎯'.encode('utf-8')),  # ðŸŽ¯ -> 🎯
        (b'\xc3\xb0\xc5\xb8\xc2\x93\xc2\x92', '🔒'.encode('utf-8')),  # ðŸ"' -> 🔒
    ]
    
    try:
        # Leer como bytes
        with open(file_path, 'rb') as f:
            content = f.read()
        
        total_fixes = 0
        
        # Aplicar cada corrección
        for bad_bytes, good_bytes in fixes:
            count = content.count(bad_bytes)
            if count > 0:
                content = content.replace(bad_bytes, good_bytes)
                total_fixes += count
                try:
                    bad_str = bad_bytes.decode('utf-8', errors='replace')
                    good_str = good_bytes.decode('utf-8')
                    print(f"Corregido '{bad_str}' -> '{good_str}' ({count} veces)")
                except:
                    print(f"Corregido bytes ({count} veces)")
        
        # Escribir como bytes
        with open(file_path, 'wb') as f:
            f.write(content)
        
        print(f"\nCOMPLETADO: {total_fixes} emojis corregidos")
        return True
        
    except Exception as e:
        print(f"ERROR: {str(e)}")
        import traceback
        traceback.print_exc()
        return False

if __name__ == '__main__':
    fix_emojis()
