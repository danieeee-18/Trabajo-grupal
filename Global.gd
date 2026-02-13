extends Node

# VARIABLES GLOBALES
var high_score = 0
var monedas = 0 # Tu cartera
var sonido_activado = true
var musica_activada = true
var vibracion_activada = true

# RUTA DE GUARDADO
const SAVE_PATH = "user://savegame.save"

func _ready():
	load_game()
	# Aplicamos el audio nada más cargar
	aplicar_audio_guardado()

# --- ACTUALIZAR RÉCORD ---
func actualizar_record(puntos_actuales):
	if puntos_actuales > high_score:
		high_score = puntos_actuales
		save_game() # Guardamos inmediatamente

# --- GESTIÓN DE DINERO ---
func agregar_monedas(cantidad):
	monedas += cantidad
	save_game() # Guardamos para que no se pierda el dinero
	print("💰 Monedas actuales: ", monedas)

# --- SISTEMA DE GUARDADO ---
func save_game():
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	var data = {
		"high_score": high_score,
		"monedas": monedas,
		"sonido_activado": sonido_activado,
		"musica_activada": musica_activada,
		"vibracion_activada": vibracion_activada
	}
	file.store_var(data)

func load_game():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var data = file.get_var()
		
		# Protección contra archivos corruptos
		if data == null or not (data is Dictionary):
			print("Archivo antiguo o corrupto. Usando valores por defecto.")
			return 
		
		high_score = data.get("high_score", 0)
		monedas = data.get("monedas", 0)
		sonido_activado = data.get("sonido_activado", true)
		musica_activada = data.get("musica_activada", true)
		vibracion_activada = data.get("vibracion_activada", true)
	else:
		print("No hay datos guardados, iniciando nueva partida.")

# --- APLICAR AUDIO ---
func aplicar_audio_guardado():
	var bus_musica = AudioServer.get_bus_index("Musica")
	var bus_efectos = AudioServer.get_bus_index("Efectos")
	
	if bus_musica != -1:
		AudioServer.set_bus_mute(bus_musica, not musica_activada)
	
	if bus_efectos != -1:
		AudioServer.set_bus_mute(bus_efectos, not sonido_activado)
