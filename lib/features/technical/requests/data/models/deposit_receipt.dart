import 'dart:typed_data';

class DepositReceipt {
  final Uint8List bytes;
  final String filename;
  const DepositReceipt._(this.bytes, this.filename);
  factory DepositReceipt.fromBytes(Uint8List bytes) {
    final jpeg =
        bytes.length >= 3 &&
            bytes[0] == 255 &&
            bytes[1] == 216 &&
            bytes[2] == 255;
    final png =
        bytes.length >= 8 &&
            [
              137,
              80,
              78,
              71,
              13,
              10,
              26,
              10,
            ].asMap().entries.every((e) => bytes[e.key] == e.value);
    final webp =
        bytes.length >= 12 &&
            String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
            String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP';
    if (!jpeg && !png && !webp)
      throw const FormatException('Unsupported receipt image');
    return DepositReceipt._(
      bytes,
      'deposit_receipt.${jpeg
          ? 'jpg'
          : png
          ? 'png'
          : 'webp'}',
    );
  }
}
