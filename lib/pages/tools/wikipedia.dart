import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../helpers/apis_helper.dart';
import '../../widgets/snippets/wikipedia_snippet.dart';

import '../../models/language.dart';
import '../../models/on_this_day.dart';
import '../../providers/cache.dart';
import '../../providers/project_state.dart';
import '../../widgets/button.dart';
import '../../widgets/text_field.dart';

class WikipediaPage extends StatefulWidget {
  const WikipediaPage({super.key});

  @override
  State<WikipediaPage> createState() => _WikipediaPageState();
}

class _WikipediaPageState extends State<WikipediaPage> {
  WikipediaSnippet? _snippet;
  String _query = '';
  bool _error = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    final project = Provider.of<ProjectState>(context, listen: false);
    final cache = Provider.of<ProjectCache>(context, listen: false);
    if (project.project != null) {
      cache.initalize(project.project!);
    }
  }

  void _search() async {
    setState(() {
      _loading = true;
      _error = false;
    });
    final project = Provider.of<ProjectState>(context, listen: false);
    final language = project.project?.language == ProjectLanguage.en
        ? 'en'
        : project.project?.language == ProjectLanguage.pl
            ? 'pl'
            : 'en';

    final response = await APIsHelper().queryWikipedia(
      _query.toLowerCase(),
      language,
    );

    if (response == null) {
      setState(() {
        _loading = false;
        _error = true;
      });
    } else {
      setState(() {
        _loading = false;
        _error = false;
        _snippet = response;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final project = Provider.of<ProjectState>(context);
    final cache = Provider.of<ProjectCache>(context);

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40.0,
                  child: WrtTextField(
                    onEdit: (val) {
                      setState(() {
                        _query = val;
                      });
                    },
                    onSubmit: (value) {
                      setState(() {
                        _query = value;
                      });
                      _search();
                    },
                    altText: 'wikipedia.search_for_article'.tr(),
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
                label: 'wikipedia.search'.tr(),
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
              '${'wikipedia.error_occurred'.tr()}!',
              style: theme.textTheme.titleMedium?.copyWith(
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          if (_snippet != null)
            WrtButton(
              callback: () {
                if (cache.hasThisSnippet(_snippet!.url)) {
                  cache.removeSnippet(_snippet!.url);
                } else {
                  cache.addSnippet(_snippet!);
                }
              },
              label: cache.hasThisSnippet(_snippet!.url)
                  ? 'wikipedia.remove'.tr()
                  : 'wikipedia.download'.tr(),
            ),
          if (_snippet != null)
            Expanded(
              child: WikipediaSnippetTile(data: _snippet),
            ),
          ...cache.wikipediaSnippets.map((e) {
            return Row(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () {
                      setState(() {
                        _snippet = e;
                      });
                    },
                    child: Row(
                      children: [
                        if (e.imageUrl != null)
                          SizedBox(
                            width: 90.0,
                            height: 90.0,
                            child: Image.network(
                              e.imageUrl!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        const SizedBox(width: 10.0),
                        SizedBox(
                          height: 90.0,
                          width: 200.0,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                e.title,
                                style: theme.textTheme.titleMedium,
                                maxLines: 2,
                                overflow: TextOverflow.fade,
                              ),
                              Text(
                                e.description,
                                style: theme.textTheme.bodySmall,
                                maxLines: 2,
                                overflow: TextOverflow.fade,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: SizedBox(
                    height: 90.0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_outlined,
                          size: 20.0,
                          color: Colors.grey,
                        ),
                        if (e.url != null)
                          Row(
                            children: [
                              const Icon(Icons.link),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Text(
                                  e.url!,
                                  style: theme.textTheme.bodySmall,
                                  maxLines: 1,
                                  softWrap: false,
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                )
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}
