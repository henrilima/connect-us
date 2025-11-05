import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter/material.dart';

class IconHelper {
  static const Map<String, IconData> icons = {
    'nodes': FontAwesomeIcons.circleNodes,
    'heart': FontAwesomeIcons.heart,
    'users': FontAwesomeIcons.users,
    'fire': FontAwesomeIcons.fire,
    'bed': FontAwesomeIcons.bed,
    'wine_glass': FontAwesomeIcons.wineGlass,
    'camera': FontAwesomeIcons.camera,
    'images': FontAwesomeIcons.images,
    'star': FontAwesomeIcons.star,
    'calendar_heart': FontAwesomeIcons.solidCalendarDays,
    'film': FontAwesomeIcons.film,
    'gamepad': FontAwesomeIcons.gamepad,
    'music': FontAwesomeIcons.music,
    'pizza_slice': FontAwesomeIcons.pizzaSlice,
    'rocket': FontAwesomeIcons.rocket,
    'bolt': FontAwesomeIcons.bolt,
    'globe': FontAwesomeIcons.globe,
    'book': FontAwesomeIcons.book,
    'paper_plane': FontAwesomeIcons.paperPlane,
    'thumbs_up': FontAwesomeIcons.thumbsUp,
    'bell': FontAwesomeIcons.bell,
    'comments': FontAwesomeIcons.comments,
    'lock': FontAwesomeIcons.lock,
    'search': FontAwesomeIcons.magnifyingGlass,
    'edit': FontAwesomeIcons.pen,
    'compass': FontAwesomeIcons.compass,
    'gift': FontAwesomeIcons.gift,
    'puzzle_piece': FontAwesomeIcons.puzzlePiece,
    'kiss': FontAwesomeIcons.faceKiss,
    'kiss_wink': FontAwesomeIcons.faceKissWinkHeart,
    'ring': FontAwesomeIcons.ring,
    'champagne': FontAwesomeIcons.champagneGlasses,
    'hand_heart': FontAwesomeIcons.handHoldingHeart,
    'heartbeat': FontAwesomeIcons.heartPulse,
    'handshake': FontAwesomeIcons.handshake,
    'jetfighter': FontAwesomeIcons.jetFighterUp,
  };

  static IconData getIcon(String key) {
    return icons[key] ?? FontAwesomeIcons.solidHeart;
  }
}
