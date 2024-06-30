import 'package:nano/Model/SummaryModal.dart';
import 'package:nano/view/Print/printerenum.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'dart:io';
import 'package:http/http.dart' as http;

///Test printing
class TestPrint {
  BlueThermalPrinter bluetooth = BlueThermalPrinter.instance;

  Future<void> printBill(
      {required SummaryModal order, required String status}) async {
    // Image max 300px X 300px

    final productL = order.products.length;

    // Print order summary in the console (optional)
    print("Order Summary:");
    print("--------------");
    print("Final Total: ${order.finalTotal}");
    print("Table Name: ${order.tableName}");
    print("Staff Name: ${order.staffName}");
    print("Type of Service: ${order.typeofservice}");
    print("Number of Products: $productL");
    print("");

    if (productL > 0) {
      for (int i = 0; i < productL; i++) {
        final product = order.products[i];
        print("Product ${i + 1}:");
        print("--------------");
        print("Name: ${product.name}");
        print("Quantity: ${product.quantity}");
        print("");
      }
    } else {
      print("No products found.");
    }

    // Image from File path
    String filename = 'logo.png';
    ByteData bytesData = await rootBundle.load("assets/images/logo.png");
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = await File('$dir/$filename').writeAsBytes(bytesData.buffer
        .asUint8List(bytesData.offsetInBytes, bytesData.lengthInBytes));

    // Image from Asset
    ByteData bytesAsset = await rootBundle.load("assets/images/logo.png");
    Uint8List imageBytesFromAsset = bytesAsset.buffer
        .asUint8List(bytesAsset.offsetInBytes, bytesAsset.lengthInBytes);

    // Image from Network
    var response = await http.get(Uri.parse(
        "https://raw.githubusercontent.com/kakzaki/blue_thermal_printer/master/example/assets/images/yourlogo.png"));
    Uint8List bytesNetwork = response.bodyBytes;
    Uint8List imageBytesFromNetwork = bytesNetwork.buffer
        .asUint8List(bytesNetwork.offsetInBytes, bytesNetwork.lengthInBytes);

    double total = 0;
    double tax = 0;
    const double taxRate = 0.10; // Example tax rate of 10%

    DateTime now = DateTime.now();

    bluetooth.isConnected.then((isConnected) {
      if (isConnected == true) {
        bluetooth.printNewLine();
        bluetooth.printImageBytes(imageBytesFromAsset); // Image from Asset
        bluetooth.printCustom(
            "Restaurant Name", Size.boldMedium.val, Align.center.val);
        bluetooth.printNewLine();
        bluetooth.printCustom(
            "Order: ${order.tableName}-${now.millisecondsSinceEpoch}",
            Size.boldMedium.val,
            Align.center.val);
        bluetooth.printNewLine();
        bluetooth.print3Column(
          "",
          "Server:",
          order.staffName,
          Size.bold.val,
        );
        bluetooth.print3Column(
          "Date & Time:",
          now.toString(),
          "",
          Size.bold.val,
        );
        bluetooth.printNewLine();
        bluetooth.printCustom(status, Size.bold.val, Align.center.val);
        bluetooth.printNewLine();

        // Print each product in the order
        for (var product in order.products) {
          double productTotal =
              product.quantity * 10; // Example product price of 10
          total += productTotal;
          tax += productTotal * taxRate;
          bluetooth.printLeftRight("${product.quantity} x ${product.name}",
              "\$${productTotal.toStringAsFixed(2)}", Size.medium.val);
        }

        // Print totals
        bluetooth.printNewLine();
        bluetooth.print3Column(
          "",
          "Sub-Total",
          "\$${total.toStringAsFixed(2)}",
          Size.bold.val,
        );
        bluetooth.print3Column(
          "",
          "Tax",
          "\$${tax.toStringAsFixed(2)}",
          Size.bold.val,
        );
        bluetooth.print3Column(
          "",
          "Total",
          "\$${(total + tax).toStringAsFixed(2)}",
          Size.bold.val,
        );

        // Finalizing the print
        bluetooth.printNewLine();
        bluetooth.printCustom("Thank You", Size.bold.val, Align.center.val);
        bluetooth.printNewLine();
        bluetooth
            .paperCut(); // some printer not supported (sometime making image not centered)
      }
    });
  }

