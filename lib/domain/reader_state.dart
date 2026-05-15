/// Snapshot of where a reader was last left, persisted on
/// app pause and reapplied when the document is reopened.
class ReaderState {
  const ReaderState({
    required this.documentPath,
    required this.position,
    this.zoom,
    this.scrollOffset,
    required this.updatedAt,
  });

  final String documentPath;
  final String position;
  final double? zoom;
  final double? scrollOffset;
  final DateTime updatedAt;

  ReaderState copyWith({
    String? position,
    double? zoom,
    double? scrollOffset,
    DateTime? updatedAt,
  }) {
    return ReaderState(
      documentPath: documentPath,
      position: position ?? this.position,
      zoom: zoom ?? this.zoom,
      scrollOffset: scrollOffset ?? this.scrollOffset,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
