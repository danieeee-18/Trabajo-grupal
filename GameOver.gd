extends CanvasLayer

# --- REFERENCIAS ---
# Asegúrate de que los nombres en la escena coinciden con estos:
@onready var label_puntos = $Panel/VBoxContainer/LabelPuntos
@onready var boton_reiniciar = $Panel/VBoxContainer/BotonReiniciar
@onready var boton_menu = $Panel/VBoxContainer/BotonMenu  # <--- NUEVO

# Variable para guardar los puntos antes de mostrar el cartel
var puntuacion_final = 0

func _ready():
	# 1. Conectamos el botón de REINTENTAR
	if boton_reiniciar:
		boton_reiniciar.pressed.connect(_on_boton_reiniciar_pressed)
	
	# 2. Conectamos el botón de MENÚ (NUEVO)
	if boton_menu:
		boton_menu.pressed.connect(_on_boton_menu_pressed)
	
	# 3. Actualizamos el texto por si ya teníamos puntos
	actualizar_texto_puntos()

func set_score(puntos):
	puntuacion_final = puntos
	actualizar_texto_puntos()

func actualizar_texto_puntos():
	if label_puntos:
		label_puntos.text = "Score: " + str(puntuacion_final)

# --- FUNCIONES DE LOS BOTONES ---

func _on_boton_reiniciar_pressed():
	# Reinicia la partida actual
	get_tree().reload_current_scene()

func _on_boton_menu_pressed():
	# Vuelve al menú principal (Asegúrate que el nombre del archivo es correcto)
	get_tree().change_scene_to_file("res://MenuPrincipal.tscn")
