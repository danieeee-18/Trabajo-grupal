extends Node2D

# Al principio, con las otras variables @onready
const GAME_OVER_SCENE = preload("res://GameOver.tscn") # Asegúrate de que la ruta sea correcta
@onready var board = $Board
@onready var pieces_array = [$Piece, $Piece2, $Piece3]
@onready var markers = [$PosicionPieza1, $PosicionPieza2, $PosicionPieza3]

# --- NUEVO: ETIQUETA DE PUNTUACIÓN ---
@onready var score_label = $ScoreLabel 

# Variables de juego
var start_positions = {}
var score = 0
var high_score = 0

# --- BASE DE DATOS DE PIEZAS (COMPLETA) ---
var shapes_database = [
	# 1. LÍNEAS
	{"name": "Line_H_2", "color": Color.PINK, "cells": [Vector2i(0,0), Vector2i(1,0)]},
	{"name": "Line_H_3", "color": Color.HOT_PINK, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0)]},
	{"name": "Line_H_4", "color": Color.CYAN, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(3,0)]},
	{"name": "Line_H_5", "color": Color.TURQUOISE, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(3,0), Vector2i(4,0)]},
	{"name": "Line_V_2", "color": Color.PINK, "cells": [Vector2i(0,0), Vector2i(0,1)]},
	{"name": "Line_V_3", "color": Color.HOT_PINK, "cells": [Vector2i(0,0), Vector2i(0,1), Vector2i(0,2)]},
	{"name": "Line_V_4", "color": Color.CYAN, "cells": [Vector2i(0,0), Vector2i(0,1), Vector2i(0,2), Vector2i(0,3)]},
	{"name": "Line_V_5", "color": Color.TURQUOISE, "cells": [Vector2i(0,0), Vector2i(0,1), Vector2i(0,2), Vector2i(0,3), Vector2i(0,4)]},

	# 2. CUADRADOS
	{"name": "Square_2x2", "color": Color.ORANGE, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(1,1)]},
	{"name": "Square_3x3", "color": Color.RED, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0),Vector2i(0,1), Vector2i(1,1), Vector2i(2,1),Vector2i(0,2), Vector2i(1,2), Vector2i(2,2)]},

	# 3. T SHAPES
	{"name": "T_Down",  "color": Color.PURPLE, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(1,1)]}, 
	{"name": "T_Up",    "color": Color.PURPLE, "cells": [Vector2i(1,0), Vector2i(0,1), Vector2i(1,1), Vector2i(2,1)]}, 
	{"name": "T_Left",  "color": Color.PURPLE, "cells": [Vector2i(1,0), Vector2i(1,1), Vector2i(1,2), Vector2i(0,1)]}, 
	{"name": "T_Right", "color": Color.PURPLE, "cells": [Vector2i(0,0), Vector2i(0,1), Vector2i(0,2), Vector2i(1,1)]}, 

	# 4. L & J SHAPES
	{"name": "L_Right", "color": Color.ORANGE_RED, "cells": [Vector2i(0,0), Vector2i(0,1), Vector2i(0,2), Vector2i(1,2)]},
	{"name": "L_Left",  "color": Color.ORANGE_RED, "cells": [Vector2i(1,0), Vector2i(1,1), Vector2i(1,2), Vector2i(0,2)]}, 
	{"name": "L_Up",    "color": Color.ORANGE_RED, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(0,1)]}, 
	{"name": "L_Down",  "color": Color.ORANGE_RED, "cells": [Vector2i(2,0), Vector2i(0,1), Vector2i(1,1), Vector2i(2,1)]}, 
	{"name": "J_Right", "color": Color.BLUE, "cells": [Vector2i(1,0), Vector2i(1,1), Vector2i(1,2), Vector2i(0,0)]}, 
	{"name": "J_Left",  "color": Color.BLUE, "cells": [Vector2i(0,0), Vector2i(0,1), Vector2i(0,2), Vector2i(1,0)]}, 
	{"name": "J_Up",    "color": Color.BLUE, "cells": [Vector2i(0,0), Vector2i(0,1), Vector2i(1,1), Vector2i(2,1)]},
	{"name": "J_Down",  "color": Color.BLUE, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(2,1)]},

	# 5. Z & S SHAPES
	{"name": "Z_Horiz", "color": Color.RED,   "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(1,1), Vector2i(2,1)]},
	{"name": "S_Horiz", "color": Color.GREEN, "cells": [Vector2i(1,0), Vector2i(2,0), Vector2i(0,1), Vector2i(1,1)]},
	{"name": "Z_Vert",  "color": Color.RED,   "cells": [Vector2i(1,0), Vector2i(0,1), Vector2i(1,1), Vector2i(0,2)]},
	{"name": "S_Vert",  "color": Color.GREEN, "cells": [Vector2i(0,0), Vector2i(0,1), Vector2i(1,1), Vector2i(1,2)]},

	# 6. EXTRAS
	{"name": "Diagonal_3",    "color": Color.MAGENTA, "cells": [Vector2i(0,0), Vector2i(1,1), Vector2i(2,2)]},
	{"name": "Rect_Vert_2x3", "color": Color.TEAL,    "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(1,1), Vector2i(0,2), Vector2i(1,2)]},
	
	# 7. MINI L
	{"name": "MiniL_BL", "color": Color.GOLD, "cells": [Vector2i(0,0), Vector2i(0,1), Vector2i(1,1)]},
	{"name": "MiniL_TL", "color": Color.GOLD, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1)]},
	{"name": "MiniL_TR", "color": Color.GOLD, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(1,1)]},
	{"name": "MiniL_BR", "color": Color.GOLD, "cells": [Vector2i(1,0), Vector2i(0,1), Vector2i(1,1)]}
]

