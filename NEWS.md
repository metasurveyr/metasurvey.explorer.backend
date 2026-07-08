# metasurvey.explorer.backend 0.1.0

* Initial release. R client for the metasurvey REST API, extracted from the
  `metasurvey` monolith (now
  [`metasurvey-legacy`](https://github.com/metasurveyr/metasurvey-legacy)) as
  part of the modularization suggested by the rOpenSci review. See
  `MIGRATION.md`.
* `api_*` functions to publish, discover, and share recipes and workflows
  against a deployed metasurvey API, plus authentication, stars, and comments.
* On load, registers `options(metasurvey.backend_provider)` and
  `options(metasurvey.anda_var_provider)` so that `set_backend("api")` in
  `metasurvey.core` and `anda_variables()` in `metasurvey.anda` route to the
  remote API.
