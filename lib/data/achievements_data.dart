import 'package:connect/ui/app_color.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

enum AchievementCategory { amor, tempo, perfil, especial }

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final AchievementCategory category;
  final bool isSecret;
  final bool Function(
    Map<String, dynamic> userData,
    Map<String, dynamic> partnerData,
    Map<String, dynamic> relationshipData,
    List<Map<String, dynamic>> timeline,
  )
  isUnlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    this.isSecret = false,
    required this.isUnlocked,
  });

  Color get color {
    switch (category) {
      case AchievementCategory.amor:
        return AppColors.errorColorHover;
      case AchievementCategory.tempo:
        return AppColors.primaryColorHover;
      case AchievementCategory.perfil:
        return AppColors.successColorHover;
      case AchievementCategory.especial:
        return Colors.amber;
    }
  }
}

final List<Achievement> allAchievements = [
  // ? TEMPO
  Achievement(
    id: '1_month',
    title: 'Primeiro Mês',
    description: 'Comemorando 1 mês!',
    icon: FontAwesomeIcons.solidHeart,
    category: AchievementCategory.tempo,
    isUnlocked: (user, partner, rel, timeline) {
      final dateStr = rel['relationshipDate'];
      if (dateStr == null) return false;
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      return now.difference(date).inDays >= 30;
    },
  ),
  Achievement(
    id: '100_days',
    title: '100 Dias Juntos',
    description: 'Uma centena de dias compartilhados.',
    icon: FontAwesomeIcons.calendarCheck,
    category: AchievementCategory.tempo,
    isUnlocked: (user, partner, rel, timeline) {
      final dateStr = rel['relationshipDate'];
      if (dateStr == null) return false;
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      return now.difference(date).inDays >= 100;
    },
  ),
  Achievement(
    id: '6_months',
    title: 'Metade do Ano',
    description: '6 meses construindo uma história.',
    icon: FontAwesomeIcons.starHalfStroke,
    category: AchievementCategory.tempo,
    isUnlocked: (user, partner, rel, timeline) {
      final dateStr = rel['relationshipDate'];
      if (dateStr == null) return false;
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      return now.difference(date).inDays >= 180;
    },
  ),
  Achievement(
    id: '1_year',
    title: 'Primeiro Ano',
    description: '365 dias de parceria e amor.',
    icon: FontAwesomeIcons.cakeCandles,
    category: AchievementCategory.tempo,
    isUnlocked: (user, partner, rel, timeline) {
      final dateStr = rel['relationshipDate'];
      if (dateStr == null) return false;
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      return now.difference(date).inDays >= 365;
    },
  ),
  Achievement(
    id: '2_years',
    title: 'Dois Anos',
    description: 'Dois anos de cumplicidade.',
    icon: FontAwesomeIcons.userGroup,
    category: AchievementCategory.tempo,
    isUnlocked: (user, partner, rel, timeline) {
      final dateStr = rel['relationshipDate'];
      if (dateStr == null) return false;
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      return now.difference(date).inDays >= 730;
    },
  ),
  Achievement(
    id: '3_years',
    title: 'Três Anos',
    description: 'Três anos de pura magia.',
    icon: FontAwesomeIcons.wandMagicSparkles,
    category: AchievementCategory.tempo,
    isUnlocked: (user, partner, rel, timeline) {
      final dateStr = rel['relationshipDate'];
      if (dateStr == null) return false;
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      return now.difference(date).inDays >= 1095;
    },
  ),
  Achievement(
    id: '5_years',
    title: 'Bodas de Madeira',
    description: '5 anos de um amor sólido.',
    icon: FontAwesomeIcons.tree,
    category: AchievementCategory.tempo,
    isUnlocked: (user, partner, rel, timeline) {
      final dateStr = rel['relationshipDate'];
      if (dateStr == null) return false;
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      return now.difference(date).inDays >= 1825;
    },
  ),
  Achievement(
    id: '1000_days',
    title: 'Mil Dias',
    description: 'Um marco incrível de 1000 dias!',
    icon: FontAwesomeIcons.crown,
    category: AchievementCategory.tempo,
    isUnlocked: (user, partner, rel, timeline) {
      final dateStr = rel['relationshipDate'];
      if (dateStr == null) return false;
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      return now.difference(date).inDays >= 1000;
    },
  ),
  Achievement(
    id: 'crystal_wedding',
    title: 'Bodas de Cristal',
    description: '15 anos de uma linda história.',
    icon: FontAwesomeIcons.gem,
    category: AchievementCategory.tempo,
    isUnlocked: (user, partner, rel, timeline) {
      final dateStr = rel['relationshipDate'];
      if (dateStr == null) return false;
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      return now.difference(date).inDays >= 5475;
    },
  ),
  Achievement(
    id: 'movie_night',
    title: 'Cinema em Casa',
    description: 'Maratona de filmes ou séries.',
    icon: FontAwesomeIcons.film,
    category: AchievementCategory.tempo,
    isSecret: true,
    isUnlocked: (user, partner, rel, timeline) {
      for (final event in timeline) {
        final title = (event['title'] as String? ?? '').toLowerCase();
        if (title.contains('filme') ||
            title.contains('série') ||
            title.contains('netflix') ||
            title.contains('cinema')) {
          return true;
        }
      }
      return false;
    },
  ),

  // ? AMOR
  Achievement(
    id: 'affectionate',
    title: 'Carinhosos',
    description: 'Trocaram mais de 100 beijos/abraços no app.',
    icon: FontAwesomeIcons.solidFaceKiss,
    category: AchievementCategory.amor,
    isUnlocked: (user, partner, rel, timeline) {
      final counters = rel['counters'];
      if (counters == null) return false;
      final kisses = counters['kissCount'] ?? 0;
      final hugs = counters['hugCount'] ?? 0;
      return (kisses + hugs) >= 100;
    },
  ),
  Achievement(
    id: 'kiss_addict',
    title: 'Viciado em Beijos',
    description: 'Mais de 500 beijos trocados!',
    icon: FontAwesomeIcons.faceKiss,
    category: AchievementCategory.amor,
    isUnlocked: (user, partner, rel, timeline) {
      final counters = rel['counters'];
      if (counters == null) return false;
      final kisses = counters['kissCount'] ?? 0;
      return kisses >= 500;
    },
  ),
  Achievement(
    id: 'kiss_master',
    title: 'Mestre dos Beijos',
    description: 'Incríveis 1000 beijos registrados!',
    icon: FontAwesomeIcons.faceKissWinkHeart,
    category: AchievementCategory.amor,
    isUnlocked: (user, partner, rel, timeline) {
      final counters = rel['counters'];
      if (counters == null) return false;
      final kisses = counters['kissCount'] ?? 0;
      return kisses >= 1000;
    },
  ),
  Achievement(
    id: 'bear_hug',
    title: 'Abraço de Urso',
    description: 'Mais de 500 abraços trocados!',
    icon: FontAwesomeIcons.solidFaceGrinBeam,
    category: AchievementCategory.amor,
    isUnlocked: (user, partner, rel, timeline) {
      final counters = rel['counters'];
      if (counters == null) return false;
      final hugs = counters['hugCount'] ?? 0;
      return hugs >= 500;
    },
  ),
  Achievement(
    id: 'hug_master',
    title: 'Mestre dos Abraços',
    description: '1000 abraços quentinhos!',
    icon: FontAwesomeIcons.handsHoldingCircle,
    category: AchievementCategory.amor,
    isUnlocked: (user, partner, rel, timeline) {
      final counters = rel['counters'];
      if (counters == null) return false;
      final hugs = counters['hugCount'] ?? 0;
      return hugs >= 1000;
    },
  ),
  Achievement(
    id: 'quiz_master',
    title: 'Autoconhecimento',
    description: 'Descobriu suas linguagens do amor.',
    icon: FontAwesomeIcons.bookOpen,
    category: AchievementCategory.amor,
    isUnlocked: (user, partner, rel, timeline) {
      if (user.containsKey('love-languages')) return true;
      return timeline.length >= 5;
    },
  ),
  Achievement(
    id: 'first_time',
    title: 'Primeira Vez',
    description: 'Um momento íntimo e especial registrado.',
    icon: FontAwesomeIcons.fire,
    category: AchievementCategory.amor,
    isSecret: true,
    isUnlocked: (user, partner, rel, timeline) {
      for (final event in timeline) {
        final title = (event['title'] as String? ?? '').toLowerCase();
        final desc = (event['description'] as String? ?? '').toLowerCase();
        if (title.contains('sexo') ||
            title.contains('amorzinho') ||
            title.contains('transa') ||
            desc.contains('sexo') ||
            desc.contains('amorzinho') ||
            desc.contains('transa')) {
          return true;
        }
      }
      return false;
    },
  ),
  Achievement(
    id: 'hot_night',
    title: 'Noite Quente',
    description: 'A temperatura subiu!',
    icon: FontAwesomeIcons.temperatureArrowUp,
    category: AchievementCategory.amor,
    isSecret: true,
    isUnlocked: (user, partner, rel, timeline) {
      for (final event in timeline) {
        final title = (event['title'] as String? ?? '').toLowerCase();
        if (title.contains('quente') || title.contains('hot')) {
          return true;
        }
      }
      return false;
    },
  ),
  Achievement(
    id: 'naughty',
    title: 'Safadinhos',
    description: 'Momentos picantes registrados.',
    icon: FontAwesomeIcons.pepperHot,
    category: AchievementCategory.amor,
    isSecret: true,
    isUnlocked: (user, partner, rel, timeline) {
      for (final event in timeline) {
        final title = (event['title'] as String? ?? '').toLowerCase();
        if (title.contains('nudes') ||
            title.contains('safadeza') ||
            title.contains('picante')) {
          return true;
        }
      }
      return false;
    },
  ),
  Achievement(
    id: 'sleepyheads',
    title: 'Dorminhocos',
    description: 'Dormiram juntinhos.',
    icon: FontAwesomeIcons.bed,
    category: AchievementCategory.amor,
    isSecret: true,
    isUnlocked: (user, partner, rel, timeline) {
      for (final event in timeline) {
        final title = (event['title'] as String? ?? '').toLowerCase();
        if (title.contains('dormir') ||
            title.contains('sono') ||
            title.contains('dormimos') ||
            title.contains('dormimos')) {
          return true;
        }
      }
      return false;
    },
  ),
  Achievement(
    id: 'romantic_dinner',
    title: 'Jantar Romântico',
    description: 'Uma refeição especial a dois.',
    icon: FontAwesomeIcons.utensils,
    category: AchievementCategory.amor,
    isSecret: true,
    isUnlocked: (user, partner, rel, timeline) {
      for (final event in timeline) {
        final title = (event['title'] as String? ?? '').toLowerCase();
        if (title.contains('jantar') ||
            title.contains('restaurante') ||
            title.contains('comida')) {
          return true;
        }
      }
      return false;
    },
  ),
  Achievement(
    id: 'surprise_sender',
    title: 'Surpresa!',
    description: 'Agendou uma surpresa para o futuro.',
    icon: FontAwesomeIcons.gift,
    category: AchievementCategory.amor,
    isUnlocked: (user, partner, rel, timeline) {
      final surprises = rel['surprises'];
      if (surprises == null || surprises is! Map) return false;
      final myId = user['userId'];
      for (final s in surprises.values) {
        if (s['senderUid'] == myId) return true;
      }
      return false;
    },
  ),
  Achievement(
    id: 'romantic_soul',
    title: 'Romântico Incorrigível',
    description: 'Agendou 5 surpresas para o parceiro(a).',
    icon: FontAwesomeIcons.heartPulse,
    category: AchievementCategory.amor,
    isUnlocked: (user, partner, rel, timeline) {
      final surprises = rel['surprises'];
      if (surprises == null || surprises is! Map) return false;
      final myId = user['userId'];
      int count = 0;
      for (final s in surprises.values) {
        if (s['senderUid'] == myId) count++;
      }
      return count >= 5;
    },
  ),
  Achievement(
    id: 'emotional_sync',
    title: 'Sintonia Emocional',
    description: 'Ambos definiram como estão se sentindo.',
    icon: FontAwesomeIcons.masksTheater,
    category: AchievementCategory.amor,
    isUnlocked: (user, partner, rel, timeline) {
      return user.containsKey('feeling') && partner.containsKey('feeling');
    },
  ),
  Achievement(
    id: 'thinking_of_you',
    title: 'Pensando em Você',
    description: 'Enviou um "Amor" para o parceiro.',
    icon: FontAwesomeIcons.paperPlane,
    category: AchievementCategory.amor,
    isUnlocked: (user, partner, rel, timeline) {
      final pings = rel['love_pings'];
      if (pings == null || pings is! Map) return false;
      return pings.containsKey(user['userId']);
    },
  ),
  Achievement(
    id: 'total_connection',
    title: 'Conexão Total',
    description: 'Ambos enviaram "Amor" um ao outro.',
    icon: FontAwesomeIcons.heartCircleBolt,
    category: AchievementCategory.amor,
    isUnlocked: (user, partner, rel, timeline) {
      final pings = rel['love_pings'];
      if (pings == null || pings is! Map) return false;
      return pings.containsKey(user['userId']) &&
          pings.containsKey(partner['userId']);
    },
  ),

  // ? PERFIL
  Achievement(
    id: 'who_is_who',
    title: 'Quem é Quem?',
    description: 'Ambos personalizaram seus nomes de usuário.',
    icon: FontAwesomeIcons.idCard,
    category: AchievementCategory.perfil,
    isUnlocked: (user, partner, rel, timeline) {
      final myName = user['username'];
      final partnerName = partner['username'];
      final myId = user['userId'];
      final partnerId = partner['userId'];
      return myName != myId && partnerName != partnerId;
    },
  ),
  Achievement(
    id: 'pretty_faces',
    title: 'Rostinhos Bonitos',
    description: 'Ambos adicionaram foto de perfil.',
    icon: FontAwesomeIcons.solidImage,
    category: AchievementCategory.perfil,
    isUnlocked: (user, partner, rel, timeline) {
      return user.containsKey('photoUrl') && partner.containsKey('photoUrl');
    },
  ),
  Achievement(
    id: 'first_memory',
    title: 'Primeira Memória',
    description: 'Adicionou o primeiro evento na linha do tempo.',
    icon: FontAwesomeIcons.cameraRetro,
    category: AchievementCategory.perfil,
    isUnlocked: (user, partner, rel, timeline) {
      return timeline.isNotEmpty;
    },
  ),
  Achievement(
    id: 'diary',
    title: 'Diário de Bordo',
    description: 'Mais de 20 memórias registradas.',
    icon: FontAwesomeIcons.bookJournalWhills,
    category: AchievementCategory.perfil,
    isUnlocked: (user, partner, rel, timeline) {
      return timeline.length >= 20;
    },
  ),
  Achievement(
    id: 'historian',
    title: 'Historiador',
    description: '50 momentos inesquecíveis guardados.',
    icon: FontAwesomeIcons.scroll,
    category: AchievementCategory.perfil,
    isUnlocked: (user, partner, rel, timeline) {
      return timeline.length >= 50;
    },
  ),
  Achievement(
    id: 'legendary_book',
    title: 'Livro Lendário',
    description: '100 memórias! Uma vida juntos.',
    icon: FontAwesomeIcons.bookAtlas,
    category: AchievementCategory.perfil,
    isUnlocked: (user, partner, rel, timeline) {
      return timeline.length >= 100;
    },
  ),
  Achievement(
    id: 'daily_photographer',
    title: 'Fotógrafo Diário',
    description: 'Postou uma foto no Registro Único.',
    icon: FontAwesomeIcons.camera,
    category: AchievementCategory.perfil,
    isUnlocked: (user, partner, rel, timeline) {
      final photos = rel['photos'];
      if (photos == null || photos is! Map) return false;
      return photos.containsKey(user['userId']);
    },
  ),
  Achievement(
    id: 'photogenic_couple',
    title: 'Casal Fotogênico',
    description: 'Ambos postaram suas fotos diárias.',
    icon: FontAwesomeIcons.images,
    category: AchievementCategory.perfil,
    isUnlocked: (user, partner, rel, timeline) {
      final photos = rel['photos'];
      if (photos == null || photos is! Map) return false;
      return photos.containsKey(user['userId']) &&
          photos.containsKey(partner['userId']);
    },
  ),
  Achievement(
    id: 'feeling_good',
    title: 'Como me sinto',
    description: 'Definiu seu status de sentimento.',
    icon: FontAwesomeIcons.faceSmile,
    category: AchievementCategory.perfil,
    isUnlocked: (user, partner, rel, timeline) {
      return user.containsKey('feeling');
    },
  ),

  // ? ESPECIAL
  Achievement(
    id: 'travelers',
    title: 'Viajantes',
    description: 'Registraram uma viagem juntos.',
    icon: FontAwesomeIcons.plane,
    category: AchievementCategory.especial,
    isUnlocked: (user, partner, rel, timeline) {
      for (final event in timeline) {
        final title = (event['title'] as String? ?? '').toLowerCase();
        if (title.contains('viagem') ||
            title.contains('trip') ||
            title.contains('férias') ||
            title.contains('praia')) {
          return true;
        }
      }
      return false;
    },
  ),
  Achievement(
    id: 'rps_novice',
    title: 'Sorte de Principiante',
    description: 'Venceu sua primeira partida de PPT.',
    icon: FontAwesomeIcons.handFist,
    category: AchievementCategory.especial,
    isUnlocked: (user, partner, rel, timeline) {
      final rps = rel['rps'];
      if (rps == null || rps['scores'] == null) return false;
      final myScore = rps['scores'][user['userId']] ?? 0;
      return myScore >= 1;
    },
  ),
  Achievement(
    id: 'rps_competitor',
    title: 'Competitivo',
    description: 'Venceu 10 partidas de Pedra, Papel e Tesoura.',
    icon: FontAwesomeIcons.hand,
    category: AchievementCategory.especial,
    isUnlocked: (user, partner, rel, timeline) {
      final rps = rel['rps'];
      if (rps == null || rps['scores'] == null) return false;
      final myScore = rps['scores'][user['userId']] ?? 0;
      return myScore >= 10;
    },
  ),
  Achievement(
    id: 'rps_master',
    title: 'Mestre do Jokenpô',
    description: 'Venceu 50 partidas! Ninguém te segura.',
    icon: FontAwesomeIcons.handScissors,
    category: AchievementCategory.especial,
    isUnlocked: (user, partner, rel, timeline) {
      final rps = rel['rps'];
      if (rps == null || rps['scores'] == null) return false;
      final myScore = rps['scores'][user['userId']] ?? 0;
      return myScore >= 50;
    },
  ),
  Achievement(
    id: 'rps_legend',
    title: 'Lenda do Jokenpô',
    description: '100 vitórias! Você lê mentes?',
    icon: FontAwesomeIcons.brain,
    category: AchievementCategory.especial,
    isUnlocked: (user, partner, rel, timeline) {
      final rps = rel['rps'];
      if (rps == null || rps['scores'] == null) return false;
      final myScore = rps['scores'][user['userId']] ?? 0;
      return myScore >= 100;
    },
  ),
  Achievement(
    id: 'busy_month',
    title: 'Mês Agitado',
    description: '10 memórias em pouco tempo!',
    icon: FontAwesomeIcons.bolt,
    category: AchievementCategory.especial,
    isSecret: true,
    isUnlocked: (user, partner, rel, timeline) {
      return timeline.length >= 10;
    },
  ),
  Achievement(
    id: 'super_busy_month',
    title: 'Mês Inesquecível',
    description: '30 memórias registradas! Uau!',
    icon: FontAwesomeIcons.explosion,
    category: AchievementCategory.especial,
    isSecret: true,
    isUnlocked: (user, partner, rel, timeline) {
      return timeline.length >= 30;
    },
  ),
  Achievement(
    id: 'dj_love',
    title: 'DJ do Amor',
    description: 'Dedicou uma música para o seu amor.',
    icon: FontAwesomeIcons.music,
    category: AchievementCategory.especial,
    isUnlocked: (user, partner, rel, timeline) {
      return partner.containsKey('partner-music');
    },
  ),
  Achievement(
    id: 'musical_harmony',
    title: 'Sintonia Musical',
    description: 'Ambos dedicaram músicas um ao outro.',
    icon: FontAwesomeIcons.headphones,
    category: AchievementCategory.especial,
    isUnlocked: (user, partner, rel, timeline) {
      return user.containsKey('partner-music') &&
          partner.containsKey('partner-music');
    },
  ),
  Achievement(
    id: 'first_plan',
    title: 'Primeiro Plano',
    description: 'Criaram um item na lista de Momentos.',
    icon: FontAwesomeIcons.list,
    category: AchievementCategory.especial,
    isUnlocked: (user, partner, rel, timeline) {
      final moments = rel['moments'];
      return moments != null && moments is Map && moments.isNotEmpty;
    },
  ),
  Achievement(
    id: 'dream_makers',
    title: 'Realizadores',
    description: 'Concluíram um Momento juntos.',
    icon: FontAwesomeIcons.checkDouble,
    category: AchievementCategory.especial,
    isUnlocked: (user, partner, rel, timeline) {
      final moments = rel['moments'];
      if (moments == null || moments is! Map) return false;
      for (final m in moments.values) {
        if (m['isCompleted'] == true) return true;
      }
      return false;
    },
  ),
  Achievement(
    id: 'full_list',
    title: 'Lista dos Sonhos',
    description: 'Criaram 10 momentos para realizar.',
    icon: FontAwesomeIcons.clipboardList,
    category: AchievementCategory.especial,
    isUnlocked: (user, partner, rel, timeline) {
      final moments = rel['moments'];
      if (moments == null || moments is! Map) return false;
      return moments.length >= 10;
    },
  ),
  Achievement(
    id: 'unlucky',
    title: 'Azarado no Jogo',
    description: 'Perdeu 10 vezes no Pedra, Papel e Tesoura.',
    icon: FontAwesomeIcons.heartCrack,
    category: AchievementCategory.especial,
    isUnlocked: (user, partner, rel, timeline) {
      final rps = rel['rps'];
      if (rps == null || rps['scores'] == null) return false;
      final partnerScore = rps['scores'][partner['userId']] ?? 0;
      return partnerScore >= 10;
    },
  ),
];
