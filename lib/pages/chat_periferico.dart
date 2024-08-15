import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_ble_peripheral_central/flutter_ble_peripheral_central.dart';

class ChatPeriferico extends StatefulWidget {
  const ChatPeriferico({super.key});

  @override
  State<ChatPeriferico> createState() => _ChatPerifericoState();
}

class _ChatPerifericoState extends State<ChatPeriferico> {
  final TextEditingController _controller = TextEditingController();
  final FlutterBlePeripheralCentral _flutterBlePeripheralCentralPlugin =
      FlutterBlePeripheralCentral();
  bool isConnect = false;
  final List<String> _receivedMessages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _permissionCheck();
    _startPeripheralService();
  }

  @override
  void dispose() {
    if (isConnect) {
      _flutterBlePeripheralCentralPlugin.bleDisconnect();
    }
    super.dispose();
  }

  Future<void> _permissionCheck() async {
    if (Platform.isAndroid) {
      var permission = await Permission.location.request();
      var bleScan = await Permission.bluetoothScan.request();
      var bleConnect = await Permission.bluetoothConnect.request();
      var bleAdvertise = await Permission.bluetoothAdvertise.request();
      var locationWhenInUse = await Permission.locationWhenInUse.request();

      log('Location permission: ${permission.isGranted}');
      log('BLE Scan permission: ${bleScan.isGranted}');
      log('BLE Connect permission: ${bleConnect.isGranted}');
      log('BLE Advertise permission: ${bleAdvertise.isGranted}');
      log('Location When In Use permission: ${locationWhenInUse.isGranted}');
    }
  }

  void _startPeripheralService() async {
    log("periferico");
    _flutterBlePeripheralCentralPlugin
        .startBlePeripheralService("Chat Periférico", "Mensagem Inicial")
        .listen((event) {
      log("evento $event");
      Map<String, dynamic> responseMap = jsonDecode(event);

      if (responseMap.containsValue("connected")) {
        setState(() {
          isConnect = true;
        });
      } else if (responseMap.containsKey('onCharacteristicWriteRequest')) {
        setState(() {
          _receivedMessages.add(responseMap['onCharacteristicWriteRequest']);
          _scrollToBottom();
        });
      }
    });
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _sendMessage() async {
    if (_controller.text.trim().isNotEmpty) {
      String message = _controller.text.trim();
      _controller.clear();
      await _flutterBlePeripheralCentralPlugin.sendIndicate(message);
      setState(() {
        _receivedMessages.add("Eu: $message");
        _scrollToBottom();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Periférico'),
      ),
      body: isConnect
          ? Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount: _receivedMessages.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_receivedMessages[index]),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'Digite uma mensagem...',
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator.adaptive()),
    );
  }
}
