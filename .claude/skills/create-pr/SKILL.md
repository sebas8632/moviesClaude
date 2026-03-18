---
name: github-pull-request
description: Analiza los cambios de la rama actual, genera y crea un Pull Request en
  GitHub con nivel de detalle medio usando gh CLI. Usar siempre que el usuario diga
  "crea un PR", "abre un pull request", "sube los cambios a revisión", "genera el PR",
  o "quiero hacer un pull request". También activar cuando el usuario diga "mis cambios
  están listos para review" o "termina el feature" en contexto de un repositorio git.
---

# GitHub Pull Request — Generación y Creación Automática

## Rol
Analizas la rama actual, comparas contra la rama base, redactas un PR con nivel de
detalle medio y lo creas directamente en GitHub usando `gh pr create`. Sin borradores
innecesarios — analizar, redactar y crear.

Nivel de detalle medio significa: suficiente para que el reviewer entienda qué cambió
y por qué, sin documentar cada línea de código.

---

## Prerequisitos

Verificar antes de continuar:
```bash
gh auth status          # gh CLI autenticado
git status              # rama con commits listos
gh repo view            # repositorio conectado a GitHub
```

Si `gh` no está instalado o no hay auth, indicar:
```
gh CLI no está disponible o no está autenticado.
Instalar: brew install gh
Autenticar: gh auth login
```

---

## Proceso

### 1. Recopilar contexto del repositorio
```bash
git branch --show-current                    # rama actual
git log main..HEAD --oneline                 # commits incluidos en el PR
git diff main...HEAD --stat                  # archivos y líneas cambiadas
git diff main...HEAD                         # diff completo para análisis
gh pr list --state open --limit 5            # PRs abiertos (contexto del equipo)
```

Si la rama base no es `main`, detectarla:
```bash
git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'
```

### 2. Analizar los cambios

Del diff extraer:
- **Tipo de cambio dominante:** feat, fix, refactor, perf, chore, docs, test
- **Scope:** módulo o feature principal afectado
- **Qué cambió:** descripción funcional de los cambios (no técnica)
- **Por qué cambió:** inferir del contexto o de los mensajes de commit
- **Archivos clave:** los más relevantes, agrupados por módulo si son muchos
- **Breaking changes:** cambios que afectan contratos públicos o comportamiento existente
- **Evidencia visual necesaria:** ¿hay cambios en UI? Si sí, incluir sección de screenshots

### 3. Redactar el PR

Usar la plantilla de abajo. Guardar en archivo temporal:
```bash
cat > /tmp/pr_body.md << 'EOF'
<contenido del PR>
EOF
```

### 4. Crear el PR
```bash
gh pr create \
  --title "<título>" \
  --body-file /tmp/pr_body.md \
  --base <rama-base> \
  --head <rama-actual>
```

### 5. Confirmar
Mostrar la URL del PR creado y el título usado.

---

## Plantilla del PR

```markdown
## ¿Qué hace este PR?
<2-3 oraciones describiendo el cambio desde la perspectiva del usuario o del sistema.
No describir implementación — describir comportamiento o resultado.>

## Tipo de cambio
<!-- Marcar el que aplica -->
- [ ] ✨ `feat` — Nueva funcionalidad
- [ ] 🐛 `fix` — Corrección de bug
- [ ] ♻️ `refactor` — Refactorización sin cambio de comportamiento
- [ ] ⚡ `perf` — Mejora de performance
- [ ] 🧪 `test` — Tests nuevos o corregidos
- [ ] 📝 `docs` — Documentación
- [ ] 🔧 `chore` — Mantenimiento, dependencias, config
- [ ] 💥 `breaking` — Cambio que rompe compatibilidad

## Cambios realizados
<Lista de los cambios principales, agrupados por módulo si aplica.
Nivel medio: qué hace cada cambio, no cómo lo hace.>

- **[Módulo/Archivo]:** <qué cambió y para qué>
- **[Módulo/Archivo]:** <qué cambió y para qué>

## Commits incluidos
<Lista de commits con su mensaje, extraída de git log>

## Evidencia visual
<Incluir esta sección SOLO si hay cambios en UI.
Si no hay cambios visuales, eliminar la sección completa.>

| Antes | Después |
|-------|---------|
| _Adjuntar screenshot_ | _Adjuntar screenshot_ |

> ⚠️ Agregar screenshots manualmente en GitHub después de crear el PR.

## ¿Hay breaking changes?
<Si no hay: "No." — Si hay, describir qué se rompe y cómo migrar.>

## Notas para el reviewer
<Opcional: contexto adicional, decisiones de diseño, áreas a prestar atención,
o cosas que quedaron fuera del scope.>
```

---

## Reglas de redacción

**Título del PR:**
- Formato: `<tipo>(<scope>): <descripción corta>`
- Mismo estilo que Conventional Commits
- Máximo 72 caracteres
- Imperativo presente: "agrega", "corrige", "migra"

**Sección "¿Qué hace este PR?":**
- Orientada al reviewer, no al implementador
- Sin jerga técnica interna — explicar como si el reviewer no vio el código
- Si viene de un ticket o issue, mencionarlo: "Implementa el flujo de login (#42)"

**Sección "Cambios realizados":**
- Agrupar por módulo o feature si hay más de 5 archivos
- No listar archivos triviales (`.gitignore`, `Package.resolved`)
- Nivel medio: "agrega validación de email en LoginViewModel" no "línea 47 de LoginViewModel.swift"

**Evidencia visual:**
- Si el diff toca archivos `*View.swift`, `*.storyboard`, o assets → incluir sección
- Si no hay cambios UI → eliminar la sección completamente del body

---

## Casos especiales

**Rama sin commits nuevos vs main:**
```
La rama actual no tiene commits nuevos respecto a main.
No hay cambios para incluir en un PR.
```

**PR ya existe para esta rama:**
```bash
gh pr view --web    # abrir el PR existente
```
Notificar al usuario que ya existe un PR y ofrecer actualizarlo.

**Muchos commits (>10):**
Agrupar los commits por tipo en la sección "Commits incluidos" en lugar de listarlos todos.

**Cambios en archivos sensibles detectados:**
Si el diff incluye `.env`, secretos, o credenciales, advertir antes de crear el PR:
```
⚠️ Se detectaron posibles archivos sensibles en el diff:
- <archivo>
¿Confirmas que estos archivos deben incluirse en el PR?
```