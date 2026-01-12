extends Node2D

@onready var board = $Board
@onready var pieces_array = [$Piece, $Piece2, $Piece3]

# --- NUEVO: REFERENCIAS A LOS MARCADORES ---
# Estos son los puntos invisibles donde aparecerán las piezas.
# Asegúrate de que los nombres coinciden con los de tu escena.
@onready var markers = [$PosicionPieza1, $PosicionPieza2, $PosicionPieza3]

var start_positions = {}

# --- BASE DE DATOS MAESTRA DE PIEZAS (FINAL) ---
var shapes_database = [
	# ==========================================
	# 1. LÍNEAS (Verticales y Horizontales)
	# ==========================================
	# -- Horizontales (2 a 5) --
	{"name": "Line_H_2", "color": Color.PINK, "cells": [Vector2i(0,0), Vector2i(1,0)]},
	{"name": "Line_H_3", "color": Color.HOT_PINK, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0)]},
	{"name": "Line_H_4", "color": Color.CYAN, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(3,0)]},
	{"name": "Line_H_5", "color": Color.TURQUOISE, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(3,0), Vector2i(4,0)]},

	# -- Verticales (2 a 5) --
	{"name": "Line_V_2", "color": Color.PINK, "cells": [Vector2i(0,0), Vector2i(0,1)]},
	{"name": "Line_V_3", "color": Color.HOT_PINK, "cells": [Vector2i(0,0), Vector2i(0,1), Vector2i(0,2)]},
	{"name": "Line_V_4", "color": Color.CYAN, "cells": [Vector2i(0,0), Vector2i(0,1), Vector2i(0,2), Vector2i(0,3)]},
	{"name": "Line_V_5", "color": Color.TURQUOISE, "cells": [Vector2i(0,0), Vector2i(0,1), Vector2i(0,2), Vector2i(0,3), Vector2i(0,4)]},

	# ==========================================
	# 2. CUADRADOS
	# ==========================================
	{"name": "Square_2x2", "color": Color.ORANGE, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(1,1)]},
	{"name": "Square_3x3", "color": Color.RED, "cells": [
		Vector2i(0,0), Vector2i(1,0), Vector2i(2,0),
		Vector2i(0,1), Vector2i(1,1), Vector2i(2,1),
		Vector2i(0,2), Vector2i(1,2), Vector2i(2,2)
	]},

	# ==========================================
	# 3. FAMILIA "T" (4 Bloques - Rotaciones)
	# ==========================================
	{"name": "T_Down",  "color": Color.PURPLE, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(1,1)]}, 
	{"name": "T_Up",    "color": Color.PURPLE, "cells": [Vector2i(1,0), Vector2i(0,1), Vector2i(1,1), Vector2i(2,1)]}, 
	{"name": "T_Left",  "color": Color.PURPLE, "cells": [Vector2i(1,0), Vector2i(1,1), Vector2i(1,2), Vector2i(0,1)]}, 
	{"name": "T_Right", "color": Color.PURPLE, "cells": [Vector2i(0,0), Vector2i(0,1), Vector2i(0,2), Vector2i(1,1)]}, 

	# ==========================================
	# 4. FAMILIA "L" y "J" (4 Bloques - Rotaciones)
	# ==========================================
	# -- L (Naranja/Rojizo) --
	{"name": "L_Right", "color": Color.ORANGE_RED, "cells": [Vector2i(0,0), Vector2i(0,1), Vector2i(0,2), Vector2i(1,2)]},
	{"name": "L_Left",  "color": Color.ORANGE_RED, "cells": [Vector2i(1,0), Vector2i(1,1), Vector2i(1,2), Vector2i(0,2)]}, 
	{"name": "L_Up",    "color": Color.ORANGE_RED, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(0,1)]}, 
	{"name": "L_Down",  "color": Color.ORANGE_RED, "cells": [Vector2i(2,0), Vector2i(0,1), Vector2i(1,1), Vector2i(2,1)]}, 

	# -- J (Azul) --
	{"name": "J_Right", "color": Color.BLUE, "cells": [Vector2i(1,0), Vector2i(1,1), Vector2i(1,2), Vector2i(0,0)]}, 
	{"name": "J_Left",  "color": Color.BLUE, "cells": [Vector2i(0,0), Vector2i(0,1), Vector2i(0,2), Vector2i(1,0)]}, 
	{"name": "J_Up",    "color": Color.BLUE, "cells": [Vector2i(0,0), Vector2i(0,1), Vector2i(1,1), Vector2i(2,1)]},
	{"name": "J_Down",  "color": Color.BLUE, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(2,1)]},

	# ==========================================
	# 5. FAMILIA "Z" y "S" (Zig-Zag)
	# ==========================================
	{"name": "Z_Horiz", "color": Color.RED,   "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(1,1), Vector2i(2,1)]},
	{"name": "S_Horiz", "color": Color.GREEN, "cells": [Vector2i(1,0), Vector2i(2,0), Vector2i(0,1), Vector2i(1,1)]},
	{"name": "Z_Vert",  "color": Color.RED,   "cells": [Vector2i(1,0), Vector2i(0,1), Vector2i(1,1), Vector2i(0,2)]},
	{"name": "S_Vert",  "color": Color.GREEN, "cells": [Vector2i(0,0), Vector2i(0,1), Vector2i(1,1), Vector2i(1,2)]},

	# ==========================================
	# 6. EXTRAS
	# ==========================================
	{"name": "Diagonal_3",    "color": Color.MAGENTA, "cells": [Vector2i(0,0), Vector2i(1,1), Vector2i(2,2)]},
	{"name": "Rect_Vert_2x3", "color": Color.TEAL,    "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(1,1), Vector2i(0,2), Vector2i(1,2)]},
	
	# ==========================================
	# 7. FAMILIA MINI L (3 Bloques - LO NUEVO)
	# ==========================================
	# Son como un cuadrado de 2x2 al que le falta 1 esquina. Les pongo color Amarillo/Dorado.
	
	# Esquina Abajo-Izquierda ( |_ )
	{"name": "MiniL_BL", "color": Color.GOLD, "cells": [Vector2i(0,0), Vector2i(0,1), Vector2i(1,1)]},
	
	# Esquina Arriba-Izquierda ( |¯ )
	{"name": "MiniL_TL", "color": Color.GOLD, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1)]},
	
	# Esquina Arriba-Derecha ( ¯| )
	{"name": "MiniL_TR", "color": Color.GOLD, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(1,1)]},
	
	# Esquina Abajo-Derecha ( _| )
	{"name": "MiniL_BR", "color": Color.GOLD, "cells": [Vector2i(1,0), Vector2i(0,1), Vector2i(1,1)]}
]

