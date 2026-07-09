---
name: sdd-design
description: Fase Design del flujo SDD. Redacta el diseno tecnico (enfoque, componentes, decisiones y trade-offs, contratos, impacto) de un feature y guarda las decisiones clave en engram. Requiere proposal + spec. Invocar con /sdd-design <slug>.
disable-model-invocation: true
argument-hint: "<slug>"
allowed-tools: Bash, Read, Write, Edit, mcp__plugin_engram_engram__mem_save
shell: bash
---

# /sdd-design — Fase Design

## Estado del Artifact Store (inyectado)
```!
if [ -f openspec/config.yaml ]; then echo "CONFIG_OK"; else echo "CONFIG_FALTA"; fi
echo "== engram_project =="
grep "engram_project" openspec/config.yaml 2>/dev/null || true
echo "== estados actuales =="
for d in openspec/changes/*/; do
  echo "-- ${d}"
  cat "${d}state.json" 2>/dev/null || echo "(sin state.json)"
done
```

## Plantilla de diseno (inyectada)
```!
cat ~/.claude/sdd/templates/design.md 2>/dev/null || echo "(plantilla no encontrada)"
```

## Tu tarea

El feature solicitado es **$ARGUMENTS**.

**Guard (control de dependencia) — primero:**
- Si el estado dice `CONFIG_FALTA` -> STATUS: blocked, correr `/sdd-init`. Terminá.
- Buscá el estado de `$ARGUMENTS` en lo inyectado. Si falta `proposal: true` -> blocked, correr `/sdd-propose $ARGUMENTS`. Si falta `spec: true` -> blocked, correr `/sdd-spec $ARGUMENTS` primero. Terminá indicando cuál falta.
- Si ya tiene `design: true` -> avisá que el diseño ya existe; ofrecé revisarlo o avanzar con `/sdd-tasks $ARGUMENTS`. No sobreescribas sin confirmar.

**Si el guard pasa:**
1. Leé con la tool Read: `openspec/changes/$ARGUMENTS/proposal.md` y `openspec/changes/$ARGUMENTS/spec.md`.
2. Redactá el diseño técnico usando la **plantilla inyectada**: enfoque, componentes afectados (archivos/módulos concretos), decisiones y trade-offs, contratos/interfaces, e impacto (migraciones, compatibilidad, riesgos).
3. Escribí `openspec/changes/$ARGUMENTS/design.md`.
4. Actualizá `openspec/changes/$ARGUMENTS/state.json`: `phase: "design"` y `artifacts.design: true` (mantené los demás).
5. Actualizá `openspec/registry.md`: Fase actual=design, Próximo=/sdd-tasks.
6. **(OPCIONAL — solo si engram está instalado; si no, omití este paso.)** Guardá en engram las **decisiones técnicas clave** con `mem_save`: title tipo "Diseño <slug>: <decisión principal>", type "decision", content con las 2-4 decisiones más importantes del diseño (decisión → por qué → alternativa descartada). Esto deja el "por qué" consultable en futuras sesiones. La memoria se asocia sola al proyecto engram de esta carpeta.
7. Cerrá con el **Result Contract**:
   ```
   STATUS: ok
   RESUMEN: Diseño de "$ARGUMENTS" redactado.
   ARTIFACTS: openspec/changes/$ARGUMENTS/design.md, state.json, registry.md + memoria engram
   NEXT: /sdd-tasks $ARGUMENTS
   RIESGO: <o "ninguno">
   ```
