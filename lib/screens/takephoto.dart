import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hmc_iload/class/listdo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_session/flutter_session.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:image/image.dart' as img;
import 'package:location/location.dart';
import 'package:hmc_iload/class/checksheetDocResult.dart';
import 'package:hmc_iload/class/getItemWoImageDetailNotFound.dart';
import 'package:hmc_iload/class/itemWoImageDetail.dart';
import 'package:hmc_iload/class/listLoadTypeMenu.dart';
import 'package:hmc_iload/class/postImage.dart';
import 'package:hmc_iload/class/postImageResult.dart';
import 'package:hmc_iload/class/ptDocumentIDCheckResult.dart';
import 'package:hmc_iload/components/menu_list.dart';
import 'package:hmc_iload/components/menu_list2.dart';
import 'package:flutter/foundation.dart';

class Takephoto extends StatefulWidget {
  @override
  _TakephotoState createState() => _TakephotoState();
}

class _TakephotoState extends State<Takephoto> {
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
  late List<ImageSubWorkTypeMenu> listImageSubWorkTypeMenu = [];
  late List<LoadTypeMenu> listLoadTypeMenu = [];
  late List<WoImageHeaderListModel> listWoImageList = [];
  bool createEnabled = false;
  bool listVisible = false;
  bool listVisible2 = false;
  bool backMenuVisible = false;
  bool backEnabledMenu = false;
  late PTDocumentIDCheckResult result = PTDocumentIDCheckResult();
  String header1 = 'Header1';
  String header2 = 'Header2';
  String header3 = 'Header3';
  bool header1Visible = false;
  bool header2Visible = false;
  bool header3Visible = false;

  bool backEnabled = false;
  bool takePhotoEnabled = false;
  bool uploadEnabled = false;
  bool nextEnabled = false;
  bool finishEnabled = false;
  bool documentWillUpload = false;
  bool documentWillUploadOrWillFinish = false;
  bool documentWillFinish = false;
  bool advsaleWoImageVisible = false;

  late File? _image = null;
  final ImagePicker _picker = ImagePicker();
  String statusUpload = '';
  String fileInBase64 = '';
  bool buttonUploadVisible = false;

  int seqence = 0;
  String name = '';
  int min = 0;
  int max = 0;
  int numberupload = 0;
  double scaleImg = 0;

  late List<FocusNode> focusNodes = List.generate(1, (index) => FocusNode());
  bool haveImageSubWorkType = false;

  List<ListDo> listDO = [];
  String tmpTicketNo = '';

