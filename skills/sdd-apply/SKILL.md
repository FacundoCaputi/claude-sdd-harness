---
name: sdd-apply
description: Fase Apply del flujo SDD. Implementa el codigo real siguiendo las tareas definidas, marcando progreso con TodoWrite. Requiere tasks. Invocar con /sdd-apply <slug>.
disable-model-invocation: true
argument-hint: "<slug>"
allowed-tools: Bash, Read, Write, Edit, Glob, Grep, TodoWrite
shell: bash
---

# /sdd-apply — Fase Apply (implementacion)

## Estado del Artifact Store (inyectado)
```!
if [ -f openspec/config.yaml ]; then echo "CONFIG_OK"; else echo "CONFIG_FALTA"; fi
echo "== comandos del proyecto =="
grep -E "test_command|typecheck_command|lint_command" openspec/config.yaml 2>/dev/null || true
echo "== estados actuales =="
for d in openspec/changes/*/; do
  echo "-- ${d}"
  cat "${d}state.json" 2>/dev/null || echo "(sin state.json)"
done
```

## Tu tarea

El feature solicitado es **$ARGUMENTS**.

**Guard (control de dependencia) — primero:**
- Si el estado dice `CONFIG_FALTA` -> STATUS: blocked, correr `/sdd-init`. Terminá.
- Buscá el estado de `$ARGUMENTS`. Si falta `tasks: true` -> STATUS: blocked, indicá qué fase falta y correr `/sdd-tasks $ARGUMENTS` (o la que corresponda). Terminá.
- Si ya tiene `apply: true` -> avisá que ya está implementado; ofrecé `/sdd-verify $ARGUMENTS`. No re-implementes sin confirmar.

**Si el guard pasa:**
1. Leé con Read: `openspec/changes/$ARGUMENTS/tasks.md`, `spec.md` y `design.md`.
2. Cargá las tareas de `tasks.md` en **TodoWrite** (una por tarea) para trackear el progreso.
3. Implementá cada tarea en orden: escribí/editá los **archivos de código reales** que indica el diseño (Write/Edit), respetando las convenciones del proyecto. Marcá cada todo como completado a medida que avanzás.
4. Hacé un chequeo rápido de sanidad (que el código cargue/compile). NO es la verificación formal — eso es `/sdd-verify`.
5. Actualizá `openspec/changes/$ARGUMENTS/state.json`: `phase: "apply"`, `artifacts.apply: true` (mantené los demás flags).
6. Actualizá `openspec/registry.md`: Fase actual=apply, Próximo=/sdd-verify.
7. Cerrá con el **Result Contract**:
   ```
   STATUS: ok | blocked
   RESUMEN: <qué se implementó>
   ARTIFACTS: <archivos de código creados/editados>, state.json, registry.md
   NEXT: /sdd-verify $ARGUMENTS
   RIESGO: <o "ninguno">
   ```
