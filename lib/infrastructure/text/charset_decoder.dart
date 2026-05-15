import 'dart:convert';

import 'package:charset/charset.dart';

/// Decodes raw file bytes into a Dart string, applying a heuristic to
/// pick an encoding when the caller did not specify one. Order of
/// preference is: explicit override → BOM → valid UTF-8 → fallback to
/// Windows-1252 (a good catch-all for Western European legacy text).
class CharsetDecoder {
  const CharsetDecoder();

  ({String text, String encoding}) decode(
    List<int> bytes, {
    String? preferredEncoding,
  }) {
    if (preferredEncoding != null) {
      final decoded = _tryDecode(bytes, preferredEncoding);
      if (decoded != null) {
        return (text: decoded, encoding: preferredEncoding);
      }
    }

    final bom = _detectBom(bytes);
    if (bom != null) {
      final decoded = _tryDecode(bytes.sublist(bom.skip), bom.encoding);
      if (decoded != null) {
        return (text: decoded, encoding: bom.encoding);
      }
    }

    try {
      return (text: utf8.decode(bytes, allowMalformed: false), encoding: 'utf-8');
    } on FormatException {
      // fall through
    }

    final cp1252 = Charset.getByName('windows-1252');
    if (cp1252 != null) {
      return (text: cp1252.decode(bytes), encoding: 'windows-1252');
    }
    return (text: latin1.decode(bytes, allowInvalid: true), encoding: 'iso-8859-1');
  }

  String? _tryDecode(List<int> bytes, String encoding) {
    final normalized = encoding.toLowerCase();
    try {
      if (normalized == 'utf-8') {
        return utf8.decode(bytes, allowMalformed: false);
      }
      if (normalized == 'iso-8859-1' || normalized == 'latin1') {
        return latin1.decode(bytes, allowInvalid: false);
      }
      final cs = Charset.getByName(normalized);
      return cs?.decode(bytes);
    } catch (_) {
      return null;
    }
  }

  ({String encoding, int skip})? _detectBom(List<int> b) {
    if (b.length >= 3 && b[0] == 0xEF && b[1] == 0xBB && b[2] == 0xBF) {
      return (encoding: 'utf-8', skip: 3);
    }
    if (b.length >= 2 && b[0] == 0xFF && b[1] == 0xFE) {
      return (encoding: 'utf-16', skip: 2);
    }
    if (b.length >= 2 && b[0] == 0xFE && b[1] == 0xFF) {
      return (encoding: 'utf-16', skip: 2);
    }
    return null;
  }
}
