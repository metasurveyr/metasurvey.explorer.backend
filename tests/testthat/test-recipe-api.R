# Ver RFC-MODULARIZACION.md · paquete metasurvey.explorer.backend
# Tests de la INTEGRACION cliente <-> core: al cargar este paquete, el backend
# "api" del core (RecipeBackend) enruta sus llamadas al provider registrado, que
# delega en las funciones api_* de este cliente. (La parte del backend LOCAL se
# testea en metasurvey.core::test-backend-local.R.)

make_api_recipe <- function(name, user = "tester", downloads = 0L, topic = NULL) {
  metasurvey.core::Recipe$new(
    name = name, edition = "2023", survey_type = "ech",
    default_engine = "data.table", depends_on = list(),
    user = user, description = paste("API test:", name),
    steps = list(), id = stats::runif(1), doi = NULL,
    topic = topic, downloads = as.integer(downloads)
  )
}

# --- Provider registration ---------------------------------------------------

test_that(".onLoad registers the core backend provider", {
  provider <- getOption("metasurvey.backend_provider")
  expect_true(is.function(provider))
})

test_that(".onLoad registers the anda variable provider", {
  provider <- getOption("metasurvey.anda_var_provider")
  expect_true(is.function(provider))
})

# --- api backend delegates through the provider ------------------------------

test_that("api backend publish routes to api_publish_recipe", {
  called <- FALSE
  local_mocked_bindings(
    api_publish_recipe = function(recipe) {
      called <<- TRUE
      invisible(list(ok = TRUE))
    }
  )
  withr::local_options(list(
    metasurvey.backend_provider = function(op, args) {
      switch(op,
        publish_recipe = do.call(api_publish_recipe, args),
        stop("unexpected op")
      )
    }
  ))
  old <- metasurvey.core::set_backend("api")
  withr::defer(options(metasurvey.backend = old))
  backend <- metasurvey.core::get_backend()
  backend$publish(make_api_recipe("API Publish"))
  expect_true(called)
})

test_that("api backend search routes to api_list_recipes", {
  local_mocked_bindings(
    api_list_recipes = function(search = NULL, ...) list(make_api_recipe("API Found"))
  )
  withr::local_options(list(
    metasurvey.backend_provider = function(op, args) {
      switch(op,
        list_recipes = do.call(api_list_recipes, args),
        stop("unexpected op")
      )
    }
  ))
  old <- metasurvey.core::set_backend("api")
  withr::defer(options(metasurvey.backend = old))
  backend <- metasurvey.core::get_backend()
  results <- backend$search("test")
  expect_length(results, 1)
})

test_that("api backend get routes to api_get_recipe", {
  local_mocked_bindings(
    api_get_recipe = function(id) make_api_recipe("API Got")
  )
  withr::local_options(list(
    metasurvey.backend_provider = function(op, args) {
      switch(op,
        get_recipe = do.call(api_get_recipe, args),
        stop("unexpected op")
      )
    }
  ))
  old <- metasurvey.core::set_backend("api")
  withr::defer(options(metasurvey.backend = old))
  backend <- metasurvey.core::get_backend()
  result <- backend$get("r_123")
  expect_true(inherits(result, "Recipe"))
})

# --- anda variable provider --------------------------------------------------

test_that("anda variable provider routes to api_get_anda_variables", {
  local_mocked_bindings(
    api_get_anda_variables = function(survey_type, var_names) {
      list(list(name = "edad", label = "Edad", type = "continuous"))
    }
  )
  withr::local_options(list(
    metasurvey.anda_var_provider = function(survey_type, var_names) {
      api_get_anda_variables(survey_type, var_names)
    }
  ))
  provider <- getOption("metasurvey.anda_var_provider")
  vars <- provider("ech", "edad")
  expect_length(vars, 1)
  expect_equal(vars[[1]]$name, "edad")
})
