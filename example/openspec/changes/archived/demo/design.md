# Diseño — Utilidad de saludo (demo)

> Feature: `demo` · Fase: design · Requiere: proposal + spec

## Enfoque
Una única función pura en `src/greet.js`. Sin clases, sin estado, sin dependencias.
La lógica es lineal: (1) normalizar el nombre → si tras `trim` queda vacío, usar
`"mundo"`; (2) normalizar el saludo desde `options.greeting` → si tras `trim` queda
vacío, usar `"Hola"`; (3) componer y devolver `` `${saludo}, ${nombre}!` ``. Los tests
viven en `test/greet.test.js` y corren con el runner nativo `node --test`, sin librería
de aserciones extra (`node:assert/strict`).

## Componentes afectados
- `src/greet.js` (nuevo) → define y exporta `greet(name, options)`.
- `test/greet.test.js` (nuevo) → suite de casos que cubre RF1–RF5 y CA1–CA7.
- `package.json` (verificar/ajustar) → confirmar `type` y, opcionalmente, `"test": "node --test"`. El `type` define si el export es CommonJS (`module.exports`) o ESM (`export`).

## Decisiones técnicas y trade-offs
- **Función pura única vs. módulo con helpers** → una sola función; el problema no
  justifica separar `normalizeName`/`normalizeGreeting` en funciones exportadas.
  Alternativa descartada: sobre-modularizar un one-liner.
- **Helper interno de normalización** → una función local `clean(value, fallback)` que
  hace `typeof value === "string" ? value.trim() : ""` y devuelve `fallback` si queda
  vacío. Cubre en un solo lugar los casos `undefined`/`null`/`""`/`"   "` (RF3, RF4,
  edge cases). Alternativa descartada: encadenar `?.` + `||` inline, menos legible y
  repetido para name y greeting.
- **Runner de tests nativo (`node --test`) vs. framework** → nativo, es el
  `test_command` del proyecto y evita dependencias (no-goal explícito). Alternativa
  descartada: Jest/Vitest.
- **Módulo CommonJS vs. ESM** → se sigue el `type` del `package.json` existente para no
  romper el runtime. Si `type` no es `"module"`, se usa `module.exports = { greet }`;
  si es `"module"`, `export function greet`. El test importa de forma coherente.
- **Default por `||` sobre string vacío** → como `""` es falsy, `trimmed || fallback`
  resuelve limpiamente el fallback sin condicionales extra.

## Contratos / interfaces
```
greet(name?: string, options?: { greeting?: string }): string
```
- `name`: nombre a saludar. `undefined`/`null`/`""`/blanco → `"mundo"`.
- `options.greeting`: saludo a usar. Ausente/`""`/blanco → `"Hola"`.
- Retorno: `"<saludo>, <nombre>!"`, con `saludo` y `nombre` ya `trim`-eados.
- Puro y determinista: sin efectos, misma entrada → misma salida.

Ejemplos (contrato observable, atado a CA2–CA6):
- `greet("Ana")` → `"Hola, Ana!"`
- `greet("Ana", { greeting: "Buenas" })` → `"Buenas, Ana!"`
- `greet("")` / `greet(null)` / `greet(undefined)` / `greet("   ")` → `"Hola, mundo!"`
- `greet("  Ana  ")` → `"Hola, Ana!"`
- `greet("mundo", { greeting: "  Buenas  " })` → `"Buenas, mundo!"`

## Impacto
- **Migraciones**: ninguna (no hay estado ni datos).
- **Compatibilidad**: código nuevo, no toca superficie existente; sin riesgo de regresión.
- **Riesgos**: mínimo. El único punto de atención es el `type` del `package.json`
  (CJS vs. ESM) para que export/import coincidan — se verifica en la primera tarea.
- **Tamaño del cambio**: ~2 archivos nuevos (implementación + tests) + ajuste menor de
  `package.json`; muy por debajo de `max_pr_lines: 400`.
