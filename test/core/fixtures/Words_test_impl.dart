import 'dart:convert';
import 'dart:io';

import 'package:bip39mnemonic/core/enumerators/language_enum.dart';
import 'package:bip39mnemonic/core/util/word.dart';

class WordsTestImpl implements Words {
  Map<Languages, String> _languageFiles;

  WordsTestImpl(
      {Map<Languages, String> languageFiles = const {
        Languages.CHINESE_SIMPLIFIED:
            'test/core/wordlists/chinese_simplified.json',
        Languages.CHINESE_TRADITIONAL:
            'test/core/wordlists/chinese_traditional.json',
        Languages.ENGLISH: 'test/core/wordlists/english.json',
        Languages.FRENCH: 'test/core/wordlists/french.json',
        Languages.ITALIAN: 'test/core/wordlists/italian.json',
        Languages.JAPANESE: 'test/core/wordlists/japanese.json',
        Languages.KOREAN: 'test/core/wordlists/korean.json',
        Languages.SPANISH: 'test/core/wordlists/spanish.json',
      }})
      : this._languageFiles = languageFiles;

  @override
  List<String> loadWordListFromFile({Languages wordList}) {
    final file =
        _languageFiles.entries.firstWhere((x) => x.key == wordList).value;
    final String res = File(file).readAsStringSync();
    List<String> words =
        (json.decode(res) as List).map((e) => e.toString()).toList();
    return words;
  }
}
