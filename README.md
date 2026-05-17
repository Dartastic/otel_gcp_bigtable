# otel_gcp_bigtable

Dartastic OpenTelemetry bridge for GCP Bigtable (wide-column NoSQL).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_gcp_bigtable/otel_gcp_bigtable.dart';

await tracedGcpBigtable<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return GcpBigtableCallResult(value: r, result: GcpBigtableResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutGcpBigtableInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
