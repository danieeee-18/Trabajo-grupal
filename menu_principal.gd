extends Control

# Aquí referenciamos los nodos (Asegúrate de que tus nodos se llaman así en la escena)
@onready var label_record = $LabelRecord  # O como se llame tu Label del récord
@onready var boton_jugar = $BotonJugar
# @onready var BotonOpciones = $BotonOpciones

func _ready():
	# 1. Cargar el Récord
	# (Si te da error aquí, revisa que tu Label del récord se llame igual que arriba)
	if label_record:
		label_record.text = "👑: " + str(Global.high_score)
	
	# 2. Conectar los botones
	boton_jugar.pressed.connect(_on_jugar_pressed)
	#BotonOpciones.pressed.connect(_on_opciones_pressed)

func _on_jugar_pressed():
	# Cambia a la pantalla de juego
	get_tree().change_scene_to_file("res://MainGame.tscn")

func _on_opciones_pressed():
	# Cambia a la pantalla de opciones
	get_tree().change_scene_to_file("res://Options.tscn")
