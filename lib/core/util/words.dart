import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';

enum WordLists {
  CHINESE_SIMPLIFIED,
  CHINESE_TRADITIONAL,
  ENGLISH,
  FRENCH,
  ITALIAN,
  JAPANESE,
  KOREAN,
  SPANISH
}

Map<WordLists, String> _wordLists = {
  WordLists.CHINESE_SIMPLIFIED: 'chinese_simplified.json',
  WordLists.CHINESE_TRADITIONAL: 'chinese_traditional.json',
  WordLists.ENGLISH: 'english.json',
  WordLists.FRENCH: 'french.json',
  WordLists.ITALIAN: 'italian.json',
  WordLists.JAPANESE: 'japanese.json',
  WordLists.KOREAN: 'korean.json',
  WordLists.SPANISH: 'spanish.json',
};

String _getWordList({@required WordLists wordList}) {
  return _wordLists.entries.firstWhere((x) => x.key == wordList).value;
}

List<String> words({@required WordLists wordList}) {
  final String res =
      File('lib/core/wordlists/${_getWordList(wordList: wordList)}')
          .readAsStringSync();
  List<String> words =
      (json.decode(res) as List).map((e) => e.toString()).toList();
  return words;
}
