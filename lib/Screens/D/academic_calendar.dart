import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class AcademicCalendarPage extends StatelessWidget {
  const AcademicCalendarPage({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Academic Calendar"),
      ),
      body: SfPdfViewer.asset('assets/pdfs/ac.pdf'),
    );
  }
}
