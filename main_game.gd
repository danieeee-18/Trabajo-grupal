extends Node2D

const GAME_OVER_SCENE = preload("res://GameOver.tscn")
const FUENTE_HYPE = preload("res://Luckiest_Guy/LuckiestGuy-Regular.ttf")
const FUENTE_MODERNA = preload("res://Fuentes/Montserrat-Black.ttf")
const ESCENA_MONEDA = preload("res://MonedaVisual.tscn")

# --- REFERENCIAS ---
@onready var board = $Board
@onready var pieces_array = [$Piece, $Piece2, $Piece3]
@onready var markers = [$PosicionPieza1, $PosicionPieza2, $PosicionPieza3]
@onready var score_label = $ScoreLabel
@onready var capa_ajustes = $CapaAjustes
@onready var camera = $Camera2D

# LOS DOS NUEVOS NODOS DE FONDO
@onready var color_fondo = $ColorFondo 
@onready var imagen_fondo = $Fondo 

var textura_base_original = null
# SONIDOS
@onready var sfx_pop = $AudioPop
@onready var sfx_linea = $AudioLinea
@onready var sfx_combo = $AudioCombo
@onready var sfx_gameover = $AudioGameOver
@onready var monedas_label = $ContenedorMonedas/MonedasLabel

# VARIABLES
var usos_refresh = 3
var usos_bomba = 3
var usos_rayo = 3
var start_positions = {}
var score = 0
var combo_actual = 0          
var hubo_puntos_turno = false 
var fuerza_temblor = 0.0      
var ultima_pos_jugada : Vector2 = Vector2.ZERO 
var umbral_puntos_moneda = 1000
# DOPAMINA & COLORES
var frases_animo = ["NICE", "GOOD", "SWEET", "PURE", "COOL", "FRESH", "SOFT", "LOVELY"]
var colores_pastel = [Color("ffb7b2"), Color("b5ead7"), Color("e2f0cb"), Color("ffdac1"), Color("e0bbe4"), Color("97c1a9")]
var paleta_niveles = [
	Color(1, 1, 1), Color(0.6, 1.5, 1.5), Color(1.3, 0.8, 1.3), 
	Color(0.8, 1.5, 0.8), Color(1.5, 1.2, 0.8), Color(1.5, 0.7, 0.7), 
	Color(0.9, 0.9, 1.8), Color(1.2, 0.5, 1.5)
]
var color_objetivo = Color.WHITE 

# BASE DE DATOS PIEZAS
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
	
	if imagen_fondo:                                   
		textura_base_original = imagen_fondo.texture
		
	update_score(0)
	umbral_puntos_moneda = 1000
	capa_ajustes.visible = false
	if not board.puntos_ganados.is_connected(_on_puntos_ganados):
		board.puntos_ganados.connect(_on_puntos_ganados)
	for i in range(pieces_array.size()):
		var p = pieces_array[i]
		if not p.pieza_soltada.is_connected(_on_pieza_soltada): p.pieza_soltada.connect(_on_pieza_soltada)
		if p.has_signal("pieza_arrastrada"):
			if not p.pieza_arrastrada.is_connected(_on_pieza_arrastrada): p.pieza_arrastrada.connect(_on_pieza_arrastrada)
		start_positions[p] = markers[i].global_position
		
	spawn_new_hand()
	aplicar_fondo_equipado() 
	
	if board.has_method("animar_ola_entrada"): board.animar_ola_entrada()
	if has_node("AudioManager"): $AudioManager.poner_musica_juego()
	elif Global.has_method("play_music_level"): Global.play_music_level()
	await get_tree().create_timer(0.3).timeout
	mostrar_frase_hype("READY?", Color(1, 0.5, 0)) 
	await get_tree().create_timer(0.6).timeout
	mostrar_frase_hype("GO!", Color(0.2, 1, 0.2))
	actualizar_ui_monedas()
	
	# --- APLICAMOS LOS AJUSTES DE AUDIO AL INICIAR ---
	actualizar_textos_ajustes()
	aplicar_audio_buses()

