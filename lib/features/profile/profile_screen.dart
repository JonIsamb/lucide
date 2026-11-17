import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/connection.dart';
import '../../core/theme/app_colors.dart';
import '../asset_detail/presentation/widgets/detail_card.dart';
import 'domain/profile.dart';
import 'presentation/profile_controller.dart';

/// The profile: the first name shown on the home screen, and what the
/// app keeps on the phone. Shows the profile and forwards the user's
/// action to the controller.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // The text being typed is visual state. It starts from the saved name.
  late final TextEditingController _name = TextEditingController(
    text: ref.read(profileControllerProvider).value?.firstName,
  );
  bool _saved = false;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    await ref.read(profileControllerProvider.notifier).setFirstName(_name.text);
    if (!mounted) return;
    // Show the cleaned name that was really saved.
    _name.text = ref.read(profileControllerProvider).value?.firstName ?? '';
    setState(() => _saved = true);
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileControllerProvider).value ?? Profile.empty;
    final offline = ref.watch(isOfflineProvider);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Center(
            child: CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.lightGreen,
              child: profile.hasName
                  ? Text(
                      profile.initials,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    )
                  : const Icon(
                      Icons.person_rounded,
                      size: 40,
                      color: AppColors.primary,
                    ),
            ),
          ),
          const SizedBox(height: 20),
          DetailCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Ton prénom', style: textTheme.titleMedium),
                const SizedBox(height: 10),
                TextField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.done,
                  maxLength: maxFirstNameLength,
                  onChanged: (_) => setState(() => _saved = false),
                  onSubmitted: (_) => _save(),
                  decoration: const InputDecoration(
                    hintText: 'Comment t’appelles-tu ?',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 4),
                FilledButton(
                  onPressed: _save,
                  child: Text(_saved ? 'Enregistré' : 'Enregistrer'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          DetailCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      offline
                          ? Icons.cloud_off_rounded
                          : Icons.cloud_done_rounded,
                      color: offline ? AppColors.fall : AppColors.primary,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      offline ? 'Hors connexion' : 'Connecté',
                      style: textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'L’app détecte seule l’absence de réseau. Hors connexion, '
                  'elle continue avec les cours, les simulations et les '
                  'parties enregistrés sur ce téléphone. Rien n’est envoyé '
                  'ailleurs : ton profil reste sur l’appareil.',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
