import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:legal_dost/main.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mockito/mockito.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}

void main() {
  setupFirebaseAuthMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  testWidgets('AuthScreen displays login form', (WidgetTester tester) async {
    await tester.pumpWidget(const LegalDostApp());

    expect(find.text('Login'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2)); // Email and password fields
    expect(find.text('Don\'t have an account? Sign Up'), findsOneWidget);
  });

  testWidgets('RoleSelectionScreen displays after login', (WidgetTester tester) async {
    // Mock authentication
    final auth = MockFirebaseAuth();
    final user = MockUser();
    when(auth.currentUser).thenReturn(user);
    when(user.uid).thenReturn('testUid');

    await tester.pumpWidget(const LegalDostApp());

    // Simulate login (this would need a more complex setup with auth mocking)
    await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'password123');
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.text('Select Your Role'), findsOneWidget);
  });
}

void setupFirebaseAuthMocks() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Add Firebase mocks if needed (e.g., using firebase_auth_mocks package)
}