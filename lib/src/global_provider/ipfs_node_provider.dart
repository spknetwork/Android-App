import 'package:get_storage/get_storage.dart';

class IpfsNodeProvider{
  String storageKey = 'ipfsNode';
  late String nodeUrl;
  GetStorage _storage = GetStorage();
  String defaultIpfsNode = 'https://ipfs-3speak.b-cdn.net/ipfs/';

static IpfsNodeProvider? _instance;
  IpfsNodeProvider._();

  static IpfsNodeProvider get instance {
    _instance ??= IpfsNodeProvider._(); 
    return _instance!;
  }
  IpfsNodeProvider() {
    _init();
  }

  void _init() {
    nodeUrl = _storage.read(storageKey) ?? defaultIpfsNode;
  }

  void changeIpfsNode(String newUrl) {
    if (newUrl != nodeUrl) {
      nodeUrl = newUrl;
      _storage.write(storageKey, newUrl);
    }
  }
}

