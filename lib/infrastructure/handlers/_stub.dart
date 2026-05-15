import 'package:flutter/material.dart';

import '../../domain/document.dart';
import 'document_handler.dart';

/// Phase 0 placeholder shared by every handler. Each concrete handler
/// gets its real renderer in Phase 1; for now they exist so the
/// registry compiles and the dispatch logic can be tested end-to-end.
mixin HandlerStubMixin on DocumentHandler {
  @override
  Future<Widget> buildReader(DocumentRef ref) async {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          '$id reader not implemented yet (Phase 1).\n${ref.displayName}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Future<Thumbnail?> generateThumbnail(DocumentRef ref) async => null;

  @override
  Future<String?> extractText(DocumentRef ref) async => null;
}
