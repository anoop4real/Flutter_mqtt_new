import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttermqttnew/modules/core/managers/MQTTManager.dart';
import 'package:fluttermqttnew/modules/core/models/MQTTAppState.dart';
import 'package:fluttermqttnew/modules/core/widgets/status_bar.dart';
import 'package:fluttermqttnew/modules/helpers/status_info_message_utils.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _hostTextController = TextEditingController();
  MQTTManager _manager;

  @override
  void dispose() {
    _hostTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _manager = Provider.of<MQTTManager>(context);
    Timer(Duration(seconds: 1), () {
      _manager.updateStream();
    });

    return Scaffold(
        appBar: _buildAppBar(context),
        body: _manager.controller.stream == null
            ? CircularProgressIndicator()
            : _buildColumn(_manager));
  }

  Widget _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('MQTT'),
      backgroundColor: Colors.greenAccent,
    );
  }

  Widget _buildColumn(MQTTManager manager) {
    return StreamBuilder(
      stream: manager.myStream,
      builder: (BuildContext context, AsyncSnapshot<MQTTAppState> snapshot) {
        if (snapshot.hasData) {
          return Column(
            children: <Widget>[
              StatusBar(
                  statusMessage: prepareStateMessageFrom(
                      snapshot.data.getAppConnectionState)),
              _buildEditableColumn(snapshot.data),
            ],
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Widget _buildEditableColumn(MQTTAppState currentAppState) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: <Widget>[
          _buildTextFieldWith(_hostTextController,'Enter broker address',
              currentAppState.getAppConnectionState),
          const SizedBox(height: 10),
          _buildConnecteButtonFrom(currentAppState.getAppConnectionState)
        ],
      ),
    );
  }

  Widget _buildTextFieldWith(TextEditingController controller, String hintText,
      MQTTAppConnectionState state) {
    bool shouldEnable = false;
    if ((controller == _hostTextController &&
        state == MQTTAppConnectionState.disconnected)) {
      shouldEnable = true;
    } else if (controller == _hostTextController && _manager.host != null) {
      _hostTextController.text = _manager.host;
    }
    return TextField(
        enabled: shouldEnable,
        controller: controller,
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.only(left: 0, bottom: 0, top: 0, right: 0),
          labelText: hintText,
        ));
  }

  Widget _buildConnecteButtonFrom(MQTTAppConnectionState state) {
    return Row(
      children: <Widget>[
        Expanded(
          child: RaisedButton(
            color: Colors.lightBlueAccent,
            child: const Text('Connect'),
            onPressed: state == MQTTAppConnectionState.disconnected
                ? _configureAndConnect
                : null, //
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RaisedButton(
            color: Colors.redAccent,
            child: const Text('Disconnect'),
            onPressed: state != MQTTAppConnectionState.disconnected
                ? _disconnect
                : null, //
          ),
        ),
      ],
    );
  }

  void _configureAndConnect() {
    // TODO: Use UUID
    String osPrefix = 'Flutter_iOS';
    if (Platform.isAndroid) {
      osPrefix = 'Flutter_Android';
    }
    _manager.initializeMQTTClient(
        host: _hostTextController.text, identifier: osPrefix);
    _manager.connect();
  }

  void _disconnect() {
    _manager.disconnect();
  }
}
