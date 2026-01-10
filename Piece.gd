extends Node2D

# --- SEÑAL ACTUALIZADA ---
# Ahora enviamos dos cosas:
# 1. "self": Enviamos la propia pieza para que el juego sepa CUÁL de las 3 es.
# 2. "global_position": Dónde la has soltado.
signal pieza_soltada(pieza_misma, posicion_global) 

var block_texture = preload("res://block_texture.tres")

# Configuración por defecto (se cambiará luego con set_configuration)
@export var piece_color: Color = Color.ORANGE
var cells = [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(1,1)]

@onready var visuals = $Visuals

# Variables de arrastre
var dragging = false
var offset_mouse = Vector2.ZERO 

func _ready():
	draw_piece()

# Función para cambiar la forma y color desde fuera (MainGame)
func set_configuration(new_cells, new_color):
	cells = new_cells
	piece_color = new_color
	
	# 1. Redibujamos los bloques
	draw_piece()
	
	# 2. Recalculamos el tamaño de la caja de colisión
	var min_x = 0
	var max_x = 0
	var min_y = 0
	var max_y = 0
	
	for cell in cells:
		if cell.x < min_x: min_x = cell.x
		if cell.x > max_x: max_x = cell.x
		if cell.y < min_y: min_y = cell.y
		if cell.y > max_y: max_y = cell.y
	
	# El ancho total es (max - min + 1) * tamaño de celda
	var width = (max_x - min_x + 1) * 64
	var height = (max_y - min_y + 1) * 64
	
	# Accedemos al CollisionShape2D y actualizamos su tamaño y posición
	# IMPORTANTE: Asumimos que la estructura es Piece -> Area2D -> CollisionShape2D
	var collider = $Area2D/CollisionShape2D
	collider.shape.size = Vector2(width, height)
	
	# Centramos el colisionador en la nueva forma
	collider.position = Vector2(width/2, height/2)

func draw_piece():
	# Limpiamos lo anterior
	for child in visuals.get_children():
		child.queue_free()
	
	# Dibujamos lo nuevo
	for cell in cells:
		var block = Sprite2D.new()
		block.texture = block_texture
		block.modulate = piece_color
		block.position = Vector2(cell.x * 64, cell.y * 64)
		visuals.add_child(block)

func _process(delta):
	if dragging:
		global_position = get_global_mouse_position() + offset_mouse

# Detección del click inicial
func _on_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			offset_mouse = global_position - get_global_mouse_position()
			scale = Vector2(1.1, 1.1) # Hacemos la pieza un poco más grande
			z_index = 10 # La ponemos por encima de todo

# Detección de soltar el click
func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and dragging:
			dragging = false
			scale = Vector2(1, 1) # Volver tamaño normal
			z_index = 0
			
			# --- AQUÍ ESTÁ LA CLAVE ---
			# Avisamos al juego: "Soy YO (self) y me han soltado AQUÍ"
			pieza_soltada.emit(self, global_position)
