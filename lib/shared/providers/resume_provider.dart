import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resume_ai/features/resume/data/resume_service.dart';
import '../../features/resume/data/resume_model.dart';


final resumeServiceProvider = Provider((ref) => ResumeService());


final userResumesProvider = FutureProvider.autoDispose<List<ResumeModel>>((ref) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return [];

  final service = ref.read(resumeServiceProvider);
  return await service.getResumesByUserId(user.uid);
});


final resumeByIdProvider = FutureProvider.family.autoDispose<ResumeModel?, String>((ref, resumeId) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;

  final service = ref.read(resumeServiceProvider);
  return await service.getResume(user.uid, resumeId);
});

/// StateProvider to track loading/creation state for forms
final resumeCreationStateProvider = StateProvider<bool>((ref) => false);