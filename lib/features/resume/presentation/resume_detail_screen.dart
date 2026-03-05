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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return resumeAsync.when(
      data: (resume) {
        if (resume == null) {
          return const Scaffold(body: Center(child: Text('Resume not found')));
        }

        return Scaffold(
          backgroundColor: isDark ? colorScheme.background : const Color(0xFFF1F5F9), 
          appBar: AppBar(
            title: Text(resume.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => ResumeFormScreen(existingResume: resume)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () async {
                  final confirm = await _showDeleteDialog(context);
                  if (confirm == true) {
                    await ref.read(resumeServiceProvider).deleteResume(resume.userId, resume.resumeId);
                    if (context.mounted) Navigator.pop(context);
                  }
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        )
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- HEADER SECTION ---
                        Center(
                          child: Column(
                            children: [
                              Text(
                                resume.fullName.toUpperCase(),
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 12,
                                children: [
                                  _contactInfo(Icons.email_outlined, resume.email, colorScheme),
                                  _contactInfo(Icons.phone_outlined, resume.phone, colorScheme),
                                ],
                              ),
                              if (resume.address.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: _contactInfo(Icons.location_on_outlined, resume.address, colorScheme),
                                ),
                            ],
                          ),
                        ),
                        const Divider(height: 40, thickness: 1),

                        // --- CONTENT SECTIONS ---
                        _buildSection(context, "EDUCATION", Icons.school_outlined),
                        ...resume.education.map((edu) => _buildDetailItem(edu['details'] ?? '', colorScheme)),
                        
                        const SizedBox(height: 24),
                        _buildSection(context, "EXPERIENCE", Icons.work_outline),
                        ...resume.experience.map((exp) => _buildDetailItem(exp['details'] ?? '', colorScheme)),
                        
                        const SizedBox(height: 24),
                        _buildSection(context, "SKILLS", Icons.bolt),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: resume.skills.map((skill) => Chip(
                              label: Text(skill, style: const TextStyle(fontSize: 12)),
                              backgroundColor: colorScheme.primary.withOpacity(0.05),
                              side: BorderSide(color: colorScheme.primary.withOpacity(0.1)),
                              visualDensity: VisualDensity.compact,
                            )).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // --- FIXED ACTION BAR AT BOTTOM ---
          bottomNavigationBar: _buildBottomActions(context, ref, resume),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator.adaptive())),
      error: (e, st) => const Scaffold(body: Center(child: Text('Failed to load resume'))),
    );
  }

  Widget _contactInfo(IconData icon, String text, ColorScheme colorScheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colorScheme.primary),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: colorScheme.onSurface.withOpacity(0.7))),
      ],
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: colorScheme.primary,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String text, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("• ", style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 15, height: 1.4, color: colorScheme.onSurface.withOpacity(0.85)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context, WidgetRef ref, dynamic resume) {
    final pdfState = ref.watch(pdfNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: pdfState.when(
          data: (_) => Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final pdfNotifier = ref.read(pdfNotifierProvider.notifier);
                    await pdfNotifier.generatePdf(resume.toFirestore());
                    await pdfNotifier.previewPdf();
                  },
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text("Generate & Preview", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () async {
                    final pdfNotifier = ref.read(pdfNotifierProvider.notifier);
                    await pdfNotifier.generatePdf(resume.toFirestore());
                    await pdfNotifier.sharePdf();
                  },
                  icon: Icon(Icons.share_outlined, color: colorScheme.onSecondaryContainer),
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ],
          ),
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => const Center(child: Text("PDF Error")),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Resume'),
        content: const Text('This action cannot be undone. Are you sure?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}