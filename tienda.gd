extends Control

# --- REFERENCIAS A TUS NODOS ---
@onready var label_monedas = $ContenedorPrincipal/Cabecera/LabelMonedas
@onready var contenedor_grid = $ContenedorPrincipal/ScrollContainer/GridContainer
@onready var plantilla = $ContenedorPrincipal/ScrollContainer/GridContainer/PlantillaItem

var botones_tienda = {} 

func _ready():
	actualizar_texto_monedas()
	generar_escaparate()
	
	if has_node("ContenedorPrincipal/Cabecera/BtnVolver"):
		$ContenedorPrincipal/Cabecera/BtnVolver.pressed.connect(_on_btn_volver_pressed)

func actualizar_texto_monedas():
	if label_monedas:
		label_monedas.text = "COINS: 🪙 " + str(Global.monedas)

func generar_escaparate():
	plantilla.visible = false
	
	for item in Global.catalogo_fondos:
		var nueva_tarjeta = plantilla.duplicate()
		nueva_tarjeta.visible = true
		
		# Referencias de la tarjeta
		var preview = nueva_tarjeta.get_node("PreviewFondo")
		var imagen_rect = preview.get_node("ImagenFondo") # <-- Buscamos el nuevo nodo de imagen
		var lbl_nombre = nueva_tarjeta.get_node("NombreFondo")
		var lbl_precio = nueva_tarjeta.get_node("PrecioFondo")
		var boton = nueva_tarjeta.get_node("BotonComprar")
		
		# Lógica para mostrar Foto o Color
		if item["ruta_imagen"] != "":
			imagen_rect.texture = load(item["ruta_imagen"])
			imagen_rect.visible = true
			preview.color = Color.WHITE # Fondo neutro detrás de la foto
		else:
			imagen_rect.visible = false
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
		boton_pulsado.text = "NOT ENOUGH COINS"
		boton_pulsado.modulate = Color.RED
		await get_tree().create_timer(1.0).timeout
		if is_instance_valid(boton_pulsado):
			actualizar_estado_boton(boton_pulsado, lbl_precio, item_data)

func refrescar_todos_los_botones():
	for item in Global.catalogo_fondos:
		var id = item["id"]
		if botones_tienda.has(id):
			var refs = botones_tienda[id]
			actualizar_estado_boton(refs["boton"], refs["precio"], item)

func _on_btn_volver_pressed():
	get_tree().change_scene_to_file("res://MenuPrincipal.tscn")
