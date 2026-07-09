---
name: sdd-tasks
description: Fase Tasks del flujo SDD. Divide el diseno en tareas atomicas y estima el Review Workload (tamano de diff, areas, si conviene partir). Requiere spec + design. Invocar con /sdd-tasks <slug>.
disable-model-invocation: true
argument-hint: "<slug>"
allowed-tools: Bash, Read, Write, Edit
shell: bash
---

# /sdd-tasks — Fase Tasks

## Estado del Artifact Store (inyectado)
```!
if [ -f openspec/config.yaml ]; then echo "CONFIG_OK"; else echo "CONFIG_FALTA"; fi
echo "== config (max_pr_lines) =="
grep -A2 "delivery:" openspec/config.yaml 2>/dev/null || true
echo "== estados actuales =="
for d in openspec/changes/*/; do
  echo "-- ${d}"
  cat "${d}state.json" 2>/dev/null || echo "(sin state.json)"
done
```

## Plantilla de tareas (inyectada)
```!
cat ~/.claude/sdd/templates/tasks.md 2>/dev/null || echo "(plantilla no encontrada)"
```

## Tu tarea

El feature solicitado es **$ARGUMENTS**.

**Guard (control de dependencia) — primero:**
- Si el estado dice `CONFIG_FALTA` -> STATUS: blocked, correr `/sdd-init`. Terminá.
- Buscá el estado de `$ARGUMENTS`. Si falta `spec: true` -> blocked, correr `/sdd-spec $ARGUMENTS`. Si falta `design: true` -> blocked, correr `/sdd-design $ARGUMENTS` primero. Terminá indicando cuál falta.
- Si ya tiene `tasks: true` -> avisá que las tareas ya existen; ofrecé revisarlas o avanzar con `/sdd-apply $ARGUMENTS`. No sobreescribas sin confirmar.

**Si el guard pasa:**
1. Leé con la tool Read: `openspec/changes/$ARGUMENTS/spec.md` y `openspec/changes/$ARGUMENTS/design.md`.
2. Completá el **Review Workload** de la plantilla: estimá líneas del diff, listá las áreas/archivos que se tocan, y recomendá la estrategia de entrega comparando contra `max_pr_lines` de la config (PR único si queda por debajo; dividir en N o encadenar si lo supera).
3. Dividí el diseño en **tareas atómicas y verificables** (cada una debería poder implementarse y testearse por separado). Ordenalas.
4. Escribí `openspec/changes/$ARGUMENTS/tasks.md` con el Review Workload + la lista de tareas + el orden sugerido.
5. Actualizá `openspec/changes/$ARGUMENTS/state.json`: `phase: "tasks"` y `artifacts.tasks: true` (mantené los demás).
6. Actualizá `openspec/registry.md`: Fase actual=tasks, Próximo=/sdd-apply.
7. Cerrá con el **Result Contract**:
   ```
   STATUS: ok
   RESUMEN: Tareas de "$ARGUMENTS" definidas (<N> tareas). Review Workload: <resumen 1 linea>.
   ARTIFACTS: openspec/changes/$ARGUMENTS/tasks.md, state.json, registry.md
   NEXT: /sdd-apply $ARGUMENTS
   RIESGO: <o riesgo de revision si el diff es grande>
   ```
