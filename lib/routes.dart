import 'package:hmc_iload/screens/main_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:hmc_iload/screens/login.dart';

// We use name route
// All our routes will be available here
final Map<String, WidgetBuilder> routes = {
  MainScreen.routeName: (context) => MainScreen(),
  Login.routeName: (context) => Login(),
};
