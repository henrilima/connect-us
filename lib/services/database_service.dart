import 'package:connect/services/location_service.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';

class DatabaseService {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  Future<bool> createRelationship(
    String authorUsername,
    String partnerUsername,
    String email,
    DateTime relationshipDate,
  ) async {
    String relationshipId = _generateRelationshipId(
      authorUsername,
      partnerUsername,
    );

    if (await relationshipExists(relationshipId)) {
      relationshipId = _generateRelationshipId(authorUsername, partnerUsername);
    }

    try {
      await dbRef.child('relationships/$relationshipId').set({
        'relationshipId': relationshipId,
        'authorId': authorUsername.toLowerCase(),
        'partnerId': partnerUsername.toLowerCase(),
        'authorEmail': email,
        'counters': {
          'kissCount': 0,
          'kissCountTime': 'Não adicionado',
          'hugCount': 0,
          'hugCountTime': 'Não adicionado',
        },
        'relationshipDate': relationshipDate.toIso8601String(),
        'createdAt': DateTime.now().toIso8601String(),
      });

      await dbRef.child('users/${authorUsername.toLowerCase()}').set({
        'userId': authorUsername.toLowerCase(),
        'partnerId': partnerUsername.toLowerCase(),
        'username': authorUsername,
        'relationshipId': relationshipId,
        'status': 'offline',
        'createdAt': DateTime.now().toIso8601String(),
      });

      await dbRef.child('users/${partnerUsername.toLowerCase()}').set({
        'userId': partnerUsername.toLowerCase(),
        'partnerId': authorUsername.toLowerCase(),
        'username': partnerUsername,
        'relationshipId': relationshipId,
        'status': 'offline',
        'createdAt': DateTime.now().toIso8601String(),
      });

      return true;
    } catch (err) {
      return false;
    }
  }

