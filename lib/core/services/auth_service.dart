import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============= EMAIL REGISTER =============
  Future<User?> registerWithEmail({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    final userCred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await _saveUser(
      userCred.user!,
      name: name,
      email: email,
      phone: phone,
    );

    return userCred.user;
  }

  // ============= EMAIL LOGIN =============
  Future<User?> loginWithEmail(String email, String password) async {
    final userCred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCred.user;
  }

  // ============= PHONE LOGIN (OTP) =============
  Future<void> sendOTP({
    required String phone,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential cred) async {
        await _auth.signInWithCredential(cred);
      },
      verificationFailed: (e) => onError(e.message ?? "Phone auth failed"),
      codeSent: (String verID, int? token) => onCodeSent(verID),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<User?> verifyOTP(String verificationId, String otp) async {
    final cred = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: otp,
    );

    final userCred = await _auth.signInWithCredential(cred);

    final exists = await _db.collection("users").doc(userCred.user!.uid).get();
    if (!exists.exists) {
      await _saveUser(
        userCred.user!,
        name: "New user",
        email: null,
        phone: userCred.user!.phoneNumber,
      );
    }

    return userCred.user;
  }

  // ============= HELPERS =============
  Future<void> _saveUser(
      User user, {
        required String name,
        String? email,
        String? phone,
      }) async {
    await _db.collection("users").doc(user.uid).set({
      "uid": user.uid,
      "name": name,
      "email": email,
      "phone": phone,
      "isPremium": false,
      "trialUsed": false,
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  Stream<User?> get authState => _auth.authStateChanges();

  Future<void> logout() async => _auth.signOut();
}
