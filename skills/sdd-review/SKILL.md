---
name: sdd-review
description: Fase Review del flujo SDD. Lanza un reviewer de contexto fresco contra el diff del feature y escribe review.md con hallazgos por severidad. Bloquea el cierre si hay criticos o mayores. Requiere apply + verify. Invocar con /sdd-review <slug>.
disable-model-invocation: true
argument-hint: "<slug>"
allowed-tools: Bash, Read, Write, Edit, Task
shell: bash
---

# /sdd-review — Fase Review (contexto fresco)

## Estado del Artifact Store (inyectado)
```!
if [ -f openspec/config.yaml ]; then echo "CONFIG_OK"; else echo "CONFIG_FALTA"; fi
echo "== estados actuales =="
for d in openspec/changes/*/; do
  echo "-- ${d}"
  cat "${d}state.json" 2>/dev/null || echo "(sin state.json)"
done
echo "== resumen del diff (codigo, excluye openspec/) =="
git diff --stat -- . ':(exclude)openspec' 2>/dev/null || git diff --stat 2>/dev/null || echo "(sin git o sin cambios)"
```

## Plantilla de review (inyectada)
```!
cat ~/.claude/sdd/templates/review.md 2>/dev/null || echo "(plantilla no encontrada)"
```

## Tu tarea

El feature solicitado es **$ARGUMENTS**.

**Guard (control de dependencia) — primero:**
- Si el estado dice `CONFIG_FALTA` -> STATUS: blocked, correr `/sdd-init`. Terminá.
- Buscá el estado de `$ARGUMENTS`. Si falta `apply: true` -> blocked, correr `/sdd-apply $ARGUMENTS`. Si falta `verify: true` -> blocked, correr `/sdd-verify $ARGUMENTS` primero. Terminá indicando cuál falta.
- Si ya tiene `review: true` -> avisá que la revisión ya existe; ofrecé releerla o avanzar con `/sdd-archive $ARGUMENTS`. No sobreescribas sin confirmar.

**Si el guard pasa:**
1. Obtené el diff del feature con **Bash**. Probá en orden y quedate con el primero que traiga cambios de **código** (excluí `openspec/`, que son artifacts del proceso):
   `git diff main...HEAD -- . ':(exclude)openspec'`, luego `git diff HEAD -- . ':(exclude)openspec'`, luego `git diff -- . ':(exclude)openspec'`.
   Si necesitás más contexto, leé con **Read** los archivos tocados.
2. **Revisión con contexto fresco.** Lanzá un subagente reviewer con el **Task tool** (subagent_type `general-purpose`), pasándole el diff completo y la rúbrica de abajo. La clave es *ojos frescos*: el reviewer NO sabe qué intentaba hacer el dev, solo ve el resultado. Si el Task tool no está disponible en este entorno, hacé vos la revisión aplicando la misma rúbrica, deliberadamente crítico.

   **Rúbrica del reviewer (por severidad):**
   - **CRÍTICO (bloquea el cierre):** bugs de lógica (condiciones invertidas, off-by-one, `null`/`undefined` no manejado), problemas de seguridad (inyección, secretos/tokens/credenciales expuestos, datos sensibles filtrados), memory leaks (listeners/subscripciones/timers sin cleanup), race conditions (estado stale en closures, async sin cancelar), pérdida de datos.
   - **MAYOR (debería arreglarse):** manejo de errores faltante (llamadas sin `catch`, errores tragados o no mostrados), valores hardcodeados que deberían ser configurables por entorno, inconsistencias con los patrones del resto del código, complejidad innecesaria o duplicación evidente.
   - **MENOR (mencionar, no bloquea):** nombres poco descriptivos, código que podría extraerse pero funciona, detalles de estilo.

3. Escribí `openspec/changes/$ARGUMENTS/review.md` usando la **plantilla inyectada**: cada hallazgo con severidad + archivo/línea aproximada + qué está mal y cómo arreglarlo, y un **veredicto final**.
4. **Decisión (guard de salida):**
   - **Si hay ≥1 hallazgo CRÍTICO o MAYOR:** NO marques `review: true`; dejá `phase` como está (`verify`). Reportá los hallazgos honestamente. STATUS: blocked, NEXT: `/sdd-apply $ARGUMENTS` para corregir (y luego re-`/sdd-verify`).
   - **Si solo hay MENORES o ninguno:** actualizá `state.json` (`phase: "review"`, `artifacts.review: true`, mantené los demás flags) y `registry.md` (Fase=review, Próximo=/sdd-archive). Mencioná los menores. STATUS: ok.
5. Cerrá con el **Result Contract**:
   ```
   STATUS: ok | blocked
   RESUMEN: Review de "$ARGUMENTS": <N críticos / M mayores / K menores>.
   ARTIFACTS: openspec/changes/$ARGUMENTS/review.md (+ state.json, registry.md si aprobó)
   NEXT: /sdd-archive $ARGUMENTS   (o /sdd-apply $ARGUMENTS si hay que corregir)
   RIESGO: <o "ninguno">
   ```
