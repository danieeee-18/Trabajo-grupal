extends Control

# REFERENCIAS A LOS NODOS
# El símbolo $ busca el nodo en tu escena.
# Si cambiaste los nombres en el paso anterior, esto funcionará perfecto.
@onready var check_sonido = $VBoxContainer/CheckButtonSonido
@onready var check_musica = $VBoxContainer/CheckButtonMusica
@onready var check_vibra = $VBoxContainer/CheckButtonVibra
@onready var boton_volver = $BotonVolver

func _ready():
	# PARTE 1: Poner los interruptores como deben estar
	# Leemos la memoria GlobalScore para saber si estaban activados o no
	check_sonido.button_pressed = Global.sonido_activado
	check_musica.button_pressed = Global.musica_activada
	check_vibra.button_pressed = Global.vibracion_activada

	# PARTE 2: Conectar las señales
	# Esto le dice al juego: "Cuando alguien pulse esto, ejecuta esa función de abajo"
	boton_volver.pressed.connect(_on_volver_pressed)
	
	# "toggled" significa cuando pasas de ON a OFF o viceversa
	check_sonido.toggled.connect(_on_sonido_toggled)
	check_musica.toggled.connect(_on_musica_toggled)
	check_vibra.toggled.connect(_on_vibra_toggled)

# --- FUNCIONES (Lo que pasa al tocar) ---

func _on_volver_pressed():
	# Vuelve al menú principal
	get_tree().change_scene_to_file("res://MenuPrincipal.tscn")

func _on_sonido_toggled(toggled_on):
	# Guardamos el nuevo estado en la variable global
	Global.sonido_activado = toggled_on
	print("Sonido cambiado a: ", toggled_on)

func _on_musica_toggled(toggled_on):
	Global.musica_activada = toggled_on
	print("Música cambiada a: ", toggled_on)

func _on_vibra_toggled(toggled_on):
	Global.vibracion_activada = toggled_on
	print("Vibración cambiada a: ", toggled_on)
