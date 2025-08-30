import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iuser/home/upload_video/upload_form.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}



class _UploadScreenState extends State<UploadScreen>
{
  getVideoFile(ImageSource sourceImg) async
  {
    final videoFile = await ImagePicker().pickVideo(source: sourceImg);

    if(videoFile != null)
    {
      //video upload form
      Get.to(
        UploadForm(
          videoFile: File(videoFile.path),
          videoPath: videoFile.path,
        ),
      );
    }
  }

  displayDialogBox()
  {
    return showDialog(
      context: context,
      builder: (context)=> SimpleDialog(
        children: [

          SimpleDialogOption(
            onPressed: ()
            {
              getVideoFile(ImageSource.gallery);
            },
            child: Row(
              children: const [
                Icon(
                  Icons.image,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      "Get Video from Phone Gallery",
                      maxLines: 3,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SimpleDialogOption(
            onPressed: ()
            {
              getVideoFile(ImageSource.camera);
            },
            child: Row(
              children: const [
                Icon(
                  Icons.camera_alt,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      "Make Video with Phone Camera",
                      maxLines: 3,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SimpleDialogOption(
            onPressed: ()
            {
              Get.back();
            },
            child: Row(
              children: const [
                Icon(
                  Icons.cancel,
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Image.asset(
              "images/upload.png",
              width: 260,
            ),

            const SizedBox(height: 20,),

            ElevatedButton(
              onPressed: ()
              {
                //display dialog box
                displayDialogBox();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text(
                "Upload New Video",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
