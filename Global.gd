extends Node

# Archivo donde se guardarán los datos
const SAVE_PATH = "user://savegame.save"

# Variables del juego
var high_score = 0
var sonido_activado = true
var musica_activada = true
var vibracion_activada = true

func _ready():
	load_game()

func actualizar_record(puntos_nuevos):
	if puntos_nuevos > high_score:
		high_score = puntos_nuevos
		save_game()

# --- SISTEMA DE GUARDADO ---

func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data = {
		"high_score": high_score,
		"sonido": sonido_activado,
		"musica": musica_activada,
		"vibracion": vibracion_activada
	}
	var json_string = JSON.stringify(data)
	file.store_line(json_string)
	print("Partida guardada.")

func load_game():
	if not FileAccess.file_exists(SAVE_PATH):
		print("No hay partida guardada previa.")
		return

	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	var json_string = file.get_line()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	
	# AQUÍ ES DONDE TE DABA EL ERROR ANTES
	# Fíjate que este 'if' está empujado a la derecha (dentro de la función)
	if parse_result == OK:
		var data = json.get_data()
		
		# Aquí aplicamos el truco del int() para evitar el 0.0
		high_score = int(data.get("high_score", 0))
		
		sonido_activado = data.get("sonido", true)
		musica_activada = data.get("musica", true)
		vibracion_activada = data.get("vibracion", true)
		print("Datos cargados correctamente. Récord: ", high_score)
	else:
		print("Error al leer el archivo de guardado.")
