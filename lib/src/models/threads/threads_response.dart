import 'dart:convert';

import 'package:acela/src/utils/safe_convert.dart';

class ThreadNamesResponse {
  final List<ThreadName> tags;
  final ThreadTokenPrices tokenPrices;

  ThreadNamesResponse({
    required this.tags,
    required this.tokenPrices,
  });

  factory ThreadNamesResponse.fromJson(Map<String, dynamic>? json) {
    var list = asList(json, 'tags');
    List<ThreadName> tags = [];
    for (var element in list) {
      var innerList = element as List<dynamic>;
      if (innerList.isNotEmpty && innerList.length == 2) {
        var count = innerList[1] as int?;
        var name = innerList[0] as String?;
        if (count != null && name != null) {
          tags.add(ThreadName(name: name, count: count));
        }
      }
    }
    return ThreadNamesResponse(
      tags: tags,
      tokenPrices: ThreadTokenPrices.fromJson(asMap(json, 'tokenPrices')),
    );
  }

  factory ThreadNamesResponse.fromJsonString(String string) =>
      ThreadNamesResponse.fromJson(
        json.decode(string),
      );
}

class ThreadName {
  final String name;
  final int count;

  ThreadName({
    required this.name,
    required this.count,
  });
}

class ThreadTokenPrices {
  final BasicAttentionToken basicAttentionToken;
  final Bitcoin bitcoin;
  final CubFinance cubFinance;
  final CurveDaoToken curveDaoToken;
  final Dogecoin dogecoin;
  final Ethereum ethereum;
  final Hive hive;
  final Link link;
  final Monero monero;
  final Polycub polycub;
  final Ripple ripple;
  final Thorchain thorchain;
  final WrappedLeo wrappedLeo;

  ThreadTokenPrices({
    required this.basicAttentionToken,
    required this.bitcoin,
    required this.cubFinance,
    required this.curveDaoToken,
    required this.dogecoin,
    required this.ethereum,
    required this.hive,
    required this.link,
    required this.monero,
    required this.polycub,
    required this.ripple,
    required this.thorchain,
    required this.wrappedLeo,
  });

  factory ThreadTokenPrices.fromJson(Map<String, dynamic>? json) =>
      ThreadTokenPrices(
        basicAttentionToken:
        BasicAttentionToken.fromJson(asMap(json, 'basic-attention-token')),
        bitcoin: Bitcoin.fromJson(asMap(json, 'bitcoin')),
        cubFinance: CubFinance.fromJson(asMap(json, 'cub-finance')),
        curveDaoToken: CurveDaoToken.fromJson(asMap(json, 'curve-dao-token')),
        dogecoin: Dogecoin.fromJson(asMap(json, 'dogecoin')),
        ethereum: Ethereum.fromJson(asMap(json, 'ethereum')),
        hive: Hive.fromJson(asMap(json, 'hive')),
        link: Link.fromJson(asMap(json, 'link')),
        monero: Monero.fromJson(asMap(json, 'monero')),
        polycub: Polycub.fromJson(asMap(json, 'polycub')),
        ripple: Ripple.fromJson(asMap(json, 'ripple')),
        thorchain: Thorchain.fromJson(asMap(json, 'thorchain')),
        wrappedLeo: WrappedLeo.fromJson(asMap(json, 'wrapped-leo')),
      );
}

class BasicAttentionToken {
  final double usd;

  BasicAttentionToken({
    this.usd = 0.0,
  });

  factory BasicAttentionToken.fromJson(Map<String, dynamic>? json) =>
      BasicAttentionToken(
        usd: asDouble(json, 'usd'),
      );

  Map<String, dynamic> toJson() => {
    'usd': usd,
  };
}

class Bitcoin {
  final int usd;

  Bitcoin({
    this.usd = 0,
  });

  factory Bitcoin.fromJson(Map<String, dynamic>? json) => Bitcoin(
    usd: asInt(json, 'usd'),
  );

  Map<String, dynamic> toJson() => {
    'usd': usd,
  };
}

class CubFinance {
  final double usd;

  CubFinance({
    this.usd = 0.0,
  });

  factory CubFinance.fromJson(Map<String, dynamic>? json) => CubFinance(
    usd: asDouble(json, 'usd'),
  );

  Map<String, dynamic> toJson() => {
    'usd': usd,
  };
}

class CurveDaoToken {
  final double usd;

  CurveDaoToken({
    this.usd = 0.0,
  });

  factory CurveDaoToken.fromJson(Map<String, dynamic>? json) => CurveDaoToken(
    usd: asDouble(json, 'usd'),
  );

  Map<String, dynamic> toJson() => {
    'usd': usd,
  };
}

class Dogecoin {
  final double usd;

  Dogecoin({
    this.usd = 0.0,
  });

  factory Dogecoin.fromJson(Map<String, dynamic>? json) => Dogecoin(
    usd: asDouble(json, 'usd'),
  );

  Map<String, dynamic> toJson() => {
    'usd': usd,
  };
}

class Ethereum {
  final double usd;

  Ethereum({
    this.usd = 0.0,
  });

  factory Ethereum.fromJson(Map<String, dynamic>? json) => Ethereum(
    usd: asDouble(json, 'usd'),
  );

  Map<String, dynamic> toJson() => {
    'usd': usd,
  };
}

class Hive {
  final double usd;

  Hive({
    this.usd = 0.0,
  });

  factory Hive.fromJson(Map<String, dynamic>? json) => Hive(
    usd: asDouble(json, 'usd'),
  );

  Map<String, dynamic> toJson() => {
    'usd': usd,
  };
}

class Link {
  final double usd;

  Link({
    this.usd = 0.0,
  });

  factory Link.fromJson(Map<String, dynamic>? json) => Link(
    usd: asDouble(json, 'usd'),
  );

  Map<String, dynamic> toJson() => {
    'usd': usd,
  };
}

class Monero {
  final double usd;

  Monero({
    this.usd = 0.0,
  });

  factory Monero.fromJson(Map<String, dynamic>? json) => Monero(
    usd: asDouble(json, 'usd'),
  );

  Map<String, dynamic> toJson() => {
    'usd': usd,
  };
}

class Polycub {
  final double usd;

  Polycub({
    this.usd = 0.0,
  });

  factory Polycub.fromJson(Map<String, dynamic>? json) => Polycub(
    usd: asDouble(json, 'usd'),
  );

  Map<String, dynamic> toJson() => {
    'usd': usd,
  };
}

class Ripple {
  final double usd;

  Ripple({
    this.usd = 0.0,
  });

  factory Ripple.fromJson(Map<String, dynamic>? json) => Ripple(
    usd: asDouble(json, 'usd'),
  );

  Map<String, dynamic> toJson() => {
    'usd': usd,
  };
}

class Thorchain {
  final double usd;

  Thorchain({
    this.usd = 0.0,
  });

  factory Thorchain.fromJson(Map<String, dynamic>? json) => Thorchain(
    usd: asDouble(json, 'usd'),
  );

  Map<String, dynamic> toJson() => {
    'usd': usd,
  };
}

class WrappedLeo {
  final double usd;

  WrappedLeo({
    this.usd = 0.0,
  });

  factory WrappedLeo.fromJson(Map<String, dynamic>? json) => WrappedLeo(
    usd: asDouble(json, 'usd'),
  );

  Map<String, dynamic> toJson() => {
    'usd': usd,
  };
}
