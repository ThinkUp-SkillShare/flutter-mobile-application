import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../search/presentation/view_models/search_view_model.dart';
import '../../../shared/subject/presentation/views/subject_filtered_search_screen.dart';
import 'subject_card.dart';

/// Section that displays a grid of the most popular subjects on the home screen.
/// Each subject card can be tapped to navigate to a filtered search view,
/// showing groups related to that specific subject.
class PopularSubjectsSection extends StatelessWidget {
  final List<Map<String, dynamic>> popularSubjects;
  final String title;

  const PopularSubjectsSection({
    super.key,
    required this.popularSubjects,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    /// If there are no popular subjects available, the section is not shown.
    if (popularSubjects.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Section title displayed above the grid.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                  color: Color(0xFF2C3E50),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        /// Grid of subject cards.
        /// GridView is wrapped in a Padding and configured
        /// with `shrinkWrap` so it can be embedded inside a scroll view.
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            // Ensures scrolling is handled by the parent view (e.g. SingleChildScrollView).

            /// Grid configuration: 2 columns, spacing, and aspect ratio.
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.6,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),

            itemCount: popularSubjects.length,
            itemBuilder: (context, index) {
              final subject = popularSubjects[index];

              return SubjectCard(
                subject: subject,

                /// When tapped, navigates to a screen that shows search results
                /// filtered by the selected subject.
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChangeNotifierProvider(
                        /// A new SearchViewModel is created specifically for
                        /// the filtered search screen.
                        create: (context) => SearchViewModel(),
                        child: SubjectFilteredSearchScreen(
                          subjectId: subject['id'] as int,
                          subjectName: subject['name'] as String,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }
}
