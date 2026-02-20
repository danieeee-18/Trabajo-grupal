# res://Piece.gd
extends Node2D

signal pieza_soltada(pieza_self, posicion_global)
signal pieza_arrastrada(pieza, posicion)

var block_texture = preload("res://block_texture.tres")

# Ahora usamos el recurso para configurar la pieza
var current_data: PieceData

@onready var visuals = $Visuals
@onready var collider = $Area2D/CollisionShape2D

var dragging = false
var offset_mouse = Vector2.ZERO 

func set_configuration(data: PieceData):
	current_data = data
	draw_piece()
	update_collider()

func draw_piece():
	for child in visuals.get_children():
		child.queue_free()
	
	for cell in current_data.cells:
		var block = Sprite2D.new()
		block.texture = block_texture
		block.modulate = current_data.color
		block.position = Vector2(cell.x * 64, cell.y * 64)
		visuals.add_child(block)

func update_collider():
	var min_p = Vector2i(0,0)
	var max_p = Vector2i(0,0)
	for cell in current_data.cells:
		min_p.x = min(min_p.x, cell.x)
		max_p.x = max(max_p.x, cell.x)
		min_p.y = min(min_p.y, cell.y)
		max_p.y = max(max_p.y, cell.y)
	
	var width = (max_p.x - min_p.x + 1) * 64
	var height = (max_p.y - min_p.y + 1) * 64
	collider.shape.size = Vector2(width, height)
	collider.position = Vector2(width/2 - 32, height/2 - 32) # Ajuste de centro

func _process(_delta):
	if dragging:
		global_position = get_global_mouse_position() + offset_mouse
		pieza_arrastrada.emit(self, global_position)

func _on_area_2d_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			offset_mouse = global_position - get_global_mouse_position()
			scale = Vector2(1.1, 1.1)
			z_index = 10

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and dragging:
			dragging = false
			scale = Vector2(1.0, 1.0)
			z_index = 0
			pieza_soltada.emit(self, global_position)
