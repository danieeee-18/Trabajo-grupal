extends Node

# Esta variable recordará el récord aunque cambies de escena
var high_score = 0

func actualizar_record(puntos_nuevos):
	# Si los puntos nuevos superan al récord...
	if puntos_nuevos > high_score:
		high_score = puntos_nuevos

# Variables de configuración (true = activado)
var sonido_activado = true
var musica_activada = true
var vibracion_activada = true
