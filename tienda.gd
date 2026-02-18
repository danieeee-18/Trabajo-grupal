extends Control

# --- REFERENCIAS A TUS NODOS ---
@onready var label_monedas = $ContenedorPrincipal/Cabecera/LabelMonedas
@onready var contenedor_grid = $ContenedorPrincipal/ScrollContainer/GridContainer
@onready var plantilla = $ContenedorPrincipal/ScrollContainer/GridContainer/PlantillaItem

# --- EL CATÁLOGO (Tu diseño) ---
var catalogo_fondos = [
	{"id": "base", "nombre": "Clásico", "precio": 0, "color": Color(0.2, 0.2, 0.25)},
	{"id": "neon", "nombre": "Cyberpunk", "precio": 100, "color": Color(0.8, 0.1, 0.5)},
	{"id": "bosque", "nombre": "Bosque Zen", "precio": 250, "color": Color(0.1, 0.6, 0.3)},
	{"id": "oro", "nombre": "Rey Midas", "precio": 500, "color": Color(0.9, 0.7, 0.1)},
	{"id": "hielo", "nombre": "Glaciar", "precio": 800, "color": Color(0.4, 0.9, 1.0)}
]

func _ready():
	actualizar_texto_monedas()
	generar_escaparate()
	
	# Conectar el botón de volver
	$ContenedorPrincipal/Cabecera/BtnVolver.pressed.connect(_on_btn_volver_pressed)

func actualizar_texto_monedas():
	if label_monedas:
		label_monedas.text = "MONEDAS: 🪙 " + str(Global.monedas)

func generar_escaparate():
	# 1. Escondemos tu plantilla original para que sirva solo de molde
	plantilla.visible = false
	
	# 2. Fabricamos las tarjetas automáticamente
	for item in catalogo_fondos:
		var nueva_tarjeta = plantilla.duplicate()
		nueva_tarjeta.visible = true
		
		# 3. Buscamos las partes dentro de la nueva tarjeta
		var preview = nueva_tarjeta.get_node("PreviewFondo")
		var lbl_nombre = nueva_tarjeta.get_node("NombreFondo")
		var lbl_precio = nueva_tarjeta.get_node("PrecioFondo")
		var boton = nueva_tarjeta.get_node("BotonComprar")
		
		# 4. Rellenamos con los colores y textos
		preview.color = item["color"]
		lbl_nombre.text = item["nombre"]
		lbl_precio.text = "🪙 " + str(item["precio"])
		
		# 5. Conectamos el botón al código
		boton.pressed.connect(_on_item_comprado.bind(item, boton))
		
		# 6. Añadimos la tarjeta a la cuadrícula
		contenedor_grid.add_child(nueva_tarjeta)

# --- ANIMACIÓN AL PULSAR COMPRAR ---
func _on_item_comprado(item_data, boton_pulsado):
	# Efecto rebote del botón
	var tween = create_tween()
	boton_pulsado.scale = Vector2(0.8, 0.8)
	tween.tween_property(boton_pulsado, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_BACK)
	
	# Simulación visual
	if Global.monedas >= item_data["precio"]:
		boton_pulsado.text = "EQUIPADO"
		boton_pulsado.modulate = Color.GREEN
		# Tu compi meterá la lógica de restar monedas aquí
	else:
		boton_pulsado.text = "SIN FONDOS"
		boton_pulsado.modulate = Color.RED
		await get_tree().create_timer(1.0).timeout
		boton_pulsado.text = "COMPRAR"
		boton_pulsado.modulate = Color.WHITE

func _on_btn_volver_pressed():
	get_tree().change_scene_to_file("res://MenuPrincipal.tscn")
