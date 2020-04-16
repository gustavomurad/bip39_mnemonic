import 'package:bip39mnemonic/core/enumerators/language_enum.dart';
import 'package:bip39mnemonic/core/util/bip39.dart';
import 'package:bip39mnemonic/core/util/word.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';

class MockWordsImpl extends Mock implements Words {}

void main() {
  Bip39 bip39;
  Words wordsTest;

  setUp(() {
    wordsTest = WordsImpl();
    bip39 = Bip39(wordList: Languages.ENGLISH, words: wordsTest);
  });

  group('basic check', () {
    test('check if is a instance of Bip39', () async {
      expect(bip39, isA<Bip39>(), reason: 'bip29 is a Bip39 instance');
    });

    test('check if is a english word list is loaded', () async {
      expect(bip39.selectedWordList, Languages.ENGLISH,
          reason: 'the list is english');
    });

    test('exposes standard wordlists', () {
      expect(bip39.wordList.length, 2048);
    });
  });

  group('setDefaultWordlist changes default wordlist', () {
    test('english to italian then english test', () async {
      expect(bip39.selectedWordList, Languages.ENGLISH,
          reason: 'the list is english');

      bip39.setDefaultWordList(wordList: Languages.ITALIAN, words: wordsTest);
      expect(bip39.selectedWordList, Languages.ITALIAN,
          reason: 'the list is italian');

      final phraseItalian =
          bip39.entropyToMnemonic('00000000000000000000000000000000');
      expect(phraseItalian.substring(0, 5), 'abaco',
          reason: 'the word is abaco');

      bip39.setDefaultWordList(wordList: Languages.ENGLISH, words: wordsTest);
      expect(bip39.selectedWordList, Languages.ENGLISH,
          reason: 'the list is english');

      final phraseEnglish =
          bip39.entropyToMnemonic('00000000000000000000000000000000');
      expect(phraseEnglish.substring(0, 7), 'abandon',
          reason: 'the word is abandon');
    });
  });

  group('generateMnemonic', () {
    test('can vary entropy length', () {
      final words = (bip39.generateMnemonic(strength: 160)).split(' ');
      expect(words.length, equals(15),
          reason: 'can vary generated entropy bit length');
    });
  });

  group('check mnemonic', () {
    test('validate seed', () async {
      expect(
          bip39.mnemonicToSeedHex(
              'hill hidden dance math apple hub march comfort wrestle inhale walk give bargain boy image cat pistol heart gate sick drop quote cancel fresh'),
          '89eeeb70d196a98ac5f898f2a9fb97820a6e548640e9d89005539ca4529b83a6f4189335174b10a746cab5275cce223d4c49fac95e14b23487526fd913753164',
          reason: 'seed is ok');
    });
  });

  group('validate mnemonic', () {
    test('short mnemonic', () async {
      expect(bip39.validateMnemonic('sleep kitten'), false,
          reason: 'fails for a mnemonic that is too short');
    });

    test('short mnemonic', () async {
      expect(bip39.validateMnemonic('sleep kitten sleep kitten sleep kitten'),
          false,
          reason: 'fails for a mnemonic that is too short');
    });

    test('too long mnemonic', () async {
      expect(
          bip39.validateMnemonic(
              'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about end grace oxygen maze bright face loan ticket trial leg cruel lizard bread worry reject journey perfect chef section caught neither install industry'),
          false,
          reason: 'fails for a mnemonic that is too long');
    });

    test(' wordsMock are not in the word list', () async {
      expect(
          bip39.validateMnemonic(
              'turtle front uncle idea crush write shrug there lottery flower risky shell'),
          false,
          reason: 'fails if mnemonic wordsMock are not in the word list');
    });

    test('invalid checksum', () async {
      expect(
          bip39.validateMnemonic(
              'sleep kitten sleep kitten sleep kitten sleep kitten sleep kitten sleep kitten'),
          false,
          reason: 'fails for invalid checksum');
    });
  });
}
