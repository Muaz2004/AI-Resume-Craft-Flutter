import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:resume_ai/features/resume/presentation/resume_form_screen.dart';
import 'package:resume_ai/shared/providers/resume_provider.dart';
import 'package:resume_ai/shared/providers/pdf_notifier.dart';

class ResumeDetailScreen extends ConsumerWidget {
  final String resumeId;

  const ResumeDetailScreen({super.key, required this.resumeId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resumeAsync = ref.watch(resumeByIdProvider(resumeId));

    return resumeAsync.when(
      data: (resume) {
        if (resume == null) {
          return const Scaffold(
            body: Center(child: Text('Resume not found')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(resume.fullName),
            actions: [
              /// EDIT
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ResumeFormScreen(existingResume: resume),
                    ),
                  );
                },
              ),

              /// DELETE 
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final confirm = await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Resume'),
                      content: const Text(
                          'Are you sure you want to delete this resume?'),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, true),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true) {
                    await ref
                        .read(resumeServiceProvider)
                        .deleteResume(
                            resume.userId, resume.resumeId);

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Resume deleted successfully')),
                    );
                  }
                },
              ),

              /// PDF ACTIONS 
              Consumer(
                builder: (context, ref, _) {
                  final pdfState =
                      ref.watch(pdfNotifierProvider);

                  return pdfState.when(
                    data: (_) => Row(
                      children: [

                        ///DOWNLOAD / PREVIEW 
                        IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () async {
                            try { // added
                              final pdfNotifier = ref.read(
                                  pdfNotifierProvider
                                      .notifier);

                              await pdfNotifier.generatePdf(
                                  resume.toFirestore());

                              await pdfNotifier.previewPdf();

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'PDF generated successfully'),
                                ),
                              );
                            } catch (_) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'PDF generation failed'),
                                ),
                              );
                            }
                          },
                        ),

                        ///SHARE 
                        IconButton( 
                          icon: const Icon(Icons.share), 
                          onPressed: () async {
                            try { 
                              final pdfNotifier = ref.read(
                                  pdfNotifierProvider
                                      .notifier);

                              await pdfNotifier.generatePdf(
                                  resume.toFirestore());

                              await pdfNotifier.sharePdf();

                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Resume shared successfully'),
                                ),
                              );
                            } catch (_) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Sharing failed')),
                              );
                            }
                          },
                        ),
                      ],
                    ),

                    loading: () => const Padding(
                      padding: EdgeInsets.all(16),
                      child:
                          CircularProgressIndicator(
                              strokeWidth: 2),
                    ),

                    error: (e, _) => IconButton(
                      icon: const Icon(Icons.error),
                      onPressed: () {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(
                          const SnackBar(
                            content:
                                Text('PDF system error'),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),


          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                _sectionTitle("Personal Information"),
                Text('Name: ${resume.fullName}',
                    style:
                        const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Email: ${resume.email}',
                    style:
                        const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Phone: ${resume.phone}',
                    style:
                        const TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text('Address: ${resume.address}',
                    style:
                        const TextStyle(fontSize: 18)),

                const SizedBox(height: 16),

                _sectionTitle("Education"),
                ...resume.education.map(
                  (edu) => Padding(
                    padding:
                        const EdgeInsets.only(
                            bottom: 4),
                    child: Text(
                        "• ${edu['details']}",
                        style:
                            const TextStyle(
                                fontSize: 16)),
                  ),
                ),

                const SizedBox(height: 16),

                _sectionTitle("Experience"),
                ...resume.experience.map(
                  (exp) => Padding(
                    padding:
                        const EdgeInsets.only(
                            bottom: 4),
                    child: Text(
                        "• ${exp['details']}",
                        style:
                            const TextStyle(
                                fontSize: 16)),
                  ),
                ),

                const SizedBox(height: 16),

                _sectionTitle("Skills"),
                Text(
                  resume.skills.join(', '),
                  style:
                      const TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        );
      },

      loading: () => const Scaffold(
        body:
            Center(child: CircularProgressIndicator()),
      ),

      error: (e, st) => const Scaffold(
        body:
            Center(child: Text('Failed to load resume')),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding:
          const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold),
      ),
    );
  }
}