import 'dart:async';
import 'package:connect/components/header.dart';
import 'package:connect/data/achievements_data.dart';
import 'package:connect/services/database_service.dart';
import 'package:connect/ui/app_color.dart';
import 'package:connect/widgets/fade_in.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AchievementsScreen extends StatefulWidget {
  final Function setPage;
  final Map<String, dynamic> userData;

  const AchievementsScreen(this.setPage, {super.key, required this.userData});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  Map<String, dynamic> _relationshipData = {};
  Map<String, dynamic> _partnerData = {};
  List<Map<String, dynamic>> _timelineData = [];
  StreamSubscription? _relationshipSubscription;
  StreamSubscription? _timelineSubscription;
  StreamSubscription? _partnerSubscription;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  @override
  void dispose() {
    _relationshipSubscription?.cancel();
    _timelineSubscription?.cancel();
    _partnerSubscription?.cancel();
    super.dispose();
  }

  void _startListening() {
    final relationshipId = widget.userData['relationshipId'];
    final partnerId = widget.userData['partnerId'];

    _relationshipSubscription = DatabaseService().databaseReference
        .child('relationships/$relationshipId')
        .onValue
        .listen((event) {
          if (event.snapshot.exists && mounted) {
            setState(() {
              _relationshipData = Map<String, dynamic>.from(
                event.snapshot.value as Map,
              );
            });
          }
        });

    _partnerSubscription = DatabaseService().getPartnerStream(partnerId).listen(
      (data) {
        if (mounted) {
          setState(() {
            _partnerData = data;
          });
        }
      },
    );

    _timelineSubscription = DatabaseService()
        .getTimelineStream(relationshipId)
        .listen((data) {
          if (mounted) {
            setState(() {
              _timelineData = data.values
                  .map((e) => Map<String, dynamic>.from(e as Map))
                  .toList();
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final visibleAchievements = allAchievements.where((achievement) {
      final isUnlocked = achievement.isUnlocked(
        widget.userData,
        _partnerData,
        _relationshipData,
        _timelineData,
      );

      return !achievement.isSecret || isUnlocked;
    }).toList();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(widget.setPage, true, title: 'Hall de Conquistas'),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: visibleAchievements.length,
                itemBuilder: (context, index) {
                  final achievement = visibleAchievements[index];
                  final isUnlocked = achievement.isUnlocked(
                    widget.userData,
                    _partnerData,
                    _relationshipData,
                    _timelineData,
                  );

                  return FadeIn(
                    delay: Duration(milliseconds: index * 50),
                    child: _buildAchievementCard(achievement, isUnlocked),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement, bool isUnlocked) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.drawerBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: isUnlocked
            ? Border.all(color: achievement.color.withAlpha(128), width: 2)
            : null,
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: achievement.color.withAlpha(51),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? achievement.color.withAlpha(26)
                  : Colors.grey.withAlpha(26),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isUnlocked ? achievement.icon : FontAwesomeIcons.lock,
              size: 32,
              color: isUnlocked ? achievement.color : Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            achievement.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isUnlocked ? AppColors.textColor : Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              achievement.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isUnlocked ? AppColors.textColorSecondary : Colors.grey,
                height: 1.2,
              ),
            ),
          ),
          if (isUnlocked) ...[
            const SizedBox(height: 12),
            Icon(Icons.check_circle, size: 16, color: achievement.color),
          ],
        ],
      ),
    );
  }
}
