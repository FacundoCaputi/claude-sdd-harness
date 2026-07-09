# Especificación — Utilidad de saludo (demo)

> Feature: `demo` · Fase: spec · Requiere: proposal

## Comportamiento esperado
El sistema expone una función pura `greet(name, options)` que devuelve un string
de saludo. Dado un nombre, arma un saludo con el patrón `"<saludo>, <nombre>!"`.
El saludo base es `"Hola"` y puede personalizarse vía `options.greeting`. Si no se
pasa un nombre utilizable, se usa el nombre genérico `"mundo"`. La función no tiene
efectos secundarios, no lee estado externo y es determinista: la misma entrada
siempre produce la misma salida.

## Requisitos funcionales
- [ ] RF1 — `greet(name)` devuelve `"Hola, <name>!"` (ej.: `greet("Ana")` → `"Hola, Ana!"`).
- [ ] RF2 — `greet(name, { greeting })` usa el saludo provisto (ej.: `greet("Ana", { greeting: "Buenas" })` → `"Buenas, Ana!"`).
- [ ] RF3 — Si `name` es ausente (`undefined`/`null`), string vacío, o solo espacios en blanco, se usa el nombre genérico `"mundo"` (ej.: `greet("")` → `"Hola, mundo!"`).
- [ ] RF4 — El nombre y el saludo se recortan (`trim`) de espacios sobrantes en los bordes antes de componer el string (ej.: `greet("  Ana  ")` → `"Hola, Ana!"`).
- [ ] RF5 — El módulo `src/greet.js` exporta `greet` como export nombrado (compatible con `require`/`import` según el `type` del `package.json`).

## Requisitos no funcionales
- Función **pura y determinista**: sin I/O, sin estado global, sin `Date`/`Math.random`.
- Sin dependencias externas — solo runtime de Node.
- Cubierta por tests que corren con `node --test` (sin typecheck ni lint).
- Cambio total muy por debajo de `max_pr_lines: 400`.

## Criterios de aceptación
- [ ] CA1 — `node --test` pasa en verde con todos los casos de abajo cubiertos.
- [ ] CA2 — `greet("Ana")` === `"Hola, Ana!"`.
- [ ] CA3 — `greet("Ana", { greeting: "Buenas" })` === `"Buenas, Ana!"`.
- [ ] CA4 — `greet("")`, `greet("   ")`, `greet(undefined)` y `greet(null)` === `"Hola, mundo!"`.
- [ ] CA5 — `greet("  Ana  ")` === `"Hola, Ana!"` (trim aplicado).
- [ ] CA6 — `greet("mundo", { greeting: "  Buenas  " })` === `"Buenas, mundo!"` (trim del saludo).
- [ ] CA7 — Llamar `greet` dos veces con los mismos argumentos devuelve el mismo resultado (determinismo).

## Casos borde
- `name` con solo espacios (`"   "`) → tratado como ausente → `"mundo"`.
- `options` ausente o `undefined` → se usa el saludo base `"Hola"`.
- `options.greeting` vacío o solo espacios → cae al saludo base `"Hola"` (no produce `", Ana!"`).
- Espacios sobrantes en `name` o `greeting` → recortados, no propagados al resultado.
- `name` que ya es `"mundo"` → funciona igual que cualquier otro nombre (sin caso especial).

## Decisiones (preguntas abiertas resueltas)
- **Formato**: sin signo de apertura `¡`; patrón fijo `"<saludo>, <nombre>!"`. No se
  fuerza mayúscula/minúscula: el nombre y el saludo se usan tal como los pasa el caller
  (solo se les aplica `trim`).
- **Nombre por defecto**: `"mundo"` cuando el nombre es ausente/vacío/blanco.
- **Saludo por defecto**: `"Hola"` cuando `options.greeting` es ausente/vacío/blanco.
