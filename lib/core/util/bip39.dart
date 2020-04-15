import 'dart:math';
import 'dart:typed_data';

import 'package:bip39mnemonic/core/util/words.dart';
import 'package:crypto/crypto.dart';
import 'package:hex/hex.dart';
import 'package:meta/meta.dart';

import 'pbkdf2.dart';

typedef Uint8List RandomBytes(int size);

Uint8List _randomBytes(int size) {
  final rng = Random.secure();
  final bytes = Uint8List(size);
  for (var i = 0; i < size; i++) {
    bytes[i] = rng.nextInt(255);
  }
  return bytes;
}

class Bip39 {
  static const String _invalidMnemonic = 'Invalid mnemonic';
  static const String _invalidEntropy = 'Invalid entropy';
  static const String _invalidChecksum = 'Invalid mnemonic checksum';
  WordLists selectedWordList;
  List<String> _wordList;

  List<String> get wordList => this._wordList;

  Bip39({@required WordLists wordList}) {
    this._wordList = words(wordList: wordList);
    this.selectedWordList = wordList;
  }

  void setDefaultWordlist({@required WordLists wordList}) {
    this._wordList = words(wordList: wordList);
    this.selectedWordList = wordList;
  }

  int _binaryToByte(String binary) {
    return int.parse(binary, radix: 2);
  }

  String _bytesToBinary(Uint8List bytes) {
    return bytes.map((byte) => byte.toRadixString(2).padLeft(8, '0')).join('');
  }

  String _deriveChecksumBits(Uint8List entropy) {
    final ent = entropy.length * 8;
    final cs = ent ~/ 32;
    final hash = sha256.newInstance().convert(entropy);
    return _bytesToBinary(Uint8List.fromList(hash.bytes)).substring(0, cs);
  }

  String generateMnemonic(
      {int strength = 128, RandomBytes randomBytes = _randomBytes}) {
    assert(strength % 32 == 0);
    final entropy = randomBytes(strength ~/ 8);
    return entropyToMnemonic(HEX.encode(entropy));
  }

  String entropyToMnemonic(String entropyString) {
    final entropy = HEX.decode(entropyString);
    if (entropy.length < 16) {
      throw ArgumentError(_invalidEntropy);
    }
    if (entropy.length > 32) {
      throw ArgumentError(_invalidEntropy);
    }
    if (entropy.length % 4 != 0) {
      throw ArgumentError(_invalidEntropy);
    }
    final entropyBits = _bytesToBinary(entropy);
    final checksumBits = _deriveChecksumBits(entropy);
    final bits = entropyBits + checksumBits;
    final regex =
        new RegExp(r".{1,11}", caseSensitive: false, multiLine: false);
    final chunks = regex
        .allMatches(bits)
        .map((match) => match.group(0))
        .toList(growable: false);
    String words =
        chunks.map((binary) => this._wordList[_binaryToByte(binary)]).join(' ');
    return words;
  }

  Uint8List mnemonicToSeed(String mnemonic) {
    final pbkdf2 = Pbkdf2();
    return pbkdf2.process(mnemonic);
  }

  String mnemonicToSeedHex(String mnemonic) {
    return mnemonicToSeed(mnemonic).map((byte) {
      return byte.toRadixString(16).padLeft(2, '0');
    }).join('');
  }

  bool validateMnemonic(String mnemonic) {
    try {
      mnemonicToEntropy(mnemonic);
    } catch (e) {
      return false;
    }
    return true;
  }

  String mnemonicToEntropy(mnemonic) {
    var words = mnemonic.split(' ');
    if (words.length % 3 != 0) {
      throw new ArgumentError(_invalidMnemonic);
    }
    // convert word indices to 11 bit binary strings
    final bits = words.map((word) {
      final index = this._wordList.indexOf(word);
      if (index == -1) {
        throw new ArgumentError(_invalidMnemonic);
      }
      return index.toRadixString(2).padLeft(11, '0');
    }).join('');
    // split the binary string into ENT/CS
    final dividerIndex = (bits.length / 33).floor() * 32;
    final entropyBits = bits.substring(0, dividerIndex);
    final checksumBits = bits.substring(dividerIndex);

    // calculate the checksum and compare
    final regex = RegExp(r".{1,8}");
    final entropyBytes = Uint8List.fromList(regex
        .allMatches(entropyBits)
        .map((match) => _binaryToByte(match.group(0)))
        .toList(growable: false));
    if (entropyBytes.length < 16) {
      throw StateError(_invalidEntropy);
    }
    if (entropyBytes.length > 32) {
      throw StateError(_invalidEntropy);
    }
    if (entropyBytes.length % 4 != 0) {
      throw StateError(_invalidEntropy);
    }
    final newChecksum = _deriveChecksumBits(entropyBytes);
    if (newChecksum != checksumBits) {
      throw StateError(_invalidChecksum);
    }
    return entropyBytes.map((byte) {
      return byte.toRadixString(16).padLeft(2, '0');
    }).join('');
  }
}