func _process(delta):
	if fuerza_temblor > 0:
		fuerza_temblor = lerp(fuerza_temblor, 0.0, 10.0 * delta)
		if camera: camera.offset = Vector2(randf_range(-fuerza_temblor, fuerza_temblor), randf_range(-fuerza_temblor, fuerza_temblor))
		if fuerza_temblor < 0.5:
			fuerza_temblor = 0
			if camera: camera.offset = Vector2.ZERO


func aplicar_fondo_equipado():
	var datos_fondo = null
	
	for item in Global.catalogo_fondos:
		if item["id"] == Global.fondo_equipado:
			datos_fondo = item
			break
			
	# CASO 1: FONDO AZUL POR DEFECTO ("base")
	if Global.fondo_equipado == "base" or datos_fondo == null:
		if textura_base_original != null:
			# Si tu azul original es un degradado (imagen)
			imagen_fondo.texture = textura_base_original
			imagen_fondo.visible = true
			color_fondo.visible = false # Apagamos el color liso
		else:
			# Si por algún casual no detecta textura, forzamos un color azul sólido por seguridad
			imagen_fondo.visible = false
			color_fondo.visible = true
			color_fondo.color = Color("1a4066") # Azul marino clásico
			
		# Mantiene la lógica de colorear por niveles
		color_objetivo = paleta_niveles[0]
		if imagen_fondo.visible:
			imagen_fondo.modulate = color_objetivo
			
	# CASO 2: IMAGEN COMPRADA EN LA TIENDA (Galaxia, Mar...)
	elif datos_fondo.has("ruta_imagen") and datos_fondo["ruta_imagen"] != "":
		imagen_fondo.texture = load(datos_fondo["ruta_imagen"])
		imagen_fondo.visible = true
		imagen_fondo.modulate = Color.WHITE
		
		# ¡CLAVE! Aseguramos que el color de fondo esté apagado para que no tape la foto
		color_fondo.visible = false 
		color_objetivo = Color.WHITE
		
	# CASO 3: COLOR LISO COMPRADO EN LA TIENDA
	else:
		imagen_fondo.visible = false # Apagamos las texturas
		
		color_fondo.visible = true
		color_fondo.color = datos_fondo["color"]
		color_objetivo = datos_fondo["color"]

func _on_puntos_ganados(puntos):
	hubo_puntos_turno = true
	var multiplicador = max(1, combo_actual + 1)
	score += puntos * multiplicador
	
	update_score(score)
	actualizar_fondo_por_puntos(score)
	
	# --- NUEVO SISTEMA: JACKPOT DE MONEDAS ---
	if score >= umbral_puntos_moneda:
		umbral_puntos_moneda += 1000 # Preparamos el siguiente umbral
		Global.agregar_monedas(10) # Damos 10 monedas de golpe
		actualizar_ui_monedas()
		
		# Hacemos que la UI de las monedas palpite más fuerte
		var tween = create_tween()
		var contenedor = monedas_label.get_parent() 
		tween.tween_property(contenedor, "scale", Vector2(1.3, 1.3), 0.15)
		tween.tween_property(contenedor, "scale", Vector2(1.0, 1.0), 0.2)
		
		var posicion_salida = ultima_pos_jugada
		if posicion_salida == Vector2.ZERO: 
			posicion_salida = board.global_position + Vector2(256, 256)
			
		# Lluvia de 10 monedas volando súper rápido
		for i in range(10):
			crear_moneda_voladora(posicion_salida)
			await get_tree().create_timer(0.05).timeout
	# -----------------------------------------
	
	if puntos > 0 and combo_actual <= 1 and randf() < 0.3: 
		mostrar_feedback_rapido()

func update_score(val):
	score = val
	score_label.text = str(score)

