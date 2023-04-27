import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../widgets/button.dart';

class ConfirmDeleteDialog extends StatelessWidget {
  const ConfirmDeleteDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      alignment: Alignment.center,
      child: Container(
        width: 500.0,
        height: 200.0,
        color: Colors.white,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Text(
                    'delete_dialog.confirm_deleting'.tr(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.grey[800],
                    ),
                  ),
                ),
                CloseWindowButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  colors: WindowButtonColors(
                    iconNormal: Colors.grey[800],
                    iconMouseDown: Colors.white,
                    iconMouseOver: Colors.white,
                    mouseOver: Colors.red,
                    mouseDown: Colors.red[200],
                    normal: Colors.transparent,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.warning_amber_outlined,
                        color: Colors.amber[900],
                        size: 40.0,
                      ),
                      const SizedBox(width: 10.0),
                      Text(
                        'delete_dialog.confirm_text'.tr(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15.0),
                  Text(
                    'delete_dialog.confirm_description'.tr(),
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Theme(
              data: ThemeData.light(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  WrtButton(
                    callback: () {
                      Navigator.of(context).pop(true);
                    },
                    label: 'delete_dialog.delete'.tr(),
                  ),
                  const SizedBox(width: 10.0),
                  WrtButton(
                    callback: () {
                      Navigator.of(context).pop(false);
                    },
                    label: 'delete_dialog.do_not_delete'.tr(),
                  ),
                  const SizedBox(width: 10.0),
                  WrtButton(
                    callback: () {
                      Navigator.of(context).pop();
                    },
                    label: 'close_dialog.cancel'.tr(),
                  ),
                  const SizedBox(width: 10.0),
                ],
              ),
            ),
            const SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }
}
