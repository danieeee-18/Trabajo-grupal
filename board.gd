extends Node2D

var block_texture = preload("res://block_texture.tres")

const GRID_SIZE = 8
const CELL_SIZE = 64

# Memoria: Ahora guardaremos el propio bloque (Sprite2D) o null
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
		
		# Si hay un sprite guardado ahí, es que está ocupado
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
	
	# 2. Inmediatamente comprobamos si hemos hecho línea
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
		if is_full:
			cols_to_clear.append(x)
	
	# Revisar Filas
	for y in range(GRID_SIZE):
		var is_full = true
		for x in range(GRID_SIZE):
			if grid_sprites[x][y] == null:
				is_full = false
				break
		if is_full:
			rows_to_clear.append(y)
	
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

# --- NUEVA FUNCIÓN: INTELIGENCIA ARTIFICIAL ---
# Esta función prueba "a fuerza bruta" si una forma cabe en ALGÚN sitio
func check_if_shape_fits_anywhere(cells_shape):
	# Probamos todas las casillas del tablero (0,0) a (7,7)
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			# Si en la posición X,Y la pieza cabe...
			if can_place_piece(x, y, cells_shape):
				return true # ¡Sí cabe! Aún no has perdido.
				
	return false # Hemos probado todo y no cabe.
	# --- NUEVA FUNCIÓN: CONTAR ESPACIOS ---
# Devuelve cuántas casillas vacías quedan (de 0 a 64)
func get_empty_cells_count():
	var empty_count = 0
	for x in range(GRID_SIZE):
		for y in range(GRID_SIZE):
			# Si es null, está vacío
			if grid_sprites[x][y] == null:
				empty_count += 1
	return empty_count
