import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resume_ai/features/resume/data/resume_model.dart';
import 'package:resume_ai/services/ai/resume_ai_service.dart';
import 'package:resume_ai/shared/providers/resume_ai_provider.dart';
import 'package:resume_ai/shared/providers/resume_provider.dart';

class ResumeFormScreen extends ConsumerStatefulWidget {
  final ResumeModel? existingResume;

  const ResumeFormScreen({super.key, this.existingResume});

  @override
  ConsumerState<ResumeFormScreen> createState() => _ResumeFormScreenState();
}

class _ResumeFormScreenState extends ConsumerState<ResumeFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _skillsController = TextEditingController();
  final _educationController = TextEditingController();
  final _addressController = TextEditingController();
  final _experienceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existingResume != null) {
      final r = widget.existingResume!;
      _nameController.text = r.fullName;
      _emailController.text = r.email;
      _phoneController.text = r.phone;
      _addressController.text = r.address;
      _skillsController.text = r.skills.join(', ');
      _educationController.text =
          r.education.map((e) => e['details']).join(', ');
      _experienceController.text =
          r.experience.map((e) => e['details']).join(', ');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _skillsController.dispose();
    _educationController.dispose();
    _addressController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  void _saveResume() async {
    if (!_formKey.currentState!.validate()) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    ref.read(resumeCreationStateProvider.notifier).state = true;

    final resume = ResumeModel(
      resumeId: widget.existingResume?.resumeId ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user.uid,
      fullName: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      skills: _skillsController.text.split(',').map((e) => e.trim()).toList(),
      education: _educationController.text
          .split(',')
          .map((e) => {'details': e.trim()})
          .toList(),
      experience: _experienceController.text
          .split(',')
          .map((e) => {'details': e.trim()})
          .toList(),
      createdAt: widget.existingResume?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      if (widget.existingResume != null) {
        await ref.read(resumeServiceProvider).updateResume(resume);
      } else {
        await ref.read(resumeServiceProvider).createResume(resume);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      ref.read(resumeCreationStateProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(resumeCreationStateProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.existingResume != null ? 'Refine Resume' : 'New Resume'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSectionCard(
                title: "Personal Details",
                icon: Icons.person_outline,
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    hint: 'John Doe',
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email Address',
                    hint: 'john@example.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: _buildTextField(
                              controller: _phoneController, label: 'Phone')),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _buildTextField(
                              controller: _addressController,
                              label: 'Location')),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              _buildSectionCard(
                title: "Professional Content",
                icon: Icons.psychology_alt_outlined,
                children: [
                  _buildAIField(
                    controller: _experienceController,
                    label: 'Experience',
                    section: ResumeSection.experience,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 20),
                  _buildAIField(
                    controller: _skillsController,
                    label: 'Skills (Comma separated)',
                    section: ResumeSection.skills,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),
                  _buildAIField(
                    controller: _educationController,
                    label: 'Education',
                    section: ResumeSection.education,
                    maxLines: 2,
                  ),
                ],
              ),
              const SizedBox(height: 32),
              isLoading
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : ElevatedButton(
                      onPressed: _saveResume,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: Text(
                        widget.existingResume != null
                            ? 'Update Resume'
                            : 'Generate Professional CV',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
      {required String title,
      required IconData icon,
      required List<Widget> children}) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildAIField({
    required TextEditingController controller,
    required String label,
    required ResumeSection section,
    int maxLines = 1,
  }) {
    return Consumer(
      builder: (context, ref, _) {
        final aiState = ref.watch(resumeAiProvider(section));
        final isEnhancing = aiState.isLoading;

        return TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            alignLabelWithHint: true,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: isEnhancing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      icon: const Icon(Icons.psychology_alt_outlined,
                          color: Color(0xFF2563EB)),
                      tooltip: 'Enhance with AI',
                      onPressed: () async {
                        await ref
                            .read(resumeAiProvider(section).notifier)
                            .enhance(controller.text, section);

                        final result =
                            ref.read(resumeAiProvider(section));

                        if (result.asData != null) {
                          controller.text = result.asData!.value ?? '';
                        }
                      },
                    ),
            ),
          ),
        );
      },
    );
  }
}