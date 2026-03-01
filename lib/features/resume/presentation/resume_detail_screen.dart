import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_ai/features/resume/data/resume_model.dart';
import 'package:resume_ai/features/resume/presentation/resume_form_screen.dart';
import 'package:resume_ai/shared/providers/resume_provider.dart';

class ResumeDetailScreen extends ConsumerWidget {
  final ResumeModel resume;

  const ResumeDetailScreen({super.key, required this.resume});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
     appBar: AppBar(
  title: Text(resume.fullName),
  actions: [
    
    IconButton(
      icon: const Icon(Icons.edit),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResumeFormScreen(existingResume: resume),
          ),
        );
      },
    ),

  
    IconButton(
      icon: const Icon(Icons.delete),
      onPressed: () async {
        final confirm = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Resume'),
            content: const Text('Are you sure you want to delete this resume?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );

        if (confirm == true) {
          await ref.read(resumeServiceProvider).deleteResume(resume.resumeId,resume.userId);
          ref.invalidate(userResumesProvider); 
          Navigator.pop(context); 
        }
      },
    ),
  ],
),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle("Personal Information"),
            Text('Name: ${resume.fullName}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Email: ${resume.email}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Phone: ${resume.phone}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text('Address: ${resume.address}', style: const TextStyle(fontSize: 18)),

            const SizedBox(height: 16),
            _sectionTitle("Education"),
            ...resume.education.map(
              (edu) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text("• ${edu['details']}", style: const TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 16),
            _sectionTitle("Experience"),
            ...resume.experience.map(
              (exp) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text("• ${exp['details']}", style: const TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 16),
            _sectionTitle("Skills"),
            Text(resume.skills.join(', '), style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  /// Reusable section title
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}