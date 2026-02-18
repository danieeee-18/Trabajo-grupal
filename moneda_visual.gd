extends Node2D

func volar_a_la_ui(posicion_destino: Vector2):
	var tween = create_tween()
	
	# --- PASO 1: SALTO Y CRECIMIENTO ---
	# Hacemos que la moneda salte y crezca de 0.5 a 0.8
	var salto = position + Vector2(randf_range(-20, 20), -50)
	
	tween.tween_property(self, "position", salto, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# Animamos la escala de 0.5 a 0.8 en paralelo al salto
	tween.parallel().tween_property(self, "scale", Vector2(0.8, 0.8), 0.2)
	
	# --- PASO 2: VUELO A LA UI ---
	# Vuela hacia el contador y vuelve a su tamaño de 0.5 (o un poco menos para efecto de distancia)
	tween.tween_property(self, "global_position", posicion_destino, 0.5).set_delay(0.1).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "scale", Vector2(0.4, 0.4), 0.5)
	
	# --- PASO 3: FINALIZACIÓN ---
	tween.tween_callback(queue_free)
