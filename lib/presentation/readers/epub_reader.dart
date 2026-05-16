import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';

import '../../domain/document.dart';

class EpubReader extends StatelessWidget {
  const EpubReader({super.key, required this.ref});
  final DocumentRef ref;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.menu_book_outlined, size: 64),
            const SizedBox(height: 16),
            const Text(
              'EPUB',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              ref.path.split(RegExp(r'[/\\]')).last,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => OpenFilex.open(ref.path),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open with external reader'),
            ),
          ],
        ),
      ),
    );
  }
}
