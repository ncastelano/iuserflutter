import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;

class FileText extends StatefulWidget {
  const FileText({Key? key}) : super(key: key);

  @override
  State<FileText> createState() => _FileTextState();
}

class _FileTextState extends State<FileText> {
  quill.QuillController _controller = quill.QuillController.basic();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                'Faça seu texto e compartilhe',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            quill.QuillSimpleToolbar(
              controller: _controller,
              config: quill.QuillSimpleToolbarConfig(
                multiRowsDisplay: false,

                iconTheme: quill.QuillIconTheme(
                  iconButtonUnselectedData: quill.IconButtonData(
                    color: Colors.white,
                    iconSize: 35,
                    padding: const EdgeInsets.all(12),
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all(Colors.grey[850]),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  iconButtonSelectedData: quill.IconButtonData(
                    color: Colors.white,
                    iconSize: 35,
                    padding: const EdgeInsets.all(8),
                    style: ButtonStyle(
                      backgroundColor:
                      MaterialStateProperty.all(Colors.blue),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(color: Colors.white,
                child: DefaultTextStyle(
                  style: const TextStyle(
                    color: Colors.black,  // texto preto
                    fontSize: 16,
                  ),

                  child: quill.QuillEditor.basic(
                    controller: _controller,
                    config: const quill.QuillEditorConfig(
                      placeholder: 'Digite seu texto...',

                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
