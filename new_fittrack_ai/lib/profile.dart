import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'login_page.dart';
import 'dart:math';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  /* ───── controllers ───── */
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final goalController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();

  /* ───── state ───── */
  String selectedGender = '';
  double? calculatedBMI;
  bool _isLoading = true;
  bool _isEditing = false;

  User? user;
  DatabaseReference? userRef;

  /* ───────────────────────── lifecycle ───────────────────────── */
  @override
  void initState() {
    super.initState();
    _initializeUser();
  }

  void _initializeUser() {
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userRef = FirebaseDatabase.instance.ref('users/${user!.uid}/profile');
      _loadUserProfile();
    } else {
      setState(() => _isLoading = false);
    }
  }

  /* ──────────────────────── load & save ─────────────────────── */
  Future<void> _loadUserProfile() async {
    try {
      final snap = await userRef!.get();
      if (snap.exists) {
        final data = Map<String, dynamic>.from(snap.value as Map);

        nameController.text = data['name'] ?? '';
        ageController.text = data['age'].toString();
        goalController.text = data['goal'] ?? '';
        weightController.text = data['weight']?.toString() ?? '';
        heightController.text = data['height']?.toString() ?? '';
        selectedGender = (data['gender'] ?? '') as String;

        _calculateBMI(); // compute using loaded height/weight
      }
    } catch (e) {
      debugPrint('Load error: $e');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _updateUserProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final weight = double.tryParse(weightController.text) ?? 0;
    final height = double.tryParse(heightController.text) ?? 0;
    _calculateBMI();

    try {
      await userRef!.set({
        'name': nameController.text,
        'age': int.tryParse(ageController.text) ?? 0,
        'goal': goalController.text,
        'weight': weight,
        'height': height,
        'gender': selectedGender,
        'bmi': calculatedBMI ?? 0.0,
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile saved!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }

    setState(() {
      _isEditing = false;
      _isLoading = false;
    });
  }

  /* ───────────────────── BMI helpers ───────────────────── */
  void _calculateBMI() {
    final w = double.tryParse(weightController.text);
    final h = double.tryParse(heightController.text);
    if (w != null && h != null && h > 0) {
      final hM = h / 100;
      calculatedBMI = w / pow(hM, 2);
    } else {
      calculatedBMI = null;
    }
  }

  String _bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _bmiColor(double bmi) {
    if (bmi < 18.5) return Colors.orange;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.deepOrange;
    return Colors.red;
  }

  /* ───────────────────────── UI ───────────────────────── */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (!_isLoading && user != null)
            IconButton(
              icon: Icon(_isEditing ? Icons.cancel : Icons.edit),
              onPressed: () => setState(() => _isEditing = !_isEditing),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : user == null
          ? const Center(child: Text('No user signed in.'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/avatar.png'),
                      backgroundColor: Color.fromARGB(255, 172, 133, 239),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      user?.email ?? 'Guest',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'User ID: ${user?.uid.substring(0, 6)}…',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 30),

                    /* ── Fields ── */
                    _buildTextField('Name', nameController),
                    _buildTextField(
                      'Age',
                      ageController,
                      inputType: TextInputType.number,
                    ),
                    _buildTextField(
                      'Weight (kg)',
                      weightController,
                      inputType: TextInputType.number,
                      extraOnChanged: _calculateBMI,
                    ),
                    _buildTextField(
                      'Height (cm)',
                      heightController,
                      inputType: TextInputType.number,
                      extraOnChanged: _calculateBMI,
                    ),
                    _buildTextField('Fitness Goal', goalController),
                    _buildGenderDropdown(),

                    const SizedBox(height: 12),
                    _buildBMICard(), // BMI + status
                    const SizedBox(height: 20),

                    if (_isEditing)
                      ElevatedButton(
                        onPressed: _updateUserProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            150,
                            121,
                            201,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Save Changes'),
                      ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  /* ────────── Helper widgets ────────── */
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType inputType = TextInputType.text,
    void Function()? extraOnChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        enabled: _isEditing,
        keyboardType: inputType,
        onChanged: (v) {
          if (!_isEditing) setState(() => _isEditing = true);
          extraOnChanged?.call();
        },
        validator: (v) => v!.isEmpty ? 'Please enter your $label' : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        value: selectedGender.isEmpty ? null : selectedGender,
        items: const [
          DropdownMenuItem(value: 'Male', child: Text('Male')),
          DropdownMenuItem(value: 'Female', child: Text('Female')),
          DropdownMenuItem(value: 'Other', child: Text('Other')),
        ],
        onChanged: _isEditing
            ? (val) => setState(() => selectedGender = val ?? '')
            : null,
        decoration: const InputDecoration(
          labelText: 'Gender',
          border: OutlineInputBorder(),
        ),
        validator: (v) =>
            (v == null || v.isEmpty) ? 'Please select your gender' : null,
      ),
    );
  }

  Widget _buildBMICard() {
    final bmiText = calculatedBMI == null
        ? '—'
        : calculatedBMI!.toStringAsFixed(1);
    final category = calculatedBMI == null ? '' : _bmiCategory(calculatedBMI!);
    final catColor = calculatedBMI == null
        ? Colors.grey
        : _bmiColor(calculatedBMI!);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        child: Column(
          children: [
            const Text(
              'BMI',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              bmiText,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            if (category.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                category,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: catColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
