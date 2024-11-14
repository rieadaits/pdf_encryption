import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfEncryptionViewer extends StatelessWidget {
  final String pdfPath;

  const PdfEncryptionViewer({
    super.key,
    required this.pdfPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Encrypted PDF Viewer'),
      ),
      body: SfPdfViewer.file(
        File(pdfPath!),
        password: "123", // Password for viewing
      ),
    );
  }
}
