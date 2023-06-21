import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:image/image.dart' as img;
import 'package:location/location.dart';
import 'package:hmc_iload/class/configsImageCheckSheet.dart';
import 'package:hmc_iload/class/getItemWoImageDetailNotFound.dart';
import 'package:hmc_iload/class/imageDetailCheckSheet.dart';
import 'package:hmc_iload/class/itemWoImageDetail.dart';
import 'package:hmc_iload/class/listLoadTypeMenu.dart';
import 'package:hmc_iload/class/postImage.dart';
import 'package:hmc_iload/class/postImageResult.dart';
import 'package:hmc_iload/class/ptDocumentIDCheckResult.dart';
import 'package:hmc_iload/components/menu_list.dart';
import 'package:hmc_iload/components/menu_list2.dart';
import 'package:flutter/foundation.dart';

class TakephotoCheckSheet extends StatefulWidget {
  @override
  _TakephotoCheckSheetState createState() => _TakephotoCheckSheetState();
}

class _TakephotoCheckSheetState extends State<TakephotoCheckSheet> {
  TextEditingController documentController = TextEditingController();
  bool documentVisible = false;
  bool documentReadonly = false;
  Color documentColor = Color(0xFFFFFFFF);
  int step = 1;
  late Timer timer;
  String configs = '';
  String accessToken = '';
  String deviceId = "";
  String deviceInfo = "";
  String osVersion = "";
  LocationData? _currentPosition;
  Location location = Location();
  String gps = "";
  bool backEnabledMenu = false;
  late PTDocumentIDCheckResult result = PTDocumentIDCheckResult();
  String dwto = "";

  bool backEnabled = false;
  bool takePhotoEnabled = false;
  bool uploadEnabled = false;
  bool finishEnabled = false;
  bool documentWillUpload = false;
  bool documentWillUploadOrWillFinish = false;
  bool documentWillFinish = false;

  late File? _image = null;
  final ImagePicker _picker = ImagePicker();
  String statusUpload = '';
  String fileInBase64 = '';
  bool buttonUploadVisible = false;

  int min = 0;
  int max = 0;
  int numberupload = 0;
  int woCheckSheetHeaderId = 0;
  double scaleImg = 0;

  @override
  void initState() {
    super.initState();
    //getLocation();
    getDeviceInfo();
    setState(() {
      step = 1;
      _image = null;
    });
    getDataImageDetailCheckSheet();
  }

  Future<void> getDataImageDetailCheckSheet() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      dwto = prefs.getString('dwto')!;
      configs = prefs.getString('configs')!;
      accessToken = prefs.getString('token')!;
      woCheckSheetHeaderId = prefs.getInt('woCheckSheetHeaderId')!;

      var url = Uri.parse('https://' +
          configs +
          '/api/Documents/GetImageDetailCheckSheet/' +
          woCheckSheetHeaderId.toString());

