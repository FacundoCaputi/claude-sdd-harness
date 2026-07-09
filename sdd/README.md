# SDD Harness — Guía rápida

Harness de **spec-driven development** nativo en Claude Code.
- **Maquinaria** (los comandos): vive en `~/.claude/` → global, ya instalada, una vez para siempre.
- **Estado** (por proyecto): vive en la carpeta `openspec/` del proyecto → lo crea `/sdd-init`.

## No tenés que memorizar nada
En cualquier sesión de Claude Code tipeá `/` y aparecen todos los `/sdd-*` con su descripción y el argumento que esperan.

**`/sdd-help`** te muestra esta guía completa en cualquier momento. Opcional: `/sdd-help <pregunta>` para algo puntual (ej: `/sdd-help como onboardeo un proyecto viejo`).

## Los 10 comandos

| Comando | Cuándo | Qué hace | Requiere |
|---------|--------|----------|----------|
| `/sdd-init` | 1 vez por proyecto | Crea `openspec/` (config + registry), calibra `CLAUDE.md` | — |
| `/sdd-status [slug]` | cuando quieras | Muestra en qué fase está cada feature | — |
| `/sdd-propose <slug>` | arrancar un feature | Propuesta: problema, objetivo, alcance, no-goals | init |
| `/sdd-spec <slug>` | definir el QUÉ | Requisitos + criterios de aceptación verificables | proposal |
| `/sdd-design <slug>` | definir el CÓMO | Decisiones técnicas, componentes, trade-offs | proposal+spec |
| `/sdd-tasks <slug>` | plan de trabajo | Tareas atómicas + Review Workload (tamaño de diff) | spec+design |
| `/sdd-apply <slug>` | implementar | Escribe el código real siguiendo las tareas | tasks |
| `/sdd-verify <slug>` | verificar | Corre los tests y escribe evidencia real | apply |
| `/sdd-review <slug>` | revisar | Reviewer de contexto fresco sobre el diff; bloquea si hay críticos/mayores | verify |
| `/sdd-archive <slug>` | cerrar | Mueve el feature a `archived/` | review |

**Cada comando (menos init/status) se niega a correr si falta el artifact anterior.** Eso garantiza el orden (el "guard").

## Proyecto nuevo
1. Sesión nueva de Claude Code en la carpeta del proyecto.
2. `/sdd-init` (una vez).
3. Por cada feature: propose → spec → design → tasks → apply → verify → review → archive.

## Proyecto existente (ya corriendo)
No recreás nada. No tocás tu código. Solo:
1. Sesión nueva en el proyecto.
2. `/sdd-init` — detecta tu stack, crea `openspec/` (nuevo, aparte), appendea a tu `CLAUDE.md`.
3. Usás el flujo en los features **nuevos** de acá en adelante. El código viejo queda como está.

Reversible: borrás `openspec/` + el bloque de `CLAUDE.md` y no queda rastro.

## Memoria (engram)
El proyecto engram = la carpeta (git-root, o nombre de carpeta). Automático.
- `/sdd-init` detecta y **confirma** el proyecto engram, lo registra en `openspec/config.yaml` (`engram_project:`), y guarda una memoria inicial.
- `/sdd-design` guarda las decisiones técnicas clave en engram (el "por qué").
- `/sdd-archive` guarda el resumen del feature completado (qué/por qué/cómo + tests).

Así el estado del pipeline vive en `openspec/` (en el repo) y el "por qué" semántico vive en engram (consultable cross-sesión). Proyecto viejo → usa su proyecto engram existente automáticamente (misma carpeta).

## Ubicación de las cosas
- Comandos: `~/.claude/skills/sdd-*/SKILL.md`
- Plantillas de artifacts: `~/.claude/sdd/templates/`
- Estado de un feature: `openspec/changes/<slug>/state.json` (fuente de verdad del DAG)
- Archivados: `openspec/changes/archived/<slug>/`

## Ojo (gotchas)
- Los comandos se cargan al **iniciar** una sesión. Si creás/actualizás un skill, abrí una sesión nueva para verlo (las viejas dan "Unknown command").
- Los `/sdd-*` son comandos de Claude Code (se tipean en el chat), no comandos del sistema operativo.
