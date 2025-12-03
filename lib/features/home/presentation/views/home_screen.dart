import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillshare/i18n/app_localizations.dart';
import 'package:skillshare/features/settings/presentation/views/settings_screen.dart';
import 'package:skillshare/features/auth/presentation/widgets/error_modal.dart';
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

    /// Home data is loaded after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadHomeData();
    });
  }

  /// Loads home data and handles session expiration
  Future<void> _loadHomeData() async {
    try {
      await context.read<HomeViewModel>().loadHomeData();

      // Check if there's an error that requires user action
      final viewModel = context.read<HomeViewModel>();
      if (viewModel.error != null &&
          viewModel.error!.contains('Session expired')) {
        await _showSessionExpiredDialog();
      }
    } catch (e) {
      // Handle unexpected errors
      if (mounted) {
        await ErrorModal.showAuthError(
          context: context,
          message: 'Failed to load home data. Please try again.',
        );
      }
    }
  }

  /// Shows dialog when session expires
  Future<void> _showSessionExpiredDialog() async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Session Expired'),
        content: const Text('Your session has expired. Please login again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToLogin();
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  /// Navigates to login screen and clears navigation stack
  void _navigateToLogin() {
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
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
      body: Consumer<HomeViewModel>(
        builder: (context, viewModel, child) {
          return RefreshIndicator(
            onRefresh: () async {
              await viewModel.refreshData();
            },
            child: _buildBodyContent(viewModel, localizations),
          );
        },
      ),
    );
  }

  /// Builds the main body based on the current state
  Widget _buildBodyContent(
    HomeViewModel viewModel,
    AppLocalizations localizations,
  ) {
    // Check for session expiration error first
    if (viewModel.error != null &&
        viewModel.error!.contains('Session expired')) {
      return _buildSessionExpiredView();
    }

    /// Loading state
    if (viewModel.isLoading && viewModel.featuredGroups.isEmpty) {
      return const HomeLoadingWidget();
    }

    /// Error state
    if (viewModel.error != null) {
      return HomeErrorWidget(
        error: viewModel.error!,
        onRetry: () => viewModel.refreshData(),
      );
    }

    /// Empty state
    if (viewModel.featuredGroups.isEmpty && viewModel.popularSubjects.isEmpty) {
      return HomeEmptyStateWidget(onReload: () => viewModel.refreshData());
    }

    /// Normal state
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          FeaturedGroupsSection(
            featuredGroups: viewModel.featuredGroups,
            title: localizations.featuredGroups ?? 'Featured Groups',
          ),

          PopularSubjectsSection(
            popularSubjects: viewModel.popularSubjects,
            title: localizations.popularSubjects ?? 'Popular Subjects',
          ),
        ],
      ),
    );
  }

  /// Builds view for session expired
  Widget _buildSessionExpiredView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.orange, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Session Expired',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your session has expired. Please login again.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _navigateToLogin,
            child: const Text('Login Again'),
          ),
        ],
      ),
    );
  }
}