func spawn_new_hand():
	var espacios_vacios = board.get_empty_cells_count()
	var presion = 1.0 - (float(espacios_vacios) / 64.0)
	var lista_segura = []
	for shape in shapes_database:
		if board.check_if_shape_fits_anywhere(shape["cells"]): lista_segura.append(shape)
	if lista_segura.size() == 0:
		generar_mano_aleatoria_total()
		check_game_over()
		return
	var p1_data = lista_segura.pick_random()
	pieces_array[0].set_configuration(p1_data["cells"], p1_data["color"])
	for i in range(1, 3):
		var pieza_elegida
		if presion > 0.70 or (presion < 0.30 and randf() < 0.5): pieza_elegida = lista_segura.pick_random()
		else: pieza_elegida = lista_segura.pick_random()
		pieces_array[i].set_configuration(pieza_elegida["cells"], pieza_elegida["color"])
	for i in range(pieces_array.size()):
		var p = pieces_array[i]
		var marker = markers[i]
		
		# Aseguramos que empiece sin rotación
		p.rotation_degrees = 0 
		
		var col_shape = p.get_node("Area2D/CollisionShape2D")
		var raw_size = col_shape.shape.size
		# Calculamos el centro usando la escala final (0.57)
		var centered_pos = marker.global_position - (raw_size / 2.0 * 0.57) 
		start_positions[p] = centered_pos
		p.global_position = centered_pos
		
		# --- ANIMACIÓN DE APARICIÓN CON REBOTE ---
		p.scale = Vector2.ZERO # Empieza invisible
		p.visible = true
		
		var tween = create_tween()
		# Aparecen una detrás de otra gracias al 'delay'
		tween.tween_property(p, "scale", Vector2(0.57, 0.57), 0.4).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT).set_delay(i * 0.1)
		# ----------------------------------------
		
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

func _on_pieza_arrastrada(which_piece, posicion_global):
	var cell_size = 64
	var local_pos = posicion_global - board.global_position
	var grid_x = round(local_pos.x / cell_size)
	var grid_y = round(local_pos.y / cell_size)
	if board.can_place_piece(grid_x, grid_y, which_piece.cells): board.actualizar_fantasma(grid_x, grid_y, which_piece.cells, which_piece.piece_color)
	else: board.ocultar_fantasma()
	# Efecto de levantar la pieza: Se hace un pelín más grande y se inclina
	var tween = create_tween()
	tween.parallel().tween_property(which_piece, "scale", Vector2(0.65, 0.65), 0.1).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(which_piece, "rotation_degrees", 5.0, 0.1)

func _on_pieza_soltada(which_piece, posicion_global):
	if board.has_method("ocultar_fantasma"): board.ocultar_fantasma()
	var cell_size = 64
	var local_pos = posicion_global - board.global_position
	var grid_x = round(local_pos.x / cell_size)
	var grid_y = round(local_pos.y / cell_size)
	if board.can_place_piece(grid_x, grid_y, which_piece.cells):
		ultima_pos_jugada = posicion_global
		if sfx_pop:
			sfx_pop.pitch_scale = randf_range(0.9, 1.1)
			sfx_pop.play()
		hubo_puntos_turno = false
		# -------- NUEVO: MICRO-JUICE AL CAER --------
		animar_polvo_caida(ultima_pos_jugada)
		aplicar_temblor(3.0) # Un temblor muy flojito para dar sensación de peso
		# --------------------------------------------
		var puntuacion_antes = score
		await board.place_piece(grid_x, grid_y, which_piece.cells, which_piece.piece_color)
		var diferencia_puntos = score - puntuacion_antes
		if diferencia_puntos > 20:
			if JuiceManager.has_method("crear_explosion"):
				JuiceManager.crear_explosion(ultima_pos_jugada, which_piece.piece_color)
			
			animar_marcador_puntos(which_piece.piece_color)
			animar_destello_tablero()
			mostrar_palabra_rotura(ultima_pos_jugada, which_piece.piece_color)
			# -------- NUEVO: CHECK PERFECT CLEAR --------
			# Si tras romper la línea, las 64 casillas están vacías... ¡BINGO!
			if board.get_empty_cells_count() == 64:
				ejecutar_perfect_clear()
			# --------------------------------------------
			combo_actual += 1
			if combo_actual > 1:
				if sfx_combo:
					sfx_combo.pitch_scale = 1.0 + (combo_actual * 0.1)
					sfx_combo.play()
				mostrar_combo_visual(combo_actual)
				aplicar_temblor(12.0)
			else:
				if sfx_linea: sfx_linea.play()
				aplicar_temblor(6.0)
		else: combo_actual = 0
		which_piece.visible = false
		which_piece.global_position = start_positions[which_piece]
		check_hand_empty()
		if not check_hand_empty_silent(): check_game_over()
	else:
		var tween = create_tween()
		tween.tween_property(which_piece, "global_position", start_positions[which_piece], 0.2).set_trans(Tween.TRANS_SINE)
		# Devolvemos el tamaño y le quitamos la inclinación
		tween.parallel().tween_property(which_piece, "scale", Vector2(0.57, 0.57), 0.2).set_trans(Tween.TRANS_BOUNCE)
		tween.parallel().tween_property(which_piece, "rotation_degrees", 0.0, 0.2)

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
		if has_node("AudioManager"): $AudioManager.poner_musica_gameover()
		Global.actualizar_record(score)
		var bloques_de_100 = int(score / 100)
		var monedas_ganadas = bloques_de_100 * 2
		if monedas_ganadas > 0: Global.agregar_monedas(monedas_ganadas)
		var game_over_instance = GAME_OVER_SCENE.instantiate()
		if game_over_instance.has_method("set_score"): game_over_instance.set_score(score)
		add_child(game_over_instance)


