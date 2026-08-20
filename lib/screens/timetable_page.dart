import 'package:flutter/material.dart';

import '../data/app_data.dart';
import '../models/schedule_slot.dart';
import '../navigation/app_routes.dart';
import '../services/admin_content_controller.dart';
import '../theme/app_colors.dart';
import '../theme/app_gradients.dart';
import '../theme/app_text_styles.dart';
import '../utils/day_of_week.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/pulsing_opacity.dart';
import '../widgets/section_header.dart';

class TimetablePage extends StatefulWidget {
  const TimetablePage({super.key});

  @override
  State<TimetablePage> createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  String _day = todayDayCode();

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      activeLabel: 'Timetable',
      onSelect: (label) => AppRoutes.navigateToLabel(context, label),
      builder: (context, openDrawer) => Container(
        decoration: const BoxDecoration(gradient: AppGradients.section),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              SectionHeader(title: 'Timetable', onMenuTap: openDrawer),
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                  itemCount: AppData.days.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, i) {
                    final d = AppData.days[i];
                    final active = d == _day;
                    return GestureDetector(
                      onTap: () => setState(() => _day = d),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: active ? AppGradients.button : null,
                          color: active ? null : AppColors.whiteAlpha(0.05),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                              color: active
                                  ? Colors.transparent
                                  : AppColors.whiteAlpha(0.12)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          d,
                          style: AppText.mono(
                            size: 11,
                            weight: FontWeight.w700,
                            color: active
                                ? Colors.white
                                : AppColors.whiteAlpha(0.6),
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                child: ListenableBuilder(
                  listenable: AdminContentController.instance,
                  builder: (context, _) {
                    final slots = AdminContentController
                            .instance.schedule[dayKeyForCode(_day)] ??
                        const [];
                    final isToday = _day == todayDayCode();

                    if (slots.isEmpty) {
                      return Center(
                        child: Text(
                          'Nothing scheduled for this day yet.',
                          style: AppText.archivo(
                              size: 13,
                              weight: FontWeight.w400,
                              color: AppColors.whiteAlpha(0.5)),
                        ),
                      );
                    }

                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 6, 20, 30),
                      itemCount: slots.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, i) {
                        final live = isToday &&
                            isSlotOnAir(
                              time: slots[i].time,
                              nextTime: i + 1 < slots.length
                                  ? slots[i + 1].time
                                  : null,
                              now: colomboNow(),
                            );
                        return _ScheduleCard(slot: slots[i], live: live);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final ScheduleSlot slot;
  final bool live;

  const _ScheduleCard({required this.slot, required this.live});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      decoration: BoxDecoration(
        color: live ? null : AppColors.whiteAlpha(0.04),
        gradient: live ? AppGradients.scheduleLive : null,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color:
                live ? AppColors.orbitAlpha(0.45) : AppColors.whiteAlpha(0.07)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: SizedBox(
              width: 44,
              child: Text(slot.time,
                  style: AppText.mono(
                      size: 12,
                      weight: FontWeight.w700,
                      color: AppColors.orbit)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    slot.title,
                    style: AppText.archivo(
                        size: 15, weight: FontWeight.w600, color: Colors.white),
                  ),
                ),
                if (live) ...[
                  const SizedBox(width: 8),
                  PulsingOpacity(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                          color: AppColors.liveRed,
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(
                        'ON AIR',
                        style: AppText.mono(
                            size: 9,
                            weight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 1),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
