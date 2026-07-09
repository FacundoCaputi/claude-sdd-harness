# SDD Harness para Claude Code

**Spec-driven development nativo en [Claude Code](https://claude.com/claude-code).** Un flujo por fases con *guardrails*: cada fase se niega a correr si falta el artifact de la anterior. Sin plugins ni servicios externos — solo *skills* (comandos `/sdd-*`) y archivos versionados en tu repo.

> El objetivo: que trabajar con un agente de IA se parezca menos a *"vibe coding"* y más a un proceso de ingeniería — con propuesta, spec, diseño, tareas, implementación y **evidencia real de tests** antes de cerrar.

> 🙏 **Basado en el trabajo de [Alan Buscaglia — Gentleman Programming](https://www.youtube.com/@gentlemanprogramming).** Este harness es una **reimplementación mínima, hecha a mano**, del núcleo del flujo SDD que Alan desarrolla en su ecosistema **[gentle-ai / gentle-pi](https://github.com/Gentleman-Programming/gentle-pi)** — pero portada de forma nativa a Claude Code (solo *skills* + archivos, cero dependencias). No es el ecosistema completo: para la versión con todo, mirá **[gentle-pi](https://github.com/Gentleman-Programming/gentle-pi)**.

---

## ¿Por qué?

Cuando le pedís a un agente que "implemente una feature", suele saltar directo a escribir código: sin acordar el problema, sin criterios de aceptación, sin plan de review. El resultado es difícil de revisar y de confiar.

Este harness impone una **máquina de estados**. Cada feature avanza por fases y **el estado vive en el repo** (`openspec/`), no en el chat. Un *guard* en cada comando corta si el artifact previo no existe, así que no se puede "saltar la spec" ni "mergear sin verificar".

## El flujo

```
   /sdd-init  (una vez por proyecto)
        │
        ▼
 propose → spec → design → tasks → apply → verify → review → archive
 propuesta  qué    cómo    plan   código  tests   review   cierre
                                                  (contexto
                                                   fresco)
```

Cada paso escribe un artifact (`proposal.md`, `spec.md`, `design.md`, `tasks.md`, `evidence.md`, `review.md`) y actualiza `state.json` — la fuente de verdad del DAG. El comando de la fase siguiente lee ese estado y **se bloquea si falta el anterior**.

## Los comandos

| Comando | Cuándo | Qué hace | Requiere |
|---------|--------|----------|----------|
| `/sdd-init` | 1 vez por proyecto | Detecta stack + test command, crea `openspec/`, calibra `CLAUDE.md` | — |
| `/sdd-status [slug]` | cuando quieras | Muestra en qué fase está cada feature | — |
| `/sdd-help [pregunta]` | cuando quieras | Explica el harness (o responde algo puntual) | — |
| `/sdd-propose <slug>` | arrancar un feature | Propuesta: problema, objetivo, alcance, no-goals | init |
| `/sdd-spec <slug>` | definir el **qué** | Requisitos + criterios de aceptación verificables | proposal |
| `/sdd-design <slug>` | definir el **cómo** | Decisiones técnicas, componentes, trade-offs | proposal + spec |
| `/sdd-tasks <slug>` | plan de trabajo | Tareas atómicas + *Review Workload* (tamaño de diff) | spec + design |
| `/sdd-apply <slug>` | implementar | Escribe el código real siguiendo las tareas | tasks |
| `/sdd-verify <slug>` | verificar | Corre los tests y escribe **evidencia real** | apply |
| `/sdd-review <slug>` | revisar | Reviewer de **contexto fresco** sobre el diff; bloquea si hay críticos/mayores | verify |
| `/sdd-archive <slug>` | cerrar | Mueve el feature a `archived/` | review |

**El guard es lo importante:** cada comando (menos `init`/`status`/`help`) corta con `STATUS: blocked` si falta el artifact anterior. Eso garantiza el orden.

## Alcance — qué es y qué no es

**Qué es:** el *core* del flujo SDD, nativo en Claude Code —
- las fases del pipeline con **guardrails** (cada una se bloquea sin la anterior),
- el estado versionado en `openspec/` (fuente de verdad del DAG),
- estimación de *Review Workload* antes de implementar,
- una fase de **review de contexto fresco** que bloquea el cierre si hay bugs críticos/mayores,
- memoria semántica opcional vía engram.

**Qué NO es (todavía):** un clon del ecosistema completo de Alan Buscaglia. Comparado con **[gentle-pi](https://github.com/Gentleman-Programming/gentle-pi)**, a este le falta —
- orquestación de subagentes (parent + workers),
- routing de modelos por fase,
- registry de skills,
- ciclo estricto de TDD (RED → GREEN → REFACTOR con evidencia),
- delta-specs / sync canónico de specs,
- las **4 lentes de review especializadas** (4R) y skills de entrega (PRs, commits, judgment).

Este repo es mi **versión mínima para Claude Code**, hecha a mano para *entender el modelo construyéndolo*. Si querés todo eso resuelto y mantenido, usá el paquete de Alan.

## Instalación

El harness es global: se instala una vez en `~/.claude/` y queda disponible en **todos** tus proyectos.

**Con script:**

```bash
git clone https://github.com/FacundoCaputi/claude-sdd-harness.git
cd claude-sdd-harness
bash install.sh          # macOS / Linux
```

```powershell
git clone https://github.com/FacundoCaputi/claude-sdd-harness.git
cd claude-sdd-harness
./install.ps1            # Windows (PowerShell)
```

**Manual** (si preferís ver qué copia): copiá `skills/` y `sdd/` dentro de tu `~/.claude/`:

```
skills/  →  ~/.claude/skills/
sdd/     →  ~/.claude/sdd/
```

> Los comandos se cargan al **iniciar** una sesión de Claude Code. Después de instalar, abrí una sesión nueva y probá `/sdd-help`.

## Quickstart

```
# en la carpeta de tu proyecto, sesión nueva de Claude Code:
/sdd-init                 # detecta stack, crea openspec/
/sdd-propose login        # arrancás un feature "login"
/sdd-spec login
/sdd-design login
/sdd-tasks login
/sdd-apply login          # escribe el código real
/sdd-verify login         # corre tests + evidencia
/sdd-review login         # reviewer de contexto fresco sobre el diff
/sdd-archive login        # cierra el ciclo
```

En cualquier momento, `/sdd-status` te dice en qué fase está cada feature y cuál es el próximo paso.

## Qué queda en tu repo

```
openspec/
├── config.yaml                     # stack + test/typecheck/lint commands
├── registry.md                     # tabla: feature → fase → próximo paso
└── changes/
    ├── <slug>/                     # feature en curso (proposal, spec, design, tasks, evidence, review, state.json)
    └── archived/<slug>/            # features cerrados
```

Es **reversible**: borrás `openspec/` + el bloque de `CLAUDE.md` y no queda rastro. No toca tu código existente.

## Ejemplo incluido

En [`example/`](example/) está un feature real (`greet`) que recorrió el flujo SDD de punta a punta — con todos sus artifacts y la evidencia de tests. Es el mejor lugar para ver cómo se ve el output del harness.

```bash
cd example
node --test        # los tests del feature de ejemplo pasan en verde
```

## Memoria semántica (opcional — engram)

Si tenés instalado el plugin de memoria **engram**, el harness guarda automáticamente el *"por qué"* de cada feature (decisiones de diseño, resumen al archivar) para consultarlo entre sesiones. **Es 100% opcional**: si engram no está instalado, el harness detecta su ausencia y sigue funcionando igual, solo sin la capa de memoria.

## Inspiración y créditos

Este harness está basado en el que **Alan Buscaglia — [Gentleman Programming](https://www.youtube.com/@gentlemanprogramming)** presentó en uno de sus videos sobre *AI harness*. Lo reimplementé **a mano** y lo adapté a mi flujo de trabajo en Claude Code. La idea de fondo que me quedó: con IA no importa tanto tener el modelo más potente como poder **dirigir** esa fuerza.

El ecosistema completo de Alan (para el agente Pi) vive en **[gentle-pi](https://github.com/Gentleman-Programming/gentle-pi)** · [npm](https://www.npmjs.com/package/gentle-pi) — muy recomendado si querés la versión con orquestación, routing de modelos, TDD estricto y review lenses.

> 📺 Video de referencia: **[El PADRE de todos los CURSOS de IA: 20 Agent Harness para programar con disciplina](https://www.youtube.com/watch?v=5Q7jV8TpMXA)** — Alan Buscaglia (Gentleman Programming)

## Licencia

[MIT](LICENSE) — usalo, forkealo, adaptalo.
