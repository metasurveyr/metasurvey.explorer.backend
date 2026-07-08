# Migración: metasurvey.explorer.backend

**CLIENTE R** de la API REST de metasurvey, extraído del monolito `metasurvey`
(renombrado a [`metasurvey-legacy`](https://github.com/metasurveyr/metasurvey-legacy))
como parte de la modularización sugerida por la revisión de rOpenSci. Ver
`RFC-MODULARIZACION.md` en el repo legacy.

> **Nota de nombre:** el repo es `metasurvey.explorer.backend` (con puntos). R no admite
> guiones en nombres de paquete, así que el paquete se llama `metasurvey.explorer.backend`
> (Opción 2 del RFC: repo = paquete, ambos con punto).

Responsabilidad: **consumir** la API (httr2) para publicar/descubrir/compartir recipes y
workflows contra un servidor metasurvey desplegado (que vive en `metasurvey.worker`).
NO es un servidor. Es lo que instala el usuario R que quiere hablar con la API.

## Origen → destino

| Archivo aquí | Origen |
|---|---|
| `R/api_client.R` | `metasurvey-legacy/R/api_client.R` (símbolos del core qualificados a `metasurvey.core::`) |
| `R/zzz.R` | **nuevo** — helpers locales (`metasurvey_msg`, `metasurvey_user_agent`) + `.onLoad` que registra los providers y la auto-config de API (movida desde `metasurvey.core::meta.R`) |
| `tests/testthat/test-api-client.R` | idem (HTTP mockeado; `Recipe$new`/`RecipeWorkflow$new` qualificados) |
| `tests/testthat/test-recipe-api.R` | **reescrito** — antes testeaba el backend LOCAL (que ahora vive y se testea en core); aquí queda la parte de integración cliente↔provider |

## Cierre de los hooks del ecosistema

Al cargar este paquete, `.onLoad` registra **dos providers** que resuelven los hooks que
`metasurvey.core` y `metasurvey.anda` dejaron inyectables:

1. `options(metasurvey.backend_provider)` — la rama `"api"` de `RecipeBackend`/
   `WorkflowBackend` del core (`.backend_api_call(op, args)`) enruta a las funciones
   `api_*` de este cliente. Así `set_backend("api")` funciona end to end.
2. `options(metasurvey.anda_var_provider)` — `metasurvey.anda::anda_variables()` obtiene
   la lista curada de variables vía `api_get_anda_variables()`.

## Movido a metasurvey.core (corrección de cobertura)

Durante la extracción se detectó que los tests del **backend LOCAL** nunca se habían
migrado a core, dejando `RecipeBackend`/`WorkflowBackend`/`RecipeRegistry`/
`WorkflowRegistry` (que viven en core) **sin testear**. Se movieron a core:
`test-backend-local.R`, `test-recipe-registry.R`, `test-workflow-registry.R`,
`test-workflow-backend.R` (+130 tests; core pasó de 1540 a 1670 pass).

## Dependencias

- **Imports**: `metasurvey.core` (reconstruye objetos Recipe/Workflow desde el JSON de la
  API), `httr2`, `jsonlite`.
- **Suggests**: `withr`, testthat, knitr, rmarkdown.

R CMD check: 0 errors, 0 warnings, 0 notes. Tests: 148 pass, 0 fail.
