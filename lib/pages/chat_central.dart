import 'dart:io';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_ble_peripheral_central/flutter_ble_peripheral_central.dart';

class ChatCentral extends StatefulWidget {
  const ChatCentral({super.key});

  @override
  State<ChatCentral> createState() => _ChatCentralState();
}

class _ChatCentralState extends State<ChatCentral> {
  final _flutterBlePeripheralCentralPlugin = FlutterBlePeripheralCentral();
  final TextEditingController _controller = TextEditingController();
  final List<String> _messages = [];
  bool isConnect = false;

  @override
  void initState() {
    super.initState();
    _permissionCheck();
    scanCentral();
  }

  @override
  void dispose() {
    _flutterBlePeripheralCentralPlugin.stopBlePeripheralService();
    super.dispose();
  }

  void scanCentral() async {
    _flutterBlePeripheralCentralPlugin.scanAndConnect().listen((event) {
      log(event.toString());
      log("log CENTRAL");
      log("Evento: $event");
      Map<String, dynamic> responseMap = jsonDecode(event);

      log(responseMap.toString());

      if (responseMap.containsValue("connected")) {
        setState(() {
          isConnect = true;
        });
      } else if (responseMap.containsKey('onCharacteristicChanged')) {
        String receivedMessage = responseMap['onCharacteristicChanged'];

        setState(() {
          _messages.add(receivedMessage);
        });
      }
    });
  }

  void _sendMessage(String message) async {
    if (message.isNotEmpty) {
      log("Enviando mensagem: $message");
      await _flutterBlePeripheralCentralPlugin.bleWriteCharacteristic(message);
      setState(() {
        _messages.add("Você: $message");
      });
      log("Mensagem enviada");
    }
  }

  void _permissionCheck() async {
    if (Platform.isAndroid) {
      var permission = await Permission.location.request();
      var bleScan = await Permission.bluetoothScan.request();
      var bleConnect = await Permission.bluetoothConnect.request();
      var bleAdvertise = await Permission.bluetoothAdvertise.request();
      var locationWhenInUse = await Permission.locationWhenInUse.request();

      log('location permission: ${permission.isGranted}');
      log('bleScan permission: ${bleScan.isGranted}');
      log('bleConnect permission: ${bleConnect.isGranted}');
      log('bleAdvertise permission: ${bleAdvertise.isGranted}');
      log('location locationWhenInUse: ${locationWhenInUse.isGranted}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Central'),
      ),
      body: isConnect
          ? Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(_messages[index]),
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
                        onPressed: () {
                          if (_controller.text.trim().isNotEmpty) {
                            _sendMessage(_controller.text.trim());
                            _controller.clear(); // Limpa o campo após enviar
                          }
                        },
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
