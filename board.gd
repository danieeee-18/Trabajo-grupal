extends Node2D
@export var efecto_explosion_scene: PackedScene

# --- SEÑAL NUEVA: Avisa cuando ganamos puntos ---
signal puntos_ganados(puntos)

var block_texture = preload("res://block_texture.tres")

const GRID_SIZE = 8
const CELL_SIZE = 64

# Matriz de sprites
var grid_sprites = [] 

func _ready():
	# Inicializamos la matriz vacía
	for x in range(GRID_SIZE):
		grid_sprites.append([]) 
		for y in range(GRID_SIZE):
			grid_sprites[x].append(null)
	
	draw_background_grid()

func draw_background_grid():
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var slot = Sprite2D.new()
			slot.texture = block_texture
			
			# ESCALA: 0.96 para dejar una línea fina entre casillas
			slot.scale = Vector2(0.96, 0.96)
			
			# EL TRUCO DEL COLOR:
			# Usamos BLANCO al 10% de opacidad.
			# Al ponerse sobre el fondo negro (#111111), se ve GRIS GRAFITO.
			slot.modulate = Color(1, 1, 1, 0.1) 
			
			slot.position = Vector2(x * CELL_SIZE, y * CELL_SIZE)
			add_child(slot)

func can_place_piece(start_x, start_y, cells_shape):
	for cell in cells_shape:
		var target_x = start_x + cell.x
		var target_y = start_y + cell.y
		
		if target_x < 0 or target_x >= GRID_SIZE or target_y < 0 or target_y >= GRID_SIZE:
			return false
		
		if grid_sprites[target_x][target_y] != null:
			return false
			
	return true

func place_piece(start_x, start_y, cells_shape, color):
	# 1. Colocamos los bloques
	for cell in cells_shape:
		var target_x = start_x + cell.x
		var target_y = start_y + cell.y
		
		var new_block = Sprite2D.new()
		new_block.texture = block_texture
		new_block.modulate = color
		new_block.position = Vector2(target_x * CELL_SIZE, target_y * CELL_SIZE)
		add_child(new_block)
		
		grid_sprites[target_x][target_y] = new_block
	
	# 2. PUNTOS BASE: Ganamos tantos puntos como bloques tenga la pieza
	puntos_ganados.emit(cells_shape.size())
	
	# 3. Comprobamos líneas
	await check_and_clear_lines()
func check_and_clear_lines():
	var rows_to_clear = []
	var cols_to_clear = []
	
	# 1. DETECTAR (Esto sigue igual)
	for x in range(GRID_SIZE):
		var is_full = true
		for y in range(GRID_SIZE):
			if grid_sprites[x][y] == null:
				is_full = false
				break
		if is_full: cols_to_clear.append(x)
	
	for y in range(GRID_SIZE):
		var is_full = true
		for x in range(GRID_SIZE):
			if grid_sprites[x][y] == null:
				is_full = false
				break
		if is_full: rows_to_clear.append(y)
		
	if rows_to_clear.size() == 0 and cols_to_clear.size() == 0:
		return
	
	var is_combo = (rows_to_clear.size() + cols_to_clear.size()) >= 2
	
	# --- FASE 1: ANIMACIÓN (Nadie muere todavía) ---
	
	# Animamos las filas detectadas
	for y in rows_to_clear:
		# No usamos await aquí para que las columnas se animen a la vez
		animar_linea_completada(y, is_combo) 
		
	# Animamos las columnas detectadas
	for x in cols_to_clear:
		animar_columna_completada(x, is_combo)
		
	# Esperamos un poco manualmente para que se vean las animaciones
	# (0.4 segundos es lo que duran tus tweens: 0.1 + 0.3)
	await get_tree().create_timer(0.4).timeout
	
	# --- FASE 2: BORRADO (Ahora sí, limpieza general) ---
	
	for y in rows_to_clear:
		delete_row(y)
		
	for x in cols_to_clear:
		delete_col(x)
		
	# Sonido de éxito (Opcional)
	# if is_combo: ...
	
	# --- CÁLCULO DE COMBO ---
	var total_lines = rows_to_clear.size() + cols_to_clear.size()
	if total_lines > 0:
		# Fórmula: 100 puntos * número de líneas * número de líneas
		# 1 linea = 100, 2 lineas = 400, 3 lineas = 900
		var score_bonus = total_lines * 100 * total_lines
		puntos_ganados.emit(score_bonus)
	
	# Borrar visualmente
	for x in cols_to_clear: delete_column(x)
	for y in rows_to_clear: delete_row(y)

func delete_column(x):
	for y in range(GRID_SIZE):
		if grid_sprites[x][y] != null:
			grid_sprites[x][y].queue_free() 
			grid_sprites[x][y] = null       

func delete_row(y):
	for x in range(GRID_SIZE):
		if grid_sprites[x][y] != null:
			grid_sprites[x][y].queue_free() 
			grid_sprites[x][y] = null     
			
func delete_col(x):
	# Recorremos todas las filas (Y) para esa columna fija (X)
	for y in range(GRID_SIZE):
		if grid_sprites[x][y] != null:
			# Borramos el nodo visual
			grid_sprites[x][y].queue_free()
			# Borramos el dato de la matriz
			grid_sprites[x][y] = null  

# IA: Comprobar si cabe algo
func check_if_shape_fits_anywhere(cells_shape):
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			if can_place_piece(x, y, cells_shape):
				return true 
	return false 

# IA: Contar vacíos
func get_empty_cells_count():
	var empty_count = 0
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			if grid_sprites[x][y] == null:
				empty_count += 1
	return empty_count

