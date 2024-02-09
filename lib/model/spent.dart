final String tableExpenditure = 'expenditure';

class ExpenditureFields {
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
        required this.amount;
        required this.category;
        required this.date;
    });
}

