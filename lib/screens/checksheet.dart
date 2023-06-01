import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hmc_iload/class/checksheetDocResult.dart';
import 'package:hmc_iload/class/itemWoCheckSheetDetail.dart';
import 'package:hmc_iload/screens/preview_checksheet.dart';

class CheckSheet extends StatefulWidget {
  static String routeName = "/checksheet";
  @override
  _CheckSheetState createState() => _CheckSheetState();
}

class _CheckSheetState extends State<CheckSheet> {
  TextEditingController documentController = TextEditingController();
  bool documentVisible = false;
  bool checksheetItemVisible = false;
  bool documentReadonly = false;
  Color documentColor = Color(0xFFFFFFFF);
  int step = 1;
  late Timer timer;
  String configs = '';
  String accessToken = '';
  String deviceId = "";
  String deviceInfo = "";
  String osVersion = "";
  late List<WoCheckSheetHeaderList> listMenu = [];
  late ItemWoCheckSheetDetail item = ItemWoCheckSheetDetail();

  int value = 0;
  bool radio = false;
  bool backEnable = false;
  bool nextEnable = false;
  TextEditingController remarkController = TextEditingController();

  bool advsalecheckSheetVisible = false;
  bool createEnabled = false;

  late List<FocusNode> focusNodes = List.generate(1, (index) => FocusNode());

  @override
  void initState() {
    super.initState();
    setState(() {
      step = 1;
      listMenu = [];
    });
    setVisible();
    setReadOnly();
    setColor();
    setText();
    setFocus();
  }

  void setVisible() {
    if (step == 1) {
      setState(() {
        documentVisible = true;
        advsalecheckSheetVisible = false;
        createEnabled = false;
        checksheetItemVisible = false;
      });
    } else if (step == 2) {
      setState(() {
        documentVisible = true;
        advsalecheckSheetVisible = true;
        createEnabled = true;
        checksheetItemVisible = false;
      });
    } else if (step == 3) {
      setState(() {
        documentVisible = false;
        advsalecheckSheetVisible = false;
        createEnabled = false;
        checksheetItemVisible = true;
      });
    }
  }

  void setReadOnly() {
    if (step == 1) {
      setState(() {
        documentReadonly = false;
      });
    } else if (step == 2) {
      setState(() {
        documentReadonly = true;
      });
    } else if (step == 3) {
      setState(() {
        backEnable = true;
      });
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
    }
  }

  void setText() {
    if (step == 1) {
      setState(() {
        documentController.text = '';
      });
    }
  }

  void setFocus() {
    if (step == 1) {
      Future.delayed(Duration(milliseconds: 100))
          .then((_) => FocusScope.of(context).requestFocus(focusNodes[0]));
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

  Future<void> setPrefswoCheckSheetHeaderId(int woCheckSheetHeaderId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('woCheckSheetHeaderId', woCheckSheetHeaderId);
  }

  Future<void> setPrefsDWTO(String dwto) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('dwto', dwto);
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
      await documentIDCheck();
      setVisible();
      setReadOnly();
      setColor();
      setText();
      setFocus();
    } else {
      return;
    }
  }

