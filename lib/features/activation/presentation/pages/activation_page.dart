import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../config/locators/global_locator.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/extensions/responsive_extension.dart';
import '../../../../core/extensions/spacing_extension.dart';
import '../../../../core/extensions/state_handle_extension.dart';
import '../../../../core/extensions/translation_extension.dart';
import '../../../../core/utils/strings_manager.dart';
import '../cubit/activation_cubit.dart';
import '../cubit/activation_state.dart';
import '../widgets/activation_device_id_card.dart';
import '../widgets/activation_expiry_banner.dart';
import '../widgets/activation_header.dart';
import '../widgets/activation_instructions_card.dart';
import '../widgets/activation_key_input_card.dart';

class ActivationPage extends StatelessWidget {
  final bool isExpired;

  const ActivationPage({
    super.key,
    this.isExpired = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ActivationCubit>()
        ..loadDeviceAndLicense(isExpiredInitial: isExpired),
      child: _ActivationView(isExpired: isExpired),
    );
  }
}

class _ActivationView extends StatefulWidget {
  final bool isExpired;

  const _ActivationView({required this.isExpired});

  @override
  State<_ActivationView> createState() => _ActivationViewState();
}

class _ActivationViewState extends State<_ActivationView> {
  final TextEditingController _keyController = TextEditingController();
  final FocusNode _keyFocusNode = FocusNode();

  @override
  void dispose() {
    _keyController.dispose();
    _keyFocusNode.dispose();
    super.dispose();
  }

  void _copyDeviceId(String deviceId) {
    Clipboard.setData(ClipboardData(text: deviceId));
    toastification.show(
      context: context,
      type: ToastificationType.info,
      style: ToastificationStyle.fillColored,
      title: Text(StringsManager.activationDeviceIdCopied.lang),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  Future<void> _pasteKey() async {
    final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
    if (clipboardData != null && clipboardData.text != null) {
      setState(() {
        _keyController.text = clipboardData.text!.trim();
      });
    }
  }

  Future<void> _sendViaWhatsApp(String deviceId) async {
    final message = StringsManager.activationWhatsAppText.lang.replaceAll('{}', deviceId);
    final encodedMessage = Uri.encodeComponent(message);
    final url = Uri.parse('https://wa.me/?text=$encodedMessage');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      debugPrint('Error launching WhatsApp: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<ActivationCubit, ActivationState>(
      listener: (context, state) {
        if (state.status == ActivationStatus.success) {
          toastification.show(
            context: context,
            type: ToastificationType.success,
            style: ToastificationStyle.fillColored,
            title: Text(StringsManager.activationSuccess.lang),
            autoCloseDuration: const Duration(seconds: 3),
          );
          context.go(AppRoutes.pos);
        } else if (state.status == ActivationStatus.error && state.errorMessage != null) {
          context.showStateHandler(
            isLoading: false,
            isError: true,
            errorMessage: state.errorMessage,
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<ActivationCubit>();

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: context.safeDp(20),
                  vertical: context.safeDp(24),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: context.isTablet ? 600 : 540,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // App Logo & Title Header
                      ActivationHeader(isExpired: state.isExpired),
                      20.vSpace,

                      // Expiry Banner if expired
                      if (state.isExpired && state.expiredAt != null) ...[
                        ActivationExpiryBanner(expiredAt: state.expiredAt!),
                        16.vSpace,
                      ],

                      // Device ID Card
                      ActivationDeviceIdCard(
                        deviceId: state.deviceId,
                        isLoadingDevice: state.isLoadingDevice,
                        onCopy: () => _copyDeviceId(state.deviceId),
                        onSendWhatsApp: () => _sendViaWhatsApp(state.deviceId),
                      ),
                      20.vSpace,

                      // Activation Key Input Card
                      ActivationKeyInputCard(
                        keyController: _keyController,
                        keyFocusNode: _keyFocusNode,
                        isActivating: state.status == ActivationStatus.activating,
                        isExpiredState: state.isExpired,
                        seedDummyData: state.seedDummyData,
                        onSeedDummyDataChanged: cubit.toggleSeedDummyData,
                        onPaste: _pasteKey,
                        onActivate: () => cubit.activate(_keyController.text),
                      ),
                      20.vSpace,

                      // Instructions Card
                      const ActivationInstructionsCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
