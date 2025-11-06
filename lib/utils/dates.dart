/// Retorna a diferença entre dois intervalos de tempo
/// .
/// [now] Momento atual (Ou outro momento para comparar).
/// [relationshipDate] Data do início do relacionamento.
/// ? Retorna um Map com a diferença em dias, horas, minutos e segundos.
Map<String, int> getDifferenceDate(DateTime relationshipDate, {DateTime? now}) {
  final actualNow = now ?? DateTime.now();

  final isNegative = actualNow.isBefore(relationshipDate);
  final earlier = isNegative ? actualNow : relationshipDate;
  final later = isNegative ? relationshipDate : actualNow;

  int years = later.year - earlier.year;
  int months = later.month - earlier.month;
  int days = later.day - earlier.day;
  int hours = later.hour - earlier.hour;
  int minutes = later.minute - earlier.minute;
  int seconds = later.second - earlier.second;

  if (seconds < 0) {
    seconds += 60;
    minutes--;
  }
  if (minutes < 0) {
    minutes += 60;
    hours--;
  }
  if (hours < 0) {
    hours += 24;
    days--;
  }
  if (days < 0) {
    final daysInPrevMonth = DateTime(later.year, later.month, 0).day;
    days += daysInPrevMonth;
    months--;
  }
  if (months < 0) {
    months += 12;
    years--;
  }

  if (isNegative) {
    years = -years;
    months = -months;
    days = -days;
    hours = -hours;
    minutes = -minutes;
    seconds = -seconds;
  }

  return <String, int>{
    'years': years,
    'months': months,
    'days': days,
    'hours': hours,
    'minutes': minutes,
    'seconds': seconds,
  };
}
