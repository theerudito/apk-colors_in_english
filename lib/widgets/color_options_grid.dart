import 'package:flutter/material.dart';

import '../db/database_helper.dart';
import '../theme/app_style.dart';

class ColorOptionsGrid extends StatelessWidget {
  final List<GameColor> options;
  final String lang;
  final Set<int> revealedWrong;
  final bool revealAll;
  final bool enabled;
  final ValueChanged<int> onSelected;

  const ColorOptionsGrid({
    super.key,
    required this.options,
    required this.lang,
    required this.revealedWrong,
    required this.revealAll,
    required this.enabled,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: options.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: isTablet ? 3.2 : 2.6,
        crossAxisSpacing: isTablet ? 24 : 18,
        mainAxisSpacing: isTablet ? 24 : 22,
      ),
      itemBuilder: (context, index) {
        final item = options[index];
        final showName = revealAll || revealedWrong.contains(index);
        final textColor = revealAll
            ? Colors.black
            : revealedWrong.contains(index)
                ? Colors.white
                : Colors.transparent;

        return Material(
          color: item.paintFor(lang),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: const BorderSide(color: Colors.white, width: 2),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: enabled ? () => onSelected(index) : null,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  showName ? item.nameFor(lang) : '',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      AppStyle.pixel(size: isTablet ? 10 : 8, color: textColor),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
