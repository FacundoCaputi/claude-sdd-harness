# Evidencia de verificación — Utilidad de saludo (demo)

> Feature: `demo` · Fase: verify · Requiere: apply

## Comandos ejecutados
- `node --test` (desde la raíz del proyecto) → **7 pass / 0 fail** (1 suite `sum` preexistente + 6 casos `greet`).
- `typecheck` → N/A (`typecheck_command: "none"`).
- `lint` → N/A (`lint_command: "none"`).

## Resultado de tests
- **7 pasan / 0 fallan** (cancelled: 0, skipped: 0, todo: 0). Duración total ~108 ms.

Salida real de `node --test`:
```
TAP version 13
# Subtest: sum suma dos numeros
ok 1 - sum suma dos numeros
# Subtest: CA2 — greet("Ana") devuelve el saludo base
ok 2 - CA2 — greet("Ana") devuelve el saludo base
# Subtest: CA3 — greeting custom via options
ok 3 - CA3 — greeting custom via options
# Subtest: CA4 — name ausente/vacío/blanco cae en "mundo"
ok 4 - CA4 — name ausente/vacío/blanco cae en "mundo"
# Subtest: CA5 — trim del name
ok 5 - CA5 — trim del name
# Subtest: CA6 — trim del greeting
ok 6 - CA6 — trim del greeting
# Subtest: CA7 — determinismo: misma entrada, misma salida
ok 7 - CA7 — determinismo: misma entrada, misma salida
1..7
# tests 7
# suites 0
# pass 7
# fail 0
# cancelled 0
# skipped 0
# todo 0
# duration_ms 108.5633
```

## Evidencia contra cada criterio de aceptación
- **CA1 — `node --test` pasa en verde** → ✅ 7 pass / 0 fail (ver salida arriba).
- **CA2 — `greet("Ana")` === `"Hola, Ana!"`** → ✅ `ok 2` (`test/greet.test.js`, "CA2 — greet(\"Ana\") devuelve el saludo base").
- **CA3 — `greet("Ana", { greeting: "Buenas" })` === `"Buenas, Ana!"`** → ✅ `ok 3` ("CA3 — greeting custom via options").
- **CA4 — `greet("")`, `greet("   ")`, `greet(undefined)`, `greet(null)` === `"Hola, mundo!"`** → ✅ `ok 4` (4 aserciones en "CA4 — name ausente/vacío/blanco cae en 'mundo'").
- **CA5 — `greet("  Ana  ")` === `"Hola, Ana!"` (trim)** → ✅ `ok 5` ("CA5 — trim del name").
- **CA6 — `greet("mundo", { greeting: "  Buenas  " })` === `"Buenas, mundo!"` (trim del saludo)** → ✅ `ok 6` ("CA6 — trim del greeting").
- **CA7 — determinismo (misma entrada → misma salida)** → ✅ `ok 7` ("CA7 — determinismo: misma entrada, misma salida").

## Evidencia TDD (si el proyecto lo declara)
- El proyecto no declara TDD obligatorio en su config (solo `test_command: "node --test"`). No se registró fase roja→verde formal; el código y los tests se escribieron en la fase apply y la suite quedó en verde en el primer sanity check.

## Archivos tocados fuera de alcance
- Ninguno. Cambios acotados a lo previsto en tasks/design: `src/greet.js` (nuevo), `test/greet.test.js` (nuevo). `package.json` no requirió edición (ya tenía `"test": "node --test"` y sin `type` → CommonJS). Artifacts SDD actualizados: `state.json`, `registry.md`, este `evidence.md`.

## Riesgos pendientes
- Ninguno. Función pura y determinista, sin dependencias externas ni I/O; cambio muy por debajo de `max_pr_lines: 400`.
