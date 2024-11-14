import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf_encrypt/pdf_view.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

// Filename of the PDF you'll download and save.
const fileName = 'pspdfkit-flutter-quickstart-guide.pdf';

// URL of the PDF file you'll download.
const pdfUrl = 'https://pspdfkit.com/downloads/$fileName';
const encrypted = 'encrypted_pdf';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Download and Display a PDF',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(
        title: "Encrypt Pdf",
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _encryptedPdfPath;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _downloadAndEncryptPdf() async {
    try {
      setState(() {
        _isLoading = true;
      });
      // Download PDF
      final response = await http.get(Uri.parse(pdfUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to download PDF');
      }

      // Get temporary directory to store the PDF
      final directory = await getApplicationDocumentsDirectory();
      final originalPdfPath = '${directory.path}/original.pdf';
      final encryptedPdfPath = '${directory.path}/$fileName';

      // // Save downloaded PDF
      // await File(originalPdfPath).writeAsBytes(response.bodyBytes);

      // Load the PDF document
      final PdfDocument document = PdfDocument(inputBytes: response.bodyBytes);

      // Set encryption options
      document.security.userPassword = "123";
      document.security.ownerPassword = "123";

      // Save the encrypted PDF
      File(encryptedPdfPath).writeAsBytes(await document.save());

      // Dispose the document
      document.dispose();

      setState(() {
        _encryptedPdfPath = encryptedPdfPath;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: (_errorMessage != null)
          ? Center(child: Text(_errorMessage!))
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'First, download a PDF file. Then open it.',
                  ),
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : TextButton(
                          // Here, you download and store the PDF file in the temporary
                          // directory.
                          onPressed: () {
                            _downloadAndEncryptPdf();
                          },
                          child: const Text('Download a PDF file'),
                        ),
                  TextButton(
                    onPressed: () async {
                      final dir = await getApplicationDocumentsDirectory();
                      final filePath = "${dir.path}/$fileName";
                      log(filePath.toString());
                      log(_encryptedPdfPath.toString());

                      if (context.mounted) {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => PdfEncryptionViewer(
                                  pdfPath: _encryptedPdfPath!,
                                )));
                      }
                    },
                    child: _encryptedPdfPath != null
                        ? const Text('Open the downloaded file')
                        : const SizedBox(),
                  ),
                ],
              ),
            ),
    );
  }
}
