import 'package:flutter/material.dart';
import '../base_ds.dart';
import '../../utils/common_props.dart';

class IconDS extends BaseDS<Icon> {
  IconDS({required this.iconName, this.color, this.size})
    : icon = _iconFromName(iconName);
  final String iconName;
  final IconData icon;
  final Color? color;
  final double? size;

  @override
  String get type => 'icon';

  @override
  Icon build() => Icon(icon, color: color, size: size);

  factory IconDS.fromJson(Map<String, dynamic> json) => IconDS(
    iconName: (json['icon'] ?? 'mic').toString(),
    color: CommonProps.parseColor(json['color']),
    size: (json['size'] as num?)?.toDouble(),
  );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'icon': iconName,
    if (color != null) 'color': CommonProps.colorToHex(color),
    if (size != null) 'size': size,
  };
}

const Map<String, IconData> _materialIconMap = {
  // Actions
  'add': Icons.add,
  'add_circle': Icons.add_circle,
  'add_circle_outline': Icons.add_circle_outline,
  'close': Icons.close,
  'check': Icons.check,
  'check_circle': Icons.check_circle,
  'check_circle_outline': Icons.check_circle_outline,
  'remove': Icons.remove,
  'remove_circle': Icons.remove_circle,
  'remove_circle_outline': Icons.remove_circle_outline,
  'delete': Icons.delete,
  'edit': Icons.edit,
  'save': Icons.save,
  'share': Icons.share,
  'download': Icons.download,
  'upload': Icons.upload,
  'favorite': Icons.favorite,
  'favorite_border': Icons.favorite_border,
  'star': Icons.star,
  'star_border': Icons.star_border,
  'info': Icons.info,
  'info_outline': Icons.info_outline,
  'warning': Icons.warning,
  'error': Icons.error,
  'help': Icons.help,
  'help_outline': Icons.help_outline,

  // Navigation
  'menu': Icons.menu,
  'more_vert': Icons.more_vert,
  'more_horiz': Icons.more_horiz,
  'arrow_back': Icons.arrow_back,
  'arrow_forward': Icons.arrow_forward,
  'arrow_upward': Icons.arrow_upward,
  'arrow_downward': Icons.arrow_downward,
  'chevron_left': Icons.chevron_left,
  'chevron_right': Icons.chevron_right,
  'keyboard_arrow_left': Icons.keyboard_arrow_left,
  'keyboard_arrow_right': Icons.keyboard_arrow_right,
  'keyboard_arrow_up': Icons.keyboard_arrow_up,
  'keyboard_arrow_down': Icons.keyboard_arrow_down,
  'home': Icons.home,
  'search': Icons.search,
  'settings': Icons.settings,
  'logout': Icons.logout,

  // Communication
  'email': Icons.email,
  'mail': Icons.mail,
  'phone': Icons.phone,
  'chat': Icons.chat,
  'send': Icons.send,
  'mic': Icons.mic,

  // Media
  'play_arrow': Icons.play_arrow,
  'pause': Icons.pause,
  'stop': Icons.stop,
  'volume_up': Icons.volume_up,
  'volume_off': Icons.volume_off,
  'camera_alt': Icons.camera_alt,
  'image': Icons.image,
  'photo': Icons.photo,

  // Content
  'list': Icons.list,
  'calendar_today': Icons.calendar_today,
  'event': Icons.event,
  'alarm': Icons.alarm,
  'timer': Icons.timer,
  'map': Icons.map,
  'location_on': Icons.location_on,
  'shopping_cart': Icons.shopping_cart,
  'shopping_bag': Icons.shopping_bag,
  'visibility': Icons.visibility,
  'visibility_off': Icons.visibility_off,
  'build': Icons.build,
  'lock': Icons.lock,
  'lock_open': Icons.lock_open,
  'person': Icons.person,
  'account_circle': Icons.account_circle,
};

String _normalizeIconKey(String name) {
  return name.trim().toLowerCase().replaceAll(' ', '_');
}

IconData _iconFromName(String name) {
  final key = _normalizeIconKey(name);
  return _materialIconMap[key] ?? Icons.circle;
}
