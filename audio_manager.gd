extends Node

# --- VARIABLES PARA ARRASTRAR TUS CANCIONES ---
@export var musica_menu: AudioStream
@export var musica_juego: AudioStream
@export var musica_gameover: AudioStream

# Referencia al altavoz hijo
@onready var player = $MusicPlayer

func _ready():
	# Configuración inicial de seguridad
	if player:
		player.volume_db = -10.0 # Un volumen base agradable
	else:
		print("ERROR CRÍTICO: No encuentro el nodo 'MusicPlayer' dentro de AudioManager.")

# --- FUNCIONES PÚBLICAS (LAS QUE LLAMA EL JUEGO) ---

func poner_musica_menu():
	cambiar_pista(musica_menu)

func poner_musica_juego():
	cambiar_pista(musica_juego)

func poner_musica_gameover():
	cambiar_pista(musica_gameover)

# --- SISTEMA INTERNO (EL CEREBRO DEL DJ) ---

func cambiar_pista(nueva_cancion):
	# 1. Si el reproductor no existe, abortamos
	if not player:
		return
	
	# 2. Si no has puesto canción en el Inspector, avisamos
	# (Aquí estaba el error, ahora pone 'nueva_cancion')
	if nueva_cancion == null:
		print("AVISO: Se ha pedido música, pero no hay archivo asignado en el Inspector.")
		return

	# 3. Si YA está sonando esa misma canción, no la reiniciamos
	if player.stream == nueva_cancion and player.playing:
		return
	
	# 4. Cambiamos el disco y le damos al Play
	player.stream = nueva_cancion
	player.play()

# --- CONTROL DE MUTE GLOBAL ---

func mutear_musica(es_muteado: bool):
	var bus_idx = AudioServer.get_bus_index("Musica")
	if bus_idx != -1:
		AudioServer.set_bus_mute(bus_idx, es_muteado)

func mutear_sfx(es_muteado: bool):
	var bus_idx = AudioServer.get_bus_index("Efectos")
	if bus_idx != -1:
		AudioServer.set_bus_mute(bus_idx, es_muteado)
