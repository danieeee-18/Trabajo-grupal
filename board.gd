extends Node2D

@export var efecto_explosion_scene: PackedScene

# Señal para puntos
signal puntos_ganados(puntos)

var block_texture = preload("res://block_texture.tres")

const GRID_SIZE = 8
const CELL_SIZE = 64

# Matriz de sprites
var grid_sprites = [] 

# Nodo contenedor para el fantasma (Para que se dibuje ENCIMA de las casillas)
var ghost_container : Node2D

func _ready():
	# Inicializamos la matriz vacía
	for x in range(GRID_SIZE):
		grid_sprites.append([]) 
		for y in range(GRID_SIZE):
			grid_sprites[x].append(null)
	
	# Creamos el contenedor del fantasma
	ghost_container = Node2D.new()
	ghost_container.z_index = 2 # ¡IMPORTANTE! Esto hace que se vea encima de todo
	add_child(ghost_container)
	
	draw_background_grid()

func draw_background_grid():
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			var slot = Sprite2D.new()
			slot.texture = block_texture
			slot.scale = Vector2(0.96, 0.96)
			slot.modulate = Color(1, 1, 1, 0.1) 
			slot.position = Vector2(x * CELL_SIZE, y * CELL_SIZE)
			add_child(slot)

# --- FUNCIONES DEL FANTASMA (NUEVO MÉTODO ROBUSTO) ---

func actualizar_fantasma(grid_x, grid_y, cells_shape, color_pieza):
	# 1. Limpiamos el fantasma anterior
	ocultar_fantasma()
	
	# 2. Creamos los nuevos bloques fantasma
	for cell in cells_shape:
		var fantasma = Sprite2D.new() # Usamos Sprite para que tenga la misma forma
		fantasma.texture = block_texture
		fantasma.scale = Vector2(0.90, 0.90) # Un pelín más pequeño para que quede elegante
		
		# Color semitransparente
		fantasma.modulate = color_pieza
		fantasma.modulate.a = 0.5 
		
		# Posición calculada
		var target_x = grid_x + cell.x
		var target_y = grid_y + cell.y
		fantasma.position = Vector2(target_x * CELL_SIZE, target_y * CELL_SIZE)
		
		ghost_container.add_child(fantasma)

func ocultar_fantasma():
	# Borramos todos los hijos del contenedor fantasma
	for hijo in ghost_container.get_children():
		hijo.queue_free()

# -----------------------------------------------------

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
	# Limpiamos fantasma al colocar
	ocultar_fantasma()
	
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
	
	puntos_ganados.emit(cells_shape.size())
	await check_and_clear_lines()

func check_and_clear_lines():
	var rows_to_clear = []
	var cols_to_clear = []
	
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
	
	for y in rows_to_clear: animar_linea_completada(y, is_combo) 
	for x in cols_to_clear: animar_columna_completada(x, is_combo)
		
	await get_tree().create_timer(0.4).timeout
	
	for y in rows_to_clear: delete_row(y)
	for x in cols_to_clear: delete_col(x)
		
	var total_lines = rows_to_clear.size() + cols_to_clear.size()
	if total_lines > 0:
		var score_bonus = total_lines * 100 * total_lines
		puntos_ganados.emit(score_bonus)

func delete_column(x): # Esta sobraba o era redundante, pero la dejo por si acaso
	delete_col(x)

func delete_row(y):
	for x in range(GRID_SIZE):
		if grid_sprites[x][y] != null:
			if is_instance_valid(grid_sprites[x][y]):
				grid_sprites[x][y].queue_free() 
			grid_sprites[x][y] = null     

func delete_col(x):
	for y in range(GRID_SIZE):
		if grid_sprites[x][y] != null:
			if is_instance_valid(grid_sprites[x][y]):
				grid_sprites[x][y].queue_free()
			grid_sprites[x][y] = null  

func check_if_shape_fits_anywhere(cells_shape):
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			if can_place_piece(x, y, cells_shape):
				return true 
	return false 

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
		if is_instance_valid(bloque): 
			tween.tween_property(bloque, "scale", Vector2(1.2, 1.2), 0.1)
			tween.tween_property(bloque, "scale", Vector2.ZERO, 0.3).set_delay(0.1)
			tween.tween_property(bloque, "modulate:a", 0.0, 0.3)
			if es_combo_grande: bloque.modulate = Color(2, 2, 2) 
	
	if es_combo_grande: aplicar_shake()
	await tween.finished

func animar_columna_completada(col_x, es_combo_grande):
	var tween = create_tween()
	tween.set_parallel(true)
	
	for y in range(GRID_SIZE):
		var bloque = grid_sprites[col_x][y]
		if is_instance_valid(bloque):
			tween.tween_property(bloque, "scale", Vector2(1.2, 1.2), 0.1)
			tween.tween_property(bloque, "scale", Vector2.ZERO, 0.3).set_delay(0.1)
			tween.tween_property(bloque, "modulate:a", 0.0, 0.3)
			if es_combo_grande: bloque.modulate = Color(2, 2, 2)
				
	if es_combo_grande: aplicar_shake()
	await tween.finished

func aplicar_shake():
	var camera = get_viewport().get_camera_2d()
	if camera:
		var tween_cam = create_tween()
		for i in range(10):
			var offset_random = Vector2(randf_range(-5, 5), randf_range(-5, 5))
			tween_cam.tween_property(camera, "offset", offset_random, 0.02)
		tween_cam.tween_property(camera, "offset", Vector2.ZERO, 0.02)

func animar_ola_entrada():
	var celdas = get_children()
	if celdas.size() == 0: return
	
	for celda in celdas:
		# Ignoramos el ghost_container para que no de error
		if celda == ghost_container: continue
		
		if celda is Node2D:
			if "Marker" in celda.name: continue 
			var grid_pos = celda.position / 64 
			var indice_ola = grid_pos.x + grid_pos.y
			var delay_final = indice_ola * 0.1 
			animar_celda(celda, delay_final)

func animar_celda(nodo, tiempo_espera):
	var color_final = nodo.modulate
	nodo.scale = Vector2(0, 0) 
	nodo.modulate = Color(2, 0.5, 1) 
	
	var tween = create_tween()
	tween.tween_interval(tiempo_espera) 
	
	tween.tween_callback(func():
		if efecto_explosion_scene:
			var explosion = efecto_explosion_scene.instantiate()
			# Si el nodo es un Sprite, no tiene "size", usamos el centro 0,0
			# Si quieres ajustar posicion de explosion, hazlo aqui
			nodo.add_child(explosion)
			explosion.emitting = true
			await explosion.finished
			explosion.queue_free()
	)
	
	tween.set_parallel(true)
	tween.tween_property(nodo, "scale", Vector2(0.96, 0.96), 0.4).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(nodo, "modulate", color_final, 0.4)
