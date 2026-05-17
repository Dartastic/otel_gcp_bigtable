// Licensed under the Apache License, Version 2.0
// Copyright 2025, Mindful Software LLC, All rights reserved.

import 'package:otel_gcp_bigtable/otel_gcp_bigtable.dart';
import 'package:test/test.dart';

void main() {
  group('otel_gcp_bigtable', () {
    test('suppression toggles in zone', () async {
      expect(gcpBigtableInstrumentationSuppressed(), isFalse);
      await runWithoutGcpBigtableInstrumentationAsync(() async {
        expect(gcpBigtableInstrumentationSuppressed(), isTrue);
      });
      expect(gcpBigtableInstrumentationSuppressed(), isFalse);
    });

    test('GcpBigtableResult fields default null', () {
      const r = GcpBigtableResult();
      expect(r.statusCode, isNull);
    });
  });
}
