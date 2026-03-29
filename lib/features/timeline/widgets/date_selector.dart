import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateSelector extends StatefulWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;

  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
  });

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // 延迟滚动到最后一个位置（最新日期）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();

    // 生成最近14天
    final dates = List.generate(14, (i) {
      return DateTime(today.year, today.month, today.day - (13 - i));
    });

    return SizedBox(
      height: 72,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: dates.length + 1, // +1 for date picker button
        itemBuilder: (context, index) {
          if (index == dates.length) {
            // 最后一项：日期选择器按钮
            return Padding(
              padding: const EdgeInsets.only(left: 6),
              child: _MoreDateButton(
                onTap: () => _showDatePicker(context),
              ),
            );
          }
          final date = dates[index];
          final isSelected = _isSameDay(date, widget.selectedDate);
          final isToday = _isSameDay(date, today);

          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => widget.onDateChanged(date),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? Colors.transparent
                        : theme.colorScheme.onSurface.withValues(alpha: 0.08),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('E', 'zh_CN').format(date),
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.8)
                            : theme.colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${date.day}',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    if (isToday)
                      Container(
                        width: 4,
                        height: 4,
                        margin: const EdgeInsets.only(top: 2),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? Colors.white
                              : theme.colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  void _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) widget.onDateChanged(picked);
  }
}

class _MoreDateButton extends StatelessWidget {
  final VoidCallback onTap;
  const _MoreDateButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52,
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_month_rounded,
              size: 20,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 2),
            Text(
              '更多',
              style: TextStyle(
                fontSize: 10,
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
