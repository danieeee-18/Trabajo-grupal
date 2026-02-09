extends Node2D

const GAME_OVER_SCENE = preload("res://GameOver.tscn")
const FUENTE_HYPE = preload("res://Luckiest_Guy/LuckiestGuy-Regular.ttf")
const FUENTE_MODERNA = preload("res://Fuentes/Montserrat-Black.ttf")

# --- REFERENCIAS A LOS NODOS ---
@onready var board = $Board
@onready var pieces_array = [$Piece, $Piece2, $Piece3]
@onready var markers = [$PosicionPieza1, $PosicionPieza2, $PosicionPieza3]
@onready var score_label = $ScoreLabel
@onready var capa_ajustes = $CapaAjustes

# CÁMARA (Asegúrate de tener un nodo Camera2D en la escena)
@onready var camera = $Camera2D

# SONIDOS (Asegúrate de tener estos nodos AudioStreamPlayer)
@onready var sfx_pop = $AudioPop
@onready var sfx_linea = $AudioLinea
@onready var sfx_combo = $AudioCombo
@onready var sfx_gameover = $AudioGameOver

# --- VARIABLES DE JUEGO ---
var start_positions = {}
var score = 0
var combo_actual = 0          # Cuenta la racha
var hubo_puntos_turno = false # Chivato de puntos
var fuerza_temblor = 0.0      # Intensidad del terremoto actual

# --- BASE DE DATOS DE PIEZAS ---
var shapes_database = [
	{"name": "Line_H_2", "color": Color.PINK, "cells": [Vector2i(0,0), Vector2i(1,0)]},
	{"name": "Line_H_3", "color": Color.HOT_PINK, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0)]},
	{"name": "Line_H_4", "color": Color.CYAN, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(3,0)]},
	{"name": "Line_H_5", "color": Color.TURQUOISE, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(3,0), Vector2i(4,0)]},
	{"name": "Line_V_2", "color": Color.PINK, "cells": [Vector2i(0,0), Vector2i(0,1)]},
	{"name": "Line_V_3", "color": Color.HOT_PINK, "cells": [Vector2i(0,0), Vector2i(0,1), Vector2i(0,2)]},
	{"name": "Line_V_4", "color": Color.CYAN, "cells": [Vector2i(0,0), Vector2i(0,1), Vector2i(0,2), Vector2i(0,3)]},
	{"name": "Line_V_5", "color": Color.TURQUOISE, "cells": [Vector2i(0,0), Vector2i(0,1), Vector2i(0,2), Vector2i(0,3), Vector2i(0,4)]},
	{"name": "Square_2x2", "color": Color.ORANGE, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(1,1)]},
	{"name": "Square_3x3", "color": Color.RED, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0),Vector2i(0,1), Vector2i(1,1), Vector2i(2,1),Vector2i(0,2), Vector2i(1,2), Vector2i(2,2)]},
	{"name": "T_Down", "color": Color.PURPLE, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(1,1)]},
	{"name": "T_Up", "color": Color.PURPLE, "cells": [Vector2i(1,0), Vector2i(0,1), Vector2i(1,1), Vector2i(2,1)]},
	{"name": "T_Left", "color": Color.PURPLE, "cells": [Vector2i(1,0), Vector2i(1,1), Vector2i(1,2), Vector2i(0,1)]},
	{"name": "T_Right", "color": Color.PURPLE, "cells": [Vector2i(0,0), Vector2i(0,1), Vector2i(0,2), Vector2i(1,1)]},
	{"name": "L_Right", "color": Color.ORANGE_RED, "cells": [Vector2i(0,0), Vector2i(0,1), Vector2i(0,2), Vector2i(1,2)]},
	{"name": "L_Left", "color": Color.ORANGE_RED, "cells": [Vector2i(1,0), Vector2i(1,1), Vector2i(1,2), Vector2i(0,2)]},
	{"name": "L_Up", "color": Color.ORANGE_RED, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(0,1)]},
	{"name": "L_Down", "color": Color.ORANGE_RED, "cells": [Vector2i(2,0), Vector2i(0,1), Vector2i(1,1), Vector2i(2,1)]},
	{"name": "J_Right", "color": Color.BLUE, "cells": [Vector2i(1,0), Vector2i(1,1), Vector2i(1,2), Vector2i(0,0)]},
	{"name": "J_Left", "color": Color.BLUE, "cells": [Vector2i(0,0), Vector2i(0,1), Vector2i(0,2), Vector2i(1,0)]},
	{"name": "J_Up", "color": Color.BLUE, "cells": [Vector2i(0,0), Vector2i(0,1), Vector2i(1,1), Vector2i(2,1)]},
	{"name": "J_Down", "color": Color.BLUE, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(2,0), Vector2i(2,1)]},
	{"name": "Z_Horiz", "color": Color.RED, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(1,1), Vector2i(2,1)]},
	{"name": "S_Horiz", "color": Color.GREEN, "cells": [Vector2i(1,0), Vector2i(2,0), Vector2i(0,1), Vector2i(1,1)]},
	{"name": "Z_Vert", "color": Color.RED, "cells": [Vector2i(1,0), Vector2i(0,1), Vector2i(1,1), Vector2i(0,2)]},
	{"name": "S_Vert", "color": Color.GREEN, "cells": [Vector2i(0,0), Vector2i(0,1), Vector2i(1,1), Vector2i(1,2)]},
	{"name": "Diagonal_3", "color": Color.MAGENTA, "cells": [Vector2i(0,0), Vector2i(1,1), Vector2i(2,2)]},
	{"name": "Rect_Vert_2x3", "color": Color.TEAL, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(1,1), Vector2i(0,2), Vector2i(1,2)]},
	{"name": "MiniL_BL", "color": Color.GOLD, "cells": [Vector2i(0,0), Vector2i(0,1), Vector2i(1,1)]},
	{"name": "MiniL_TL", "color": Color.GOLD, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1)]},
	{"name": "MiniL_TR", "color": Color.GOLD, "cells": [Vector2i(0,0), Vector2i(1,0), Vector2i(1,1)]},
	{"name": "MiniL_BR", "color": Color.GOLD, "cells": [Vector2i(1,0), Vector2i(0,1), Vector2i(1,1)]}
]

