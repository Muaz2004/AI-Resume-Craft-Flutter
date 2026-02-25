import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/resume_model.dart';

class ResumeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create a new resume 
  
  Future<void> createResume(ResumeModel resume) async {
    try {
      await _firestore
          .collection('users')
          .doc(resume.userId)
          .collection('resumes')
          .doc(resume.resumeId)
          .set(resume.toFirestore());
    } catch (e) {
      throw Exception('Failed to create resume: $e');
    }
  }

  /// Get a single resume 
  
  Future<ResumeModel?> getResume(String userId, String resumeId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('resumes')
          .doc(resumeId)
          .get();
      if (doc.exists) {
        return ResumeModel.fromFirestore(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get resume: $e');
    }
  }

  /// Update a resume 
  
  Future<void> updateResume(ResumeModel resume) async {
    try {
      await _firestore
          .collection('users')
          .doc(resume.userId)
          .collection('resumes')
          .doc(resume.resumeId)
          .update({
        ...resume.toFirestore(),
        'updatedAt': Timestamp.now(), 
      });
    } catch (e) {
      throw Exception('Failed to update resume: $e');
    }
  }

  /// Delete a resume
  /// 
  Future<void> deleteResume(String userId, String resumeId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('resumes')
          .doc(resumeId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete resume: $e');
    }
  }

  // Get all resumes of a user

  Future<List<ResumeModel>> getResumesByUserId(String userId) async {
    try {
      QuerySnapshot query = await _firestore
          .collection('users')
          .doc(userId)
          .collection('resumes')
          .get();
      return query.docs
          .map((doc) => ResumeModel.fromFirestore(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get resumes: $e');
    }
  }
}