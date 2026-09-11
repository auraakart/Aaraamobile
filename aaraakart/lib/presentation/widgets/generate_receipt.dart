import 'package:aaraa_kart/core/config/brand_config.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class DairyProduct {
  final String name;
  final int quantity;
  final double rate;

  DairyProduct({
    required this.name,
    required this.quantity,
    required this.rate,
  });

  double get total => quantity * rate;
}

Future<Uint8List> generateInvoicePdf({
  required PdfPageFormat format,
  required String invoiceNumber,
  required String invoiceDate,
  required String orderNumber,
  required String orderDate,
  required String paymentMethod,
  required String customerName,
  required String customerAddress,
  required String contactNumber,
  required List<DairyProduct> items,
}) async {
  final brand = BrandConfig.instance;
  final pdf = pw.Document();
  final font = await PdfGoogleFonts.poppinsMedium();
  final fontLight = await PdfGoogleFonts.poppinsRegular();

  final total = items.fold<double>(0.0, (sum, item) => sum + item.total);

  final logoBytes =
      (await rootBundle.load(brand.images.logo)).buffer.asUint8List();

  final PdfColor primaryColor =
      PdfColor.fromInt(brand.theme.primary.toARGB32());
  final PdfColor secondaryColor =
      PdfColor.fromInt(brand.theme.primary.toARGB32());

  pdf.addPage(pw.MultiPage(
    pageFormat: format,
    margin: const pw.EdgeInsets.all(20),
    build: (context) => [
      pw.Container(
        padding: const pw.EdgeInsets.all(10),
        color: primaryColor,
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    brand.appName,
                    style: pw.TextStyle(
                      font: font,
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  if (brand.content.tagline.isNotEmpty)
                    pw.Text(
                      brand.content.tagline,
                      style: pw.TextStyle(
                        font: font,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                    ),
                ]),
            pw.Container(
              height: 70,
              width: 70,
              alignment: pw.Alignment.center,
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex("#FFFFFF"),
                shape: pw.BoxShape.circle,
              ),
              child: pw.Container(
                height: 60,
                width: 60,
                child: pw.Image(
                  pw.MemoryImage(logoBytes),
                  fit: pw.BoxFit.contain,
                ),
              ),
            ),
          ],
        ),
      ),
      pw.SizedBox(height: 20),
      pw.Text(
        'Thank you for your purchase from ${brand.appName}!',
        style: pw.TextStyle(
          font: font,
          fontSize: 14,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.black,
        ),
      ),
      pw.SizedBox(height: 5),
      pw.Text(
        'We truly appreciate your support. Every order helps promote sustainable farming and local livelihoods.',
        style: pw.TextStyle(
          font: fontLight,
          fontSize: 12,
          color: PdfColors.black,
        ),
      ),
      pw.SizedBox(height: 10),
      pw.Text(
        'For any queries or assistance related to your order, please contact:',
        style: pw.TextStyle(
          font: fontLight,
          fontSize: 12,
          color: PdfColors.black,
        ),
      ),
      pw.SizedBox(height: 5),
      pw.Text(
        '+91-${brand.content.whatsappNumber.trim()}    |    ${brand.content.supportMail}',
        style: pw.TextStyle(
          font: font,
          fontSize: 12,
          color: primaryColor,
        ),
      ),
      pw.SizedBox(height: 10),
      pw.Divider(),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Invoice Number:  ',
              style: pw.TextStyle(
                  font: fontLight, fontSize: 12, color: PdfColors.black)),
          pw.Text(invoiceNumber,
              style: pw.TextStyle(
                font: fontLight,
                fontSize: 12,
                color: primaryColor,
                fontWeight: pw.FontWeight.bold,
              )),
        ],
      ),
      pw.SizedBox(height: 2),

      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Invoice Date:  ',
              style: pw.TextStyle(
                  font: fontLight, fontSize: 12, color: PdfColors.black)),
          pw.Text(invoiceDate,
              style: pw.TextStyle(
                font: fontLight,
                fontSize: 12,
                color: primaryColor,
                fontWeight: pw.FontWeight.bold,
              )),
        ],
      ),
      pw.SizedBox(height: 2),

      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Order Number:  ',
              style: pw.TextStyle(
                  font: fontLight, fontSize: 12, color: PdfColors.black)),
          pw.Text(orderNumber,
              style: pw.TextStyle(
                font: fontLight,
                fontSize: 12,
                color: primaryColor,
                fontWeight: pw.FontWeight.bold,
              )),
        ],
      ),
      pw.SizedBox(height: 2),

      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Order Date:  ',
              style: pw.TextStyle(
                  font: fontLight, fontSize: 12, color: PdfColors.black)),
          pw.Text(orderDate,
              style: pw.TextStyle(
                font: fontLight,
                fontSize: 12,
                color: primaryColor,
                fontWeight: pw.FontWeight.bold,
              )),
        ],
      ),
      pw.SizedBox(height: 2),

      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Payment Method:  ',
              style: pw.TextStyle(
                  font: fontLight, fontSize: 12, color: PdfColors.black)),
          pw.Text(paymentMethod,
              style: pw.TextStyle(
                font: fontLight,
                fontSize: 12,
                color: primaryColor,
                fontWeight: pw.FontWeight.bold,
              )),
        ],
      ),
      pw.SizedBox(height: 15),

      /// Customer Details
      pw.Text('Customer Details:   ',
          style:
              pw.TextStyle(font: font, fontSize: 14, color: PdfColors.black)),
      pw.SizedBox(height: 4),
      pw.Text('$customerName\n$customerAddress\n$contactNumber',
          style:
              pw.TextStyle(font: fontLight, fontSize: 11, color: primaryColor)),

      if (brand.content.officeAddress.isNotEmpty) ...[
        pw.SizedBox(height: 12),

        /// Office Address
        pw.Text('${brand.appName} Office Address:   ',
            style: pw.TextStyle(
                font: font, fontSize: 14, color: PdfColors.black)),
        pw.SizedBox(height: 4),
        pw.Text(brand.content.officeAddress,
            style: pw.TextStyle(
                font: fontLight, fontSize: 11, color: primaryColor)),
      ],

      pw.SizedBox(height: 20),
      pw.Text('Purchased Items',
          style: pw.TextStyle(
              font: font,
              fontSize: 14,
              color: PdfColors.black,
              fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 10),
      pw.Table.fromTextArray(
        border: pw.TableBorder.all(color: secondaryColor, width: 1),
        headers: ['Item', 'Qty', 'Rate (₹)', 'Total (₹)'],
        headerStyle: pw.TextStyle(
            font: font, color: primaryColor, fontWeight: pw.FontWeight.bold),
        cellStyle:
            pw.TextStyle(font: fontLight, fontSize: 11, color: primaryColor),
        cellAlignment: pw.Alignment.center,
        data: items.map((item) {
          return [
            item.name,
            item.quantity.toString(),
            item.rate.toStringAsFixed(2),
            item.total.toStringAsFixed(2),
          ];
        }).toList(),
      ),
      pw.SizedBox(height: 10),
      pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Total: ₹${total.toStringAsFixed(2)}',
          style: pw.TextStyle(
            font: font,
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ),
    ],
  ));

  return pdf.save();
}


