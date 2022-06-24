import 'package:dice_fe/core/domain/models/websocket_icd.dart';
import 'package:dice_fe/core/widgets/app_ui.dart';
import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  final double? width;
  final double? height;
  final List<PopupMenuEntry<dynamic>> Function(BuildContext)? popupActionsBuilder;
  const PrimaryButton(
    {required this.text,
    required this.onTap,
    this.width,
    this.height,
    this.popupActionsBuilder,
    Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppUI.setUntitsSize(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
              onTap != null ? AppUI.primaryColor : AppUI.lightGrayColor),
            splashFactory: NoSplash.splashFactory,
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: popupActionsBuilder == null ?
                    BorderRadius.circular(12.0) :
                    const BorderRadius.horizontal(left: Radius.circular(12.0))
              )
            )
          ),
          onPressed: onTap,
          child: SizedBox(
            width: width ?? AppUI.widthUnit * 36,
            height: height ?? AppUI.heightUnit * 7,
            child: Center(
              child: Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
        if (popupActionsBuilder != null)
          Container(
            width: width == null ? AppUI.widthUnit * 9 : width! / 4,
            height: height ?? AppUI.heightUnit * 7,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(12.0)),
              color: onTap != null ? AppUI.primaryColor : AppUI.lightGrayColor
            ),
            child: PopupMenuButton(
              itemBuilder: popupActionsBuilder!,
            )
          )
      ],
    );
  }
}
