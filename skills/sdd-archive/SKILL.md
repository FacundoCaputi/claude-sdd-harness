---
name: sdd-archive
description: Fase Archive del flujo SDD. Cierra un feature revisado moviendolo a openspec/changes/archived/, guarda un resumen en engram, y lo marca en el registry. Requiere review. Invocar con /sdd-archive <slug>.
disable-model-invocation: true
argument-hint: "<slug>"
allowed-tools: Bash, Read, Write, Edit, mcp__plugin_engram_engram__mem_save
shell: bash
---

# /sdd-archive — Fase Archive (cierre)

## Estado del Artifact Store (inyectado)
```!
if [ -f openspec/config.yaml ]; then echo "CONFIG_OK"; else echo "CONFIG_FALTA"; fi
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
- Buscá el estado de `$ARGUMENTS`. Si falta `verify: true` -> STATUS: blocked, correr `/sdd-verify $ARGUMENTS` primero. Si falta `review: true` -> STATUS: blocked, correr `/sdd-review $ARGUMENTS` primero. Terminá indicando cuál falta.

**Si el guard pasa:**
1. Antes de mover nada, leé `openspec/changes/$ARGUMENTS/proposal.md`, `openspec/changes/$ARGUMENTS/evidence.md` y `openspec/changes/$ARGUMENTS/review.md` para tener el resumen del feature (objetivo, evidencia de tests, veredicto del review) a mano.
2. Con la tool **Bash**, creá la carpeta de archivo si no existe y mové el feature (sustituí `$ARGUMENTS` por el slug real):
   `mkdir -p openspec/changes/archived && mv openspec/changes/$ARGUMENTS openspec/changes/archived/$ARGUMENTS`
3. Actualizá el `state.json` movido (`openspec/changes/archived/$ARGUMENTS/state.json`): `phase: "archived"`.
4. Actualizá `openspec/registry.md`: marcá el feature como **archivado** (Fase actual=archived, Próximo=—).
5. **(OPCIONAL — solo si engram está instalado; si no, omití este paso.)** Guardá en engram el resumen del feature completado con `mem_save`: title tipo "Feature <slug> completado", type "architecture", content con qué se hizo, el objetivo/por qué (de la propuesta), el approach clave (del diseño) y el resultado de verificación (de evidence.md). Es el registro durable del feature, consultable a futuro. Se asocia sola al proyecto engram de esta carpeta.
6. Cerrá con el **Result Contract**:
   ```
   STATUS: ok
   RESUMEN: Feature "$ARGUMENTS" archivado (ciclo SDD completo).
   ARTIFACTS: openspec/changes/archived/$ARGUMENTS/ (movido), registry.md + memoria engram
   NEXT: — (nuevo feature con /sdd-propose <slug>)
   RIESGO: ninguno
   ```
