class Task {
  final int? id;
  final String name;
  final String description;
  final int period;
  final bool archive;

  final DateTime? completedAt;


  Task({
    this.id,
    required this.name,
    required this.description,
    required this.period,
    required this.archive,

    this.completedAt,

  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'period': period,
      'archive': archive ? 1 : 0,
    };
  }
}