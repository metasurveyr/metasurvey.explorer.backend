# Ver RFC-MODULARIZACION.md · paquete metasurvey.explorer.backend
# Tests de los endpoints admin (usados por metasurvey.explorer.frontend).

test_that("api_pending_users hits admin/pending-users", {
  ep <- NULL
  local_mocked_bindings(
    api_request = function(endpoint, method = "GET", ...) {
      ep <<- endpoint
      list(ok = TRUE, users = list())
    }
  )
  api_pending_users()
  expect_equal(ep, "admin/pending-users")
})

test_that("api_approve_user builds the approve path", {
  ep <- NULL
  local_mocked_bindings(
    api_request = function(endpoint, method = "GET", ...) {
      ep <<- endpoint
      list(ok = TRUE)
    }
  )
  api_approve_user("ana@example.com")
  expect_equal(ep, "admin/approve/ana@example.com")
})

test_that("api_reject_user builds the reject path", {
  ep <- NULL
  local_mocked_bindings(
    api_request = function(endpoint, method = "GET", ...) {
      ep <<- endpoint
      list(ok = TRUE)
    }
  )
  api_reject_user("ana@example.com")
  expect_equal(ep, "admin/reject/ana@example.com")
})

test_that("api_generate_token hits auth/generate-token", {
  ep <- NULL
  local_mocked_bindings(
    api_request = function(endpoint, method = "GET", ...) {
      ep <<- endpoint
      list(ok = TRUE, token = "t")
    }
  )
  api_generate_token()
  expect_equal(ep, "auth/generate-token")
})
