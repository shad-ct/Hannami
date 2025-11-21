class DiaryMoodData {
  final String key; // internal key stored in entry.mood
  final String emoji; // displayed emoji
  final String name; // short label
  final String description; // tooltip / long-press meaning
  const DiaryMoodData(this.key, this.emoji, this.name, this.description);
}

// Ordered list for display
const List<DiaryMoodData> diaryMoods = [
  DiaryMoodData('happy', '😀', 'Happy', 'Joyful – positive, cheerful mood'),
  DiaryMoodData('neutral', '🙂', 'Content', 'Neutral / Content – calm, okay, average mood'),
  DiaryMoodData('indifferent', '😐', 'Meh', 'Indifferent – neutral or unengaged mood'),
  DiaryMoodData('sad', '😔', 'Sad', 'Sad / Down – feeling low or upset'),
  DiaryMoodData('angry', '😡', 'Angry', 'Angry / Frustrated – irritation or strong negative mood'),
  DiaryMoodData('excited', '😍', 'Excited', 'Excited / Loving – high positive energy, affection'),
  DiaryMoodData('tired', '😴', 'Tired', 'Tired / Sleepy – low energy, exhausted mood'),
  DiaryMoodData('confused', '😕', 'Confused', 'Confused / Anxious – uncertain or worried mood'),
];

DiaryMoodData moodByKey(String key) {
  return diaryMoods.firstWhere(
    (m) => m.key == key,
    orElse: () => diaryMoods.firstWhere((m) => m.key == 'neutral'),
  );
}