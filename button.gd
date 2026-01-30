extends Button

func _ready():
	# Configura el texto inicial
	actualizar_boton(button_pressed)

func _toggled(esta_encendido):
	actualizar_boton(esta_encendido)

func actualizar_boton(esta_encendido):
	if esta_encendido:
		text = "ON"
		# Letra Blanca brillante
		add_theme_color_override("font_color", Color(1, 1, 1, 1))
	else:
		text = "OFF"
		# Letra Gris clarito (para que se note apagado)
		add_theme_color_override("font_color", Color(0.9, 0.9, 0.9, 1))
