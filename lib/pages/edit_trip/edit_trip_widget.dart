import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/utils/agency_utils.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'edit_trip_model.dart';
export 'edit_trip_model.dart';

class EditTripWidget extends StatefulWidget {
  const EditTripWidget({
    super.key,
    required this.tripRef,
  });

  final DocumentReference? tripRef;

  static String routeName = 'edit_trip';
  static String routePath = '/edit-trip';

  @override
  State<EditTripWidget> createState() => _EditTripWidgetState();
}

class _EditTripWidgetState extends State<EditTripWidget> {
  late EditTripModel _model;
  TripsRecord? _trip;
  bool _isLoading = true;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => EditTripModel());
    _loadTrip();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadTrip() async {
    if (widget.tripRef == null) {
      _showErrorMessage('Trip reference is null');
      return;
    }

    try {
      final doc = await widget.tripRef!.get();
      if (doc.exists && doc.data() != null) {
        _trip = TripsRecord.fromSnapshot(doc);
        _initializeControllers();
      } else {
        _showErrorMessage('Trip not found');
      }
    } catch (e) {
      _showErrorMessage('Error loading trip: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _initializeControllers() {
    if (_trip == null) return;

    _model.titleController = TextEditingController(text: _trip!.title);
    _model.titleFocusNode = FocusNode();

    _model.locationController = TextEditingController(text: _trip!.location);
    _model.locationFocusNode = FocusNode();

    _model.priceController = TextEditingController(text: _trip!.price.toString());
    _model.priceFocusNode = FocusNode();

    _model.quantityController = TextEditingController(text: _trip!.quantity.toString());
    _model.quantityFocusNode = FocusNode();

    _model.descriptionController = TextEditingController(text: _trip!.description);
    _model.descriptionFocusNode = FocusNode();

    _model.imageController = TextEditingController(text: _trip!.image);
    _model.imageFocusNode = FocusNode();

    // Initialize itinerary controllers for each day
    _initializeItineraryControllers(_trip!.itenarary);

    _model.startDatePicked = _trip!.startDate;
    _model.endDatePicked = _trip!.endDate;
  }

  void _initializeItineraryControllers(List<String> days) {
    // Dispose existing controllers
    for (var controller in _model.itineraryControllers) {
      controller.dispose();
    }
    for (var focusNode in _model.itineraryFocusNodes) {
      focusNode.dispose();
    }
    
    // Create new controllers for each day
    _model.itineraryControllers = days.map((day) => TextEditingController(text: day)).toList();
    _model.itineraryFocusNodes = days.map((_) => FocusNode()).toList();
    
    // Ensure at least one day exists
    if (_model.itineraryControllers.isEmpty) {
      _addItineraryDay();
    }
  }

  void _addItineraryDay() {
    setState(() {
      _model.itineraryControllers.add(TextEditingController());
      _model.itineraryFocusNodes.add(FocusNode());
    });
  }

  void _removeItineraryDay(int index) {
    if (_model.itineraryControllers.length <= 1) {
      _showErrorMessage('At least one day is required');
      return;
    }
    
    setState(() {
      _model.itineraryControllers[index].dispose();
      _model.itineraryFocusNodes[index].dispose();
      _model.itineraryControllers.removeAt(index);
      _model.itineraryFocusNodes.removeAt(index);
    });
  }

  bool _canEditTrip() {
    if (_trip == null) return false;
    
    final isAdmin = _isCurrentUserAdmin();
    final agencyRef = AgencyUtils.getCurrentAgencyRef();
    
    return isAdmin || (_trip!.agencyReference == agencyRef);
  }

  bool _isCurrentUserAdmin() {
    final userDoc = currentUserDocument;
    if (userDoc == null) return false;
    final role = AgencyUtils.lc(userDoc.role.join(' '));
    return role.contains('admin');
  }

  Future<void> _updateTrip() async {
    if (!_model.formKey.currentState!.validate() || _trip == null) {
      return;
    }

    if (!_canEditTrip()) {
      _showErrorMessage('You do not have permission to edit this trip');
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

      final startDate = _model.startDatePicked ?? _trip!.startDate;
      final endDate = _model.endDatePicked ?? _trip!.endDate;

      if (endDate != null && startDate != null && endDate.isBefore(startDate)) {
        _showErrorMessage('End date must be after start date');
        return;
      }

      // Calculate available seats based on the quantity change
      final quantityDifference = quantity - _trip!.quantity;
      final newAvailableSeats = _trip!.availableSeats + quantityDifference;

      // Collect itinerary days
      final days = _model.itineraryControllers
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList();

      if (days.isEmpty) {
        _showErrorMessage('At least one itinerary day is required');
        return;
      }

      final updateData = {
        'title': _model.titleController!.text.trim(),
        'price': price,
        'location': _model.locationController!.text.trim(),
        'description': _model.descriptionController!.text.trim(),
        'image': _model.imageController!.text.trim(),
        'itenarary': days,
        'start_date': startDate,
        'end_date': endDate,
        'quantity': quantity,
        'available_seats': newAvailableSeats.clamp(0, quantity),
        'modified_at': DateTime.now(),
      };

      await widget.tripRef!.update(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Trip updated successfully!'),
            backgroundColor: FlutterFlowTheme.of(context).success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        context.pop();
      }
    } catch (e) {
      _showErrorMessage('Error updating trip: $e');
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD76B30)),
          ),
        ),
      );
    }

    if (_trip == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Trip Not Found'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text(
                'Trip Not Found',
                style: FlutterFlowTheme.of(context).headlineSmall,
              ),
              SizedBox(height: 8),
              Text(
                'The trip you are trying to edit could not be found.',
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

    if (!_canEditTrip()) {
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
                'Access Denied',
                style: FlutterFlowTheme.of(context).headlineSmall,
              ),
              SizedBox(height: 8),
              Text(
                'You do not have permission to edit this trip.',
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
        'Edit Trip',
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
                'Image URL',
                _model.imageController!,
                _model.imageFocusNode!,
                Icons.image,
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
                  onPressed: _model.isLoading ? null : _updateTrip,
                  text: _model.isLoading ? 'Updating...' : 'Update Trip',
                  icon: Icon(
                    _model.isLoading ? Icons.hourglass_empty : Icons.save,
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

  Widget _buildItinerarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Itinerary',
              style: FlutterFlowTheme.of(context).titleSmall.override(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: FlutterFlowTheme.of(context).primaryText,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Color(0xFFD76B30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: _addItineraryDay,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Add Day',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _model.itineraryControllers.length,
          itemBuilder: (context, index) {
            return Container(
              key: ValueKey('itinerary_day_$index'),
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(0xFFD76B30).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(0xFFD76B30).withOpacity(0.1),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Day ${index + 1}',
                          style: FlutterFlowTheme.of(context).titleSmall.override(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFD76B30),
                          ),
                        ),
                        if (_model.itineraryControllers.length > 1)
                          InkWell(
                            borderRadius: BorderRadius.circular(4),
                            onTap: () => _removeItineraryDay(index),
                            child: Padding(
                              padding: EdgeInsets.all(4),
                              child: Icon(
                                Icons.close,
                                color: Colors.red,
                                size: 16,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: TextFormField(
                      controller: _model.itineraryControllers[index],
                      focusNode: _model.itineraryFocusNodes[index],
                      obscureText: false,
                      maxLines: null,
                      minLines: 2,
                      decoration: InputDecoration(
                        hintText: 'Enter activities for Day ${index + 1}',
                        hintStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                          color: FlutterFlowTheme.of(context).secondaryText,
                          fontSize: 14,
                        ),
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
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
}