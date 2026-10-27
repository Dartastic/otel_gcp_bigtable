// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_gcp_bigtable/otel_gcp_bigtable.dart';

/// Traces Gcp Bigtable calls with OpenTelemetry.
///
/// `otel_gcp_bigtable` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Gcp Bigtable call in
/// [tracedGcpBigtable]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'gcp-bigtable-example');

  // Traces a Gcp Bigtable call.
  final gcpBigtableId = await tracedGcpBigtable<String>(
    operation: 'create',
    invoke: () async {
      // Make the Gcp Bigtable call here, then report what it returned.
      const id = 'gcp_bigtable_8f3a2c';
      return const GcpBigtableCallResult(
          value: id,
          result: GcpBigtableResult(
              project: 'example',
              instance: 'example',
              table: 'orders',
              columnFamily: 'example',
              rowKey: 'orders/2026/inv-1042.pdf',
              rowsAffected: 1,
              location: 'example',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedGcpBigtable create returned $gcpBigtableId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutGcpBigtableInstrumentationAsync.
  await runWithoutGcpBigtableInstrumentationAsync(
    () => tracedGcpBigtable<String>(
      operation: 'create',
      invoke: () async {
        const id = 'gcp_bigtable_8f3a2c';
        return const GcpBigtableCallResult(
            value: id,
            result: GcpBigtableResult(
                project: 'example',
                instance: 'example',
                table: 'orders',
                columnFamily: 'example',
                rowKey: 'orders/2026/inv-1042.pdf',
                rowsAffected: 1,
                location: 'example',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
