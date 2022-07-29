import 'package:dice_fe/core/domain/dice_user.dart';
import 'package:dice_fe/core/domain/models/game_rules.dart';
import 'package:dice_fe/core/domain/models/websocket_icd.dart';
import 'package:dice_fe/features/create_user/app/pages/create_user_page.dart';
import 'package:dice_fe/features/game/domain/repositories/game_repository.dart';
import 'package:dice_fe/features/home/pages/home_page.dart';
import 'package:dice_fe/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';

enum PlayerPickerSide { left, right }

class LobbyController extends Controller {
  final String roomCode;
  List<DiceUser> players = [];
  DiceUser? currentPlayer;
  DiceUser? leftPlayer;
  DiceUser? rightPlayer;
  bool userReady = false;
  GameRules rules = GameRules(exactAllowed: true, pasoAllowed: true, initialDiceCount: 5);
  bool readyLoading = false;
  Function()? onReady;
  late final Stream _websocketStream;
  String? errorMessage;
  final GameRepository _gameRepository;
  LobbyController(this.roomCode, this._gameRepository) : super();

  @override
  void initListeners() {}

  @override
  void onInitState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print("Here");
      bool codeValid = false;
      // Check if user is logged in
      final logedInResult = _gameRepository.isUserLoggedIn();
      await logedInResult.fold(
        (failure) async {
          await Navigator.pushNamed(getContext(), CreateUserPage.routeName, arguments: (DiceUser createdUser) {
            Navigator.pop(getContext());
            print(createdUser);
            currentPlayer = createdUser;
          });
        },
        (user) async {
          currentPlayer = user;
        },
      );

      if (currentPlayer == null) {
        return;
      }

      // Check room code is valid
      _gameRepository.isRoomCodeValid(roomCode, currentPlayer!.id).then(
            (isRoomCodeValid) => isRoomCodeValid.fold((failure) {
              onCriticalError("Room code is invalid");
            }, (joinable) {
              if (joinable) {
                _joinRoom();
              } else {
                onCriticalError("Room code is invalid");
              }
            }),
          );
    });
  }

  void onCriticalError(String message) {
    ScaffoldMessenger.of(getContext()).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
    Navigator.of(getContext()).popUntil(ModalRoute.withName(HomePage.routeName));
  }

  void _joinRoom() async {
    final streamResult = await _gameRepository.joinRoom(roomCode);
    streamResult.fold((failure) {
      onCriticalError("Network error");
    }, (stream) {
      _websocketStream = stream;
      _handleBackendStream();
    });
  }

  void _handleBackendStream() {
    _websocketStream.listen((message) {
      print("Got Message: ${(message as Message).messageType}");
      switch ((message as Message).messageType) {
        case Event.lobbyUpdate:
          message = message as LobbyUpdate;
          players = message.players;
          rules = message.rules ?? rules;
          break;
      }
      refreshUI();
    });
  }

  void leaveRoom() {
    _gameRepository.sendMessage(PlayerLeave());
    _gameRepository.exit();
    Navigator.of(getContext()).popUntil(ModalRoute.withName(HomePage.routeName));
  }

  void selectPlayer(PlayerPickerSide side, DiceUser? user) {
    if (side == PlayerPickerSide.left) {
      leftPlayer = user;
    } else {
      rightPlayer = user;
    }
    if (leftPlayer != null && rightPlayer != null) {
      onReady = onReadyClicked;
      refreshUI();
    }
  }

  void onReadyClicked() async {
    readyLoading = true;
    refreshUI();
    await Future.delayed(const Duration(seconds: 1));
    readyLoading = false;
    refreshUI();
  }
}