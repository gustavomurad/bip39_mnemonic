import 'dart:convert';
import 'dart:io';

import 'package:bip39mnemonic/core/enumerators/language_enum.dart';
import 'package:meta/meta.dart';

abstract class Words {
  List<String> loadWordListFromFile({@required Languages wordList});
}

class WordsImpl implements Words {

  Map<Languages, String> _languageFiles;


  WordsImpl({ Map<Languages, String> languageFiles = const {
    Languages.CHINESE_SIMPLIFIED: 'lib/core/wordlists/chinese_simplified.json',
    Languages
        .CHINESE_TRADITIONAL: 'lib/core/wordlists/chinese_traditional.json',
    Languages.ENGLISH: 'lib/core/wordlists/english.json',
    Languages.FRENCH: 'lib/core/wordlists/french.json',
    Languages.ITALIAN: 'lib/core/wordlists/italian.json',
    Languages.JAPANESE: 'lib/core/wordlists/japanese.json',
    Languages.KOREAN: 'lib/core/wordlists/korean.json',
    Languages.SPANISH: 'lib/core/wordlists/spanish.json',
  }}) : this._languageFiles = languageFiles;

  @override
  List<String> loadWordListFromFile({Languages wordList}) {
    final file =
        _languageFiles.entries
            .firstWhere((x) => x.key == wordList)
            .value;
    final String res = File(file).readAsStringSync();
    List<String> words =
    (json.decode(res) as List).map((e) => e.toString()).toList();
    return words;
  }
}