func _ready():
	update_score(0)
	capa_ajustes.visible = false
	
	if not board.puntos_ganados.is_connected(_on_puntos_ganados):
		board.puntos_ganados.connect(_on_puntos_ganados)

	for i in range(pieces_array.size()):
		var p = pieces_array[i]
		if not p.pieza_soltada.is_connected(_on_pieza_soltada):
			p.pieza_soltada.connect(_on_pieza_soltada)
		start_positions[p] = markers[i].global_position
	
	spawn_new_hand()
	
	# Iniciar la ola en el tablero
	if board.has_method("animar_ola_entrada"):
		board.animar_ola_entrada()
	
	# INTRODUCCIÓN CON HYPE
	await get_tree().create_timer(0.3).timeout
	mostrar_frase_hype("READY?", Color(1, 0.5, 0)) 
	
	await get_tree().create_timer(0.6).timeout
	mostrar_frase_hype("GO!", Color(0.2, 1, 0.2))

# --- FUNCIÓN PROCESS PARA EL TEMBLOR ---
func _process(delta):
	if fuerza_temblor > 0:
		# Reducimos la fuerza poco a poco
		fuerza_temblor = lerp(fuerza_temblor, 0.0, 10.0 * delta)
		
		# Movemos la cámara aleatoriamente
		if camera:
			camera.offset = Vector2(
				randf_range(-fuerza_temblor, fuerza_temblor),
				randf_range(-fuerza_temblor, fuerza_temblor)
			)
		
		# Si es casi cero, lo paramos
		if fuerza_temblor < 0.5:
			fuerza_temblor = 0
			if camera: camera.offset = Vector2.ZERO

# --- FUNCIÓN PARA ACTIVAR EL TEMBLOR ---
func aplicar_temblor(intensidad):
	fuerza_temblor += intensidad

# --- LÓGICA DE JUEGO ---

func _on_puntos_ganados(puntos):
	# 1. Avisamos de que en este turno SI hubo puntos
	hubo_puntos_turno = true
	
	# 2. Calculamos el multiplicador
	var multiplicador = max(1, combo_actual + 1)
	
	# 3. Sumamos puntos con PREMIO
	var puntos_finales = puntos * multiplicador
	score += puntos_finales
	update_score(score)

func update_score(val):
	score = val
	score_label.text = str(score)

func spawn_new_hand():
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
		generar_mano_aleatoria_total()
		check_game_over()
		return

	var p1_data = lista_segura.pick_random()
	pieces_array[0].set_configuration(p1_data["cells"], p1_data["color"])
	
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

