import 'package:flutter/material.dart';
import 'package:flutter_restaurant/localization/language_constrants.dart';
import 'package:flutter_restaurant/helper/router_helper.dart';
import 'package:flutter_restaurant/view/base/custom_app_bar.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool route = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: getTranslated('qr_scan', context)),
      body: MobileScanner(
        controller: MobileScannerController(
          returnImage: true,
        ),
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if(barcode.rawValue != null && barcode.rawValue!.contains('qrcode=') && route){
              route = false;
              context.pop();
               RouterHelper.getQrCategoryScreen(qrData: barcode.rawValue!.replaceRange(0, barcode.rawValue!.indexOf('?qrcode='), '').replaceAll('?qrcode=', ''));
            }

            debugPrint('Barcode found! ${barcode.rawValue}');
          }
        },
      ),
    );
  }
}
