/// Model for technical reference sections
/// Used to store structured reference content that can be displayed in accordion-style UI
class ReferenceSection {
  final String title;
  final List<String> bulletPoints;
  final String? disclaimer;

  const ReferenceSection({
    required this.title,
    required this.bulletPoints,
    this.disclaimer,
  });
}