# --- LÓGICA MAESTRA DE COLOCACIÓN Y SONIDO ---
func _on_pieza_soltada(which_piece, posicion_global):
	var cell_size = 64
	var local_pos = posicion_global - board.global_position
	var grid_x = round(local_pos.x / cell_size)
	var grid_y = round(local_pos.y / cell_size)
	
	if board.can_place_piece(grid_x, grid_y, which_piece.cells):
		
		# 1. SONIDO POP (Inmediato)
		if sfx_pop:
			sfx_pop.pitch_scale = randf_range(0.9, 1.1)
			sfx_pop.play()
		
		# REINICIO ESTRICTO
		hubo_puntos_turno = false 
		var puntuacion_antes = score
		
		# 2. COLOCAR LA PIEZA (Con AWAIT)
		await board.place_piece(grid_x, grid_y, which_piece.cells, which_piece.piece_color)
		
		# 3. CÁLCULO DE RESULTADOS
		var diferencia_puntos = score - puntuacion_antes
		var es_jugada_maestra = diferencia_puntos > 20 
		
		if es_jugada_maestra:
			combo_actual += 1
			# DECIDIMOS SONIDO Y VISUALES AQUÍ
			if combo_actual > 1:
				# --- COMBO ---
				if sfx_combo:
					sfx_combo.pitch_scale = 1.0 + (combo_actual * 0.1)
					sfx_combo.play()
				mostrar_combo_visual(combo_actual)
				aplicar_temblor(12.0)
			else:
				# --- LÍNEA NORMAL ---
				if sfx_linea:
					sfx_linea.play()
				aplicar_temblor(6.0)
		else:
			combo_actual = 0
			
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
	for p in pieces_array:
		if p.visible:
			if board.check_if_shape_fits_anywhere(p.cells):
				can_move = true
				break
	
	if not can_move:
		if sfx_gameover: sfx_gameover.play()
		Global.actualizar_record(score)
		var game_over_instance = GAME_OVER_SCENE.instantiate()
		if game_over_instance.has_method("set_score"):
			game_over_instance.set_score(score)
		add_child(game_over_instance)

# --- BOTONES DEL MENÚ DE PAUSA ---

func _on_btn_home_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://MenuPrincipal.tscn")

func _on_btn_replay_pressed():
	capa_ajustes.visible = false
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_boton_cerrar_pressed():
	capa_ajustes.visible = false
	get_tree().paused = false

func _on_btn_abrir_ajustes_pressed():
	capa_ajustes.visible = true
	get_tree().paused = true

# --- SISTEMA VISUAL (HYPE Y COMBOS) ---

func mostrar_frase_hype(texto, color_texto):
	var label = Label.new()
	label.text = texto
	
	var settings = LabelSettings.new()
	settings.font = FUENTE_MODERNA
	settings.font_size = 90
	settings.font_color = color_texto
	settings.shadow_size = 20
	settings.shadow_color = Color(0, 0, 0, 0.5)
	settings.shadow_offset = Vector2(5, 5)
	label.label_settings = settings
	
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.anchors_preset = Control.PRESET_CENTER
	
	var pantalla_centro = get_viewport_rect().size / 2
	pantalla_centro.y -= 200 # Ajuste hacia arriba
	
	label.global_position = pantalla_centro
	label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	label.grow_vertical = Control.GROW_DIRECTION_BOTH
	label.z_index = 100 
	add_child(label)
	
	# Shockwave
	var shockwave = label.duplicate()
	shockwave.modulate = color_texto
	shockwave.z_index = 99
	add_child(shockwave)
	
	var t_shock = create_tween()
	shockwave.scale = Vector2(1, 1)
	t_shock.parallel().tween_property(shockwave, "scale", Vector2(2.5, 2.5), 0.25).set_ease(Tween.EASE_OUT)
	t_shock.parallel().tween_property(shockwave, "modulate:a", 0.0, 0.25)
	t_shock.tween_callback(shockwave.queue_free)
	
	# Animación Principal
	var tween = create_tween()
	label.scale = Vector2(0, 0)
	label.rotation_degrees = randf_range(-10, 10)
	
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "rotation_degrees", 0, 0.2)
	tween.tween_interval(0.2) 
	tween.tween_property(label, "scale", Vector2(0, 0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_callback(label.queue_free)

func mostrar_combo_visual(valor_combo):
	var color_combo = Color.YELLOW
	var texto_extra = "COMBO"
	
	if valor_combo == 3:
		color_combo = Color(1, 0.5, 0)
		texto_extra = "SUPER"
	elif valor_combo >= 4:
		color_combo = Color(1, 0, 0)
		texto_extra = "ULTRA"
	
	var texto_final = texto_extra + "\nx" + str(valor_combo) + "!"
	mostrar_frase_hype(texto_final, color_combo)
