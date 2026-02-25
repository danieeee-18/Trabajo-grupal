extends Control

# --- REFERENCIAS A TUS NODOS (Mantenemos los nombres en español para no romper la escena) ---
@onready var label_monedas = $ContenedorPrincipal/Cabecera/LabelMonedas
@onready var contenedor_grid = $ContenedorPrincipal/ScrollContainer/GridContainer
@onready var plantilla = $ContenedorPrincipal/ScrollContainer/GridContainer/PlantillaItem

# --- EL CATÁLOGO (Traducido al inglés) ---
var catalogo_fondos = [
	{"id": "base", "nombre": "Classic", "precio": 0, "color": Color(0.2, 0.2, 0.25)},
	{"id": "neon", "nombre": "Cyberpunk", "precio": 100, "color": Color(0.8, 0.1, 0.5)},
	{"id": "bosque", "nombre": "Zen Forest", "precio": 250, "color": Color(0.1, 0.6, 0.3)},
	{"id": "oro", "nombre": "King Midas", "precio": 500, "color": Color(0.9, 0.7, 0.1)},
	{"id": "hielo", "nombre": "Glacier", "precio": 800, "color": Color(0.4, 0.9, 1.0)}
]

var botones_tienda = {} 

func _ready():
	actualizar_texto_monedas()
	generar_escaparate()
	
	if has_node("ContenedorPrincipal/Cabecera/BtnVolver"):
		$ContenedorPrincipal/Cabecera/BtnVolver.pressed.connect(_on_btn_volver_pressed)

func actualizar_texto_monedas():
	if label_monedas:
		# Texto traducido
		label_monedas.text = "COINS: 🪙 " + str(Global.monedas)

func generar_escaparate():
	plantilla.visible = false
	
	for item in catalogo_fondos:
		var nueva_tarjeta = plantilla.duplicate()
		nueva_tarjeta.visible = true
		
		var preview = nueva_tarjeta.get_node("PreviewFondo")
		var lbl_nombre = nueva_tarjeta.get_node("NombreFondo")
		var lbl_precio = nueva_tarjeta.get_node("PrecioFondo")
		var boton = nueva_tarjeta.get_node("BotonComprar")
		
		preview.color = item["color"]
		lbl_nombre.text = item["nombre"]
		
		actualizar_estado_boton(boton, lbl_precio, item)
		
		boton.pressed.connect(func(): _on_item_comprado(item, boton, lbl_precio))
		
		botones_tienda[item["id"]] = {"boton": boton, "precio": lbl_precio}
		contenedor_grid.add_child(nueva_tarjeta)

# --- TEXTOS DE BOTONES EN INGLÉS ---
func actualizar_estado_boton(boton, lbl_precio, item):
	if item["id"] == Global.fondo_equipado:
		boton.text = "EQUIPPED"
		boton.modulate = Color.GREEN
		lbl_precio.text = "In use"
	elif item["id"] in Global.fondos_desbloqueados:
		boton.text = "EQUIP"
		boton.modulate = Color.YELLOW
		lbl_precio.text = "Owned"
	else:
		boton.text = "BUY"
		boton.modulate = Color.WHITE
		lbl_precio.text = "🪙 " + str(item["precio"])

func _on_item_comprado(item_data, boton_pulsado, lbl_precio):
	var tween = create_tween()
	boton_pulsado.scale = Vector2(0.8, 0.8)
	tween.tween_property(boton_pulsado, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_BACK)
	
	var id_item = item_data["id"]
	
	if id_item in Global.fondos_desbloqueados:
		Global.fondo_equipado = id_item
		Global.save_game() 
		refrescar_todos_los_botones()
		return
		
	if Global.monedas >= item_data["precio"]:
		Global.monedas -= item_data["precio"]
		actualizar_texto_monedas()
		
		Global.fondos_desbloqueados.append(id_item)
		Global.fondo_equipado = id_item
		Global.save_game() 
		
		refrescar_todos_los_botones()
		
	else:
		# Texto de error traducido
		boton_pulsado.text = "NOT ENOUGH COINS"
		boton_pulsado.modulate = Color.RED
		await get_tree().create_timer(1.0).timeout
		if is_instance_valid(boton_pulsado):
			actualizar_estado_boton(boton_pulsado, lbl_precio, item_data)

func refrescar_todos_los_botones():
	for item in catalogo_fondos:
		var id = item["id"]
		if botones_tienda.has(id):
			var refs = botones_tienda[id]
			actualizar_estado_boton(refs["boton"], refs["precio"], item)

func _on_btn_volver_pressed():
	get_tree().change_scene_to_file("res://MenuPrincipal.tscn")
