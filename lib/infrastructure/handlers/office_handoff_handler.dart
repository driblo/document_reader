import 'package:flutter/widgets.dart';

import '../../domain/document.dart';
import '../../presentation/readers/office_handoff_view.dart';
import 'document_handler.dart';

class OfficeHandoffHandler extends DocumentHandler {
  static const _exts = {
    'doc', 'docx', 'odt', 'rtf',
    'xls', 'xlsx', 'ods',
    'ppt', 'pptx', 'odp',
  };

  @override
  String get id => 'office_handoff';

  @override
  bool canHandle(DocumentRef ref, {List<int>? headerBytes}) =>
      _exts.contains(ref.extension);

  @override
  Future<Widget> buildReader(DocumentRef ref) async =>
      OfficeHandoffView(ref: ref);

  @override
  Future<Thumbnail?> generateThumbnail(DocumentRef ref) async => null;

  @override
  Future<String?> extractText(DocumentRef ref) async => null;
}
