import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_editor/image_editor.dart';
import 'package:toko_kece/resources/themes.dart';
import 'package:toko_kece/resources/themes.dart';
import 'package:toko_kece/resources/themes.dart';
import 'package:toko_kece/resources/themes.dart';
import 'package:toko_kece/ui/components/camera/camera_timer_component.dart';
import 'package:toko_kece/ui/components/camera/custom_gallery_screen.dart';
import 'package:toko_kece/ui/components/loading_display_component.dart';

class CustomCameraComponent extends StatefulWidget {
  final bool videoMode;

  CustomCameraComponent({Key key, this.videoMode = false}) : super(key: key);

  @override
  _CustomCameraComponentState createState() => _CustomCameraComponentState();
}

class _CustomCameraComponentState extends State<CustomCameraComponent>
    with WidgetsBindingObserver {

  CameraController _cameraController;
  List<CameraDescription> _cameras;
  int _cameraDesc = 0;
  File _videoRes;

  Future _initCamera(int index) async {
    _cameras = await availableCameras();
    if (_cameras.length > 0) {
      _cameraController =
          CameraController(_cameras[index], ResolutionPreset.medium);
    } else {
      _cameraController = CameraController(_cameras[0], ResolutionPreset.medium);
    }
    await _cameraController.initialize();
    await _cameraController.setFlashMode(FlashMode.off);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // App state changed before we got the chance to initialize.
    if (_cameraController == null || !_cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_cameraController != null) {
        setState(() {}); // rebuild
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    _cameraController.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  Future<File> _takePicture() async {
    try {
      print("PRE-CAPTURE");
      final xFile = await _cameraController.takePicture();
      print("CAPTURED");
      if (_cameras[_cameraDesc].lensDirection == CameraLensDirection.front) {
        // 1. read the image from disk into memory
        var file = File(xFile.path);
        Uint8List imageBytes = await file.readAsBytes();

        // 2. flip the image on the X axis
        final ImageEditorOption option = ImageEditorOption();
        option.addOption(FlipOption(horizontal: true));
        imageBytes = await ImageEditor.editImage(image: imageBytes, imageEditorOption: option);

        // 3. write the image back to disk
        print("CAPTURED FRONT");
        await file.delete();
        return await file.writeAsBytes(imageBytes);
      } else {
        print("CAPTURED REAR");
        return File(xFile.path);
      }
    } catch (e) {
      print("CAMERA ERROR : $e");
      return null;
    }
  }

  Future<void> _takeVideo() async {
    try {
      await _cameraController.startVideoRecording();
    } catch (e) {
      print("ERROR : $e");
    }
  }

  Future<File> _stopVideoRecording() async {
    try {
      final xFile = await _cameraController.stopVideoRecording();
      return File(xFile.path);
    } on CameraException catch (e) {
      print("ERROR : $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: FutureBuilder(
          future: _initCamera(_cameraDesc),
          builder: (ctx, snap) {
            return snap.connectionState == ConnectionState.done
                ? StatefulBuilder(
                    builder: (BuildContext c, StateSetter setMyState) {
                      return Stack(
                        children: [
                          Center(
                            child: AspectRatio(
                              aspectRatio: _cameraController.value.aspectRatio,
                              child: CameraPreview(_cameraController),
                            ),
                          ),
                          Align(
                            alignment: Alignment.topCenter,
                            child: Column(
                              children: [
                                widget.videoMode &&
                                    _cameraController.value.isRecordingVideo
                                    ? CameraTimerComponent(
                                  endByTimer: () async {
                                    _videoRes = await _stopVideoRecording();
                                    _cameraController.dispose();
                                    Navigator.of(context).pop(_videoRes);
                                  },
                                )
                                    : Container(
                                  width: 0,
                                  height: 0,
                                ),
                                // widget.videoMode ? Container() : _flashModeRowWidget(setMyState),
                              ],
                            ),
                          ),
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 50),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  widget.videoMode
                                      ? Container(
                                          width: 80,
                                          height: 0,
                                        )
                                      : RaisedButton(
                                          onPressed: () async {
                                            final result =
                                                await Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    CustomGalleryScreen(),
                                              ),
                                            ) as File;
                                            if (result != null) {
                                              Navigator.of(context).pop(result);
                                            }
                                          },
                                          clipBehavior: Clip.antiAlias,
                                          shape: CircleBorder(),
                                          color: Colors.white,
                                          child: Icon(Icons.image),
                                        ),
                                  Container(
                                    width: 80,
                                    height: 80,
                                    child: GestureDetector(
                                      onLongPress: () async {
                                        print("take video");
                                        await _takeVideo();
                                        setMyState(() {}); // refresh widget
                                      },
                                      onLongPressUp: () async {
                                        _videoRes = await _stopVideoRecording();
                                        _cameraController.dispose();
                                        Navigator.of(context).pop(_videoRes);
                                      },
                                      child: RaisedButton(
                                        onPressed: widget.videoMode
                                            ? null
                                            : () async {
                                                if (!_cameraController
                                                    .value.isTakingPicture) {
                                                  File result =
                                                      await _takePicture();
                                                  Navigator.of(context)
                                                      .pop(result);
                                                }
                                              },
                                        clipBehavior: Clip.antiAlias,
                                        shape: CircleBorder(
                                          side: BorderSide(
                                            color: Colors.grey, width: 5,
                                          ),
                                        ),
                                        color: widget.videoMode
                                            ? _cameraController
                                                    .value.isRecordingVideo
                                                ? Colors.red
                                                : Colors.white
                                            : Colors.white,
                                      ),
                                    ),
                                  ),
                                  RaisedButton(
                                    onPressed: () {
                                      setState(() {
                                        if (_cameraDesc == 0)
                                          _cameraDesc = 1;
                                        else
                                          _cameraDesc = 0;
                                      });
                                    },
                                    clipBehavior: Clip.antiAlias,
                                    shape: CircleBorder(),
                                    color: Colors.white,
                                    child: Icon(Icons.wifi_protected_setup),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  )
                : LoadingDisplayComponent();
          },
        ),
      ),
    );
  }

  Widget _flashModeRowWidget(setMyState) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        IconButton(
          icon: const Icon(Icons.flash_off),
          color: _cameraController?.value?.flashMode == FlashMode.off
              ? primaryColor
              : Colors.grey.shade300,
          onPressed: _cameraController != null
              ? () => _onFlashModeButtonPressed(FlashMode.off, setMyState)
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.flash_auto),
          color: _cameraController?.value?.flashMode == FlashMode.auto
              ? primaryColor
              : Colors.grey.shade300,
          onPressed: _cameraController != null
              ? () => _onFlashModeButtonPressed(FlashMode.auto, setMyState)
              : null,
        ),
        IconButton(
          icon: const Icon(Icons.flash_on),
          color: _cameraController?.value?.flashMode == FlashMode.always
              ? primaryColor
              : Colors.grey.shade300,
          onPressed: _cameraController != null
              ? () => _onFlashModeButtonPressed(FlashMode.always, setMyState)
              : null,
        ),
      ],
    );
  }

  Future<void> _onFlashModeButtonPressed(FlashMode mode, setMyState) async {
    await _cameraController.setFlashMode(mode);
    setMyState(() {});
  }

}
