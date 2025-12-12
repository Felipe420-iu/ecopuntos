import codecs

# Leer archivo
with codecs.open('core/templates/core/index.html', 'r', 'utf-8') as f:
    lines = f.readlines()

# Correcciones línea por línea
changes = {
    175: ('ðŸ"'', '🔒'),
    231: ('ðŸ†', '🏆'),
    270: ('ðŸ›ï¸', '🛍️'),
    270: ('🎁Š', '🎊'),
    292: ('ðŸš€', '🚀'),
    658: ('ðŸ"„', '🔄'),
    961: ('ðŸ'¤', '👤'),
    962: ('ðŸ'¤', '👤'),
    963: ('ðŸ'¤', '👤'),
}

for line_num, (old, new) in changes.items():
    idx = line_num - 1
    if old in lines[idx]:
        lines[idx] = lines[idx].replace(old, new)
        print(f'Línea {line_num}: OK')

# Guardar
with codecs.open('core/templates/core/index.html', 'w', 'utf-8') as f:
    f.writelines(lines)

print('Completado')
