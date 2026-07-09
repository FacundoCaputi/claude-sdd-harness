---
name: sdd-propose
description: Fase Proposal del flujo SDD. Redacta la propuesta (problema, objetivo, alcance, no-goals) de un feature. Requiere el proyecto inicializado. Invocar con /sdd-propose <slug>.
disable-model-invocation: true
argument-hint: "<slug>"
allowed-tools: Bash, Read, Write, Edit
shell: bash
---

# /sdd-propose — Fase Proposal

## Estado del Artifact Store (inyectado)
```!
if [ -f openspec/config.yaml ]; then echo "CONFIG_OK"; else echo "CONFIG_FALTA"; fi
echo "== features existentes =="
ls -1 openspec/changes 2>/dev/null || echo "(ninguno)"
echo "== estados actuales =="
for d in openspec/changes/*/; do
  echo "-- ${d}"
  cat "${d}state.json" 2>/dev/null || echo "(sin state.json)"
done
```

## Plantilla de propuesta (inyectada)
```!
cat ~/.claude/sdd/templates/proposal.md 2>/dev/null || echo "(plantilla no encontrada)"
```

## Tu tarea

El feature solicitado es **$ARGUMENTS**.

**Guard (control de dependencia) — hacelo primero:**
- Si el estado inyectado dice `CONFIG_FALTA` -> STATUS: blocked. No escribas nada. Indicá correr `/sdd-init` primero. Terminá.
- Si en los estados ya aparece `openspec/changes/$ARGUMENTS/` con `proposal: true` -> avisá que la propuesta ya existe; ofrecé revisarla o avanzar con `/sdd-spec $ARGUMENTS`. No sobreescribas sin confirmación.

**Si el guard pasa:**
1. Si el usuario no dio contexto suficiente sobre el feature, hacé 1-2 preguntas mínimas; si dio contexto, seguí.
2. Redactá la propuesta usando la **plantilla inyectada arriba**, completando cada sección para `$ARGUMENTS`.
3. Escribí `openspec/changes/$ARGUMENTS/proposal.md` con esa propuesta.
4. Creá/actualizá `openspec/changes/$ARGUMENTS/state.json`:
   ```json
   {
     "slug": "$ARGUMENTS",
     "title": "<titulo del feature>",
     "phase": "proposal",
     "artifacts": { "explore": false, "proposal": true, "spec": false, "design": false, "tasks": false, "apply": false, "verify": false },
     "updated": "<fecha de hoy>"
   }
   ```
5. Actualizá `openspec/registry.md`: agregá o actualizá el renglón del feature (Slug=$ARGUMENTS, Título, Fase actual=proposal, Próximo=/sdd-spec).
6. Cerrá con el **Result Contract**:
   ```
   STATUS: ok
   RESUMEN: Propuesta de "$ARGUMENTS" redactada.
   ARTIFACTS: openspec/changes/$ARGUMENTS/proposal.md, state.json, registry.md
   NEXT: /sdd-spec $ARGUMENTS
   RIESGO: <o "ninguno">
   ```
