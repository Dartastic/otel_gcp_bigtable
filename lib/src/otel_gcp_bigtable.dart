// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';

import 'otel_gcp_bigtable_suppression.dart';

class GcpBigtableResult {
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

class GcpBigtableCallResult<T> {
  const GcpBigtableCallResult({required this.value, this.result});
  final T value;
  final GcpBigtableResult? result;
}

Future<T> tracedGcpBigtable<T>({
  required String operation,
  required Future<GcpBigtableCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (gcpBigtableInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_gcp_bigtable');
  final span = t.startSpan('bigtable $operation', kind: SpanKind.client);
  try {
    span.addAttributes(
        OTel.attributes([OTel.attributeString('db.system.name', 'bigtable')]));
    span.addAttributes(
        OTel.attributes([OTel.attributeString('gcp.service', 'bigtable')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.project != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('gcp.project.id', res.project!)]));
      }
      if (res.instance != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('db.namespace', res.instance!)]));
      }
      if (res.table != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('db.collection.name', res.table!)]));
      }
      if (res.columnFamily != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
            'gcp.bigtable.column_family',
            res.columnFamily!,
          )
        ]));
      }
      if (res.rowKey != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('gcp.bigtable.row_key', res.rowKey!)]));
      }
      if (res.rowsAffected != null) {
        span.addAttributes(OTel.attributes([
          OTel.attributeInt('db.response.returned_rows', res.rowsAffected!)
        ]));
      }
      if (res.location != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('cloud.region', res.location!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeInt('http.response.status_code', res.statusCode!)]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTel.attributes(
            [OTel.attributeString('bigtable.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTel.attributes([
          OTel.attributeString(
            ErrorResource.errorType.key,
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
