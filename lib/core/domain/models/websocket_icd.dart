import 'package:dice_fe/core/domain/dice_user.dart';
import 'package:dice_fe/core/domain/models/game_rules.dart';
import 'package:json_annotation/json_annotation.dart';

part 'websocket_icd.g.dart';

enum Event {
  gameStart,
  lobbyUpdate,
  none
}

Map<String, Event> eventMap = {
  "game_start": Event.gameStart,
  "game_update": Event.lobbyUpdate
};

class Message {
  final Event messageType;
  const Message(this.messageType);

  factory Message.fromJson(Map<String, dynamic> json) {
    switch (eventMap[json['event']]) {
      case Event.gameStart:
        return GameStart();
      case Event.lobbyUpdate:
        return LobbyUpdate.fromJson(json);
      default:
        return const Message(Event.none);    
    }
  }
}

class GameStart extends Message {
  GameStart() : super(Event.gameStart);
}

_usersFromJson(List<dynamic> json) {
  return json.map((user) {
    String id = user.keys.toList().first;
    String name = user[id];
    return DiceUser(id: id, name: name);
  });
}

@JsonSerializable(explicitToJson: true)
class LobbyUpdate extends Message {
  LobbyUpdate(this.players, this.rules) : super(Event.lobbyUpdate);
  @JsonKey(fromJson: _usersFromJson)
  List<DiceUser>? players;

  GameRules? rules;

  factory LobbyUpdate.fromJson(Map<String, dynamic> json) => _$LobbyUpdateFromJson(json);
  toJson() => _$LobbyUpdateToJson(this);
}
