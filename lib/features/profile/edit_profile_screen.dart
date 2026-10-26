import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../core/media.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../state/app_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(), email = TextEditingController();
  Uint8List? avatar;
  bool loaded = false, busy = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!loaded) {
      final state = AppScope.of(context);
      name.text = state.name;
      email.text = state.email;
      avatar = state.avatar;
      loaded = true;
    }
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    super.dispose();
  }

  Future<void> pick() async {
    try {
      final bytes = await pickGalleryImage(maxSize: 512);
      if (bytes != null && mounted) setState(() => avatar = bytes);
    } catch (_) {
      if (mounted) toast(context, 'Unable to open this image.');
    }
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    setState(() => busy = true);
    try {
      await AppScope.of(context).updateProfile(name.text, email.text, avatar);
      if (mounted) {
        Navigator.pop(context);
        toast(context, 'Profile updated');
      }
    } catch (_) {
      if (mounted) toast(context, 'Unable to save your profile.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const PageHeader('Edit Profile'),
    body: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Form(
        key: form,
        child: Column(
          children: [
            const SizedBox(height: 50),
            GestureDetector(
              onTap: pick,
              child: SizedBox(
                width: 96,
                height: 100,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipOval(
                        child: avatar == null
                            ? const Art('sun-glass')
                            : Image.memory(avatar!, fit: BoxFit.cover),
                      ),
                    ),
                    const Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.blue,
                        child: Icon(Icons.edit, size: 15, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 60),
            TextFormField(
              controller: name,
              decoration: const InputDecoration(
                hintText: 'Full Name',
                prefixIcon: Icon(Icons.person_outline),
                suffixIcon: Icon(Icons.edit_outlined, size: 19),
              ),
              validator: (v) =>
                  (v?.trim().length ?? 0) < 2 ? 'Enter your full name' : null,
            ),
            const SizedBox(height: 22),
            TextFormField(
              controller: email,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Email',
                prefixIcon: Icon(Icons.mail_outline),
                suffixIcon: Icon(Icons.edit_outlined, size: 19),
              ),
              validator: emailValidator,
            ),
            const SizedBox(height: 22),
            TextFormField(
              readOnly: true,
              obscureText: true,
              initialValue: 'DiveSea2026',
              onTap: () =>
                  toast(context, 'Passwords are not stored in this demo.'),
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock_outline),
                suffixIcon: Icon(Icons.edit_outlined, size: 19),
              ),
            ),
            const SizedBox(height: 40),
            PrimaryButton(
              busy ? 'Saving…' : 'Save Changes',
              onPressed: busy ? null : save,
            ),
            const SizedBox(height: 36),
          ],
        ),
      ),
    ),
  );
}
