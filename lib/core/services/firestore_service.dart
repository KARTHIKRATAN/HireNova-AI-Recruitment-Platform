import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/question_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // =========================
  // SAVE HR USER
  // =========================

  Future<void> saveHRUser({
    required String uid,
    required String name,
    required String email,
    required String companyName,
    String profileImage = "",
  }) async {
    await _firestore.collection("users").doc(uid).set({
      "uid": uid,
      "name": name,
      "email": email,
      "companyName": companyName,
      "role": "HR",
      "profileImage": profileImage,

      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> ensureHRUser({
    required String uid,
    required String name,
    required String email,
    required String companyName,
    String profileImage = "",
  }) async {
    final docRef = _firestore.collection("users").doc(uid);

    final snapshot = await docRef.get();

    if (snapshot.exists) {
      await docRef.set({
        "uid": uid,
        "name": name,
        "email": email,
        "companyName": companyName,
        "role": "HR",
        if (profileImage.isNotEmpty) "profileImage": profileImage,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return;
    }

    await docRef.set({
      "uid": uid,
      "name": name,
      "email": email,
      "companyName": companyName,
      "role": "HR",
      "profileImage": profileImage,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateHRProfile({
    required String uid,
    required String name,
    required String companyName,
    required String profileImage,
  }) async {
    await _firestore.collection("users").doc(uid).set({
      "name": name,
      "companyName": companyName,
      "profileImage": profileImage,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveAssessmentInvite({
    required String assessmentId,
    required String examPassword,
    required String candidateInviteCode,
    required String jobRole,
    required String skills,
    required String difficulty,
    required String hrUid,
  }) async {
    await _firestore.collection("assessments").doc(assessmentId).set({
      "assessmentId": assessmentId,
      "examId": assessmentId,
      "examPassword": examPassword,
      "candidateInviteCode": candidateInviteCode,
      "jobRole": jobRole,
      "skills": skills,
      "difficulty": difficulty,
      "hrUid": hrUid,
      "status": "active",
      "createdAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<Map<String, dynamic>?> validateExamCredentials({
    required String examId,
    required String examPassword,
  }) async {
    try {
      final document = await _firestore
          .collection("assessments")
          .doc(examId)
          .get();

      if (!document.exists || document.data() == null) {
        return null;
      }

      final data = document.data()!;

      final isPasswordValid = data["examPassword"] == examPassword;
      final isActive = data["status"] == null || data["status"] == "active";

      if (!isPasswordValid || !isActive) {
        return null;
      }

      return data;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }

  Future<String> saveCandidateLogin({
    required String candidateName,
    required String assessmentId,
  }) async {
    final document = await _firestore.collection("candidates").add({
      "candidateName": candidateName,
      "name": candidateName,
      "assessmentId": assessmentId,
      "loginTime": FieldValue.serverTimestamp(),
      "status": "started",
    });

    return document.id;
  }

  Future<void> saveCheatingLog({
    required String candidateName,
    required String role,
    required String assessmentId,
    required String violationType,
  }) async {
    await _firestore.collection("cheating_logs").add({
      "candidateName": candidateName,
      "role": role,
      "assessmentId": assessmentId,
      "violationType": violationType,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  Future<String> saveGeneratedQuestions({
    required String role,
    required String difficulty,
    required String createdBy,
    required List<QuestionModel> questions,
    String? assessmentId,
  }) async {
    final generatedSetRef = _firestore.collection("question_sets").doc();
    final batch = _firestore.batch();

    batch.set(generatedSetRef, {
      "questionSetId": generatedSetRef.id,
      "role": role,
      "difficulty": difficulty,
      "numberOfQuestions": questions.length,
      "createdBy": createdBy,
      "createdAt": FieldValue.serverTimestamp(),
    });

    for (final question in questions) {
      final questionRef = _firestore.collection("questions").doc();
      final questionData = {
        "questionId": questionRef.id,
        "questionSetId": generatedSetRef.id,
        "role": role,
        "createdBy": createdBy,
        "createdAt": FieldValue.serverTimestamp(),
        ...question.toJson(),
      };

      batch.set(questionRef, questionData);

      if (assessmentId != null && assessmentId.isNotEmpty) {
        final assessmentQuestionRef = _firestore
            .collection("assessments")
            .doc(assessmentId)
            .collection("questions")
            .doc(questionRef.id);

        batch.set(assessmentQuestionRef, questionData);
      }
    }

    if (assessmentId != null && assessmentId.isNotEmpty) {
      batch.set(
        _firestore.collection("assessments").doc(assessmentId),
        {
          "assessmentId": assessmentId,
          "questionSetId": generatedSetRef.id,
          "jobRole": role,
          "difficulty": difficulty,
          "updatedAt": FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();

    return generatedSetRef.id;
  }

  Future<List<QuestionModel>> getAssessmentQuestions(
    String assessmentId,
  ) async {
    final snapshot = await _firestore
        .collection("assessments")
        .doc(assessmentId)
        .collection("questions")
        .orderBy("createdAt")
        .get();

    return snapshot.docs
        .map(
          (doc) =>
              QuestionModel.fromJson({"questionId": doc.id, ...doc.data()}),
        )
        .toList();
  }

  Future<void> saveCodingSubmission({
    required String candidateId,
    required String assessmentId,
    required String questionId,
    required String questionTitle,
    required String language,
    required String code,
    required int score,
    required bool passed,
    required String output,
  }) async {
    await _firestore
        .collection("candidates")
        .doc(candidateId)
        .collection("coding_submissions")
        .doc(questionId)
        .set({
          "assessmentId": assessmentId,
          "questionId": questionId,
          "questionTitle": questionTitle,
          "language": language,
          "code": code,
          "score": score,
          "passed": passed,
          "output": output,
          "submittedAt": FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  Future<String> saveAssessmentResult({
    required String candidateId,
    required String candidateName,
    required String assessmentId,
    required int mcqScore,
    required int mcqTotal,
    required int codingScore,
    required int codingTotal,
  }) async {
    final totalScore = mcqScore + codingScore;
    final totalMarks = mcqTotal + codingTotal;
    final percentage = totalMarks == 0 ? 0 : (totalScore / totalMarks) * 100;

    await _firestore.collection("candidates").doc(candidateId).set({
      "candidateName": candidateName,
      "assessmentId": assessmentId,
      "status": "completed",
      "completedAt": FieldValue.serverTimestamp(),
      "mcqScore": mcqScore,
      "mcqTotal": mcqTotal,
      "codingScore": codingScore,
      "codingTotal": codingTotal,
      "totalScore": totalScore,
      "totalMarks": totalMarks,
      "percentage": percentage,
    }, SetOptions(merge: true));

    final resultRef = _firestore.collection("results").doc(candidateId);

    await resultRef.set({
      "candidateId": candidateId,
      "candidateName": candidateName,
      "assessmentId": assessmentId,
      "mcqScore": mcqScore,
      "mcqTotal": mcqTotal,
      "codingScore": codingScore,
      "codingTotal": codingTotal,
      "totalScore": totalScore,
      "totalMarks": totalMarks,
      "percentage": percentage,
      "createdAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return resultRef.id;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> resultsStream() {
    return _firestore
        .collection("results")
        .orderBy("percentage", descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> assessmentsStream() {
    return _firestore
        .collection("assessments")
        .orderBy("createdAt", descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> cheatingLogsStream() {
    return _firestore
        .collection("cheating_logs")
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> candidatesStream() {
    return _firestore
        .collection("candidates")
        .orderBy("loginTime", descending: true)
        .snapshots();
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final candidatesSnapshot = await _firestore.collection("candidates").get();
    final assessmentsSnapshot = await _firestore
        .collection("assessments")
        .get();
    final resultsSnapshot = await _firestore.collection("results").get();

    final activeAssessments = assessmentsSnapshot.docs
        .where((doc) => (doc.data()["status"] ?? "active") == "active")
        .length;

    final completedAssessments = resultsSnapshot.docs.length;

    final percentages = resultsSnapshot.docs
        .map((doc) => (doc.data()["percentage"] as num?)?.toDouble() ?? 0)
        .toList();
    final averageScore = percentages.isEmpty
        ? 0
        : percentages.reduce((a, b) => a + b) / percentages.length;

    return {
      "totalCandidates": candidatesSnapshot.docs.length,
      "activeAssessments": activeAssessments,
      "completedAssessments": completedAssessments,
      "averageScore": averageScore,
    };
  }

  // =========================
  // GET USER DATA
  // =========================

  Future<DocumentSnapshot> getUserData(String uid) async {
    return await _firestore.collection("users").doc(uid).get();
  }

  // =========================
  // GET CURRENT HR DATA
  // =========================

  Future<Map<String, dynamic>?> getHRData(String uid) async {
    try {
      DocumentSnapshot document = await _firestore
          .collection("users")
          .doc(uid)
          .get();

      if (!document.exists || document.data() == null) {
        return null;
      }

      return document.data() as Map<String, dynamic>;
    } catch (e) {
      debugPrint(e.toString());
      return null;
    }
  }
}