func _ready():
	# Reiniciamos puntuación
	update_score(0)
	
	# CONECTAMOS LA SEÑAL DEL BOARD PARA RECIBIR PUNTOS
	if not board.puntos_ganados.is_connected(_on_puntos_ganados):
		board.puntos_ganados.connect(_on_puntos_ganados)

	# Setup Piezas
	for i in range(pieces_array.size()):
		var p = pieces_array[i]
		if not p.pieza_soltada.is_connected(_on_pieza_soltada):
			p.pieza_soltada.connect(_on_pieza_soltada)
		start_positions[p] = markers[i].global_position
	
	spawn_new_hand()

# --- SISTEMA DE PUNTUACIÓN ---
func _on_puntos_ganados(puntos):
	score += puntos
	update_score(score)

func update_score(val):
	score = val
	score_label.text = str(score)

func spawn_new_hand():
	print(">> GENERANDO MANO...")
	var espacios_vacios = board.get_empty_cells_count()
	var presion = 1.0 - (float(espacios_vacios) / 64.0) 
	
	var lista_segura = []  
	var lista_riesgo = []  
	
	for shape in shapes_database:
		if board.check_if_shape_fits_anywhere(shape["cells"]):
			lista_segura.append(shape)
		else:
			lista_riesgo.append(shape)

	if lista_segura.size() == 0:
		print(">> CRÍTICO: Game Over Inevitable.")
		generar_mano_aleatoria_total()
		check_game_over()
		return

	# Slot 1: Seguro
	var p1_data = lista_segura.pick_random()
	pieces_array[0].set_configuration(p1_data["cells"], p1_data["color"])
	
	# Slot 2 y 3: Lógica
	for i in range(1, 3): 
		var pieza_elegida
		if presion > 0.70:
			pieza_elegida = lista_segura.pick_random()
		elif presion < 0.30:
			if randf() > 0.5: pieza_elegida = shapes_database.pick_random()
			else: pieza_elegida = lista_segura.pick_random()
		else:
			pieza_elegida = lista_segura.pick_random()
		
		pieces_array[i].set_configuration(pieza_elegida["cells"], pieza_elegida["color"])

	# Centrado
	for i in range(pieces_array.size()):
		var p = pieces_array[i]
		var marker = markers[i]
		
		p.visible = true
		p.scale = Vector2(0.57, 0.57)
		var col_shape = p.get_node("Area2D/CollisionShape2D")
		var raw_size = col_shape.shape.size
		var centered_pos = marker.global_position - (raw_size / 2.0 * p.scale.x)
		
		start_positions[p] = centered_pos
		p.global_position = centered_pos
	
	check_game_over()

func generar_mano_aleatoria_total():
	for i in range(pieces_array.size()):
		var p = pieces_array[i]
		var marker = markers[i]
		assign_random_shape(p)
		p.visible = true
		start_positions[p] = marker.global_position
		p.global_position = marker.global_position

func assign_random_shape(piece_node):
	var random_idx = randi() % shapes_database.size()
	var data = shapes_database[random_idx]
	piece_node.set_configuration(data["cells"], data["color"])

func _on_pieza_soltada(which_piece, posicion_global):
	var cell_size = 64
	var local_pos = posicion_global - board.global_position
	var grid_x = round(local_pos.x / cell_size)
	var grid_y = round(local_pos.y / cell_size)
	
	if board.can_place_piece(grid_x, grid_y, which_piece.cells):
		# COLOCAR (Aquí el Board emitirá la señal de puntos)
		board.place_piece(grid_x, grid_y, which_piece.cells, which_piece.piece_color)
		
		which_piece.visible = false
		which_piece.global_position = start_positions[which_piece]
		
		check_hand_empty()
		
		if not check_hand_empty_silent():
			check_game_over()
		
	else:
		var tween = create_tween()
		tween.tween_property(which_piece, "global_position", start_positions[which_piece], 0.2).set_trans(Tween.TRANS_SINE)

func check_hand_empty():
	if check_hand_empty_silent():
		await get_tree().create_timer(0.3).timeout
		spawn_new_hand()

func check_hand_empty_silent():
	for p in pieces_array:
		if p.visible: return false
	return true

func check_game_over():
	var can_move = false
	# Revisamos si alguna de las 3 piezas cabe en el tablero
	for p in pieces_array:
		if p.visible:
			if board.check_if_shape_fits_anywhere(p.cells):
				can_move = true
				break 
	
	if not can_move:
		print("!!! GAME OVER REAL !!!")
		
		# 1. Guardamos el récord
		Global.actualizar_record(score)
		
		# 2. INSTANCIAMOS LA PANTALLA DE GAME OVER
		var game_over_instance = GAME_OVER_SCENE.instantiate()
		
		# 3. Le pasamos la puntuación para que la muestre
		# (Asegúrate de que el script de GameOver tenga la función set_score que te di arriba)
		if game_over_instance.has_method("set_score"):
			game_over_instance.set_score(score)
			
		# 4. La añadimos a la escena
		add_child(game_over_instance)
		
		# 5. OPCIONAL: Pausar el juego de fondo (si quieres)
		# get_tree().paused = true
