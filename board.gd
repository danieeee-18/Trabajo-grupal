# res://board.gd
extends Node2D

@export var efecto_explosion_scene: PackedScene

# Señal para puntos
signal puntos_ganados(puntos)

var block_texture = preload("res://block_texture.tres")

const GRID_SIZE = 8
const CELL_SIZE = 64

# Matriz de sprites
var grid_sprites = [] 

# Nodo contenedor para el fantasma
var ghost_container : Node2D

func _ready():
	# Inicializamos la matriz vacía de forma segura
	grid_sprites = []
	for x in range(GRID_SIZE):
		grid_sprites.append([]) 
		for y in range(GRID_SIZE):
			grid_sprites[x].append(null)
	
	# Creamos el contenedor del fantasma
	ghost_container = Node2D.new()
	ghost_container.name = "GhostContainer"
	ghost_container.z_index = 2 
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

func actualizar_fantasma(grid_x, grid_y, cells_shape, color_pieza):
	ocultar_fantasma()
	for cell in cells_shape:
		var fantasma = Sprite2D.new()
		fantasma.texture = block_texture
		fantasma.scale = Vector2(0.90, 0.90)
		fantasma.modulate = color_pieza
		fantasma.modulate.a = 0.5 
		
		var target_x = grid_x + cell.x
		var target_y = grid_y + cell.y
		fantasma.position = Vector2(target_x * CELL_SIZE, target_y * CELL_SIZE)
		ghost_container.add_child(fantasma)

func ocultar_fantasma():
	for hijo in ghost_container.get_children():
		hijo.queue_free()

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
	ocultar_fantasma()
	for cell in cells_shape:
		var target_x = start_x + cell.x
		var target_y = start_y + cell.y
		var new_block = Sprite2D.new()
		new_block.texture = block_texture
		new_block.modulate = color
		new_block.position = Vector2(target_x * CELL_SIZE, target_y * CELL_SIZE)
		add_child(new_block)
		grid_sprites[target_x][target_y] = new_block
	
	# Emitimos los puntos por colocar la pieza
	puntos_ganados.emit(cells_shape.size())
	await check_and_clear_lines()

func check_and_clear_lines():
	var rows_to_clear = []
	var cols_to_clear = []
	
	for x in range(GRID_SIZE):
		var is_full = true
		for y in range(GRID_SIZE):
			if grid_sprites[x][y] == null:
				is_full = false; break
		if is_full: cols_to_clear.append(x)
	
	for y in range(GRID_SIZE):
		var is_full = true
		for x in range(GRID_SIZE):
			if grid_sprites[x][y] == null:
				is_full = false; break
		if is_full: rows_to_clear.append(y)
		
	if rows_to_clear.size() == 0 and cols_to_clear.size() == 0:
		return
	
	var es_combo = (rows_to_clear.size() + cols_to_clear.size()) >= 2
	
	# Ejecutamos animaciones
	for y in rows_to_clear: animar_linea_completada(y, es_combo) 
	for x in cols_to_clear: animar_columna_completada(x, es_combo)
		
	await get_tree().create_timer(0.4).timeout
	
	# Borramos datos de la matriz
	for y in rows_to_clear: delete_row(y)
	for x in cols_to_clear: delete_col(x)
		
	var total_lines = rows_to_clear.size() + cols_to_clear.size()
	if total_lines > 0:
		var score_bonus = total_lines * 100
		puntos_ganados.emit(score_bonus)

func delete_row(y):
	for x in range(GRID_SIZE):
		if is_instance_valid(grid_sprites[x][y]):
			grid_sprites[x][y].queue_free()
		grid_sprites[x][y] = null     

func delete_col(x):
	for y in range(GRID_SIZE):
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
	var count = 0
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			if grid_sprites[x][y] == null: count += 1
	return count

func animar_linea_completada(fila_y, es_combo_grande):
	var tween = create_tween().set_parallel(true)
	for x in range(GRID_SIZE):
		var bloque = grid_sprites[x][fila_y]
		if is_instance_valid(bloque): 
			tween.tween_property(bloque, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BACK)
			tween.tween_property(bloque, "modulate:a", 0.0, 0.3)
	if es_combo_grande: aplicar_shake()

func animar_columna_completada(col_x, es_combo_grande):
	var tween = create_tween().set_parallel(true)
	for y in range(GRID_SIZE):
		var bloque = grid_sprites[col_x][y]
		if is_instance_valid(bloque):
			tween.tween_property(bloque, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BACK)
			tween.tween_property(bloque, "modulate:a", 0.0, 0.3)
	if es_combo_grande: aplicar_shake()

func aplicar_shake():
	var camera = get_viewport().get_camera_2d()
	if camera and camera.has_method("aplicar_temblor"):
		camera.aplicar_temblor(10.0)
func animar_ola_entrada():
	# Definimos una lista de colores vibrantes para el efecto confeti/ola
	var colores_fiesta = [
		Color(1, 0.2, 0.2), # Rojo
		Color(0.2, 1, 0.2), # Verde
		Color(0.2, 0.6, 1), # Azul
		Color(1, 1, 0.2),   # Amarillo
		Color(1, 0.2, 1),   # Rosa
		Color(0.2, 1, 1)    # Cian
	]
	
	var celdas = get_children()
	if celdas.size() == 0: return
	
	for celda in celdas:
		# Ignoramos el ghost_container y otros nodos que no sean las casillas
		if celda == ghost_container or not celda is Sprite2D: continue
		
		# Calculamos el delay basado en la posición para que haga el efecto de "ola" (diagonal)
		var grid_pos = celda.position / CELL_SIZE
		var indice_ola = grid_pos.x + grid_pos.y
		var delay_final = indice_ola * 0.08 # Un poco más rápido para que sea dinámico
		
		# Elegimos un color aleatorio de nuestra lista para el efecto inicial
		var color_aleatorio = colores_fiesta.pick_random()
		
		animar_celda(celda, delay_final, color_aleatorio)
