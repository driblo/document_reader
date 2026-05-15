import 'package:document_reader/domain/document.dart';
import 'package:document_reader/infrastructure/handlers/handler_registry.dart';
import 'package:flutter_test/flutter_test.dart';

DocumentRef _ref(String name) => DocumentRef(
      path: '/tmp/$name',
      displayName: name,
      mimeType: 'application/octet-stream',
      sizeBytes: 0,
    );

void main() {
  final registry = HandlerRegistry.defaults();

  test('routes pdf to the pdf handler', () {
    expect(registry.resolve(_ref('foo.pdf'))?.id, 'pdf');
  });

  test('markdown wins over generic text for .md', () {
    expect(registry.resolve(_ref('notes.md'))?.id, 'markdown');
  });

  test('falls back to office handoff for docx', () {
    expect(registry.resolve(_ref('report.docx'))?.id, 'office_handoff');
  });

  test('returns null for unknown extensions', () {
    expect(registry.resolve(_ref('mystery.xyz')), isNull);
  });

  test('detects pdf via magic bytes when extension is wrong', () {
    final header = [0x25, 0x50, 0x44, 0x46]; // %PDF
    expect(
      registry.resolve(_ref('weird.bin'), headerBytes: header)?.id,
      'pdf',
    );
  });
}
