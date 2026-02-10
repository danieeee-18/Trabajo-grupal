extends Node

# --- VARIABLES PARA ARRASTRAR MÚSICA ---
@export var musica_menu: AudioStream
@export var musica_juego: AudioStream
@export var musica_gameover: AudioStream

# Referencia al hijo (el altavoz)
@onready var player = $MusicPlayer

func _ready():
	# Configuración inicial de volumen
	if player:
		player.volume_db = -10.0
	else:
		print("ERROR CRÍTICO: No encuentro el nodo MusicPlayer")

# --- FUNCIONES DE CONTROL ---

func poner_musica_menu():
	if musica_menu: cambiar_pista(musica_menu)

func poner_musica_juego():
	if musica_juego: cambiar_pista(musica_juego)

func poner_musica_gameover():
	if musica_gameover: cambiar_pista(musica_gameover)

# --- LÓGICA INTERNA ---
func cambiar_pista(nueva_cancion):
	# Si ya suena esa canción, no hacemos nada
	if player.stream == nueva_cancion and player.playing:
		return
	
	# Si es nueva, cambiamos
	player.stream = nueva_cancion
	player.play()
	
	# --- CONTROL DE VOLUMEN GLOBAL ---

func mutear_musica(es_muteado: bool):
	# Buscamos el canal "Musica"
	var bus_idx = AudioServer.get_bus_index("Musica")
	# Lo apagamos o encendemos
	AudioServer.set_bus_mute(bus_idx, es_muteado)

func mutear_sfx(es_muteado: bool):
	# Buscamos el canal "Efectos"
	var bus_idx = AudioServer.get_bus_index("Efectos")
	AudioServer.set_bus_mute(bus_idx, es_muteado)
