import 'dart:async';
import 'dart:math' as math;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/general_helper.dart';
import '../../models/file_tab.dart';
import '../../models/version/version.dart';
import '../../pages/version_control/compare_page.dart';
import '../../providers/project_state.dart';
import '../../providers/version_control.dart';
import '../button.dart';
import '../expandable_section.dart';
import '../prompts/text_prompt.dart';

class VersionControlTab extends StatelessWidget {
  const VersionControlTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ProjectState>(context);
    final versionControl = Provider.of<VersionControl>(context);

    return Column(
      children: [
        SizedBox(
          height: 45.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  'taskbar.version_control'.tr().toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.grey[400],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (provider.isProjectOpened)
          Expanded(
            child: ListView(
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 20.0,
                        bottom: 4.0,
                      ),
                      child: Text(
                        'version_control.current_project'.tr(),
                        style: theme.textTheme.labelLarge,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                        maxLines: 1,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        provider.project!.name,
                        style: theme.textTheme.bodySmall,
                        textAlign: TextAlign.right,
                      ),
                    ),
                    const SizedBox(width: 5.0),
                  ],
                ),
                if (versionControl.isLoading)
                  const LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    minHeight: 4.0,
                    color: Color(0xFF1638E2),
                  )
                else
                  const SizedBox(height: 4.0),
                if (versionControl.isVersioningEnabled)
                  if (versionControl.current != null)
                    // verioning is enabled, we are on some version right now
                    Column(
                      children: [
                        if (!versionControl.current!.commited)
                          // current is not commited, commit
                          Column(
                            children: [
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(
                                  left: 20.0,
                                  right: 5.0,
                                ),
                                child: WrtButton(
                                  callback: () async {
                                    if (provider.isProjectBeingAnalized) return;
                                    if (versionControl.isLoading) return;
                                    if (provider.containsUnsaved) return;

                                    if (versionControl.isVersioningEnabled) {
                                      final message = await showTextPrompt(
                                        context,
                                        message: 'version_control.message'.tr(),
                                      );
                                      // user closed the prompt
                                      if (message == null) return;
                                      final commitMessage =
                                          message.trim().isEmpty
                                              ? null
                                              : message;

                                      versionControl.commit(commitMessage);
                                    }
                                  },
                                  color: theme.colorScheme.primary,
                                  label: 'version_control.commit'.tr(),
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(
                                  left: 20.0,
                                  right: 5.0,
                                ),
                                child: Text(
                                  'version_control.commiting_explanation'.tr(),
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                            ],
                          )
                        else
                          // start new version, current is commited
                          Column(
                            children: [
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(
                                  left: 20.0,
                                  right: 5.0,
                                ),
                                child: WrtButton(
                                  callback: () async {
                                    if (provider.isProjectBeingAnalized) return;
                                    if (versionControl.isLoading) return;
                                    if (provider.containsUnsaved) return;

                                    if (versionControl.isVersioningEnabled) {
                                      if (versionControl.current != null) {
                                        if (versionControl.current!.commited) {
                                          versionControl.startNewVersion();
                                        }
                                      }
                                    }
                                  },
                                  color: theme.colorScheme.primary,
                                  label: 'version_control.add_version'.tr(),
                                ),
                              ),
                              const SizedBox(height: 10.0),
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(
                                  left: 20.0,
                                  right: 5.0,
                                ),
                                child: Text(
                                  'version_control.adding_version_explanation'
                                      .tr(
                                    args: [versionControl.current!.code],
                                  ),
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 10.0),
                        Container(
                          width: double.infinity,
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(
                            left: 20.0,
                            bottom: 4.0,
                          ),
                          child: Text(
                            'version_control.versions'.tr(),
                            style: theme.textTheme.labelLarge,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.fade,
                            softWrap: false,
                            maxLines: 1,
                          ),
                        ),
                        _buildAllVersionsList(context),
                        const SizedBox(height: 10.0),
                        _buildCurrentVersionDetails(
                          context,
                          versionControl.current!,
                        ),
                        const SizedBox(height: 20.0),
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(left: 20.0),
                          height: 20.0,
                          child: FutureBuilder<bool>(
                            future: versionControl.isCheckoutSafe(),
                            builder: (context, snapshot) {
                              /// TODO: checking if checkout is safe does not work
                              return Text(
                                snapshot.data == null
                                    ? '...'
                                    : snapshot.data! &&
                                            !provider.containsUnsaved
                                        ? 'version_control.checkout_safe'.tr()
                                        : 'version_control.checkout_unsafe'
                                            .tr(),
                                style: theme.textTheme.bodyLarge,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        _buildVersionControlIntroduction(context),
                      ],
                    )
                  else
                    // versioning is enabled but there is no current version
                    const Column(
                      children: [],
                    )
                else
                  // default view when versioning is disabled
                  Column(
                    children: [
                      const SizedBox(height: 10.0),
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(
                          left: 20.0,
                          right: 5.0,
                        ),
                        child: WrtButton(
                          callback: () {
                            if (provider.isProjectBeingAnalized) return;
                            if (versionControl.isLoading) return;

                            if (!versionControl.isVersioningEnabled) {
                              versionControl.startVersioning();
                            }
                          },
                          color: theme.colorScheme.primary,
                          label: 'version_control.start_versioning'.tr(),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      _buildVersionControlIntroduction(context),
                    ],
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildVersionControlIntroduction(BuildContext context) {
    final theme = Theme.of(context);

    return WrtExpandableSection(
      header: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Text(
          'version_control.introduction_to_versions'.tr(),
          style: theme.textTheme.labelLarge,
          textAlign: TextAlign.start,
          overflow: TextOverflow.fade,
          softWrap: false,
          maxLines: 1,
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'version_control.introduction.versions'.tr(),
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 3.0),
            Text(
              'version_control.introduction.versions_description'.tr(),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 10.0),
            Text(
              'version_control.introduction.branches'.tr(),
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 3.0),
            Text(
              'version_control.introduction.branches_description'.tr(),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 10.0),
            Text(
              'version_control.introduction.sharing'.tr(),
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 3.0),
            Text(
              'version_control.introduction.sharing_description'.tr(),
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentVersionDetails(BuildContext context, Version version) {
    final theme = Theme.of(context);
    final versionControl = Provider.of<VersionControl>(context);

    return Column(
      children: [
        Container(
          width: double.infinity,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(
            left: 20.0,
            bottom: 4.0,
          ),
          child: Text(
            '${'version_control.current'.tr()} (${version.code})',
            style: theme.textTheme.labelLarge,
            textAlign: TextAlign.start,
            overflow: TextOverflow.fade,
            softWrap: false,
            maxLines: 1,
          ),
        ),
        const SizedBox(height: 10.0),
        Row(
          children: [
            const SizedBox(width: 20.0),
            const Icon(
              Icons.history,
              size: 20.0,
              color: Colors.grey,
            ),
            const SizedBox(width: 10.0),
            Text(
              '${'calendar.date_format_short'.tr(namedArgs: {
                    'month':
                        '${version.timestamp.month < 10 ? '0' : ''}${version.timestamp.month}',
                    'day':
                        '${version.timestamp.day < 10 ? '0' : ''}${version.timestamp.day}',
                    'year': version.timestamp.year.toString(),
                  })} ${version.timestamp.hour < 10 ? '0' : ''}${version.timestamp.hour}:${version.timestamp.minute < 10 ? '0' : ''}${version.timestamp.minute}:${version.timestamp.second < 10 ? '0' : ''}${version.timestamp.second}',
            ),
            const SizedBox(width: 10.0),
          ],
        ),
        const SizedBox(height: 10.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(width: 20.0),
            const Icon(
              Icons.title,
              size: 20.0,
              color: Colors.grey,
            ),
            const SizedBox(width: 10.0),
            Text(
              version.message ?? 'version_control.no_message'.tr(),
              maxLines: 5,
            ),
            const SizedBox(width: 10.0),
          ],
        ),
        const SizedBox(height: 10.0),
        Row(
          children: [
            const SizedBox(width: 20.0),
            const Icon(
              Icons.memory_outlined,
              size: 20.0,
              color: Colors.grey,
            ),
            const SizedBox(width: 10.0),
            Text(
              GeneralHelper().formatBytes(version.size),
            ),
            const SizedBox(width: 10.0),
          ],
        ),
        const SizedBox(height: 10.0),
        Row(
          children: [
            const SizedBox(width: 20.0),
            const Icon(
              Icons.merge,
              size: 20.0,
              color: Colors.grey,
            ),
            const SizedBox(width: 10.0),
            Text(
              version.previous ?? 'version_control.initial_version'.tr(),
            ),
            const SizedBox(width: 10.0),
          ],
        ),
      ],
    );
  }

  Container _buildAllVersionsList(BuildContext context) {
    final versionControl = Provider.of<VersionControl>(context);

    return Container(
      constraints: const BoxConstraints(
        maxHeight: 250.0,
        minHeight: 10.0,
      ),
      padding: const EdgeInsets.only(left: 20.0),
      height: versionControl.versions.length * 34,
      child: ListView(
        children: List.generate(
          versionControl.versions.length,
          (index) {
            final version = versionControl.versions[index];
            return _VersionTile(
              version: version,
              key: Key('version_tile_${version.code}'),
            );
          },
        ),
      ),
    );
  }
}

class _VersionTile extends StatefulWidget {
  const _VersionTile({
    super.key,
    required this.version,
  });
  final Version version;

  @override
  State<_VersionTile> createState() => _VersionTileState();
}

class _VersionTileState extends State<_VersionTile> {
  OverlayEntry? _overlayEntry;
  bool _focus = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _timer?.cancel();
    setState(() {
      _overlayEntry?.remove();
      _overlayEntry = null;
      _focus = false;
    });
  }

  OverlayEntry _buildOverlay() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;
    var offset = renderBox.localToGlobal(Offset.zero);
    final theme = Theme.of(context);
    final versionControl = Provider.of<VersionControl>(context, listen: false);

    return OverlayEntry(
      maintainState: true,
      builder: (context) {
        return Positioned(
          top: offset.dy - 150 + (size.height / 2),
          left: offset.dx + size.width + 20.0,
          child: MouseRegion(
            onEnter: (event) {
              setState(() {
                _timer?.cancel();
              });
            },
            onExit: (event) {
              setState(() {
                _timer = Timer(const Duration(seconds: 2), () {
                  _removeOverlay();
                });
              });
            },
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Transform.rotate(
                  angle: -math.pi / 4,
                  child: Container(
                    width: 20.0,
                    height: 20.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4.0),
                      color: Colors.black,
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 10.0,
                          spreadRadius: 2.0,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 350.0,
                  height: 300.0,
                  margin: const EdgeInsets.only(left: 8.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10.0),
                    color: Colors.black,
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 10.0,
                        spreadRadius: 2.0,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10.0,
                      horizontal: 15.0,
                    ),
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${'version_control.version'.tr()}: ${widget.version.code}',
                              style: theme.textTheme.headlineSmall,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.fade,
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _timer?.cancel();
                                  _removeOverlay();
                                });
                              },
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              borderRadius: BorderRadius.circular(8.0),
                              child: const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.close,
                                  color: Colors.grey,
                                  size: 20.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      if (versionControl.current?.code != widget.version.code)
                        WrtButton(
                          callback: () {
                            final provider = Provider.of<ProjectState>(
                              context,
                              listen: false,
                            );
                            provider.openTab(
                              FileTab(
                                path: CompareVersionsPage.pageName,
                                id: null,
                                type: FileType.system,
                              ),
                            );
                            versionControl.compare(widget.version.code);
                            setState(() {
                              _removeOverlay();
                              _timer?.cancel();
                            });
                          },
                          label: 'version_control.compare'.tr(),
                          color: theme.colorScheme.primary,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final versionControl = Provider.of<VersionControl>(context);

    return Container(
      color: versionControl.current?.code == widget.version.code
          ? Colors.white10
          : Colors.transparent,
      height: 30.0,
      margin: const EdgeInsets.only(bottom: 4.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          onTap: () {
            if (_focus) {
              setState(() {
                _removeOverlay();
                _focus = false;
              });
              return;
            }
            setState(() {
              _focus = !_focus;
              _overlayEntry = _buildOverlay();
              Overlay.of(context).insert(_overlayEntry!);
              _timer = Timer(const Duration(seconds: 2), () {
                _removeOverlay();
              });
            });
          },
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(width: 2.0),
              const Icon(
                Icons.linear_scale_rounded,
                size: 20.0,
                color: Colors.grey,
              ),
              const SizedBox(width: 5.0),
              Expanded(
                child: Text(
                  '${widget.version.code}${widget.version.message == null ? '' : ':'} ${widget.version.message ?? ''}',
                  style: theme.textTheme.labelMedium,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.fade,
                ),
              ),
              const SizedBox(width: 5.0),
              if (widget.version.commited)
                Text(
                  '(${'version_control.commited'.tr()})',
                  style: theme.textTheme.bodySmall,
                )
              else
                Text(
                  '(${'version_control.uncommited'.tr()})',
                  style: theme.textTheme.bodySmall,
                ),
              const SizedBox(width: 2.0),
            ],
          ),
        ),
      ),
    );
  }
}
