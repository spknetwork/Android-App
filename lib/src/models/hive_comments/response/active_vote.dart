import 'package:acela/src/utils/safe_convert.dart';

class ActiveVote {
  // 1000
  final int percent;
  // 784865040553638
  final int reputation;
  // 179995483613
  final int rshares;
  // 2022-02-06T04:25:57
  final String time;
  // jongolson
  final String voter;
  // 179995483613
  final int weight;

  ActiveVote({
    this.percent = 0,
    this.reputation = 0,
    this.rshares = 0,
    this.time = "",
    this.voter = "",
    this.weight = 0,
  });

  factory ActiveVote.fromJson(Map<String, dynamic>? json) => ActiveVote(
    percent: asInt(json, 'percent'),
    reputation: asInt(json, 'reputation'),
    rshares: asInt(json, 'rshares'),
    time: asString(json, 'time'),
    voter: asString(json, 'voter'),
    weight: asInt(json, 'weight'),
  );

  Map<String, dynamic> toJson() => {
    'percent': percent,
    'reputation': reputation,
    'rshares': rshares,
    'time': time,
    'voter': voter,
    'weight': weight,
  };
}

