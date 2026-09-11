extension StringCasingExtension on String {
  String capitalizeFirst() {
    return isNotEmpty ? '${this[0].toUpperCase()}${substring(1)}' : '';
  }
}


