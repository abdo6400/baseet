import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:baseet/core/extensions/translation_extension.dart';
import 'package:baseet/core/common/widgets/scanner/barcode_scanner_modal.dart';
import 'package:baseet/app/presentation/refresh_business.dart';
import '../cubits/transfer_cubit.dart';

class TransferPage extends StatefulWidget {
  const TransferPage({super.key});
  @override
  State<TransferPage> createState() => _TransferPageState();
}

class _TransferPageState extends State<TransferPage>
    with WidgetsBindingObserver {
  final code = TextEditingController();
  Timer? timer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) context.read<TransferCubit>().stop();
  }

  @override
  void dispose() {
    timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    code.dispose();
    super.dispose();
  }

  Future<void> confirm() async {
    final accepted = await showDialog<bool>(
        context: context,
        builder: (dialog) => AlertDialog(
                title: Text('simple.replace_title'.lang),
                content: Text('simple.replace_warning'.lang),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(dialog, false),
                      child: Text('common_cancel'.lang)),
                  FilledButton(
                      onPressed: () => Navigator.pop(dialog, true),
                      child: Text('simple.replace_confirm'.lang))
                ]));
    if (accepted == true && mounted) context.read<TransferCubit>().restore();
  }

  @override
  Widget build(BuildContext context) => BlocConsumer<TransferCubit,
          TransferState>(
      listener: (context, state) {
        if (state.restored) refreshBusiness(context, clearCart: true);
      },
      builder: (context, state) => Scaffold(
          appBar: AppBar(title: Text('simple.transfer'.lang)),
          body: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: ListView(padding: const EdgeInsets.all(20), children: [
                    Text('simple.transfer_intro'.lang,
                        style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 12),
                    if (state.busy) const LinearProgressIndicator(),
                    if (state.error != null)
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                              (state.error!.startsWith('simple.') ||
                                          state.error!.startsWith('validation.')
                                      ? state.error!
                                      : 'simple.transfer_failed')
                                  .lang,
                              style: TextStyle(
                                  color: Theme.of(context).colorScheme.error))),
                    if (state.message != null)
                      Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(state.message!.lang)),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                        onPressed: state.busy
                            ? null
                            : () => context.read<TransferCubit>().send(),
                        icon: const Icon(Icons.qr_code_2),
                        label: Text('simple.send'.lang)),
                    if (state.session case final session?) ...[
                      const SizedBox(height: 12),
                      Text('simple.qr_hint'.lang),
                      if (DateTime.now().isBefore(session.expiresAt)) ...[
                        Center(
                            child: Container(
                                color: Colors.white,
                                padding: const EdgeInsets.all(12),
                                child: QrImageView(
                                    data: session.code,
                                    size: 240,
                                    backgroundColor: Colors.white))),
                        Text('simple.qr_expires'.lang,
                            textAlign: TextAlign.center),
                        TextButton.icon(
                            onPressed: () => Clipboard.setData(
                                ClipboardData(text: session.code)),
                            icon: const Icon(Icons.copy),
                            label: Text('simple.copy_code'.lang)),
                      ] else
                        Text('simple.qr_expired'.lang),
                      OutlinedButton(
                          onPressed: () => context.read<TransferCubit>().stop(),
                          child: Text('simple.stop'.lang)),
                    ],
                    const SizedBox(height: 24),
                    Text('simple.receive'.lang,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                        onPressed: state.busy
                            ? null
                            : () async {
                                final value =
                                    await BarcodeScannerModal.show(context);
                                if (value != null && context.mounted) {
                                  code.text = value;
                                  context.read<TransferCubit>().receive(value);
                                }
                              },
                        icon: const Icon(Icons.qr_code_scanner),
                        label: Text('simple.scan_code'.lang)),
                    const SizedBox(height: 12),
                    TextField(
                        controller: code,
                        decoration: InputDecoration(
                            labelText: 'simple.paste_code'.lang),
                        textDirection: TextDirection.ltr),
                    const SizedBox(height: 8),
                    OutlinedButton(
                        onPressed: state.busy
                            ? null
                            : () => context
                                .read<TransferCubit>()
                                .receive(code.text),
                        child: Text('simple.preview_data'.lang)),
                    if (state.preview case final preview?)
                      Card(
                          child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('simple.preview'.lang,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge),
                                    const SizedBox(height: 12),
                                    Text(
                                        '${'simple.products'.lang}: ${preview.products}'),
                                    Text(
                                        '${'simple.customers'.lang}: ${preview.customers}'),
                                    Text(
                                        '${'simple.invoices'.lang}: ${preview.invoices}'),
                                    Text(preview.createdAt
                                        .toLocal()
                                        .toString()
                                        .substring(0, 16)),
                                    const SizedBox(height: 12),
                                    Text('simple.replace_warning'.lang),
                                    const SizedBox(height: 12),
                                    FilledButton(
                                        onPressed: state.busy ? null : confirm,
                                        child: Text('simple.use_data'.lang)),
                                  ]))),
                    const Divider(height: 40),
                    Text('simple.backup'.lang,
                        style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                        onPressed: state.busy
                            ? null
                            : () => context.read<TransferCubit>().save(),
                        icon: const Icon(Icons.save_alt),
                        label: Text('simple.save_backup'.lang)),
                    OutlinedButton.icon(
                        onPressed: state.busy
                            ? null
                            : () => context.read<TransferCubit>().pick(),
                        icon: const Icon(Icons.folder_open),
                        label: Text('simple.open_backup'.lang)),
                    const SizedBox(height: 12),
                    Text('simple.backup_private'.lang,
                        style: Theme.of(context).textTheme.bodySmall),
                  ])))));
}
