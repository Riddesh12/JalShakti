import 'package:flutter/material.dart';
import 'package:jal_shakti/login_page.dart';
import 'package:jal_shakti/navigation_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _idController = TextEditingController();

  bool isOfficial = false; // toggle between citizens/officials

  Widget _buildTextField(String label, String hint,
      {TextEditingController? controller, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            hintText: hint,
            hintStyle: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.white70),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white54),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00008B), Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Toggle Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() => isOfficial = false),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        !isOfficial ? Colors.white : Colors.transparent,
                        foregroundColor: !isOfficial
                            ? Colors.black
                            : Colors.white,
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: !isOfficial ? 6 : 0,
                      ),
                      child: const Text("Citizens"),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => setState(() => isOfficial = true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        isOfficial ? Colors.white : Colors.transparent,
                        foregroundColor:
                        isOfficial ? Colors.black : Colors.white,
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: isOfficial ? 6 : 0,
                      ),
                      child: const Text("Officials"),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Image.asset("Assets/jalshakti.png", height: 150),

                const SizedBox(height: 20),

                // Always show for both
                _buildTextField("Name", "Enter your name",
                    controller: _nameController),
                _buildTextField("Number", "Enter phone number",
                    controller: _phoneController,
                    keyboardType: TextInputType.number),
                _buildTextField("Email Id", "Enter email",
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress),

                // Only for officials
                if (isOfficial)
                  _buildTextField("Id", "Proof Id",
                      controller: _idController),

                // Always show
                _buildTextField("City", "Enter city",
                    controller: _cityController),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isEmpty ||
                        _phoneController.text.isEmpty ||
                        _emailController.text.isEmpty ||
                        _cityController.text.isEmpty ||
                        (isOfficial && _idController.text.isEmpty)) {  // ✅ Only check ID if official
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Colors.red,
                          content: Text("Please fill all the required fields"),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NavigationPage()),
                      );
                    }
                  },

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 8,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                  ),
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                SizedBox(height: 2,),
                TextButton(onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (_)=>LoginPage()));
                }, child: Text(" Already a user? Login",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white,fontSize: 15),))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
