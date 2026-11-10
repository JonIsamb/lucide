import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../domain/market_event.dart';
import '../../domain/window_regime.dart';
import '../explanation_texts.dart';

/// Text styles shared by the context and explanation cards.
abstract final class CardText {
  static const body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.45,
    color: AppColors.ink,
  );
  static const small = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.muted,
  );
}

/// "Une période de crise", with a colored dot.
class RegimeHeader extends StatelessWidget {
  const RegimeHeader({super.key, required this.regime});

  final MarketRegime regime;

  @override
  Widget build(BuildContext context) {
    final color = switch (regime) {
      MarketRegime.calm => AppColors.rise,
      MarketRegime.lively => AppColors.primary,
      MarketRegime.crisis => AppColors.fall,
    };
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              regimeTitle(regime),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.ink,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w900,
        color: AppColors.primary,
      ),
    );
  }
}

/// One real event.
///
/// With a [cutoff] (before the answer): its title, the facts dated before
/// the cutoff and how markets read this kind of event, never what followed.
/// Without (after the answer): its title and the whole story.
class EventTile extends StatelessWidget {
  const EventTile({super.key, required this.event, this.cutoff});

  final MarketEvent event;
  final DateTime? cutoff;

  @override
  Widget build(BuildContext context) {
    final cutoff = this.cutoff;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            event.title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          if (cutoff == null)
            Text(event.summary, style: CardText.body)
          else ...[
            for (final milestone in milestonesBefore(event, cutoff))
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '${formatDay(milestone.day)} : ${milestone.text}',
                  style: CardText.body,
                ),
              ),
            const SizedBox(height: 2),
            Text(event.mechanism, style: CardText.body),
          ],
          const SizedBox(height: 4),
          for (final source in event.sources)
            // No link opener in the app: the address can be copied.
            SelectableText(
              '${source.label} : ${source.url}',
              style: CardText.small,
            ),
        ],
      ),
    );
  }
}

class TipRow extends StatelessWidget {
  const TipRow({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2, right: 8),
            child: Icon(
              Icons.check_circle_outline_rounded,
              size: 16,
              color: AppColors.primary,
            ),
          ),
          Expanded(child: Text(text, style: CardText.body)),
        ],
      ),
    );
  }
}
