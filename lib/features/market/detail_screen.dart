import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../domain/models.dart';
import '../../state/app_state.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context) {
    final nft = AppScope.of(context).nft(id);
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: nft.id == 'sun' ? const Art('product-art') : NftArt(nft),
          ),
          Positioned(
            top: 18,
            right: 18,
            child: BackCircle(
              icon: Icons.close,
              onPressed: () => Navigator.maybePop(context),
            ),
          ),
          Positioned(
            bottom: 44,
            left: 16,
            right: 16,
            child: SoftCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nft.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Row(
                              children: [
                                const SizedBox(
                                  width: 19,
                                  height: 19,
                                  child: ClipOval(child: Art('sun-glass')),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  nft.creator,
                                  style: const TextStyle(fontSize: 11),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'View detail',
                        onPressed: () => go(context, '/detail?id=$id'),
                        icon: const Icon(Icons.arrow_forward),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${AppScope.of(context).currentBid(nft).toStringAsFixed(2)} ETH',
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              '\$3,147.61',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 133,
                        child: PrimaryButton(
                          'Place a bid',
                          height: 48,
                          onPressed: () =>
                              go(context, '/detail?id=$id&sheet=bid'),
                        ),
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
}

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.id, this.sheet});
  final String id;
  final String? sheet;
  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.sheet != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.sheet == 'bid') {
          showBid();
        } else {
          showMenu();
        }
      });
    }
  }

  void showBid() =>
      frostedSheet(context, BidSheet(nft: AppScope.of(context).nft(widget.id)));
  void showMenu() => showDialog<void>(
    context: context,
    barrierColor: Colors.white.withValues(alpha: .1),
    builder: (context) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Align(
        alignment: const Alignment(.75, -.5),
        child: Material(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          elevation: 10,
          child: SizedBox(
            width: 248,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text(
                      'New bid',
                      style: TextStyle(fontSize: 14),
                    ),
                    trailing: const Icon(Icons.monetization_on_outlined),
                    onTap: () {
                      Navigator.pop(context);
                      showBid();
                    },
                  ),
                  const Divider(),
                  for (final label in [
                    'View on OpenSea',
                    'View on Etherscan',
                    'Report',
                  ])
                    ListTile(
                      title: Text(label, style: const TextStyle(fontSize: 13)),
                      trailing: Icon(
                        label == 'Report'
                            ? Icons.flag_outlined
                            : Icons.arrow_forward,
                        size: 20,
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        showInfo(label);
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
  void showInfo(String title) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(
        title == 'Report'
            ? 'This is a local demo item. To report a real collection, use the marketplace where it is listed.'
            : 'This preview collection has no on-chain contract. You can copy its local identifier.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: widget.id));
            Navigator.pop(context);
          },
          child: const Text('Copy ID'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context), nft = state.nft(widget.id);
    return Scaffold(
      appBar: PageHeader(
        'Detail',
        actions: [
          IconButton(
            tooltip: 'Bid options',
            onPressed: showMenu,
            icon: const Icon(Icons.more_horiz),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(23, 22, 23, 26),
        child: Column(
          children: [
            SoftCard(
              radius: 9,
              padding: const EdgeInsets.fromLTRB(7, 8, 7, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 274,
                    child: Stack(
                      children: [
                        Positioned.fill(child: NftArt(nft, radius: 5)),
                        Positioned(
                          bottom: 6,
                          right: 6,
                          child: IconButton(
                            tooltip: 'Favorite',
                            onPressed: () => state.toggleFavorite(nft.id),
                            icon: Icon(
                              state.favorites.contains(nft.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(13, 16, 13, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Text('AlexCa.', style: TextStyle(fontSize: 13)),
                            SizedBox(width: 20),
                            Verified(),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Project ${nft.name}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 7),
                        const Text(
                          'A collection of 10,000 utility-enabled PFPs that feature a richly diverse and unique pool of rarity-powered traits.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.65,
                            color: AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _Owner(
                                nft.creator,
                                'Created by',
                                'seller-7',
                              ),
                            ),
                            const Expanded(
                              child: _Owner('Videz', 'Owned by', 'seller-5'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Bid',
                        style: TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                      const SizedBox(height: 3),
                      Eth(
                        state.currentBid(nft).toStringAsFixed(2),
                        size: 24,
                        bold: true,
                      ),
                    ],
                  ),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'End in',
                        style: TextStyle(color: AppColors.muted, fontSize: 12),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '27 Oct, 2026 at 23:59',
                        style: TextStyle(fontFamily: 'DMSans', fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            PrimaryButton(
              'Place Bid',
              icon: Icons.account_balance_wallet,
              onPressed: showBid,
            ),
          ],
        ),
      ),
    );
  }
}

class _Owner extends StatelessWidget {
  const _Owner(this.name, this.role, this.image);
  final String name, role, image;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Avatar(image, size: 35),
      const SizedBox(width: 5),
      Flexible(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              role,
              style: const TextStyle(fontSize: 9, color: AppColors.muted),
            ),
            Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'DMSans',
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class BidSheet extends StatefulWidget {
  const BidSheet({super.key, required this.nft});
  final Nft nft;
  @override
  State<BidSheet> createState() => _BidSheetState();
}

class _BidSheetState extends State<BidSheet> {
  final amount = TextEditingController();
  String? error;
  bool busy = false;
  @override
  void dispose() {
    amount.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    final state = AppScope.of(context),
        value = double.tryParse(amount.text.trim());
    if (value == null ||
        !value.isFinite ||
        value < state.minimumBid(widget.nft)) {
      setState(
        () => error =
            'Minimum bid is ${state.minimumBid(widget.nft).toStringAsFixed(2)} ETH.',
      );
      return;
    }
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await state.placeBid(widget.nft, value);
      if (mounted) {
        Navigator.pop(context);
        toast(context, 'Bid placed · ${value.toStringAsFixed(2)} demo ETH');
      }
    } on ArgumentError catch (e) {
      if (mounted) setState(() => error = e.message.toString());
    } catch (_) {
      if (mounted) {
        setState(() => error = 'Unable to save your bid. Please try again.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * .86,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SheetHandle(),
              const Center(
                child: Text(
                  'History of Bid',
                  style: TextStyle(
                    fontFamily: 'DMSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Center(
                child: Text(
                  dateLabel(DateTime(2026, 10, 27)),
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ),
              const SizedBox(height: 20),
              for (final bid in state.history(widget.nft).take(3)) ...[
                SoftCard(
                  radius: 12,
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    children: [
                      Avatar(bid.image, size: 54, verified: true),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bid.name,
                              style: const TextStyle(
                                fontFamily: 'DMSans',
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${dateLabel(bid.date)} at ${bid.date.hour}:${bid.date.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Eth(bid.amount.toStringAsFixed(2), size: 18, bold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
              ],
              const SizedBox(height: 12),
              const Text(
                'Your Bid',
                style: TextStyle(
                  fontFamily: 'DMSans',
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.ink),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 126,
                      height: 58,
                      decoration: const BoxDecoration(
                        color: AppColors.black,
                        borderRadius: BorderRadius.horizontal(
                          left: Radius.circular(15),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'ETH',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.expand_more, color: Colors.white),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        key: const Key('bid-amount'),
                        controller: amount,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          filled: false,
                          hintText:
                              'Minimum ${state.minimumBid(widget.nft).toStringAsFixed(2)} ETH',
                          hintStyle: const TextStyle(
                            fontSize: 11,
                            color: AppColors.muted,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    error!,
                    style: const TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ),
              const SizedBox(height: 10),
              PrimaryButton(
                busy ? 'Submitting…' : 'Submit',
                icon: Icons.account_balance_wallet,
                onPressed: busy ? null : submit,
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Demo bid · No blockchain transaction',
                  style: TextStyle(fontSize: 10, color: AppColors.muted),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
