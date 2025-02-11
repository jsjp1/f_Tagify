String secTimeConvert(int time) {
  int hour = time ~/ 3600;
  int min = (time % 3600) ~/ 60;
  int sec = time % 60;

  if (hour > 0) {
    return "$hour:${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  } else if (min > 0) {
    return "$min:${sec.toString().padLeft(2, '0')}";
  } else {
    return sec.toString();
  }
}