  sample() async {
    //image max 300px X 300px

    ///image from File path
    String filename = 'logo.png';
    ByteData bytesData = await rootBundle.load("assets/images/logo.png");
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = await File('$dir/$filename').writeAsBytes(bytesData.buffer
        .asUint8List(bytesData.offsetInBytes, bytesData.lengthInBytes));

    ///image from Asset
    ByteData bytesAsset = await rootBundle.load("assets/images/logo.png");
    Uint8List imageBytesFromAsset = bytesAsset.buffer
        .asUint8List(bytesAsset.offsetInBytes, bytesAsset.lengthInBytes);

    ///image from Network
    var response = await http.get(Uri.parse(
        "https://raw.githubusercontent.com/kakzaki/blue_thermal_printer/master/example/assets/images/yourlogo.png"));
    Uint8List bytesNetwork = response.bodyBytes;
    Uint8List imageBytesFromNetwork = bytesNetwork.buffer
        .asUint8List(bytesNetwork.offsetInBytes, bytesNetwork.lengthInBytes);

    bluetooth.isConnected.then((isConnected) {
      if (isConnected == true) {
        bluetooth.printNewLine();
        bluetooth.printCustom("HEADER", Size.boldMedium.val, Align.center.val);
        bluetooth.printNewLine();
        bluetooth.printImage(file.path); //path of your image/logo
        bluetooth.printNewLine();
        bluetooth.printImageBytes(imageBytesFromAsset); //image from Asset
        bluetooth.printNewLine();
        bluetooth.printImageBytes(imageBytesFromNetwork); //image from Network
        bluetooth.printNewLine();
        bluetooth.printLeftRight("LEFT", "RIGHT", Size.medium.val);
        bluetooth.printLeftRight("LEFT", "RIGHT", Size.bold.val);
        bluetooth.printLeftRight("LEFT", "RIGHT", Size.bold.val,
            format:
                "%-15s %15s %n"); //15 is number off character from left or right
        bluetooth.printNewLine();
        bluetooth.printLeftRight("LEFT", "RIGHT", Size.boldMedium.val);
        bluetooth.printLeftRight("LEFT", "RIGHT", Size.boldLarge.val);
        bluetooth.printLeftRight("LEFT", "RIGHT", Size.extraLarge.val);
        bluetooth.printNewLine();
        bluetooth.print3Column("Col1", "Col2", "Col3", Size.bold.val);
        bluetooth.print3Column("Col1", "Col2", "Col3", Size.bold.val,
            format:
                "%-10s %10s %10s %n"); //10 is number off character from left center and right
        bluetooth.printNewLine();
        bluetooth.print4Column("Col1", "Col2", "Col3", "Col4", Size.bold.val);
        bluetooth.print4Column("Col1", "Col2", "Col3", "Col4", Size.bold.val,
            format: "%-8s %7s %7s %7s %n");
        bluetooth.printNewLine();
        bluetooth.printCustom("čĆžŽšŠ-H-ščđ", Size.bold.val, Align.center.val,
            charset: "windows-1250");
        bluetooth.printLeftRight("Številka:", "18000001", Size.bold.val,
            charset: "windows-1250");
        bluetooth.printCustom("Body left", Size.bold.val, Align.left.val);
        bluetooth.printCustom("Body right", Size.medium.val, Align.right.val);
        bluetooth.printNewLine();
        bluetooth.printCustom("Thank You", Size.bold.val, Align.center.val);
        bluetooth.printNewLine();
        bluetooth.printQRcode(
            "Insert Your Own Text to Generate", 200, 200, Align.center.val);
        bluetooth.printNewLine();
        bluetooth.printNewLine();
        bluetooth
            .paperCut(); //some printer not supported (sometime making image not centered)
        //bluetooth.drawerPin2(); // or you can use bluetooth.drawerPin5();
      }
    });
  }

//   sample(String pathImage) async {
//     //SIZE
//     // 0- normal size text
//     // 1- only bold text
//     // 2- bold with medium text
//     // 3- bold with large text
//     //ALIGN
//     // 0- ESC_ALIGN_LEFT
//     // 1- ESC_ALIGN_CENTER
//     // 2- ESC_ALIGN_RIGHT
//
// //     var response = await http.get("IMAGE_URL");
// //     Uint8List bytes = response.bodyBytes;
//     bluetooth.isConnected.then((isConnected) {
//       if (isConnected == true) {
//         bluetooth.printNewLine();
//         bluetooth.printCustom("HEADER", 3, 1);
//         bluetooth.printNewLine();
//         bluetooth.printImage(pathImage); //path of your image/logo
//         bluetooth.printNewLine();
// //      bluetooth.printImageBytes(bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
//         bluetooth.printLeftRight("LEFT", "RIGHT", 0);
//         bluetooth.printLeftRight("LEFT", "RIGHT", 1);
//         bluetooth.printLeftRight("LEFT", "RIGHT", 1, format: "%-15s %15s %n");
//         bluetooth.printNewLine();
//         bluetooth.printLeftRight("LEFT", "RIGHT", 2);
//         bluetooth.printLeftRight("LEFT", "RIGHT", 3);
//         bluetooth.printLeftRight("LEFT", "RIGHT", 4);
//         bluetooth.printNewLine();
//         bluetooth.print3Column("Col1", "Col2", "Col3", 1);
//         bluetooth.print3Column("Col1", "Col2", "Col3", 1,
//             format: "%-10s %10s %10s %n");
//         bluetooth.printNewLine();
//         bluetooth.print4Column("Col1", "Col2", "Col3", "Col4", 1);
//         bluetooth.print4Column("Col1", "Col2", "Col3", "Col4", 1,
//             format: "%-8s %7s %7s %7s %n");
//         bluetooth.printNewLine();
//         String testString = " čĆžŽšŠ-H-ščđ";
//         bluetooth.printCustom(testString, 1, 1, charset: "windows-1250");
//         bluetooth.printLeftRight("Številka:", "18000001", 1,
//             charset: "windows-1250");
//         bluetooth.printCustom("Body left", 1, 0);
//         bluetooth.printCustom("Body right", 0, 2);
//         bluetooth.printNewLine();
//         bluetooth.printCustom("Thank You", 2, 1);
//         bluetooth.printNewLine();
//         bluetooth.printQRcode("Insert Your Own Text to Generate", 200, 200, 1);
//         bluetooth.printNewLine();
//         bluetooth.printNewLine();
//         bluetooth.paperCut();
//       }
//     });
//   }
}
