import 'package:intl/intl.dart';

extension UserFriendlyDate on String {
  String toUserFriendlyDate() {
    try {
      final dateTime = DateTime.parse(this);
      final dateFormat = DateFormat("d MMMM yyyy 'jam' HH:mm:ss");
      return dateFormat.format(dateTime);
    } catch (e) {
      return 'Tanggal tidak valid';
    }
  }
}

extension StringRounding on String {
  String roundToDecimals(int decimalPlaces) {
    try {
      final number = double.parse(this);
      return number.toStringAsFixed(decimalPlaces);
    } catch (e) {
      return this;
    }
  }
}
