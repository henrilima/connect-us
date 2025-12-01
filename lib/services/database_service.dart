import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/rendering.dart';
import 'package:geolocator/geolocator.dart';
import 'package:connect/services/api_service.dart';

class DatabaseService {
  final DatabaseReference databaseReference = FirebaseDatabase.instance.ref();

  /// ? CRIAR RELACIONAMENTO
  Future<String> createRelationship(
    String authorId,
    String partnerId,
    String email,
    DateTime relationshipDate,
  ) async {
    if (await userExists(authorId)) {
      return 'error:O ID de usuário que você escolheu já existe.';
    }

    if (await userExists(partnerId)) {
      return 'error:O ID de usuário do seu par já existe.';
    }

    String relationshipId = _generateRelationshipId(authorId, partnerId);

    await databaseReference.child('relationships/$relationshipId').set({
      'relationshipId': relationshipId,
      'authorId': authorId.toLowerCase(),
      'partnerId': partnerId.toLowerCase(),
      'authorEmail': email,
      'counters': {'kissCount': 0, 'hugCount': 0},
      'relationshipDate': relationshipDate.toIso8601String(),
      'createdAt': DateTime.now().toIso8601String(),
    });

    await databaseReference.child('users/${authorId.toLowerCase()}').set({
      'userId': authorId.toLowerCase(),
      'partnerId': partnerId.toLowerCase(),
      'username': authorId.toLowerCase(),
      'relationshipId': relationshipId,
      'status': false,
      'last-login': '0',
    });

    await databaseReference.child('users/${partnerId.toLowerCase()}').set({
      'userId': partnerId.toLowerCase(),
      'partnerId': authorId.toLowerCase(),
      'username': partnerId.toLowerCase(),
      'relationshipId': relationshipId,
      'status': false,
      'last-login': '0',
    });

    return 'id:$relationshipId';
  }

