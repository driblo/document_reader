import '../../domain/document.dart';
import '_stub.dart';
import 'document_handler.dart';

class ImageHandler extends DocumentHandler with HandlerStubMixin {
  static const _exts = {
    'jpg', 'jpeg', 'png', 'webp', 'gif', 'bmp', 'heic', 'heif', 'tiff', 'tif',
  };

  @override
  String get id => 'image';

  @override
  bool canHandle(DocumentRef ref, {List<int>? headerBytes}) =>
      _exts.contains(ref.extension);
}
