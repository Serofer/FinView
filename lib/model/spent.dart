import 'package:flutter/material.dart';
import 'package:sqlfite/sqflite.dart';

const String tableExpenditure = 'expenditure';

class ExpenditureFields {
  static final List<String> values = [
    //Add all fields
    id, amount, category, date
  ];

  static const String id = '_id';
  static const String amount = 'amount';
  static const String category = 'category';
  static const String date = 'date';
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

  factory Expenditure.fromMap(Map<String, dynamic> json) => new Expenditure(
    id: json['id'],
    amount: json['amount'],
    category: json['category'],
    date: json['date'],
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'date': date,
    };
  }
}
