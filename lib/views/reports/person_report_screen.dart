import 'package:flutter/material.dart';

class PersonReportScreen extends StatefulWidget {
  const PersonReportScreen({super.key});

  @override
  State<PersonReportScreen> createState() => _PersonReportScreenState();
}

class _PersonReportScreenState extends State<PersonReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Text('Person Report'));
  }
}
