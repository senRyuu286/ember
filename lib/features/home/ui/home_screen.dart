import 'package:ember/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/entities/home_navigation.dart';
import '../providers/home_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(homeCurrentIndexProvider);
    final destinations = ref.watch(homeDestinationsProvider);
    final screens = ref.watch(homeScreensProvider);

    return Scaffold(
      extendBody: true,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: KeyedSubtree(
          key: ValueKey<int>(currentIndex),
          child: screens[currentIndex],
        ),
      ),
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: currentIndex,
        destinations: destinations,
        onTap: (index) {
          ref.read(homeCurrentIndexProvider.notifier).selectTab(index);
        },
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final List<HomeNavDestination> destinations;
  final ValueChanged<int> onTap;

  const _FloatingNavBar({
    required this.currentIndex,
    required this.destinations,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.darkBackground,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: AppColors.black.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(destinations.length, (index) {
              final dest = destinations[index];
              final isSelected = index == currentIndex;

              return GestureDetector(
                onTap: () => onTap(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? 16 : 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? dest.selectedIcon : dest.icon,
                        size: 22,
                        color: AppColors.white,
                      ),
                      AnimatedSize(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        child: isSelected
                            ? Row(
                                children: [
                                  const SizedBox(width: 8),
                                  Text(
                                    dest.label,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: AppColors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
