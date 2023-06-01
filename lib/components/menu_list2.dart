import 'package:flutter/material.dart';

class MenuList2 extends StatelessWidget {
  const MenuList2({
    Key? key,
    required this.text,
    required this.imageIcon,
    this.press,
  }) : super(key: key);

  final String text;
  final Image imageIcon;
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextButton(
        style: TextButton.styleFrom(
          primary: Colors.white,
          onSurface: Colors.white,
          shadowColor: Colors.white,
          padding: EdgeInsets.all(16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          //backgroundColor: Color(0xFFF5F6F9),
          backgroundColor: Colors.white,
        ),
        onPressed: press,
        child: Row(
          children: [
            imageIcon,
            SizedBox(width: 20),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }
}
