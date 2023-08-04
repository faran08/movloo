import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

class CSVGraphPage extends StatefulWidget {
  const CSVGraphPage({super.key, required this.locationName});

  final String locationName;
  @override
  _CSVGraphPageState createState() => _CSVGraphPageState();
}

class _CSVGraphPageState extends State<CSVGraphPage> {
  List<FlSpot> spots = [];
  int lastLabeledYear = 0;

  @override
  void initState() {
    super.initState();
    loadAssetWeb();
    // loadAsset();
  }

  String getYearTitle(double value) {
    final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
    if (date.year >= lastLabeledYear + 2) {
      lastLabeledYear = date.year;
      return '${date.year}';
    }
    return '';
  }

  Future<void> loadAssetWeb() async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage.ref().child('custom_review_db.csv');
      String downloadURL = await ref.getDownloadURL();

      final response = await http.get(Uri.parse(downloadURL));
      final csvString = response.body;

      final fields = const CsvToListConverter().convert(csvString);

      List<FlSpot> newSpots = [];

      for (var row in fields) {
        if (row[0] == widget.locationName) {
          double formattedDate = DateFormat('dd/MM/yyyy')
              .parse(row[5])
              .millisecondsSinceEpoch
              .toDouble();
          double ratingsValue = row[3].toDouble();
          newSpots.add(FlSpot(formattedDate, ratingsValue));
        }
      }

      setState(() {
        newSpots.sort((a, b) => a.x.compareTo(b.x));
        spots = newSpots;
      });
    } catch (e) {
      print('Error occurred while trying to download file: $e');
    }
  }

  Future<void> loadAsset() async {
    final csvString = await rootBundle.loadString('custom_review_db.csv');

    final fields = const CsvToListConverter().convert(csvString);

    List<FlSpot> newSpots = [];

    for (var row in fields) {
      if (row[0] == widget.locationName) {
        double formattedDate = DateFormat('dd/MM/yyyy')
            .parse(row[5])
            .millisecondsSinceEpoch
            .toDouble();
        double ratingsValue = row[3].toDouble();
        newSpots.add(FlSpot(formattedDate, ratingsValue));
      }
    }

    setState(() {
      newSpots.sort((a, b) => a.x.compareTo(b.x));
      spots = newSpots;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CSV Graph'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(8, 50, 50, 8),
        child: spots.isNotEmpty
            ? LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      barWidth: 3,
                      colors: [
                        Colors.blue,
                      ],
                      dotData: FlDotData(
                        show: true,
                      ),
                    ),
                  ],
                  minY: 0,
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        getTitles: getYearTitle,
                        margin: 12),
                    leftTitles: SideTitles(
                      showTitles: true,
                      getTitles: (value) {
                        return value.toInt().toString();
                      },
                      reservedSize: 28,
                      margin: 12,
                    ),
                  ),
                  gridData: FlGridData(
                    show: false,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: const Color(0xff37434d),
                        strokeWidth: 1,
                      );
                    },
                    drawVerticalLine: true,
                    getDrawingVerticalLine: (value) {
                      return FlLine(
                        color: const Color(0xff37434d),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(
                    show: false,
                  ),
                ),
              )
            : Container(),
      ),
    );
  }
}
