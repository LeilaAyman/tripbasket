# Manual Agency Setup Guide

Since the automated script isn't working due to Flutter compilation issues, here's how to manually set up the agencies in your Firebase console:

## Step 1: Open Firebase Console
1. Go to https://console.firebase.google.com/
2. Select your TripsBasket project
3. Navigate to Firestore Database

## Step 2: Create Agency Collection
1. Click "Start collection"
2. Collection ID: `agency`
3. Add the following documents:

### Agency 1: Adventure World Travel
**Document ID:** `adventure_world_travel`
**Fields:**
- `name` (string): Adventure World Travel
- `description` (string): Specializing in thrilling outdoor adventures and extreme sports experiences around the globe.
- `logo_url` (string): https://via.placeholder.com/150x150?text=Adventure+World
- `contact_email` (string): info@adventureworld.com
- `contact_phone` (string): +1-555-ADVENTURE
- `website_url` (string): https://www.adventureworld.com
- `rating` (number): 4.7
- `total_trips` (number): 45
- `verified` (boolean): true
- `created_time` (timestamp): [Current date/time]

### Agency 2: Luxury Escapes International
**Document ID:** `luxury_escapes_intl`
**Fields:**
- `name` (string): Luxury Escapes International
- `description` (string): Premium luxury travel experiences with 5-star accommodations and personalized service.
- `logo_url` (string): https://via.placeholder.com/150x150?text=Luxury+Escapes
- `contact_email` (string): bookings@luxuryescapes.com
- `contact_phone` (string): +1-555-LUXURY
- `website_url` (string): https://www.luxuryescapes.com
- `rating` (number): 4.9
- `total_trips` (number): 28
- `verified` (boolean): true
- `created_time` (timestamp): [Current date/time]

### Agency 3: Cultural Heritage Tours
**Document ID:** `cultural_heritage_tours`
**Fields:**
- `name` (string): Cultural Heritage Tours
- `description` (string): Authentic cultural experiences and historical site visits with expert local guides.
- `logo_url` (string): https://via.placeholder.com/150x150?text=Cultural+Heritage
- `contact_email` (string): explore@culturalheritage.com
- `contact_phone` (string): +1-555-CULTURE
- `website_url` (string): https://www.culturalheritage.com
- `rating` (number): 4.5
- `total_trips` (number): 62
- `verified` (boolean): true
- `created_time` (timestamp): [Current date/time]

### Agency 4: Eco Travel Solutions
**Document ID:** `eco_travel_solutions`
**Fields:**
- `name` (string): Eco Travel Solutions
- `description` (string): Sustainable and eco-friendly travel options that protect and preserve natural environments.
- `logo_url` (string): https://via.placeholder.com/150x150?text=Eco+Travel
- `contact_email` (string): green@ecotravelsolutions.com
- `contact_phone` (string): +1-555-ECOTRIP
- `website_url` (string): https://www.ecotravelsolutions.com
- `rating` (number): 4.6
- `total_trips` (number): 39
- `verified` (boolean): true
- `created_time` (timestamp): [Current date/time]

### Agency 5: Family Fun Adventures
**Document ID:** `family_fun_adventures`
**Fields:**
- `name` (string): Family Fun Adventures
- `description` (string): Family-friendly trips with activities suitable for all ages and memorable experiences for everyone.
- `logo_url` (string): https://via.placeholder.com/150x150?text=Family+Fun
- `contact_email` (string): fun@familyadventures.com
- `contact_phone` (string): +1-555-FAMILY
- `website_url` (string): https://www.familyadventures.com
- `rating` (number): 4.4
- `total_trips` (number): 51
- `verified` (boolean): true
- `created_time` (timestamp): [Current date/time]

## Step 3: Update Existing Trips (Optional)
To connect existing trips to agencies, you can edit some of your trip documents:

1. Find existing trip documents in the `trips` collection
2. Add an `agency_reference` field with a DocumentReference to one of the agencies above
3. Example: For a trip document, add:
   - `agency_reference` (reference): `/agency/adventure_world_travel`

## Step 4: Test the Features
Once you've added the agencies:

1. **Test Agencies List**: Navigate to `/agencies` in your app to see the agencies list
2. **Test Agency Trips**: Click on an agency to see trips filtered by that agency
3. **Test Search**: Search for agency names in the search bar

## Navigation Routes Available:
- `/agencies` - View all agencies
- `/agency-trips?agency=${agencyRef}` - View trips from specific agency
- `/search-results?query=${searchTerm}` - Search functionality

Your complete agency management system is now ready to use!