      var headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + accessToken
      };

      http.Response response = await http.get(url, headers: headers);
      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        late ImageDetailCheckSheet result;
        setState(() {
          result = ImageDetailCheckSheet.fromJson(data);
          min = int.parse(result.min!);
          max = int.parse(result.max!);
          numberupload = result.detail!.imageNo!;
          documentController.text = dwto;
        });

        if (numberupload < max && numberupload < min) {
          setState(() {
            documentWillUpload = true;
            documentWillUploadOrWillFinish = false;
            documentWillFinish = false;
            statusUpload = 'รูปภาพเพิ่มเติม : ' +
                numberupload.toString() +
                ' / ' +
                max.toString();
            step = 2;
          });
        } else if (numberupload < max && numberupload >= min) {
          setState(() {
            documentWillUpload = false;
            documentWillUploadOrWillFinish = true;
            documentWillFinish = false;
            step = 4;
            statusUpload = 'รูปภาพเพิ่มเติม : ' +
                numberupload.toString() +
                ' / ' +
                max.toString();
          });
        } else if (numberupload >= max) {
          setState(() {
            documentWillUpload = false;
            documentWillUploadOrWillFinish = false;
            documentWillFinish = true;
            step = 4;
            statusUpload = 'รูปภาพเพิ่มเติม : ' +
                numberupload.toString() +
                ' / ' +
                max.toString();
          });
        }
        await showProgressLoading(true);
        setVisible();
        setReadOnly();
        setColor();
        setText();
      } else {
        await showProgressLoading(true);
        showErrorDialog(data.toString());
      }
    } catch (e) {
      await showProgressLoading(true);
      showErrorDialog('Error occured while getDataImageDetailCheckSheet');
    }
  }

  Future<void> getLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    _currentPosition = await location.getLocation();
    setState(() {
      gps = (_currentPosition!.latitude.toString() +
          ',' +
          _currentPosition!.longitude.toString());
    });
  }

  Future<void> getDeviceInfo() async {
    if (kIsWeb) {
      var webBrowserInfo = await DeviceInfoPlugin().webBrowserInfo;
      setState(() {
        deviceId = webBrowserInfo.browserName.name;
        osVersion = webBrowserInfo.userAgent!.toString();
        deviceInfo = webBrowserInfo.browserName.name +
            '(' +
            webBrowserInfo.vendor!.toString() +
            ')';
      });
    } else {
      var androidInfo = await DeviceInfoPlugin().androidInfo;
      setState(() {
        deviceId = androidInfo.id;
        osVersion = 'Android(' + androidInfo.version.release + ')';
        deviceInfo = androidInfo.manufacturer + '(' + androidInfo.model + ')';
      });
    }
  }

  Future<void> showProgressLoading(bool finish) async {
    if (finish == false) {
      showDialog(
          // The user CANNOT close this dialog  by pressing outsite it
          barrierDismissible: false,
          context: context,
          builder: (_) {
            return Dialog(
              // The background color
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    // The loading indicator
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 10,
                    ),
                    // Some text
                    Text('Loading...')
                  ],
                ),
              ),
            );
          });
    } else {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void setVisible() {
    if (step == 1) {
      setState(() {
        documentVisible = true;
        buttonUploadVisible = false;
      });
    } else if (step > 1) {
      setState(() {
        documentVisible = true;
        buttonUploadVisible = true;
      });
    }
  }

  void setReadOnly() {
    if (step == 1) {
      setState(() {
        documentReadonly = false;
        backEnabled = false;
        takePhotoEnabled = false;
        uploadEnabled = false;
        finishEnabled = false;
        documentWillUpload = false;
        documentWillUploadOrWillFinish = false;
        documentWillFinish = false;
      });
    } else if (step == 2) {
      if (documentWillUpload) {
        setState(() {
          documentReadonly = true;
          backEnabled = true;
          takePhotoEnabled = true;
          uploadEnabled = false;
          finishEnabled = false;
        });
      } else if (documentWillUploadOrWillFinish) {
        setState(() {
          documentReadonly = true;
          backEnabled = true;
          takePhotoEnabled = true;
          uploadEnabled = false;
          finishEnabled = true;
        });
      } else if (documentWillFinish) {
        setState(() {
          documentReadonly = true;
          backEnabled = true;
          takePhotoEnabled = false;
          uploadEnabled = false;
          finishEnabled = true;
        });
      }
    } else if (step == 3) {
      setState(() {
        documentReadonly = true;
        backEnabled = true;
        takePhotoEnabled = false;
        uploadEnabled = true;
        finishEnabled = false;
      });
    } else if (step == 4) {
      if (documentWillUpload) {
        setState(() {
          documentReadonly = true;
          backEnabled = true;
          takePhotoEnabled = true;
          uploadEnabled = false;
          finishEnabled = false;
        });
      } else if (documentWillUploadOrWillFinish) {
        setState(() {
          documentReadonly = true;
          backEnabled = true;
          takePhotoEnabled = true;
          uploadEnabled = false;
          finishEnabled = true;
        });
      } else if (documentWillFinish) {
        setState(() {
          documentReadonly = true;
          backEnabled = true;
          takePhotoEnabled = false;
          uploadEnabled = false;
          finishEnabled = true;
        });
      }
    }
  }

  void setColor() {
    if (step == 1) {
      setState(() {
        documentColor = Color(0xFFFFFFFF);
      });
    } else if (step == 2) {
      setState(() {
        documentColor = Color(0xFFEEEEEE);
      });
    } else if (step == 3) {
      setState(() {
        documentColor = Color(0xFFEEEEEE);
      });
    } else if (step == 4) {
      setState(() {
        documentColor = Color(0xFFEEEEEE);
      });
    }
  }

  void setText() {
    if (step == 1) {
      setState(() {
        documentController.text = '';
        statusUpload = '';
        fileInBase64 = '';
        min = 0;
        max = 0;
        numberupload = 0;
      });
    }
  }

  Future<void> backButtonUpload() async {
    setState(() {
      backEnabled = false;
    });

    if (step == 2) {
      Navigator.pop(context);
      return;
    } else if (step == 3) {
      setState(() {
        step--;
        _image = null;
      });
    } else if (step == 4) {
      Navigator.pop(context);
      return;
    }
  }

  void alertDialog(String msg, String type) {
    Icon icon = Icon(Icons.info_outline, color: Colors.lightBlue);
    switch (type) {
      case "Success":
        icon = Icon(Icons.check_circle_outline, color: Colors.lightGreen);
        break;
      case "Error":
        icon = Icon(Icons.error_outline, color: Colors.redAccent);
        break;
      case "Warning":
        icon = Icon(Icons.warning_amber_outlined, color: Colors.orangeAccent);
        break;
      case "Infomation":
        icon = Icon(Icons.info_outline, color: Colors.lightBlue);
        break;
    }

    showDialog(
        context: context,
        builder: (BuildContext builderContext) {
          timer = Timer(Duration(seconds: 5), () {
            Navigator.of(context, rootNavigator: true).pop();
          });

          return AlertDialog(
            title: Row(children: [icon, Text(" " + type)]),
            content: Text(msg),
          );
        }).then((val) {
      if (timer.isActive) {
        timer.cancel();
      }
    });
  }

  void showErrorDialog(String error) {
    //MyWidget.showMyAlertDialog(context, "Error", error);
    alertDialog(error, 'Error');
  }

  void showSuccessDialog(String success) {
    //MyWidget.showMyAlertDialog(context, "Success", success);
    alertDialog(success, 'Success');
  }

  Future<void> openCamera() async {
    setState(() {
      takePhotoEnabled = false;
    });
    if (step == 4) {
      setState(() {
        step = 2;
      });
    }
    if (kIsWeb) {
      //WEB
      final XFile? selectedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2000,
        maxHeight: 2000,
        imageQuality: 30,
      );

      if (selectedImage != null) {
        final encodedBytes = await selectedImage.readAsBytes();
        setState(() {
          _image = File(selectedImage.path);
          fileInBase64 = base64Encode(encodedBytes);
        });
      }
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String showMenu = prefs.getString('showMenu')!;
      // Original = 1[0%] , Low = 0.25[20%] , Medium = 0.21755 [40%] , High = 0.175[60%]
      if (showMenu == 'Original') {
        setState(() {
          scaleImg = 30;
        });
      } else if (showMenu == 'Low') {
        setState(() {
          scaleImg = 15;
        });
      } else if (showMenu == 'Medium') {
        setState(() {
          scaleImg = 20;
        });
      } else if (showMenu == 'High') {
        setState(() {
          scaleImg = 25;
        });
      }

      //open camera device
      PickedFile? selectedImage = await _picker.getImage(
          source: ImageSource.camera,
          imageQuality: scaleImg.toInt(),
          maxHeight: 1920,
          maxWidth: 1080);

      //set image from camera
      File? temp;
      if (selectedImage != null) {
        temp = File(selectedImage.path);
        if (selectedImage.path.isNotEmpty) {
          await showProgressLoading(false);

          setState(() {
            _image = temp;
            final encodedBytes = _image!.readAsBytesSync();
            fileInBase64 = base64Encode(encodedBytes);
          });
        }
        await showProgressLoading(true);
      }
    }

    if (_image != null) {
      setState(() {
        step++;
      });
    }
  }

  Future<void> uploadImage() async {
    setState(() {
      uploadEnabled = false;
    });
    await showProgressLoading(false);
    await getDeviceInfo();
    //await getLocation();
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      configs = prefs.getString('configs')!;
      accessToken = prefs.getString('token')!;

      var url = Uri.parse('https://' +
          configs +
          '/api/Documents/UploadImageWoCheckSheetHeader');

      var headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + accessToken
      };

      late Detail? imageupload = Detail();

      setState(() {
        imageupload.referenceId = woCheckSheetHeaderId;
        imageupload.referenceType = 'C';
        imageupload.imageNo = 0;
        imageupload.imageValue = fileInBase64;
        imageupload.deviceInfo = deviceInfo;
        imageupload.osInfo = osVersion;
      });

      var jsonBody = jsonEncode(imageupload);
      final encoding = Encoding.getByName('utf-8');

      http.Response response = await http.post(
        url,
        headers: headers,
        body: jsonBody,
        encoding: encoding,
      );
      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        Detail result = Detail.fromJson(data);

        setState(() {
          numberupload = result.imageNo!;
        });

        if (numberupload < max && numberupload < min) {
          setState(() {
            documentWillUpload = true;
            documentWillUploadOrWillFinish = false;
            documentWillFinish = false;
            statusUpload = 'รูปภาพเพิ่มเติม : ' +
                numberupload.toString() +
                ' / ' +
                max.toString();
            step = 2;
            _image = null;
          });
        } else if (numberupload < max && numberupload >= min) {
          setState(() {
            documentWillUpload = false;
            documentWillUploadOrWillFinish = true;
            documentWillFinish = false;
            statusUpload = 'รูปภาพเพิ่มเติม : ' +
                numberupload.toString() +
                ' / ' +
                max.toString();
            step = 4;
            _image = null;
          });
        } else if (numberupload >= max) {
          setState(() {
            documentWillUpload = false;
            documentWillUploadOrWillFinish = false;
            documentWillFinish = true;
            statusUpload = 'รูปภาพเพิ่มเติม : ' +
                numberupload.toString() +
                ' / ' +
                max.toString();
            step = 4;
            _image = null;
          });
        }
        await showProgressLoading(true);
      } else if (response.statusCode == 404) {
        int tmp = numberupload + 1;
        setState(() {
          documentWillUpload = false;
          documentWillUploadOrWillFinish = false;
          documentWillFinish = true;
          statusUpload =
              'รูปภาพเพิ่มเติม : ' + tmp.toString() + ' / ' + max.toString();
          step++;
          _image = null;
        });
        await showProgressLoading(true);
      } else {
        await showProgressLoading(true);
        showErrorDialog('uploadImage Error!');
      }
    } catch (e) {
      await showProgressLoading(true);
      showErrorDialog('Error occured while uploadImage');
    }
  }

  Future<void> finish() async {
    setState(() {
      finishEnabled = false;
    });
    await showProgressLoading(false);
    await getDeviceInfo();
    //await getLocation();
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      configs = prefs.getString('configs')!;
      accessToken = prefs.getString('token')!;

      var url = Uri.parse('https://' +
          configs +
          '/api/Documents/CompletedWoCheckSheetHeader?woCheckSheetHeaderId=' +
          woCheckSheetHeaderId.toString() +
          '&inspectionResult=false&isCompleted=true');

      var headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + accessToken
      };

      Map<String, dynamic> body = {
        'woCheckSheetHeaderId': woCheckSheetHeaderId,
        'inspectionResult': false,
        'isCompleted': true
      };
      var jsonBody = json.encode(body);
      final encoding = Encoding.getByName('utf-8');

      http.Response response = await http.post(
        url,
        headers: headers,
        body: jsonBody,
        encoding: encoding,
      );
      //var data = json.decode(response.body);

      if (response.statusCode == 200) {
        await showProgressLoading(true);
        Navigator.pop(context);
        Navigator.pop(context);
        Navigator.pop(context);
        showSuccessDialog('Document is Completed!');
      } else {
        await showProgressLoading(true);
        showErrorDialog('Finish Document Error');
      }
    } catch (e) {
      await showProgressLoading(true);
      showErrorDialog('Error occured while finish');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          leading: BackButton(color: Colors.black),
          backgroundColor: Colors.white,
          title: Text(
            'Take Photo CheckSheet',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.qr_code_scanner_rounded,
                color: Colors.black,
              ),
              onPressed: () {},
            )
          ],
        ),
        body: SafeArea(
            child: Container(
                child: SingleChildScrollView(
                    child: Column(children: [
          SizedBox(height: 28),
          Container(
              padding: new EdgeInsets.only(
                  left: MediaQuery.of(context).size.width / 5,
                  right: MediaQuery.of(context).size.width / 5),
              child: Visibility(
                  visible: documentVisible,
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    readOnly: documentReadonly,
                    textInputAction: TextInputAction.go,
                    onFieldSubmitted: (value) async {},
                    decoration: InputDecoration(
                      //icon: const Icon(Icons.person),
                      fillColor: documentColor,
                      filled: true,
                      hintText: 'Enter Data',
                      labelText: 'Ticket Number',
                      border: OutlineInputBorder(),
                      isDense: true, // Added this
                      contentPadding: EdgeInsets.all(13.5), //
                    ),
                    controller: documentController,
                  ))),
          SizedBox(
            height: 12,
          ),
          Visibility(
              visible: buttonUploadVisible,
              child: new Center(
                child: new ButtonBar(
                  mainAxisSize: MainAxisSize
                      .min, // this will take space as minimum as posible(to center)
                  children: <Widget>[
                    SizedBox(
                        width: 63, // specific value
                        child: new ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue),
                          child: const Text('Back',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12.3)),
                          onPressed: backEnabled
                              ? () async {
                                  await backButtonUpload();
                                  setVisible();
                                  setReadOnly();
                                  setColor();
                                  setText();
                                }
                              : null,
                        )),
                    SizedBox(
                        width: 58, // specific value
                        child: new ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                step == 2 ? Colors.green : Colors.blue,
                          ),
                          child: Column(
                            children: <Widget>[
                              Icon(Icons.add_a_photo_outlined)
                            ],
                          ),
                          onPressed: takePhotoEnabled
                              ? () async {
                                  await openCamera();
                                  setVisible();
                                  setReadOnly();
                                  setColor();
                                  setText();
                                }
                              : null,
                        )),
                    SizedBox(
                        width: 58, // specific value
                        child: new ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                step == 3 ? Colors.green : Colors.blue,
                          ),
                          child: Column(
                            children: <Widget>[Icon(Icons.upload_file)],
                          ),
                          onPressed: uploadEnabled
                              ? () async {
                                  await uploadImage();
                                  setVisible();
                                  setReadOnly();
                                  setColor();
                                  setText();
                                }
                              : null,
                        )),
                    SizedBox(
                        width: 58, // specific value
                        child: new ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                step == 4 ? Colors.green : Colors.blue,
                          ),
                          child: const Text('Finish',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12.3)),
                          onPressed: finishEnabled
                              ? () async {
                                  await finish();
                                  setVisible();
                                  setReadOnly();
                                  setColor();
                                  setText();
                                }
                              : null,
                        )),
                  ],
                ),
              )),
          Visibility(
              visible: buttonUploadVisible,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Center(
                      child: _image != null
                          ? Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Container(
                                width: 225,
                                height: 225,
                                child: kIsWeb
                                    ? Image.network(_image!.path)
                                    : Image.file(
                                        _image!,
                                      ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(18.0),
                              child: Text(statusUpload),
                            ),
                    )
                  ])),
        ])))));
  }
}
