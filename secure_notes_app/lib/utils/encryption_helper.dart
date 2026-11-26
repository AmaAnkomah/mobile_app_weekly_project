import 'package:encrypt/encrypt.dart';


class EncryptionHelper {
  static final _key = Key.fromUtf8('my32bytekey123456789012345678901'); // Exactly 32 bytes for AES-256
  static final _iv = IV.fromLength(16);


  static String encrypt(String plainText) {
    final encrypter = Encrypter(AES(_key));
    final encrypted = encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }


  static String decrypt(String cipherText) {
    final encrypter = Encrypter(AES(_key));
    final decrypted = encrypter.decrypt(Encrypted.fromBase64(cipherText), iv: _iv);
    return decrypted;
  }
}
