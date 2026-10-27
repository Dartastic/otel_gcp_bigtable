// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_gcp_bigtable_suppression.dart';

class GcpBigtableResult {
  /// Creates a result.
  const GcpBigtableResult({
    this.project,
    this.instance,
    this.table,
    this.columnFamily,
    this.rowKey,
    this.rowsAffected,
    this.location,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? project;
  final String? instance;
  final String? table;
  final String? columnFamily;
  final String? rowKey;
  final int? rowsAffected;
  final String? location;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class GcpBigtableCallResult<T> {
  /// Creates a call result.
  const GcpBigtableCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final GcpBigtableResult? result;
}

Future<T> tracedGcpBigtable<T>({
  required String operation,
  required Future<GcpBigtableCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (gcpBigtableInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_gcp_bigtable');
  final span = t.startSpan('bigtable $operation', kind: SpanKind.client);
  try {
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('db.system.name', 'bigtable')]));
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('gcp.service', 'bigtable')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.project != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('gcp.project.id', res.project!)]));
      }
      if (res.instance != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('db.namespace', res.instance!)]));
      }
      if (res.table != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('db.collection.name', res.table!)]));
      }
      if (res.columnFamily != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            'gcp.bigtable.column_family',
            res.columnFamily!,
          )
        ]));
      }
      if (res.rowKey != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('gcp.bigtable.row_key', res.rowKey!)]));
      }
      if (res.rowsAffected != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('db.response.returned_rows', res.rowsAffected!)
        ]));
      }
      if (res.location != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('cloud.region', res.location!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('bigtable.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'bigtable.error',
          )
        ]));
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
