---
name: sdd-init
description: Inicializa un proyecto SDD (spec-driven development). Detecta el stack y el comando de test, asocia el proyecto a engram, crea openspec/config.yaml y openspec/registry.md, y agrega el bloque de calibracion SDD a CLAUDE.md. Invocar con /sdd-init.
disable-model-invocation: true
argument-hint: ""
allowed-tools: Bash, Read, Write, Edit, Glob, mcp__plugin_engram_engram__mem_current_project, mcp__plugin_engram_engram__mem_save
shell: bash
---

# /sdd-init — Inicializar proyecto SDD

## Estado del proyecto (inyectado por shell antes de que leas esto)
```!
if [ -f openspec/config.yaml ]; then echo "YA_INICIALIZADO"; else echo "NO_INICIALIZADO"; fi
echo "== package.json (primeras 40 lineas) =="
head -40 package.json 2>/dev/null || echo "(no hay package.json)"
echo "== markers de stack presentes =="
ls -1 package-lock.json yarn.lock pnpm-lock.yaml tsconfig.json requirements.txt pyproject.toml pom.xml build.gradle template.yaml samconfig.toml serverless.yml Cargo.toml go.mod 2>/dev/null || true
echo "== CLAUDE.md =="
if [ -f CLAUDE.md ]; then echo "CLAUDE_MD_OK"; else echo "SIN_CLAUDE_MD"; fi
echo "== nombre de carpeta =="
basename "$PWD"
```

## Tu tarea

Sos el inicializador del harness SDD. Usá SOLO el estado inyectado arriba (no vuelvas a inspeccionar salvo que falte info crítica).

1. **Si el estado dice `YA_INICIALIZADO`**: no sobreescribas nada. Respondé el Result Contract con STATUS: ok, RESUMEN: "El proyecto ya estaba inicializado", NEXT: `/sdd-status`. Terminá.

2. **Si dice `NO_INICIALIZADO`**, detectá del estado inyectado:
   - `language`: typescript si hay tsconfig.json; javascript si hay package.json sin tsconfig; python si requirements.txt/pyproject.toml; etc.
   - `runtime`: node si hay package.json; python; etc.
   - `framework`: aws-sam si hay template.yaml/samconfig.toml; serverless si serverless.yml; si aparece uno claro en package.json usalo; si no, `none`.
   - `test_command`: leé el script `test` de package.json si existe; si no, inferí (`node --test`, `pytest`); si no hay forma, `none`.
   - `typecheck_command`: `npx tsc --noEmit` si es TS; si no, `none`.
   - `lint_command`: `npx eslint .` si hay eslint; si no, `none`.
   Si algún dato es ambiguo, elegí lo más probable y anotalo — NO frenes a preguntar.

3. **Binding a engram (memoria del proyecto) — OPCIONAL, solo si engram está instalado.** Si en esta máquina NO existe la tool `mem_current_project`/`mem_save`, poné `engram_project: none` en la config, saltá también el paso 7, y seguí normal. Si engram SÍ está disponible: llamá a la tool `mem_current_project`. Devuelve el proyecto engram detectado para esta carpeta (por `git_root` o `dir_basename`) y posibles alternativas. Mostrale al usuario el nombre detectado y su origen, y aclará que **toda la memoria del SDD** (decisiones de diseño, features completados) va a quedar asociada a ese proyecto engram. Si `available_projects` trae alternativas, o si el usuario ya te indicó otro nombre, usá ese; si no, usá el detectado. Guardá el nombre elegido en el campo `engram_project` del config.yaml.

4. **Creá `openspec/config.yaml`** con esta forma exacta (rellenando valores):
   ```yaml
   # openspec/config.yaml — generado por /sdd-init
   project: <nombre del package.json o de la carpeta>
   engram_project: <nombre detectado/elegido en el paso 3>
   stack:
     language: <...>
     runtime: <...>
     framework: <...>
   test_command: "<...>"
   typecheck_command: "<...>"
   lint_command: "<...>"
   phases: [explore, proposal, spec, design, tasks, apply, verify, review, archive]
   delivery:
     max_pr_lines: 400
   ```

5. **Creá `openspec/registry.md`**:
   ```markdown
   # SDD Registry — <project>

   Proyecto inicializado con /sdd-init. Un renglon por feature.

   | Slug | Titulo | Fase actual | Proximo paso |
   |------|--------|-------------|--------------|
   | _(sin features todavia)_ | | | |
   ```

6. **Agregá el bloque de calibración a `CLAUDE.md`** (creá el archivo si `SIN_CLAUDE_MD`, o appendealo si `CLAUDE_MD_OK`):
   ```markdown

   ## SDD Harness (spec-driven development)
   Este proyecto usa el flujo SDD. El estado del proceso vive en `openspec/`, no en el chat.
   La memoria semantica del proyecto vive en engram (proyecto: <engram_project>).
   - Fases: explore -> proposal -> spec -> design -> tasks -> apply -> verify -> review -> archive.
   - Comandos: /sdd-status, /sdd-propose, /sdd-spec, /sdd-design, /sdd-tasks, /sdd-apply, /sdd-verify, /sdd-review, /sdd-archive.
   - Cada fase se niega a correr si falta el artifact previo (ver openspec/changes/<slug>/state.json).
   - Comando de test del proyecto: `<test_command>`.
   ```

7. **(OPCIONAL — solo si engram está instalado.)** Guardá en engram una memoria inicial del proyecto con `mem_save`: title "Proyecto <project> inicializado con harness SDD", type "architecture", content con el stack detectado, el `test_command`, y que el proyecto ahora se gestiona con el flujo SDD (openspec/). Esto ancla el contexto del proyecto en engram.

8. Cerrá SIEMPRE con el **Result Contract**:
   ```
   STATUS: ok | blocked
   RESUMEN: <1-2 lineas, incluí el proyecto engram asociado>
   ARTIFACTS: <archivos creados o modificados> + memoria engram
   NEXT: <comando siguiente>
   RIESGO: <o "ninguno">
   ```
