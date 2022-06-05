
import 'package:json_annotation/json_annotation.dart';

part 'dice_user.g.dart';

const String userCookieRecordName = 'dice_user';

@JsonSerializable()
class DiceUser {
  final String id;
  final String name;
  final bool? ready;
  @JsonKey(name: 'player_on_left')
  final String? playerOnLeft;
  @JsonKey(name: 'player_on_right')
  final String? playerOnRight;

  DiceUser({
    required this.id,
    required this.name,
    this.ready,
    this.playerOnLeft,
    this.playerOnRight
  });

  factory DiceUser.fromJson(Map<String, dynamic> json) => _$DiceUserFromJson(json);
  toJson() => _$DiceUserToJson(this);
}
