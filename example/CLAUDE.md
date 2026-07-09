
## SDD Harness (spec-driven development)
Este proyecto usa el flujo SDD. El estado del proceso vive en `openspec/`, no en el chat.
- Fases: explore -> proposal -> spec -> design -> tasks -> apply -> verify -> review -> archive.
- Comandos: /sdd-status, /sdd-propose, /sdd-spec, /sdd-design, /sdd-tasks, /sdd-apply, /sdd-verify, /sdd-review, /sdd-archive.
- Cada fase se niega a correr si falta el artifact previo (ver openspec/changes/<slug>/state.json).
- Comando de test del proyecto: `node --test`.
