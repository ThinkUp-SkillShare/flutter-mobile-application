import 'package:flutter/material.dart';

/// Simple loading widget displayed while the home screen is fetching data.
/// Shows a centered CircularProgressIndicator to indicate activity.
class HomeLoadingWidget extends StatelessWidget {
  const HomeLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      /// The loader is centered to maintain a clean and neutral loading state.
      child: CircularProgressIndicator(),
    );
  }
}
