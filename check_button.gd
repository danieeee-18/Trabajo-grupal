extends CheckButton

func _ready():
	# 1. El PIVOTE: Le decimos que crezca desde su propio centro, 
	# para que no se mueva de sitio al crecer.
	pivot_offset = size / 2
	
	# 2. LA ESCALA: Aquí es donde multiplicamos su tamaño.
	# Pon 2.0 para el doble, 3.0 para el triple...
	scale = Vector2(2.5, 2.5)
