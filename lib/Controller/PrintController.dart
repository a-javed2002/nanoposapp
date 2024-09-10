import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/services.dart';
import 'package:nano/Controller/SummaryController.dart';
import 'package:nano/Model/OrderTable.dart';
import 'package:nano/Model/SummaryModal.dart';
import 'package:nano/view/Print/testprint.dart';

class PrintController extends GetxController {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;
  final SummaryController summaryController = Get.put(SummaryController());

  final RxList<BluetoothDevice> _devices = <BluetoothDevice>[].obs;
  BluetoothDevice? _device;
  var connected = false.obs;
  TestPrint testPrint = TestPrint();

  Future<void> initPlatformState() async {
    bool? isConnected = await bluetooth.isConnected;
    List<BluetoothDevice> devices = [];
    try {
      devices = await bluetooth.getBondedDevices();
    } on PlatformException {
      if (kDebugMode) {
        print("platform error");
      }
    }

    bluetooth.onStateChanged().listen((state) {
      switch (state) {
        case BlueThermalPrinter.CONNECTED:
          connected.value = true;
          if (kDebugMode) {
            print("bluetooth device state: connected");
          }
          break;
        case BlueThermalPrinter.DISCONNECTED:
          connected.value = false;
          if (kDebugMode) {
            print("bluetooth device state: disconnected");
          }
          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          connected.value = false;
          if (kDebugMode) {
            print("bluetooth device state: disconnect requested");
          }
          break;
        case BlueThermalPrinter.STATE_TURNING_OFF:
          connected.value = false;
          if (kDebugMode) {
            print("bluetooth device state: bluetooth turning off");
          }
          break;
        case BlueThermalPrinter.STATE_OFF:
          connected.value = false;
          if (kDebugMode) {
            print("bluetooth device state: bluetooth off");
          }
          break;
        case BlueThermalPrinter.STATE_ON:
          connected.value = false;
          if (kDebugMode) {
            print("bluetooth device state: bluetooth on");
          }
          break;
        case BlueThermalPrinter.STATE_TURNING_ON:
          connected.value = false;
          if (kDebugMode) {
            print("bluetooth device state: bluetooth turning on");
          }
          break;
        case BlueThermalPrinter.ERROR:
          connected.value = false;
          if (kDebugMode) {
            print("bluetooth device state: error");
          }
          break;
        default:
          if (kDebugMode) {
            print(state);
          }
          break;
      }
    });

    // if (!mounted) return;
    // _devices.value = devices;

    // Check if the controller is initialized before updating values
    if (connected != null &&
        _devices != null &&
        !(connected.value == null) &&
        !(_devices.value == null)) {
      _devices.value = devices;

      if (isConnected == true) {
        connected.value = true;
      }
    } else {
      return;
    }
  }

  void printDialog(
      {required BuildContext context,required OrderTableModal order, String billStatus = "Un Paid",bool finall = false}) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Print"),
            content: ListView(
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    const SizedBox(width: 10),
                    const Text(
                      'Device:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 22),
                    Expanded(
                      child: DropdownButton(
                        items: _getDeviceItems(),
                        onChanged: (BluetoothDevice? value) => _device = value,
                        value: _device,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown),
                      onPressed: () {
                        initPlatformState();
                      },
                      child: const Text(
                        'Refresh',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              connected.value ? Colors.red : Colors.green),
                      onPressed: () {
                        connected.value
                            ? disconnect(context)
                            : connect(context);
                      },
                      child: Text(
                        connected.value ? 'Disconnect' : 'Connect',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 10.0, right: 10.0, top: 50),
                  child: ElevatedButton(
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                    onPressed: () async{
                      // final order = summaryController.summaryModal.value;
                      // await summaryController.fetchOrderDetails();
                      final productL = order.products.length;

                      // Print order summary in the console (optional)
                      print("Order Summary:");
                      print("--------------");
                      print("Final Total: ${order.finalTotal}");
                      print("Table Name: ${order.tableName}");
                      print("Staff Name: ${order.staffName}");
                      print("Type of Service: ${order.typeOfService}");
                      print("Number of Products: $productL");
                      print("");

                      testPrint.printBill(order: order, status: billStatus,finall:finall);
                    },
                    child: const Text('Print Slip',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void showToast({required BuildContext context, required String message}) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2), // Adjust the duration as needed
      behavior: SnackBarBehavior
          .floating, // Ensure SnackBar is displayed above other content
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devices.isEmpty) {
      items.add(const DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      for (var device in _devices) {
        items.add(DropdownMenuItem(
          value: device,
          child: Text(device.name ?? ""),
        ));
      }
    }
    return items;
  }

  void connect(BuildContext context) {
    if (_device != null) {
      bluetooth.isConnected.then((isConnected) {
        if (isConnected == false) {
          bluetooth.connect(_device!).catchError((error) {
            connected.value = false;
          });
          connected.value = true;
          show('Connected.', context: context);
        }
      });
    } else {
      show('No device selected.', context: context);
    }
  }

  void disconnect(BuildContext context) {
    bluetooth.disconnect();
    connected.value = false;
    show('Disconnected.', context: context);
  }

  Future show(String message,
      {Duration duration = const Duration(seconds: 3),
      required BuildContext context}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        duration: duration,
      ),
    );
  }
}
