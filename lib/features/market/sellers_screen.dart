import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../domain/models.dart';
import '../../state/app_state.dart';

class SellersScreen extends StatelessWidget {
  const SellersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return Scaffold(
      appBar: const PageHeader('Best sellers'),
      bottomNavigationBar: const BottomTabs(0),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        itemCount: sellers.length,
        separatorBuilder: (_, _) => const SizedBox(height: 16),
        itemBuilder: (context, i) {
          final seller = sellers[i],
              followed = state.following.contains(sellers[i].handle);
          return SizedBox(
            height: 64,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => go(context, '/profile'),
                  child: Avatar(
                    seller.image,
                    size: 56,
                    rank: i < 3 ? i + 1 : null,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(seller.name, style: const TextStyle(fontSize: 14)),
                      const SizedBox(height: 3),
                      Text(
                        '@${seller.handle}',
                        style: const TextStyle(
                          color: Color(0xFF777E90),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: 78,
                  height: 32,
                  child: OutlinedButton(
                    onPressed: () => state.toggleFollow(seller.handle),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.zero,
                      backgroundColor: followed
                          ? AppColors.line
                          : Colors.transparent,
                      side: const BorderSide(color: AppColors.line, width: 2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: Text(
                      followed ? 'Unfollow' : 'Follow',
                      style: const TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
