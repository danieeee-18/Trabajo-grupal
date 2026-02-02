extends Control

# REFERENCIAS A LOS NODOS
@onready var check_sonido = find_child("CheckButtonSonido")
@onready var check_musica = find_child("CheckButtonMusica")
@onready var check_vibra = find_child("CheckButtonVibra")
@onready var boton_volver = find_child("BotonVolver")
@onready var boton_reset = find_child("BotonReset")
@onready var boton_eliminar = find_child("BotonEliminar")

func _ready():
	print("Script de opciones cargado en: ", name)
	
	# 1. Verificar si los nodos se han encontrado
	if boton_volver == null:
		print("ERROR: No se encuentra 'BotonVolver'. Revisa el nombre en la escena.")
		return

	# 2. Sincronizar estados con Global (Cargamos lo que haya guardado)
	check_sonido.button_pressed = Global.sonido_activado
	check_musica.button_pressed = Global.musica_activada
	check_vibra.button_pressed = Global.vibracion_activada

	# 3. Conexión de botones
	boton_volver.pressed.connect(_on_volver_pressed)
	boton_reset.pressed.connect(_on_reset_record_pressed)
	boton_eliminar.pressed.connect(_on_eliminar_cuenta_pressed)
	
	# Conexión de los interruptores
	check_sonido.toggled.connect(_on_sonido_toggled)
	check_musica.toggled.connect(_on_musica_toggled)
	check_vibra.toggled.connect(_on_vibra_toggled)

# --- FUNCIONES DE LÓGICA ---

func _on_volver_pressed():
	print("Botón Volver detectado. Cambiando de escena...")
	var error = get_tree().change_scene_to_file("res://MenuPrincipal.tscn")
	if error != OK:
		print("Error al cargar la escena del menú. ¿Existe res://MenuPrincipal.tscn?")

func _on_reset_record_pressed():
	Global.high_score = 0
	Global.save_game() # <--- GUARDAMOS EL CAMBIO
	print("Récord reseteado y guardado")

func _on_eliminar_cuenta_pressed():
	# Reseteamos variables
	Global.high_score = 0
	Global.sonido_activado = true
	Global.musica_activada = true
	Global.vibracion_activada = true
	
	Global.save_game() # <--- GUARDAMOS EL RESET TOTAL
	
	# Recargamos para ver los cambios visuales
	get_tree().reload_current_scene()
	print("Cuenta eliminada y guardada.")

# --- INTERRUPTORES (Ahora guardan al instante) ---

func _on_sonido_toggled(toggled_on): 
	Global.sonido_activado = toggled_on
	Global.save_game() 

func _on_musica_toggled(toggled_on): 
	Global.musica_activada = toggled_on
	Global.save_game()

func _on_vibra_toggled(toggled_on): 
	Global.vibracion_activada = toggled_on
	Global.save_game()
