import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart'; // Import the 'intl' package for date formatting

class ChartWidget extends StatelessWidget {
  final List<EnvironmentalData> data;

  ChartWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    return SfCartesianChart(
      title: ChartTitle(text: 'Grafik Data VOC'),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
      ),
      tooltipBehavior: TooltipBehavior(enable: true),
      primaryXAxis: DateTimeAxis(
        dateFormat: DateFormat.Hm(),
      ), // Gunakan DateTimeAxis untuk sumbu waktu
      series: <ChartSeries>[
        // VOC Series
        LineSeries<EnvironmentalData, DateTime>(
          dataSource: data,
          xValueMapper: (EnvironmentalData data, _) => data.time,
          yValueMapper: (EnvironmentalData data, _) => data.value,
          name: 'VOC',
        ),
      ],
    );
  }
}

class EnvironmentalData {
  EnvironmentalData(this.time, this.value);

  final DateTime time; // Gunakan DateTime untuk waktu
  final double value;
}

// Contoh penggunaan ChartWidget di dalam widget Dashboard Anda
// ...
// Container(
//   margin: EdgeInsets.only(top: 24),
//   decoration: BoxDecoration(color: Colors.white),
//   child: ChartWidget(data: yourVOCDataList),
// )
// ...
