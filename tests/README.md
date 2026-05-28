# tests/

Tests automatizados con [GUT](https://github.com/bitwes/Gut).

- **unit/** — prueban una clase/sistema aislado.
- **integration/** — prueban varios sistemas juntos.

Convención: archivos `test_*.gd`, clases `extends GutTest`. Config en `.gutconfig.json` (raíz).
Los tests corren en CI en cada PR (ver `.github/workflows/tests.yml`).