# --- SISTEMA VISUAL ---
func mostrar_frase_hype(texto, color_texto = Color.WHITE):
	efecto_combo_fondo()
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
	pantalla_centro.y -= 200
	label.global_position = pantalla_centro
	label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	label.grow_vertical = Control.GROW_DIRECTION_BOTH
	label.z_index = 100 
	add_child(label)
	var shockwave = label.duplicate()
	shockwave.modulate = color_texto
	shockwave.z_index = 99
	add_child(shockwave)
	var t_shock = create_tween()
	shockwave.scale = Vector2(1, 1)
	t_shock.parallel().tween_property(shockwave, "scale", Vector2(2.5, 2.5), 0.25).set_ease(Tween.EASE_OUT)
	t_shock.parallel().tween_property(shockwave, "modulate:a", 0.0, 0.25)
	t_shock.tween_callback(shockwave.queue_free)
	var tween = create_tween()
	label.scale = Vector2(0, 0)
	label.rotation_degrees = randf_range(-10, 10)
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "rotation_degrees", 0, 0.2)
	tween.tween_interval(0.2) 
	tween.tween_property(label, "scale", Vector2(0, 0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_callback(label.queue_free)

func mostrar_feedback_rapido():
	var texto = frases_animo.pick_random()
	var color = colores_pastel.pick_random()
	var label = Label.new()
	label.text = texto
	var settings = LabelSettings.new()
	settings.font = FUENTE_MODERNA
	settings.font_size = 48 
	settings.font_color = color
	settings.outline_size = 8
	settings.outline_color = Color.BLACK
	label.label_settings = settings
	label.anchors_preset = Control.PRESET_CENTER
	var centro = get_viewport_rect().size / 2
	var offset = Vector2(randf_range(-100, 100), randf_range(-150, -50))
	label.global_position = centro + offset
	label.z_index = 90 
	add_child(label)
	var tween = create_tween()
	label.scale = Vector2(0, 0)
	label.rotation_degrees = randf_range(-15, 15)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "position:y", label.position.y - 50, 0.6)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.6).set_ease(Tween.EASE_IN)
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

func aplicar_temblor(intensidad):
	fuerza_temblor += intensidad
	
	# --- NUEVO: VIBRACIÓN FÍSICA DEL MÓVIL ---
	if Global.vibracion_activada:
		# Multiplicamos la intensidad visual por 10 para sacar los milisegundos de vibración
		# Ej: Un golpe suave (3.0) vibrará 30ms. Un Perfect Clear (20.0) vibrará 200ms!
		var tiempo_vibracion = int(intensidad * 10) 
		Input.vibrate_handheld(tiempo_vibracion)

