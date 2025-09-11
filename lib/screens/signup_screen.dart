import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'landing_page.dart';
import 'package:legacy_lane_fresh/widgets/hover_widget.dart';
import 'package:legacy_lane_fresh/services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String _userType = 'create';
  final TextEditingController _communityNameController =
      TextEditingController();
  final TextEditingController _communityIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  // Categorized community types
  final Map<String, List<String>> _categorizedCommunityTypes = {
    'Education & Alumni': [
      'University Alumni',
      'School Alumni',
      'College Alumni',
      'Fraternity/Sorority',
      'Bootcamp Graduates',
      'Online Course Community',
      'Other Education Group',
    ],
    'Professional & Business': [
      'Professional Association',
      'Corporate Alumni',
      'Business Network',
      'Entrepreneur Group',
      'Startup Incubator',
      'Industry Association',
      'Other Professional Group',
    ],
    'Recreational & Social': [
      'Sports Team',
      'Hobbyist Group',
      'Book Club',
      'Gaming Community',
      'Travel Enthusiasts',
      'Social Club',
      'Other Recreational Group',
    ],
    'Arts & Culture': [
      'Artists Collective',
      'Music Band/Group',
      'Theater Company',
      'Writing Group',
      'Photography Club',
      'Dance Troupe',
      'Other Arts Group',
    ],
    'Community & Civic': [
      'Neighborhood Association',
      'Volunteer Organization',
      'Non-Profit Group',
      'Political Organization',
      'Religious Community',
      'Cultural Association',
      'Other Community Group',
    ],
    'Support & Wellness': [
      'Health Support Group',
      'Fitness Community',
      'Mental Wellness Group',
      'Parenting Network',
      'Recovery Community',
      'Other Support Group',
    ],
  };

  String _selectedCommunityType = 'Select community type';
  String _communityType = '';
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _showCommunityTypeModal = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _communityNameController.addListener(() => setState(() {}));
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
    _firstNameController.addListener(() => setState(() {}));
    _lastNameController.addListener(() => setState(() {}));
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _communityNameController.dispose();
    _communityIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Legacy Lane',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LandingPage()),
            );
          },
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Column(
                      children: [
                        Text(
                          'Start Your Legacy Journey',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Create or join a community to get started',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'I want to:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: ChoiceChip(
                                  label: const Text('Create New Community'),
                                  selected: _userType == 'create',
                                  onSelected: (bool selected) {
                                    setState(() {
                                      _userType = 'create';
                                    });
                                  },
                                  selectedColor: Colors.deepPurple,
                                  labelStyle: TextStyle(
                                    color: _userType == 'create'
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ChoiceChip(
                                  label: const Text('Join Existing Community'),
                                  selected: _userType == 'join',
                                  onSelected: (bool selected) {
                                    setState(() {
                                      _userType = 'join';
                                    });
                                  },
                                  selectedColor: Colors.deepPurple,
                                  labelStyle: TextStyle(
                                    color: _userType == 'join'
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // User Credentials Section - Always visible
                  Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Your Account Details',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.person),
                            ),
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email Address',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.email),
                            ),
                            keyboardType: TextInputType.emailAddress,
                          ),
                          const SizedBox(height: 15),
                          TextFormField(
                            controller: _passwordController,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            obscureText: _obscurePassword,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  if (_userType == 'create') _buildCreateForm(),
                  if (_userType == 'join') _buildJoinForm(),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_userType == 'create') {
                          _validateAndCreateCommunity();
                        } else {
                          _validateAndJoinCommunity();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Continue',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text('Or', style: TextStyle(color: Colors.grey)),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Contextual Google button based on user selection
                  if (_userType == 'create') ..._buildGoogleCreateSection(),
                  if (_userType == 'join') ..._buildGoogleJoinSection(),

                  const SizedBox(height: 20),

                  Center(
                    child: HoverWidget(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      builder: (isHovered) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isHovered
                                ? Colors.deepPurple.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text.rich(
                            TextSpan(
                              text: 'Already have an account? ',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: isHovered ? 15 : 14,
                              ),
                              children: [
                                TextSpan(
                                  text: 'Login',
                                  style: TextStyle(
                                    color: isHovered
                                        ? Colors.deepPurple[800]
                                        : Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isHovered ? 15 : 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Home Link with Hover Effect
                  Center(
                    child: HoverWidget(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LandingPage(),
                          ),
                        );
                      },
                      builder: (isHovered) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isHovered
                                ? Colors.grey.withOpacity(0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.home,
                                size: 16,
                                color: isHovered
                                    ? Colors.deepPurple
                                    : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Back to Home',
                                style: TextStyle(
                                  color: isHovered
                                      ? Colors.deepPurple
                                      : Colors.grey,
                                  fontWeight: isHovered
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildCreateForm() {
    final int currentLength = _communityNameController.text.length;
    final bool isOverLimit = currentLength > 40;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Community Details',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _communityNameController,
              decoration: InputDecoration(
                labelText: 'Community Name',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.group),
                counterText: '$currentLength/40',
                errorText: isOverLimit ? 'Maximum 40 characters allowed' : null,
                errorStyle: const TextStyle(color: Colors.red),
                suffixIcon: currentLength > 0
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        onPressed: () {
                          _communityNameController.clear();
                        },
                      )
                    : null,
              ),
              maxLength: 40,
            ),
            if (isOverLimit)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  '⚠️ Community name must be 40 characters or less',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 15),

            // Community type selector
            const Text(
              'Community Type',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            _buildCommunityTypeSelector(),
            const SizedBox(height: 8),
            const Text(
              'This helps us understand how Legacy Lane is being used worldwide.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _showCommunityTypeModal = true;
              _searchQuery = '';
              _searchController.clear();
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedCommunityType,
                  style: TextStyle(
                    color: _selectedCommunityType == 'Select community type'
                        ? Colors.grey
                        : Colors.black,
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        if (_showCommunityTypeModal) _buildCommunityTypeModal(),
      ],
    );
  }

  Widget _buildCommunityTypeModal() {
    // Filter types based on search query
    final filteredTypes = _searchQuery.isEmpty
        ? _categorizedCommunityTypes
        : _categorizedCommunityTypes.map((category, types) {
            final filtered = types.where(
              (type) =>
                  type.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  category.toLowerCase().contains(_searchQuery.toLowerCase()),
            );
            return MapEntry(category, filtered.toList());
          });

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(4),
        color: Colors.white,
      ),
      child: Column(
        children: [
          // Search bar
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Search community types...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Categories and types
          SizedBox(
            height: 300,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: filteredTypes.entries.map((entry) {
                  if (entry.value.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.key,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...entry.value.map((type) {
                        return ListTile(
                          title: Text(type),
                          contentPadding: EdgeInsets.zero,
                          onTap: () {
                            setState(() {
                              _selectedCommunityType = type;
                              _communityType = type;
                              _showCommunityTypeModal = false;
                            });
                          },
                        );
                      }),
                      const SizedBox(height: 16),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),

          // Custom option
          ListTile(
            title: const Text('My community type isn\'t listed'),
            leading: const Icon(Icons.add),
            onTap: () {
              _showCustomCommunityTypeDialog();
            },
          ),
        ],
      ),
    );
  }

  void _showCustomCommunityTypeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        TextEditingController customController = TextEditingController();
        return AlertDialog(
          title: const Text('Add Custom Community Type'),
          content: TextField(
            controller: customController,
            decoration: const InputDecoration(
              hintText: 'Enter your community type',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (customController.text.trim().isNotEmpty) {
                  setState(() {
                    _selectedCommunityType = customController.text.trim();
                    _communityType = customController.text.trim();
                    _showCommunityTypeModal = false;
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildJoinForm() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Join Existing Community',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),
            TextFormField(
              controller: _communityIdController,
              decoration: const InputDecoration(
                labelText: 'Community Invite Code or ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
                hintText: 'Enter the community code provided to you',
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Don\'t have an invite code? Contact your community administrator.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildGoogleCreateSection() {
    return [
      const Text(
        'Quickly create your community using your Google account',
        style: TextStyle(fontSize: 12, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 10),
      HoverWidget(
        builder: (isHovered) {
          return SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _signInWithGoogleCreateCommunity();
              },
              icon: const Icon(Icons.g_mobiledata, size: 24),
              label: AnimatedScale(
                scale: isHovered ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: const Text('Create Community with Google'),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: isHovered ? Colors.deepPurple : Colors.black,
                side: BorderSide(
                  color: isHovered ? Colors.deepPurple : Colors.grey,
                  width: isHovered ? 1.5 : 1.0,
                ),
                backgroundColor: isHovered
                    ? Colors.deepPurple.withOpacity(0.1)
                    : Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          );
        },
      ),
    ];
  }

  List<Widget> _buildGoogleJoinSection() {
    return [
      const Text(
        'Find and join your community using Google',
        style: TextStyle(fontSize: 12, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
      const SizedBox(height: 10),
      HoverWidget(
        builder: (isHovered) {
          return SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _signInWithGoogleJoinCommunity();
              },
              icon: const Icon(Icons.g_mobiledata, size: 24),
              label: AnimatedScale(
                scale: isHovered ? 1.05 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: const Text('Find Community with Google'),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: isHovered ? Colors.deepPurple : Colors.black,
                side: BorderSide(
                  color: isHovered ? Colors.deepPurple : Colors.grey,
                  width: isHovered ? 1.5 : 1.0,
                ),
                backgroundColor: isHovered
                    ? Colors.deepPurple.withOpacity(0.1)
                    : Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          );
        },
      ),
    ];
  }

  void _validateAndCreateCommunity() async {
    final String communityName = _communityNameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String firstName = _firstNameController.text.trim();
    final String lastName = _lastNameController.text.trim();

    if (communityName.isEmpty) {
      _showErrorDialog('Please enter a community name');
      return;
    }

    if (communityName.length > 40) {
      _showErrorDialog('Community name must be 40 characters or less');
      return;
    }

    if (_communityType.isEmpty || _communityType == 'Select community type') {
      _showErrorDialog('Please select a community type');
      return;
    }

    if (firstName.isEmpty) {
      _showErrorDialog('Please enter your first name');
      return;
    }

    if (lastName.isEmpty) {
      _showErrorDialog('Please enter your last name');
      return;
    }

    if (email.isEmpty) {
      _showErrorDialog('Please enter your email address');
      return;
    }

    if (password.isEmpty) {
      _showErrorDialog('Please enter a password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService().signUpWithEmail(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        communityName: communityName,
        communityType: _communityType,
      );

      print('Community created successfully: $result');
      // TODO: Navigate to dashboard
    } catch (e) {
      _showErrorDialog('Error creating community: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _validateAndJoinCommunity() async {
    final String communityId = _communityIdController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();
    final String firstName = _firstNameController.text.trim();
    final String lastName = _lastNameController.text.trim();

    if (communityId.isEmpty) {
      _showErrorDialog('Please enter a community invite code or ID');
      return;
    }

    if (firstName.isEmpty) {
      _showErrorDialog('Please enter your first name');
      return;
    }

    if (lastName.isEmpty) {
      _showErrorDialog('Please enter your last name');
      return;
    }

    if (email.isEmpty) {
      _showErrorDialog('Please enter your email address');
      return;
    }

    if (password.isEmpty) {
      _showErrorDialog('Please enter a password');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService().joinCommunityWithEmail(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        communityId: communityId,
      );

      print('Joined community successfully: $result');
      // TODO: Navigate to dashboard
    } catch (e) {
      _showErrorDialog('Error joining community: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _signInWithGoogleCreateCommunity() async {
    final String communityName = _communityNameController.text.trim();

    if (communityName.isEmpty) {
      _showErrorDialog('Please enter a community name');
      return;
    }

    if (_communityType.isEmpty || _communityType == 'Select community type') {
      _showErrorDialog('Please select a community type');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService().signInWithGoogleCreateCommunity(
        communityName: communityName,
        communityType: _communityType,
      );

      print('Community created with Google: $result');
      // TODO: Navigate to dashboard
    } catch (e) {
      _showErrorDialog('Error creating community with Google: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _signInWithGoogleJoinCommunity() async {
    final String communityId = _communityIdController.text.trim();

    if (communityId.isEmpty) {
      _showErrorDialog('Please enter a community invite code or ID');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await AuthService().signInWithGoogleJoinCommunity(
        communityId,
      );

      print('Joined community with Google: $result');
      // TODO: Navigate to dashboard
    } catch (e) {
      _showErrorDialog('Error joining community with Google: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