func animar_celda(nodo, tiempo_espera, color_brillo):
	var color_original_fondo = Color(1, 1, 1, 0.1) # El gris transparente del fondo
	
	nodo.scale = Vector2(0, 0)
	nodo.modulate = color_brillo # Empieza con el color del confeti
	
	var tween = create_tween()
	tween.tween_interval(tiempo_espera)
	
	# Efecto de confeti (explosión de partículas)
	tween.tween_callback(func():
		if efecto_explosion_scene:
			var explosion = efecto_explosion_scene.instantiate()
			nodo.add_child(explosion)
			explosion.emitting = true
			# Hacemos que la explosión también tenga el color aleatorio
			explosion.modulate = color_brillo 
			
			# Limpieza 100% segura usando Tweens en vez de Timers
			var tween_limpieza = explosion.create_tween()
			tween_limpieza.tween_interval(1.0)
			tween_limpieza.tween_callback(explosion.queue_free)
	)
	
	tween.set_parallel(true)
	# Animación de escala con rebote (Elastic)
	tween.tween_property(nodo, "scale", Vector2(0.96, 0.96), 0.6).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	# Transición de color: del color brillante al gris transparente original
	tween.tween_property(nodo, "modulate", color_original_fondo, 0.8).set_trans(Tween.TRANS_SINE)


# ==========================================
# --- PODERES INTELIGENTES (POWER-UPS) ---
# ==========================================

func explotar_bomba_inteligente():
	var mejor_x = 1
	var mejor_y = 1
	var max_bloques = -1
	
	# 1. ESCÁNER: Buscamos el centro ideal (de 3x3) que tenga más bloques
	for cx in range(1, GRID_SIZE - 1):
		for cy in range(1, GRID_SIZE - 1):
			var contador = 0
			# Contamos los bloques en el 3x3 alrededor de este centro
			for dx in [-1, 0, 1]:
				for dy in [-1, 0, 1]:
					if grid_sprites[cx + dx][cy + dy] != null:
						contador += 1
						
			if contador > max_bloques:
				max_bloques = contador
				mejor_x = cx
				mejor_y = cy
				
	# 2. DESTRUCCIÓN: Explotamos esa zona 3x3
	var bloques_destruidos = 0
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			var tx = mejor_x + dx
			var ty = mejor_y + dy
			var bloque = grid_sprites[tx][ty]
			
			if is_instance_valid(bloque):
				# Animación de implosión
				var tween = create_tween()
				tween.tween_property(bloque, "scale", Vector2.ZERO, 0.3).set_trans(Tween.TRANS_BACK)
				tween.tween_callback(bloque.queue_free) # Lo borramos de la memoria
				
				grid_sprites[tx][ty] = null # Liberamos la casilla
				bloques_destruidos += 1
				
	# 3. RECOMPENSA: Damos un bonus de puntos por los bloques destruidos
	if bloques_destruidos > 0:
		puntos_ganados.emit(bloques_destruidos * 50)

func disparar_rayo_inteligente():
	var cuenta_filas = [0, 0, 0, 0, 0, 0, 0, 0]
	var cuenta_columnas = [0, 0, 0, 0, 0, 0, 0, 0]
	
	# 1. ESCÁNER: Contamos cuántos bloques hay en cada fila y columna
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			if grid_sprites[x][y] != null:
				cuenta_columnas[x] += 1
				cuenta_filas[y] += 1
				
	# 2. BÚSQUEDA DE LA CRUZ PERFECTA: Buscamos la intersección que rompa más bloques
	var mejor_x = 0
	var mejor_y = 0
	var max_bloques = -1
	
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			# Sumamos los de su fila y columna
			var suma = cuenta_columnas[x] + cuenta_filas[y]
			# Si en el centro exacto de la cruz hay un bloque, restamos 1 para no contarlo doble
			if grid_sprites[x][y] != null: 
				suma -= 1
				
			if suma > max_bloques:
				max_bloques = suma
				mejor_x = x
				mejor_y = y
				
	# 3. DESTRUCCIÓN: Limpiamos esa fila y columna entera (Forma de cruz)
	var bloques_destruidos = 0
	
	# Destruimos la Columna
	for y in range(GRID_SIZE):
		var bloque = grid_sprites[mejor_x][y]
		if is_instance_valid(bloque):
			var tween = create_tween()
			tween.tween_property(bloque, "scale", Vector2.ZERO, 0.2).set_delay(y * 0.05) # Efecto cascada
			tween.tween_callback(bloque.queue_free)
			grid_sprites[mejor_x][y] = null
			bloques_destruidos += 1
			
	# Destruimos la Fila
	for x in range(GRID_SIZE):
		var bloque = grid_sprites[x][mejor_y]
		if is_instance_valid(bloque):
			var tween = create_tween()
			tween.tween_property(bloque, "scale", Vector2.ZERO, 0.2).set_delay(x * 0.05) # Efecto cascada
			tween.tween_callback(bloque.queue_free)
			grid_sprites[x][mejor_y] = null
			bloques_destruidos += 1

	# 4. RECOMPENSA: Bonus extra brutal por usar el rayo
	if bloques_destruidos > 0:
		puntos_ganados.emit(bloques_destruidos * 60)
