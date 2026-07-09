---
name: sdd-spec
description: Fase Spec del flujo SDD. Redacta la especificacion (comportamiento esperado, requisitos, criterios de aceptacion, casos borde) de un feature. Requiere la propuesta. Invocar con /sdd-spec <slug>.
disable-model-invocation: true
argument-hint: "<slug>"
allowed-tools: Bash, Read, Write, Edit
shell: bash
---

# /sdd-spec — Fase Spec

## Estado del Artifact Store (inyectado)
```!
if [ -f openspec/config.yaml ]; then echo "CONFIG_OK"; else echo "CONFIG_FALTA"; fi
echo "== estados actuales =="
for d in openspec/changes/*/; do
  echo "-- ${d}"
  cat "${d}state.json" 2>/dev/null || echo "(sin state.json)"
done
```

## Plantilla de spec (inyectada)
```!
cat ~/.claude/sdd/templates/spec.md 2>/dev/null || echo "(plantilla no encontrada)"
```

## Tu tarea

El feature solicitado es **$ARGUMENTS**.

**Guard (control de dependencia) — primero:**
- Si el estado dice `CONFIG_FALTA` -> STATUS: blocked, correr `/sdd-init`. Terminá.
- Buscá el estado de `$ARGUMENTS` en lo inyectado. Si no existe o tiene `proposal: false` (falta la propuesta) -> STATUS: blocked, correr `/sdd-propose $ARGUMENTS` primero. Terminá.
- Si ya tiene `spec: true` -> avisá que la spec ya existe; ofrecé revisarla o avanzar con `/sdd-design $ARGUMENTS`. No sobreescribas sin confirmar.

**Si el guard pasa:**
1. Leé la propuesta con la tool Read: `openspec/changes/$ARGUMENTS/proposal.md`. Basá la spec en ella.
2. Redactá la especificación usando la **plantilla inyectada arriba**: comportamiento esperado, requisitos funcionales y no funcionales, criterios de aceptación **verificables**, y casos borde. Resolvé las preguntas abiertas que dejó la propuesta.
3. Escribí `openspec/changes/$ARGUMENTS/spec.md`.
4. Actualizá `openspec/changes/$ARGUMENTS/state.json`: `phase: "spec"` y `artifacts.spec: true` (mantené los demás flags como estaban).
5. Actualizá `openspec/registry.md`: Fase actual=spec, Próximo=/sdd-design.
6. Cerrá con el **Result Contract**:
   ```
   STATUS: ok
   RESUMEN: Spec de "$ARGUMENTS" redactada.
   ARTIFACTS: openspec/changes/$ARGUMENTS/spec.md, state.json, registry.md
   NEXT: /sdd-design $ARGUMENTS
   RIESGO: <o "ninguno">
   ```
