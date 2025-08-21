# Agency System Implementation Guide

## Overview
This document outlines the complete implementation of the agency system for TripBasket, including unique agency IDs, user connections, CSV upload capabilities, and enhanced dashboard functionality.

## 🏗️ **System Architecture**

### **1. Database Schema Updates**

#### **Agencies Collection (`agency`)**
- **`agency_id`**: Unique identifier (e.g., `AGY_1703123456789_1234`)
- **`name`**: Agency name
- **`description`**: Agency description
- **`logo`**: Agency logo URL
- **`contact_email`**: Primary contact email
- **`contact_phone`**: Primary contact phone
- **`website`**: Agency website URL
- **`location`**: Agency location
- **`rating`**: Average rating
- **`total_trips`**: Total number of trips
- **`created_at`**: Creation timestamp
- **`status`**: Agency status (active/inactive)

#### **Users Collection (`users`)**
- **`agency_reference`**: Reference to agency document
- **`role`**: User roles (can include 'agency', 'admin', etc.)

#### **Trips Collection (`trips`)**
- **`agency_reference`**: Reference to agency document
- **`title`**: Trip title
- **`price`**: Trip price
- **`location`**: Trip destination
- **`description`**: Trip description
- **`image`**: Trip image URL
- **`itinerary`**: List of itinerary items
- **`start_date`**: Trip start date
- **`end_date`**: Trip end date
- **`quantity`**: Total seats available
- **`available_seats`**: Remaining seats
- **`rating`**: Trip rating
- **`created_at`**: Creation timestamp
- **`modified_at`**: Last modification timestamp

## 🔧 **Key Features Implemented**

### **1. Unique Agency ID System**
- **Automatic Generation**: Unique IDs generated using timestamp + random number
- **Format**: `AGY_{timestamp}_{random}`
- **Example**: `AGY_1703123456789_1234`

### **2. Agency-User Connection**
- Users can be connected to agencies via `agency_reference` field
- Role-based access control (agency users get specific permissions)
- Seamless integration with existing authentication system

### **3. CSV Upload for Agencies**
- **Access Control**: Only agency users and admins can upload CSV files
- **Format**: 9-column CSV with trip data
- **Validation**: Comprehensive error handling and validation
- **Bulk Processing**: Upload multiple trips simultaneously

### **4. Enhanced Agency Dashboard**
- **Scrollable Interface**: Fixed scrolling issues with SingleChildScrollView
- **Consistent Color Theme**: Unified color scheme throughout
- **Advanced Filtering**: Search and filter trips by status
- **Quick Actions**: Easy access to common tasks
- **Statistics**: Real-time dashboard metrics

## 📁 **Files Created/Modified**

### **New Files**
- `lib/pages/agency_csv_upload/agency_csv_upload_widget.dart`
- `lib/pages/agency_csv_upload/agency_csv_upload_model.dart`
- `scripts/setup_agency_system.dart`
- `AGENCY_SYSTEM_IMPLEMENTATION.md`

### **Modified Files**
- `lib/backend/schema/agencies_record.dart` - Added `agency_id` field
- `lib/backend/schema/users_record.dart` - Added `agency_reference` field
- `lib/utils/agency_utils.dart` - Enhanced utility functions
- `lib/pages/agency_dashboard/agency_dashboard_widget.dart` - Fixed scrolling, added CSV upload

## 🚀 **Setup Instructions**

### **1. Database Setup**
```bash
# Run the agency setup script
dart run scripts/setup_agency_system.dart
```

### **2. Manual Agency Creation**
```dart
// Example: Create agency programmatically
final agencyRef = await createAgency(
  name: 'Your Agency Name',
  description: 'Agency description',
  contactEmail: 'contact@agency.com',
  contactPhone: '+1-555-0123',
  location: 'City, State',
);
```

### **3. Connect User to Agency**
```dart
// Example: Connect existing user to agency
await connectUserToAgency(
  userEmail: 'user@example.com',
  agencyRef: agencyRef,
  roles: ['agency'],
);
```

