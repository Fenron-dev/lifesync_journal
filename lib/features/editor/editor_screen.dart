import 'package:flutter/material.dart';

class EditorScreen extends StatelessWidget {
  final int? entryId;
  
  const EditorScreen({super.key, this.entryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editor'),
      ),
      body: const Center(
        child: Text('Editor Screen - Phase 2'),
      ),
    );
  }
}
