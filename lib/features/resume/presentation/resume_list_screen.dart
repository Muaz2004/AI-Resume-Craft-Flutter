import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:resume_ai/features/resume/presentation/resume_detail_screen.dart';
import 'package:resume_ai/features/resume/presentation/resume_form_screen.dart';
import 'package:resume_ai/shared/providers/resume_provider.dart';

class ResumeListScreen extends ConsumerWidget {
  const ResumeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumesAsync = ref.watch(userResumesProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Resumes',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            fontSize: 24,
            color: colorScheme.onPrimary,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {}, 
            icon: Icon(Icons.account_circle_outlined, size: 28, color: colorScheme.onPrimary),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: resumesAsync.when(
        data: (resumes) {
          if (resumes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.description_outlined,
                    size: 80,
                    color: colorScheme.primary.withOpacity(0.2),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No resumes found',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onBackground.withOpacity(0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start your career journey today.',
                    style: TextStyle(color: colorScheme.onBackground.withOpacity(0.5)),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: resumes.length,
            itemBuilder: (context, index) {
              final resume = resumes[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isDark
                        ? [] 
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                  ),
                  child: Material(
                    color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ResumeDetailScreen(resumeId: resume.resumeId),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            // Initial Avatar
                            Container(
                              height: 56,
                              width: 56,
                              decoration: BoxDecoration(
                                color: isDark 
                                    ? colorScheme.primary.withOpacity(0.2) 
                                    : colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: Text(
                                  resume.fullName.isNotEmpty ? resume.fullName[0].toUpperCase() : '?',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? colorScheme.primaryContainer : colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Details Section
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    resume.fullName,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface, 
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    resume.email,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: colorScheme.onSurface.withOpacity(0.6),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today, 
                                        size: 12, 
                                        color: isDark ? colorScheme.primaryContainer : colorScheme.primary
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Updated ${DateFormat('MMM d, yyyy').format(resume.createdAt)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? colorScheme.primaryContainer : colorScheme.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.chevron_right, 
                              color: colorScheme.onSurface.withOpacity(0.2)
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, st) => Center(
          child: Text(
            'Failed to load resumes',
            style: TextStyle(color: colorScheme.error),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ResumeFormScreen(),
            ),
          );
        },
        backgroundColor: colorScheme.primary,
        child: const Icon(Icons.add_rounded, size: 28),
      ),
    );
  }
}