import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:baseet/core/extensions/translation_extension.dart';
import 'package:baseet/app/presentation/cubits/process_lookups_cubit.dart';

class ProcessLookupsGate extends StatelessWidget {
  final bool categories, customers;
  final Widget child;
  const ProcessLookupsGate(
      {super.key,
      required this.child,
      this.categories = false,
      this.customers = false});
  @override
  Widget build(BuildContext context) =>
      BlocBuilder<ProcessLookupsCubit, ProcessLookupsState>(
          builder: (context, state) {
        if (state.loading) {
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
        if (state.error != null) {
          return Scaffold(
              appBar: AppBar(),
              body: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(state.error!.lang),
                IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => context
                        .read<ProcessLookupsCubit>()
                        .load(categories: categories, customers: customers))
              ])));
        }
        return child;
      });
}
