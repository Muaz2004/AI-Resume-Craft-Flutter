import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_ai/features/resume/presentation/resume_detail_screen.dart';
import 'package:resume_ai/features/resume/presentation/resume_form_screen.dart';
import 'package:resume_ai/shared/providers/resume_provider.dart';

class ResumeListScreen extends ConsumerWidget {
  const ResumeListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumesAsync = ref.watch(userResumesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Resumes'),
      ),

      body: resumesAsync.when(
        data: (resumes) {
          if (resumes.isEmpty) {
            return const Center(
              child: Text('No resumes found. Create one!'),
            );
          }

          return ListView.builder(
            itemCount: resumes.length,
            itemBuilder: (context, index) {
              final resume = resumes[index];

              return ListTile(
                title: Text(resume.fullName),
                subtitle: Text(
                  '${resume.email}\nCreated: ${resume.createdAt.toLocal()}',
                ),

                isThreeLine: true,

                onTap: () {
                         Navigator.push( context,
                MaterialPageRoute(
                builder: (_) => ResumeDetailScreen(resume: resume),
                     ),
                 );
                },
              );
            },
          );
        },

        loading: () =>
            const Center(child: CircularProgressIndicator()),

        error: (e, st) =>
            const Center(child: Text('Failed to load resumes')),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // wait navigation result
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ResumeFormScreen(),
            ),
          );

          //  refresh resumes after creation
          ref.invalidate(userResumesProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}