/// @description 셋업 화면 — root 계정 생성 후 라이브러리 화면으로 이동
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see SetupNotifier, SetupProvider
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import 'setup_notifier.dart';
import 'setup_provider.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(setupProvider);

    ref.listen<SetupState>(setupProvider, (_, next) {
      if (next is SetupSuccess) {
        Navigator.of(context).pushReplacementNamed('/library');
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Text(
                'folio',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'root 계정을 생성해 주세요.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 48),
              AppTextField(
                key: const Key('setup_username'),
                hint: 'username',
                controller: _usernameController,
              ),
              const SizedBox(height: 12),
              AppTextField(
                key: const Key('setup_password'),
                hint: 'password',
                controller: _passwordController,
                isPassword: true,
              ),
              const SizedBox(height: 12),
              AppTextField(
                key: const Key('setup_confirm_password'),
                hint: 'password 확인',
                controller: _confirmController,
                isPassword: true,
              ),
              if (state is SetupFailure) ...[
                const SizedBox(height: 12),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 24),
              AppButton(
                label: '계정 생성',
                isLoading: state is SetupLoading,
                enabled: state is! SetupLoading,
                onPressed: () => ref.read(setupProvider.notifier).submit(
                      username: _usernameController.text.trim(),
                      password: _passwordController.text,
                      confirmPassword: _confirmController.text,
                    ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
