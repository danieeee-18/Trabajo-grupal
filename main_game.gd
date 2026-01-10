extends Node2D

@onready var board = $Board
@onready var pieces_array = [$Piece, $Piece2, $Piece3]

var start_positions = {}

# Tu base de datos de piezas
var shapes_database = [
	{"name": "Square", "color": Color.ORANGE, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(1,1)]},
	{"name": "Line", "color": Color.CYAN, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(3,0)]},
	{"name": "L_Shape", "color": Color.BLUE, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(2,1)]},
	{"name": "J_Shape", "color": Color.DODGER_BLUE, "cells": [Vector2i(0,1), Vector2i(1,1), Vector2i(2,1), Vector2i(2,0)]},
	{"name": "T_Shape", "color": Color.PURPLE, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(1,1)]},
	{"name": "Z_Shape", "color": Color.RED, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(1,1), Vector2i(2,1)]},
	{"name": "S_Shape", "color": Color.GREEN, "cells": [Vector2i(1,0), Vector2i(2,0), Vector2i(0,1), Vector2i(1,1)]},
	{"name": "Dot", "color": Color.YELLOW, "cells": [Vector2i(0,0)]},
	{"name": "Small_Line", "color": Color.PINK, "cells": [Vector2i(0,0), Vector2i(1,0)]}
]

func _ready():
	for p in pieces_array:
		if not p.pieza_soltada.is_connected(_on_pieza_soltada):
			p.pieza_soltada.connect(_on_pieza_soltada)
		start_positions[p] = p.global_position
	
	spawn_new_hand()

## --- GENERACIÓN INTELIGENTE V2.0 (Lógica de Ingeniero) ---
func spawn_new_hand():
	print(">> ---------------------------------------")
	print(">> INICIANDO PROTOCOLO DE GENERACIÓN INTELIGENTE")
	
	# 1. ANÁLISIS DEL ESTADO DEL JUEGO
	var espacios_vacios = board.get_empty_cells_count()
	var presion = 1.0 - (float(espacios_vacios) / 64.0) 
	# presion 0.0 = Vacío | presion 1.0 = Lleno total
	print(">> Presión del tablero: ", presion * 100, "%")

	# 2. CLASIFICACIÓN DE PIEZAS (Filtro Matemático)
	var lista_segura = []  # Piezas que CABEN seguro
	var lista_riesgo = []  # Piezas que NO caben ahora mismo
	
	for shape in shapes_database:
		if board.check_if_shape_fits_anywhere(shape["cells"]):
			lista_segura.append(shape)
		else:
			lista_riesgo.append(shape)
	
	print(">> Piezas Seguras disponibles: ", lista_segura.size())
	print(">> Piezas de Riesgo (Imposibles): ", lista_riesgo.size())

	# 3. VERIFICACIÓN DE SUPERVIVENCIA (Game Over Check)
	if lista_segura.size() == 0:
		print(">> CRÍTICO: Ninguna pieza cabe. Game Over Inevitable.")
		# Generamos cualquier cosa y dejamos que el check_game_over nos mate después
		generar_mano_aleatoria_total()
		check_game_over()
		return

	# 4. ASIGNACIÓN DE SLOTS (La Lógica de Decisión)
	
	# -- SLOT 1: EL SALVADOR (Garantizado) --
	# Siempre damos al menos una pieza que cabe para que el jugador pueda jugar.
	var p1_data = lista_segura.pick_random()
	pieces_array[0].set_configuration(p1_data["cells"], p1_data["color"])
	
	# -- SLOT 2 y 3: BALANCEO DE DIFICULTAD --
	for i in range(1, 3): # Indices 1 y 2 (Piece2 y Piece3)
		var pieza_elegida
		
		# CASO A: PÁNICO (Tablero > 70% lleno)
		# El jugador va a morir. Ayudémosle dándole solo piezas que caben.
		if presion > 0.70:
			pieza_elegida = lista_segura.pick_random()
			print(">> Modo Pánico: Asignando pieza segura en slot ", i)
			
		# CASO B: RELAX (Tablero < 30% lleno)
		# El jugador va sobrado. Podemos darle piezas arriesgadas o aleatorias.
		elif presion < 0.30:
			# 50% probabilidad de darle algo totalmente aleatorio (incluso si no cabe)
			# para obligarle a pensar en el futuro.
			if randf() > 0.5:
				pieza_elegida = shapes_database.pick_random()
			else:
				pieza_elegida = lista_segura.pick_random()
			print(">> Modo Relax: Asignando pieza mixta en slot ", i)
			
		# CASO C: NORMAL (30% - 70%)
		# Juego estándar. Preferimos seguras pero variadas.
		else:
			pieza_elegida = lista_segura.pick_random()
		
		# Configurar la pieza visualmente
		pieces_array[i].set_configuration(pieza_elegida["cells"], pieza_elegida["color"])

	# 5. FINALIZAR (Hacerlas visibles y colocarlas)
	for p in pieces_array:
		p.visible = true
		p.global_position = start_positions[p]
		p.scale = Vector2(0.8, 0.8)
	
	# Revisión final por si acaso
	check_game_over()

# Función auxiliar por si todo falla (Game Over)
func generar_mano_aleatoria_total():
	for p in pieces_array:
		assign_random_shape(p)
		p.visible = true
		p.global_position = start_positions[p]

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
		which_piece.global_position = start_positions[which_piece]
		
		check_hand_empty()
		
		# Verificamos si podemos seguir jugando con lo que queda
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
	for p in pieces_array:
		if p.visible:
			if board.check_if_shape_fits_anywhere(p.cells):
				can_move = true
				break 
	
	if not can_move:
		print("!!! GAME OVER REAL !!!")
		get_tree().paused = true
