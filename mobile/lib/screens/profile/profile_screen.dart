import 'package:flutter/material.dart';
import '../../models/profile_model.dart';
import 'widgets/profile_header.dart';
import 'widgets/personal_info_form.dart';
import 'widgets/physical_info_section.dart';
import 'widgets/emergency_contacts_section.dart';
import 'widgets/delete_account_section.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Replace with actual provider or state
    final profile = ProfileData(
      fullName: 'Jane Doe',
      email: 'jane.doe@email.com',
      photoUrl: '',
      phone: '123-456-7890',
      bio: 'Asthma warrior',
      age: 28,
      weight: 60.0,
      height: 165.0,
      gender: 'female',
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ProfileHeader(
              profile: profile,
              isEditing: false,
              isUpdating: false,
            ),
            const SizedBox(height: 24),
            PersonalInfoForm(
              fullNameController: TextEditingController(text: profile.fullName),
              phoneController: TextEditingController(text: profile.phone ?? ''),
              bioController: TextEditingController(text: profile.bio ?? ''),
              email: profile.email,
              isEditing: false,
            ),
            const SizedBox(height: 24),
            PhysicalInfoSection(
              ageController:
                  TextEditingController(text: profile.age?.toString() ?? ''),
              weightController:
                  TextEditingController(text: profile.weight?.toString() ?? ''),
              heightController:
                  TextEditingController(text: profile.height?.toString() ?? ''),
              selectedGender: profile.gender,
              isEditing: false,
              onGenderChanged: (_) {},
            ),
            const SizedBox(height: 24),
            EmergencyContactsSection(
              contacts: const [],
              isLoading: false,
            ),
            const SizedBox(height: 24),
            DeleteAccountSection(
              onDeleteAccount: () {},
              isLoading: false,
            ),
          ],
        ),
      ),
    );
  }
}
