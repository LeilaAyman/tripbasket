# Itinerary Data for Firebase Console

## For Japan Trip:
**Field name:** `itenarary`  
**Type:** Array  
**Values:**
```
[
  "Day 1: Arrival in Tokyo - Check into hotel in Shibuya + Evening at Tokyo Skytree",
  "Day 2: Traditional Tokyo - Senso-ji Temple + Asakusa district + Imperial Palace Gardens", 
  "Day 3: Modern Tokyo - Harajuku + Shibuya Crossing + Robot Restaurant show",
  "Day 4: Day trip to Mount Fuji - 5th Station + Lake Kawaguchi + Traditional onsen",
  "Day 5: Tech & Culture - TeamLab Digital Art Museum + Ginza shopping + Farewell dinner"
]
```

## For Paris Trip:
**Field name:** `itenarary`  
**Type:** Array  
**Values:**
```
[
  "Day 1: Arrival in Paris - Eiffel Tower visit + Seine river cruise + Welcome dinner",
  "Day 2: Art & Culture - Louvre Museum + Tuileries Garden + Champs-Élysées shopping",
  "Day 3: Royal Experience - Versailles Palace day trip + Gardens tour", 
  "Day 4: Montmartre Adventure - Sacré-Cœur + Artists' Quarter + Moulin Rouge show",
  "Day 5: Final Exploration - Notre-Dame area + Latin Quarter + Departure"
]
```

## Instructions:

### Option 1: Using Firebase Console (Easier)
1. Go to Firebase Console → Firestore Database
2. Find your trips collection
3. Open the Japan trip document
4. Add a new field called `itenarary` (type: array)
5. Add each day as a separate string in the array
6. Repeat for Paris trip

### Option 2: Using the Script
1. Run: `dart lib/update_trip_itineraries.dart`
2. The script will automatically find and update Japan and Paris trips

### Current Status:
- ✅ Dahab trip: Already has proper itinerary
- ❌ Japan trip: Empty itinerary array  
- ❌ Paris trip: No proper itinerary array

After adding these, all trips will have structured itinerary data!
