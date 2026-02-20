# res://src/autoload/GameEvents.gd
extends Node

# Emitido cuando el jugador gana puntos
signal score_updated(total_score: int)

# Emitido cuando se hace un combo (ej: limpiar 2 líneas a la vez)
signal combo_detected(multiplier: int)

# Emitido cuando una pieza es colocada con éxito
signal piece_placed(color: Color)

# Emitido al perder
signal game_over
