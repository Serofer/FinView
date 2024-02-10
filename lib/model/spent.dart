final String tableExpenditure = 'expenditure';

class ExpenditureFields {
  static final List<String> values = [
    //Add all fields
    id, amount, category, date
  ];

  static final String id = '_id';
  static final String amount = 'amount';
  static final String category = 'category';
  static final String date = 'date';
}

class Expenditure {
  final int? id;
  final double amount;
  final String category;
  final DateTime date;

  const Expenditure({
    this.id,
    required this.amount,
    required this.category,
    required this.date,
  });

  Expenditure copy({
    int? id,
    double? amount,
    String? category,
    DateTime? date,
  }) =>
      Expenditure(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        date: date ?? this.date,
      );

  static Expenditure fromJson(Map<String, Object?> json) => Expenditure(
        id: json[ExpenditureFields.id] as int?,
        amount: json[ExpenditureFields.amount] as double,
        category: json[ExpenditureFields.category] as String,
        date: DateTime.parse(json[ExpenditureFields.date] as String),
      );

  Map<String, Object?> toJson() => {
        ExpenditureFields.id: id,
        ExpenditureFields.amount: amount,
        ExpenditureFields.category: category,
        ExpenditureFields.date: date.toIso8601String(),
      };
}
