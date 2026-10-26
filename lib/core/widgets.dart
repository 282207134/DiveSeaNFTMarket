import 'dart:ui';

import 'package:flutter/material.dart';

import '../domain/models.dart';
import '../state/app_state.dart';
import 'theme.dart';

void go(BuildContext context, String route) =>
    Navigator.of(context).pushNamed(route);
void toast(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(
    this.label, {
    super.key,
    required this.onPressed,
    this.icon,
    this.height = 60,
    this.light = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;
  final bool light;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: height,
    width: double.infinity,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        backgroundColor: light ? Colors.white : AppColors.black,
        foregroundColor: light ? AppColors.ink : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(
          fontFamily: 'DMSans',
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 9)],
          Flexible(child: Text(label, maxLines: 1)),
        ],
      ),
    ),
  );
}

class BackCircle extends StatelessWidget {
  const BackCircle({super.key, this.onPressed, this.icon = Icons.chevron_left});
  final VoidCallback? onPressed;
  final IconData icon;
  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: icon == Icons.close ? 'Close' : 'Back',
    onPressed:
        onPressed ??
        () async {
          if (!await Navigator.of(context).maybePop() && context.mounted) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        },
    icon: Container(
      width: 32,
      height: 32,
      decoration: const BoxDecoration(
        color: AppColors.line,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 24, color: AppColors.ink),
    ),
  );
}

class PageHeader extends StatelessWidget implements PreferredSizeWidget {
  const PageHeader(this.title, {super.key, this.actions});
  final String title;
  final List<Widget>? actions;
  @override
  Size get preferredSize => const Size.fromHeight(92);
  @override
  Widget build(BuildContext context) => AppBar(
    toolbarHeight: 92,
    titleSpacing: 0,
    leadingWidth: 72,
    leading: const Padding(
      padding: EdgeInsets.only(left: 12),
      child: BackCircle(),
    ),
    title: Text(title),
    actions: actions,
  );
}

class Art extends StatelessWidget {
  const Art(this.name, {super.key, this.fit = BoxFit.cover, this.radius = 0});
  final String name;
  final BoxFit fit;
  final double radius;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: Image.asset(
      'assets/images/$name.png',
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      gaplessPlayback: true,
    ),
  );
}

class NftArt extends StatelessWidget {
  const NftArt(this.nft, {super.key, this.radius = 0});
  final Nft nft;
  final double radius;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: nft.bytes == null
        ? Art(nft.image)
        : Image.memory(
            nft.bytes!,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
  );
}

class Avatar extends StatelessWidget {
  const Avatar(
    this.image, {
    super.key,
    this.size = 48,
    this.verified = false,
    this.rank,
  });
  final String image;
  final double size;
  final bool verified;
  final int? rank;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: size + 6,
    height: size + 4,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: ClipOval(child: Art(image)),
        ),
        if (verified)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Color(0xFF39B576),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            ),
          ),
        if (rank != null)
          Positioned(
            right: 0,
            top: 0,
            child: CircleAvatar(
              radius: 10,
              backgroundColor: AppColors.ink,
              child: Text(
                '$rank',
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
            ),
          ),
      ],
    ),
  );
}

class Verified extends StatelessWidget {
  const Verified({super.key, this.size = 17});
  final double size;
  @override
  Widget build(BuildContext context) =>
      Icon(Icons.verified, color: AppColors.blue, size: size);
}

class Eth extends StatelessWidget {
  const Eth(this.value, {super.key, this.size = 16, this.bold = false});
  final String value;
  final double size;
  final bool bold;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      CustomPaint(size: Size(size * .6, size * 1.1), painter: _EthPainter()),
      const SizedBox(width: 5),
      Text(
        value,
        style: TextStyle(
          fontFamily: 'DMSans',
          fontSize: size,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
    ],
  );
}

class _EthPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    canvas.drawPath(
      Path()
        ..moveTo(w / 2, 0)
        ..lineTo(0, h * .58)
        ..lineTo(w / 2, h * .76)
        ..lineTo(w, h * .58)
        ..close(),
      Paint()..color = AppColors.ink,
    );
    canvas.drawPath(
      Path()
        ..moveTo(0, h * .66)
        ..lineTo(w / 2, h)
        ..lineTo(w, h * .66)
        ..lineTo(w / 2, h * .84)
        ..close(),
      Paint()..color = AppColors.ink,
    );
  }

  @override
  bool shouldRepaint(_EthPainter oldDelegate) => false;
}

class BottomTabs extends StatelessWidget {
  const BottomTabs(this.index, {super.key});
  final int index;
  @override
  Widget build(BuildContext context) {
    const icons = [
      Icons.home_outlined,
      Icons.search,
      Icons.add,
      Icons.monitor_heart_outlined,
      Icons.account_circle_outlined,
    ];
    const labels = ['Home', 'Search', 'Create', 'Activity', 'Profile'];
    const routes = [
      '/home',
      '/search',
      '/upload',
      '/notifications',
      '/profile',
    ];
    return Container(
      height: 96,
      padding: const EdgeInsets.fromLTRB(23, 12, 23, 15),
      decoration: const BoxDecoration(
        color: Color(0xFFFCFCFD),
        border: Border(top: BorderSide(color: Color(0xFFD9D9DC))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          5,
          (i) => SizedBox(
            width: 52,
            child: Column(
              children: [
                SizedBox(
                  height: 48,
                  width: 48,
                  child: IconButton(
                    tooltip: labels[i],
                    onPressed: () {
                      if (i == 2) {
                        go(context, '/home?add=true');
                      } else if (index != i) {
                        Navigator.of(context).pushReplacementNamed(routes[i]);
                      }
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: i == 2
                          ? AppColors.black
                          : Colors.transparent,
                      foregroundColor: i == 2 ? Colors.white : AppColors.ink,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    icon: Icon(
                      i == 0 && index == 0 ? Icons.home_filled : icons[i],
                      size: i == 2 ? 34 : 26,
                    ),
                  ),
                ),
                if (index == i)
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(top: 5),
                    decoration: const BoxDecoration(
                      color: AppColors.black,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.radius = 16,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: .045),
          offset: const Offset(0, 14),
          blurRadius: 32,
        ),
      ],
    ),
    child: child,
  );
}

Future<T?> frostedSheet<T>(BuildContext context, Widget child) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.white.withValues(alpha: .12),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(context).bottom,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: child,
        ),
      ),
    );

class SheetHandle extends StatelessWidget {
  const SheetHandle({super.key});
  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 82,
      height: 5,
      margin: const EdgeInsets.only(top: 10, bottom: 22),
      decoration: BoxDecoration(
        color: const Color(0xFFD4D4D4),
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}

class WalletBadge extends StatelessWidget {
  const WalletBadge({super.key});
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    return TextButton(
      onPressed: () => go(context, '/wallet?return=true'),
      style: TextButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      ),
      child: Eth(
        '${state.balance.toStringAsFixed(2)} ETH',
        size: 12,
        bold: true,
      ),
    );
  }
}

String dateLabel(DateTime d) =>
    '${d.day} ${const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][d.month - 1]} ${d.year}';
String? emailValidator(String? value) =>
    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value?.trim() ?? '')
    ? null
    : 'Enter a valid email address';
