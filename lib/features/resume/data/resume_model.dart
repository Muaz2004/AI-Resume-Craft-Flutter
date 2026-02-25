import 'package:cloud_firestore/cloud_firestore.dart';

class ResumeModel {

final String resumeId;
final String userId;


final String fullName;
final String email;
final String phone;
final String address;


final List<Map<String, dynamic>> education;
final List<Map<String, dynamic>> experience;
final List<String> skills;



final DateTime createdAt;
final DateTime updatedAt;


// constructor
ResumeModel({
  required this.resumeId,
  required this.userId,
  required this.fullName,
  required this.email,
  required this.phone,
  required this.address,
  required this.education,
  required this.experience,
  required this.skills,
  required this.createdAt,
  required this.updatedAt,

}
);

// firestor---app
factory ResumeModel.fromFirestore(Map<String, dynamic> data) {
  return ResumeModel(
    resumeId: data['resumeId'] ?? '',
    userId: data['userId'] ?? '',
    fullName: data['fullName'] ?? '',
    email: data['email'] ?? '',
    phone: data['phone'] ?? '',
    address: data['address'] ?? '',
    education: List<Map<String, dynamic>>.from(data['education'] ?? []),
    experience: List<Map<String, dynamic>>.from(data['experience'] ?? []),
    skills: List<String>.from(data['skills'] ?? []),
    createdAt: (data['createdAt'] as Timestamp).toDate(),
    updatedAt: (data['updatedAt'] as Timestamp).toDate(),
  );
}

//app-to-firestore
Map<String, dynamic> toFirestore() {
  return {
    'resumeId': resumeId,
    'userId': userId,
    'fullName': fullName,
    'email': email,
    'phone': phone,
    'address': address,
    'education': education,
    'experience': experience,
    'skills': skills,
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
  

}