  @override
  void initState() {
    super.initState();
    //getLocation();
    getDeviceInfo();
    setState(() {
      step = 1;
      listImageSubWorkTypeMenu.clear();
      listLoadTypeMenu.clear();
      listWoImageList.clear();
    });
    setVisible();
    setReadOnly();
    setColor();
    setText();
    setFocus();
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
        header1Visible = false;
        header2Visible = false;
        listVisible = false;
        listVisible2 = false;
        backMenuVisible = false;
        buttonUploadVisible = false;
        advsaleWoImageVisible = false;
        createEnabled = false;
      });
    } else if (step == 2) {
      setState(() {
        documentVisible = true;
        header1Visible = false;
        header2Visible = false;
        listVisible = false;
        listVisible2 = false;
        advsaleWoImageVisible = true;
        createEnabled = true;
        buttonUploadVisible = false;
      });
    } else if (step == 3) {
      setState(() {
        documentVisible = true;
        header1Visible = true;
        header2Visible = false;
        listVisible = true;
        listVisible2 = false;
        backMenuVisible = true;
        buttonUploadVisible = false;
        advsaleWoImageVisible = false;
        createEnabled = false;
      });
    } else if (step == 4) {
      setState(() {
        documentVisible = true;
        header1Visible = true;
        header2Visible = true;

        listVisible = false;
        listVisible2 = true;
        backMenuVisible = true;
        buttonUploadVisible = false;
        advsaleWoImageVisible = false;
        createEnabled = false;
      });
    } else if (step == 5 || step == 6 || step == 7 || step == 8) {
      setState(() {
        documentVisible = true;
        header1Visible = true;
        header2Visible = true;
        header3Visible = true;

        listVisible = false;
        listVisible2 = false;
        backMenuVisible = false;
        buttonUploadVisible = true;
        advsaleWoImageVisible = false;
        createEnabled = false;
      });
    }
  }

  void setReadOnly() {
    if (step == 1) {
      setState(() {
        haveImageSubWorkType = false;
        documentReadonly = false;
        backEnabled = false;
        takePhotoEnabled = false;
        uploadEnabled = false;
        nextEnabled = false;
        finishEnabled = false;
        documentWillUpload = false;
        documentWillUploadOrWillFinish = false;
        documentWillFinish = false;
      });
    } else if (step == 2) {
      setState(() {
        documentReadonly = true;
        backEnabled = false;
        takePhotoEnabled = false;
        uploadEnabled = false;
        nextEnabled = false;
        finishEnabled = false;
        documentWillUpload = false;
        documentWillUploadOrWillFinish = false;
        documentWillFinish = false;
      });
    } else if (step == 3) {
      setState(() {
        documentReadonly = true;
        backEnabled = false;
        takePhotoEnabled = false;
        uploadEnabled = false;
        nextEnabled = false;
        finishEnabled = false;
        documentWillUpload = false;
        documentWillUploadOrWillFinish = false;
        documentWillFinish = false;
      });
    } else if (step == 4) {
      setState(() {
        documentReadonly = true;
        backEnabled = false;
        takePhotoEnabled = false;
        uploadEnabled = false;
        nextEnabled = false;
        finishEnabled = false;
        documentWillUpload = false;
        documentWillUploadOrWillFinish = false;
        documentWillFinish = false;
      });
    } else if (step == 5) {
      if (documentWillUpload) {
        setState(() {
          documentReadonly = true;
          backEnabled = true;
          takePhotoEnabled = true;
          uploadEnabled = false;
          nextEnabled = false;
          finishEnabled = false;
        });
      } else if (documentWillUploadOrWillFinish) {
        setState(() {
          documentReadonly = true;
          backEnabled = true;
          takePhotoEnabled = true;
          uploadEnabled = false;
          nextEnabled = true;
          finishEnabled = false;
        });
      } else if (documentWillFinish) {
        setState(() {
          documentReadonly = true;
          backEnabled = true;
          takePhotoEnabled = false;
          uploadEnabled = false;
          nextEnabled = true;
          finishEnabled = false;
        });
      }
    } else if (step == 6) {
      setState(() {
        documentReadonly = true;
        backEnabled = true;
        takePhotoEnabled = false;
        uploadEnabled = true;
        nextEnabled = false;
        finishEnabled = false;
      });
    } else if (step == 7) {
      if (documentWillUpload) {
        setState(() {
          documentReadonly = true;
          backEnabled = true;
          takePhotoEnabled = true;
          uploadEnabled = false;
          nextEnabled = false;
          finishEnabled = false;
        });
      } else if (documentWillUploadOrWillFinish) {
        setState(() {
          documentReadonly = true;
          backEnabled = true;
          takePhotoEnabled = true;
          uploadEnabled = false;
          nextEnabled = true;
          finishEnabled = false;
        });
      } else if (documentWillFinish) {
        setState(() {
          documentReadonly = true;
          backEnabled = true;
          takePhotoEnabled = false;
          uploadEnabled = false;
          nextEnabled = true;
          finishEnabled = false;
        });
      }
    } else if (step == 8) {
      setState(() {
        documentReadonly = true;
        backEnabled = true;
        takePhotoEnabled = false;
        uploadEnabled = false;
        nextEnabled = false;
        finishEnabled = true;
      });
    }
  }

  void setColor() {
    if (step == 1) {
      setState(() {
        documentColor = Color(0xFFFFFFFF);
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
        header1 = '';
        header2 = '';
        header3 = '';
        statusUpload = '';
        fileInBase64 = '';
        seqence = 0;
        name = '';
        min = 0;
        max = 0;
        numberupload = 0;
      });
    }
    if (step > 1) {
      setState(() {
        documentController.text = tmpTicketNo;
      });
    }
  }

  void setFocus() {
    if (step == 1) {
      Future.delayed(Duration(milliseconds: 100))
          .then((_) => FocusScope.of(context).requestFocus(focusNodes[0]));
    }
  }

  Future<void> backMenu() async {
    if (step == 3) {
      setState(() {
        step = 1;
      });
    } else if (step == 4) {
      if (haveImageSubWorkType) {
        setState(() {
          step = 1;
        });
        //await documentIDCheck();
      } else {
        setState(() {
          step--;
        });
        await documentIDCheck();
      }
    }
  }

  Future<void> backButtonUpload() async {
    setState(() {
      backEnabled = false;
    });
    if (step == 5 || step == 7 || step == 8) {
      setState(() {
        step = 1;
        _image = null;
        listImageSubWorkTypeMenu.clear();
        listLoadTypeMenu.clear();
      });
    } else if (step == 6) {
      setState(() {
        step--;
        _image = null;
        listImageSubWorkTypeMenu.clear();
        listLoadTypeMenu.clear();
      });
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

  Future<void> setPrefsDocumentId(int documentId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('documentId', documentId);
  }

  Future<void> setPrefsWorkTypeId(int loadTypeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('workTypeId', loadTypeId);
  }

  Future<void> setPrefsWorkTypeName(String loadTypeName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('workTypeName', loadTypeName);
  }

  Future<void> setPrefsImageSubWorkTypeId(int imageSubWorkTypeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('imageSubWorkTypeId', imageSubWorkTypeId);
  }

  Future<void> setPrefsImageSubWorkTypeName(String imageSubWorkTypeName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('imageSubWorkTypeName', imageSubWorkTypeName);
  }

  Future<void> setPrefsLoadTypeId(int loadTypeId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('loadTypeId', loadTypeId);
  }

  Future<void> setPrefsLoadTypeName(String loadTypeName) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('loadTypeName', loadTypeName);
  }

  Future<void> setPrefsWoImageHeaderId(int woImageHeaderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('woImageHeaderId', woImageHeaderId);
  }

  Future<void> setPrefsAdvsaleWoImageHeaderId(int woImageHeaderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('advSalewoImageHeaderId', woImageHeaderId);
  }

  Future<void> setPrefsWoImageDetailId(int woImageDetailId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('woImageDetailId', woImageDetailId);
  }

  Future<void> setPrefsCreateAdvSale(String advSale) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('advSale', advSale);
  }

  Future<void> scanQR() async {
    if (step == 1) {
      String barcodeScanRes;
      try {
        barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
            '#ff6666', 'Cancel', true, ScanMode.QR);
      } on PlatformException {
        barcodeScanRes = 'Failed to get platform version.';
      }

      if (barcodeScanRes == '-1') {
        return;
      }

      setState(() {
        documentController.text = barcodeScanRes;
      });
      await getDataDO();
      setVisible();
      setReadOnly();
      setColor();
      setText();
      setFocus();
    } else {
      return;
    }
  }

  DataTable _createDataTable() {
    return DataTable(
        headingRowColor: MaterialStateColor.resolveWith(
          (states) => Colors.grey[200]!,
        ),
        columnSpacing: 5,
        //border: TableBorder.all(width: 1),
        columns: _createColumns(),
        rows: _createRows());
  }

  List<DataColumn> _createColumns() {
    return [
      DataColumn(
          label: Expanded(
              child: (Text('DO No.',
                  softWrap: true,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black))))),
      DataColumn(
          label: Expanded(
              child: (Text('WH',
                  softWrap: true,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black))))),
      DataColumn(
          label: Expanded(
              child: Text('Select',
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)))),
    ];
  }

  List<DataRow> _createRows() {
    return listDO
        .map((listDO) => DataRow(
                color: MaterialStateColor.resolveWith((states) {
                  return Colors.transparent; //make tha magic!
                }),
                cells: [
                  DataCell(Container(
                      width: 70, //SET width
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            listDO.doNumber.toString(),
                            textAlign: TextAlign.start,
                          )))),
                  DataCell(Container(
                      width: 60, //SET width
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            listDO.wareHouse.toString(),
                            textAlign: TextAlign.start,
                          )))),
                  DataCell(Align(
                      alignment: Alignment.center,
                      child: new SizedBox(
                        width: 50.0,
                        height: 30.0,
                        child: ElevatedButton(
                          onPressed: () async {
                            Navigator.of(context, rootNavigator: true).pop();
                            await showProgressLoading(false);
                            await setPrefsDocumentId(listDO.documentId!);
                            await documentIDCheck();
                            setVisible();
                            setReadOnly();
                            setColor();
                            setText();
                            setFocus();
                          },
                          child: Icon(Icons.assignment),
                          style: ButtonStyle(
                            minimumSize: MaterialStateProperty.all<Size>(
                                Size(50, 50)), //////// HERE
                            backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.lightBlue),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                      ))),
                ]))
        .toList();
  }

  void showDialogDO() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          //title: Text('Select DO'),
          content: SingleChildScrollView(
            child: Container(
              width: double.infinity,
              child: Container(
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.black)),
                //height: MediaQuery.of(context).size.height / 2.4,
                //width: MediaQuery.of(context).size.width / 1.5,
                child: SingleChildScrollView(
                    child: Column(children: [
                  _createDataTable(),
                ])),
              ),
            ),
          ),
        );
      },
    );
    return;
  }

  Future<void> getDataDO() async {
    await showProgressLoading(false);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      configs = prefs.getString('configs')!;
      accessToken = prefs.getString('token')!;
      setState(() {
        listImageSubWorkTypeMenu.clear();
        tmpTicketNo = documentController.text.toString();
      });

      var url = Uri.parse('https://' +
          configs +
          '/api/Documents/ValidateDocumentNoList/' +
          documentController.text.toString());

      var headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + accessToken
      };

      http.Response response = await http.get(url, headers: headers);
      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        var datalist =
            List<ListDo>.from(data.map((model) => ListDo.fromJson(model)));

        setState(() {
          listDO = datalist;
        });

        if (listDO.length == 1) {
          //await showProgressLoading(true);
          await setPrefsDocumentId(listDO[0].documentId!);
          await documentIDCheck();
        } else if (listDO.length > 1) {
          await showProgressLoading(true);
          showDialogDO();
        }
      } else {
        await showProgressLoading(true);
        showErrorDialog(data.toString());
      }
    } catch (e) {
      await showProgressLoading(true);
      showErrorDialog('Error occured while getDataDO');
    }
  }

  Future<void> documentIDCheck() async {
    //await showProgressLoading(false);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      configs = prefs.getString('configs')!;
      accessToken = prefs.getString('token')!;
      setState(() {
        listImageSubWorkTypeMenu.clear();
      });

      int? docIDtmp = prefs.getInt('documentId');

      var url = Uri.parse('https://' +
          configs +
          '/api/Documents/ValidateDocument/' +
          docIDtmp.toString());

      var headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + accessToken
      };

      http.Response response = await http.get(url, headers: headers);
      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        late PTDocumentIDCheckResult result;
        setState(() {
          result = PTDocumentIDCheckResult.fromJson(data);
        });

        //getHeader1
        setState(() {
          String temp = result.workTypeName.toString();
          header1 = 'WorkType : $temp';
        });

        //getListImageSubWorkTypeMenu
        for (int i = 0; i < result.data!.length; i++) {
          late ImageSubWorkTypeMenu temp;
          setState(() {
            temp = result.data![i];
            listImageSubWorkTypeMenu.add(temp);
          });
        }

        //check subworktype
        if (result.imageSubWorkTypeId != null) {
          int index = 0;

          for (int i = 0; i < listImageSubWorkTypeMenu.length; i++) {
            if (listImageSubWorkTypeMenu[i].imageSubWorkTypeId ==
                result.imageSubWorkTypeId) {
              index = i;
            }
          }
          setState(() {
            //getHeader2
            String temp = listImageSubWorkTypeMenu[index]
                .menuWorkTypeNameMobile
                .toString();
            header2 = 'SubWorkType : $temp';
            step = 4;
            haveImageSubWorkType = true;
          });

          //getListAdvsalDoc
          if (result.woImageHeaderListModel!.length > 0) {
            listWoImageList.clear();
            for (int i = 0; i < result.woImageHeaderListModel!.length; i++) {
              late WoImageHeaderListModel temp;
              setState(() {
                temp = result.woImageHeaderListModel![i];
                listWoImageList.add(temp);
              });
            }
            setState(() {
              step = 2;
            });
          }

          await setPrefsImageSubWorkTypeId(
              listImageSubWorkTypeMenu[index].imageSubWorkTypeId!);
          await setPrefsImageSubWorkTypeName(
              listImageSubWorkTypeMenu[index].menuWorkTypeNameMobile!);
          await setPrefsDocumentId(result.documentId!);
          await setPrefsWorkTypeId(result.workTypeId!);
          await setPrefsWorkTypeName(result.workTypeName!);
          await getLoadTypeMenu();
          await showProgressLoading(true);
        } else {
          if (step == 1) {
            setState(() {
              step = 3;
            });
          }
          await setPrefsDocumentId(result.documentId!);
          await setPrefsWorkTypeId(result.workTypeId!);
          await setPrefsWorkTypeName(result.workTypeName!);
          await showProgressLoading(true);
        }
      } else {
        await showProgressLoading(true);
        showErrorDialog(data.toString());
      }
    } catch (e) {
      await showProgressLoading(true);
      showErrorDialog('Error occured while documentIDCheck');
    }
  }

  Future<void> getLoadTypeMenu() async {
    await showProgressLoading(false);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int documentIdTemp = prefs.getInt('documentId')!;
      int imageSubWorkTypeIdTemp = prefs.getInt('imageSubWorkTypeId')!;
      configs = prefs.getString('configs')!;
      accessToken = prefs.getString('token')!;
      setState(() {
        listLoadTypeMenu.clear();
      });

      var url = Uri.parse('https://' +
          configs +
          '/api/Documents/GetLoadTypeMenu/' +
          imageSubWorkTypeIdTemp.toString());

      var headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + accessToken
      };

      http.Response response = await http.get(url, headers: headers);
      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        late ListLoadTypeMenu result;
        setState(() {
          result = ListLoadTypeMenu.fromJson(data);
        });

        //getListLoadTypeMenu
        for (int i = 0; i < result.data!.length; i++) {
          late LoadTypeMenu temp;
          setState(() {
            temp = result.data![i];
            listLoadTypeMenu.add(temp);
          });
        }
        await showProgressLoading(true);
      } else {
        await showProgressLoading(true);
        showErrorDialog('LoadTypeMenu Not Found!');
      }
    } catch (e) {
      await showProgressLoading(true);
      showErrorDialog('Error occured while getLoadTypeMenu');
    }
  }

  Future<void> getItemWoImageDetail() async {
    await showProgressLoading(false);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int documentIdTemp = prefs.getInt('documentId')!;
      int imageSubWorkTypeIdTemp = prefs.getInt('imageSubWorkTypeId')!;
      int workTypeIdTemp = prefs.getInt('workTypeId')!;
      int loadIdTemp = prefs.getInt('loadTypeId')!;
      String? advSaleTemp = prefs.getString('advSale');
      int? woImageHeaderIdTempAdvsale = prefs.getInt('advSalewoImageHeaderId');
      advSaleTemp = advSaleTemp == null ? "false" : advSaleTemp;
      if (advSaleTemp == "true") {
        woImageHeaderIdTempAdvsale = null;
      }
      configs = prefs.getString('configs')!;
      accessToken = prefs.getString('token')!;
      setState(() {
        listLoadTypeMenu.clear();
      });
      String documentIdTempStr = documentIdTemp.toString();
      String imageSubWorkTypeIdTempStr = imageSubWorkTypeIdTemp.toString();
      String workTypeIdTempStr = workTypeIdTemp.toString();
      String loadIdTempStr = loadIdTemp.toString();

      var strWoImage = woImageHeaderIdTempAdvsale == null
          ? ""
          : "&woImageHeaderId=" + woImageHeaderIdTempAdvsale.toString();

      var url = Uri.parse('https://' +
          configs +
          '/api/Documents/GetItemWoImageDetail?documentId=' +
          documentIdTempStr +
          '&workTypeId=' +
          workTypeIdTempStr +
          '&imageSubWorkTypeId=' +
          imageSubWorkTypeIdTempStr +
          '&loadTypeId=' +
          loadIdTempStr +
          '&advsaleCreate=' +
          advSaleTemp +
          strWoImage);

      var headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + accessToken
      };

      http.Response response = await http.get(url, headers: headers);
      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        var datalist = List<ItemWoImageDetail>.from(
            data.map((model) => ItemWoImageDetail.fromJson(model)));
        late ItemWoImageDetail result;
        result = datalist[0];

        setState(() {
          min = result.min!;
          max = result.max!;
          numberupload = result.numberUpload!;
        });

        if (numberupload < max && numberupload < min) {
          setState(() {
            documentWillUpload = true;
            documentWillUploadOrWillFinish = false;
            documentWillFinish = false;
            seqence = result.sequence!;
            name = result.name!;
            statusUpload = seqence.toString() +
                '. ' +
                name +
                ' : ' +
                numberupload.toString() +
                ' / ' +
                max.toString();
            step = 5;
          });
        } else if (numberupload < max && numberupload >= min) {
          setState(() {
            documentWillUpload = false;
            documentWillUploadOrWillFinish = true;
            documentWillFinish = false;
            seqence = result.sequence!;
            name = result.name!;
            statusUpload = seqence.toString() +
                '. ' +
                name +
                ' : ' +
                numberupload.toString() +
                ' / ' +
                max.toString();
            step = 7;
          });
        } else if (numberupload >= max) {
          setState(() {
            documentWillUpload = false;
            documentWillUploadOrWillFinish = false;
            documentWillFinish = true;
            seqence = result.sequence!;
            name = result.name!;
            statusUpload = seqence.toString() +
                '. ' +
                name +
                ' : ' +
                numberupload.toString() +
                ' / ' +
                max.toString();
            step = 7;
          });
        }

        await setPrefsWoImageHeaderId(result.woImageHeaderId!);
        await setPrefsWoImageDetailId(result.woImageDetailId!);
        await showProgressLoading(true);
      } else if (response.statusCode == 404) {
        late GetItemWoImageDetailNotFound result;
        setState(() {
          result = GetItemWoImageDetailNotFound.fromJson(data);
        });

        if (result.data!.length > 0) {
          int headertmp = result.woImageHeaderId!;
          setState(() {
            step = 8;
            _image = null;
            String tmp = result.data.toString();

            String tmp1 = tmp.replaceAll('[', ' ');
            String tmp2 = tmp1.replaceAll(']', '');
            var splitted = tmp2.split(',');
            statusUpload = '';

            for (int i = 0; i < splitted.length; i++) {
              setState(() {
                statusUpload =
                    statusUpload + splitted[i].toString() + '\n' + '\n';
              });
            }
          });
          await setPrefsWoImageHeaderId(headertmp);
          await showProgressLoading(true);
        } else {
          setState(() {
            step--;
          });
          await getLoadTypeMenu();
          setState(() {
            header3 = '';
            listVisible2 = false;
          });
          await showProgressLoading(true);
          showSuccessDialog('LoadType Completed!');
        }
      } else {
        await showProgressLoading(true);
        showErrorDialog('ItemWoImageDetail Not Found!');
      }
    } catch (e) {
      await showProgressLoading(true);
      showErrorDialog('Error occured while getItemWoImageDetail');
    }
  }

  Future<void> openCamera() async {
    setState(() {
      takePhotoEnabled = false;
    });
    if (step == 7) {
      setState(() {
        step = 5;
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
      int woImageDetailIdTemp = prefs.getInt('woImageDetailId')!;
      configs = prefs.getString('configs')!;
      accessToken = prefs.getString('token')!;
      setState(() {
        listLoadTypeMenu.clear();
      });

      var url = Uri.parse(
          'https://' + configs + '/api/Documents/UploadImageWoImageDetail');

      var headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + accessToken
      };

      late PostImage? imageupload = new PostImage();

      setState(() {
        imageupload.woImageDetailId = woImageDetailIdTemp;
        imageupload.type = 'P';
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
        PostImageResult result = PostImageResult.fromJson(data);

        setState(() {
          min = result.min!;
          max = result.max!;
          numberupload = result.numberUpload!;
        });

        if (numberupload < max && numberupload < min) {
          setState(() {
            documentWillUpload = true;
            documentWillUploadOrWillFinish = false;
            documentWillFinish = false;
            seqence = result.sequence!;
            name = result.name!;
            statusUpload = seqence.toString() +
                '. ' +
                name +
                ' : ' +
                numberupload.toString() +
                ' / ' +
                max.toString();
            step--;
            _image = null;
          });
        } else if (numberupload < max && numberupload >= min) {
          setState(() {
            documentWillUpload = false;
            documentWillUploadOrWillFinish = true;
            documentWillFinish = false;
            seqence = result.sequence!;
            name = result.name!;
            statusUpload = seqence.toString() +
                '. ' +
                name +
                ' : ' +
                numberupload.toString() +
                ' / ' +
                max.toString();
            step++;
            _image = null;
          });
        } else if (numberupload >= max) {
          setState(() {
            documentWillUpload = false;
            documentWillUploadOrWillFinish = false;
            documentWillFinish = true;
            seqence = result.sequence!;
            name = result.name!;
            statusUpload = seqence.toString() +
                '. ' +
                name +
                ' : ' +
                numberupload.toString() +
                ' / ' +
                max.toString();
            step++;
            _image = null;
          });
        }

        await setPrefsWoImageHeaderId(result.woImageHeaderId!);
        await setPrefsWoImageDetailId(result.woImageDetailId!);
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

  Future<void> next() async {
    setState(() {
      nextEnabled = false;
    });
    await showProgressLoading(false);

    await getDeviceInfo();

    //await getLocation();
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int woImageHeaderIdTemp = prefs.getInt('woImageHeaderId')!;
      int woImageDetailIdTemp = prefs.getInt('woImageDetailId')!;
      configs = prefs.getString('configs')!;
      accessToken = prefs.getString('token')!;
      setState(() {
        listLoadTypeMenu.clear();
      });

      var url = Uri.parse('https://' +
          configs +
          '/api/Documents/CompletedWoImageDetail?woImageHeaderId=' +
          woImageHeaderIdTemp.toString() +
          '&woImageDetailId=' +
          woImageDetailIdTemp.toString());

      var headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + accessToken
      };

      Map<String, dynamic> body = {
        'woImageHeaderId': woImageHeaderIdTemp,
        'woImageDetailIdTemp': woImageDetailIdTemp
      };
      var jsonBody = json.encode(body);
      final encoding = Encoding.getByName('utf-8');

      http.Response response = await http.post(
        url,
        headers: headers,
        body: jsonBody,
        encoding: encoding,
      );
      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        PostImageResult result = PostImageResult.fromJson(data);

        setState(() {
          min = result.min!;
          max = result.max!;
          numberupload = result.numberUpload!;
        });

        if (numberupload < max && numberupload < min) {
          setState(() {
            documentWillUpload = true;
            documentWillUploadOrWillFinish = false;
            documentWillFinish = false;
            seqence = result.sequence!;
            name = result.name!;
            statusUpload = seqence.toString() +
                '. ' +
                name +
                ' : ' +
                numberupload.toString() +
                ' / ' +
                max.toString();
            step--;
            step--;
            _image = null;
            //print(step);
          });
        } else if (numberupload < max && numberupload >= min) {
          setState(() {
            documentWillUpload = false;
            documentWillUploadOrWillFinish = true;
            documentWillFinish = false;
            seqence = result.sequence!;
            name = result.name!;
            statusUpload = seqence.toString() +
                '. ' +
                name +
                ' : ' +
                numberupload.toString() +
                ' / ' +
                max.toString();
            //step++;
            _image = null;
            //print(step);
          });
        } else if (numberupload >= max) {
          setState(() {
            documentWillUpload = false;
            documentWillUploadOrWillFinish = false;
            documentWillFinish = true;
            seqence = result.sequence!;
            name = result.name!;
            statusUpload = seqence.toString() +
                '. ' +
                name +
                ' : ' +
                numberupload.toString() +
                ' / ' +
                max.toString();
            step++;
            _image = null;
            //print(step);
          });
        }

        await setPrefsWoImageHeaderId(result.woImageHeaderId!);
        await setPrefsWoImageDetailId(result.woImageDetailId!);
        await showProgressLoading(true);
      } else if (response.statusCode == 404) {
        setState(() {
          step++;
          _image = null;
          String tmp = data.toString();
          String tmp1 = tmp.replaceAll('[', ' ');
          String tmp2 = tmp1.replaceAll(']', '');
          var splitted = tmp2.split(',');
          statusUpload = '';

          for (int i = 0; i < splitted.length; i++) {
            setState(() {
              statusUpload =
                  statusUpload + splitted[i].toString() + '\n' + '\n';
            });
          }
        });
        await showProgressLoading(true);
      } else {
        await showProgressLoading(true);
        showErrorDialog('Next Sequence Error!');
      }
    } catch (e) {
      await showProgressLoading(true);
      showErrorDialog('Error occured while next');
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
      int woImageHeaderIdTemp = prefs.getInt('woImageHeaderId')!;
      int woImageDetailIdTemp = prefs.getInt('woImageDetailId')!;
      configs = prefs.getString('configs')!;
      accessToken = prefs.getString('token')!;
      setState(() {
        listLoadTypeMenu.clear();
      });

      var url = Uri.parse('https://' +
          configs +
          '/api/Documents/CompletedWoImageHeader?woImageHeaderId=' +
          woImageHeaderIdTemp.toString());

      var headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + accessToken
      };

      Map<String, dynamic> body = {'woImageHeaderId': woImageHeaderIdTemp};
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
        setState(() {
          step = 4;
        });
        await getLoadTypeMenu();
        setState(() {
          header3 = '';
          listVisible2 = false;
        });
        await showProgressLoading(true);
        showSuccessDialog('Document Completed');
      } else {
        await showProgressLoading(true);
        showErrorDialog('Finish Document Error');
      }
    } catch (e) {
      await showProgressLoading(true);
      showErrorDialog('Error occured while finish');
    }
  }

  Future<void> setAdvSale(String advSaleCreate, int? woImageHeaderId) async {
    setState(() {
      setPrefsCreateAdvSale(advSaleCreate);
      if (woImageHeaderId != null) {
        setPrefsAdvsaleWoImageHeaderId(woImageHeaderId.toInt());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          leading: BackButton(color: Colors.black),
          backgroundColor: Colors.white,
          title: Text(
            'Take Photo',
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
                onPressed: scanQR)
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
                    //keyboardType: TextInputType.number,
                    focusNode: focusNodes[0],
                    readOnly: documentReadonly,
                    textInputAction: TextInputAction.go,
                    onFieldSubmitted: (value) async {
                      await getDataDO();
                      setVisible();
                      setReadOnly();
                      setColor();
                      setText();
                      setFocus();
                    },
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
          Visibility(
            visible: advsaleWoImageVisible,
            child: Container(
              child: SingleChildScrollView(
                  child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(15),
                      child: Text(
                        "Take Photo History",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                    Center(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: listWoImageList.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: CircleAvatar(
                              child: ImageIcon(
                                AssetImage('assets/checksheet.png'),
                                size: 25,
                                color: Colors.blue,
                              ),
                              backgroundColor: Colors.transparent,
                            ),
                            onTap: () async {
                              step = 4;
                              await getLoadTypeMenu();
                              setAdvSale('false',
                                  listWoImageList[index].woImageHeaderId);
                              setVisible();
                              setReadOnly();
                              setColor();
                              setText();
                              setFocus();
                            },
                            title: Text(documentController.text),
                            subtitle:
                                Text(listWoImageList[index].sloc.toString()),
                            trailing: Text(DateFormat.jm().format(
                                DateTime.parse(listWoImageList[index]
                                    .createdOn
                                    .toString()))),
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      child: const Text('Create',
                          style:
                              TextStyle(color: Colors.white, fontSize: 12.3)),
                      onPressed: createEnabled
                          ? () async {
                              step = 4;
                              await getLoadTypeMenu();
                              setAdvSale("true", null);
                              setVisible();
                              setReadOnly();
                              setColor();
                              setText();
                              setFocus();
                            }
                          : null,
                    ),
                  ],
                ),
              )),
            ),
          ),
          SizedBox(
            height: 12,
          ),
          Visibility(
              visible: header1Visible,
              child: Container(
                //width: 300,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  header1,
                  style: TextStyle(fontSize: 13),
                  textAlign: TextAlign.left,
                ),
              )),
          Visibility(
              visible: header2Visible,
              child: Container(
                //width: 300,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  header2,
                  style: TextStyle(fontSize: 13),
                  textAlign: TextAlign.left,
                ),
              )),
          Visibility(
              visible: header3Visible,
              child: Container(
                //width: 300,
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  header3,
                  style: TextStyle(fontSize: 13),
                  textAlign: TextAlign.left,
                ),
              )),
          Visibility(
              visible: listVisible,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _showLists(context),
                  ],
                ),
              )),
          Visibility(
              visible: listVisible2,
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _showLists2(context),
                  ],
                ),
              )),
          Visibility(
              visible: backMenuVisible,
              child: new Center(
                child: new ButtonBar(
                  mainAxisSize: MainAxisSize
                      .min, // this will take space as minimum as posible(to center)
                  children: <Widget>[
                    new ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text('Back',
                          style: TextStyle(
                            color: Colors.white,
                          )),
                      onPressed: true
                          ? () async {
                              await backMenu();
                              setVisible();
                              setReadOnly();
                              setColor();
                              setText();
                              setFocus();

                              if (step == 1) {
                                setState(() {
                                  listImageSubWorkTypeMenu.clear();
                                });
                              } else if (step == 3) {
                                setState(() {
                                  listLoadTypeMenu.clear();
                                });
                              }
                            }
                          : null,
                    ),
                  ],
                ),
              )),
          //SizedBox(height: 10),
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
                                  setFocus();
                                }
                              : null,
                        )),
                    SizedBox(
                        width: 58, // specific value
                        child: new ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                step == 5 ? Colors.green : Colors.blue,
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
                                  setFocus();
                                  print('---Finish Preview Image---');
                                  print(DateTime.now());
                                  print('-------');
                                }
                              : null,
                        )),
                    SizedBox(
                        width: 58, // specific value
                        child: new ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                step == 6 ? Colors.green : Colors.blue,
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
                                  setFocus();
                                  print(
                                      '---Finish Call Function uploadImage---');
                                  print(DateTime.now());
                                  print('-------');
                                }
                              : null,
                        )),
                    SizedBox(
                        width: 58, // specific value
                        child: new ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                step == 7 ? Colors.green : Colors.blue,
                          ),
                          child: const Text('Next',
                              style: TextStyle(
                                  color: Colors.white, fontSize: 12.3)),
                          onPressed: nextEnabled
                              ? () async {
                                  await next();
                                  setVisible();
                                  setReadOnly();
                                  setColor();
                                  setText();
                                  setFocus();
                                }
                              : null,
                        )),
                    SizedBox(
                        width: 58, // specific value
                        child: new ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                step == 8 ? Colors.green : Colors.blue,
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
                                  setFocus();
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

  Widget _showLists(BuildContext context) {
    return Visibility(
        visible: listVisible,
        child: SingleChildScrollView(
          child: Column(children: <Widget>[
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                int temp = index + 1;
                return MenuList2(
                  text: listImageSubWorkTypeMenu[index]
                      .menuWorkTypeNameMobile
                      .toString(),
                  imageIcon: Image.asset(
                    "assets/subwoktypemenu.gif",
                    width: 45,
                    height: 35,
                  ),
                  press: () async => {
                    await showProgressLoading(false),
                    setState(() {
                      //getHeader2
                      String temp = listImageSubWorkTypeMenu[index]
                          .menuWorkTypeNameMobile
                          .toString();
                      header2 = 'SubWorkType : $temp';
                      step++;
                    }),
                    await setPrefsImageSubWorkTypeId(
                        listImageSubWorkTypeMenu[index].imageSubWorkTypeId!),
                    await setPrefsImageSubWorkTypeName(
                        listImageSubWorkTypeMenu[index]
                            .menuWorkTypeNameMobile!),
                    await getLoadTypeMenu(),
                    setVisible(),
                    setReadOnly(),
                    setColor(),
                    setText(),
                    setFocus(),
                    await showProgressLoading(true),
                  },
                );
              },
              itemCount: listImageSubWorkTypeMenu.length,
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              scrollDirection: Axis.vertical,
            ),
          ]),
        ));
  }

  Widget _showLists2(BuildContext context) {
    return Visibility(
        visible: listVisible2,
        child: SingleChildScrollView(
          child: Column(children: <Widget>[
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return MenuList2(
                  text: listLoadTypeMenu[index].loadTypeName.toString(),
                  imageIcon: Image.asset(
                    "assets/loadtype.gif",
                    width: 45,
                    height: 35,
                  ),
                  press: () async => {
                    await showProgressLoading(false),
                    setState(() {
                      //getHeader3
                      String temp =
                          listLoadTypeMenu[index].loadTypeName.toString();
                      header3 = 'LoadType : $temp';
                      step++;
                    }),
                    await showProgressLoading(true),
                    await setPrefsLoadTypeId(
                        listLoadTypeMenu[index].loadTypeId!),
                    await setPrefsLoadTypeName(
                        listLoadTypeMenu[index].loadTypeName!),
                    await getItemWoImageDetail(),
                    setVisible(),
                    setReadOnly(),
                    setColor(),
                    setText(),
                    setFocus(),
                  },
                );
              },
              itemCount: listLoadTypeMenu.length,
              padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
              scrollDirection: Axis.vertical,
            ),
          ]),
        ));
  }
}
