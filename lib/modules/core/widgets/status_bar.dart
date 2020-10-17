import 'package:flutter/material.dart';

class StatusBar extends StatelessWidget {
  String _statusMessage;
  StatusBar({@required statusMessage}): _statusMessage = statusMessage;

  @override
  Widget build(BuildContext context) {
    return _buildConnectionStateText(_statusMessage);
  }

  Widget _buildConnectionStateText(String status) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Container(
              color: Colors.deepOrangeAccent,
              child: Text(status, textAlign: TextAlign.center)),
        ),
      ],
    );
  }
}
