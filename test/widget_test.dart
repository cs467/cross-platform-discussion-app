// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:disc/screens/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:disc/screens/home.dart';
// import 'package:flutter_driver/flutter_driver.dart';
// import 'package:test/test.dart';

void main() {
  Duration aLongWeekend = new Duration(seconds:7);
  testWidgets('email and password filled OK', (WidgetTester tester) async {
    var app = MaterialApp(
      home: LoginPage(),
    );

    await tester.pumpWidget(app);

    Finder email = find.byKey(new Key('email'));
    Finder pwd = find.byKey(new Key('password'));

    await tester.enterText(email, 'alpha6@gmail.com');
    await tester.enterText(pwd, 'password');
    await tester.pump(aLongWeekend);

    Finder formWidgetFinder = find.byType(Form);
    Form formWidget = tester.widget(formWidgetFinder) as Form;
    GlobalKey<FormState> formKey = formWidget.key as GlobalKey<FormState>;

    expect(formKey.currentState.validate(), isTrue);
  });
}
