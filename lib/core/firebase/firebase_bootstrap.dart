import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';

/// Initialise Firebase, active le cache offline et connecte un utilisateur anonyme.
///
/// Offline-first :
/// - Firestore garde un cache disque (par défaut sur mobile).
/// - L'auth anonyme permet d'écrire/lire selon les security rules sans écran login.
class FirebaseBootstrap {
  FirebaseBootstrap._();

  /// Doit être appelé une seule fois avant [runApp].
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Persistance explicite (déjà active par défaut sur Android/iOS).
    FirebaseFirestore.instance.settings = const Settings(
      persistenceEnabled: true,
      cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    );

    await _ensureAnonymousUser();
  }

  /// Crée une session anonyme si aucun utilisateur n'est déjà connecté.
  static Future<User> _ensureAnonymousUser() async {
    final auth = FirebaseAuth.instance;
    final current = auth.currentUser;
    if (current != null) return current;

    final credential = await auth.signInAnonymously();
    return credential.user!;
  }
}
