import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../tooltip.dart';

import '../../helpers/file_explorer_helper.dart';
import '../../providers/project_state.dart';

class ShareButton extends StatefulWidget {
  const ShareButton({super.key});

  @override
  State<ShareButton> createState() => _ShareButtonState();
}

class _ShareButtonState extends State<ShareButton> {
  Timer? _timer;
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _timer?.cancel();
    _overlayEntry?.remove();
    super.dispose();
  }

  Future<void> _platfromShare() async {
    final provider = Provider.of<ProjectState>(context, listen: false);
    final renderObject = context.findRenderObject() as RenderBox;
    final offset = renderObject.localToGlobal(Offset.zero);

    final file = await provider.getExportingFile();
    if (file == null) return;
    final name = FileExplorerHelper().macosGetProjectPathName(
      provider.project!.name,
    );
    final dir = Directory(p.join(provider.project!.path, 'export'));
    if (!(dir.existsSync())) await dir.create();
    final temp = File(
      p.join(dir.path, '$name.weave'),
    );
    await temp.create();
    await temp.writeAsString(file);

    await Share.shareXFiles(
      [
        XFile.fromData(
          Uint8List.fromList(file.codeUnits),
          lastModified: DateTime.now(),
          name: '$name.weave',
          path: temp.path,
          mimeType: 'application/xml',
        ),
      ],
      text: 'exporting.export'.tr(),
      sharePositionOrigin: Rect.fromCircle(
        center: offset.translate(13.0, 0.0),
        radius: 30.0,
      ),
    );

    await temp.delete();
  }

  void _buildMoreOptions() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;
    }
    _timer?.cancel();
    setState(() {
      _timer = null;
      _overlayEntry = _getOverlay();
      Overlay.of(context).insert(_overlayEntry!);
    });
  }

  OverlayEntry _getOverlay() {
    final provider = Provider.of<ProjectState>(context, listen: false);
    final renderObject = context.findRenderObject() as RenderBox;
    final offset = renderObject.localToGlobal(Offset.zero);
    final size = renderObject.size;

    // for future changes: adjust this value to the length of list
    const width = 70.0;

    return OverlayEntry(
      maintainState: true,
      builder: (context) {
        return Positioned(
          top: offset.dy,
          left: offset.dx + size.width - width,
          child: MouseRegion(
            onExit: (event) {
              _overlayEntry?.remove();
              setState(() {
                _overlayEntry = null;
              });
            },
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: width,
                height: size.height,
                decoration: BoxDecoration(
                  color: const Color(0xFF1C1C1C),
                  borderRadius: BorderRadius.circular(6.0),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 10.0,
                      spreadRadius: -10.0,
                      offset: Offset(-15.0, 0),
                      color: Colors.black,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    WrtTooltip(
                      content: 'exporting.export'.tr(),
                      key: const Key('exporting_more_opt_download_button'),
                      showOnTheBottom: true,
                      showOnTheLeft: true,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6.0),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            provider.export();
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(4.0),
                            child: Icon(
                              Icons.download_outlined,
                              size: 20.0,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 5.0),
                    WrtTooltip(
                      content: 'exporting.share'.tr(),
                      key: const Key('exporting_more_opt_share_button'),
                      showOnTheBottom: true,
                      showOnTheLeft: true,
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(6.0),
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            _platfromShare();
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Icon(
                              Platform.isMacOS
                                  ? Icons.ios_share
                                  : Icons.share_outlined,
                              size: 20.0,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final icon = Platform.isMacOS ? Icons.ios_share : Icons.share_outlined;

    return MouseRegion(
      onEnter: (event) {
        setState(() {
          _timer = Timer(const Duration(milliseconds: 850), () {
            _buildMoreOptions();
          });
        });
      },
      onExit: (event) {
        _timer?.cancel();
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6.0),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            _platfromShare();
          },
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Icon(
              icon,
              size: 20.0,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}
