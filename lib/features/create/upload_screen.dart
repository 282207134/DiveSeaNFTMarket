import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/media.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../state/app_state.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key, this.multiple = false});
  final bool multiple;
  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final form = GlobalKey<FormState>();
  final title = TextEditingController(),
      price = TextEditingController(),
      editions = TextEditingController(text: '10');
  Uint8List? bytes;
  bool busy = false;
  @override
  void dispose() {
    title.dispose();
    price.dispose();
    editions.dispose();
    super.dispose();
  }

  Future<void> pick() async {
    try {
      final data = await pickGalleryImage();
      if (data == null) return;
      if (mounted) setState(() => bytes = data);
    } catch (_) {
      if (mounted) {
        toast(context, 'Unable to open this image. Please choose another.');
      }
    }
  }

  Future<void> upload() async {
    if (bytes == null) {
      await pick();
      return;
    }
    if (!form.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      final suffix = widget.multiple ? ' · ${editions.text} editions' : '';
      await AppScope.of(context)
          .publish('${title.text}$suffix', double.parse(price.text), bytes!);
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/profile', (_) => false);
        toast(context, 'Published to your local collection');
      }
    } catch (_) {
      if (mounted) toast(context, 'Unable to save your NFT. Please try again.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const PageHeader('Upload'),
    body: SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 52, 24, 32),
      child: Form(
        key: form,
        child: Column(
          children: [
            GestureDetector(
              onTap: pick,
              child: SizedBox(
                height: bytes == null ? 397 : 260,
                child: SoftCard(
                  radius: 24,
                  padding: EdgeInsets.zero,
                  child: bytes == null
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.upload_file_outlined,
                                size: 36,
                                color: AppColors.black,
                              ),
                              SizedBox(height: 20),
                              Text(
                                'PNG, JPG or WEBP.\nMax 10 MB.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.muted,
                                  height: 1.8,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.memory(
                            bytes!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                ),
              ),
            ),
            if (bytes != null) ...[
              const SizedBox(height: 24),
              TextFormField(
                controller: title,
                decoration: const InputDecoration(labelText: 'Artwork name'),
                validator: (v) => (v?.trim().length ?? 0) < 2
                    ? 'Enter an artwork name'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: price,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Starting price',
                  suffixText: 'ETH',
                ),
                validator: (v) {
                  final number = double.tryParse(v ?? '');
                  return number != null && number.isFinite && number > 0
                      ? null
                      : 'Enter a price greater than 0';
                },
              ),
              if (widget.multiple) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: editions,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Number of editions',
                  ),
                  validator: (v) {
                    final number = int.tryParse(v ?? '');
                    return number != null && number >= 2 && number <= 100
                        ? null
                        : 'Enter 2–100 editions';
                  },
                ),
              ],
            ],
            const SizedBox(height: 60),
            PrimaryButton(
              busy
                  ? 'Publishing…'
                  : bytes == null
                  ? 'Upload'
                  : 'Publish NFT',
              onPressed: busy ? null : upload,
            ),
            const SizedBox(height: 14),
            const Text(
              'Your artwork is saved on this device.',
              style: TextStyle(fontSize: 11, color: AppColors.muted),
            ),
          ],
        ),
      ),
    ),
  );
}
