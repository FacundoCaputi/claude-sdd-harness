# Tareas — Utilidad de saludo (demo)

> Feature: `demo` · Fase: tasks · Requiere: spec + design

## Review Workload (estimación)
- Líneas estimadas: ~60 (src/greet.js ~15, test/greet.test.js ~40, package.json ~2 de ajuste).
- Áreas tocadas:
  - `package.json` → confirmar `type` (CJS vs. ESM) y script `test`.
  - `src/greet.js` (nuevo) → función `greet` + helper interno `clean`.
  - `test/greet.test.js` (nuevo) → suite `node --test` cubriendo CA1–CA7.
- Recomendación de entrega: **PR único**. ~60 líneas contra `max_pr_lines: 400` — queda holgadamente por debajo; no hay razón para dividir ni encadenar.

## Tareas
- [ ] T1 — Confirmar el `type` de `package.json` (CommonJS vs. ESM) y, si falta, agregar el script `"test": "node --test"`. Resultado esperado: queda definido qué sintaxis de export/import usar en T2/T3.
- [ ] T2 — Implementar `src/greet.js`: helper interno `clean(value, fallback)` (`trim` de strings, fallback si queda vacío) + `greet(name, options)` que componga `"<saludo>, <nombre>!"`, con export acorde al `type` de T1. Cubre RF1–RF5.
- [ ] T3 — Escribir `test/greet.test.js` con `node --test` + `node:assert/strict`, un test por criterio: CA2 (saludo base), CA3 (greeting custom), CA4 (name vacío/blanco/`null`/`undefined` → "mundo"), CA5 (trim de name), CA6 (trim de greeting), CA7 (determinismo).
- [ ] T4 — Correr `node --test` y verificar verde (CA1). Si algún caso falla, corregir T2/T3 hasta que pase.

## Orden sugerido
1. T1 — decidir CJS/ESM antes de escribir código (bloquea la sintaxis de T2 y T3).
2. T2 — implementación.
3. T3 — tests (dependen del export de T2).
4. T4 — correr la suite y cerrar en verde.
