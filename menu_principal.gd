extends Control

# Aquí referenciamos los nodos (Asegúrate de que tus nodos se llaman así en la escena)
@onready var label_record = $LabelRecord  # O como se llame tu Label del récord
@onready var boton_jugar = $BotonJugar
# @onready var BotonOpciones = $BotonOpciones

func _ready():
	# Actualizamos el récord si el nodo existe
	if has_node("LabelRecord"):
		# He quitado los dos puntos (:). Ahora solo hay un espacio después de la corona.
		$LabelRecord.text = "👑 " + str(Global.high_score)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://MainGame.tscn")

func _on_options_pressed() -> void:
	# Esta es la línea que arregla tu duda:
	get_tree().change_scene_to_file("res://Options.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()


func _on_boton_jugar_pressed() -> void:
	pass # Replace with function body.
