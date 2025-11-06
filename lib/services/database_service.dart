import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';

class DatabaseService {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  /// ? CREATE RELATIONSHIP
  Future<String> createRelationship(
    String authorUsername,
    String partnerUsername,
    String email,
    DateTime relationshipDate,
  ) async {
    String relationshipId = _generateRelationshipId(
      authorUsername,
      partnerUsername,
    );
    await databaseReference.child('relationships/$relationshipId').set({
      'relationshipId': relationshipId,
      'authorId': authorUsername.toLowerCase(),
      'partnerId': partnerUsername.toLowerCase(),
      'authorEmail': email,
      'counters': {'kissCount': 0, 'hugCount': 0},
      'relationshipDate': relationshipDate.toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
    });

    await databaseReference.child('users/${authorUsername.toLowerCase()}').set({
      'userId': authorUsername.toLowerCase(),
      'partnerId': partnerUsername.toLowerCase(),
      'username': authorUsername.toLowerCase(),
      'relationshipId': relationshipId,
    });

    await databaseReference
        .child('users/${partnerUsername.toLowerCase()}')
        .set({
          'userId': partnerUsername.toLowerCase(),
          'partnerId': authorUsername.toLowerCase(),
          'username': partnerUsername.toLowerCase(),
          'relationshipId': relationshipId,
        });

    return relationshipId;
  }

