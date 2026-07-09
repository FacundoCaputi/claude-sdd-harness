# Propuesta — Utilidad de saludo (demo)

> Feature: `demo` · Fase: proposal

## Problema
El proyecto `sdd-lab` es un sandbox para ejercitar el harness SDD de punta a punta, pero todavía no existe ningún feature real que atraviese todas las fases (explore → proposal → spec → design → tasks → apply → verify → archive). Sin un caso concreto y verificable, no se puede validar que el pipeline funcione.

## Objetivo
Entregar un módulo `greet(name, options)` — una función pura, sin dependencias — que sirva como caso de prueba end-to-end del harness, cubierto por tests que corran con `node --test`.

## Alcance (in-scope)
- Módulo `src/greet.js` que exporta `greet(name, options)`.
- Comportamiento base: `greet("Ana")` → `"Hola, Ana!"`.
- Opción `greeting` para personalizar el saludo: `greet("Ana", { greeting: "Buenas" })` → `"Buenas, Ana!"`.
- Manejo de borde: nombre vacío/ausente → saludo genérico (p. ej. `"Hola, mundo!"`).
- Tests con `node --test` cubriendo los casos anteriores.

## Fuera de alcance (no-goals)
- CLI, servidor HTTP o cualquier endpoint.
- Internacionalización / múltiples idiomas más allá de la opción `greeting`.
- Persistencia, base de datos o estado compartido.
- Dependencias externas o framework.

## Contexto y restricciones
- Stack: JavaScript sobre Node, sin framework (según `openspec/config.yaml`).
- `test_command`: `node --test`. Sin typecheck ni lint configurados.
- Debe ser una función pura y determinista para que las fases posteriores (verify) sean triviales de validar.
- `max_pr_lines`: 400 — el cambio debe quedar muy por debajo.

## Riesgos / preguntas abiertas
- **Asunción de alcance**: se interpretó `demo` como un feature de prueba mínimo (función `greet`). Si buscabas ejercitar el harness con otro caso (CLI, endpoint, etc.), avisá antes de `/sdd-spec` para reorientar.
- Formato exacto del saludo (signo de apertura `¡`, mayúsculas) a definir en la fase spec.
- Definir el valor por defecto para nombre vacío (`"mundo"` vs. otro) en spec.
