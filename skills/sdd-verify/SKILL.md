---
name: sdd-verify
description: Fase Verify del flujo SDD. Corre los tests del proyecto y escribe evidence.md con evidencia REAL (comandos, resultados, archivos fuera de alcance). Requiere apply. Invocar con /sdd-verify <slug>.
disable-model-invocation: true
argument-hint: "<slug>"
allowed-tools: Bash, Read, Write, Edit
shell: bash
---

# /sdd-verify — Fase Verify (evidencia)

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

## Plantilla de evidencia (inyectada)
```!
cat ~/.claude/sdd/templates/evidence.md 2>/dev/null || echo "(plantilla no encontrada)"
```

## Tu tarea

El feature solicitado es **$ARGUMENTS**.

**Guard (control de dependencia) — primero:**
- Si el estado dice `CONFIG_FALTA` -> STATUS: blocked, correr `/sdd-init`. Terminá.
- Buscá el estado de `$ARGUMENTS`. Si falta `apply: true` -> STATUS: blocked, correr `/sdd-apply $ARGUMENTS` primero. Terminá.

**Si el guard pasa:**
1. Leé con Read: `openspec/changes/$ARGUMENTS/spec.md` (criterios de aceptación) y `tasks.md`.
2. Corré con la tool **Bash** el `test_command` del proyecto (el que aparece arriba, p.ej. `node --test`), desde la raíz del proyecto. Capturá la salida **REAL**. Si `typecheck_command`/`lint_command` no son "none", corrélos también.
3. Escribí `openspec/changes/$ARGUMENTS/evidence.md` usando la plantilla inyectada, con: comandos ejecutados y su resultado **real** (pegá lo que devolvió Bash, NO inventes), evidencia contra cada criterio de aceptación de la spec, archivos tocados fuera de alcance, y riesgos pendientes.
4. **Si TODOS los tests pasan:** actualizá `state.json` (`phase: "verify"`, `artifacts.verify: true`) y `registry.md` (Fase=verify, Próximo=/sdd-review). STATUS: ok.
   **Si algún test falla:** NO marques `verify: true` ni avances la fase. Reportá los fallos honestamente. STATUS: blocked, NEXT: volver a `/sdd-apply $ARGUMENTS` para corregir.
5. Cerrá con el **Result Contract**:
   ```
   STATUS: ok | blocked
   RESUMEN: Tests: <X pasan / Y fallan>.
   ARTIFACTS: openspec/changes/$ARGUMENTS/evidence.md (+ state.json, registry.md si pasó)
   NEXT: /sdd-review $ARGUMENTS   (o /sdd-apply $ARGUMENTS si falló)
   RIESGO: <o "ninguno">
   ```
