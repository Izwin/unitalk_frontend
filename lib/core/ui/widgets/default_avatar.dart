import 'package:flutter/cupertino.dart' show StatelessWidget;
import 'package:flutter/material.dart';

class DefaultAvatar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: Icon(
        Icons.person,
        size: 40,
        color: Colors.grey[600],
      ),
    );
  }
}
