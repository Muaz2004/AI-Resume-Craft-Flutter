import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resume_ai/features/resume/data/resume_model.dart';
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
    // Pre-fill controllers if editing an existing resume
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

    // Set loading state
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
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Resume updated!')));
      } else {
        await ref.read(resumeServiceProvider).createResume(resume);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Resume created!')));
      }
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Failed to save resume: $e')));
    } finally {
      ref.read(resumeCreationStateProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(resumeCreationStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingResume != null ? 'Edit Resume' : 'Create Resume'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Full Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Enter full name' : null,
              ),

              // Email
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter email';
                  final emailRegex =
                      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
                  return null;
                },
              ),

              // Phone Number
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Enter phone number';
                  final phoneRegex = RegExp(r'^\d{7,}$'); // min 7 digits
                  if (!phoneRegex.hasMatch(value)) return 'Enter a valid phone number';
                  return null;
                },
              ),

              // Skills
              TextFormField(
                controller: _skillsController,
                decoration: const InputDecoration(
                  labelText: 'Skills (comma separated)',
                ),
              ),

              // Education
              TextFormField(
                controller: _educationController,
                decoration: const InputDecoration(labelText: 'Education'),
              ),

              // Address
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),

              // Experience
              TextFormField(
                controller: _experienceController,
                decoration: const InputDecoration(labelText: 'Experience'),
              ),

              const SizedBox(height: 20),

              // Save Button
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _saveResume,
                      child: Text(
                        widget.existingResume != null ? 'Update Resume' : 'Generate Resume',
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}