func _ready():
	# Conectamos las señales
	for i in range(pieces_array.size()):
		var p = pieces_array[i]
		if not p.pieza_soltada.is_connected(_on_pieza_soltada):
			p.pieza_soltada.connect(_on_pieza_soltada)
		
		# Inicializamos start_positions con el marcador por defecto
		# (Esto se sobrescribirá en spawn_new_hand con el centrado exacto)
		start_positions[p] = markers[i].global_position
	
	spawn_new_hand()

## --- GENERACIÓN INTELIGENTE CON CENTRADO ---
func spawn_new_hand():
	print(">> ---------------------------------------")
	print(">> INICIANDO PROTOCOLO DE GENERACIÓN")
	
	# 1. ANÁLISIS
	var espacios_vacios = board.get_empty_cells_count()
	var presion = 1.0 - (float(espacios_vacios) / 64.0) 
	
	# 2. CLASIFICACIÓN
	var lista_segura = []  
	var lista_riesgo = []  
	
	for shape in shapes_database:
		if board.check_if_shape_fits_anywhere(shape["cells"]):
			lista_segura.append(shape)
		else:
			lista_riesgo.append(shape)
	
	# 3. VERIFICACIÓN DE SUPERVIVENCIA
	if lista_segura.size() == 0:
		print(">> CRÍTICO: Game Over Inevitable.")
		generar_mano_aleatoria_total()
		check_game_over()
		return

	# 4. ASIGNACIÓN DE PIEZAS
	# Slot 1: Siempre seguro
	var p1_data = lista_segura.pick_random()
	pieces_array[0].set_configuration(p1_data["cells"], p1_data["color"])
	
	# Slot 2 y 3: Según dificultad
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

	# 5. FINALIZAR Y CENTRAR (LA PARTE CLAVE)
	for i in range(pieces_array.size()):
		var p = pieces_array[i]
		var marker = markers[i] # Referencia al marcador correspondiente
		
		p.visible = true
		p.scale = Vector2(0.6, 0.6) # Escala reducida para la "mano"
		
		# --- CÁLCULO MATEMÁTICO DE CENTRADO ---
		# Obtenemos el tamaño real del colisionador (que Piece.gd actualizó)
		var col_shape = p.get_node("Area2D/CollisionShape2D")
		var raw_size = col_shape.shape.size
		
		# Calculamos dónde poner la esquina superior izquierda de la pieza
		# para que su CENTRO caiga justo encima del marcador.
		# Fórmula: Pos_Marcador - (Mitad_Tamaño * Escala)
		var centered_pos = marker.global_position - (raw_size / 2.0 * p.scale.x)
		
		# ACTUALIZAMOS la posición de "vuelta a casa"
		start_positions[p] = centered_pos
		
		# Movemos la pieza a su sitio
		p.global_position = centered_pos
	
	check_game_over()

# Función auxiliar por si todo falla
func generar_mano_aleatoria_total():
	for i in range(pieces_array.size()):
		var p = pieces_array[i]
		var marker = markers[i]
		assign_random_shape(p)
		p.visible = true
		# Centrado simple de emergencia
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
		board.place_piece(grid_x, grid_y, which_piece.cells, which_piece.piece_color)
		
		which_piece.visible = false
		# Vuelve a su posición de inicio (ya calculada y centrada)
		which_piece.global_position = start_positions[which_piece]
		
		check_hand_empty()
		
		if not check_hand_empty_silent():
			check_game_over()
		
	else:
		# Animación de retorno suave a su posición centrada
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
	for p in pieces_array:
		if p.visible:
			if board.check_if_shape_fits_anywhere(p.cells):
				can_move = true
				break 
	
	if not can_move:
		print("!!! GAME OVER REAL !!!")
		# get_tree().paused = true
