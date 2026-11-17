import 'dart:io';

/// Enforce the dependency direction documented in docs/architecture.md.
void main() {
  final root = File.fromUri(Platform.script).parent.parent;
  final errors = <String>[];
  for (final folder in ['lib', 'apps/ml_lab/lib']) {
    for (final file
        in Directory('${root.path}/$folder')
            .listSync(recursive: true)
            .whereType<File>()
            .where((f) => f.path.endsWith('.dart'))) {
      final relative = file.path.substring(root.path.length + 1);
      for (final match in RegExp(
        r'''(?:import|export)\s+['"]([^'"]+)['"]''',
      ).allMatches(file.readAsStringSync())) {
        final uri = match.group(1)!;
        final resolved = uri.startsWith('package:ml_lab/')
            ? '${root.path}/apps/ml_lab/lib/${uri.substring('package:ml_lab/'.length)}'
            : file.uri.resolve(uri).path;
        final coreViolation =
            folder == 'lib' &&
            (uri.startsWith('package:') ||
                uri == 'dart:io' ||
                resolved.contains('/apps/'));
        final domainViolation =
            relative.contains('/domain/') &&
            (uri.startsWith('package:flutter/') ||
                uri.startsWith('package:material_ui/') ||
                resolved.contains('/application/') ||
                resolved.contains('/presentation/') ||
                resolved.contains('/app/'));
        final dataViolation =
            relative.contains('/data/') &&
            folder != 'lib' &&
            (uri.startsWith('package:flutter/') ||
                uri.startsWith('package:material_ui/') ||
                resolved.contains('/application/') ||
                resolved.contains('/presentation/'));
        final applicationViolation =
            relative.contains('/application/') &&
            (resolved.contains('/presentation/') ||
                uri.startsWith('package:material_ui/'));
        final painterViolation =
            relative.contains('/painters/') &&
            (resolved.endsWith('/lab_view_model.dart') ||
                resolved.endsWith('/experiment_session.dart'));
        if (coreViolation ||
            domainViolation ||
            dataViolation ||
            applicationViolation ||
            painterViolation) {
          errors.add('$relative must not depend on $uri');
        }
      }
    }
  }
  if (errors.isNotEmpty) {
    stderr.writeln(errors.join('\n'));
    exitCode = 1;
  } else {
    stdout.writeln(
      'Architecture boundaries verified: pure Dart core, inward feature dependencies, snapshot-only painters.',
    );
  }
}
