import 'package:flutter/material.dart';
import 'package:hmc_iload/components/menu_list2.dart';
import 'package:hmc_iload/screens/checksheet.dart';
import 'package:hmc_iload/screens/takephoto.dart';

class Menu extends StatefulWidget {
  static String routeName = "/menu";
  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<Menu> {
  bool containerVisible = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
              SizedBox(height: 10),
              Visibility(
                visible: containerVisible,
                child: MenuList2(
                  text: "Check Sheet",
                  imageIcon: Image.asset(
                    "assets/checksheet.gif",
                    width: 65,
                    height: 55,
                  ),
                  press: () => {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => CheckSheet()))
                  },
                ),
              ),
              /* Visibility(
                visible: containerVisible,
                child: MenuList2(
                  text: "Take Photo",
                  imageIcon: Image.asset(
                    "assets/takephoto.gif",
                    width: 65,
                    height: 55,
                  ),
                  press: () => {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PreviewCheckSheet2()))
                  },
                ),
              ),*/
              Visibility(
                visible: containerVisible,
                child: MenuList2(
                  text: "Take Photo",
                  imageIcon: Image.asset(
                    "assets/takephoto.gif",
                    width: 65,
                    height: 55,
                  ),
                  press: () => {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Takephoto()))
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
