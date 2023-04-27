import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_audio/simple_audio.dart';
import 'package:url_launcher/url_launcher.dart' as url;
import '../../helpers/apis_helper.dart';
import '../../models/word_definition.dart';
import '../../providers/project_state.dart';
import '../../widgets/button.dart';
import '../../widgets/text_field.dart';

class DictionaryPage extends StatefulWidget {
  const DictionaryPage({super.key, this.compact = false});

  final bool compact;

  @override
  State<DictionaryPage> createState() => _DictionaryPageState();
}

class _DictionaryPageState extends State<DictionaryPage> {
  List<WordDefinition>? _definitions;
  String _searchWord = '';
  bool _error = false;
  bool _loading = false;

  final SimpleAudio _player = SimpleAudio();

  void _search() async {
    setState(() {
      _loading = true;
    });
    if (_searchWord.isNotEmpty) {
      final def = await APIsHelper().lookupWordDefinitions(
        _searchWord.toLowerCase().trim(),
      );
      if (def != null) {
        setState(() {
          _error = false;
          _loading = false;
          _definitions = def;
        });
      } else {
        setState(() {
          _loading = false;
          _error = true;
          _definitions = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ProjectState>(context);

    return ListView(
      padding: const EdgeInsets.symmetric(
        vertical: 20.0,
        horizontal: 25.0,
      ),
      children: [
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 40.0,
                child: WrtTextField(
                  onEdit: (val) {
                    setState(() {
                      _searchWord = val;
                    });
                  },
                  onSubmit: (value) {
                    setState(() {
                      _searchWord = value;
                    });
                    _search();
                  },
                  altText: 'dictionary.search_hint'.tr(),
                  borderless: true,
                  maxLines: 1,
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            WrtButton(
              callback: () {
                _search();
              },
              label: 'dictionary.search'.tr(),
            ),
          ],
        ),
        if (_loading)
          const LinearProgressIndicator(
            backgroundColor: Colors.transparent,
            minHeight: 4.0,
            color: Color(0xFF1638E2),
          )
        else
          const SizedBox(height: 4.0),
        const SizedBox(height: 8.0),
        if (_error)
          Text(
            '${'dictionary.error_occurred'.tr()}!',
            style: theme.textTheme.titleMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        if (_definitions != null)
          if (_definitions!.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!widget.compact &&
                    !provider.smallScreenView &&
                    !provider.rightSidebar)
                  Expanded(
                    flex: 2,
                    child: SelectableText(
                      _definitions!.first.word,
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                Expanded(
                  flex: 3,
                  child: Column(
                    children: List.generate(
                      _definitions!.length,
                      (index) {
                        final element = _definitions![index];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 35.0,
                              height: 35.0,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: const Color(0xFF1638E2),
                                  width: 4.0,
                                ),
                              ),
                              child: Text(
                                '${index + 1}.',
                                style: theme.textTheme.titleMedium,
                              ),
                            ),
                            const SizedBox(width: 15.0),
                            Expanded(child: _definitionTile(element)),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
        const SizedBox(height: 20.0),
        Text(
          'dictionary.internet_needed'.tr(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.grey,
          ),
        ),
        Text(
          'dictionary.english_only'.tr(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.grey,
          ),
        ),
        Text(
          'dictionary.attribution'.tr(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Column _definitionTile(WordDefinition element) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          element.word,
          style: theme.textTheme.headlineSmall,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                '${'dictionary.pronunciation'.tr()}:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
              ),
            ),
            const SizedBox(width: 8.0),
            if (element.phonetics.where((element) {
              return element.audio != null && element.text != null;
            }).isNotEmpty)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: element.phonetics.where((element) {
                    return element.audio != null &&
                        (element.audio?.isNotEmpty ?? false) &&
                        element.text != null;
                  }).map((e) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 30.0,
                          height: 30.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF1638E2),
                              width: 2.0,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                setState(() {
                                  _loading = true;
                                });
                                if (await _player.isPlaying) {
                                  await _player.stop();
                                }

                                try {
                                  await _player.open(e.audio!, autoplay: true);
                                  setState(() {
                                    _loading = false;
                                  });
                                } catch (e) {
                                  setState(() {
                                    _loading = false;
                                  });
                                }
                              },
                              borderRadius: BorderRadius.circular(50.0),
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              child: const Icon(
                                Icons.multitrack_audio,
                                size: 20.0,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 45.0, width: 15.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.text!,
                                style: theme.textTheme.titleMedium,
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                              ),
                              const SizedBox(height: 4.0),
                              if (e.licenseName != null && e.licenseUrl != null)
                                InkWell(
                                  focusColor: Colors.transparent,
                                  hoverColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onTap: () {
                                    url.launchUrl(
                                      Uri.parse(e.licenseUrl!),
                                      mode: url.LaunchMode.platformDefault,
                                    );
                                  },
                                  child: Text.rich(
                                    TextSpan(
                                      children: [
                                        TextSpan(
                                          text:
                                              '${'dictionary.license'.tr()}: ',
                                          style: theme.textTheme.labelSmall,
                                        ),
                                        TextSpan(
                                          text: e.licenseName!,
                                        ),
                                      ],
                                    ),
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: const Color(0xFF6F83E6),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              )
            else if (element.phonetic != null)
              SelectableText(
                element.phonetic!,
                style: theme.textTheme.titleMedium,
              )
            else
              Text(
                'dictionary.none'.tr(),
                style: theme.textTheme.titleMedium,
              ),
          ],
        ),
        const SizedBox(height: 10.0),
        ...element.meanings.map((e) {
          return SelectableRegion(
            focusNode: FocusNode(),
            selectionControls: DesktopTextSelectionControls(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (e.partOfSpeech != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 5.0),
                    child: Text(
                      'dictionary.parts_of_speech.${e.partOfSpeech}'.tr(),
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ...List.generate(e.definitions.length, (index) {
                  final def = e.definitions[index];
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${index + 1}.'),
                      const SizedBox(width: 6.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              def.definition,
                              style: theme.textTheme.bodyMedium,
                              maxLines: 20,
                            ),
                            if (def.example != null)
                              Text(
                                '"${def.example!}"',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: Colors.grey,
                                  fontStyle: FontStyle.italic,
                                ),
                                maxLines: 20,
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
                const SizedBox(height: 5.0),
                if (e.synonyms.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${'dictionary.synonyms'.tr()}: ',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          e.synonyms.join(', '),
                          style: theme.textTheme.labelMedium,
                        ),
                      ),
                    ],
                  ),
                if (e.antonyms.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${'dictionary.antonyms'.tr()}: ',
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(width: 8.0),
                      Expanded(
                        child: Text(
                          e.antonyms.join(', '),
                          style: theme.textTheme.labelMedium,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 10.0),
              ],
            ),
          );
        }).toList(),
        if (element.sources.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${'dictionary.source'.tr()}: ',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: element.sources.map((e) {
                      return InkWell(
                        focusColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          url.launchUrl(
                            Uri.parse(e),
                            mode: url.LaunchMode.platformDefault,
                          );
                        },
                        child: Text(
                          e,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: const Color(0xFF6F83E6),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        if (element.licenseName != null && element.licenseUrl != null)
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: InkWell(
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                url.launchUrl(
                  Uri.parse(element.licenseUrl!),
                  mode: url.LaunchMode.platformDefault,
                );
              },
              child: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: '${'dictionary.license'.tr()}: ',
                      style: theme.textTheme.labelMedium,
                    ),
                    TextSpan(text: element.licenseName!),
                  ],
                ),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF6F83E6),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),
        const SizedBox(height: 30.0),
      ],
    );
  }
}
