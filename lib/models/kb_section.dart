/// Model for Knowledge Base section with expandable content
class KbSection {
  final String id;
  final String title;
  final List<String> bullets;
  final List<KbLinkAction>? actions;

  const KbSection({
    required this.id,
    required this.title,
    required this.bullets,
    this.actions,
  });
}

/// Model for linking KB sections to calculator tools
class KbLinkAction {
  final String label;
  final String route;

  const KbLinkAction({
    required this.label,
    required this.route,
  });
}
