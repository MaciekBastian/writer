import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../helpers/spell_check_helper.dart';
import '../../models/error/spelling_error.dart';
import '../../providers/project_state.dart';

class SpellCheckPage extends StatefulWidget {
  const SpellCheckPage({super.key});

  @override
  State<SpellCheckPage> createState() => _SpellCheckPageState();
}

class _SpellCheckPageState extends State<SpellCheckPage> {
  bool _loading = true;
  final _pageController = PageController();
  String _tabIdentifier = '';
  List<SpellingError> _misspellings = [];

  @override
  void initState() {
    super.initState();
    _check();
  }

  void _check([bool force = false]) async {
    final provider = Provider.of<ProjectState>(context, listen: false);
    final identifier = provider.selectedTab?.id ??
        provider.selectedTab?.path ??
        provider.selectedTab?.type.name ??
        '';
    if (identifier.isEmpty && _loading) {
      setState(() {
        _loading = false;
      });
    }
    if (identifier == _tabIdentifier && !force) return;
    final content = provider.selectedTabContent;
    if (content == null) return;
    if (!_loading) {
      setState(() {
        _loading = true;
      });
    }
    final result = await SpellCheckHelper().spellCheck(content);
    if (result != null) {
      setState(() {
        _tabIdentifier = identifier;
        _misspellings = result;
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProjectState>(context);
    final content = provider.selectedTabContent;
    final theme = Theme.of(context);

    if (content == null) {
      return Center(
        child: Icon(
          Icons.spellcheck,
          color: Colors.grey[900],
          size: 180.0,
        ),
      );
    }

    if (!_loading) {
      _check();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'spell_check.spell_check'.tr(),
                    style: theme.textTheme.headlineSmall,
                  ),
                  if (_misspellings.isNotEmpty)
                    Container(
                      width: 30.0,
                      height: 30.0,
                      margin: const EdgeInsets.only(left: 10.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        _misspellings.length.toString(),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                ],
              ),
              Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        _check(true);
                      },
                      borderRadius: BorderRadius.circular(6.0),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.refresh,
                          size: 20.0,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (_pageController.page?.toInt() == 0) {
                          return;
                        }
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                        );
                      },
                      borderRadius: BorderRadius.circular(6.0),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.arrow_back,
                          size: 20.0,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6.0),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (_pageController.page?.toInt() ==
                            _misspellings.length) {
                          return;
                        }
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                        );
                      },
                      borderRadius: BorderRadius.circular(6.0),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.arrow_forward,
                          size: 20.0,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Divider(
          height: 10.0,
          thickness: 2.0,
          color: Colors.grey[800]!,
        ),
        if (_loading)
          const LinearProgressIndicator(
            backgroundColor: Colors.transparent,
            minHeight: 4.0,
            color: Color(0xFF1638E2),
          )
        else
          const SizedBox(height: 4.0),
        if (_misspellings.isEmpty)
          Expanded(
            child: Center(
              child: Icon(
                Icons.done_all,
                color: Colors.grey[900],
                size: 180.0,
              ),
            ),
          )
        else
          Expanded(
            child: PageView(
              controller: _pageController,
              children: _misspellings.map((e) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    children: [
                      Text(
                        'spell_check.misspelling'.tr(),
                        style: theme.textTheme.titleSmall,
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        margin: const EdgeInsets.only(top: 5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(6.0),
                                  topRight: Radius.circular(6.0),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 8.0,
                                      bottom: 4.0,
                                      top: 4.0,
                                    ),
                                    child: Text(
                                      'ABC',
                                      style: theme.textTheme.labelSmall,
                                    ),
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () {
                                        SpellCheckHelper().addToDictionary(
                                          e.wordWithError,
                                        );
                                        setState(() {
                                          _misspellings.remove(e);
                                        });
                                      },
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 4.0,
                                          right: 8.0,
                                          bottom: 4.0,
                                          top: 4.0,
                                        ),
                                        child: Text(
                                          'Add to dictionary',
                                          style: theme.textTheme.labelMedium
                                              ?.copyWith(
                                            color: const Color(0xFF6F83E6),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(e.wordWithError),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        'spell_check.where'.tr(),
                        style: theme.textTheme.titleSmall,
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        margin: const EdgeInsets.only(top: 5.0),
                        padding: const EdgeInsets.all(8.0),
                        child: Text(e.sentence),
                      ),
                      const SizedBox(height: 10.0),
                      Text(
                        'spell_check.suggestions'.tr(),
                        style: theme.textTheme.titleSmall,
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                        margin: const EdgeInsets.only(top: 5.0),
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: e.suggestions.map((e) {
                            return Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {},
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(8.0),
                                  margin: const EdgeInsets.only(bottom: 4.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8.0),
                                    border: Border.all(
                                      color: Colors.grey[800]!,
                                      width: 2.0,
                                    ),
                                  ),
                                  child: Text(e),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
