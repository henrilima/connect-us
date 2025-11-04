/// Valida um endereço de e-mail.
/// [email] E-mail a ser validado.
/// Retorna `true` se o e-mail for válido, caso contrário `false`.
bool isValidEmail(String email) {
  final regex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
  return regex.hasMatch(email);
}
