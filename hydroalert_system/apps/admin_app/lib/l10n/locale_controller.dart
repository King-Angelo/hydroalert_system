import 'package:flutter/material.dart';

abstract final class LocaleController {
  static final ValueNotifier<Locale> locale = ValueNotifier(const Locale('en'));

  static void setLocale(Locale next) {
    locale.value = next;
  }
}
