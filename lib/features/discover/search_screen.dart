import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../domain/models.dart';
import '../../state/app_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.query = ''});
  final String query;
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final controller = TextEditingController(text: widget.query);
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = controller.text.trim().toLowerCase();
    final results = AppScope.of(context).allNfts
        .where((n) => '${n.name} ${n.creator}'.toLowerCase().contains(query))
        .toList();
    return Scaffold(
      appBar: const PageHeader('Search'),
      bottomNavigationBar: const BottomTabs(1),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: Column(
          children: [
            TextField(
              key: const Key('search-input'),
              controller: controller,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                suffixIcon: IconButton(
                  tooltip: query.isEmpty ? 'Search' : 'Clear search',
                  onPressed: () {
                    controller.clear();
                    setState(() {});
                  },
                  icon: Icon(
                    query.isEmpty ? Icons.search : Icons.close,
                    color: AppColors.muted,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(color: AppColors.line),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: query.isEmpty
                  ? const Center(
                      child: Text(
                        'Discover\nAnything ?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'DMSans',
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          color: Color(0xFFDFDFDF),
                        ),
                      ),
                    )
                  : results.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.search_off,
                            size: 48,
                            color: AppColors.muted,
                          ),
                          const SizedBox(height: 12),
                          const Text('No artworks found'),
                          const SizedBox(height: 6),
                          Text(
                            'Try a title or creator name.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: results.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 20),
                      itemBuilder: (context, index) =>
                          SearchResult(results[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchResult extends StatelessWidget {
  const SearchResult(this.nft, {super.key});
  final Nft nft;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => go(context, '/detail?id=${nft.id}'),
    child: SizedBox(
      height: 494,
      child: Stack(
        children: [
          Positioned.fill(child: NftArt(nft, radius: 14)),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.ink,
                borderRadius: BorderRadius.circular(7),
              ),
              child: const Text(
                '08H 40M 14S',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          Positioned(
            left: 10,
            right: 10,
            bottom: 10,
            child: SoftCard(
              radius: 10,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nft.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Avatar('seller-2', size: 18),
                            const SizedBox(width: 3),
                            Text(
                              nft.creator,
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${AppScope.of(context).currentBid(nft).toStringAsFixed(2)} ETH',
                        style: const TextStyle(
                          fontFamily: 'DMSans',
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        '\$2,625.61',
                        style: TextStyle(fontSize: 10, color: AppColors.muted),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