func actualizar_fondo_por_puntos(puntos_actuales):
	if not color_fondo: return
	
	# Si hemos comprado un fondo especial en la tienda, no cambiamos los colores
	if Global.fondo_equipado != "base": return
		
	var nivel = int(puntos_actuales / 1000)
	var indice_color = nivel % paleta_niveles.size()
	var nuevo_color = paleta_niveles[indice_color]
	
	if color_objetivo != nuevo_color:
		color_objetivo = nuevo_color
		var tween = create_tween()
		# IMPORTANTE: Ahora aplicamos el color al 'modulate' del degradado, no al fondo sólido
		tween.tween_property(imagen_fondo, "modulate", color_objetivo, 2.0).set_trans(Tween.TRANS_SINE)
func efecto_combo_fondo():
	var tween = create_tween()
	
	# 1. Si estamos usando el fondo Clásico (tu degradado azul)
	if Global.fondo_equipado == "base":
		tween.tween_property(imagen_fondo, "modulate", Color(1.5, 1.5, 2.0), 0.1) 
		tween.tween_property(imagen_fondo, "modulate", color_objetivo, 0.5)
		
	# 2. Si es una foto de la tienda (Galaxia, Mar...)
	elif Global.fondo_equipado != "base" and imagen_fondo.visible:
		tween.tween_property(imagen_fondo, "modulate", Color(1.5, 1.5, 2.0), 0.1) 
		tween.tween_property(imagen_fondo, "modulate", Color.WHITE, 0.5)
		
	# 3. Si es un color liso comprado en la tienda
	else:
		tween.tween_property(color_fondo, "color", Color(1.5, 1.5, 2.0), 0.1) 
		tween.tween_property(color_fondo, "color", color_objetivo, 0.5)
func actualizar_ui_monedas():
	if monedas_label:
		monedas_label.text = str(Global.monedas)