## 📊 **CSV Upload Format**

### **Required Columns (in order)**
1. **title** - Trip title
2. **price** - Trip price (number)
3. **location** - Trip destination
4. **description** - Trip description
5. **image_url** - Trip image URL
6. **itinerary** - Trip itinerary
7. **start_date** - Start date (YYYY-MM-DD)
8. **end_date** - End date (YYYY-MM-DD)
9. **quantity** - Number of seats (number)

### **Example CSV Content**
```csv
title,price,location,description,image_url,itinerary,start_date,end_date,quantity
Bali Adventure,1200,Bali,Explore beautiful Bali,https://example.com/bali.jpg,Day 1: Arrival,2024-03-01,2024-03-07,20
Tokyo Experience,1800,Tokyo,Discover Tokyo culture,https://example.com/tokyo.jpg,Day 1: City Tour,2024-04-01,2024-04-08,15
```

## 🔐 **Access Control**

### **CSV Upload Permissions**
- **Admin Users**: Full access to all features
- **Agency Users**: Can upload CSV files for their agency
- **Regular Users**: No access to CSV upload

### **Agency Dashboard Access**
- **Agency Users**: Full access to their agency dashboard
- **Admin Users**: Can view all agencies
- **Regular Users**: No access

## 🎨 **UI/UX Improvements**

### **Color Theme Consistency**
- **Primary Colors**: Consistent use of theme colors
- **Gradients**: Modern gradient backgrounds for cards
- **Shadows**: Subtle shadows for depth
- **Typography**: Google Fonts (Poppins + Inter)

### **Responsive Design**
- **Scrollable Interface**: Fixed dashboard scrolling issues
- **Grid Layout**: Responsive trip card grid
- **Mobile Optimized**: Touch-friendly interface elements

## 🧪 **Testing**

### **1. Agency Creation Test**
```dart
// Test agency creation
final agencyRef = await script.createAgency(
  name: 'Test Agency',
  description: 'Test Description',
  contactEmail: 'test@agency.com',
  contactPhone: '+1-555-9999',
  location: 'Test City',
);
```

### **2. User Connection Test**
```dart
// Test user connection
await script.connectUserToAgency(
  userEmail: 'test@user.com',
  agencyRef: agencyRef,
);
```

### **3. CSV Upload Test**
- Create a test CSV file with sample data
- Upload through the agency CSV upload interface
- Verify trips are created in the database

## 🔍 **Troubleshooting**

### **Common Issues**

#### **1. Agency Reference Not Found**
- **Cause**: User not properly connected to agency
- **Solution**: Run the agency setup script or manually connect user

#### **2. CSV Upload Permission Denied**
- **Cause**: User doesn't have agency role
- **Solution**: Ensure user has 'agency' role and agency reference

#### **3. Dashboard Not Loading**
- **Cause**: Agency reference mismatch
- **Solution**: Check user's agency_reference field

### **Debug Commands**
```dart
// List all agencies
await script.listAgencies();

// List agency users
await script.listAgencyUsers();

// Check current user's agency
final userDoc = currentUserDocument;
print('Agency Reference: ${userDoc?.agencyReference?.path}');
```

## 📈 **Future Enhancements**

### **Planned Features**
1. **Agency Analytics**: Detailed performance metrics
2. **Bulk Operations**: Mass trip updates/deletions
3. **Advanced Filtering**: Date range, price range filters
4. **Export Functionality**: Download trip data as CSV
5. **Multi-Agency Support**: Users can manage multiple agencies

### **API Endpoints**
- `POST /api/agencies` - Create agency
- `GET /api/agencies/{id}` - Get agency details
- `PUT /api/agencies/{id}` - Update agency
- `POST /api/agencies/{id}/trips/upload` - Upload CSV

## 📞 **Support**

For technical support or questions about the agency system:
1. Check this documentation first
2. Review the code comments
3. Run the setup script for testing
4. Contact the development team

---

**Last Updated**: December 2024
**Version**: 1.0.0
**Status**: Production Ready ✅
