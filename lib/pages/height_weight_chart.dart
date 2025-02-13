import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:children/pages/home_page.dart';
import 'package:children/models/measurement.dart';
import 'package:children/services/firestore_service.dart';

class GrowthChartPage extends StatefulWidget {
  final int rangeInYears;              // 預設顯示幾年，例如1、3、6、9...
  static const routeName = '/growth_chart';

  const GrowthChartPage({
    Key? key,
    required this.rangeInYears,
  }) : super(key: key);

  @override
  State<GrowthChartPage> createState() => _GrowthChartPageState();
}

class _GrowthChartPageState extends State<GrowthChartPage> {
  // 這裡假設你已經事先準備好 WHO 的標準線, 以月齡為 x、對應身高/體重為 y
  // 假設以「月齡」(0~36)做 x 軸，視需求可擴到 60 或 108 (9年)
  // 這裡用一個簡化的 map 來示意
  final Map<int, double> whoHeightP50 = {
    0: 50.0, 1: 54.7, 2: 58.4, 3: 61.4, // ... 假資料
  };
  final List<Measurement> measurements = [];

  Future<List<Measurement>> getHeightWeightData() async {
    final firestoreService = Provider.of<FirestoreService>(context, listen: false);
    final List<Measurement> measurements = await firestoreService.getHeightWeight() ; // 寶寶量測資料
    return measurements;
  }

  @override
  void initState() {
    super.initState();
    getHeightWeightData().then((value) {
      setState(() {
        measurements.addAll(value);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // 先根據 rangeInYears 算出最大月齡
    int maxMonths = widget.rangeInYears * 12;

    // 轉換「寶寶量測紀錄」成「月齡 -> 身高點」。例如寶寶生日是 measurements[0].date
    // 不同寶寶的計算方式可依實際狀況 (有的會以出生日當 X=0, 或蒐集所有 date 做相對月齡)
    // 以下僅示範：將 date 轉成「與最初量測時間相差的月數」
    final List<FlSpot> babyHeightSpots = [];
    final DateTime? firstDate = measurements.isNotEmpty
        ? measurements.first.date
        : null;

    for (final m in measurements) {
      // if (firstDate != null) {
      //   int monthDiff = _monthDifference(firstDate, m.date);
      //   if (monthDiff <= maxMonths) {
      //     babyHeightSpots.add(FlSpot(monthDiff.toDouble(), m.height));
      //   }
      // }
      babyHeightSpots.add(FlSpot(m.date.month.toDouble(), m.height));
    }

    // 準備 WHO 參考線 (只截取 0..maxMonths)
    final List<FlSpot> whoP50Spots = [];
    for (int mo in whoHeightP50.keys) {
      if (mo <= maxMonths) {
        final double h = whoHeightP50[mo] ?? 0;
        whoP50Spots.add(FlSpot(mo.toDouble(), h));
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.rangeInYears} 年成長曲線 (身高)'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () {
            Navigator.of(context).pushNamed(HomePage.routeName);
          },
        )
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: maxMonths.toDouble(),
            // 依據實際身高範圍調整
            minY: 40,
            maxY: 120,

            // y 軸標籤刻度、x 軸刻度 (可自行客製)
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 6, // 每6個月顯示一個刻度
                  getTitlesWidget: (value, meta) {
                    return Text('${value.toInt()}M'); // e.g. "6M" "12M"
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 10,
                  getTitlesWidget: (value, meta) {
                    return Text('${value.toInt()} cm');
                  },
                ),
              ),
            ),

            // 繪製多條線 (寶寶實際 + WHO參考)
            lineBarsData: [
              // WHO 中位數 (P50) 參考線
              LineChartBarData(
                spots: whoP50Spots,
                isCurved: true,
                color: Colors.green,
                barWidth: 2,
                dotData: FlDotData(show: false),
              ),
              // 寶寶實際量測線
              LineChartBarData(
                spots: babyHeightSpots,
                isCurved: true,
                color: Colors.blue,
                barWidth: 3,
                dotData: FlDotData(show: true), // 顯示量測點
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _monthDifference(DateTime start, DateTime end) {
    return (end.year - start.year) * 12 + (end.month - start.month);
  }
}