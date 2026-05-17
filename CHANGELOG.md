# Changelog

## [0.1.0-beta.1-wip]

### Added

- Initial release.
- `tracedGcpBigtable<T>(...)` — wraps a otel_gcp_bigtable call in a CLIENT-kind span
  with vendor-specific attributes.
- Zone-scoped suppression via `runWithoutGcpBigtableInstrumentation()` / `Async()`.
