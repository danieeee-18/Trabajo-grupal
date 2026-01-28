extends CanvasLayer

# --- REFERENCIAS ---
@onready var panel = $Panel # <--- Nueva referencia para poder animar la tarjeta
@onready var label_puntos = $Panel/VBoxContainer/LabelPuntos
@onready var boton_reiniciar = $Panel/VBoxContainer/BotonReiniciar
@onready var boton_menu = $Panel/VBoxContainer/BotonMenu

# Variable para guardar los puntos
var puntuacion_final = 0

func _ready():
	# 1. Conexiones de botones
	if boton_reiniciar:
		boton_reiniciar.pressed.connect(_on_boton_reiniciar_pressed)
	if boton_menu:
		boton_menu.pressed.connect(_on_boton_menu_pressed)
	
	# 2. Actualizar texto
	actualizar_texto_puntos()

	# --- 3. ANIMACIÓN DE ENTRADA (NUEVO) ---
	# Preparamos el panel para que crezca desde el centro
	panel.pivot_offset = panel.size / 2
	
	# Lo hacemos invisible (diminuto) al principio
	panel.scale = Vector2.ZERO 
	
	# Creamos la animación (Tween)
	var tween = create_tween()
	
	# Hacemos que escale de 0 a 1 con efecto rebote (TRANS_BACK)
	# El 0.4 es la velocidad (segundos). Cuanto menor, más rápido.
	tween.tween_property(panel, "scale", Vector2.ONE, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func set_score(puntos):
	puntuacion_final = puntos
	actualizar_texto_puntos()

func actualizar_texto_puntos():
	if label_puntos:
		label_puntos.text = "Score: " + str(puntuacion_final)

# --- FUNCIONES DE LOS BOTONES ---

func _on_boton_reiniciar_pressed():
	get_tree().reload_current_scene()

func _on_boton_menu_pressed():
	get_tree().change_scene_to_file("res://MenuPrincipal.tscn")