  /// ? Deletar Usuário
  Future<bool> deleteUser(String userId) async {
    try {
      await databaseReference.child('users/$userId').remove();
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  /// ? Atualizar Usuário
  Future<bool> updateUser(String userId, Map<String, dynamic> userData) async {
    try {
      await databaseReference.child('users/$userId').update(userData);
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  /// ? Definir Token de Mensagem do Usuário
  Future<bool> setUserMessagerToken(String userId, String token) async {
    try {
      await databaseReference.child('users/$userId/messager-token').set(token);
      return true;
    } catch (e) {
      debugPrint(e.toString());
      return false;
    }
  }

  /// ? Validações
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

  /// ? Obter Dados do Usuário e Relacionamento
  Future<Map<String, dynamic>> getUserData(String userId) async {
    var snapshot = await databaseReference.child('users/$userId').get();
    if (!snapshot.exists) return <String, dynamic>{};

    final rawUser = snapshot.value as Map<dynamic, dynamic>;
    final userData = Map<String, dynamic>.from(rawUser);

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
    String? partnerId,
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

      if (increment && partnerId != null) {
        final newValue = currentValue + 1;
        if (countName == 'kissCount') {
          if (newValue == 100) {
            _notifyAchievement(partnerId, 'Carinhosos', '100 beijos trocados!');
          }
          if (newValue == 500) {
            _notifyAchievement(
              partnerId,
              'Viciado em Beijos',
              '500 beijos trocados!',
            );
          }
          if (newValue == 1000) {
            _notifyAchievement(
              partnerId,
              'Mestre dos Beijos',
              '1000 beijos trocados!',
            );
          }
        } else if (countName == 'hugCount') {
          if (newValue == 100) {
            _notifyAchievement(
              partnerId,
              'Carinhosos',
              '100 abraços trocados!',
            );
          }
          if (newValue == 500) {
            _notifyAchievement(
              partnerId,
              'Abraço de Urso',
              '500 abraços trocados!',
            );
          }
          if (newValue == 1000) {
            _notifyAchievement(
              partnerId,
              'Mestre dos Abraços',
              '1000 abraços trocados!',
            );
          }
        }
      }
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
    String? partnerId,
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

      if (partnerId != null) {
        final snapshot = await relationshipTimelineRef.get();
        if (snapshot.exists) {
          final count = snapshot.children.length;
          if (count == 1) {
            _notifyAchievement(
              partnerId,
              'Primeira Memória',
              'Primeiro evento registrado!',
            );
          }
          if (count == 20) {
            _notifyAchievement(
              partnerId,
              'Diário de Bordo',
              '20 memórias registradas!',
            );
          }
          if (count == 50) {
            _notifyAchievement(
              partnerId,
              'Historiador',
              '50 momentos inesquecíveis!',
            );
          }
          if (count == 100) {
            _notifyAchievement(
              partnerId,
              'Livro Lendário',
              '100 memórias! Uma vida juntos.',
            );
          }
        }
      }
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
          'isDeleted': false,
        });
  }

  Future<void> updateMessage({
    required String relationshipId,
    required String messageId,
    required String newMessage,
  }) async {
    await databaseReference
        .child('relationships/$relationshipId/chat-messages/$messageId')
        .update({'message': newMessage});
  }

  Future<void> deleteMessage({
    required String relationshipId,
    required String messageId,
  }) async {
    await databaseReference
        .child('relationships/$relationshipId/chat-messages/$messageId')
        .update({'message': 'Mensagem apagada', 'isDeleted': true});
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

  Future<void> updateUserFeeling(
    String userId,
    String feeling,
    int iconCodePoint,
    int colorValue,
  ) async {
    await databaseReference.child('users/$userId/feeling').set({
      'label': feeling,
      'icon': iconCodePoint,
      'color': colorValue,
      'updatedAt': DateTime.now().toIso8601String(),
    });
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

  Stream<Map<String, dynamic>> getMessagesStream(
    String relationshipId, {
    int limit = 10,
  }) {
    final relationshipNodeRef = databaseReference
        .child('relationships/$relationshipId/chat-messages')
        .orderByKey()
        .limitToLast(limit);

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

  Stream<Map<String, dynamic>> getPartnerStream(String partnerId) {
    final userNodeRef = databaseReference.child('users/$partnerId');

    return userNodeRef.onValue.map((event) {
      final snapshot = event.snapshot;

      if (snapshot.exists && snapshot.value != null) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);
        return data;
      }

      return <String, dynamic>{};
    });
  }

  Future<void> updateUserStatus(String userId, bool isOnline) async {
    await databaseReference.child('users/$userId').update({
      'status': isOnline,
      'last-login': DateTime.now().toIso8601String(),
    });
  }

  /// ? Enviar Amor
  Future<void> sendLove(
    String relationshipId,
    String senderId,
    String partnerId,
  ) async {
    // Atualizar timestamp para o remetente
    await databaseReference
        .child('relationships/$relationshipId/love_pings/$senderId')
        .set(DateTime.now().toIso8601String());

    // Enviar notificação
    final partnerToken = await getMessagerToken(partnerId);
    if (partnerToken != null) {
      await ApiService().sendNotification(
        partnerToken,
        'Amor recebido!',
        'Seu amor está pensando em você. ❤️',
      );
    }
  }

  Stream<Map<String, String>> getLovePingsStream(String relationshipId) {
    return databaseReference
        .child('relationships/$relationshipId/love_pings')
        .onValue
        .map((event) {
          if (event.snapshot.value == null) {
            return {};
          }
          final data = Map<String, dynamic>.from(event.snapshot.value as Map);
          return data.map((key, value) => MapEntry(key, value.toString()));
        });
  }

  /// ? Fotos Diárias
  Stream<Map<String, dynamic>> getDailyPhotosStream(String relationshipId) {
    return databaseReference
        .child('relationships/$relationshipId/photos')
        .onValue
        .map((event) {
          if (event.snapshot.value == null) {
            return {};
          }
          return Map<String, dynamic>.from(event.snapshot.value as Map);
        });
  }

  Future<void> updateDailyPhotoData(
    String relationshipId,
    String userId, {
    String? caption,
    String? partnerId,
  }) async {
    final Map<String, dynamic> updates = {
      'timestamp': DateTime.now().toIso8601String(),
    };
    if (caption != null) {
      updates['caption'] = caption;
    }
    await databaseReference
        .child('relationships/$relationshipId/photos/$userId')
        .update(updates);

    if (partnerId != null) {
      final partnerToken = await getMessagerToken(partnerId);
      if (partnerToken != null) {
        await ApiService().sendNotification(
          partnerToken,
          'Novo registro único! 📸',
          'Seu amor acabou de postar uma foto do dia. Corra para ver, pois ela não fica salva.',
        );
      }
    }
  }

  Future<void> deleteDailyPhoto(String relationshipId, String userId) async {
    await databaseReference
        .child('relationships/$relationshipId/photos/$userId')
        .remove();
  }

  /// ? Surpresas
  Future<String?> getMessagerToken(String userId) async {
    final snapshot = await databaseReference
        .child('users/$userId/messager-token')
        .get();
    if (snapshot.exists) {
      return snapshot.value as String?;
    }
    return null;
  }

  Future<void> createSurprise(
    String relationshipId,
    Map<String, dynamic> surpriseData,
  ) async {
    // Buscar tokens
    final senderUid = surpriseData['senderUid'];
    final receiverUid = surpriseData['receiverUid'];

    final senderToken = await getMessagerToken(senderUid);
    final receiverToken = await getMessagerToken(receiverUid);

    // Atualizar dados com tokens
    surpriseData['senderId'] = senderToken;
    surpriseData['receiverId'] = receiverToken;

    final newSurpriseRef = databaseReference
        .child('relationships/$relationshipId/surprises')
        .push();

    // Adicionar o ID aos dados
    surpriseData['id'] = newSurpriseRef.key;

    await newSurpriseRef.set(surpriseData);
  }

  Future<void> updateSurprise(
    String relationshipId,
    String surpriseId,
    Map<String, dynamic> updates,
  ) async {
    await databaseReference
        .child('relationships/$relationshipId/surprises/$surpriseId')
        .update(updates);
  }

  Future<void> deleteSurprise(String relationshipId, String surpriseId) async {
    await databaseReference
        .child('relationships/$relationshipId/surprises/$surpriseId')
        .remove();
  }

  Stream<Map<String, dynamic>> getSurprisesStream(String relationshipId) {
    return databaseReference
        .child('relationships/$relationshipId/surprises')
        .onValue
        .map((event) {
          if (event.snapshot.value == null) {
            return {};
          }
          return Map<String, dynamic>.from(event.snapshot.value as Map);
        });
  }

  Future<void> markSurpriseAsRead(
    String relationshipId,
    String surpriseId,
  ) async {
    await databaseReference
        .child('relationships/$relationshipId/surprises/$surpriseId')
        .update({'isRead': true});
  }

  /// ? Gerações, Ordenações e Mapas
  /// ? Jogo Pedra Papel Tesoura
  Future<void> updateRPSSelection(
    String relationshipId,
    String userId,
    String selection,
  ) async {
    await databaseReference
        .child('relationships/$relationshipId/rps/$userId')
        .update({'selection': selection, 'confirmed': false});
  }

  Future<void> confirmRPSSelection(String relationshipId, String userId) async {
    await databaseReference
        .child('relationships/$relationshipId/rps/$userId')
        .update({'confirmed': true});
  }

  Future<void> updateRPSScores(
    String relationshipId,
    String winnerId, {
    String? partnerId,
  }) async {
    await databaseReference
        .child('relationships/$relationshipId/rps/scores/$winnerId')
        .set(ServerValue.increment(1));

    if (partnerId != null) {
      final snapshot = await databaseReference
          .child('relationships/$relationshipId/rps/scores/$winnerId')
          .get();
      if (snapshot.exists) {
        final score = snapshot.value as int;
        if (score == 1) {
          _notifyAchievement(
            partnerId,
            'Sorte de Principiante',
            'Venceu a primeira partida!',
          );
        }
        if (score == 10) {
          _notifyAchievement(
            partnerId,
            'Competitivo',
            'Venceu 10 partidas de PPT!',
          );
        }
        if (score == 50) {
          _notifyAchievement(
            partnerId,
            'Mestre do Jokenpô',
            'Venceu 50 partidas!',
          );
        }
        if (score == 100) {
          _notifyAchievement(
            partnerId,
            'Lenda do Jokenpô',
            '100 vitórias! Incrível!',
          );
        }
      }
    }
  }

  Future<void> resetRPSRound(String relationshipId) async {
    await databaseReference
        .child('relationships/$relationshipId/rps')
        .update({});
    final snapshot = await databaseReference
        .child('relationships/$relationshipId/rps')
        .get();
    if (snapshot.exists) {
      final data = snapshot.value as Map;
      data.forEach((key, value) {
        if (key != 'scores') {
          databaseReference
              .child('relationships/$relationshipId/rps/$key')
              .update({'selection': '', 'confirmed': false});
        }
      });
    }
  }

  Future<void> resetRPSScores(String relationshipId) async {
    await databaseReference
        .child('relationships/$relationshipId/rps/scores')
        .remove();
  }

  Stream<Map<String, dynamic>> getRPSStream(String relationshipId) {
    return databaseReference
        .child('relationships/$relationshipId/rps')
        .onValue
        .map((event) {
          final snapshot = event.snapshot;
          if (snapshot.exists && snapshot.value != null) {
            return Map<String, dynamic>.from(snapshot.value as Map);
          }
          return <String, dynamic>{};
        });
  }

  String _generateRelationshipId(String authorId, String partnerId) {
    final prefix = 'rel-';
    final a = (authorId.hashCode).abs() % 10000;
    final b = (partnerId.hashCode).abs() % 10000;
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

  /// ? Momentos
  Future<void> createMoment(
    String relationshipId,
    Map<String, dynamic> momentData,
  ) async {
    final newMomentRef = databaseReference
        .child('relationships/$relationshipId/moments')
        .push();

    momentData['id'] = newMomentRef.key;
    momentData['createdAt'] = DateTime.now().toIso8601String();
    momentData['isCompleted'] = false;

    await newMomentRef.set(momentData);
  }

  Future<void> updateMoment(
    String relationshipId,
    String momentId,
    Map<String, dynamic> updates,
  ) async {
    await databaseReference
        .child('relationships/$relationshipId/moments/$momentId')
        .update(updates);
  }

  Future<void> deleteMoment(String relationshipId, String momentId) async {
    await databaseReference
        .child('relationships/$relationshipId/moments/$momentId')
        .remove();
  }

  Future<void> markMomentAsCompleted(
    String relationshipId,
    String momentId,
  ) async {
    await databaseReference
        .child('relationships/$relationshipId/moments/$momentId')
        .update({
          'isCompleted': true,
          'completedAt': DateTime.now().toIso8601String(),
        });
  }

  Stream<Map<String, dynamic>> getMomentsStream(String relationshipId) {
    return databaseReference
        .child('relationships/$relationshipId/moments')
        .onValue
        .map((event) {
          if (event.snapshot.value == null) {
            return {};
          }
          return Map<String, dynamic>.from(event.snapshot.value as Map);
        });
  }

  Future<void> _notifyAchievement(
    String partnerId,
    String title,
    String body,
  ) async {
    final token = await getMessagerToken(partnerId);
    if (token != null) {
      await ApiService().sendNotification(
        token,
        "Conquista Desbloqueada! 🏆",
        "$title: $body",
      );
    }
  }
}
