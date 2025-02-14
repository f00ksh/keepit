import 'package:uuid/uuid.dart';
import '../../domain/models/note.dart';

class NotesSeeder {
  static final List<Map<String, String>> _noteContents = [
    {
      "title": "Recipe: Chocolate Cake",
      "content":
          "Ingredients:\n- 2 cups flour\n- 2 cups sugar\n- 3/4 cup cocoa powder\n- 2 eggs\n- 1 cup milk\n- 1/2 cup vegetable oil\nInstructions: Mix dry ingredients...",
    },
    {
      "title": "Meeting Notes: Project Launch",
      "content":
          "Date: Feb 13, 2025\nAttendees: Sarah, Mike, John\nKey points:\n- Launch date set for March 1st\n- Budget approved\n- Marketing strategy review pending",
    },
    {
      "title": "Book Recommendations",
      "content":
          "1. The Midnight Library\n2. Project Hail Mary\n3. Atomic Habits\n4. The Psychology of Money\n5. The Thursday Murder Club",
    },
    {
      "title": "Workout Routine",
      "content":
          "Monday: Chest & Triceps\nTuesday: Back & Biceps\nWednesday: Legs\nThursday: Shoulders\nFriday: Full body HIIT\nWeekend: Rest",
    },
    {
      "title": "Travel Checklist: Paris",
      "content":
          "Documents:\n- Passport\n- Tickets\n- Hotel booking\n- Insurance\n\nPacking:\n- Clothes\n- Toiletries\n- Camera\n- Adapters",
    },
    {
      "title": "Learning Flutter: Tips",
      "content":
          "1. Master widgets\n2. Understand state management\n3. Learn about providers\n4. Practice with small projects\n5. Read documentation",
    },
    {
      "title": "Garden Planning",
      "content":
          "Spring planting:\n- Tomatoes\n- Basil\n- Peppers\n- Cucumbers\n\nMaintenance schedule:\n- Water daily\n- Fertilize monthly",
    },
    {
      "title": "Movie Watchlist",
      "content":
          "To watch:\n1. Inception\n2. The Grand Budapest Hotel\n3. Everything Everywhere All at Once\n4. The Shawshank Redemption\n5. Parasite",
    },
    {
      "title": "Home Improvement Ideas",
      "content":
          "Kitchen:\n- New cabinets\n- Island renovation\n\nLiving Room:\n- Paint walls\n- New lighting\n\nBathroom:\n- Retile shower\n- Update fixtures",
    },
    {
      "title": "Language Learning Goals",
      "content":
          "Spanish:\n- 30 minutes daily practice\n- Watch Spanish movies\n- Use language learning apps\n- Find conversation partner",
    },
    {
      "title": "Project Deadlines",
      "content":
          "Frontend:\n- UI design: March 1\n- Implementation: March 15\n- Testing: March 20\n\nBackend:\n- API development: March 10\n- Database setup: March 5",
    },
    {
      "title": "Shopping List",
      "content":
          "Groceries:\n- Fruits\n- Vegetables\n- Milk\n- Bread\n- Eggs\n\nHousehold:\n- Paper towels\n- Soap\n- Detergent",
    },
    {
      "title": "Birthday Party Planning",
      "content":
          "Guest list:\n- Family members\n- Close friends\n- Colleagues\n\nTo-do:\n- Order cake\n- Decorations\n- Send invitations\n- Plan menu",
    },
    {
      "title": "Financial Goals 2025",
      "content":
          "1. Build emergency fund\n2. Invest in index funds\n3. Reduce unnecessary expenses\n4. Start retirement planning\n5. Create budget spreadsheet",
    },
    {
      "title": "Coding Resources",
      "content":
          "Websites:\n- Stack Overflow\n- GitHub\n- Medium\n- Dev.to\n\nYouTube channels:\n- Traversy Media\n- Fireship\n- Flutter",
    },
    {
      "title": "Health Goals",
      "content":
          "Daily:\n- 8 hours sleep\n- 2L water\n- 10k steps\n\nWeekly:\n- 3x exercise\n- Meal prep\n- Meditation",
    },
    {
      "title": "Music Practice Schedule",
      "content":
          "Monday: Scales\nTuesday: New piece\nWednesday: Theory\nThursday: Technique\nFriday: Review\nWeekend: Free practice",
    },
    {
      "title": "Home Network Setup",
      "content":
          "Equipment:\n- Router\n- Switch\n- Access points\n\nConfiguration:\n- SSID setup\n- Security settings\n- Guest network",
    },
    {
      "title": "Art Projects",
      "content":
          "Current:\n- Oil painting landscape\n- Digital portrait\n\nPlanned:\n- Watercolor series\n- Sculpture experiment",
    },
    {
      "title": "Meditation Notes",
      "content":
          "Morning routine:\n1. 5 minutes breathing\n2. Body scan\n3. Mindful observation\n\nEvening:\n1. Gratitude practice\n2. Reflection",
    },
  ];

  static List<Note> generateInitialNotes() {
    final uuid = Uuid();
    final now = DateTime.now();

    return _noteContents.asMap().entries.map((entry) {
      final index = entry.key;
      final noteData = entry.value;

      return Note(
        id: uuid.v4(),
        title: noteData["title"]!,
        content: noteData["content"]!,
        colorIndex: index % 6, // Rotating through 6 colors
        createdAt: now.subtract(Duration(days: index)),
        updatedAt: now.subtract(Duration(hours: index)),
        index: index,
      );
    }).toList();
  }
}
