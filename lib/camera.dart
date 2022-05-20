import 'package:camera/camera.dart';
import 'package:firebase_demo/picture.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);
  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  List<CameraDescription>? cameras;
  List<Widget>? cameraButtons;
  CameraDescription? activeCamera;
  CameraController? cameraController;
  CameraPreview? preview;

  @override
  void initState() {
    listCameras().then((result) {
      setState(() {
        cameraButtons = result;
        setCameraController();
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    if (cameraController != null) {
      cameraController!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera View'),
      ),
      body: Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: cameraButtons ??
                  [
                    Container(
                      child: Text('No cameras available'),
                    )
                  ],
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 2,
              child: preview,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (cameraController != null) {
                      takePicture().then((dynamic picture) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PictureScreen(
                              picture: picture,
                            ),
                          ),
                        );
                      });
                    }
                  },
                  child: Text('Take picture'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<List<Widget>?> listCameras() async {
    List<Widget> buttons = [];
    cameras = await availableCameras();
    if (cameras == null) return null;
    activeCamera ??= cameras!.first;
    if (cameras!.isNotEmpty) {
      for (CameraDescription camera in cameras!) {
        buttons.add(
          ElevatedButton(
            onPressed: () {
              setState(() {
                activeCamera = camera;
                setCameraController();
              });
            },
            child: Row(
              children: [
                Icon(Icons.camera_alt),
                Text(camera == null ? '' : camera.name)
              ],
            ),
          ),
        );
      }
      return buttons;
    } else {
      return [];
    }
  }

  Future setCameraController() async {
    if (activeCamera == null) return;
    cameraController = CameraController(
      activeCamera!,
      ResolutionPreset.high,
    );
    await cameraController!.initialize();
    setState(() {
      preview = CameraPreview(cameraController!);
    });
  }

  Future takePicture() async {
    if (!cameraController!.value.isInitialized) {
      return null;
    }
    if (cameraController!.value.isTakingPicture) {
      return null;
    }
    try {
      await cameraController!.setFlashMode(FlashMode.off);
      XFile picture = await cameraController!.takePicture();
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PictureScreen(picture: picture),
        ),
      );
    } catch (exception) {
      print(exception.toString());
    }
  }
}
