# Plan de refactorización segura de EcoPuntos

## Objetivo
Aplicar una limpieza estructural del proyecto sin romper la funcionalidad actual del sistema Django y mantener intacta la lógica de negocio.

## Principio base
No hacer un rewrite completo de una vez. La refactorización debe ser incremental, reversible y validada con pruebas de humo.

## Fase 1: estabilizar el proyecto
- Mantener funcionando `python manage.py check`.
- Separar archivos temporales, logs y scripts de diagnóstico del producto principal.
- No borrar módulos funcionales sin revisar dependencias reales.

## Fase 2: consolidar modelos
- Revisar y decidir qué modelos reales serán la fuente de verdad.
- Resolver la diferencia entre nombres viejos y actuales: `Material` vs `MaterialTasa`, `Reciclaje` vs `Canje`, etc.
- Crear una capa de compatibilidad temporal para endpoints o tests heredados si aún se necesitan.

## Fase 3: reducir ruido en URLs
- Revisar [core/urls.py](../core/urls.py).
- Eliminar rutas duplicadas y agrupar por dominio funcional.
- Mantener aliases solo si hay compatibilidad con clientes antiguos.

## Fase 4: separar responsabilidades
- `views.py` debe quedar más pequeña.
- Mover lógica pesada a servicios y utilidades.
- Dejar endpoints HTTP y lógica de negocio separadas.

## Fase 5: limpiar pruebas
- Mover tests legacy a una carpeta `legacy_tests/` o `archive/tests_legacy/` si ya no corresponden al modelo actual.
- Mantener un conjunto pequeño de pruebas de humo para validar cada flujo principal.

## Fase 6: dejar el proyecto limpio
- Dejar un único estándar de naming y estructura.
- Eliminar scripts de depuración y herramientas de una sola vez.
- Documentar cada módulo y su responsabilidad.

## Reglas para no romper funcionalidad
1. No renombrar modelos sin migración y compatibilidad.
2. No borrar rutas de producción sin identificar su uso real.
3. No mover lógica de negocio a una sola vez.
4. Validar con `manage.py check` y pruebas mínimas después de cada bloque.

## Estado actual verificado
- `python manage.py check` pasa.
- `pytest -q` falla por importaciones de tests legacy obsoletos, no por el backend principal.

## Siguiente acción recomendada
1. Crear una capa de compatibilidad para los nombres legacy usados en tests.
2. Mover tests obsoletos fuera del pipeline principal.
3. Refactorizar `core/views.py` en servicios por dominio.
4. Revisar `core/urls.py` y dejar solo rutas vivas.
