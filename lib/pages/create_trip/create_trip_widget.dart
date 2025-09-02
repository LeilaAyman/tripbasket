import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/utils/agency_utils.dart';
import '/components/image_upload_widget.dart';
import '/components/multiple_image_upload_widget.dart';
import '/components/pdf_upload_widget.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'create_trip_model.dart';
export 'create_trip_model.dart';

class CreateTripWidget extends StatefulWidget {
  const CreateTripWidget({super.key});

  static String routeName = 'create_trip';
  static String routePath = '/create-trip';

  @override
  State<CreateTripWidget> createState() => _CreateTripWidgetState();
}

class _CreateTripWidgetState extends State<CreateTripWidget> {
  late CreateTripModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  String? _uploadedImageUrl;
  List<String> _galleryImages = [];
  String? _uploadedPdfUrl;
  late final String _tripId;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CreateTripModel());
    _tripId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    _model.titleController ??= TextEditingController();
    _model.titleFocusNode ??= FocusNode();

    _model.locationController ??= TextEditingController();
    _model.locationFocusNode ??= FocusNode();

    _model.priceController ??= TextEditingController();
    _model.priceFocusNode ??= FocusNode();

    _model.quantityController ??= TextEditingController();
    _model.quantityFocusNode ??= FocusNode();

    _model.descriptionController ??= TextEditingController();
    _model.descriptionFocusNode ??= FocusNode();

    _model.specificationsController ??= TextEditingController();
    _model.specificationsFocusNode ??= FocusNode();

    _model.itineraryController ??= TextEditingController();
    _model.itineraryFocusNode ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  bool _canCreateTrip() {
    return AgencyUtils.isCurrentUserAgency() || _isCurrentUserAdmin();
  }

  bool _isCurrentUserAdmin() {
    final userDoc = currentUserDocument;
    if (userDoc == null) return false;
    final role = AgencyUtils.lc(userDoc.role.join(' '));
    return role.contains('admin');
  }

  Future<void> _createTrip() async {
    if (!_model.formKey.currentState!.validate()) {
      return;
    }

    // Validate image upload
    if (_uploadedImageUrl == null || _uploadedImageUrl!.isEmpty) {
      _showErrorMessage('Please upload a trip image');
      return;
    }

    final agencyRef = AgencyUtils.getCurrentAgencyRef();
    if (!_isCurrentUserAdmin() && agencyRef == null) {
      _showErrorMessage('Agency reference not found. Please contact support.');
      return;
    }

    setState(() {
      _model.isLoading = true;
    });

    try {
      final price = int.tryParse(_model.priceController!.text.trim()) ?? 0;
      final quantity = int.tryParse(_model.quantityController!.text.trim()) ?? 1;

      if (price <= 0) {
        _showErrorMessage('Price must be greater than 0');
        return;
      }

      if (quantity <= 0) {
        _showErrorMessage('Quantity must be greater than 0');
        return;
      }

      final startDate = _model.startDatePicked ?? DateTime.now().add(Duration(days: 7));
      final endDate = _model.endDatePicked ?? DateTime.now().add(Duration(days: 14));

      if (endDate.isBefore(startDate)) {
        _showErrorMessage('End date must be after start date');
        return;
      }

      final tripData = createTripsRecordData(
        title: _model.titleController!.text.trim(),
        price: price,
        location: _model.locationController!.text.trim(),
        description: _model.descriptionController!.text.trim(),
        specifications: _model.specificationsController!.text.trim(),
        image: _uploadedImageUrl ?? '',
        gallery: _galleryImages,
        itenarary: _model.itineraryControllers.map((controller) => controller.text.trim()).where((text) => text.isNotEmpty).toList(),
        startDate: startDate,
        endDate: endDate,
        quantity: quantity,
        availableSeats: quantity,
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
        agencyReference: agencyRef,
        rating: 0.0,
        itineraryPdf: _uploadedPdfUrl,
      );

      await FirebaseFirestore.instance.collection('trips').add(tripData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trip created successfully!'),
            backgroundColor: FlutterFlowTheme.of(context).success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      _showErrorMessage('Error creating trip: $e');
    } finally {
      if (mounted) {
        setState(() {
          _model.isLoading = false;
        });
      }
    }
  }

  void _showErrorMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: FlutterFlowTheme.of(context).error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_canCreateTrip()) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Access Denied'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.block, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Agency Access Required',
                style: FlutterFlowTheme.of(context).headlineSmall,
              ),
              SizedBox(height: 8),
              Text(
                'You need agency privileges to create trips.',
                style: FlutterFlowTheme.of(context).bodyMedium,
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _model.unfocusNode.canRequestFocus
          ? FocusScope.of(context).requestFocus(_model.unfocusNode)
          : FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Color(0xFFD76B30),
      automaticallyImplyLeading: false,
      elevation: 0,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFD76B30),
              Color(0xFFDBA237),
            ],
          ),
        ),
      ),
      leading: Container(
        margin: EdgeInsets.only(left: 16),
        child: FlutterFlowIconButton(
          borderColor: Colors.white.withOpacity(0.2),
          borderRadius: 12,
          borderWidth: 1,
          buttonSize: 48,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 24,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      title: Text(
        'Create New Trip',
        style: FlutterFlowTheme.of(context).headlineMedium.override(
          color: Colors.white,
          fontSize: 24,
          letterSpacing: 0.5,
          fontWeight: FontWeight.w700,
        ),
      ),
      centerTitle: false,
    );
  }

  Widget _buildBody() {
    return SafeArea(
      top: true,
      child: Form(
        key: _model.formKey,
        autovalidateMode: AutovalidateMode.disabled,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormField(
                'Trip Title',
                _model.titleController!,
                _model.titleFocusNode!,
                Icons.flight_takeoff,
                validator: (value) => value?.isEmpty == true ? 'Please enter a trip title' : null,
              ),
              SizedBox(height: 16),
              _buildFormField(
                'Location',
                _model.locationController!,
                _model.locationFocusNode!,
                Icons.location_on,
                validator: (value) => value?.isEmpty == true ? 'Please enter a location' : null,
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildFormField(
                      'Price (\$)',
                      _model.priceController!,
                      _model.priceFocusNode!,
                      Icons.attach_money,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty == true) return 'Enter price';
                        final price = int.tryParse(value!);
                        if (price == null || price <= 0) return 'Invalid price';
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildFormField(
                      'Quantity',
                      _model.quantityController!,
                      _model.quantityFocusNode!,
                      Icons.people,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value?.isEmpty == true) return 'Enter quantity';
                        final qty = int.tryParse(value!);
                        if (qty == null || qty <= 0) return 'Invalid quantity';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              _buildFormField(
                'Description',
                _model.descriptionController!,
                _model.descriptionFocusNode!,
                Icons.description,
                maxLines: 3,
                validator: (value) => value?.isEmpty == true ? 'Please enter a description' : null,
              ),
              SizedBox(height: 16),
              _buildFormField(
                'What\'s Included',
                _model.specificationsController!,
                _model.specificationsFocusNode!,
                Icons.check_circle_outline,
                maxLines: 3,
                validator: null, // Optional field
              ),
              SizedBox(height: 16),
              ImageUploadWidget(
                agencyId: AgencyUtils.getCurrentAgencyRef()?.id ?? 'unknown',
                tripId: _tripId,
                onImageUploaded: (url) {
                  setState(() {
                    _uploadedImageUrl = url;
                  });
                },
                label: 'Trip Image',
                isRequired: true,
              ),
              SizedBox(height: 16),
              MultipleImageUploadWidget(
                agencyId: AgencyUtils.getCurrentAgencyRef()?.id ?? 'unknown',
                tripId: _tripId,
                onImagesUploaded: (urls) {
                  setState(() {
                    _galleryImages = urls;
                  });
                },
                label: 'Additional Photos (Optional)',
                initialImageUrls: _galleryImages,
              ),
              SizedBox(height: 16),
              PdfUploadWidget(
                agencyId: AgencyUtils.getCurrentAgencyRef()?.id ?? 'unknown',
                tripId: _tripId,
                onPdfUploaded: (url) {
                  setState(() {
                    _uploadedPdfUrl = url;
                  });
                },
                label: 'Trip Itinerary PDF',
                isRequired: false,
              ),
              SizedBox(height: 16),
              _buildItinerarySection(),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildDatePicker(
                      'Start Date',
                      _model.startDatePicked,
                      (date) => setState(() => _model.startDatePicked = date),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildDatePicker(
                      'End Date',
                      _model.endDatePicked,
                      (date) => setState(() => _model.endDatePicked = date),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),
              Container(
                width: double.infinity,
                child: FFButtonWidget(
                  onPressed: _model.isLoading ? null : _createTrip,
                  text: _model.isLoading ? 'Creating...' : 'Create Trip',
                  icon: Icon(
                    _model.isLoading ? Icons.hourglass_empty : Icons.add,
                    size: 24,
                  ),
                  options: FFButtonOptions(
                    height: 56,
                    color: Color(0xFFD76B30),
                    textStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    elevation: 4,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField(
    String label,
    TextEditingController controller,
    FocusNode focusNode,
    IconData icon, {
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FlutterFlowTheme.of(context).titleSmall.override(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: FlutterFlowTheme.of(context).primaryText,
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Color(0xFFD76B30).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            obscureText: false,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: Color(0xFFD76B30),
                size: 24,
              ),
              hintText: 'Enter $label',
              hintStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                color: FlutterFlowTheme.of(context).secondaryText,
                fontSize: 16,
              ),
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
            ),
            style: FlutterFlowTheme.of(context).bodyLarge.override(
              fontSize: 16,
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime? selectedDate,
    Function(DateTime) onDateSelected,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: FlutterFlowTheme.of(context).titleSmall.override(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: FlutterFlowTheme.of(context).primaryText,
          ),
        ),
        SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime.now().add(Duration(days: 7)),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(Duration(days: 365)),
            );
            if (date != null) {
              onDateSelected(date);
            }
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Color(0xFFD76B30).withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: Color(0xFFD76B30),
                  size: 20,
                ),
                SizedBox(width: 12),
                Text(
                  selectedDate != null
                      ? DateFormat('MMM dd, yyyy').format(selectedDate)
                      : 'Select $label',
                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                    fontSize: 16,
                    color: selectedDate != null
                        ? FlutterFlowTheme.of(context).primaryText
                        : FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildItinerarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Itinerary',
              style: FlutterFlowTheme.of(context).titleMedium.override(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: FlutterFlowTheme.of(context).primaryText,
              ),
            ),
            TextButton.icon(
              onPressed: _addItineraryDay,
              icon: Icon(Icons.add, size: 18, color: Color(0xFFD76B30)),
              label: Text(
                'Add Day',
                style: TextStyle(color: Color(0xFFD76B30), fontSize: 14),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        if (_model.itineraryControllers.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: FlutterFlowTheme.of(context).alternate,
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: FlutterFlowTheme.of(context).secondaryText,
                  size: 32,
                ),
                SizedBox(height: 8),
                Text(
                  'No itinerary days added yet',
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                    color: FlutterFlowTheme.of(context).secondaryText,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Tap "Add Day" to create your first itinerary day',
                  style: FlutterFlowTheme.of(context).bodySmall.override(
                    color: FlutterFlowTheme.of(context).secondaryText,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          )
        else
          ...List.generate(_model.itineraryControllers.length, (index) {
            return Container(
              margin: EdgeInsets.only(bottom: 12),
              child: _buildItineraryDayCard(index),
            );
          }),
      ],
    );
  }

  Widget _buildItineraryDayCard(int index) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: FlutterFlowTheme.of(context).alternate,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFFD76B30),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Day ${index + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _removeItineraryDay(index),
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20,
                ),
                padding: EdgeInsets.all(4),
                constraints: BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          SizedBox(height: 12),
          TextFormField(
            controller: _model.itineraryControllers[index],
            focusNode: _model.itineraryFocusNodes[index],
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Describe activities for Day ${index + 1}...',
              hintStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                color: FlutterFlowTheme.of(context).secondaryText,
                fontSize: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: FlutterFlowTheme.of(context).alternate,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Color(0xFFD76B30),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.all(12),
            ),
            style: FlutterFlowTheme.of(context).bodyLarge.override(
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _addItineraryDay() {
    setState(() {
      _model.itineraryControllers.add(TextEditingController());
      _model.itineraryFocusNodes.add(FocusNode());
    });
  }

  void _removeItineraryDay(int index) {
    setState(() {
      _model.itineraryControllers[index].dispose();
      _model.itineraryFocusNodes[index].dispose();
      _model.itineraryControllers.removeAt(index);
      _model.itineraryFocusNodes.removeAt(index);
    });
  }
}