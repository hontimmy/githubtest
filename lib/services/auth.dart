import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:github_sign_in/github_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

FirebaseAuth auth = FirebaseAuth.instance;

Future<dynamic> signInWithGithub(context) async {
  String? _errorMessage;
  UserCredential? userCredential;
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  try {
    final GitHubSignIn gitHubSignIn = GitHubSignIn(
      clientId: '76db39d44d0ba2e2c88b',
      clientSecret: '8ee4d9a929992b2324bb1851e83adb26bd802ff5',
      redirectUrl: 'https://jtestapp-c1072.firebaseapp.com/__/auth/handler',
    );

    final result = await gitHubSignIn.signIn(context);

    final AuthCredential githubAuthCredential =
        GithubAuthProvider.credential(result.token);

    userCredential =
        await FirebaseAuth.instance.signInWithCredential(githubAuthCredential);

    sharedPreferences.setBool('isLogin', true);
    sharedPreferences.setString('displayName', userCredential.user!.displayName.toString());
    sharedPreferences.setString('email', userCredential.user!.email.toString());
    sharedPreferences.setBool('isVerified', userCredential.user!.emailVerified);
  } on FirebaseAuthException catch (e) {
    _errorMessage = e.message;
  }

  if (_errorMessage != null) {
    return _errorMessage;
  }

  return userCredential;
}

Future<void> signOut() async {
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  sharedPreferences.clear();
  await auth.signOut();
}
