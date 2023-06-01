import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:hmc_iload/class/itemWoCheckSheetDetail.dart';
import 'package:hmc_iload/screens/takephoto_checksheet.dart';

class PreviewCheckSheet2 extends StatefulWidget {
  @override
  State<PreviewCheckSheet2> createState() => _PreviewCheckSheet2State();
}

class _PreviewCheckSheet2State extends State<PreviewCheckSheet2> {
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

  Future<void> getListItemWoCheckSheetDetail() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      configs = prefs.getString('configs')!;
      accessToken = prefs.getString('token')!;
      woCheckSheetHeaderId = prefs.getInt('woCheckSheetHeaderId')!;

      var url = Uri.parse('https://' +
          configs +
          '/api/Documents/GetListItemWoCheckSheetDetail?woCheckSheetHeaderId=1026');

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
          Navigator.push(context,
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
    ProgressDialog pr = ProgressDialog(context);
    pr = ProgressDialog(context,
        type: ProgressDialogType.normal, isDismissible: true, showLogs: true);
    pr.style(
        progress: 50.0,
        message: "Please wait...",
        progressWidget: Container(
            padding: EdgeInsets.all(8.0), child: CircularProgressIndicator()),
        maxProgress: 100.0,
        progressTextStyle: TextStyle(
            color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
        messageTextStyle: TextStyle(
            color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600));

    if (finish == false) {
      await pr.show();
    } else {
      await pr.hide();
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
          (states) => Colors.blue,
        ),
        columnSpacing: 25,
        border: TableBorder.all(width: 1),
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
                      fontWeight: FontWeight.bold, color: Colors.white))))),
      DataColumn(
          label: Expanded(
              child: Text('Result',
                  softWrap: true,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)))),
      DataColumn(
          label: Expanded(
              child: (Text('Detail',
                  softWrap: true,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white))))),
    ];
  }

  List<DataRow> _createRows() {
    return _data
        .map((_data) => DataRow(cells: [
              DataCell(Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _data.runningNo.toString(),
                    textAlign: TextAlign.start,
                  ))),
              DataCell(
                _data.ischecked == true
                    ? Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.check,
                          color: Colors.green,
                          size: 30.0,
                        ))
                    : Align(
                        alignment: Alignment.centerLeft,
                        child: Icon(
                          Icons.close,
                          color: Colors.red,
                          size: 30.0,
                        )),
              ),
              DataCell(Align(
                  alignment: Alignment.centerLeft,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Container(
                          width: MediaQuery.of(context).size.width / 1.9,
                          child: Text(
                            _data.detail.toString(),
                            textAlign: TextAlign.start,
                          ))))),
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
            'Table',
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
                height: MediaQuery.of(context).size.height / 3,
                width: MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                    child: Column(children: [
                  _createDataTable(),
                ])),
              ),
              SizedBox(height: 25),
              RadioButtonYes("ผ่าน", 1),
              SizedBox(
                height: 25,
              ),
              RadioButtonNo("ไม่ผ่าน", 2),
              SizedBox(
                height: 25,
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
