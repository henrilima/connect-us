/// Valida um endereço de e-mail.
/// [email] E-mail a ser validado.
/// Retorna `true` se o e-mail for válido, caso contrário `false`.
bool isValidEmail(String email) {
  final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  return regex.hasMatch(email);
}

/// Valida um id de usuário.
/// Regras: apenas letras ASCII (A-Z, a-z), dígitos e underscore; sem espaços; 1..16 caracteres.
/// Retorna `true` se válido, caso contrário `false`.
bool isValidUserId(String id) {
  final regex = RegExp(r'^[A-Za-z0-9_]{4,16}$');
  return regex.hasMatch(id);
}

/// Retorna `null` se válido, ou uma mensagem de erro descrevendo o problema.
String? validateUserId(String id, String user) {
  if (id.isEmpty) return 'O $user não pode ser vazio.';
  if (id.length < 4 || id.length > 16) return 'O $user tem que ter entre 4 e 16 caracteres.';
  if (id.contains(' ')) return 'O $user não pode conter espaços.';
  final regex = RegExp(r'^[A-Za-z0-9_]+$');
  if (!regex.hasMatch(id)) return 'O $user só pode conter letras, números e underscore.';
  return null;
}