  Future<Map<String, String?>?> getUserRoleInRelationship(
    String relationshipId,
    String userId,
  ) async {
    try {
      final snapshot = await dbRef.child('relationships/$relationshipId').get();
      if (!snapshot.exists || snapshot.value == null) return null;

      final raw = snapshot.value as Map<dynamic, dynamic>;
      final author = (raw['authorId'] as String?)?.toLowerCase();
      final partner = (raw['partnerId'] as String?)?.toLowerCase();
      final uid = userId.toLowerCase();

      if (uid == author) {
        return {'role': 'author', 'partnerId': partner};
      }
      if (uid == partner) {
        return {'role': 'partner', 'partnerId': author};
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isAuthor(String relationshipId, String userId) async {
    final res = await getUserRoleInRelationship(relationshipId, userId);
    return res != null && res['role'] == 'author';
  }

  Future<bool> isPartner(String relationshipId, String userId) async {
    final res = await getUserRoleInRelationship(relationshipId, userId);
    return res != null && res['role'] == 'partner';
  }

  Future<bool> deleteUser(String userId) async {
    try {
      await dbRef.child('users/$userId').remove();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      await dbRef.child('users/$userId').update(userData);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> userExists(String userId) async {
    var snapshot = await dbRef.child('users/$userId').get();
    return snapshot.exists;
  }

  Future<bool> relationshipExists(String relationshipId) async {
    var snapshot = await dbRef.child('relationships/$relationshipId').get();
    return snapshot.exists;
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      var snapshot = await dbRef.child('users/$userId').get();
      if (!snapshot.exists) return null;

      final rawUser = snapshot.value as Map<dynamic, dynamic>;
      final userData = Map<String, dynamic>.from(rawUser);

      final partnerIdRaw = userData['partnerId'];
      if (partnerIdRaw is String && partnerIdRaw.isNotEmpty) {
        final partnerId = partnerIdRaw.toLowerCase();

        if (partnerId != userId) {
          var partnerSnapshot = await dbRef.child('users/$partnerId').get();
          if (partnerSnapshot.exists && partnerSnapshot.value != null) {
            final rawPartner = partnerSnapshot.value as Map<dynamic, dynamic>;
            userData['partnerData'] = Map<String, dynamic>.from(rawPartner);
          }
        }
      }

      return userData;
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getRelationshipData(
    String relationshipId,
  ) async {
    var snapshot = await dbRef.child('relationships/$relationshipId').get();
    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return null;
  }

  String _generateRelationshipId(
    String authorUsername,
    String partnerUsername,
  ) {
    final prefix = 'rel-';
    final a = (authorUsername.hashCode).abs() % 10000;
    final b = (partnerUsername.hashCode).abs() % 10000;
    return '$prefix${a.toString().padLeft(4, '0')}${b.toString().padLeft(4, '0')}';
  }

  Stream<Map<String, dynamic>?> getCountsStream(String relationshipId) {
    final relationshipNodeRef = dbRef.child(
      'relationships/$relationshipId/counters',
    );

    return relationshipNodeRef.onValue.map((event) {
      final dataSnapshot = event.snapshot;
      if (dataSnapshot.exists && dataSnapshot.value != null) {
        final rawMap = dataSnapshot.value as Map;
        return rawMap.cast<String, dynamic>();
      }

      return {};
    });
  }

  Future<void> manageHugsCount(
    String relationshipId, {
    bool increment = true,
  }) async {
    int op = increment ? 1 : -1;
    final relationshipNodeRef = dbRef.child(
      'relationships/$relationshipId/counters/hugCount',
    );
    final test = await relationshipNodeRef.get();
    int? currentValue = test.value as int?;
    currentValue ??= 0;

    if ((currentValue + op) < 0) return;
    await relationshipNodeRef.set(ServerValue.increment(increment ? 1 : -1));
  }

  Future<void> manageKissesCount(
    String relationshipId, {
    bool increment = true,
  }) async {
    int op = increment ? 1 : -1;
    final relationshipNodeRef = dbRef.child(
      'relationships/$relationshipId/counters/kissCount',
    );
    final test = await relationshipNodeRef.get();
    int? currentValue = test.value as int?;
    currentValue ??= 0;

    if ((currentValue + op) < 0) return;
    await relationshipNodeRef.set(ServerValue.increment(increment ? 1 : -1));
  }

  Future<void> addEventFromTimeline({
    required String relationshipId,
    required String title,
    required String description,
    required DateTime date,
    bool update = false,
    String? eventkey,
  }) async {
    final relationshipTimelineRef = dbRef.child(
      'relationships/$relationshipId/timeline',
    );

    final Map<String, String> data = {
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
    };

    if (update) {
      if (eventkey != null && eventkey.isNotEmpty) {
        return await relationshipTimelineRef.child(eventkey).set(data);
      }
    } else {
      await relationshipTimelineRef.push().set(data);
    }
  }

  Future<void> deleteEventFromTimeline({
    required String relationshipId,
    required String eventkey,
  }) async {
    if (eventkey.isEmpty) return;

    await dbRef
        .child('relationships/$relationshipId/timeline/$eventkey')
        .remove();
  }

  Future<Map<String, dynamic>> getEventFromTimeline(
    String relationshipId,
    String? eventKey,
  ) async {
    if (eventKey == null) return <String, dynamic>{};

    final snapshot = await dbRef
        .child('relationships/$relationshipId/timeline/$eventKey')
        .get();

    if (!snapshot.exists || snapshot.value == null) return <String, dynamic>{};

    return Map<String, dynamic>.from(snapshot.value as Map);
  }

  Stream<Map<String, dynamic>?> getTimelineStream(String relationshipId) {
    final relationshipTimelineRef = dbRef.child(
      'relationships/$relationshipId/timeline',
    );

    return relationshipTimelineRef.onValue.map((event) {
      final snapshopt = event.snapshot;
      if (snapshopt.exists) {
        Map<String, dynamic> timelineData = (snapshopt.value as Map)
            .cast<String, dynamic>();

        final entries = timelineData.entries.map((e) {
          final v = e.value;
          final mapValue = v is Map ? v : <String, dynamic>{'date': v};
          return MapEntry(e.key, mapValue);
        }).toList();

        entries.sort((a, b) {
          final aDateStr = a.value['date'] as String? ?? '';
          final bDateStr = b.value['date'] as String? ?? '';
          final aDate =
              DateTime.tryParse(aDateStr) ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final bDate =
              DateTime.tryParse(bDateStr) ??
              DateTime.fromMillisecondsSinceEpoch(0);
          return aDate.compareTo(bDate);
        });

        final sorted = <String, dynamic>{};
        for (final e in entries) {
          sorted[e.key] = e.value;
        }

        timelineData = sorted;
        return timelineData;
      }

      return null;
    });
  }

  Future<void> updateLocation(String userId) async {
    await LocationService().getCurrentLocation().then((value) async {
      await dbRef.child('users/$userId/location').set({
        'latitude': value.latitude,
        'longitude': value.longitude,
      });
    });
  }

  Future<String> getUsersDistance(String authorId, String partnerId) async {
    final author = await dbRef.child('users/$authorId/location').get();
    final partner = await dbRef.child('users/$partnerId/location').get();

    if (author.exists && partner.exists) {
      final authorData = Map<String, dynamic>.from(author.value as Map);
      final partnerData = Map<String, dynamic>.from(partner.value as Map);

      final double authorLat = (authorData['latitude'] as num).toDouble();
      final double authorLon = (authorData['longitude'] as num).toDouble();
      final double partnerLat = (partnerData['latitude'] as num).toDouble();
      final double partnerLon = (partnerData['longitude'] as num).toDouble();

      final double originalDistance = Geolocator.distanceBetween(
        authorLat,
        authorLon,
        partnerLat,
        partnerLon,
      );

      return (originalDistance / 1000).toStringAsFixed(2);
    } else {
      return "incalculáveis ";
    }
  }

  Future<void> sendMessageInChat({
    required String relationshipId,
    required String author,
    required String message,
  }) async {
    final relationshipTimelineRef = dbRef.child(
      'relationships/$relationshipId/chat-messages',
    );
    await relationshipTimelineRef.push().set({
      'author': author,
      'message': message,
      'date': DateTime.now().toIso8601String(),
    });
  }

  Stream<Map<String, dynamic>?> getMessagesStream(String relationshipId) {
    final relationshipNodeRef = dbRef.child(
      'relationships/$relationshipId/chat-messages',
    );

    return relationshipNodeRef.onValue.map((event) {
      final dataSnapshot = event.snapshot;
      if (dataSnapshot.exists && dataSnapshot.value != null) {
        Map<String, dynamic> chatData = (dataSnapshot.value as Map)
            .cast<String, dynamic>();

        final entries = chatData.entries.map((e) {
          final v = e.value;
          final mapValue = v is Map ? v : <String, dynamic>{'date': v};
          return MapEntry(e.key, mapValue);
        }).toList();

        entries.sort((a, b) {
          final aDateStr = a.value['date'] as String? ?? '';
          final bDateStr = b.value['date'] as String? ?? '';
          final aDate =
              DateTime.tryParse(aDateStr) ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final bDate =
              DateTime.tryParse(bDateStr) ??
              DateTime.fromMillisecondsSinceEpoch(0);
          return aDate.compareTo(bDate);
        });

        final sorted = <String, dynamic>{};
        for (final e in entries) {
          sorted[e.key] = e.value;
        }

        chatData = sorted;
        final reversed = <String, dynamic>{};
        for (final e in chatData.entries.toList().reversed) {
          reversed[e.key] = e.value;
        }
        return reversed;
      }

      return {};
    });
  }

  Future<void> setUserLoveLanguage(
    String userId,
    Map<String, String> languages,
  ) async {
    final userNodeRef = dbRef.child('users/$userId/love-languages');

    await userNodeRef.set({
      'palavras_de_afirmacao': languages['palavras_de_afirmacao'],
      'tempo_de_qualidade': languages['tempo_de_qualidade'],
      'presentes': languages['presentes'],
      'atos_de_servico': languages['atos_de_servico'],
      'toque_fisico': languages['toque_fisico'],
    });
  }

  Future<Map<String, String>> getUserLoveLanguages(String userId) async {
    final userNodeRef = dbRef.child('users/$userId/love-languages');
    final snapshot = await userNodeRef.get();

    if (snapshot.exists && snapshot.value is Map) {
      final data = Map<String, String>.from(snapshot.value as Map);
      final sortedResults = data.entries.toList();

      sortedResults.sort((a, b) {
        try {
          final valueA = double.parse(a.value);
          final valueB = double.parse(b.value);
          return valueB.compareTo(valueA);
        } catch (e) {
          return 0;
        }
      });

      final Map<String, String> finalMap = Map.fromEntries(sortedResults);
      return finalMap;
    }

    return <String, String>{};
  }

  Stream<Map<String, String>> streamUserLoveLanguages(String userId) {
    final userNodeRef = dbRef.child('users/$userId/love-languages');

    return userNodeRef.onValue.map((event) {
      final snapshot = event.snapshot;

      if (snapshot.exists && snapshot.value is Map) {
        final data = Map<String, String>.from(snapshot.value as Map);
        final sortedResults = data.entries.toList();

        sortedResults.sort((a, b) {
          try {
            final valueA = double.parse(a.value);
            final valueB = double.parse(b.value);
            return valueB.compareTo(valueA);
          } catch (e) {
            return 0;
          }
        });

        final Map<String, String> finalMap = Map.fromEntries(sortedResults);
        return finalMap;
      }

      return <String, String>{};
    });
  }
}
