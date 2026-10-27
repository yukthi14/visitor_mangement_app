import 'package:flutter/material.dart';
import 'shimmer_loading.dart';

class LoadingView extends StatelessWidget {
  final String? message;

  const LoadingView({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return const VisitorListShimmer();
  }
}
