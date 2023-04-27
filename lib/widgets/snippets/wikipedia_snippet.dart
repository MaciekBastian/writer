import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart' as url;
import 'package:url_launcher/url_launcher_string.dart';

import '../../models/on_this_day.dart';

class WikipediaSnippetTile extends StatelessWidget {
  const WikipediaSnippetTile({super.key, required this.data});

  final WikipediaSnippet? data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (data == null) return Container();

    return ListView(
      padding: const EdgeInsets.all(10.0),
      children: [
        SelectableText(
          data!.title,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8.0),
        SelectableText(
          data!.description,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 8.0),
        const Divider(
          thickness: 2.0,
          color: Color(0xFF212121),
          height: 6.0,
        ),
        const SizedBox(height: 8.0),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SelectableText(
                data!.extract,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.justify,
              ),
            ),
            const SizedBox(width: 8.0),
            if (data!.imageUrl != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    data!.imageUrl!,
                    width: 200,
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8.0),
        if (data!.url != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'wikipedia.source'.tr(),
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(width: 5.0),
                  Expanded(
                    child: InkWell(
                      mouseCursor: SystemMouseCursors.click,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        if (data?.url == null) return;
                        url.launchUrl(
                          Uri.parse(data!.url!),
                          mode: LaunchMode.platformDefault,
                        );
                      },
                      child: Text(
                        '${data!.url}',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: const Color.fromARGB(255, 88, 111, 230),
                          decoration: TextDecoration.underline,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                        softWrap: false,
                      ),
                    ),
                  ),
                ],
              ),
              if (data!.imageUrl != null)
                Row(
                  children: [
                    Text(
                      'wikipedia.image_by'.tr(),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(width: 5.0),
                    Expanded(
                      child: InkWell(
                        mouseCursor: SystemMouseCursors.click,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          if (data?.url == null) return;
                          url.launchUrl(
                            Uri.parse(data!.imageUrl!),
                            mode: LaunchMode.platformDefault,
                          );
                        },
                        child: Text(
                          data!.imageUrl!,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: const Color.fromARGB(255, 88, 111, 230),
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.fade,
                          softWrap: false,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        Text(
          'wikipedia.wikipedia_attribution'.tr(),
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
