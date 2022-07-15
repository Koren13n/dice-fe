import 'package:dice_fe/core/domain/dice_user.dart';
import 'package:dice_fe/core/domain/models/game_rules.dart';
import 'package:dice_fe/core/widgets/app_bar_title.dart';
import 'package:dice_fe/core/widgets/app_ui.dart';
import 'package:dice_fe/core/widgets/drawer/dice_drawer.dart';
import 'package:dice_fe/core/widgets/primary_button.dart';
import 'package:dice_fe/features/game/domain/repositories/game_repository.dart';
import 'package:dice_fe/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_clean_architecture/flutter_clean_architecture.dart';
import 'lobby_controller.dart';

class LobbyPage extends View {
  static String routeName = '/lobby';
  final String roomCode;
  LobbyPage({required this.roomCode, Key? key}) : super(key: key);

  @override
  // ignore: no_logic_in_create_state
  State<LobbyPage> createState() => LobbyPageState(roomCode);
}

class LobbyPageState extends ViewState<LobbyPage, LobbyController> {
  String roomCode;

  LobbyPageState(this.roomCode) : super(LobbyController(roomCode, serviceLocator<GameRepository>()));

  @override
  Widget get view {
    AppUI.setUntitsSize(context);
    return Scaffold(
      drawer: const DiceDrawer(),
      appBar: AppBar(
        title: const DiceAppBarTitle(),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              showDialog(context: context, builder: (context) => buildExitConfirmationDialog(context));
            },
          ),
        ],
      ),
      body: buildLobbyPage(),
    );
  }

  Widget buildExitConfirmationDialog(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Are you sure you want to exit?",
        style: TextStyle(
          fontSize: 24,
        ),
      ),
      actions: [
        TextButton(
          child: const Text("Leave", style: TextStyle(fontSize: 20, color: Colors.red)),
          onPressed: () {},
        ),
        TextButton(
          child: const Text(
            "Stay",
            style: TextStyle(fontSize: 20),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Widget buildLobbyPage() {
    AppUI.setUntitsSize(context);
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 4 * AppUI.heightUnit),
          Text("Room ${widget.roomCode}", style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w700)),
          SizedBox(height: 4 * AppUI.heightUnit),
          const PlayerList(),
          const Expanded(child: SizedBox()),
          const Text("Who sits next to you?", style: TextStyle(fontSize: 18)),
          SizedBox(height: 2 * AppUI.heightUnit),
          Row(
            children: [
              SizedBox(width: 2 * AppUI.widthUnit),
              const PlayerPicker(PlayerPickerSide.left),
              SizedBox(width: 3 * AppUI.widthUnit),
              const PlayerPicker(PlayerPickerSide.right),
              SizedBox(width: 2 * AppUI.widthUnit),
            ],
          ),
          SizedBox(height: 8 * AppUI.heightUnit),
          const Text("Game settings", style: TextStyle(fontSize: 24)),
          SizedBox(height: 2 * AppUI.heightUnit),
          const RulesView(),
          const Expanded(child: SizedBox()),
          const ErrorText(),
          const ReadyButton(),
          SizedBox(height: 4 * AppUI.heightUnit),
        ],
      ),
    );
  }
}

class PlayerList extends StatelessWidget {
  const PlayerList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LobbyController lobbyController = FlutterCleanArchitecture.getController<LobbyController>(context);
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(children: [
        ...lobbyController.players.map((user) => Text(user.name, style: const TextStyle(fontSize: 24))),
      ]),
    );
  }
}

class PlayerPicker extends StatelessWidget {
  final PlayerPickerSide side;
  const PlayerPicker(this.side, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LobbyController lobbyController = FlutterCleanArchitecture.getController<LobbyController>(context);
    return Container(
      width: 27.5 * AppUI.widthUnit,
      decoration: BoxDecoration(
        border: Border.all(color: AppUI.lightGrayColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          isExpanded: true,
          value: lobbyController.leftPlayer,
          items: lobbyController.players
              .map((user) => DropdownMenuItem(
                    value: user,
                    child: Container(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(user.name)),
                  ))
              .toList(),
          onChanged: lobbyController.userReady ? null : (DiceUser? user) => lobbyController.selectPlayer(side, user),
          hint: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text("Who sits on your ${side.name}?"),
          ),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}

class RulesView extends StatelessWidget {
  const RulesView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LobbyController lobbyController = FlutterCleanArchitecture.getController<LobbyController>(context);
    GameRules rules = lobbyController.rules;
    return Row(children: [
      SizedBox(width: 4 * AppUI.widthUnit),
      Expanded(
        child: Column(
          children: [
            const Text("Dice count", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300)),
            SizedBox(height: AppUI.heightUnit),
            Text("${rules.initialDiceCount}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      SizedBox(width: 4 * AppUI.widthUnit),
      Expanded(
        child: Column(
          children: [
            const Text("Paso", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300)),
            SizedBox(height: AppUI.heightUnit),
            Text(rules.pasoAllowed! ? "ON" : "OFF", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      SizedBox(width: 4 * AppUI.widthUnit),
      Expanded(
        child: Column(
          children: [
            const Text("Exactly", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300)),
            SizedBox(height: AppUI.heightUnit),
            Text(rules.exactAllowed! ? "ON" : "OFF", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
      SizedBox(width: 4 * AppUI.widthUnit)
    ]);
  }
}

class ReadyButton extends StatelessWidget {
  const ReadyButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LobbyController lobbyController = FlutterCleanArchitecture.getController<LobbyController>(context);
    if (lobbyController.readyLoading) {
      return const CircularProgressIndicator.adaptive();
    }
    return PrimaryButton(
        text: lobbyController.userReady ? "Unready" : "Ready",
        width: MediaQuery.of(context).size.width * 0.8,
        height: 8 * AppUI.heightUnit,
        onTap: lobbyController.onReady);
  }
}

class ErrorText extends StatelessWidget {
  const ErrorText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LobbyController lobbyController = FlutterCleanArchitecture.getController<LobbyController>(context);
    if (lobbyController.errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(lobbyController.errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 18)),
      );
    }

    return Container();
  }
}
