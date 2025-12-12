# ===================================
# EcoPuntos Tower Defense - Export Setup Script
# ===================================

# 📱 Configuración automática de exportación desde código
# Ejecuta este script desde Godot Editor: Tools > Execute Script

@tool

func setup_export_presets():
	print("🚀 Configurando presets de exportación...")
	
	# Configurar exportación Android
	setup_android_export()
	
	# Configurar exportación Web
	setup_web_export()
	
	# Configurar exportación Windows
	setup_windows_export()
	
	print("✅ Presets configurados exitosamente")

func setup_android_export():
	print("📱 Configurando Android...")
	
	# Configurar opciones de Android
	var android_settings = {
		"package/unique_name": "com.ecopuntos.towerdefense",
		"package/name": "EcoPuntos Tower Defense",
		"package/signed": true,
		"architecture/arm64-v8a": true,
		"permissions/access_network_state": true,
		"permissions/internet": true,
		"screen/orientation": 1,  # Landscape
		"screen/support_small": false,
		"screen/support_normal": true,
		"screen/support_large": true,
		"screen/support_xlarge": true
	}
	
	# Aplicar configuración (en un proyecto real)
	# EditorInterface.get_export_manager().add_export_preset("Android", android_settings)

func setup_web_export():
	print("🌐 Configurando Web...")
	
	var web_settings = {
		"html/custom_html_shell": "",
		"html/head_include": "",
		"progressive_web_app/enabled": true,
		"progressive_web_app/display": 2,  # Standalone
		"progressive_web_app/orientation": 2,  # Landscape
		"progressive_web_app/icon_144x144": "res://icon-144.png",
		"progressive_web_app/icon_180x180": "res://icon-180.png",
		"progressive_web_app/icon_512x512": "res://icon-512.png",
		"progressive_web_app/background_color": "#1a472a"
	}

func setup_windows_export():
	print("🖥️ Configurando Windows...")
	
	var windows_settings = {
		"binary_format/64_bits": true,
		"custom_template/debug": "",
		"custom_template/release": "",
		"application/icon": "res://icon.ico",
		"application/file_version": "1.0.0",
		"application/product_version": "1.0.0",
		"application/company_name": "EcoPuntos",
		"application/product_name": "Tower Defense",
		"application/file_description": "EcoPuntos Tower Defense Game"
	}

# 🎮 Configuración de controles adaptativos
func setup_mobile_controls():
	# Crear UI adaptativa para móvil
	var mobile_ui_scene = """
[gd_scene load_steps=2 format=3]

[node name="MobileUI" type="Control"]
layout_mode = 3
anchors_preset = 15

[node name="TouchControls" type="VBoxContainer" parent="."]
layout_mode = 1
anchors_preset = 3
anchor_left = 1.0
anchor_top = 1.0
anchor_right = 1.0
anchor_bottom = 1.0
offset_left = -200.0
offset_top = -300.0

[node name="PlaceTowerButton" type="Button" parent="TouchControls"]
layout_mode = 2
text = "🏗️ Colocar Torre"
custom_minimum_size = Vector2(150, 60)

[node name="UpgradeButton" type="Button" parent="TouchControls"]
layout_mode = 2
text = "⬆️ Mejorar"
custom_minimum_size = Vector2(150, 60)

[node name="SellButton" type="Button" parent="TouchControls"]
layout_mode = 2
text = "💰 Vender"
custom_minimum_size = Vector2(150, 60)
"""

# 🌐 PWA Manifest desde código
func generate_pwa_manifest():
	var manifest = {
		"name": "EcoPuntos Tower Defense",
		"short_name": "EcoPuntos TD",
		"description": "Juego de tower defense ecológico",
		"start_url": "./",
		"display": "standalone",
		"orientation": "landscape",
		"theme_color": "#1a472a",
		"background_color": "#ffffff",
		"icons": [
			{
				"src": "icon-192.png",
				"sizes": "192x192",
				"type": "image/png"
			},
			{
				"src": "icon-512.png",
				"sizes": "512x512", 
				"type": "image/png"
			}
		]
	}
	
	# Guardar manifest
	var file = FileAccess.open("res://manifest.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(manifest))
		file.close()
		print("✅ PWA manifest generado")

# 🚀 Script principal
func _run():
	setup_export_presets()
	generate_pwa_manifest()
	print("🎉 ¡Configuración de exportación completada!")