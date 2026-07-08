# Ver RFC-MODULARIZACION.md · paquete metasurvey.explorer.backend
# Helpers locales + registro de los providers de los hooks del core y de anda.

# `metasurvey_msg()` and `metasurvey_user_agent()` are internal, non-exported
# helpers in metasurvey.core. We keep local copies rather than reach into
# another package's namespace.

#' Emit an informational message, respecting the verbosity option
#' @param ... Arguments passed to [message()].
#' @return Invisibly `NULL`; called for its side effect.
#' @noRd
metasurvey_msg <- function(...) {
  if (isTRUE(getOption("metasurvey.verbose", TRUE))) {
    message(...)
  }
}

#' User-Agent string for API HTTP requests
#' @return Character string like "metasurvey.explorer.backend/0.1.0 (...)".
#' @noRd
metasurvey_user_agent <- function() {
  version <- tryCatch(
    as.character(utils::packageVersion("metasurvey.explorer.backend")),
    error = function(e) "dev"
  )
  paste0(
    "metasurvey.explorer.backend/", version,
    " (https://github.com/metasurveyr/metasurvey.explorer.backend)"
  )
}

# ── Provider registration ─────────────────────────────────────────────────────
# This client resolves two injectable hooks left open by upstream packages:
#   * metasurvey.core   -> options(metasurvey.backend_provider): routes the "api"
#                          RecipeBackend/WorkflowBackend branch to this client.
#   * metasurvey.anda   -> options(metasurvey.anda_var_provider): supplies curated
#                          ANDA variable metadata via api_get_anda_variables().
# Loading this package wires both, so set_backend("api") and anda_variables()
# work end to end.

.register_backend_provider <- function() {
  options(metasurvey.backend_provider = function(op, args) {
    fn <- switch(op,
      list_recipes = api_list_recipes,
      get_recipe = api_get_recipe,
      publish_recipe = api_publish_recipe,
      download_recipe = api_download_recipe,
      list_workflows = api_list_workflows,
      get_workflow = api_get_workflow,
      publish_workflow = api_publish_workflow,
      download_workflow = api_download_workflow,
      stop("Unknown backend op: ", op, call. = FALSE)
    )
    do.call(fn, args)
  })
}

.register_anda_var_provider <- function() {
  options(metasurvey.anda_var_provider = function(survey_type, var_names) {
    api_get_anda_variables(survey_type, var_names)
  })
}

.onLoad <- function(libname, pkgname) {
  .register_backend_provider()
  .register_anda_var_provider()

  # Auto-configure API from environment variables (moved out of metasurvey.core)
  env_url <- Sys.getenv("METASURVEY_API_URL", "")
  if (nzchar(env_url)) {
    options(metasurvey.api_url = sub("/$", "", env_url))
  }
  env_token <- Sys.getenv("METASURVEY_TOKEN", "")
  if (nzchar(env_token)) {
    options(metasurvey.api_token = env_token)
  }
}
