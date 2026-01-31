extends Control

# REFERENCIAS A LOS NODOS
@onready var check_sonido = get_node_or_null("CenterContainer/PanelContainer/VBoxContainer/CheckButtonSonido")
@onready var check_musica = get_node_or_null("CenterContainer/PanelContainer/VBoxContainer/CheckButtonMusica")
@onready var check_vibra = get_node_or_null("CenterContainer/PanelContainer/VBoxContainer/CheckButtonVibra")
@onready var boton_volver = get_node_or_null("CenterContainer/PanelContainer/VBoxContainer/BotonVolver")
@onready var boton_reset = get_node_or_null("CenterContainer/PanelContainer/VBoxContainer/BotonReset")
@onready var boton_eliminar = get_node_or_null("CenterContainer/PanelContainer/VBoxContainer/BotonEliminar")

func _ready():
	# 1. Sincronizar estados
	if check_sonido:
		check_sonido.button_pressed = Global.sonido_activado
		check_musica.button_pressed = Global.musica_activada
		check_vibra.button_pressed = Global.vibracion_activada

	# 2. Conexión manual y segura del botón Volver
	if boton_volver:
		# Si ya estaba conectado, lo soltamos para evitar errores
		if boton_volver.pressed.is_connected(_on_volver_pressed):
			boton_volver.pressed.disconnect(_on_volver_pressed)
		# Conectamos de cero
		boton_volver.pressed.connect(_on_volver_pressed)
# --- FUNCIONES DE LÓGICA ---

func _on_volver_pressed():
	print("--- EL BOTÓN HA SIDO PULSADO ---")
	get_tree().change_scene_to_file("res://MenuPrincipal.tscn")

func _on_reset_record_pressed():
	Global.high_score = 0
	print("Récord reseteado")

func _on_eliminar_cuenta_pressed():
	Global.high_score = 0
	Global.sonido_activado = true
	Global.musica_activada = true
	Global.vibracion_activada = true
	get_tree().reload_current_scene()
	print("Cuenta eliminada/Reset total")

func _on_sonido_toggled(toggled_on):
	Global.sonido_activado = toggled_on

func _on_musica_toggled(toggled_on):
	Global.musica_activada = toggled_on

func _on_vibra_toggled(toggled_on):
	Global.vibracion_activada = toggled_on

# --- FUNCIONES DE ANIMACIÓN ---

func _on_elemento_mouse_entered(elemento: Control):
	# Forzamos el pivote por si el tamaño cambió
	elemento.pivot_offset = elemento.size / 2
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# Escalamos a 1.08 para que el efecto "levante" sea bien visible
	tween.tween_property(elemento, "scale", Vector2(1.08, 1.08), 0.2)

func _on_elemento_mouse_exited(elemento: Control):
	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(elemento, "scale", Vector2(1.0, 1.0), 0.2)
