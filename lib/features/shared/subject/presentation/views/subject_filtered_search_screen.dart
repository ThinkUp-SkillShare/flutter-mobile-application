import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../search/presentation/view_models/search_view_model.dart';
import '../../../../search/presentation/widgets/group_cards/compact_group_card.dart';

class SubjectFilteredSearchScreen extends StatefulWidget {
  final int subjectId;
  final String subjectName;

  const SubjectFilteredSearchScreen({
    super.key,
    required this.subjectId,
    required this.subjectName,
  });

  @override
  State<SubjectFilteredSearchScreen> createState() => _SubjectFilteredSearchScreenState();
}

class _SubjectFilteredSearchScreenState extends State<SubjectFilteredSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late SearchViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _viewModel.loadData().then((_) {
        _viewModel.filterBySubject(widget.subjectId);
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _viewModel = context.read<SearchViewModel>();
  }

  void _clearSearch() {
    _searchController.clear();
    _viewModel.filterGroups('');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: Text('${widget.subjectName} Groups'),
        backgroundColor: const Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<SearchViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: viewModel.filterGroups,
                    decoration: InputDecoration(
                      hintText: 'Search in ${widget.subjectName}...',
                      border: InputBorder.none,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: _buildSearchResults(viewModel),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(SearchViewModel viewModel) {
    if (viewModel.filteredGroups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              viewModel.currentSearchQuery.isEmpty
                  ? 'No groups found in ${widget.subjectName}'
                  : 'No results found for "${viewModel.currentSearchQuery}"',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: viewModel.filteredGroups.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CompactGroupCard(
            group: viewModel.filteredGroups[index],
            onJoinGroup: (groupId) async {
              final success = await viewModel.joinGroup(groupId);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Joined group successfully')),
                );
                viewModel.loadData();
              }
            },
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}