---
name: sdd-status
description: Muestra el estado del proceso SDD — features registrados, su fase actual y el proximo paso recomendado. Solo lectura. Invocar con /sdd-status [slug].
disable-model-invocation: true
argument-hint: "[slug]"
allowed-tools: Bash, Read
shell: bash
---

# /sdd-status — Estado del proceso SDD

## Estado (inyectado)
```!
if [ ! -f openspec/config.yaml ]; then echo "SIN_INIT"; fi
echo "== registry =="
cat openspec/registry.md 2>/dev/null || echo "(sin registry)"
echo "== states =="
for d in openspec/changes/*/; do
  echo "-- ${d}"
  cat "${d}state.json" 2>/dev/null || echo "(sin state.json)"
done
```

## Tu tarea

- Si aparece `SIN_INIT`: informá que el proyecto no está inicializado. STATUS: blocked, NEXT: `/sdd-init`. Terminá.
- El argumento (si vino) es **$ARGUMENTS**. Si hay un slug, reportá solo ese feature; si no, reportá todos.
- Para cada feature mostrá: slug, título, fase actual (`phase`), y el próximo comando según el DAG:
  proposal -> `/sdd-spec`, spec -> `/sdd-design`, design -> `/sdd-tasks`, tasks -> `/sdd-apply`, apply -> `/sdd-verify`, verify -> `/sdd-review`, review -> `/sdd-archive`.
- Si no hay features, decilo y sugerí `/sdd-propose <slug>`.
- Cerrá con el **Result Contract** (STATUS/RESUMEN/ARTIFACTS/NEXT/RIESGO). En ARTIFACTS poné "ninguno (solo lectura)".
