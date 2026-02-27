extends Node

# Cargamos la escena de la explosión para tenerla lista
var explosion_escena = preload("res://Explosion.tscn")

func crear_explosion(posicion: Vector2, color_pieza: Color):
	# 1. Creamos una copia de la explosión
	var explosion = explosion_escena.instantiate()
	
	# 2. La añadimos a la escena actual (al MainGame)
	get_tree().current_scene.add_child(explosion)
	
	# 3. La ponemos justo donde soltaste la pieza
	explosion.global_position = posicion
	
	# 4. Le damos el color de la pieza que acabas de colocar
	explosion.color = color_pieza
	
	# 5. ¡BOOM! Hacemos que explote
	explosion.emitting = true
	
	# 6. Limpieza: Esperamos 1.5 segundos y la borramos de la memoria
	await get_tree().create_timer(1.5).timeout
	if is_instance_valid(explosion):
		explosion.queue_free()
