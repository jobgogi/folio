/// @description 서버 주소 입력 화면 — 연결 테스트 후 다음 화면으로 이동
/// @author 설석주 (ixymori@gmail.com)
/// @since 2026.04.28
/// @version 1.0.0
/// @see ServerAddressNotifier, ServerAddressProvider
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_loading_spinner.dart';
import 'server_address_notifier.dart';
import 'server_address_provider.dart';

class ServerAddressScreen extends ConsumerStatefulWidget {
  const ServerAddressScreen({super.key});

  @override
  ConsumerState<ServerAddressScreen> createState() =>
      _ServerAddressScreenState();
}

class _ServerAddressScreenState extends ConsumerState<ServerAddressScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// @description 연결 성공 시 nextScreen에 따라 화면을 이동한다.
  /// @param nextScreen 이동할 화면 (setup / login)
  void _navigate(NextScreen nextScreen) {
    final route =
        nextScreen == NextScreen.setup ? '/setup' : '/login';
    Navigator.of(context).pushReplacementNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(serverAddressProvider);

    ref.listen<ServerAddressState>(serverAddressProvider, (_, next) {
      if (next is ServerAddressSuccess) {
        // 자동 이동 없이 다음 버튼 활성화만 처리
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
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'http://nas.local:3000',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),
              _buildStatus(state),
              const SizedBox(height: 16),
              AppButton(
                label: '연결 테스트',
                enabled: _controller.text.trim().isNotEmpty &&
                    state is! ServerAddressLoading,
                isLoading: state is ServerAddressLoading,
                onPressed: () => ref
                    .read(serverAddressProvider.notifier)
                    .testAndSave(_controller.text.trim()),
              ),
              if (state is ServerAddressSuccess) ...[
                const SizedBox(height: 12),
                AppButton(
                  label: '다음',
                  onPressed: () => _navigate(state.nextScreen),
                ),
              ],
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatus(ServerAddressState state) {
    if (state is ServerAddressSuccess) {
      return const Text(
        '연결되었습니다.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.green),
      );
    }
    if (state is ServerAddressFailure) {
      return Text(
        state.message,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.red),
      );
    }
    return const SizedBox.shrink();
  }
}
