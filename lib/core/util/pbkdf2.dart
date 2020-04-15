import 'dart:convert';
import 'dart:typed_data';

import 'package:pointycastle/digests/sha512.dart';
import 'package:pointycastle/key_derivators/api.dart';
import 'package:pointycastle/key_derivators/pbkdf2.dart';
import 'package:pointycastle/macs/hmac.dart';

class Pbkdf2 {
  final int blockLength;
  final int iterationCount;
  final int desiredKeyLength;

  PBKDF2KeyDerivator _pbkdf2KeyDerivator;
  Uint8List _salt;

  Pbkdf2(
      {this.blockLength = 128,
      this.iterationCount = 2048,
      this.desiredKeyLength = 64,
      String salt = "mnemonic"}) {
    _salt = utf8.encode(salt);
    _pbkdf2KeyDerivator = PBKDF2KeyDerivator(HMac(SHA512Digest(), blockLength))
      ..init(Pbkdf2Parameters(_salt, iterationCount, desiredKeyLength));
  }

  Uint8List process(String mnemonic) {
    return _pbkdf2KeyDerivator.process(Uint8List.fromList(mnemonic.codeUnits));
  }
}
