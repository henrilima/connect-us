/// Retorna a diferença entre dois intervalos de tempo
/// .
/// [now] Momento atual (Ou outro momento para comparar).
/// [relationshipDate] Data do início do relacionamento.
/// ? Retorna um Map com a diferença em dias, horas, minutos e segundos.
Map<String, int> getPreciseDifference(DateTime start, {DateTime? now}) {
  final current = now ?? DateTime.now();

  int totalMonths =
      (current.year - start.year) * 12 + (current.month - start.month);

  DateTime baseDate = DateTime(
    start.year,
    start.month + totalMonths,
    start.day,
    start.hour,
    start.minute,
    start.second,
  );

  if (current.isBefore(baseDate)) {
    totalMonths--;
    baseDate = DateTime(
      start.year,
      start.month + totalMonths,
      start.day,
      start.hour,
      start.minute,
      start.second,
    );
  }

  int years = totalMonths ~/ 12;
  int months = totalMonths % 12;

  Duration diff = current.difference(baseDate);

  int days = diff.inDays;
  int hours = diff.inHours % 24;
  int minutes = diff.inMinutes % 60;
  int seconds = diff.inSeconds % 60;

  return {
    'years': years,
    'months': months,
    'days': days,
    'hours': hours,
    'minutes': minutes,
    'seconds': seconds,
  };
}

int getDateInDays(DateTime start) {
  int totalDays = DateTime.now().difference(start).inDays;
  return totalDays;
}
