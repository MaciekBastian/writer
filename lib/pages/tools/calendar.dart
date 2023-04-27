import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../helpers/apis_helper.dart';
import '../../widgets/button.dart';

import '../../models/on_this_day.dart';
import '../../providers/project_state.dart';
import '../../widgets/expandable_section.dart';
import '../../widgets/hover_box.dart';
import '../../widgets/snippets/wikipedia_snippet.dart';
import '../../widgets/tooltip.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key, this.compact = false});

  final bool compact;

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime _selectedDate = DateTime.now();

  bool _loading = false;
  OnThisDay? _onThisDay;
  List<String>? _nameDay;

  void _saveDate(DateTime date) {
    final provider = Provider.of<ProjectState>(context, listen: false);
    provider.saveDate(date);
  }

  void _getDataForTheDate() async {
    final lang = Provider.of<ProjectState>(
      context,
      listen: false,
    ).project?.language;
    if (lang == null) return;
    setState(() {
      _loading = true;
    });
    _nameDay = await APIsHelper().getNameday(_selectedDate, lang);
    _onThisDay = await APIsHelper().getOnThisDay(_selectedDate);
    setState(() {
      _loading = false;
    });
  }

  Widget _buildDateDetailsSection() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_onThisDay != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Text(
              '${'calendar.date_format'.tr(namedArgs: {
                    'month': 'calendar.months.${_onThisDay!.date.month}'.tr(),
                    'year': _onThisDay!.date.year.toString(),
                    'day': _onThisDay!.date.day.toString(),
                  })}:',
              style: theme.textTheme.labelSmall,
            ),
          ),
        if (_nameDay != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100.0,
                child: Text(
                  'calendar.nameday'.tr(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  _nameDay!.join(', '),
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        const SizedBox(height: 8.0),
        if (_onThisDay != null && (_onThisDay?.births.isNotEmpty ?? false))
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100.0,
                child: Text(
                  'calendar.famous_births'.tr(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 2.0),
                  child: WrtExpandableSection(
                    content: _buildPeopleOrEvents(_onThisDay!.births, null),
                    header: _onThisDay!.births.length > 3
                        ? Text(
                            '${_onThisDay!.births[0].name.substring(
                              0,
                              (!_onThisDay!.births[0].name.contains(',')
                                  ? null
                                  : _onThisDay!.births[0].name.indexOf(',')),
                            )} (${_onThisDay!.births[0].year}), ${_onThisDay!.births[1].name.substring(
                              0,
                              (!_onThisDay!.births[1].name.contains(',')
                                  ? null
                                  : _onThisDay!.births[1].name.indexOf(',')),
                            )} (${_onThisDay!.births[1].year}) ${'calendar.and_more'.tr(
                              namedArgs: {
                                'count':
                                    (_onThisDay!.births.length - 2).toString(),
                              },
                            )}',
                            style: theme.textTheme.bodySmall,
                            softWrap: false,
                            maxLines: 3,
                            overflow: TextOverflow.fade,
                          )
                        : Text(
                            _onThisDay!.births.map(
                              (e) {
                                return e.name.substring(
                                  0,
                                  (!e.name.contains(',')
                                      ? null
                                      : e.name.indexOf(',')),
                                );
                              },
                            ).join(', '),
                            style: theme.textTheme.bodySmall,
                            softWrap: false,
                            maxLines: 3,
                            overflow: TextOverflow.fade,
                          ),
                    initiallyExpanded: false,
                  ),
                ),
              ),
            ],
          ),
        if (_onThisDay != null && (_onThisDay?.deaths.isNotEmpty ?? false))
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100.0,
                child: Text(
                  'calendar.famous_deaths'.tr(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 2.0),
                  child: WrtExpandableSection(
                    content: _buildPeopleOrEvents(_onThisDay!.deaths, null),
                    header: _onThisDay!.deaths.length > 3
                        ? Text(
                            '${_onThisDay!.deaths[0].name.substring(
                              0,
                              (!_onThisDay!.deaths[0].name.contains(',')
                                  ? null
                                  : _onThisDay!.deaths[0].name.indexOf(',')),
                            )} (${_onThisDay!.deaths[0].year}), ${_onThisDay!.deaths[1].name.substring(
                              0,
                              (!_onThisDay!.deaths[1].name.contains(',')
                                  ? null
                                  : _onThisDay!.deaths[1].name.indexOf(',')),
                            )} (${_onThisDay!.deaths[1].year}) ${'calendar.and_more'.tr(
                              namedArgs: {
                                'count':
                                    (_onThisDay!.deaths.length - 2).toString(),
                              },
                            )}',
                            style: theme.textTheme.bodySmall,
                            softWrap: false,
                            maxLines: 3,
                            overflow: TextOverflow.fade,
                          )
                        : Text(
                            _onThisDay!.deaths.map(
                              (e) {
                                return e.name.substring(
                                  0,
                                  (!e.name.contains(',')
                                      ? null
                                      : e.name.indexOf(',')),
                                );
                              },
                            ).join(', '),
                            style: theme.textTheme.bodySmall,
                            softWrap: false,
                            maxLines: 3,
                            overflow: TextOverflow.fade,
                          ),
                    initiallyExpanded: false,
                  ),
                ),
              ),
            ],
          ),
        if (_onThisDay != null && (_onThisDay?.events.isNotEmpty ?? false))
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100.0,
                child: Text(
                  'calendar.events'.tr(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 2.0),
                  child: WrtExpandableSection(
                    content: _buildPeopleOrEvents(null, _onThisDay!.events),
                    header: _onThisDay!.deaths.length > 3
                        ? Text(
                            '${_onThisDay!.events[0].name.substring(
                              0,
                              (!_onThisDay!.events[0].name.contains('.')
                                  ? null
                                  : _onThisDay!.events[0].name.indexOf('.')),
                            )} (${_onThisDay!.events[0].year}), ${_onThisDay!.events[1].name.substring(
                              0,
                              (!_onThisDay!.events[1].name.contains('.')
                                  ? null
                                  : _onThisDay!.events[1].name.indexOf('.')),
                            )} (${_onThisDay!.events[1].year}) ${'calendar.and_more'.tr(
                              namedArgs: {
                                'count':
                                    (_onThisDay!.events.length - 2).toString(),
                              },
                            )}',
                            style: theme.textTheme.bodySmall,
                            softWrap: false,
                            maxLines: 3,
                            overflow: TextOverflow.fade,
                          )
                        : Text(
                            _onThisDay!.deaths.map(
                              (e) {
                                return e.name.substring(
                                  0,
                                  (!e.name.contains(',')
                                      ? null
                                      : e.name.indexOf(',')),
                                );
                              },
                            ).join(', '),
                            style: theme.textTheme.bodySmall,
                            softWrap: false,
                            maxLines: 3,
                            overflow: TextOverflow.fade,
                          ),
                    initiallyExpanded: false,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildPeopleOrEvents(
    List<PersonBirthOrDeath>? people,
    List<Event>? events,
  ) {
    final theme = Theme.of(context);
    final years = people != null
        ? people.map((e) => e.year).toList()
        : events!.map((e) => e.year).toList();
    final centuries = years
        .map(
          (e) {
            if (e.isNegative) {
              return -(int.parse(e
                      .toString()
                      .substring(1, e.toString().length == 4 ? 3 : 2)) +
                  1);
            }
            return int.parse(e
                    .toString()
                    .substring(0, e.toString().length == 4 ? 2 : 1)) +
                1;
          },
        )
        .toSet()
        .toList();
    final keys = List.generate(centuries.length, (index) => GlobalKey());
    final labels = centuries.map((e) {
      final lastDigit = int.parse(e.toString().characters.last);
      final ending = e > 10 && e < 20
          ? 'th'
          : lastDigit == 1
              ? 'st'
              : lastDigit == 2
                  ? 'nd'
                  : lastDigit == 3
                      ? 'rd'
                      : 'th';
      return '$e${context.locale.languageCode.contains('en') ? ending : ''} ${'calendar.century'.tr()}';
    }).toList();

    final sortedByCentury = centuries.map(
      (e) {
        return (people ?? events!).where((element) {
          return (element is PersonBirthOrDeath
                  ? element.year
                  : element is Event
                      ? element.year
                      : 0)
              .toString()
              .startsWith((e - 1).toString());
        }).toList();
      },
    ).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            children: labels.map(
              (e) {
                final index = labels.indexOf(e);
                return WidgetSpan(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10.0),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (keys[index].currentContext != null) {
                            Scrollable.ensureVisible(
                              keys[index].currentContext!,
                            );
                          }
                        },
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        mouseCursor: SystemMouseCursors.click,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Text(
                            e,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: const Color(0xFF6F83E6),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ).toList(),
          ),
        ),
        ...List.generate(sortedByCentury.length, (index) {
          return Container(
            key: keys[index],
            margin: const EdgeInsets.only(top: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: sortedByCentury[index].map((e) {
                return HoverBox(
                  showOnTheLeft: true,
                  content: WikipediaSnippetTile(
                    data: e is PersonBirthOrDeath
                        ? e.relatedPages.first
                        : e is Event
                            ? e.relatedPages.first
                            : null,
                  ),
                  size: const Size(400, 250),
                  autoDecideIfBottom: true,
                  showOnTheBottom: false,
                  waitTime: const Duration(milliseconds: 1000),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (e is PersonBirthOrDeath
                                ? e.year
                                : e is Event
                                    ? e.year
                                    : 0)
                            .toString(),
                        style: theme.textTheme.bodyLarge,
                        softWrap: false,
                        maxLines: 1,
                        overflow: TextOverflow.fade,
                      ),
                      const SizedBox(width: 10.0),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              (e is PersonBirthOrDeath
                                  ? e.name
                                  : e is Event
                                      ? e.name
                                      : ''),
                              style: theme.textTheme.bodyMedium,
                              softWrap: false,
                              maxLines: 1,
                              overflow: TextOverflow.fade,
                            ),
                            const SizedBox(height: 10.0),
                            WrtExpandableSection(
                              header: Text(
                                'calendar.sources'.tr(),
                                style: theme.textTheme.bodySmall,
                              ),
                              content: Column(
                                children: [
                                  // TODO: open wikipedia articles
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          );
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = Provider.of<ProjectState>(context);
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10.0),
                  height: 130.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '${'calendar.month_names.${_selectedDate.month}'.tr()} ${_selectedDate.year}',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.fade,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              borderRadius: BorderRadius.circular(12.0),
                              onTap: () {
                                int day = _selectedDate.day;

                                final newDate = DateTime(
                                  _selectedDate.year - 1,
                                  _selectedDate.month,
                                  1,
                                );
                                if (day > 28) {
                                  final months30 = [4, 6, 9, 11];
                                  if (months30.contains(
                                    newDate.month,
                                  )) {
                                    if (day == 31) {
                                      day = 30;
                                    }
                                  } else if (newDate.month == 2) {
                                    day = 28;
                                  }
                                }
                                setState(() {
                                  _selectedDate = DateTime(
                                    newDate.year,
                                    newDate.month,
                                    day,
                                  );
                                });
                              },
                              child: Container(
                                width: 30.0,
                                height: 30.0,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.fast_rewind_outlined,
                                  size: 20.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5.0),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              borderRadius: BorderRadius.circular(12.0),
                              onTap: () {
                                setState(() {
                                  _selectedDate = DateTime.now();
                                });
                              },
                              child: Container(
                                width: 30.0,
                                height: 30.0,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.event_outlined,
                                  size: 20.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 5.0),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              borderRadius: BorderRadius.circular(12.0),
                              onTap: () {
                                int day = _selectedDate.day;

                                final newDate = DateTime(
                                  _selectedDate.year + 1,
                                  _selectedDate.month,
                                  1,
                                );
                                if (day > 28) {
                                  final months30 = [4, 6, 9, 11];
                                  if (months30.contains(
                                    newDate.month,
                                  )) {
                                    if (day == 31) {
                                      day = 30;
                                    }
                                  } else if (newDate.month == 2) {
                                    day = 28;
                                  }
                                }
                                setState(() {
                                  _selectedDate = DateTime(
                                    newDate.year,
                                    newDate.month,
                                    day,
                                  );
                                });
                              },
                              child: Container(
                                width: 30.0,
                                height: 30.0,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.fast_forward_outlined,
                                  size: 20.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              borderRadius: BorderRadius.circular(12.0),
                              onTap: () {
                                int day = _selectedDate.day;
                                final firstOfMonth = DateTime(
                                  _selectedDate.year,
                                  _selectedDate.month,
                                  1,
                                );
                                final newDate = firstOfMonth.subtract(
                                  const Duration(days: 1),
                                );
                                if (day > 28) {
                                  final months30 = [4, 6, 9, 11];
                                  if (months30.contains(
                                    newDate.month,
                                  )) {
                                    if (day == 31) {
                                      day = 30;
                                    }
                                  } else if (newDate.month == 2) {
                                    day = 28;
                                  }
                                }
                                setState(() {
                                  _selectedDate = DateTime(
                                    newDate.year,
                                    newDate.month,
                                    day,
                                  );
                                });
                              },
                              child: Container(
                                width: 30.0,
                                height: 30.0,
                                alignment: Alignment.center,
                                child: const Icon(
                                  Icons.arrow_back,
                                  size: 20.0,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              highlightColor: Colors.transparent,
                              splashColor: Colors.transparent,
                              borderRadius: BorderRadius.circular(12.0),
                              onTap: () {
                                int day = _selectedDate.day;
                                final lastOfMonth = DateTime(
                                  _selectedDate.year,
                                  _selectedDate.month,
                                  [4, 6, 9, 11].contains(_selectedDate.month)
                                      ? 30
                                      : _selectedDate.month == 2
                                          ? (_selectedDate.year % 4 == 0) &&
                                                  ((_selectedDate.year % 100 !=
                                                          0) ||
                                                      (_selectedDate.year %
                                                              400 ==
                                                          0))
                                              ? 29
                                              : 28
                                          : 31,
                                );
                                final newDate = lastOfMonth.add(
                                  const Duration(days: 1),
                                );
                                if (day > 28) {
                                  final months30 = [4, 6, 9, 11];
                                  if (months30.contains(
                                    newDate.month,
                                  )) {
                                    if (day == 31) {
                                      day = 30;
                                    }
                                  } else if (newDate.month == 2) {
                                    day = 28;
                                  }
                                }
                                setState(() {
                                  _selectedDate = DateTime(
                                    newDate.year,
                                    newDate.month,
                                    day,
                                  );
                                });
                              },
                              child: Container(
                                width: 30.0,
                                height: 30.0,
                                alignment: Alignment.center,
                                child: const Icon(
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
                TableCalendar(
                  focusedDay: _selectedDate,
                  selectedDayPredicate: (day) =>
                      day.day == _selectedDate.day &&
                      day.month == _selectedDate.month &&
                      day.year == _selectedDate.year,
                  firstDay: DateTime(1800),
                  lastDay: DateTime(2100),
                  locale: context.locale.languageCode,
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'M',
                  },
                  headerVisible: false,
                  startingDayOfWeek: StartingDayOfWeek.values.firstWhere(
                    (el) =>
                        el.name == 'calendar.first_day_of_week_ALWAYS_EN'.tr(),
                  ),
                  availableGestures: AvailableGestures.horizontalSwipe,
                  currentDay: DateTime.now(),
                  weekNumbersVisible: true,
                  calendarBuilders: CalendarBuilders(
                    dowBuilder: (context, day) {
                      return SizedBox(
                        height: 20.0,
                        child: Text(
                          'calendar.days_of_week.${day.weekday}'
                              .tr()
                              .substring(0, 3)
                              .toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    },
                    defaultBuilder: (context, day, focusedDay) {
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          borderRadius: BorderRadius.circular(12.0),
                          onTap: () {
                            setState(() {
                              _selectedDate = day;
                            });
                          },
                          onDoubleTap: () => _saveDate(day),
                          child: Container(
                            width: 40.0,
                            height: 40.0,
                            alignment: Alignment.center,
                            child: Text(
                              day.day.toString(),
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                        ),
                      );
                    },
                    selectedBuilder: (context, day, focusedDay) {
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          borderRadius: BorderRadius.circular(12.0),
                          onDoubleTap: () => _saveDate(day),
                          child: Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              color: theme.colorScheme.primary,
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              day.day.toString(),
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                        ),
                      );
                    },
                    todayBuilder: (context, day, focusedDay) {
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          borderRadius: BorderRadius.circular(12.0),
                          onDoubleTap: () => _saveDate(day),
                          onTap: () {
                            setState(() {
                              _selectedDate = day;
                            });
                          },
                          child: Container(
                            width: 40.0,
                            height: 40.0,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                color: theme.colorScheme.primary,
                                width: 2.0,
                              ),
                            ),
                            child: Text(
                              day.day.toString(),
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                        ),
                      );
                    },
                    outsideBuilder: (context, day, focusedDay) {
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          borderRadius: BorderRadius.circular(12.0),
                          onTap: () {
                            setState(() {
                              _selectedDate = day;
                            });
                          },
                          onDoubleTap: () => _saveDate(day),
                          child: Container(
                            width: 40.0,
                            height: 40.0,
                            alignment: Alignment.center,
                            child: Text(
                              day.day.toString(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    weekNumberBuilder: (context, weekNumber) {
                      return Container(
                        width: 30.0,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Text(
                          '$weekNumber.',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'calendar.date_format'.tr(namedArgs: {
                      'month': 'calendar.months.${_selectedDate.month}'.tr(),
                      'day': _selectedDate.day.toString(),
                      'year': _selectedDate.year.toString(),
                    }),
                    style: theme.textTheme.headlineSmall,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'calendar.days_of_week.${_selectedDate.weekday}'.tr(),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                ),
                if (!widget.compact)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: WrtButton(
                      callback: () {
                        if (_onThisDay?.date != null) {
                          final day = DateTime(
                            _onThisDay!.date.year,
                            _onThisDay!.date.month,
                            _onThisDay!.date.day,
                          );
                          final selected = DateTime(
                            _selectedDate.year,
                            _selectedDate.month,
                            _selectedDate.day,
                          );
                          if (day.isAtSameMomentAs(selected)) return;
                        }
                        _getDataForTheDate();
                      },
                      label: 'calendar.search_internet_for_this_date'.tr(),
                    ),
                  ),
                if (_loading)
                  const LinearProgressIndicator(
                    backgroundColor: Colors.transparent,
                    minHeight: 4.0,
                    color: Color(0xFF1638E2),
                  ),
                if (!widget.compact && !provider.rightSidebar)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: _buildDateDetailsSection(),
                  ),
                const SizedBox(height: 30.0),
              ],
            ),
          ),
        ),
        if (!widget.compact && !provider.rightSidebar)
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.symmetric(
                vertical: 10.0,
                horizontal: 8.0,
              ),
              color: theme.colorScheme.surfaceVariant,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'calendar.saved_dates'.tr(),
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    'calendar.double_click_to_save'.tr(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onBackground,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Expanded(
                    child: ListView(
                      children: provider.savedDates.map((e) {
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedDate = e;
                              });
                            },
                            onDoubleTap: () {
                              provider.deleteDate(e);
                            },
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'calendar.date_format'.tr(namedArgs: {
                                  'month': 'calendar.months.${e.month}'.tr(),
                                  'year': e.year.toString(),
                                  'day': e.day.toString(),
                                }),
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
