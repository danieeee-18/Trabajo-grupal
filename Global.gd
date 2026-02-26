extends Node

# VARIABLES GLOBALES

var fondos_desbloqueados = ["base"] # Empezamos con el clásico desbloqueado
var fondo_equipado = "base"

var high_score = 0
var monedas = 0 # Tu cartera
var sonido_activado = true
var musica_activada = true
var vibracion_activada = true

# --- EL CATÁLOGO (Híbrido: Colores + Imágenes) ---
var catalogo_fondos = [
	{"id": "base", "nombre": "Classic", "precio": 0, "color": Color(0.2, 0.2, 0.25), "ruta_imagen": ""},
	{"id": "neon", "nombre": "Cyberpunk", "precio": 100, "color": Color(0.8, 0.1, 0.5), "ruta_imagen": ""},
	{"id": "oro", "nombre": "King Midas", "precio": 500, "color": Color(0.9, 0.7, 0.1), "ruta_imagen": ""},
	
	# Nuevos fondos con imágenes (Asegúrate de que estas imágenes existen en tu carpeta 'fondos')
	{"id": "infierno", "nombre": "Hell", "precio": 1000, "color": Color(1, 0, 0), "ruta_imagen": "res://fondos/infierno.jpg"},
	{"id": "mar", "nombre": "Ocean", "precio": 1200, "color": Color(0, 0, 1), "ruta_imagen": "res://fondos/mar.JPG"},
	{"id": "galaxia", "nombre": "Galaxy", "precio": 1500, "color": Color(0.5, 0, 0.8), "ruta_imagen": "res://fondos/galaxia.jpg"}
]

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
		"vibracion_activada": vibracion_activada,
		"fondos_desbloqueados": fondos_desbloqueados, # NUEVO
		"fondo_equipado": fondo_equipado              # NUEVO
	}
	file.store_var(data)

func load_game():
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var data = file.get_var()
		if data == null or not (data is Dictionary): return 
		
		high_score = data.get("high_score", 0)
		monedas = data.get("monedas", 0)
		sonido_activado = data.get("sonido_activado", true)
		musica_activada = data.get("musica_activada", true)
		vibracion_activada = data.get("vibracion_activada", true)
		fondos_desbloqueados = data.get("fondos_desbloqueados", ["base"]) # NUEVO
		fondo_equipado = data.get("fondo_equipado", "base")               # NUEVO
# --- APLICAR AUDIO ---
func aplicar_audio_guardado():
	var bus_musica = AudioServer.get_bus_index("Musica")
	var bus_efectos = AudioServer.get_bus_index("Efectos")
	
	if bus_musica != -1:
		AudioServer.set_bus_mute(bus_musica, not musica_activada)
	
	if bus_efectos != -1:
		AudioServer.set_bus_mute(bus_efectos, not sonido_activado)