  /// ? Delete User
  Future<bool> deleteUser(String userId) async {
    try {
      await databaseReference.child('users/$userId').remove();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  /// ? Update User
  Future<bool> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      await databaseReference.child('users/$userId').update(userData);
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  /// ? Validations
  Future<bool> userExists(String userId) async {
    var snapshot = await databaseReference.child('users/$userId').get();
    return snapshot.exists;
  }

  Future<bool> relationshipExists(String relationshipId) async {
    var snapshot = await databaseReference
        .child('relationships/$relationshipId')
        .get();
    return snapshot.exists;
  }

  /// ? Get User and Relationship Data
  Future<Map<String, dynamic>> getUserData(String userId) async {
    var snapshot = await databaseReference.child('users/$userId').get();
    if (!snapshot.exists) return <String, dynamic>{};

    final rawUser = snapshot.value as Map<dynamic, dynamic>;
    final userData = Map<String, dynamic>.from(rawUser);

    final partnerIdRaw = userData['partnerId'];

    if (partnerIdRaw is String && partnerIdRaw.isNotEmpty) {
      final partnerSnapshot = await databaseReference
          .child('users/${partnerIdRaw.toLowerCase()}')
          .get();
      if (partnerSnapshot.exists && partnerSnapshot.value != null) {
        final rawPartner = partnerSnapshot.value as Map<dynamic, dynamic>;
        userData['partnerData'] = Map<String, dynamic>.from(rawPartner);
      }
    }

    return userData;
  }

  Future<Map<String, dynamic>> getRelationshipData(
    String relationshipId,
  ) async {
    var snapshot = await databaseReference
        .child('relationships/$relationshipId')
        .get();

    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }

    return <String, dynamic>{};
  }

  /// ? Future sem retorno
  /// Aqui ficam as funções Future sem retorno

  Future<void> manageCount(
    String relationshipId, {
    required String countName,
    bool increment = true,
    bool custom = false,
  }) async {
    int op = increment ? 1 : -1;
    var relationshipRef = databaseReference.child(
      'relationships/$relationshipId/counters/',
    );

    if (custom) {
      relationshipRef = relationshipRef.child('custom/$countName');
    } else {
      relationshipRef = relationshipRef.child(countName);
    }

    final snapshot = await relationshipRef.get();
    Map<String, dynamic>? data;
    if (custom) {
      data = Map<String, dynamic>.from(snapshot.value as Map);
    }
    int? currentValue = custom
        ? data!['value'] as int?
        : snapshot.value as int?;
    currentValue ??= 0;

    if ((currentValue + op) < 0) return;
    if (custom) {
      await relationshipRef
          .child('value')
          .set(ServerValue.increment(increment ? 1 : -1));
      await relationshipRef.child('time').set(DateTime.now().toIso8601String());
    } else {
      await relationshipRef.set(ServerValue.increment(increment ? 1 : -1));
      await databaseReference
          .child('relationships/$relationshipId/counters/${countName}Time')
          .set(DateTime.now().toIso8601String());
    }
  }

  Future<void> setCounter(
    String relationshipId, {
    required String title,
    required String description,
    required String icon,
    bool update = false,
    String? counterKey,
  }) async {
    final relationshipRef = databaseReference.child(
      'relationships/$relationshipId/counters/custom/',
    );

    if (update && counterKey != null) {
      await relationshipRef.child(counterKey).update({
        'title': title,
        'description': description,
        'icon': icon,
      });
    } else {
      await relationshipRef.push().set({
        'title': title,
        'description': description,
        'icon': icon,
        'value': 0,
      });
    }
  }

  Future<void> deleteCounter(
    String relationshipId, {
    required String countName,
  }) async {
    await databaseReference
        .child('relationships/$relationshipId/counters/custom/$countName')
        .remove();
  }

  Future<void> addEventFromTimeline({
    required String relationshipId,
    required String title,
    required String description,
    required DateTime date,
    bool update = false,
    String? eventkey,
  }) async {
    final relationshipTimelineRef = databaseReference.child(
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
      await relationshipTimelineRef.push().update(data);
    }
  }

  Future<void> deleteEventFromTimeline({
    required String relationshipId,
    required String eventkey,
  }) async {
    if (eventkey.isEmpty) return;

    await databaseReference
        .child('relationships/$relationshipId/timeline/$eventkey')
        .remove();
  }

  Future<void> sendMessageInChat({
    required String relationshipId,
    required String author,
    required String message,
  }) async {
    await databaseReference
        .child('relationships/$relationshipId/chat-messages')
        .push()
        .set({
          'author': author,
          'message': message,
          'date': DateTime.now().toIso8601String(),
        });
  }

  Future<void> setUserLoveLanguage(
    String userId,
    Map<String, String> languages,
  ) async {
    await databaseReference.child('users/$userId/love-languages').set({
      'palavras_de_afirmacao': languages['palavras_de_afirmacao'],
      'tempo_de_qualidade': languages['tempo_de_qualidade'],
      'presentes': languages['presentes'],
      'atos_de_servico': languages['atos_de_servico'],
      'toque_fisico': languages['toque_fisico'],
    });
  }

  Future<void> updatePartnerMusic(
    String partnerId,
    String link,
    String? note, {
    delete = false,
  }) async {
    if (!delete) {
      await databaseReference.child('users/$partnerId/partner-music').set({
        'url': link,
        'note': note,
      });
    } else {
      await databaseReference.child('users/$partnerId/partner-music').remove();
    }
  }

  Future<void> updateUserAndRelationshipData({
    String? userId,
    String? relationshipId,
    String? newUsername,
    DateTime? newDate,
  }) async {
    if (newUsername != null && newUsername.isNotEmpty) {
      await databaseReference.child('users/$userId/username').set(newUsername);
    }

    if (newDate != null) {
      await databaseReference
          .child('relationships/$relationshipId/relationshipDate')
          .set(newDate.toIso8601String());
    }
  }

  /// ? Future com retorno
  /// Aqui ficam as funções Future com retorno

  Future<Map<String, dynamic>> getEventFromTimeline(
    String relationshipId,
    String? eventKey,
  ) async {
    if (eventKey == null) return <String, dynamic>{};

    final snapshot = await databaseReference
        .child('relationships/$relationshipId/timeline/$eventKey')
        .get();

    if (!snapshot.exists || snapshot.value == null) return <String, dynamic>{};

    return Map<String, dynamic>.from(snapshot.value as Map);
  }

  Future<void> updateLocation(String userId, Position position) async {
    await databaseReference.child('users/$userId/location').set({
      'latitude': position.latitude,
      'longitude': position.longitude,
    });
  }

  Future<String?> getUsersDistance(String authorId, String partnerId) async {
    final authorSnapshot = await databaseReference
        .child('users/$authorId/location')
        .get();
    final partnerSnapshot = await databaseReference
        .child('users/$partnerId/location')
        .get();

    if (authorSnapshot.exists && partnerSnapshot.exists) {
      final authorData = Map<String, dynamic>.from(authorSnapshot.value as Map);
      final partnerData = Map<String, dynamic>.from(
        partnerSnapshot.value as Map,
      );

      final double originalDistance = Geolocator.distanceBetween(
        (authorData['latitude'] as num).toDouble(),
        (authorData['longitude'] as num).toDouble(),
        (partnerData['latitude'] as num).toDouble(),
        (partnerData['longitude'] as num).toDouble(),
      );

      return (originalDistance / 1000).toStringAsFixed(2);
    } else {
      return null;
    }
  }

  Future<Map<String, String>> getUserLoveLanguages(String userId) async {
    final snapshot = await databaseReference
        .child('users/$userId/love-languages')
        .get();

    if (snapshot.exists && snapshot.value is Map) {
      final data = Map<String, String>.from(snapshot.value as Map);
      final sortedResults = data.entries.toList();

      sortedResults.sort((a, b) {
        try {
          final valueA = double.parse(a.value);
          final valueB = double.parse(b.value);
          return valueB.compareTo(valueA);
        } catch (e) {
          debugPrint(e.toString());
          return 0;
        }
      });

      return Map.fromEntries(sortedResults);
    }
    return <String, String>{};
  }

  Future<Map<String, String>> getPartnerMusic(String partnerId) async {
    final snapshot = await databaseReference
        .child('users/$partnerId/partner-music')
        .get();

    if (snapshot.exists && snapshot.value is Map) {
      final data = snapshot.value as Map;
      return Map<String, String>.from(data);
    } else {
      return <String, String>{};
    }
  }

  Future<Map<String, dynamic>> getCustomCounter(
    String relationshipId,
    String counterKey,
  ) async {
    final snapshot = await databaseReference
        .child('relationships/$relationshipId/counters/custom/$counterKey')
        .get();

    if (snapshot.exists) {
      final data = snapshot.value as Map;
      return Map<String, dynamic>.from(data);
    }

    return <String, dynamic>{};
  }

  Future<String> getUsername(String id) async {
    final username = await databaseReference.child('users/$id/username').get();

    if (username.exists) {
      return username.value as String;
    }

    return '';
  }

  /// ? Streams
  /// Aqui ficam os Streams
  Stream<Map<String, dynamic>> getCountsStream(String relationshipId) {
    final relationshipNodeRef = databaseReference.child(
      'relationships/$relationshipId/counters',
    );

    return relationshipNodeRef.onValue.map((event) {
      final dataSnapshot = event.snapshot;
      if (dataSnapshot.exists && dataSnapshot.value != null) {
        final rawMap = dataSnapshot.value as Map;
        return rawMap.cast<String, dynamic>();
      }

      return <String, dynamic>{};
    });
  }

  Stream<Map<String, dynamic>> getTimelineStream(String relationshipId) {
    final relationshipTimelineRef = databaseReference.child(
      'relationships/$relationshipId/timeline',
    );

    return relationshipTimelineRef.onValue.map((event) {
      final snapshopt = event.snapshot;
      if (snapshopt.exists) {
        Map<String, dynamic> timelineData = (snapshopt.value as Map)
            .cast<String, dynamic>();

        return sortMapByDate(timelineData);
      }

      return <String, dynamic>{};
    });
  }

  Stream<Map<String, dynamic>> getMessagesStream(String relationshipId) {
    final relationshipNodeRef = databaseReference.child(
      'relationships/$relationshipId/chat-messages',
    );

    return relationshipNodeRef.onValue.map((event) {
      final dataSnapshot = event.snapshot;
      if (dataSnapshot.exists && dataSnapshot.value != null) {
        Map<String, dynamic> chatData = (dataSnapshot.value as Map)
            .cast<String, dynamic>();

        final reversed = <String, dynamic>{};
        for (final e in sortMapByDate(chatData).entries.toList().reversed) {
          reversed[e.key] = e.value;
        }
        return reversed;
      }

      return <String, dynamic>{};
    });
  }

  Stream<Map<String, String>> streamUserLoveLanguages(String userId) {
    final userNodeRef = databaseReference.child('users/$userId/love-languages');

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
            debugPrint(e.toString());
            return 0;
          }
        });

        final Map<String, String> finalMap = Map.fromEntries(sortedResults);
        return finalMap;
      }

      return <String, String>{};
    });
  }

  Stream<Map<String, String>> streamPartnerMusic(String userId) {
    final userNodeRef = databaseReference.child('users/$userId/partner-music');

    return userNodeRef.onValue.map((event) {
      final snapshot = event.snapshot;

      if (snapshot.exists) {
        final data = snapshot.value as Map;
        return Map<String, String>.from(data);
      } else {
        return <String, String>{};
      }
    });
  }

  /// ? Generations, Sorts and Maps
  String _generateRelationshipId(
    String authorUsername,
    String partnerUsername,
  ) {
    final prefix = 'rel-';
    final a = (authorUsername.hashCode).abs() % 10000;
    final b = (partnerUsername.hashCode).abs() % 10000;
    return '$prefix${a.toString().padLeft(4, '0')}${b.toString().padLeft(4, '0')}';
  }

  Map<String, dynamic> sortMapByDate(Map<String, dynamic> data) {
    final entries = data.entries.toList()
      ..sort((a, b) {
        final aDate = DateTime.tryParse(a.value['date'] ?? '') ?? DateTime(0);
        final bDate = DateTime.tryParse(b.value['date'] ?? '') ?? DateTime(0);
        return aDate.compareTo(bDate);
      });
    return Map.fromEntries(entries);
  }
}
