extends CanvasLayer

var fondo_negro : ColorRect

func _ready():
	# 1. Configuramos la capa para que esté por encima de absolutamente todo
	layer = 100 
	
	# 2. Fabricamos el fondo negro por código
	fondo_negro = ColorRect.new()
	fondo_negro.set_anchors_preset(Control.PRESET_FULL_RECT)
	fondo_negro.color = Color(0, 0, 0, 0) # Empieza totalmente transparente (alfa 0)
	fondo_negro.mouse_filter = Control.MOUSE_FILTER_IGNORE # Deja pasar los clics
	
	add_child(fondo_negro)

func cambiar_escena(ruta_nueva_escena: String):
	# 1. Activamos el "escudo" para que el jugador no pueda hacer clics locos mientras carga
	fondo_negro.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 2. Fundido a negro (0.4 segundos)
	var tween_ida = create_tween()
	tween_ida.tween_property(fondo_negro, "color:a", 1.0, 0.4).set_trans(Tween.TRANS_SINE)
	await tween_ida.finished
	
	# 3. Cambiamos la escena de verdad
	get_tree().change_scene_to_file(ruta_nueva_escena)
	
	# 4. Fundido de vuelta a transparente (0.4 segundos)
	var tween_vuelta = create_tween()
	tween_vuelta.tween_property(fondo_negro, "color:a", 0.0, 0.4).set_trans(Tween.TRANS_SINE)
	await tween_vuelta.finished
	
	# 5. Quitamos el escudo protector
	fondo_negro.mouse_filter = Control.MOUSE_FILTER_IGNORE
