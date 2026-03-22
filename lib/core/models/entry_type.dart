import 'package:flutter/material.dart';

/// Verfügbare Eintragstypen für den Quick Entry Sheet
enum EntryType {
  note,
  mood,
  photo,
  audio,
  video,
  workout,
  meal,
  media,
  book,
  gratitude,
  idea,
  contact,
}

extension EntryTypeExtension on EntryType {
  String get emoji {
    switch (this) {
      case EntryType.note:      return '📝';
      case EntryType.mood:      return '😊';
      case EntryType.photo:     return '📷';
      case EntryType.audio:     return '🎙️';
      case EntryType.video:     return '🎬';
      case EntryType.workout:   return '💪';
      case EntryType.meal:      return '🍽️';
      case EntryType.media:     return '📺';
      case EntryType.book:      return '📚';
      case EntryType.gratitude: return '🙏';
      case EntryType.idea:      return '💡';
      case EntryType.contact:   return '👥';
    }
  }

  String get label {
    switch (this) {
      case EntryType.note:      return 'Notiz';
      case EntryType.mood:      return 'Stimmung';
      case EntryType.photo:     return 'Foto';
      case EntryType.audio:     return 'Audio';
      case EntryType.video:     return 'Video';
      case EntryType.workout:   return 'Workout';
      case EntryType.meal:      return 'Mahlzeit';
      case EntryType.media:     return 'Media';
      case EntryType.book:      return 'Buch';
      case EntryType.gratitude: return 'Dankbarkeit';
      case EntryType.idea:      return 'Idee';
      case EntryType.contact:   return 'Kontakt';
    }
  }

  Color get color {
    switch (this) {
      case EntryType.note:      return Colors.blue;
      case EntryType.mood:      return Colors.orange;
      case EntryType.photo:     return Colors.green;
      case EntryType.audio:     return Colors.purple;
      case EntryType.video:     return Colors.red;
      case EntryType.workout:   return Colors.teal;
      case EntryType.meal:      return Colors.amber;
      case EntryType.media:     return Colors.indigo;
      case EntryType.book:      return Colors.brown;
      case EntryType.gratitude: return Colors.pink;
      case EntryType.idea:      return Colors.yellow;
      case EntryType.contact:   return Colors.cyan;
    }
  }

  String get entryTypeString => name;

  static EntryType fromString(String value) {
    return EntryType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => EntryType.note,
    );
  }
}
