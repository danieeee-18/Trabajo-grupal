extends Control

# REFERENCIAS A LOS NODOS
@onready var check_sonido = find_child("CheckButtonSonido")
@onready var check_musica = find_child("CheckButtonMusica")
@onready var check_vibra = find_child("CheckButtonVibra")
@onready var boton_volver = $BotonVolver
@onready var boton_reset = find_child("BotonReset")

func _ready():
	print("Script de opciones cargado en: ", name)
	
	if boton_volver == null:
		print("ERROR: No se encuentra 'BotonVolver'. Revisa el nombre en la escena.")
		return

	# 1. SINCRONIZAR BOTONES CON VARIABLES GLOBALES
	check_sonido.button_pressed = Global.sonido_activado
	check_musica.button_pressed = Global.musica_activada
	check_vibra.button_pressed = Global.vibracion_activada
	
	# 2. APLICAR EL SILENCIO REAL AL ENTRAR EN EL MENÚ <--- NUEVO
	# (Esto asegura que si entras y estaba apagado, siga apagado)
	_actualizar_audio_real()

	# 3. CONEXIÓN DE BOTONES
	boton_volver.pressed.connect(_on_volver_pressed)
	boton_reset.pressed.connect(_on_reset_record_pressed)
	
	check_sonido.toggled.connect(_on_sonido_toggled)
	check_musica.toggled.connect(_on_musica_toggled)
	check_vibra.toggled.connect(_on_vibra_toggled)

# --- FUNCIÓN AUXILIAR NUEVA ---
func _actualizar_audio_real():
	# Buscamos los canales
	var bus_musica = AudioServer.get_bus_index("Musica")
	var bus_efectos = AudioServer.get_bus_index("Efectos")
	
	# Aplicamos el muteo
	# Si el botón está ACTIVADO (true), el mute debe ser FALSO.
	# Si el botón está DESACTIVADO (false), el mute debe ser VERDADERO.
	AudioServer.set_bus_mute(bus_musica, not Global.musica_activada)
	AudioServer.set_bus_mute(bus_efectos, not Global.sonido_activado)

# --- FUNCIONES DE LÓGICA ---

func _on_volver_pressed():
	get_tree().change_scene_to_file("res://MenuPrincipal.tscn")

func _on_reset_record_pressed():
	Global.high_score = 0
	Global.save_game()
	print("Récord reseteado.")

# --- INTERRUPTORES (ACTUALIZAN VARIABLE Y AUDIO AL INSTANTE) ---

func _on_sonido_toggled(toggled_on): 
	# 1. Guardar dato
	Global.sonido_activado = toggled_on
	Global.save_game()
	
	# 2. Aplicar silencio real <--- NUEVO
	var bus_idx = AudioServer.get_bus_index("Efectos")
	# "not toggled_on" significa: Si el botón está ON, Mute es OFF.
	AudioServer.set_bus_mute(bus_idx, not toggled_on)

func _on_musica_toggled(toggled_on): 
	print("--- INTENTANDO CAMBIAR MÚSICA ---")
	
	# 1. Buscamos el índice
	var bus_idx = AudioServer.get_bus_index("Musica")
	print("El índice del bus Musica es: ", bus_idx)
	
	if bus_idx == -1:
		print("ERROR: ¡No existe el bus 'Musica'! Revisa la pestaña Audio.")
	else:
		# 2. Aplicamos silencio
		AudioServer.set_bus_mute(bus_idx, not toggled_on)
		print("Música cambiada. ¿Está muteado?: ", AudioServer.is_bus_mute(bus_idx))
		
	# 3. Guardar dato
	Global.musica_activada = toggled_on
	Global.save_game()

func _on_vibra_toggled(toggled_on): 
	Global.vibracion_activada = toggled_on
	Global.save_game()
	# La vibración se controla en el MainGame con un 'if Global.vibracion_activada',
	# así que aquí no hace falta llamar al AudioServer.
	
func _on_btn_tienda_pressed():
	# Despausar es clave antes de cambiar de escena
	get_tree().paused = false 
	get_tree().change_scene_to_file("res://tienda.tscn")
