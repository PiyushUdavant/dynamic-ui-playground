import 'package:flutter/widgets.dart';

abstract class BaseDS<T extends Widget> {
  const BaseDS();
  String get type;
  T build();
  Map<String, dynamic> toJson();
}

