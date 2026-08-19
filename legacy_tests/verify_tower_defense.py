#!/usr/bin/env python
"""
Script de verificación para el proyecto Tower Defense en Godot
"""
import os
import sys

def check_godot_project():
    """Verifica que el proyecto de Godot esté correctamente configurado"""
    print("🔍 Verificando proyecto Tower Defense...")
    
    base_path = r"c:\Users\FELIPE MARTINEZ\Desktop\ecopuntos1.0\TowerDefenseEco"
    
    required_files = [
        "project.godot",
        "Main.tscn", 
        "GameWorld.tscn",
        "scripts/core/Main.gd",
        "scripts/core/GameWorld.gd",
        "scripts/core/GameManager.gd",
        "scripts/utils/Constants.gd",
        "scripts/gameplay/enemies/PlasticWaste.gd",
        "scripts/gameplay/enemies/visual_placeholder.gd",
        "scenes/gameplay/enemies/PlasticWaste.tscn"
    ]
    
    missing_files = []
    existing_files = []
    
    for file_path in required_files:
        full_path = os.path.join(base_path, file_path)
        if os.path.exists(full_path):
            existing_files.append(file_path)
            print(f"✅ {file_path}")
        else:
            missing_files.append(file_path)
            print(f"❌ {file_path}")
    
    print(f"\n📊 Resumen:")
    print(f"   Archivos existentes: {len(existing_files)}")
    print(f"   Archivos faltantes: {len(missing_files)}")
    
    if missing_files:
        print(f"\n⚠️ Archivos faltantes:")
        for file_path in missing_files:
            print(f"   - {file_path}")
    
    return len(missing_files) == 0

def check_project_structure():
    """Verifica la estructura de carpetas del proyecto"""
    print(f"\n🗂️ Verificando estructura de carpetas...")
    
    base_path = r"c:\Users\FELIPE MARTINEZ\Desktop\ecopuntos1.0\TowerDefenseEco"
    
    required_dirs = [
        "scripts",
        "scripts/core",
        "scripts/gameplay",
        "scripts/gameplay/enemies",
        "scripts/utils",
        "scenes",
        "scenes/gameplay",
        "scenes/gameplay/enemies"
    ]
    
    for dir_path in required_dirs:
        full_path = os.path.join(base_path, dir_path)
        if os.path.exists(full_path):
            print(f"✅ {dir_path}/")
        else:
            print(f"❌ {dir_path}/")
            os.makedirs(full_path, exist_ok=True)
            print(f"   📁 Creada carpeta: {dir_path}/")

if __name__ == '__main__':
    print("🚀 Iniciando verificación del proyecto Tower Defense...\n")
    
    check_project_structure()
    success = check_godot_project()
    
    if success:
        print("\n✅ ¡Proyecto verificado exitosamente!")
        print("\n🎮 Pasos para probar:")
        print("1. Abre Godot 4.5.1")
        print("2. Importa el proyecto desde: TowerDefenseEco/")
        print("3. Ejecuta la escena Main.tscn")
        print("4. Presiona ESPACIO para generar enemigos manualmente")
        print("5. Los enemigos deberían moverse por el path automáticamente")
        
        print("\n🔧 Controles:")
        print("- ESPACIO: Generar enemy manual")
        print("- ESC: Salir del juego")
        
    else:
        print("\n❌ Faltan archivos importantes. Revisa los errores anteriores.")
    
    print("\n🎯 ¡Verificación completada!")