import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../domain/models.dart';
import '../../state/app_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.trending = false, this.add = false});
  final bool trending, add;
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late bool trending = widget.trending;
  @override
  void initState() {
    super.initState();
    if (widget.add) {
      WidgetsBinding.instance.addPostFrameCallback((_) => showCreate());
    }
  }

  void showCreate() => frostedSheet(
    context,
    Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SheetHandle(),
          const Text(
            'Create your NFT',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          for (final item in [
            ('Single', 'One original, one collector'),
            ('Multiple', 'Create a numbered edition'),
          ])
            ListTile(
              title: Text(item.$1),
              subtitle: Text(
                item.$2,
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () {
                Navigator.pop(context);
                go(context, '/upload?multiple=${item.$1 == 'Multiple'}');
              },
            ),
        ],
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    bottomNavigationBar: const BottomTabs(0),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 25, 24, 20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const WalletBadge(),
                IconButton(
                  tooltip: 'Profile options',
                  onPressed: () => go(context, '/profile?menu=account'),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    fixedSize: const Size(48, 48),
                  ),
                  icon: const CircleAvatar(
                    radius: 17,
                    backgroundColor: AppColors.background,
                    child: Text(
                      'UI',
                      style: TextStyle(fontSize: 14, color: AppColors.ink),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => trending = !trending),
                    child: Text(
                      trending ? 'Trending' : 'Best sellers',
                      style: TextStyle(
                        fontFamily: 'DMSans',
                        fontSize: trending ? 26 : 32,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: trending ? 'Switch to featured' : 'All sellers',
                  onPressed: () {
                    if (trending) {
                      setState(() => trending = false);
                    } else {
                      go(context, '/sellers');
                    }
                  },
                  icon: const Icon(Icons.chevron_right, size: 22),
                ),
              ],
            ),
            if (trending) ...[
              const SizedBox(height: 14),
              SizedBox(
                height: 350,
                child: ListView.separated(
                  clipBehavior: Clip.none,
                  scrollDirection: Axis.horizontal,
                  itemCount: AppScope.of(context).allNfts.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 20),
                  itemBuilder: (context, i) => SizedBox(
                    width: 239,
                    child: TrendingCard(AppScope.of(context).allNfts[i]),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Top Collections',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 25,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextButton(
                    onPressed: () => go(context, '/sellers'),
                    child: const Text(
                      'View All',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
              for (var i = 0; i < 3; i++)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Avatar(sellers[i].image, size: 46, rank: i + 1),
                  title: Text(
                    sellers[i].name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    sellers[i].handle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Eth(['8,456', '5,327', '4,218'][i], bold: true),
                      const SizedBox(height: 5),
                      Text(
                        i == 1 ? '-32.01%' : '+23.00%',
                        style: TextStyle(
                          fontSize: 12,
                          color: i == 1 ? Colors.red : const Color(0xFF00BB5C),
                        ),
                      ),
                    ],
                  ),
                  onTap: () => go(context, '/profile'),
                ),
            ] else ...[
              const SizedBox(height: 10),
              SizedBox(
                height: 66,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: 4,
                  separatorBuilder: (_, _) => const SizedBox(width: 22),
                  itemBuilder: (context, i) => GestureDetector(
                    onTap: () => go(context, '/sellers'),
                    child: SizedBox(
                      width: 202,
                      child: Row(
                        children: [
                          Avatar(sellers[i].image, size: 60, verified: true),
                          const SizedBox(width: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                sellers[i].name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '\$${sellers[i].earnings}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF777E90),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FeatureCard(AppScope.of(context).allNfts.first),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => setState(() => trending = true),
                child: const Text(
                  'Explore trending →',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

class FeatureCard extends StatelessWidget {
  const FeatureCard(this.nft, {super.key});
  final Nft nft;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => go(context, '/product?id=${nft.id}'),
    child: SizedBox(
      height: 460,
      child: Stack(
        children: [
          Positioned.fill(child: NftArt(nft, radius: 24)),
          Positioned(
            top: 20,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFCFCFD),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nft.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Row(
                        children: [
                          SizedBox(
                            width: 19,
                            height: 19,
                            child: ClipOval(child: Art('sun-glass')),
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Alex Ca.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${AppScope.of(context).currentBid(nft).toStringAsFixed(2)} ETH',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        '\$3,147.61',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF777E90),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 133,
                child: PrimaryButton(
                  'Place a bid',
                  height: 48,
                  onPressed: () =>
                      go(context, '/detail?id=${nft.id}&sheet=bid'),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class TrendingCard extends StatelessWidget {
  const TrendingCard(this.nft, {super.key});
  final Nft nft;
  @override
  Widget build(BuildContext context) => SoftCard(
    radius: 24,
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => go(context, '/detail?id=${nft.id}'),
          child: SizedBox(
            height: 215,
            child: Stack(
              children: [
                Positioned.fill(child: NftArt(nft, radius: 16)),
                Positioned(
                  top: 12,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: .3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '07h 09m 12s',
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            nft.name,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current bid',
                    style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 5),
                  Eth(
                    AppScope.of(context).currentBid(nft).toStringAsFixed(2),
                    size: 14,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 102,
              child: PrimaryButton(
                'Place Bid',
                height: 44,
                onPressed: () => go(context, '/detail?id=${nft.id}&sheet=bid'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
      ],
    ),
  );
}