func animar_monedas_ui():
	if not monedas_label: return
	var tween = create_tween()
	var contenedor = monedas_label.get_parent() 
	tween.tween_property(contenedor, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(contenedor, "scale", Vector2(1.0, 1.0), 0.1)

func crear_moneda_voladora(pos_inicio: Vector2):
	var moneda = ESCENA_MONEDA.instantiate()
	add_child(moneda)
	moneda.scale = Vector2(0.25, 0.25) 
	var variacion_random = Vector2(randf_range(-30, 30), randf_range(-30, 30))
	moneda.global_position = pos_inicio + variacion_random
	if moneda.has_method("volar_a_la_ui"):
		moneda.volar_a_la_ui(monedas_label.global_position)


# ===================================================
# --- LÓGICA DE LOS BOTONES DE AJUSTES (LIMPIA) ---
# ===================================================

func _on_boton_cerrar_pressed():
	capa_ajustes.visible = false
	get_tree().paused = false

func _on_btn_abrir_ajustes_pressed():
	capa_ajustes.visible = true
	get_tree().paused = true

func _on_fila_musica_pressed():
	Global.musica_activada = not Global.musica_activada
	Global.save_game()
	actualizar_textos_ajustes()
	aplicar_audio_buses()

func _on_fila_sonido_pressed():
	Global.sonido_activado = not Global.sonido_activado
	Global.save_game()
	actualizar_textos_ajustes()
	aplicar_audio_buses()

func _on_fila_vibracion_pressed():
	Global.vibracion_activada = not Global.vibracion_activada
	Global.save_game()
	actualizar_textos_ajustes()
	if Global.vibracion_activada:
		Input.vibrate_handheld(50) 

func _on_fila_home_pressed():
	# 1. Quitamos la pausa del juego para que la animación pueda funcionar
	get_tree().paused = false
	
	# 2. Escondemos el menú de ajustes (si lo tenías visible) para que quede limpio
	if capa_ajustes:
		capa_ajustes.visible = false
		
	# 3. Llamamos a nuestra transición mágica
	TransitionManager.cambiar_escena("res://MenuPrincipal.tscn")

func _on_fila_replay_pressed():
	capa_ajustes.visible = false
	get_tree().paused = false
	get_tree().reload_current_scene()

func actualizar_textos_ajustes():
	var color_encendido = Color("ff8c00") 
	var color_apagado = Color.DIM_GRAY   
	
	var btn_musica = find_child("FilaMusica", true, false)
	if btn_musica and btn_musica is Button:
		btn_musica.text = "ON" if Global.musica_activada else "OFF"
		btn_musica.add_theme_color_override("font_color", color_encendido if Global.musica_activada else color_apagado)

	var btn_sonido = find_child("FilaSonido", true, false)
	if btn_sonido and btn_sonido is Button:
		btn_sonido.text = "ON" if Global.sonido_activado else "OFF"
		btn_sonido.add_theme_color_override("font_color", color_encendido if Global.sonido_activado else color_apagado)

	var btn_vibra = find_child("FilaVibracion", true, false)
	if btn_vibra and btn_vibra is Button:
		btn_vibra.text = "ON" if Global.vibracion_activada else "OFF"
		btn_vibra.add_theme_color_override("font_color", color_encendido if Global.vibracion_activada else color_apagado)

func aplicar_audio_buses():
	var bus_musica = AudioServer.get_bus_index("Musica")
	var bus_efectos = AudioServer.get_bus_index("Efectos")
	
	if bus_musica >= 0:
		AudioServer.set_bus_mute(bus_musica, not Global.musica_activada)
	if bus_efectos >= 0:
		AudioServer.set_bus_mute(bus_efectos, not Global.sonido_activado)


# ==========================================
# --- NUEVAS ANIMACIONES DE JUICE (LÍNEAS) ---
# ==========================================

func animar_marcador_puntos(color_pieza):
	if not score_label: return
	var tween = create_tween()
	
	score_label.pivot_offset = score_label.size / 2 
	
	# 1. Salto MÁS GRANDE y cambio al color de la pieza
	tween.parallel().tween_property(score_label, "scale", Vector2(1.8, 1.8), 0.15).set_trans(Tween.TRANS_BACK)
	tween.parallel().tween_property(score_label, "modulate", color_pieza, 0.15)
	
	# 2. TRUCO: Congelamos la animación un tercio de segundo para que el color se lea bien
	tween.chain().tween_interval(0.3)
	
	# 3. Vuelta suave a la normalidad y al color blanco
	tween.chain().tween_property(score_label, "scale", Vector2(1.0, 1.0), 0.4).set_trans(Tween.TRANS_BOUNCE)
	tween.parallel().tween_property(score_label, "modulate", Color.WHITE, 0.4)

func animar_destello_tablero():
	if not board: return
	var tween = create_tween()
	# Flashazo blanco intenso
	tween.tween_property(board, "modulate", Color(2.5, 2.5, 2.5, 1.0), 0.05)
	# Vuelta a su color normal
	tween.tween_property(board, "modulate", Color.WHITE, 0.2)

func mostrar_palabra_rotura(posicion, color_texto):
	# ¡Palabras en inglés y con mucha energía!
	var palabras = ["CLEAR!", "CLEAN!", "AWESOME!", "BOOM!", "PERFECT!", "SMASH!", "NICE!"]
	
	var label = Label.new()
	label.text = palabras.pick_random()
	
	var settings = LabelSettings.new()
	settings.font = FUENTE_MODERNA
	settings.font_size = 60 # Un pelín más grandes también
	settings.font_color = color_texto
	settings.outline_size = 12
	settings.outline_color = Color.BLACK
	label.label_settings = settings
	
	label.anchors_preset = Control.PRESET_CENTER
	label.global_position = posicion - Vector2(100, 80) 
	label.z_index = 100 
	add_child(label)
	
	var tween = create_tween()
	label.scale = Vector2(0, 0)
	label.rotation_degrees = randf_range(-25, 25) 
	
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(label, "position:y", label.position.y - 100, 0.7).set_trans(Tween.TRANS_SINE)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.7).set_delay(0.2)
	
	tween.tween_callback(label.queue_free)
	# ==========================================
# --- EVENTO ESPECIAL: PERFECT CLEAR ---
# ==========================================

func ejecutar_perfect_clear():
	# 1. Super premio de puntos y monedas
	score += 1000
	update_score(score)
	Global.agregar_monedas(25) # 25 monedas de golpe
	actualizar_ui_monedas()
	
	# 2. Espectáculo Visual
	mostrar_frase_hype("PERFECT\nCLEAR!!!", Color.GOLD)
	
	# Un temblor bestial
	aplicar_temblor(20.0)
	
	# Si tienes un sonido de Game Over o algo épico, puedes usarlo aquí cambiándole el pitch
	if sfx_combo:
		sfx_combo.pitch_scale = 1.5
		sfx_combo.play()

	# 3. Lluvia de monedas desde el centro de la pantalla
	var pantalla_centro = get_viewport_rect().size / 2
	for i in range(15):
		crear_moneda_voladora(pantalla_centro)
		await get_tree().create_timer(0.08).timeout
		
