import 'package:intl/intl.dart';

extension UserFriendlyDate on String {
  /// Mengonversi string tanggal ISO 8601 menjadi format ramah pengguna.
  /// Contoh output: "10 November 2024 jam 13:45:52".
  String toUserFriendlyDate() {
    try {
      // Parsing tanggal dari format ISO 8601
      final dateTime = DateTime.parse(this);

      // Format tampilan tanpa `locale` sebagai pengujian awal
      final dateFormat = DateFormat("d MMMM yyyy 'jam' HH:mm:ss");
      return dateFormat.format(dateTime);
    } catch (e) {
      // Kembalikan string error jika parsing atau formatting gagal
      return 'Tanggal tidak valid';
    }
  }
}

extension StringRounding on String {
  /// Membulatkan angka dalam string ke sejumlah desimal tertentu
  String roundToDecimals(int decimalPlaces) {
    try {
      // Mengonversi string ke double
      final number = double.parse(this);

      // Membulatkan ke jumlah desimal yang diinginkan
      return number.toStringAsFixed(decimalPlaces);
    } catch (e) {
      // Jika parsing gagal, kembalikan string asli atau pesan error
      return this; // atau "Invalid number"
    }
  }
}
