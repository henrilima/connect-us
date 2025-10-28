Map<String, int> getDifferenceDate(DateTime now, DateTime relationshipDate) {
  final DateTime date = DateTime(
    relationshipDate.year,
    relationshipDate.month,
    relationshipDate.day,
  );

  return <String, int>{
    'days': now.difference(date).inDays,
    'hours': now.difference(date).inHours % 24,
    'minutes': now.difference(date).inMinutes % 60,
    'seconds': now.difference(date).inSeconds % 60,
  };
}

