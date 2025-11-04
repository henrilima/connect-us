/// Retorna a diferença entre dois intervalos de tempo
/// .
/// [now] Momento atual (Ou outro momento para comparar).
/// [relationshipDate] Data do início do relacionamento.
/// ? Retorna um Map com a diferença em dias, horas, minutos e segundos.
Map<String, int> getDifferenceDate(DateTime relationshipDate, {DateTime? now}) {
  final actualNow = now ?? DateTime.now();
  final diff = actualNow.difference(
    DateTime(
      relationshipDate.year,
      relationshipDate.month,
      relationshipDate.day,
    ),
  );

  return <String, int>{
    'days': diff.inDays,
    'hours': diff.inHours % 24,
    'minutes': diff.inMinutes % 60,
    'seconds': diff.inSeconds % 60,
  };
}
