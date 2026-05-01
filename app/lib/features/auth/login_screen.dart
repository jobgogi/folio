/// @description 로그인 화면 — 자동 로그인 시도 후 성공 시 라이브러리 화면으로 이동
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see LoginNotifier, LoginProvider
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/storage_providers.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import 'login_notifier.dart';
import 'login_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(loginProvider.notifier).checkAutoLogin(),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<String>>(savedServerAddressProvider, (prev, next) {
      final wasEmpty = prev?.valueOrNull?.isEmpty ?? true;
      final isNowAvailable = next.valueOrNull?.isNotEmpty ?? false;
      if (wasEmpty && isNowAvailable) {
        ref.read(loginProvider.notifier).checkAutoLogin();
      }
    });

    final state = ref.watch(loginProvider);

    ref.listen<LoginState>(loginProvider, (_, next) {
      if (next is LoginSuccess) {
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
              const SizedBox(height: 48),
              AppTextField(
                key: const Key('login_username'),
                hint: 'username',
                controller: _usernameController,
              ),
              const SizedBox(height: 12),
              AppTextField(
                key: const Key('login_password'),
                hint: 'password',
                controller: _passwordController,
                isPassword: true,
              ),
              if (state is LoginFailure) ...[
                const SizedBox(height: 12),
                Text(
                  state.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ],
              const SizedBox(height: 24),
              AppButton(
                label: '로그인',
                isLoading: state is LoginLoading,
                enabled: state is! LoginLoading,
                onPressed: () => ref.read(loginProvider.notifier).login(
                      username: _usernameController.text.trim(),
                      password: _passwordController.text,
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
