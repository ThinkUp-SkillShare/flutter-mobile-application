import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_models/search_view_model.dart';
import '../widgets/category_chips.dart';
import '../widgets/group_cards/compact_group_card.dart';
import '../widgets/group_cards/large_group_card.dart';
import '../widgets/group_cards/medium_group_card.dart';
import '../widgets/group_cards/trending_group_card.dart';
import '../widgets/search_app_bar.dart';
import '../widgets/section_header.dart';
import '../widgets/statistics_cards.dart';
import '../widgets/subject_grid.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SearchViewModel>().loadData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Consumer<SearchViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                pinned: true,
                snap: false,
                backgroundColor: const Color(0xFFFAFAFA),
                surfaceTintColor: const Color(0xFFFAFAFA),
                elevation: 1,
                title: SearchAppBar(
                  searchController: _searchController,
                  onSearchChanged: viewModel.filterGroups,
                  onClearSearch: _clearSearch,
                ),
                centerTitle: false,
                titleSpacing: 20,
              ),

              if (viewModel.currentSubjectFilterId != null)
                _buildActiveFilterHeader(viewModel),

              if (viewModel.isSearching)
                _buildSearchResults(viewModel)
              else
                ..._buildHomeSections(viewModel),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActiveFilterHeader(SearchViewModel viewModel) {
    final subjectName = viewModel.selectedCategory;

    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.filter_alt,
              color: Colors.blue[700],
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Showing groups in: $subjectName',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                viewModel.clearSubjectFilter();
                _searchController.clear();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(Icons.close, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      'Clear',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<SearchViewModel>().filterGroups('');
  }

  Widget _buildSearchResults(SearchViewModel viewModel) {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            if (viewModel.filteredGroups.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Text(
                    'No groups found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
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
          childCount: viewModel.filteredGroups.isEmpty ? 1 : viewModel.filteredGroups.length,
        ),
      ),
    );
  }

  List<Widget> _buildHomeSections(SearchViewModel viewModel) {
    return [
      if (viewModel.subjects.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: CategoryChips(
            categories: viewModel.subjects.map((subject) => subject['name'] as String).toList(),
            selectedCategory: viewModel.selectedCategory,
            onCategorySelected: (category) {
              final subject = viewModel.subjects.firstWhere(
                    (s) => s['name'] == category,
                orElse: () => {'id': 0},
              );
              if (subject['id'] != 0) {
                viewModel.filterBySubject(subject['id']);
              }
            },
          ),
        ),
      ],

      SliverToBoxAdapter(
        child: StatisticsCards(
          totalGroups: viewModel.totalGroups,
          totalStudents: viewModel.totalStudents,
          totalDocuments: viewModel.totalDocuments,
        ),
      ),

      if (viewModel.recommendedGroups.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Recommended for You',
            subtitle: 'Based on your interests',
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 300,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: viewModel.recommendedGroups.length,
              itemBuilder: (context, index) {
                return LargeGroupCard(group: viewModel.recommendedGroups[index]);
              },
            ),
          ),
        ),
      ],

      if (viewModel.popularGroups.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Popular This Week',
            subtitle: 'Most active groups',
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                return MediumGroupCard(group: viewModel.popularGroups[index]);
              },
              childCount: viewModel.popularGroups.length,
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 16)),
      ],

      if (viewModel.trendingGroups.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Trending Now',
            subtitle: '🔥 Hot topics',
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: viewModel.trendingGroups.length,
              itemBuilder: (context, index) {
                return TrendingGroupCard(group: viewModel.trendingGroups[index]);
              },
            ),
          ),
        ),
      ],

      if (viewModel.newGroups.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'New Groups',
            subtitle: 'Fresh communities to explore',
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: CompactGroupCard(
                    group: viewModel.newGroups[index],
                    onJoinGroup: (groupId) async {
                      final success = await viewModel.joinGroup(groupId);
                      if (success && mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Joined group successfully')),
                        );
                        viewModel.loadData();
                      }
                    },
                    showNewBadge: true,
                  ),
                );
              },
              childCount: viewModel.newGroups.length,
            ),
          ),
        ),
      ],

      if (viewModel.subjects.isNotEmpty) ...[
        SliverToBoxAdapter(
          child: SectionHeader(
            title: 'Browse by Subject',
            subtitle: 'Explore all categories',
          ),
        ),
        SliverToBoxAdapter(
          child: Transform.translate(
            offset: const Offset(0, -50),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: SubjectGrid(
                subjects: viewModel.subjects,
                allGroups: viewModel.allGroups,
                onSubjectSelected: viewModel.filterBySubject,
              ),
            ),
          ),
        ),
      ],

    ];
  }
}