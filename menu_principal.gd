extends Control

func _ready():
	# Buscamos el nodo llamado "BotonJugar" y le decimos que avise cuando lo pulsen
	# IMPORTANTE: Asegúrate de que tu botón en la lista se llame exactamente: BotonJugar
	$BotonJugar.pressed.connect(_al_pulsar_jugar)

func _al_pulsar_jugar():
	print("¡Cambiando de escena!") # Esto saldrá en la consola abajo para confirmar
	
	# Cambia a la escena del juego. 
	# Verifica que "res://MainGame.tscn" sea el nombre EXACTO de tu archivo de juego.
	get_tree().change_scene_to_file("res://MainGame.tscn")
