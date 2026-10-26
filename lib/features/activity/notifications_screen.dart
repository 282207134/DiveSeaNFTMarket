import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../state/app_state.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({
    super.key,
    this.empty = false,
    this.loading = false,
  });
  final bool empty, loading;
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final notices = empty
        ? state.notices.take(0).toList()
        : state.notices.take(loading ? 4 : state.notices.length).toList();
    return Scaffold(
      appBar: PageHeader(
        'Notification',
        actions: [
          if (notices.isNotEmpty)
            IconButton(
              tooltip: 'Clear notifications',
              icon: const Icon(Icons.done_all, size: 21),
              onPressed: () async {
                final clear = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear notifications?'),
                    content: const Text(
                      'Your bids and collection will stay saved.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
                if (clear == true) await state.clearNotices();
              },
            ),
          const SizedBox(width: 10),
        ],
      ),
      bottomNavigationBar: const BottomTabs(3),
      body: notices.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'No Recents?',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 40,
                      color: Color(0xFFDFDFDF),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 42),
                  SizedBox(
                    width: 120,
                    child: PrimaryButton(
                      'Go Home',
                      height: 48,
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/home'),
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async =>
                  Future<void>.delayed(const Duration(milliseconds: 350)),
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(17, 30, 17, 25),
                itemCount: notices.length + (loading ? 1 : 0),
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  if (index == notices.length) {
                    return const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }
                  final notice = notices[index], isBid = notice.nftId != null;
                  return GestureDetector(
                    onTap: () => go(
                      context,
                      isBid
                          ? '/detail?id=${notice.nftId}'
                          : '/wallet?return=true',
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: .68),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.black,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (isBid)
                            Avatar(
                              index == 3 ? 'seller-4' : 'seller-2',
                              size: 42,
                            )
                          else
                            const CircleAvatar(
                              radius: 23,
                              backgroundColor: AppColors.line,
                              child: Icon(
                                Icons.note_add,
                                size: 23,
                                color: AppColors.black,
                              ),
                            ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  notice.title,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontFamily: 'DMSans',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  notice.subtitle,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${dateLabel(notice.date)}, ${notice.date.hour}:${notice.date.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(
                                    color: AppColors.muted,
                                    fontSize: 9,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 5),
                          if (isBid)
                            SizedBox(
                              width: 54,
                              height: 60,
                              child: NftArt(state.nft(notice.nftId), radius: 8),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: AppColors.line,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: const Text(
                                'My balance',
                                style: TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
