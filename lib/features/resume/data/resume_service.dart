import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/resume_model.dart';

class ResumeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createResume(ResumeModel resume) async {
    try {
      await _firestore.collection('resumes').doc(resume.resumeId).set(resume.toFirestore());
    } catch (e) {
      throw Exception('Failed to create resume: $e');
    }
  }
  
  Future<ResumeModel?> getResume(String resumeId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('resumes').doc(resumeId).get();
      if (doc.exists) {
        return ResumeModel.fromFirestore(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get resume: $e');
    }
  }

  Future<void> updateResume(ResumeModel resume) async {
    try {
      await _firestore.collection('resumes').doc(resume.resumeId).update(resume.toFirestore());
    } catch (e) {
      throw Exception('Failed to update resume: $e');
    }
  }

  Future<void> deleteResume(String resumeId) async {
    try {
      await _firestore.collection('resumes').doc(resumeId).delete();
    } catch (e) {
      throw Exception('Failed to delete resume: $e');
    }
  }

  Future<List<ResumeModel>> getResumesByUserId(String userId) async {
    try {
      QuerySnapshot query = await _firestore.collection('resumes').where('userId', isEqualTo: userId).get();
      return query.docs.map((doc) => ResumeModel.fromFirestore(doc.data() as Map<String, dynamic>)).toList();
    } catch (e) {
      throw Exception('Failed to get resumes: $e');
    }
  }

  

}