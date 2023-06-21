import 'package:flutter/material.dart';
import 'package:hmc_iload/components/menu_list2.dart';
import 'package:hmc_iload/components/setting_menu.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:hmc_iload/screens/main_screen.dart';
import 'package:hmc_iload/screens/login.dart';

class Setting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    void logoutDialog() {
      showDialog(
          context: context,
          builder: (_) => AssetGiffyDialog(
              image: Image.asset(
                'assets/men_wearing_jacket.gif',
                fit: BoxFit.cover,
              ),
              title: Text(
                'LOGOUT',
                style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w600),
              ),
              description: Text(
                'Are your sure logout?',
                textAlign: TextAlign.center,
                style: TextStyle(),
              ),
              entryAnimation: EntryAnimation.RIGHT,
              onOkButtonPressed: () {
                Navigator.of(context, rootNavigator: true).pushReplacement(
                    MaterialPageRoute(builder: (context) => Login()));
              },
              onCancelButtonPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
                //Navigator.of(context).pop();
              }));
    }

    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
            image: new DecorationImage(
          image: new AssetImage("assets/hmc_background6.jpeg"),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.5), BlendMode.dstATop),
        )),
        alignment: Alignment.center,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 50),
          child: Column(
            children: [
              MenuList2(
                text: "Log Out",
                imageIcon: Image.asset(
                  "assets/logout.gif",
                  width: 65,
                  height: 55,
                ),
                press: () => {logoutDialog()},
              )
            ],
          ),
        ),
      ),
    );
  }
}