func animar_polvo_caida(posicion: Vector2):
	for i in range(6):
		var polvo = ColorRect.new()
		polvo.size = Vector2(10, 10)
		polvo.pivot_offset = polvo.size / 2
		polvo.color = Color(0.8, 0.8, 0.8, 0.7)
		
		var offset_inicial = Vector2(randf_range(-30, 30), randf_range(-10, 20))
		polvo.global_position = posicion + offset_inicial
		polvo.z_index = 80
		add_child(polvo)
		
		var tween = create_tween()
		var angulo = randf_range(0, PI * 2)
		var distancia = randf_range(30, 70)
		var dest_x = polvo.position.x + cos(angulo) * distancia
		var dest_y = polvo.position.y + sin(angulo) * distancia
		
		tween.parallel().tween_property(polvo, "position", Vector2(dest_x, dest_y), 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tween.parallel().tween_property(polvo, "rotation_degrees", randf_range(-180, 180), 0.3)
		tween.parallel().tween_property(polvo, "scale", Vector2.ZERO, 0.3)
		
		tween.tween_callback(polvo.queue_free)
		
# ==========================================
# --- SISTEMA DE PODERES (POWER-UPS) ---
# ==========================================

func _on_boton_refresh_pressed():
	if usos_refresh <= 0:
		mostrar_frase_hype("EMPTY!", Color.GRAY)
		return # Cortamos la función aquí para que no haga nada más
		
	var precio = 20
	if Global.monedas >= precio:
		usos_refresh -= 1 # Restamos un uso
		Global.monedas -= precio
		actualizar_ui_monedas()
		mostrar_frase_hype("REFRESH!", Color.CYAN)
		if sfx_pop: sfx_pop.play()
		
		for p in pieces_array:
			if p.visible:
				var tween = create_tween()
				tween.tween_property(p, "scale", Vector2.ZERO, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
				tween.tween_callback(p.hide)
		
		await get_tree().create_timer(0.3).timeout
		spawn_new_hand()
	else:
		mostrar_frase_hype("NO COINS!", Color.RED)
		animar_monedas_ui()

func _on_boton_bomba_pressed():
	if usos_bomba <= 0:
		mostrar_frase_hype("EMPTY!", Color.GRAY)
		return
		
	var precio = 50
	if Global.monedas >= precio:
		if board.has_method("explotar_bomba_inteligente"):
			usos_bomba -= 1 # Restamos un uso
			Global.monedas -= precio
			actualizar_ui_monedas()
			mostrar_frase_hype("BOMB!", Color.ORANGE)
			aplicar_temblor(15.0)
			
			board.explotar_bomba_inteligente()
			
			await get_tree().create_timer(0.5).timeout
			if board.get_empty_cells_count() == 64:
				ejecutar_perfect_clear()
			check_game_over()
	else:
		mostrar_frase_hype("NO COINS!", Color.RED)
		animar_monedas_ui()

func _on_boton_rayo_pressed():
	if usos_rayo <= 0:
		mostrar_frase_hype("EMPTY!", Color.GRAY)
		return
		
	var precio = 75
	if Global.monedas >= precio:
		if board.has_method("disparar_rayo_inteligente"):
			usos_rayo -= 1 # Restamos un uso
			Global.monedas -= precio
			actualizar_ui_monedas()
			mostrar_frase_hype("LASER!", Color.YELLOW)
			aplicar_temblor(12.0)
			
			board.disparar_rayo_inteligente()
			
			await get_tree().create_timer(0.5).timeout
			if board.get_empty_cells_count() == 64:
				ejecutar_perfect_clear()
			check_game_over()
	else:
		mostrar_frase_hype("NO COINS!", Color.RED)
		animar_monedas_ui()
