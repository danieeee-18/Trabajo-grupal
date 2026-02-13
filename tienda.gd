extends Control

# --- REFERENCIAS ---
# Asegúrate de que el nombre coincida con tu nodo en la escena
@onready var label_monedas = $LabelMonedas 

func _ready():
	# Al abrir la tienda, actualizamos el texto
	actualizar_texto_monedas()

# --- FUNCIÓN PARA ACTUALIZAR LA INTERFAZ ---
func actualizar_texto_monedas():
	if label_monedas:
		# Leemos las monedas guardadas en Global
		label_monedas.text = "MONEDAS: " + str(Global.monedas)
	else:
		print("❌ ERROR: No encuentro el nodo LabelMonedas en la Tienda")

# --- BOTÓN PARA VOLVER (Seguramente lo necesites) ---
func _on_btn_volver_pressed():
	get_tree().change_scene_to_file("res://MenuPrincipal.tscn")
