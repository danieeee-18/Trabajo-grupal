extends Node2D

# --- SEÑAL NUEVA: Avisa cuando ganamos puntos ---
signal puntos_ganados(cantidad)

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
			slot.modulate = Color(0.2, 0.2, 0.2) 
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
	check_and_clear_lines()

func check_and_clear_lines():
	var rows_to_clear = []
	var cols_to_clear = []
	
	# Revisar Columnas
	for x in range(GRID_SIZE):
		var is_full = true
		for y in range(GRID_SIZE):
			if grid_sprites[x][y] == null:
				is_full = false
				break
		if is_full: cols_to_clear.append(x)
	
	# Revisar Filas
	for y in range(GRID_SIZE):
		var is_full = true
		for x in range(GRID_SIZE):
			if grid_sprites[x][y] == null:
				is_full = false
				break
		if is_full: rows_to_clear.append(y)
	
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
