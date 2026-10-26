import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../core/media.dart';
import '../../core/widgets.dart';
import '../../domain/models.dart';
import '../../state/app_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    this.activity = false,
    this.menu,
    this.favorites = false,
  });
  final bool activity, favorites;
  final String? menu;
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late bool activity = widget.activity;
  bool salesOnly = true;
  @override
  void initState() {
    super.initState();
    if (widget.menu != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.menu == 'cover') {
          coverMenu();
        } else {
          accountMenu();
        }
      });
    }
  }

  Future<void> share() async {
    await Clipboard.setData(
      ClipboardData(
        text:
            'DiveSea · ${AppScope.of(context).name}\nCollection: divesea://profile',
      ),
    );
    if (mounted) toast(context, 'Profile copied to clipboard');
  }

  Future<void> replaceCover() async {
    final state = AppScope.of(context);
    try {
      final bytes = await pickGalleryImage();
      if (bytes != null) await state.replaceCover(bytes);
    } catch (_) {
      if (mounted) toast(context, 'Unable to open this cover image.');
    }
  }

  void coverMenu() => showDialog<void>(
    context: context,
    barrierColor: Colors.white.withValues(alpha: .1),
    builder: (dialogContext) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Align(
        alignment: const Alignment(.65, -.6),
        child: Material(
          color: Colors.white,
          elevation: 10,
          borderRadius: BorderRadius.circular(20),
          child: SizedBox(
            width: 245,
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final item in [
                    ('Edit profile', Icons.edit_outlined),
                    ('Share', Icons.ios_share),
                    ('Replace cover', Icons.image_outlined),
                    ('Remove cover', Icons.close),
                  ]) ...[
                    ListTile(
                      dense: true,
                      title: Text(
                        item.$1,
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      trailing: Icon(item.$2, size: 20),
                      onTap: () async {
                        final state = AppScope.of(context);
                        Navigator.pop(dialogContext);
                        if (item.$1 == 'Edit profile') {
                          go(context, '/edit-profile');
                        }
                        if (item.$1 == 'Share') {
                          await share();
                        }
                        if (item.$1 == 'Replace cover') {
                          await replaceCover();
                        }
                        if (item.$1 == 'Remove cover') {
                          await state.setCoverVisible(false);
                        }
                      },
                    ),
                    if (item.$1 == 'Edit profile') const Divider(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  void accountMenu() => frostedSheet(
    context,
    Padding(
      padding: const EdgeInsets.fromLTRB(26, 0, 26, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SheetHandle(),
          for (final item in [
            ('Setting', Icons.settings),
            ('Your Activity', Icons.explore),
            ('Wallet', Icons.account_balance_wallet),
            ('Share Your Profile', Icons.person),
            ('Favorite', Icons.star),
            ('Logout', Icons.logout),
          ])
            ListTile(
              leading: Icon(item.$2, size: 21, color: const Color(0xFF17132B)),
              title: Text(
                item.$1,
                style: const TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                switch (item.$1) {
                  case 'Setting':
                    go(context, '/settings');
                  case 'Your Activity':
                    setState(() => activity = true);
                  case 'Wallet':
                    go(context, '/wallet?return=true');
                  case 'Share Your Profile':
                    await share();
                  case 'Favorite':
                    go(context, '/profile?favorites=true');
                  case 'Logout':
                    await AppScope.of(context).signOut();
                    if (mounted) {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (_) => false,
                      );
                    }
                }
              },
            ),
        ],
      ),
    ),
  );
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final items = widget.favorites
        ? state.allNfts.where((n) => state.favorites.contains(n.id)).toList()
        : [...state.uploads, ...nfts.take(2)];
    return Scaffold(
      bottomNavigationBar: const BottomTabs(4),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 277,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 208,
                    child: state.coverVisible
                        ? state.cover == null
                              ? const Art('sun-glass')
                              : Image.memory(state.cover!, fit: BoxFit.cover)
                        : const ColoredBox(color: AppColors.line),
                  ),
                  Positioned(
                    top: 34,
                    left: 12,
                    child: BackCircle(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/home'),
                    ),
                  ),
                  Positioned(
                    top: 34,
                    right: 12,
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'Cover options',
                          onPressed: coverMenu,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: .8),
                          ),
                          icon: const Icon(Icons.edit_outlined, size: 20),
                        ),
                        IconButton(
                          tooltip: 'Account options',
                          onPressed: accountMenu,
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white.withValues(alpha: .8),
                          ),
                          icon: const Icon(Icons.more_horiz, size: 22),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () => go(context, '/edit-profile'),
                        child: Container(
                          width: 134,
                          height: 134,
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: ClipOval(
                            child: state.avatar == null
                                ? const Art('sun-glass')
                                : Image.memory(
                                    state.avatar!,
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  state.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(width: 12),
                const Verified(size: 22),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final item in [
                  ('9.9K', 'Items'),
                  ('14.9K', 'Items'),
                  ('16.4', 'Floor Price'),
                  ('26.4', 'Traded'),
                ])
                  Column(
                    children: [
                      if (item.$2 == 'Floor Price' || item.$2 == 'Traded')
                        Eth(item.$1, size: 18, bold: true)
                      else
                        Text(
                          item.$1,
                          style: const TextStyle(
                            fontFamily: 'DMSans',
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      Text(
                        item.$2,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 26),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Row(
                children: [
                  for (final tab in [false, true])
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() => activity = tab),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    tab ? Icons.explore : Icons.collections,
                                    size: 19,
                                    color: activity == tab
                                        ? const Color(0xFF17132B)
                                        : const Color(0xFFCCCCCC),
                                  ),
                                  const SizedBox(width: 7),
                                  Text(
                                    tab
                                        ? 'Activity'
                                        : widget.favorites
                                        ? 'Favorites'
                                        : 'Collection',
                                    style: TextStyle(
                                      fontFamily: 'DMSans',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: activity == tab
                                          ? Colors.black
                                          : const Color(0xFFCCCCCC),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: activity == tab
                                    ? AppColors.ink
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (activity)
              _activity(state)
            else if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(36),
                child: Text(
                  'Save an artwork to see it here.',
                  style: TextStyle(color: AppColors.muted),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 18,
                    childAspectRatio: .71,
                  ),
                  itemBuilder: (context, i) => _CollectionCard(items[i]),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _activity(AppState state) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextButton.icon(
                onPressed: () => setState(() => salesOnly = !salesOnly),
                icon: const Icon(Icons.shopping_cart, size: 15),
                label: Text(salesOnly ? 'Sales  ⌄' : 'Bids  ⌄'),
                style: TextButton.styleFrom(backgroundColor: Colors.white),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: TextButton.icon(
                onPressed: () => toast(context, 'All demo items use Ethereum'),
                icon: const Icon(Icons.link, size: 15),
                label: const Text('All Chains  ⌄'),
                style: TextButton.styleFrom(backgroundColor: Colors.white),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (!salesOnly && state.bids.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24),
            child: Text('Your bids will appear here.'),
          )
        else
          for (final nft
              in salesOnly
                  ? [nfts[1]]
                  : state.allNfts.where((n) => state.bids.containsKey(n.id)))
            GestureDetector(
              onTap: () => go(context, '/detail?id=${nft.id}'),
              child: SoftCard(
                radius: 10,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 53,
                          height: 56,
                          child: NftArt(nft, radius: 5),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                nft.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                nft.creator,
                                style: const TextStyle(fontSize: 9),
                              ),
                              const Text(
                                '6 minutes ago',
                                style: TextStyle(
                                  fontSize: 8,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              salesOnly ? 'Sale' : 'Your bid',
                              style: const TextStyle(
                                fontSize: 9,
                                color: Color(0xFF39B576),
                              ),
                            ),
                            Eth(
                              salesOnly
                                  ? '16.4'
                                  : state.currentBid(nft).toStringAsFixed(2),
                              size: 13,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(height: 26),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        for (final item in [
                          ('USD Price', '\$19K'),
                          ('Quantity', '14.9K'),
                          ('Floor price', '16.4'),
                          ('Traded', '26.4'),
                        ])
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.$1,
                                style: const TextStyle(
                                  fontSize: 8,
                                  color: AppColors.muted,
                                ),
                              ),
                              Text(
                                item.$2,
                                style: const TextStyle(
                                  fontFamily: 'DMSans',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
      ],
    ),
  );
}

class _CollectionCard extends StatelessWidget {
  const _CollectionCard(this.nft);
  final Nft nft;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => go(context, '/detail?id=${nft.id}'),
    child: SoftCard(
      radius: 12,
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: NftArt(nft, radius: 5)),
          const SizedBox(height: 6),
          Row(
            children: [
              Flexible(
                child: Text(
                  nft.creator,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              const Verified(size: 12),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            nft.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Eth(nft.id == 'sun' ? '16.4' : '26.4', size: 16, bold: true),
              Row(
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 13,
                    color: AppColors.muted,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    '${nft.likes}',
                    style: const TextStyle(fontSize: 9, color: AppColors.muted),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 5),
        ],
      ),
    ),
  );
}
