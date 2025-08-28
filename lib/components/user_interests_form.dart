import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/uploaded_file.dart';

class UserInterestsForm extends StatefulWidget {
  const UserInterestsForm({
    super.key,
    this.onSave,
    this.initialData,
  });

  final Function({
    String? favoriteDestination,
    String? tripType,
    List<String>? foodPreferences,
    List<String>? hobbies,
    FFUploadedFile? profilePhoto,
    String? instagramLink,
  })? onSave;

  final Map<String, dynamic>? initialData;

  @override
  State<UserInterestsForm> createState() => _UserInterestsFormState();
}

class _UserInterestsFormState extends State<UserInterestsForm> {
  final _formKey = GlobalKey<FormState>();
  final _favoriteDestinationController = TextEditingController();
  final _instagramController = TextEditingController();
  
  String? _selectedTripType;
  final List<String> _selectedFoodPreferences = [];
  final List<String> _selectedHobbies = [];
  FFUploadedFile? _profilePhoto;

  // Dropdown options
  final List<String> _tripTypes = [
    'Adventure',
    'Luxury',
    'Budget',
    'Family',
    'Romantic',
    'Business',
    'Solo',
    'Cultural',
    'Beach',
    'Mountain',
  ];

  final List<String> _foodOptions = [
    'Vegetarian',
    'Non-Vegetarian',
    'Vegan',
    'Halal',
    'Kosher',
    'Gluten-Free',
    'Dairy-Free',
    'No Restrictions',
  ];

  final List<String> _hobbyOptions = [
    'Hiking',
    'Museums',
    'Beaches',
    'Nightlife',
    'Photography',
    'Food & Dining',
    'Shopping',
    'Art & Culture',
    'Sports',
    'Music',
    'Nature',
    'History',
    'Architecture',
    'Adventure Sports',
    'Wellness & Spa',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFromData();
  }

  void _initializeFromData() {
    if (widget.initialData != null) {
      _favoriteDestinationController.text = widget.initialData!['favoriteDestination'] ?? '';
      _instagramController.text = widget.initialData!['instagramLink'] ?? '';
      _selectedTripType = widget.initialData!['tripType'];
      
      if (widget.initialData!['foodPreferences'] != null) {
        _selectedFoodPreferences.addAll(List<String>.from(widget.initialData!['foodPreferences']));
      }
      
      if (widget.initialData!['hobbies'] != null) {
        _selectedHobbies.addAll(List<String>.from(widget.initialData!['hobbies']));
      }
    }
  }

  Future<void> _pickProfilePhoto() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        _profilePhoto = FFUploadedFile(
          name: image.name,
          bytes: bytes,
        );
      });
    }
  }

  String? _validateInstagramLink(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    
    if (!value.startsWith('https://instagram.com/') && !value.startsWith('https://www.instagram.com/')) {
      return 'Please enter a valid Instagram URL (https://instagram.com/username)';
    }
    
    return null;
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      widget.onSave?.call(
        favoriteDestination: _favoriteDestinationController.text.trim(),
        tripType: _selectedTripType,
        foodPreferences: _selectedFoodPreferences,
        hobbies: _selectedHobbies,
        profilePhoto: _profilePhoto,
        instagramLink: _instagramController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            '✈️ Tell us about your travel preferences',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: FlutterFlowTheme.of(context).primaryText,
            ),
          ),
          const SizedBox(height: 24),

          // Profile Photo Upload
          _buildProfilePhotoSection(),
          const SizedBox(height: 24),

          // Favorite Destination
          _buildFavoriteDestinationField(),
          const SizedBox(height: 20),

          // Trip Type Dropdown
          _buildTripTypeDropdown(),
          const SizedBox(height: 20),

          // Food Preferences
          _buildFoodPreferencesSection(),
          const SizedBox(height: 20),

          // Hobbies/Interests
          _buildHobbiesSection(),
          const SizedBox(height: 20),

          // Instagram Link
          _buildInstagramField(),
          const SizedBox(height: 32),

          // Save Button
          Center(
            child: FFButtonWidget(
              onPressed: _handleSave,
              text: 'Save Preferences',
              options: FFButtonOptions(
                width: double.infinity,
                height: 50,
                padding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                color: const Color(0xFFD76B30),
                textStyle: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                elevation: 2,
                borderSide: const BorderSide(
                  color: Colors.transparent,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📸 Profile Photo (Optional)',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: FlutterFlowTheme.of(context).primaryText,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _pickProfilePhoto,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(60),
              border: Border.all(
                color: const Color(0xFFD76B30),
                width: 2,
              ),
            ),
            child: _profilePhoto != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(58),
                    child: Image.memory(
                      _profilePhoto!.bytes!,
                      width: 116,
                      height: 116,
                      fit: BoxFit.cover,
                    ),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo,
                        color: const Color(0xFFD76B30),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add Photo',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: const Color(0xFFD76B30),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildFavoriteDestinationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '✈️ Favorite Travel Destination',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: FlutterFlowTheme.of(context).primaryText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _favoriteDestinationController,
          decoration: InputDecoration(
            hintText: 'e.g., Bali, Paris, Tokyo...',
            hintStyle: GoogleFonts.poppins(
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
            filled: true,
            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: GoogleFonts.poppins(),
        ),
      ],
    );
  }

  Widget _buildTripTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🏖 Preferred Type of Trips',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: FlutterFlowTheme.of(context).primaryText,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedTripType,
          decoration: InputDecoration(
            filled: true,
            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          hint: Text(
            'Select your preferred trip type',
            style: GoogleFonts.poppins(
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
          ),
          items: _tripTypes.map((String type) {
            return DropdownMenuItem<String>(
              value: type,
              child: Text(
                type,
                style: GoogleFonts.poppins(),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedTripType = newValue;
            });
          },
        ),
      ],
    );
  }

  Widget _buildFoodPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🍴 Food Preferences (Select all that apply)',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: FlutterFlowTheme.of(context).primaryText,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _foodOptions.map((String option) {
            final isSelected = _selectedFoodPreferences.contains(option);
            return FilterChip(
              label: Text(
                option,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isSelected ? Colors.white : FlutterFlowTheme.of(context).primaryText,
                ),
              ),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedFoodPreferences.add(option);
                  } else {
                    _selectedFoodPreferences.remove(option);
                  }
                });
              },
              backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
              selectedColor: const Color(0xFFD76B30),
              checkmarkColor: Colors.white,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildHobbiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🎶 Hobbies/Interests (Select all that apply)',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: FlutterFlowTheme.of(context).primaryText,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _hobbyOptions.map((String option) {
            final isSelected = _selectedHobbies.contains(option);
            return FilterChip(
              label: Text(
                option,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: isSelected ? Colors.white : FlutterFlowTheme.of(context).primaryText,
                ),
              ),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    _selectedHobbies.add(option);
                  } else {
                    _selectedHobbies.remove(option);
                  }
                });
              },
              backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
              selectedColor: const Color(0xFFD76B30),
              checkmarkColor: Colors.white,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInstagramField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '📱 Instagram Link (Optional)',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: FlutterFlowTheme.of(context).primaryText,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _instagramController,
          validator: _validateInstagramLink,
          decoration: InputDecoration(
            hintText: 'https://instagram.com/yourusername',
            hintStyle: GoogleFonts.poppins(
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
            filled: true,
            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            prefixIcon: const Icon(
              Icons.link,
              color: Color(0xFFD76B30),
            ),
          ),
          style: GoogleFonts.poppins(),
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _favoriteDestinationController.dispose();
    _instagramController.dispose();
    super.dispose();
  }
}
