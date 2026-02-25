extends Control

# --- REFERENCIAS A LOS NODOS ---
# (Asegúrate de que los nombres coinciden con tu escena)
@onready var label_record = $LabelRecord 
@onready var boton_jugar = $BotonJugar
# @onready var BotonOpciones = $BotonOpciones

# NUEVO: Referencia al texto de las monedas
# (Asegúrate de que la ruta coincida con cómo lo llamaste en el panel de nodos)
@onready var label_monedas = $ContenedorMonedas/LabelMonedas

func _ready():
	# 0. CARGAMOS LA PARTIDA (Para asegurar que tenemos las monedas y récord al día)
	if Global.has_method("load_game"):
		Global.load_game()

	# 1. ACTUALIZAR RÉCORD
	# Verificamos si existe el nodo para evitar errores rojos
	if has_node("LabelRecord"):
		# Mostramos la corona y el número guardado en Global
		$LabelRecord.text = "👑 " + str(Global.high_score)
		
	# 1.5 ACTUALIZAR MONEDAS (NUEVO)
	actualizar_monedas_ui()
		
	# 2. MÚSICA
	# Le decimos al DJ que ponga el disco de Menú Principal
	if has_node("/root/AudioManager"):
		AudioManager.poner_musica_menu()

# --- FUNCIONES DE LA INTERFAZ ---
func actualizar_monedas_ui():
	# Si hemos encontrado el nodo, le ponemos la cantidad de monedas
	if label_monedas:
		label_monedas.text = str(Global.monedas)

# --- FUNCIONES DE LOS BOTONES ---

# Botón Jugar (Play)
func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://MainGame.tscn")

# Botón Opciones
func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Options.tscn")

# Botón Salir
func _on_exit_pressed() -> void:
	get_tree().quit()

# Botón Tienda (NUEVO)
func _on_boton_tienda_pressed():
	get_tree().change_scene_to_file("res://tienda.tscn")

# --- FUNCIONES EXTRA (Por si tienes señales antiguas conectadas) ---
func _on_boton_jugar_pressed() -> void:
	# Si tienes un botón conectado aquí, redirigimos al juego también
	_on_play_pressed()
