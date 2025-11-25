import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../i18n/app_localizations.dart';
import '../../../settings/presentation/views/settings_screen.dart';
import '../view_models/home_view_model.dart';
import '../widgets/featured_groups_section.dart';
import '../widgets/home_empty_state_widget.dart';
import '../widgets/home_error_widget.dart';
import '../widgets/home_loading_widget.dart';
import '../widgets/popular_subjects_section.dart';

/// HomeScreen is the main landing page shown after login.
/// It displays featured groups, popular subjects, and manages loading/error states.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();

    /// Home data is loaded after the first frame to ensure
    /// that the widget tree is ready and context is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadHomeData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Image.asset('assets/logo/SkillShare_logo.png'),
        ),
        surfaceTintColor: const Color(0xFFFAFAFA),
        shadowColor: Colors.black38,
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0.5,
        title: const Text(
          'SkillShare',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF2C3E50),
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),

        /// Settings button to navigate to preferences and account options.
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.settings, color: Colors.black87),
          ),
        ],
        centerTitle: true,
      ),

      /// Using Consumer to rebuild the body when HomeViewModel notifies changes.
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          return RefreshIndicator(
            /// Pull-to-refresh manually reloads home data.
            onRefresh: () async {
              await viewModel.refreshData();
            },
            child: _buildBodyContent(viewModel, localizations),
          );
        },
      ),
    );
  }

  /// Builds the main body based on the current state:
  /// loading, error, empty state, or content.
  Widget _buildBodyContent(
      HomeViewModel viewModel, AppLocalizations localizations) {

    /// Loading state: show shimmer/loaders.
    if (viewModel.isLoading) {
      return const HomeLoadingWidget();
    }

    /// Error state: display retry option.
    if (viewModel.error != null) {
      return HomeErrorWidget(
        error: viewModel.error!,
        onRetry: () => viewModel.refreshData(),
      );
    }

    /// Empty state when both sections have no data.
    if (viewModel.featuredGroups.isEmpty &&
        viewModel.popularSubjects.isEmpty) {
      return HomeEmptyStateWidget(
        onReload: () => viewModel.refreshData(),
      );
    }

    /// Normal state: show content sections.
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          /// Section for recommended / highlighted groups.
          FeaturedGroupsSection(
            featuredGroups: viewModel.featuredGroups,
            title: localizations.featuredGroups,
          ),

          /// Section showing most-used or trending subjects.
          PopularSubjectsSection(
            popularSubjects: viewModel.popularSubjects,
            title: localizations.popularSubjects,
          ),
        ],
      ),
    );
  }
}
