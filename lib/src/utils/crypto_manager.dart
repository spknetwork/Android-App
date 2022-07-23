// import 'package:bs58/bs58.dart';
// import 'package:elliptic/elliptic.dart';
import 'package:bs58check/bs58check.dart' as bs58check;
import 'package:hex/hex.dart';
import 'package:steemdart_ecc/steemdart_ecc.dart';

class CryptoManager {
  String privToPub(String privateKey) {
    SteemPrivateKey pkey = SteemPrivateKey.fromString(privateKey);
    return pkey.toPublicKey().toString();
  }

  String decodeMemo(String memo, String privateKey) {
    SteemPrivateKey pkey = SteemPrivateKey.fromString(privateKey);
    SteemPublicKey publicKey = pkey.toPublicKey();
    var newMemo = memo.replaceAll("#", "");
    var decodedMemo = bs58check.base58.decode(newMemo);
    var hexString = HEX.encode(decodedMemo);
    return hexString;
  }
}