  Future<void> documentIDCheck() async {
    await showProgressLoading(false);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        configs = prefs.getString('configs')!;
        accessToken = prefs.getString('token')!;
        //documentController.text = 'WO7';
      });

      var url = Uri.parse('https://' +
          configs +
          '/api/Documents/ValidateDocumentCheckSheet/' +
          documentController.text.toString());

      var headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + accessToken
      };

      http.Response response = await http.get(url, headers: headers);
      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        late CheckSheetDocResult result;
        setState(() {
          result = CheckSheetDocResult.fromJson(data);
        });

        //advancedsale
        if (result.woCheckSheetHeaderList!.length > 0) {
          //getWoCheckSheetHeaderList
          for (int i = 0; i < result.woCheckSheetHeaderList!.length; i++) {
            late WoCheckSheetHeaderList temp;
            setState(() {
              temp = result.woCheckSheetHeaderList![i];
              listMenu.add(temp);
            });
          }

          setState(() {
            step = 2;
          });
          await setPrefsDocumentId(result.documentDetail!.documentId!);
          await setPrefsDWTO(documentController.text.toString());
          await showProgressLoading(true);
        } else {
          await setPrefsDocumentId(result.documentDetail!.documentId!);
          await setPrefsDWTO(documentController.text.toString());
          await getItemWoCheckSheetDetailFirst(null);
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

  Future<void> getItemWoCheckSheetDetailFirst(int? woCheckSheetHeaderId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int documentIdTemp = prefs.getInt('documentId')!;
      setState(() {
        configs = prefs.getString('configs')!;
        accessToken = prefs.getString('token')!;
      });

      var strWocheckSheet = woCheckSheetHeaderId == null
          ? ""
          : "?wochecksheetheaderId=" + woCheckSheetHeaderId.toString();

      var url = Uri.parse('https://' +
          configs +
          '/api/Documents/GetItemWoCheckSheetDetialFirst/' +
          documentIdTemp.toString() +
          strWocheckSheet);

      var headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + accessToken
      };

      http.Response response = await http.get(url, headers: headers);
      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        late ItemWoCheckSheetDetail result;
        setState(() {
          result = ItemWoCheckSheetDetail.fromJson(data);
          item = result;
          step = 3;
        });
      } else {
        await showProgressLoading(true);
        showErrorDialog(data.toString());
        return;
      }

      if (item.modifiedBy != null) {
        if (item.ischecked == true) {
          setState(() {
            radio = true;
            value = 1;
            remarkController.text = item.remark.toString();
            nextEnable = true;
          });
        } else if (item.ischecked == false) {
          setState(() {
            radio = true;
            value = 2;
            remarkController.text = item.remark.toString();
            nextEnable = true;
          });
        }
        await nextButtonCheckupItem();
      }
    } catch (e) {
      await showProgressLoading(true);
      showErrorDialog('Error occured while getItemWoCheckSheetDetailFirst');
    }
  }

  Future<void> backButtonCheckupItem() async {
    setState(() {
      backEnable = false;
    });
    if (item.runningNo == 1) {
      Navigator.pop(context);
      return;
    }
    await showProgressLoading(false);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        configs = prefs.getString('configs')!;
        accessToken = prefs.getString('token')!;
      });

      var url = Uri.parse('https://' +
          configs +
          '/api/Documents/UploadItemWoCheckSheetDetail?step=Back');

      var headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + accessToken
      };

      late ItemWoCheckSheetDetail itemTemp = ItemWoCheckSheetDetail();
      setState(() {
        itemTemp.woCheckSheetHeaderId = item.woCheckSheetHeaderId;
        itemTemp.woCheckSheetItemId = item.woCheckSheetItemId;
        itemTemp.ischecked = false;
        itemTemp.remark = '';
      });

      var jsonBody = jsonEncode(itemTemp);
      final encoding = Encoding.getByName('utf-8');

      http.Response response = await http.post(
        url,
        headers: headers,
        body: jsonBody,
        encoding: encoding,
      );
      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        late ItemWoCheckSheetDetail result;
        setState(() {
          result = ItemWoCheckSheetDetail.fromJson(data);
          item = result;
          step = 3;
        });

        //check data
        if (item.ischecked == null) {
          setState(() {
            value = 0;
            radio = false;
            backEnable = true;
            nextEnable = false;
            remarkController.text = "";
          });
        } else {
          if (item.ischecked == true) {
            setState(() {
              value = 1;
              radio = true;
            });
          } else if (item.ischecked == false) {
            setState(() {
              value = 2;
              radio = true;
            });
          }
          setState(() {
            backEnable = true;
            nextEnable = true;
            remarkController.text = item.remark.toString();
          });
        }
        await showProgressLoading(true);
      } else {
        await showProgressLoading(true);
        showErrorDialog('ItemWoCheckSheetDetailBack Not Found!');
      }
    } catch (e) {
      await showProgressLoading(true);
      showErrorDialog('Error occured while backButtonCheckupItem');
    }
  }

  Future<void> nextButtonCheckupItem() async {
    setState(() {
      nextEnable = false;
    });
    await showProgressLoading(false);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        configs = prefs.getString('configs')!;
        accessToken = prefs.getString('token')!;
      });

      var url = Uri.parse('https://' +
          configs +
          '/api/Documents/UploadItemWoCheckSheetDetail?step=Next');

      var headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + accessToken
      };

      setState(() {
        if (value == 1) {
          item.ischecked = true;
        } else if (value == 2) {
          item.ischecked = false;
        }
        item.remark = remarkController.text.toString();
      });

      var jsonBody = jsonEncode(item);
      final encoding = Encoding.getByName('utf-8');

      http.Response response = await http.post(
        url,
        headers: headers,
        body: jsonBody,
        encoding: encoding,
      );
      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        late ItemWoCheckSheetDetail result;
        setState(() {
          result = ItemWoCheckSheetDetail.fromJson(data);
          item = result;
          step = 3;
        });

        //check data
        if (item.ischecked == null) {
          setState(() {
            value = 0;
            radio = false;
            backEnable = true;
            nextEnable = false;
            remarkController.text = "";
          });
        } else {
          if (item.ischecked == true) {
            setState(() {
              value = 1;
              radio = true;
            });
          } else if (item.ischecked == false) {
            setState(() {
              value = 2;
              radio = true;
            });
          }
          setState(() {
            backEnable = true;
            nextEnable = true;
            remarkController.text = item.remark.toString();
          });
        }
        await showProgressLoading(true);
      } else if (response.statusCode == 404) {
        await setPrefswoCheckSheetHeaderId(item.woCheckSheetHeaderId!);
        setState(() {
          nextEnable = true;
        });
        await showProgressLoading(true);
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => PreviewCheckSheet()));
      } else {
        await showProgressLoading(true);
        showErrorDialog('PostCheckupItem Error!');
      }
    } catch (e) {
      await showProgressLoading(true);
      showErrorDialog('Error occured while nextButtonCheckupItem');
    }
  }

  Widget RadioButtonYes(String text, int index) {
    return new SizedBox(
        width: 200.0,
        height: 50.0,
        child: OutlinedButton(
          onPressed: () {
            setState(() {
              radio = true;
              value = index;
              nextEnable = true;
            });
          },
          child: Text(
            text,
            style: TextStyle(
              color: (value == index) ? Colors.green : Colors.black,
            ),
          ),
          style: OutlinedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            side: BorderSide(
                color: (value == index) ? Colors.green : Colors.black),
          ),
        ));
  }

  Widget RadioButtonNo(String text, int index) {
    return new SizedBox(
        width: 200.0,
        height: 50.0,
        child: OutlinedButton(
          onPressed: () {
            setState(() {
              radio = true;
              value = index;
              nextEnable = true;
            });
          },
          child: Text(
            text,
            style: TextStyle(
              color: (value == index) ? Colors.red : Colors.black,
            ),
          ),
          style: OutlinedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            side:
                BorderSide(color: (value == index) ? Colors.red : Colors.black),
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          leading: BackButton(color: Colors.black),
          backgroundColor: Colors.white,
          title: Text(
            'CheckSheet',
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
                      await documentIDCheck();
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
            visible: advsalecheckSheetVisible,
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
                        "Check Sheet History",
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                    Center(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: listMenu.length,
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
                              await getItemWoCheckSheetDetailFirst(
                                  listMenu[index].woCheckSheetHeaderId);
                              setVisible();
                              setReadOnly();
                              setColor();
                              setText();
                              setFocus();
                            },
                            title: Text(listMenu[index].containerNo.toString()),
                            subtitle:
                                Text(listMenu[index].containerNo.toString()),
                            trailing:
                                Text(listMenu[index].datetime!.toString()),
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
                              await getItemWoCheckSheetDetailFirst(null);
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
          Visibility(
              visible: checksheetItemVisible,
              child: Container(
                  child: SingleChildScrollView(
                child: Center(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    /*SizedBox(
                      height: MediaQuery.of(context).size.height / 20,
                    ),*/
                    SizedBox(
                        width: MediaQuery.of(context).size.width / 1.25,
                        child: Text(
                          ((item.checkSheetHeaderName).toString()),
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        )),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                        width: MediaQuery.of(context).size.width / 1.25,
                        child: Text(
                          ((item.sequence).toString() +
                              ". " +
                              item.detail.toString()),
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                          textAlign: TextAlign.left,
                        )),
                    SizedBox(height: 25),
                    RadioButtonYes("ผ่าน", 1),
                    SizedBox(
                      height: 25,
                    ),
                    RadioButtonNo("ไม่ผ่าน", 2),
                    SizedBox(height: 25),
                    Container(
                      padding: new EdgeInsets.only(
                          left: MediaQuery.of(context).size.width / 6,
                          right: MediaQuery.of(context).size.width / 6),
                      child: SingleChildScrollView(
                          child: TextFormField(
                        maxLength: 250,
                        minLines: 1,
                        maxLines: 3,
                        keyboardType: TextInputType.multiline,
                        textAlignVertical: TextAlignVertical.center,
                        textInputAction: TextInputAction.go,
                        onFieldSubmitted: (value) {},
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.note_alt_outlined, size: 26),
                          filled: true,
                          hintText: 'Enter Remark',
                          labelText: 'Remark',
                          border: OutlineInputBorder(),
                          isDense: true, // Added this
                          contentPadding: EdgeInsets.all(20), //
                        ),
                        controller: remarkController,
                      )),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment
                          .center, //Center Row contents horizontally,
                      crossAxisAlignment: CrossAxisAlignment
                          .center, //Center Row contents vertically,
                      children: <Widget>[
                        new ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                backEnable == true ? Colors.red : Colors.grey,
                          ),
                          child: const Text('Back',
                              style: TextStyle(
                                color: Colors.white,
                              )),
                          onPressed: backEnable
                              ? () async {
                                  FocusScope.of(context).previousFocus();
                                  await backButtonCheckupItem();
                                  setVisible();
                                  setReadOnly();
                                  setColor();
                                  setText();
                                  setFocus();
                                }
                              : null,
                        ),
                        SizedBox(
                            width: MediaQuery.of(context).size.width * 0.15),
                        new ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                nextEnable == true ? Colors.green : Colors.grey,
                          ),
                          child: const Text('Next',
                              style: TextStyle(
                                color: Colors.white,
                              )),
                          onPressed: nextEnable
                              ? () async {
                                  FocusScope.of(context).previousFocus();
                                  await nextButtonCheckupItem();
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
                  ],
                )),
              )))
        ])))));
  }
}