func animar_linea_completada(fila_y, es_combo_grande):
	var tween = create_tween()
	tween.set_parallel(true)
	
	for x in range(GRID_SIZE):
		var bloque = grid_sprites[x][fila_y]
		
		# --- CAMBIA ESTA LÍNEA ---
		if is_instance_valid(bloque): # <--- Antes ponía: if bloque != null:
		# -------------------------
			
			tween.tween_property(bloque, "scale", Vector2(1.2, 1.2), 0.1)
			tween.tween_property(bloque, "scale", Vector2.ZERO, 0.3).set_delay(0.1) # Aquí daba el error
			tween.tween_property(bloque, "modulate:a", 0.0, 0.3)
			
			if es_combo_grande:
				bloque.modulate = Color(2, 2, 2) 
	
	if es_combo_grande:
		aplicar_shake()
	
	await tween.finished
	
	# Recorremos todas las celdas de esa fila (Asumiendo tablero de 10x10 u 8x8)
	for x in range(GRID_SIZE): # Asegúrate de usar tu variable de ancho (8 o 10)
		var bloque = grid_sprites[x][fila_y]
		
		if bloque != null:
			# 1. ANIMACIÓN BÁSICA (Escala y Transparencia)
			# Hacemos que crezca un pelín y luego desaparezca (efecto "Pop")
			tween.tween_property(bloque, "scale", Vector2(1.2, 1.2), 0.1)
			tween.tween_property(bloque, "scale", Vector2.ZERO, 0.3).set_delay(0.1)
			tween.tween_property(bloque, "modulate:a", 0.0, 0.3) # Desvanecer
			
			# 2. ANIMACIÓN DE COMBO (Si borras 2+ líneas)
			if es_combo_grande:
				# Flash Blanco: Cambiamos el color a blanco puro brillante y luego volvemos
				bloque.modulate = Color(2, 2, 2) # Blanco brillante (HDR)
	
	# Efecto de Cámara (Shake) si es combo
	if es_combo_grande:
		aplicar_shake()
	
	# Esperamos a que termine la animación antes de devolver el control
	await tween.finished

func aplicar_shake():
	var camera = get_viewport().get_camera_2d()
	if camera:
		var tween_cam = create_tween()
		for i in range(10):
			var offset_random = Vector2(randf_range(-5, 5), randf_range(-5, 5))
			tween_cam.tween_property(camera, "offset", offset_random, 0.02)
		tween_cam.tween_property(camera, "offset", Vector2.ZERO, 0.02)
		
func animar_columna_completada(col_x, es_combo_grande):
	var tween = create_tween()
	tween.set_parallel(true)
	
	for y in range(GRID_SIZE):
		var bloque = grid_sprites[col_x][y]
		
		# --- CAMBIA ESTA LÍNEA TAMBIÉN ---
		if is_instance_valid(bloque): # <--- Usa is_instance_valid aquí también
		# -------------------------------
			
			tween.tween_property(bloque, "scale", Vector2(1.2, 1.2), 0.1)
			tween.tween_property(bloque, "scale", Vector2.ZERO, 0.3).set_delay(0.1)
			tween.tween_property(bloque, "modulate:a", 0.0, 0.3)
			
			if es_combo_grande:
				bloque.modulate = Color(2, 2, 2)
				
	if es_combo_grande:
		aplicar_shake()
		
	await tween.finished
	
	

# --- ANIMACIONES DEL TABLERO ---

# En Board.gd

func animar_ola_entrada():
	var celdas = get_children()
	
	if celdas.size() == 0: return
	
	print("🌊 Lanzando ola lenta desde Arriba-Izquierda...")
	
	for celda in celdas:
		if celda is Node2D or celda is Control:
			if "Marker" in celda.name: continue 
			
			# 1. Calculamos posición en la cuadrícula
			var grid_pos = celda.position / 64 
			
			# 2. FÓRMULA DE OLA CLÁSICA (Arriba-Izquierda -> Abajo-Derecha)
			# Sumamos X + Y: Las celdas cerca del (0,0) empiezan antes.
			var indice_ola = grid_pos.x + grid_pos.y
			
			# 3. VELOCIDAD
			# Multiplicamos por 0.1 (Cuanto más alto el número, más lenta la ola)
			var delay_final = indice_ola * 0.1 
			
			animar_celda(celda, delay_final)

func animar_celda(nodo, tiempo_espera):
	# Guardamos su color original (blanco o el que tenga)
	var color_final = nodo.modulate
	
	# ESTADO INICIAL (Antes de aparecer)
	nodo.scale = Vector2(0, 0) # Invisible (diminuto)
	nodo.modulate = Color(2, 0.5, 1) # Un color inicial (ej. morado/rosa brillante)
	
	# EL TWEEN (La animación)
	var tween = create_tween()
	tween.tween_interval(tiempo_espera) # Esperar su turno
	
	# --- NUEVO: Disparar la explosión ---
	tween.tween_callback(func():
		if efecto_explosion_scene:
			var explosion = efecto_explosion_scene.instantiate()
			
			# Centramos la explosión en la celda
			if "size" in nodo:
				explosion.position = nodo.size / 2
			
			nodo.add_child(explosion)
			explosion.emitting = true
			
			# Limpieza automática: borra la explosión cuando termine
			await explosion.finished
			explosion.queue_free()
	)
	# ------------------------------------
	
	# Efecto de "Pop" elástico
	tween.set_parallel(true)
	tween.tween_property(nodo, "scale", Vector2(1, 1), 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(nodo, "modulate", color_final, 0.4) # Volver a su color normal
