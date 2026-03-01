import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:resume_ai/features/resume/data/resume_service.dart';
import '../../features/resume/data/resume_model.dart';

final resumeServiceProvider = Provider((ref) => ResumeService());

///  StreamProvider for real-time updates of user's resumes
final userResumesProvider = StreamProvider.autoDispose<List<ResumeModel>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return const Stream.empty();

  final service = ref.read(resumeServiceProvider);
  return service.streamResumesByUserId(user.uid);
});

/// StreamProvider for a single resume by ID
final resumeByIdProvider = StreamProvider.family.autoDispose<ResumeModel?, String>((ref, resumeId) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return const Stream.empty();

  final service = ref.read(resumeServiceProvider);
  return service.streamResumeById(user.uid, resumeId);
});

/// StateProvider to track loading/creation state for forms
final resumeCreationStateProvider = StateProvider<bool>((ref) => false);