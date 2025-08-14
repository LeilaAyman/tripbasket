# Admin CSV Upload Functionality

## Overview
The admin CSV upload functionality allows users with admin privileges to bulk upload trip data to the Firebase Firestore database using CSV files.

## Features
- **Role-based Access Control**: Only users with 'admin' role can access the upload functionality
- **CSV File Parsing**: Supports standard CSV format with custom field mapping
- **Batch Upload**: Processes multiple trips from a single CSV file
- **Real-time Progress**: Shows upload progress and status updates
- **Error Handling**: Provides detailed error reporting for failed uploads
- **Data Validation**: Validates CSV structure and data types

## Access Requirements
1. User must be authenticated
2. User role must include 'admin' in their role array
3. Access via Profile page → "Upload Trips (CSV)" option

## CSV Format
The CSV file must contain the following columns in order:
1. **title** - Trip name/title (string)
2. **price** - Trip price in USD (number)
3. **location** - Trip location (string)
4. **description** - Trip description (string)
5. **image** - Image URL (string)

### Example CSV Structure:
```csv
title,price,location,description,image
Bali Adventure,1500,Bali Indonesia,Explore the beautiful beaches and temples,https://example.com/bali.jpg
Tokyo City Tour,2000,Tokyo Japan,Discover modern culture and traditions,https://example.com/tokyo.jpg
```

## How to Use
1. **Access Admin Panel**: 
   - Navigate to Profile page
   - Admin users will see a red "Admin" section
   - Click "Upload Trips (CSV)"

2. **Prepare CSV File**:
   - Create CSV file with required columns
   - Use the provided `sample_trips.csv` as template
   - Ensure image URLs are valid and accessible

3. **Upload Process**:
   - Click "Choose File" button
   - Select your CSV file
   - Wait for processing (progress shown)
   - Review upload results

## Database Schema
Each trip is stored in Firestore with the following fields:
- `title` (string): Trip title
- `price` (number): Price in USD
- `location` (string): Trip location
- `description` (string): Trip description
- `image` (string): Image URL
- `created_at` (timestamp): Upload timestamp

## Error Handling
The system handles various error scenarios:
- **Invalid CSV format**: Missing columns or malformed data
- **Data type errors**: Invalid price values or empty required fields
- **Firebase errors**: Network issues or permission problems
- **File errors**: Corrupt files or unsupported formats

## Security Features
- **Authentication Required**: Must be logged in
- **Role Verification**: Admin role checked on both client and server
- **Input Validation**: CSV data validated before database writes
- **Error Logging**: Detailed error messages for troubleshooting

## Implementation Details

### Files Created/Modified:
1. `lib/pages/admin_upload/admin_upload_widget.dart` - Main upload interface
2. `lib/pages/admin_upload/admin_upload_model.dart` - Widget state management
3. `lib/pages/profile/profile_widget.dart` - Added admin section
4. `lib/index.dart` - Added admin widget export
5. `lib/flutter_flow/nav/nav.dart` - Added routing
6. `pubspec.yaml` - Added file_picker and csv dependencies
7. `sample_trips.csv` - Example CSV file

### Dependencies Added:
- `file_picker: ^8.0.0+1` - File selection functionality
- `csv: ^6.0.0` - CSV parsing and processing

### Key Functions:
- `_pickAndProcessCSV()` - File selection and initial processing
- `_processCSVData()` - CSV parsing and validation
- `_addTripToFirestore()` - Database write operations
- `isAdmin` getter - Role verification

## Testing
1. **Create Test User**: Ensure user has 'admin' in role array
2. **Prepare Test CSV**: Use provided sample_trips.csv
3. **Test Upload**: Follow upload process and verify database
4. **Verify Data**: Check Firestore console for new trip documents

## Troubleshooting

### Common Issues:
1. **Access Denied**: User doesn't have admin role
2. **CSV Format Error**: Check column order and data types
3. **Upload Fails**: Check Firebase permissions and network
4. **Image Issues**: Verify image URLs are valid and accessible

### Debug Tips:
- Check browser console for detailed error messages
- Verify user role in Firebase Authentication console
- Test CSV format with sample file first
- Ensure Firebase rules allow admin writes

## Future Enhancements
- **Image Upload**: Direct image upload instead of URLs
- **Bulk Edit**: Edit existing trips via CSV
- **Data Export**: Export current trips to CSV
- **Template Generator**: Create CSV templates from existing data
- **Preview Mode**: Preview trips before final upload
- **Rollback**: Undo recent uploads

## Maintenance
- **Regular Backups**: Backup Firestore data before bulk operations
- **Role Management**: Regularly audit admin user roles
- **Error Monitoring**: Monitor upload errors and patterns
- **Performance**: Consider pagination for large CSV files
