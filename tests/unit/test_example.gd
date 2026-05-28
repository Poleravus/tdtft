extends GutTest
## Test de ejemplo / plantilla. Sirve para validar que GUT corre en CI.
## Copiá este patrón para tus tests reales (nombre del archivo: test_*.gd).

func test_sanity() -> void:
	assert_eq(1 + 1, 2, "la aritmética básica debería funcionar")
