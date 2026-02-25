extends CanvasLayer

# Esta es la función que llama el main_game.gd para pasarle los puntos
func set_score(puntos_finales):
	var label = find_child("*Score*", true, false)
	if not label:
		label = find_child("*Puntos*", true, false)
		
	if label and label is Label:
		# ¡AQUÍ ESTÁ LA MAGIA! Le pegamos la palabra delante del número
		label.text = "SCORE: " + str(puntos_finales)

# --- BOTONES DE LA PANTALLA DE GAME OVER ---
# Conecta las señales de tus botones en el editor a estas funciones:

func _on_btn_reintentar_pressed():
	# Reinicia la partida
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_btn_menu_pressed():
	# Vuelve al menú principal
	get_tree().paused = false
	get_tree().change_scene_to_file("res://MenuPrincipal.tscn")


func _on_boton_reiniciar_pressed() -> void:
	pass # Replace with function body.


func _on_boton_menu_pressed() -> void:
	pass # Replace with function body.
