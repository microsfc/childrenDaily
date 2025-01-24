// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Are you sure to delete?`
  String get areYouSureToDelete {
    return Intl.message(
      'Are you sure to delete?',
      name: 'areYouSureToDelete',
      desc: '',
      args: [],
    );
  }

  /// `Delete successfully!`
  String get deleteSuccess {
    return Intl.message(
      'Delete successfully!',
      name: 'deleteSuccess',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get confirm {
    return Intl.message(
      'Confirm',
      name: 'confirm',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Activity Record`
  String get activityRecord {
    return Intl.message(
      'Activity Record',
      name: 'activityRecord',
      desc: '',
      args: [],
    );
  }

  /// `Timeline`
  String get timeline {
    return Intl.message(
      'Timeline',
      name: 'timeline',
      desc: '',
      args: [],
    );
  }

  /// `Search Keyword`
  String get searchKeyword {
    return Intl.message(
      'Search Keyword',
      name: 'searchKeyword',
      desc: '',
      args: [],
    );
  }

  /// `No record found`
  String get noRecordFound {
    return Intl.message(
      'No record found',
      name: 'noRecordFound',
      desc: '',
      args: [],
    );
  }

  /// `Error occurred`
  String get errorOccurred {
    return Intl.message(
      'Error occurred',
      name: 'errorOccurred',
      desc: '',
      args: [],
    );
  }

  /// `Please select date and input record`
  String get pleaseSelectDateAndInputRecord {
    return Intl.message(
      'Please select date and input record',
      name: 'pleaseSelectDateAndInputRecord',
      desc: '',
      args: [],
    );
  }

  /// `Add Baby Record`
  String get addBabyRecord {
    return Intl.message(
      'Add Baby Record',
      name: 'addBabyRecord',
      desc: '',
      args: [],
    );
  }

  /// `Please select date`
  String get pleaseSelectDate {
    return Intl.message(
      'Please select date',
      name: 'pleaseSelectDate',
      desc: '',
      args: [],
    );
  }

  /// `Select Date`
  String get selectDate {
    return Intl.message(
      'Select Date',
      name: 'selectDate',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get date {
    return Intl.message(
      'Date',
      name: 'date',
      desc: '',
      args: [],
    );
  }

  /// `Please select photo`
  String get pleaseSelectPhoto {
    return Intl.message(
      'Please select photo',
      name: 'pleaseSelectPhoto',
      desc: '',
      args: [],
    );
  }

  /// `Select Photo`
  String get selectPhoto {
    return Intl.message(
      'Select Photo',
      name: 'selectPhoto',
      desc: '',
      args: [],
    );
  }

  /// `Note`
  String get vaccineStatus {
    return Intl.message(
      'Note',
      name: 'vaccineStatus',
      desc: '',
      args: [],
    );
  }

  /// `Weight`
  String get weight {
    return Intl.message(
      'Weight',
      name: 'weight',
      desc: '',
      args: [],
    );
  }

  /// `Height`
  String get height {
    return Intl.message(
      'Height',
      name: 'height',
      desc: '',
      args: [],
    );
  }

  /// `Diary`
  String get diary {
    return Intl.message(
      'Diary',
      name: 'diary',
      desc: '',
      args: [],
    );
  }

  /// `Tag`
  String get tag {
    return Intl.message(
      'Tag',
      name: 'tag',
      desc: '',
      args: [],
    );
  }

  /// `Please input record`
  String get pleaseInputRecord {
    return Intl.message(
      'Please input record',
      name: 'pleaseInputRecord',
      desc: '',
      args: [],
    );
  }

  /// `Tag (separated by comma)`
  String get tagSeparator {
    return Intl.message(
      'Tag (separated by comma)',
      name: 'tagSeparator',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get save {
    return Intl.message(
      'Save',
      name: 'save',
      desc: '',
      args: [],
    );
  }

  /// `Baby Growth Tracker`
  String get babyGrowthTracker {
    return Intl.message(
      'Baby Growth Tracker',
      name: 'babyGrowthTracker',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'zh', countryCode: 'TW'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
