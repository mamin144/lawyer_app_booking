import 'dart:io';

import 'package:flutter/material.dart';

class LegalNeedsQualificationScreen extends StatefulWidget {
  const LegalNeedsQualificationScreen({super.key});

  @override
  _LegalNeedsQualificationScreenState createState() =>
      _LegalNeedsQualificationScreenState();
}

class _LegalNeedsQualificationScreenState
    extends State<LegalNeedsQualificationScreen> {
  String? _selectedLegalArea;
  String? _selectedQualification;

  final List<String> _legalAreas = [
    'Family Law',
    'Business Law',
    'Criminal Law',
    'Property Law',
  ];

  final List<String> _qualifications = [
    'Bachelor of Laws (LLB)',
    'Juris Doctor (JD)',
    'Master of Laws (LLM)',
    'PhD in Law',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Welcome to App',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Help Us Understand Your Legal Needs',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 40),
              const Text(
                'Select experience',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children:
                    _legalAreas.map((area) {
                      return ChoiceChip(
                        label: Text(area),
                        selected: _selectedLegalArea == area,
                        onSelected: (bool selected) {
                          setState(() {
                            _selectedLegalArea = selected ? area : null;
                          });
                        },
                        selectedColor: Colors.blue.shade100,
                        backgroundColor: Colors.grey.shade100,
                        labelStyle: TextStyle(
                          color:
                              _selectedLegalArea == area
                                  ? Colors.blue
                                  : Colors.black,
                        ),
                      );
                    }).toList(),
              ),
              const SizedBox(height: 40),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  hintText: 'Select Qualification',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                items:
                    _qualifications
                        .map(
                          (qualification) => DropdownMenuItem(
                            value: qualification,
                            child: Text(qualification),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedQualification = value;
                  });
                },
              ),
              const SizedBox(height: 40),
              Text(
                'Upload Your Certificate',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // TODO: Implement certificate upload logic
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_circle_outline,
                            color: Colors.blue,
                            size: 50,
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Add Your Certificate',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      _selectedLegalArea != null &&
                              _selectedQualification != null
                          ? () {
                            // TODO: Implement next step navigation
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
