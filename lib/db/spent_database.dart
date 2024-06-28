import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:fin_view/model/spent.dart';
import 'package:fin_view/charts/data/bar_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fin_view/charts/data/table_data.dart';
import 'package:fin_view/user_data/timeframe_manager.dart';

//import 'package:fin_view/charts/data/table_data.dart';

class SpentDatabase {
  static final SpentDatabase instance = SpentDatabase._init();

  static Database? _database;

  SpentDatabase._init();

  //Beginning of database functions

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('expenditure.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    //https://dart.dev/codelabs/async-await
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const doubleType = 'DECIMAL(10, 2) NOT NULL';
    const textType = 'TEXT NOT NULL';
    const dateType = 'DATE'; //format: YYY-MM-DD

    await db.execute('''
            CREATE TABLE $tableExpenditure (
                ${ExpenditureFields.id} $idType,
                ${ExpenditureFields.amount} $doubleType,
                ${ExpenditureFields.category} $textType,
                ${ExpenditureFields.date} $dateType
            )
        ''');
  }

  Future<Expenditure> create(Expenditure expenditure) async {
    final db = await instance.database;

    final id = await db.insert(tableExpenditure, expenditure.toJson());
    return expenditure.copy(id: id);
  }

  Future<Expenditure> readExpenditure(int id) async {
    final db = await instance.database;

    final maps = await db.query(
      tableExpenditure,
      columns: ExpenditureFields.values,
      where: '${ExpenditureFields.id} = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Expenditure.fromJson(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Expenditure>> readAllExpenditure() async {
    final db = await instance.database;

    //final result = await db.query(
    //  'SELECT * FROM $tableExpenditure ORDER BY ${ExpenditureFields.date} ASC');

    final result = await db.query(tableExpenditure,
        orderBy: '${ExpenditureFields.date} DESC');

    return result.map((json) => Expenditure.fromJson(json)).toList();
  }

  

  Future<int> update(Expenditure expenditure) async {
    final db = await instance.database;

    return db.update(
      tableExpenditure,
      expenditure.toJson(),
      where: '${ExpenditureFields.id} = ?',
      whereArgs: [expenditure.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      tableExpenditure,
      where: '${ExpenditureFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAll() async {
    final db = await instance.database;

    return await db.delete(tableExpenditure);
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }

//calculate percentages
//has to access the selected timeframe, during IFASS
  Future<List<dynamic>> calculatePercentages(String? timeframe) async {
    final db = await instance.database;

    List categories = ['Food', 'Event', 'Education', 'Other'];
    List percentages = [];
    dynamic sumAmount;
    double spentCat = 0.0;
    late List spentOnCat;
    late DateTime timefilter;
    late DateTime timeborder;
   

    //expenses = await SpentDatabase.instance.readAllExpenditure();
    //spentOnCat = await db.rawQuery("SELECT SUM(amount) FROM expenditure");----------------------------------------------------------------changed
    //List result = await db.rawQuery("SELECT amount, category FROM expenditure");

    //Map<String, dynamic> timeData = getTimeData(timeframe);

    switch (timeframe) {
      case 'Last 7 Days':
        // Get data from the last seven days
        timefilter = DateTime.now()
            .subtract(const Duration(days: 8))
            .subtract(const Duration(seconds: 1));
        timeborder = DateTime.now();
        break;
      case 'Last 30 Days':
        // Get data from the last thirty days
        timefilter = DateTime.now()
            .subtract(const Duration(days: 30))
            .subtract(const Duration(seconds: 1));
        timeborder = DateTime.now();

        break;
      case 'This Month':
        // Get data for the current month
        int currentYear = DateTime.now().year;
        int currentMonth = DateTime.now().month;

        String timefilterString =
            '$currentYear-${currentMonth.toString().padLeft(2, '0')}-01';
        timefilter = DateTime.parse(timefilterString);
        //print("timefilter: $timefilter");

        String timeborderString = '${DateTime.now().year.toString().padLeft(4, '0')}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day.toString().padLeft(2, '0')}T23:59:59';
        timeborder = DateTime.parse(timeborderString);
        //print("timeborder: $timeborder");
        

        break;
      case 'This Year':
        // Get data for the current year
        int currentYear = DateTime.now().year;
        int selectedYear = currentYear - 1;
        String timefilterString = '$selectedYear-12-31 23:59:59';
        timefilter = DateTime.parse(timefilterString);
        String timeborderString = '$currentYear-12-31';
        timeborder = DateTime.parse(timeborderString);

        break;
      case 'All Time':
        // Get all data
        DateTime now = DateTime.now();
        timefilter = DateTime(now.year - 100, now.month, now.day);
        timeborder = DateTime(now.year + 100, now.month, now.day);

        break;
      default:
        // Invalid timeframe
        throw ArgumentError('Invalid timeframe: $timeframe');
    }

    for (int i = 0; i < categories.length; i++) {
      
      
      spentOnCat = await db.rawQuery(
          "SELECT SUM(amount) FROM expenditure WHERE category = '${categories[i]}' AND date >= ? AND date <= ?",
          [timefilter.toIso8601String(), timeborder.toIso8601String()]);
      
      

      //List<dynamic> spentOnCat =
      //await SpentDatabase.instance.readCategory(categories[i]);
      sumAmount = spentOnCat[0]['SUM(amount)'] ?? 0.0;

      //convert always to double:
      if (sumAmount is int) {
        spentCat = sumAmount.toDouble();
      } else {
        spentCat = sumAmount;
      }
      //List countAll = await SpentDatabase.instance.readAmount();
      final List countAll = await db.rawQuery(
          "SELECT SUM(amount) FROM expenditure WHERE date >= ? AND date <= ?",
          [timefilter.toIso8601String(), timeborder.toIso8601String()]);

      double? totalAmount = countAll[0]['SUM(amount)'] is int
          ? (countAll[0]['SUM(amount)'] as int).toDouble()
          : countAll[0]['SUM(amount)'];
      //print(totalAmount);
      double totAmount = totalAmount ?? 0.0;
      double toAdd = (spentCat / totAmount) * 100;
      String percent = toAdd.toStringAsFixed(2);
      double percentNum = double.parse(percent);
      percentages.add(percentNum);
    }

    //print(percentages);

    return percentages;
  }

  Future<dynamic> queryForBar(String? timeframe, bool bar) async {
    late int dataPerSection;
    List categories = ['Food', 'Event', 'Education', 'Other'];
    List categoriesExtra = categories.toList();
    categoriesExtra.add('Total');
    List totalCategoryValues = List.generate(categories.length, (index) => 0.0);

    Map<String, dynamic> labeling = {
      'Last 30 Days': 'Week',
      'This Month': 'Week',
      'Last 7 Days': 'Day',
      'This Year': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'],
      'All Time': ['Jan-Feb', 'Mar-Apr', 'May-Jun', 'Jul-Aug', 'Sep-Oct', 'Nov-Dec'],
    };
    Map<int, int> daysPerMonth = {
      1: 31,
      2: 28, //Leap year
      3: 31,
      4: 30,
      5: 31,
      6: 30,
      7: 31,
      8: 31,
      9: 30,
      10: 31,
      11: 30,
      12: 31
    };
    List categoryColors = [
      const Color(0xff0293ee),
      const Color(0xfff8b250),
      const Color(0xff845bef),
      const Color(0xff13d38e)
    ];
    List<Data> barData = [];
    Map<String, dynamic> timeData = {};
    final db = await instance.database; //delete unnecessary stuff
    final now = DateTime.now();
    final currentYear = now.year;
    final currentMonth = now.month;

    bool incraseDate = false;

    late DateTime currentDate;
    late List result;
    late int timeshift;
    late int shiftCorrect;
    late int groupedSections;
    int dataIndex = 0;

    timeData = await getTimeData(timeframe);

    groupedSections = timeData['groupedSections'];
    dataPerSection = timeData['dataPerSection'];
    timeshift = timeData['timeshift'];
    shiftCorrect = timeData['shiftCorrect'];
    
    currentDate = timeData['currentDate'];
    result = timeData['result'];
    timeframe = timeData['timeframe'];
    //print(result);

    //List sectionValues =
    //List.generate(timeData['dataPerSection'], (index) => 0.0);
    List totalTimeValues = List.generate(groupedSections, (index) => 0.0);
    List<TableData> tableData = List.generate(groupedSections + 1, (index) {
      // Generate TableData for each index
      return TableData(
        time: '',
        categoryData: { for (var category in categoriesExtra) category : 0.0 }, // Initialize with default value
      );
    });

    for (int i = 0; i < groupedSections; i++) {
      print("i: $i");
      List categoryValues = List.generate(categories.length, (index) => 0.0);

      double total = 0.0;
      double barHeight = 0.0;
      print('saved timeframe: $timeframe');
      if (timeframe == 'This Year') {
        tableData[i].time = labeling[timeframe][i];
      }
      else if (timeframe == 'All Time') {
        
        if (groupedSections <= 36 && timeshift == 30) {//years <= 2
          if (i < 12) {
            if (groupedSections == 24) {
              tableData[i].time = "${labeling['This Year'][i]} ${currentYear - 1}";
            }
            else {
              tableData[i].time = "${labeling['This Year'][i]} ${currentYear - 2}";
            }
            
          }
          else if (i < 24) {
            if (groupedSections == 24) {
              tableData[i].time = "${labeling['This Year'][i - 12]} $currentYear";
            }
            else {
              tableData[i].time = "${labeling['This Year'][i - 12]} ${currentYear - 1}";
            }
          }
          else if (i < 36) {//only if 3 years (years = 2)          
            tableData[i].time = "${labeling['This Year'][i - 24]} $currentYear";
          }
        }
        else if (groupedSections <= 30 && timeshift == 60) {//every two months (years <= 4)
          if (i < 6) {
            if (groupedSections == 24) {
              tableData[i].time = "${labeling['All Time'][i]} ${currentYear - 3}";
            }
            else {
              tableData[i].time = "${labeling['All Time'][i]} ${currentYear - 4}";
            }
            
          }
          else if (i < 12) {
            if (groupedSections == 24) {
              tableData[i].time = "${labeling['All Time'][i - 6]} ${currentYear - 2}";
            }
            else {
              tableData[i].time = "${labeling['All Time'][i- 6]} ${currentYear - 3}";
            }   
          }
          else if (i < 18) {
            if (groupedSections == 24) {
              tableData[i].time = "${labeling['All Time'][i - 12]} ${currentYear - 1}";
            }
            else {
              tableData[i].time = "${labeling['All Time'][i - 12]} ${currentYear - 2}";
            }
          }
          else if (i < 24) {
            if (groupedSections == 24) {
              tableData[i].time = "${labeling['All Time'][i - 18]} $currentYear";
            }
            else {
              tableData[i].time = "${labeling['All Time'][i - 18]} ${currentYear - 1}";
            }          
          }        
          else if (i < 30) {//only if 5 years (years = 4)
            tableData[i].time = "${labeling['All Time'][i - 24]} $currentYear";
        }
        }
        else if (timeshift == 365) {
          tableData[i].time = "${currentYear - (groupedSections - (i + 1))}";
        }
      }
      else {
        tableData[i].time =
          '${labeling[timeframe]} ${(i + 1).toString()}';//month: Week, 7 days: Day, Year: array with Months
      }
      
      //define an almost empty listElement of the barData
       
      barData.add(Data(
        id: i,
        name: 'Week ${i.toString()}',
        rodData: List.generate(
          dataPerSection,
          (index) => BarChartRodDataClass(
            barHeight: 0.0,
            rodItems: List.generate(
              categories.length,
              (index) => RodStackItemsClass(
                minY: 0.0,
                maxY: 0.0,
                color: const Color(0xff19bfff),
              ),
            ),
          ),
        ),
      ));

      for (int j = 0; j < dataPerSection; j++) {
        print(j);
        //define some variables
        var thisData = {};
        late var nextData;
        late DateTime nextDate;

        incraseDate = false;

        //check if data is still available
        if (dataIndex < result.length) {
          thisData = result[dataIndex];
        } else {
          print('end of data');
          break;
        }
        if (dataIndex < result.length - 1) {
          nextData = {};
          nextData = result[dataIndex + 1];
          nextDate = DateTime.parse(nextData['date']);
          nextDate = nextDate.add(const Duration(seconds: 1));
        } else {
          nextDate = now.add(const Duration(days: 1000000));
        }

        DateTime dateFromDatabase = DateTime.parse(thisData['date']);
        dateFromDatabase = dateFromDatabase.add(const Duration(seconds: 1));
        print('Date from database: $dateFromDatabase');
        print('reference date: $currentDate');

        if (dateFromDatabase.isBefore(currentDate)) {
          //print('isBefore');

          
          //if the date from the database is before the currentDate
          barHeight += thisData['amount'];
          categoryValues[categories.indexOf(thisData['category'])] +=
              thisData['amount'];
          j--; //reset, so that the dataPerSection can be increased
          dataIndex++;//changed------------------------------------------------------------------------------
          //print(nextDate);
          
          

          print(currentDate);
          print(nextDate);
          if (nextDate.isAfter(currentDate)) { 
            //if the nextDate is after this one
            //print('head on');
            incraseDate = true; //date has to be increased
            //print(dateFromDatabase);
            //print(currentDate);
            j++;
            barData[i].rodData[j].barHeight = barHeight;

            barHeight = 0.0;

            double y = 0.0;

            for (int k = 0; k < categories.length; k++) {
              //insert data in table and barChart
              if (categoryValues[k] > 0) {
                tableData[i].categoryData[categories[k]] = categoryValues[k];
                total += categoryValues[k];
                totalCategoryValues[k] += categoryValues[k];
                //tableData[i][categories[k]] = categoryValues[k];//set the key and value for table
                //set the rodItems
                barData[i].rodData[j].rodItems[k].minY = y;
                y += categoryValues[k];
                barData[i].rodData[j].rodItems[k].maxY = y;
                barData[i].rodData[j].rodItems[k].color = categoryColors[k];
                //reset the categoryValues
                categoryValues[k] = 0.0;
              }
            }
            //print(currentDate);
            

            tableData[i].categoryData['Total'] = total;
            
          }
        } else {
          incraseDate = true;
          
        }
        if (incraseDate) {// if the date current date is not before the referencedate
        
          
          

          //modifications for This Month
          if (((timeframe == "This Month" &&
                      daysPerMonth[currentMonth]! > 29) ||
                  timeframe == "Last 30 Days") &&
              i == timeData['groupedSections'] - 1) {
            //if it is a longer month and the last gropuedSection

            currentDate =
                currentDate.add(const Duration(days: 1)); //instead of 2 let it be 3 so that 21 + 3*3 = 30
                
                
            if ( j == dataPerSection - 2) { //if it is the last grouped Data from this month
              
              currentDate = currentDate.add(const Duration(days: 2)); //incrase so that 21 + 3*3 + 2 = 32
              //print("increased");
              if ((timeframe == "This Month" &&
                    daysPerMonth[currentMonth] == 30) ||
                timeframe == "Last 30 Days") {
                  
              //month has only 30 days so 3*7 + 3*3  + 2 - 1 = 31
              currentDate = currentDate.subtract(const Duration(days: 1));
              }
            }
          }

          if(timeframe == "This Month" && currentMonth == 2 && i == timeData['groupedSections'] - 1 && j == dataPerSection - 2) {
            currentDate = currentDate.add(const Duration(days:1));
          }

          if ((timeframe == "This Month" &&
                currentMonth == 2 &&
                currentYear % 4 == 0 &&
                currentYear % 100 != 0) && i == timeData['groupedSections'] - 1 && j == dataPerSection - 2) {
              //if it is a leap year than add one day so 4*7 + 1  = 29
              currentDate = currentDate.add(const Duration(days: 1));
            }
          if (j == dataPerSection - 2) {
            //next iteration will be the last one for this section so add one more for 2 + 2 + 3 = 7
            currentDate = currentDate.add(Duration(days: shiftCorrect)); 
            
          }

          //modifications for This Year, NOT EXACT YET, MONTHS SHOULD BE MORE PRECISE

          /*if (timeframe == "This Year" && i == timeData['groupedSections'] - 1 && j == dataPerSection - 2) {
            currentDate = currentDate.add(const Duration(days: 6));

            if (currentYear % 4 == 0 && currentYear % 100 != 0) {
              currentDate = currentDate.add(const Duration(days: 1));

            }
          }*/
          if (timeframe == "This Year" && j == dataPerSection - 2) {
            int monthNumber = currentDate.month;
            int yearNumber = currentDate.year;
            if (i % 12 == 0) {
              currentDate = currentDate.add(const Duration(days: 1));
            }

            
            if (daysPerMonth[monthNumber] == 31) {
              currentDate = currentDate.add(const Duration(days: 1));
              //------------------------for summer and winter time, to be updated if it changes
              if (monthNumber == 3) {
                currentDate = currentDate.subtract(const Duration (hours: 1));
              }
              if (monthNumber == 10) {
                currentDate = currentDate.add(const Duration (hours: 1));
              }
              //-----------------------------------------------------------
            }
            if (daysPerMonth[monthNumber] == 28) {
              currentDate = currentDate.subtract(const Duration(days: 2));
              if (yearNumber % 4 == 0 && yearNumber % 100 != 0) {
                currentDate = currentDate.add(const Duration(days: 1));
              }

            }
            
            
          }
          currentDate = currentDate.add(Duration(days: timeshift)); //switched to bottom
          
        }
      } //loop of sectionPerData is over
    } //loop of groupedSections is over

    //assign the total values in the tableData
    double allAdded = 0.0;
    tableData[groupedSections].time = 'All';
    for (int i = 0; i < categories.length; i++) {
      tableData[groupedSections].categoryData[categories[i]] =
          totalCategoryValues[i];
      allAdded += totalCategoryValues[i];
    }

    tableData[groupedSections].categoryData['Total'] = allAdded;
    //assign the total values in the tableData
    //tableData[gropuedSections].categoryValues['Food'] =
    //List<TableData> table_data = List.generate(sections, (index) => null);
    if (bar) {
      return barData;
    } else {
      return tableData;
    }
  }

  Future<Map<String, dynamic>> getTimeData(String? timeframe) async {
    Map<String, dynamic> timeData = {};
    final db = await instance.database;
    List months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];

    final now = DateTime.now();
    DateTime currentDateAtMidnight =
        DateTime(now.year, now.month, now.day, 0, 0, 0);
    final currentYear = now.year;


    final currentMonth = now.month;


    
    late DateTime currentDate;
    timeData['shiftCorrect'] = 0;

    if (timeframe == "All Time") {
      //calculate somehow
      timeData['groupedSections'] = 1;
      timeData['dataPerSection'] = 1;
      timeData['timeshift'] = 0;

      timeData['result'] = await db.rawQuery(
          "SELECT amount, category, date FROM expenditure ORDER BY date ASC");
      currentDate = DateTime.parse(timeData['result'][0]['date']);
      //currentDate = timeData['currentDate'];
      print("FIRST DAY RECORDED IS: $currentDate");

      DateTime sevenDays = currentDateAtMidnight.subtract(const Duration(days: 7));
      DateTime thisMonth = DateTime(currentYear, currentMonth, 1);
      int targetMonth = currentMonth - 3;
      int targetYear = currentYear;
      int startYear = currentDate.year;
      print(startYear);
      int years = currentYear - startYear;
      print("YEARS: $years");

      if (targetMonth < 1) {
        targetMonth += 12; // Wrap around to December of the previous year
        targetYear -= 1; // Adjust the year
      }
      DateTime threeMonths = DateTime(targetYear, targetMonth, 1);

      if (currentDate.isAfter(sevenDays)) {
        timeframe = "Last 7 Days";
      } else if (currentDate.isAfter(thisMonth)) {
        timeframe = "This Month";
      } else if (currentDate.isAfter(threeMonths)) { //change parameters
        timeData['groupedSections'] = 12;
        timeData['dataPerSection'] = 1;
        timeData['timeshift'] = 3;
      } else if (years == 0) {
        timeframe = "This Year";
      } else {
        if (years <= 2) { 
          timeData['groupedSections'] = (years + 1) * 12;
          timeData['dataPerSection'] = 1;
          timeData['timeshift'] = 30;
          timeData['currentDate'] = DateTime(startYear, 1, 1);
          
        }
        else if (years <= 4){
          timeData ['groupedSections'] = (years + 1) * 6;
          timeData ['dataPerSection'] = 1;
          timeData ['timeshift'] = 60;
          timeData['currentDate'] = DateTime(startYear, 2, 1);
        }
        else {
          timeData ['groupedSections'] = years + 1;
          timeData ['dataPerSection'] = 1;
          timeData ['timeshift'] = 365;
          timeData['currentDate'] = DateTime(startYear, 12, 31);
        }
      }
      timeData['timeframe'] = timeframe;
      _saveGroupedSections(timeData['groupedSections']);
    }

    if (timeframe == "This Year") {
      timeData['timeframe'] = timeframe;
      timeData['groupedSections'] = 12;
      timeData['dataPerSection'] = 3;
      timeData['timeshift'] = 10;
      timeData['currentDate'] = DateTime(now.year, 1, 10);
      int currentYear = DateTime.now().year;
// Query to select data for the current year
      timeData['result'] = await db.rawQuery(
        "SELECT amount, category, date FROM expenditure WHERE strftime('%Y', date) = ? ORDER BY date ASC",
        ['$currentYear'], 
      );
      print(timeData['result']);
    }
    if (timeframe == "This Month") {
      timeData['timeframe'] = timeframe;
      timeData['groupedSections'] = 4;
      timeData['dataPerSection'] = 3;
      timeData['timeshift'] = 2;
      timeData['currentDate'] = DateTime(currentYear, currentMonth, 2, 0, 0, 0);//start at the second day of the month to compare
      timeData['shiftCorrect'] = 1;

      //String timefilterString =
          //'$currentYear-${currentMonth.toString().padLeft(2, '0')}-01';
      String timefilterString = '${currentMonth == 1 ? now.year - 1 : now.year}-${(currentMonth == 1 ? 12 : currentMonth - 1).toString().padLeft(2, '0')}-${DateTime(currentMonth == 1 ? now.year - 1 : now.year, (currentMonth == 1 ? 12 : currentMonth - 1) + 1, 0).day} 23:59:59';
      DateTime timefilter = DateTime.parse(timefilterString);
      print("Timefilter: $timefilter");
      timeData['result'] = await db.rawQuery(
          "SELECT amount, category, date FROM expenditure WHERE date >= ? ORDER BY date ASC",
          [timefilter.toIso8601String()]);
    }
    if (timeframe == "Last 30 Days") {
      timeData['timeframe'] = timeframe;
      timeData['groupedSections'] = 4;
      timeData['dataPerSection'] = 3;
      timeData['timeshift'] = 2;
      timeData['shiftCorrect'] = 1;
      timeData['currentDate'] =
          currentDateAtMidnight.subtract(const Duration(days: 28));
      currentDate = timeData['currentDate'];
    String formattedDate = DateFormat('yyyy-MM-dd')
          .format(currentDate.subtract(const Duration(days: 2)));
      print("start date: $formattedDate");

// Query to select data from the last thirty days
      timeData['result'] = await db.rawQuery(
        "SELECT amount, category, date FROM expenditure WHERE date >= ? ORDER BY date ASC",
        [formattedDate],
      );
    }
    if (timeframe == "Last 7 Days") {
      timeData['timeframe'] = timeframe;
      timeData['groupedSections'] = 8;
      timeData['dataPerSection'] = 1;
      timeData['timeshift'] = 1;
      timeData['currentDate'] =
          currentDateAtMidnight.subtract(const Duration(days: 6));
      currentDate = timeData['currentDate'];
      String formattedDate = DateFormat('yyyy-MM-dd')
          .format(currentDate.subtract(const Duration(days: 1)));

// Query to select data from the last seven days
      timeData['result'] = await db.rawQuery(
        "SELECT amount, category, date FROM expenditure WHERE date >= ? ORDER BY date ASC",
        [formattedDate],
      );
    }
    
    
    return timeData;
  }
  void _saveGroupedSections(int sections) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setInt('groupedSections', sections);
  TimeframeManager().groupedSections = sections;
}
}
