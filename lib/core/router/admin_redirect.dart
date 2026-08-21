/// Redirection des routes admin. [isAdmin] `null` = rôle pas encore résolu.
String? adminRedirect({
  required String location,
  required bool? isAdmin,
}) {
  final onLogin = location == '/admin/login';
  final onAdmin = location == '/admin';
  if (!onLogin && !onAdmin) return null;

  if (isAdmin == true) {
    return onLogin ? '/admin' : null;
  }
  if (isAdmin == null) return null;
  return onAdmin ? '/admin/login' : null;
}
