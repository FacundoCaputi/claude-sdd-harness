---
name: sdd-help
description: Muestra la guia del harness SDD de forma clara — los 10 comandos, el flujo para proyecto nuevo y existente, y la memoria/engram. Opcional una pregunta puntual. Invocar con /sdd-help [pregunta].
disable-model-invocation: true
argument-hint: "[pregunta opcional]"
allowed-tools: Bash, Read
shell: bash
---

# /sdd-help — Guia del harness SDD

## Guia (inyectada)
```!
cat ~/.claude/sdd/README.md 2>/dev/null || echo "(no se encontro ~/.claude/sdd/README.md)"
```

## Estado del proyecto actual (inyectado)
```!
if [ -f openspec/config.yaml ]; then
  echo "Este proyecto YA es SDD. Config:"
  grep -E "project|engram_project|test_command" openspec/config.yaml 2>/dev/null
  echo "Features:"
  cat openspec/registry.md 2>/dev/null | grep "^|" | tail -n +3 || echo "(sin registry)"
else
  echo "Este proyecto NO esta inicializado como SDD (corre /sdd-init para activarlo)."
fi
```

## Tu tarea

Explicale al usuario cómo usar el harness SDD, de forma **clara y amigable**, basándote en la guía inyectada arriba.

- Si el usuario NO pasó argumento: presentá un resumen útil — la tabla de los 10 comandos (qué hace / cuándo / qué requiere), el flujo para **proyecto nuevo** y para **proyecto existente** (el `/sdd-init` de un solo paso), y una línea sobre la memoria/engram. Usá el estado del proyecto actual (inyectado) para decirle si este proyecto ya está o no inicializado, y cuál sería su próximo paso.
- Si el usuario pasó una pregunta como argumento (**$ARGUMENTS**): respondé **específicamente eso** usando la guía, sin volcar todo el manual.
- Cerrá con una sugerencia accionable (ej: "corré `/sdd-init` para activar este proyecto", o "arrancá un feature con `/sdd-propose <slug>`").

**No escribas ni modifiques archivos** — es solo lectura y explicación.
