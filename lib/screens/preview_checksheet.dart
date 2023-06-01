import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:hmc_iload/class/itemWoCheckSheetDetail.dart';
import 'package:hmc_iload/screens/takephoto_checksheet.dart';

class PreviewCheckSheet extends StatefulWidget {
  @override
  State<PreviewCheckSheet> createState() => _PreviewCheckSheetState();
}

class _PreviewCheckSheetState extends State<PreviewCheckSheet> {
  bool backEnable = true;
  bool nextEnable = false;
  String configs = '';
  String accessToken = '';
  int woCheckSheetHeaderId = 0;
  late Timer timer;

  int value = 0;
  bool radio = false;

  List<ItemWoCheckSheetDetail> _data = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => getListItemWoCheckSheetDetail());
  }

  String setDetail(int no, String msg) {
    if (msg.length > 10) {
      return no.toString() + '. ' + msg.substring(0, 18).toString() + '..';
    } else {
      return no.toString() + '. ' + msg;
    }
  }

  Future<void> getListItemWoCheckSheetDetail() async {
    await showProgressLoading(false);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      configs = prefs.getString('configs')!;
      accessToken = prefs.getString('token')!;
      woCheckSheetHeaderId = prefs.getInt('woCheckSheetHeaderId')!;

      var url = Uri.parse('https://' +
          configs +
          '/api/Documents/GetListItemWoCheckSheetDetail?woCheckSheetHeaderId=' +
          woCheckSheetHeaderId.toString());

      var headers = {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer " + accessToken
      };

      http.Response response = await http.get(url, headers: headers);
      var data = json.decode(response.body);

      if (response.statusCode == 200) {
        var datalist = List<ItemWoCheckSheetDetail>.from(
            data.map((model) => ItemWoCheckSheetDetail.fromJson(model)));
        setState(() {
          _data = datalist;
        });
        await showProgressLoading(true);
      } else {
        showErrorDialog('ListItemWoCheckSheetDetail Not Found!');
      }
    } catch (e) {
      showErrorDialog('Error occured while getListItemWoCheckSheetDetail');
    }
  }

  Future<void> next() async {
    setState(() {
      nextEnable = false;
    });
    await showProgressLoading(false);
    if (value == 1) {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        configs = prefs.getString('configs')!;
        accessToken = prefs.getString('token')!;
        woCheckSheetHeaderId = prefs.getInt('woCheckSheetHeaderId')!;

        var url = Uri.parse('https://' +
            configs +
            '/api/Documents/CompletedWoCheckSheetHeader?woCheckSheetHeaderId=' +
            woCheckSheetHeaderId.toString() +
            '&inspectionResult=true&isCompleted=true');

        var headers = {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer " + accessToken
        };

        Map<String, dynamic> body = {
          'woCheckSheetHeaderId': woCheckSheetHeaderId,
          'inspectionResult': true,
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
          showSuccessDialog('Document is Completed!');
        } else {
          await showProgressLoading(true);
          setState(() {
            nextEnable = true;
          });
          showErrorDialog('Error Finish WoCheckSheetDetail!');
        }
      } catch (e) {
        showErrorDialog('Error occured while next');
      }
    } else if (value == 2) {
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();

        configs = prefs.getString('configs')!;
        accessToken = prefs.getString('token')!;
        woCheckSheetHeaderId = prefs.getInt('woCheckSheetHeaderId')!;

        var url = Uri.parse('https://' +
            configs +
            '/api/Documents/CompletedWoCheckSheetHeader?woCheckSheetHeaderId=' +
            woCheckSheetHeaderId.toString() +
            '&inspectionResult=false&isCompleted=false');

        var headers = {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer " + accessToken
        };

        Map<String, dynamic> body = {
          'woCheckSheetHeaderId': woCheckSheetHeaderId,
          'inspectionResult': false,
          'isCompleted': false
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
          setState(() {
            nextEnable = true;
          });
          await Navigator.push(context,
              MaterialPageRoute(builder: (context) => TakephotoCheckSheet()));
        } else {
          await showProgressLoading(true);
          setState(() {
            nextEnable = true;
          });
          showErrorDialog('Error Finish WoCheckSheetDetail!');
        }
      } catch (e) {
        showErrorDialog('Error occured while next');
      }
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

  void viewDetailDialog(String checkSheetHeaderName, int runningNo,
      String detail, bool ischecked, String remark) {
    Color colorIsChecked;
    String textIsChecked;
    bool remarkVisible;

    if (ischecked) {
      colorIsChecked = Colors.green;
      textIsChecked = 'ผ่าน';
    } else {
      colorIsChecked = Colors.red;
      textIsChecked = 'ไม่ผ่าน';
    }

    if (remark.length == 0) {
      remark = '';
      remarkVisible = false;
    } else {
      remark = 'Remark : ' + remark;
      remarkVisible = true;
    }

    Icon icon = Icon(
      Icons.info_outline,
      color: Colors.lightBlue,
      size: 35,
    );

    showDialog(
        context: context,
        builder: (BuildContext builderContext) {
          timer = Timer(Duration(seconds: 5), () {
            Navigator.of(context, rootNavigator: true).pop();
          });

          return AlertDialog(
            title: Row(
                children: [icon, Text(" " + checkSheetHeaderName.toString())]),
            content: SingleChildScrollView(
                child: Column(children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width / 1.25,
                  child: Text(
                    (runningNo.toString() + ". " + detail.toString()),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  )),
              SizedBox(height: 28),
              new SizedBox(
                  width: 200.0,
                  height: 50.0,
                  child: OutlinedButton(
                    onPressed: () {},
                    child: Text(
                      textIsChecked,
                      style: TextStyle(
                        color: colorIsChecked,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      side: BorderSide(color: colorIsChecked),
                    ),
                  )),
              SizedBox(height: 28),
              Visibility(
                  visible: remarkVisible,
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width / 1.25,
                      child: Text(
                        (remark),
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.left,
                      ))),
            ])),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
            ],
          );
        }).then((val) {
      if (timer.isActive) {
        timer.cancel();
      }
    });
  }

  void viewDetailDialog2(
      String checkSheetHeaderName, int runningNo, String detail) {
    Icon icon = Icon(
      Icons.info_outline,
      color: Colors.lightBlue,
      size: 20,
    );

    showDialog(
        context: context,
        builder: (BuildContext builderContext) {
          timer = Timer(Duration(seconds: 5), () {
            Navigator.of(context, rootNavigator: true).pop();
          });

          return AlertDialog(
            title: SingleChildScrollView(
                child: Column(children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width / 1.25,
                  child: Row(children: [
                    icon,
                    Text(
                      " ${checkSheetHeaderName.toString()}",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      softWrap: true,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                  ])),
            ])),
            content: SingleChildScrollView(
                child: Column(children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width / 1.25,
                  child: Text(
                    (runningNo.toString() + ". " + detail.toString()),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.left,
                  )),
            ])),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
            ],
          );
        }).then((val) {
      if (timer.isActive) {
        timer.cancel();
      }
    });
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

  DataTable _createDataTable() {
    return DataTable(
        headingRowColor: MaterialStateColor.resolveWith(
          (states) => Colors.grey[200]!,
        ),
        columnSpacing: 5,
        //border: TableBorder.all(width: 1),
        columns: _createColumns(),
        rows: _createRows());
    /*dividerThickness: 5,
        dataRowHeight: 20,
        showBottomBorder: true,
        headingTextStyle:
            TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        headingRowColor:
            MaterialStateProperty.resolveWith((states) => Colors.black));*/
    /*border: TableBorder.all(
          width: 1.0,
          color: Colors.black,
        ));*/
  }

  List<DataColumn> _createColumns() {
    return [
      DataColumn(
          label: Expanded(
              child: (Text('No',
                  softWrap: true,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black))))),
      DataColumn(
          label: Expanded(
              child: Text('Result',
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)))),
      /*  DataColumn(
          label: Expanded(
              child: (Text('Description',
                  softWrap: true,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black))))),*/
      DataColumn(
          label: Expanded(
              child: Text('Detail',
                  softWrap: true,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black)))),
    ];
  }

  List<DataRow> _createRows() {
    return _data
        .map((_data) => DataRow(
                color: MaterialStateColor.resolveWith((states) {
                  return _data.runningNo! % 2 == 0
                      ? Colors.grey[200]!
                      : Colors.transparent; //make tha magic!
                }),
                cells: [
                  DataCell(Container(
                      width: 160, //SET width
                      child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            setDetail(
                                _data.runningNo!, _data.detail.toString()),
                            textAlign: TextAlign.start,
                          )))),
                  DataCell(
                    _data.ischecked == true
                        ? Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.check,
                              color: Colors.green,
                              size: 30.0,
                            ))
                        : Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 30.0,
                            )),
                  ),
                  /* DataCell(Align(
                      alignment: Alignment.centerLeft,
                      child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Container(
                              width: MediaQuery.of(context).size.width / 1.75,
                              child: Text(
                                _data.detail.toString(),
                                overflow: TextOverflow.visible,
                                softWrap: true,
                                textAlign: TextAlign.start,
                              ))))),*/

                  DataCell(Align(
                      alignment: Alignment.center,
                      child: new SizedBox(
                        width: 50.0,
                        height: 30.0,
                        child: ElevatedButton(
                          onPressed: () {
                            viewDetailDialog2(_data.checkSheetHeaderName!,
                                _data.runningNo!, _data.detail!);
                          },
                          child: Icon(Icons.search),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 50,
          leading: BackButton(color: Colors.black),
          backgroundColor: Colors.white,
          title: Text(
            'Confirm CheckSheet',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black, fontSize: 18),
          ),
        ),
        body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(children: [
              SizedBox(height: 25),
              Container(
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.black)),
                height: MediaQuery.of(context).size.height / 2.4,
                width: MediaQuery.of(context).size.width / 1.2,
                child: SingleChildScrollView(
                    child: Column(children: [
                  _createDataTable(),
                ])),
              ),
              SizedBox(height: 30),
              RadioButtonYes("ผ่าน", 1),
              SizedBox(
                height: 15,
              ),
              RadioButtonNo("ไม่ผ่าน", 2),
              SizedBox(
                height: 15,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment
                    .center, //Center Row contents horizontally,
                crossAxisAlignment:
                    CrossAxisAlignment.center, //Center Row contents vertically,
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
                            Navigator.pop(context);
                          }
                        : null,
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.05),
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
                            await next();
                          }
                        : null,
                  ),
                ],
              ),
              SizedBox(
                height: 25,
              ),
            ])));
  }
}
