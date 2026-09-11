String getInitials(String? data) {
  if (data!.isEmpty) {
    return data.substring(0, 2).toUpperCase();
  }

  List<String> nameParts = data.trim().split(' ');
  if (nameParts.length >= 2) {
    return '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase();
  } else if (nameParts.isNotEmpty && nameParts[0].length >= 2) {
    return nameParts[0].substring(0, 2).toUpperCase();
  }
  return 'AJ';
}


