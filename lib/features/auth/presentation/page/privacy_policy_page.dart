import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

class PdfViewerPage extends StatefulWidget {
  final String title;
  final String storagePath;

  const PdfViewerPage({
    super.key,
    required this.title,
    required this.storagePath,
  });

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? localPath;
  bool isLoading = true;
  String? errorMessage;
  int totalPages = 0;
  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      // Получаем URL из Firebase Storage
      final ref = FirebaseStorage.instance.ref(widget.storagePath);
      final url = await ref.getDownloadURL();

      // Скачиваем PDF во временную директорию
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/${widget.title}.pdf');
        await file.writeAsBytes(response.bodyBytes);

        setState(() {
          localPath = file.path;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to download PDF');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (totalPages > 0)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '${currentPage + 1} / $totalPages',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading document...'),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Failed to load document',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadPdf,
                icon: Icon(Icons.refresh),
                label: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (localPath == null) {
      return Center(child: Text('No document available'));
    }

    return PDFView(
      filePath: localPath!,
      enableSwipe: true,
      swipeHorizontal: false,
      autoSpacing: true,
      pageFling: true,
      pageSnap: true,
      onRender: (pages) {
        setState(() {
          totalPages = pages ?? 0;
        });
      },
      onPageChanged: (page, total) {
        setState(() {
          currentPage = page ?? 0;
        });
      },
      onError: (error) {
        setState(() {
          errorMessage = error.toString();
        });
      },
    );
  }
}

// Страница для Privacy Policy
class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PdfViewerPage(
      title: 'Privacy Policy',
      storagePath: 'policy/policy.pdf', // Укажите правильный путь
    );
  }
}

// Страница для Terms of Use
class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return PdfViewerPage(
      title: 'Terms of Use',
      storagePath: 'policy/terms.pdf', // Укажите правильный путь
    );
  }
}