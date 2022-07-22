import 'package:steemdart_ecc/steemdart_ecc.dart';

class CryptoManager {
  String privToPub(String privateKey) {
    SteemPrivateKey pkey = SteemPrivateKey.fromString(privateKey);
    return pkey.toPublicKey().toString();
  }
}
