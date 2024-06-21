// ignore_for_file: prefer_const_constructors, avoid_print, use_build_context_synchronously, library_private_types_in_public_api, use_super_parameters, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cookie_flutter_app/main.dart' as main;
import 'package:cookie_flutter_app/pages/admin/SettingsPage.dart';
import 'package:cookie_flutter_app/pages/admin/dashboardPage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AnalysisPage extends StatefulWidget {
  final String token;

  const AnalysisPage({Key? key, required this.token}) : super(key: key);

  @override
  _AnalysisPageState createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  String _selectedOption = 'hora';
  List<LoginRecord> records = [];
  List<GenderRecord> gender = [];
  List<PostRecord> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getStats();
    _getSexes();
    _getPosts();
  }

  Future<void> _logout(BuildContext context) async {
    const String logoutUrl = 'https://co-api-vjvb.onrender.com/api/auth/logout';

    final http.Response response = await http.post(
      Uri.parse(logoutUrl),
      headers: {
        'x-access-token': widget.token,
      },
    );

    if (response.statusCode == 200) {
      print('Sesión cerrada exitosamente');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_token');

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const main.MyApp()),
        (Route<dynamic> route) => false,
      );
    } else {
      print('Error al cerrar sesión: ${response.statusCode}');
    }
  }

  Future<void> _getSexes() async {
    const String statsUrl = 'https://co-api-vjvb.onrender.com/api/stats/sexes';

    final response = await http.get(
      Uri.parse(statsUrl),
      headers: {
        'x-access-token': widget.token,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        gender = (data['sexes'] as List)
            .map((record) => GenderRecord.fromJson(record))
            .toList();
        isLoading = false;
      });
    } else {
      print('Error al obtener estadísticas: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _getStats() async {
    const String statsUrl = 'https://co-api-vjvb.onrender.com/api/stats/';

    final response = await http.get(
      Uri.parse(statsUrl),
      headers: {
        'x-access-token': widget.token,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        records = (data['records'] as List)
            .map((record) => LoginRecord.fromJson(record))
            .toList();
        isLoading = false;
      });
    } else {
      print('Error al obtener estadísticas: ${response.statusCode}');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _getPosts() async {
    const String postsUrl = 'https://co-api-vjvb.onrender.com/api/stats/posts';

    final response = await http.get(
      Uri.parse(postsUrl),
      headers: {
        'x-access-token': widget.token,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        posts = (data['posts'] as List)
            .map((post) => PostRecord.fromJson(post))
            .toList();
        isLoading = false;
      });
    } else {
      print('Error al obtener los posts: ${response.statusCode}');
    }
  }

  List<SplineSeries<LoginRecord, String>> _createLoginChartData() {
    if (_selectedOption == 'hora') {
      return _createPeakHourChartData();
    }
    Map<String, int> periodLoginCounts = {};
    for (var record in records) {
      String periodKey;
      DateTime loginTime = record.loginTime;

      if (_selectedOption == 'dia') {
        periodKey = '${loginTime.year}-${loginTime.month}-${loginTime.day}';
      } else if (_selectedOption == 'semana') {
        int weekNumber = ((loginTime.day - 1) / 7).floor() + 1;
        periodKey = '${loginTime.year}-W$weekNumber';
      } else {
        periodKey = '${loginTime.year}-${loginTime.month}';
      }

      periodLoginCounts[periodKey] = (periodLoginCounts[periodKey] ?? 0) + 1;
    }

    List<LoginRecord> chartData = periodLoginCounts.entries
        .map((entry) => LoginRecord(
            period: entry.key,
            loginCount: entry.value,
            loginTime: DateTime.now()))
        .toList();

    chartData.sort((a, b) => a.period.compareTo(b.period));

    return [
      SplineSeries<LoginRecord, String>(
        dataSource: chartData,
        xValueMapper: (LoginRecord record, _) => record.period,
        yValueMapper: (LoginRecord record, _) => record.loginCount.toDouble(),
        color: Colors.blue,
      ),
    ];
  }

  List<SplineSeries<LoginRecord, String>> _createPeakHourChartData() {
    Map<int, int> loginCounts = {};
    for (var record in records) {
      DateTime loginTime = record.loginTime.toLocal();
      int hour = loginTime.hour;
      loginCounts[hour] = (loginCounts[hour] ?? 0) + 1;
    }

    List<LoginRecord> chartData = [];
    for (int hour = 0; hour < 24; hour += 2) {
      chartData.add(LoginRecord(
          hour: DateFormat('HH').format(DateTime(2024, 1, 1, hour)),
          loginCount: loginCounts[hour] ?? 0,
          loginTime: DateTime.now()));
    }

    return [
      SplineSeries<LoginRecord, String>(
        dataSource: chartData,
        xValueMapper: (LoginRecord record, _) => record.hour,
        yValueMapper: (LoginRecord record, _) => record.loginCount,
        color: Colors.blue,
      ),
    ];
  }

  List<PieSeries<GenderData, String>> _createGenderChartData() {
    int maleCount = gender.where((record) => record.gender == 'male').length;
    int femaleCount =
        gender.where((record) => record.gender == 'female').length;
    int nonBinaryCount =
        gender.where((record) => record.gender == 'not binary').length;

    int totalCount = maleCount + femaleCount + nonBinaryCount;

    List<GenderData> chartData = [
      GenderData(gender: 'male', count: (maleCount / totalCount * 100).round()),
      GenderData(
          gender: 'female', count: (femaleCount / totalCount * 100).round()),
      GenderData(
          gender: 'not binary',
          count: (nonBinaryCount / totalCount * 100).round()),
    ];

    return [
      PieSeries<GenderData, String>(
        dataSource: chartData,
        xValueMapper: (GenderData data, _) => data.gender,
        yValueMapper: (GenderData data, _) => data.count,
        dataLabelMapper: (GenderData data, _) => '${data.count}%',
        dataLabelSettings: DataLabelSettings(isVisible: true),
      ),
    ];
  }

  List<SplineSeries<PostRecord, String>> _createPostsChartData() {
    Map<String, int> postsPerDay = {};
    for (var post in posts) {
      String dayKey = DateFormat('yyyy-MM-dd').format(post.postTime);
      postsPerDay[dayKey] = (postsPerDay[dayKey] ?? 0) + 1;
    }

    List<PostRecord> chartData = postsPerDay.entries
        .map((entry) => PostRecord(
            postTime: DateTime.parse(entry.key),
            day: entry.key,
            postCount: entry.value))
        .toList();

    chartData.sort((a, b) => a.day.compareTo(b.day));

    return [
      SplineSeries<PostRecord, String>(
        dataSource: chartData,
        xValueMapper: (PostRecord record, _) => record.day,
        yValueMapper: (PostRecord record, _) => record.postCount.toDouble(),
        color: Colors.green, // Puedes cambiar el color según tu preferencia
      ),
    ];
  }

  List<ColumnSeries<PostRecord, String>> _createPeakDayChartData() {
    Map<String, int> postsPerWeekday = {
      'Monday': 0,
      'Tuesday': 0,
      'Wednesday': 0,
      'Thursday': 0,
      'Friday': 0,
      'Saturday': 0,
      'Sunday': 0,
    };
    for (var post in posts) {
      String weekday = DateFormat('EEEE').format(post.postTime);
      postsPerWeekday[weekday] = (postsPerWeekday[weekday] ?? 0) + 1;
    }

    List<PostRecord> chartData = postsPerWeekday.entries
        .map((entry) => PostRecord(
            day: entry.key, postCount: entry.value, postTime: DateTime.now()))
        .toList();

    chartData.sort((a, b) => b.postCount.compareTo(a.postCount));

    return [
      ColumnSeries<PostRecord, String>(
        dataSource: chartData,
        xValueMapper: (PostRecord record, _) => record.day,
        yValueMapper: (PostRecord record, _) => record.postCount.toDouble(),
        color: Colors.orange,
      ),
    ];
  }

  List<SplineSeries<PostRecord, String>> _createPeakHourPostsChartData() {
    Map<int, int> postsPerHour = {};
    for (var post in posts) {
      int hour = post.postTime.hour;
      postsPerHour[hour] = (postsPerHour[hour] ?? 0) + 1;
    }

    List<PostRecord> chartData = [];
    for (int hour = 0; hour < 24; hour++) {
      chartData.add(PostRecord(
          hour: DateFormat('HH').format(DateTime(2024, 1, 1, hour)),
          postCount: postsPerHour[hour] ?? 0,
          postTime: DateTime.now()));
    }

    return [
      SplineSeries<PostRecord, String>(
        dataSource: chartData,
        xValueMapper: (PostRecord record, _) => record.hour,
        yValueMapper: (PostRecord record, _) => record.postCount.toDouble(),
        color: Colors.red,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('STATS', style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.dashboard),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DashboardPage(token: widget.token)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.analytics),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AnalysisPage(token: widget.token)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons
                .person), // Cambiado el ícono de configuración por el ícono de perfil
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => SettingsPage(token: widget.token)),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: DropdownButton<String>(
                      value: _selectedOption,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedOption = newValue!;
                        });
                      },
                      style: TextStyle(color: Colors.black, fontSize: 18),
                      underline: Container(
                        height: 2,
                        color: Colors.blue,
                      ),
                      items: <String>['hora', 'dia', 'semana', 'mes']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                  ),
                  SizedBox(
                    height: 400,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      title: ChartTitle(
                          text: _selectedOption == 'hora'
                              ? 'Logins por hora'
                              : 'Logins por $_selectedOption'),
                      legend: Legend(isVisible: true),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: _createLoginChartData(),
                    ),
                  ),
                  SizedBox(
                    height: 400,
                    child: SfCircularChart(
                      title: ChartTitle(text: 'Distribución de Género'),
                      legend: Legend(isVisible: true),
                      series: _createGenderChartData(),
                    ),
                  ),
                  SizedBox(
                    height: 400,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      title: ChartTitle(text: 'Posts por día'),
                      legend: Legend(isVisible: true),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: _createPostsChartData(),
                    ),
                  ),
                  SizedBox(
                    height: 400,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      title: ChartTitle(text: 'Días con más posts'),
                      legend: Legend(isVisible: true),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: _createPeakDayChartData(),
                    ),
                  ),
                  SizedBox(
                    height: 400,
                    child: SfCartesianChart(
                      primaryXAxis: CategoryAxis(),
                      title: ChartTitle(text: 'Horas pico de posts'),
                      legend: Legend(isVisible: true),
                      tooltipBehavior: TooltipBehavior(enable: true),
                      series: _createPeakHourPostsChartData(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class LoginRecord {
  final DateTime loginTime;
  final String period;
  final int loginCount;
  final String hour;

  LoginRecord({
    required this.loginTime,
    this.period = '',
    this.loginCount = 0,
    this.hour = '',
  });

  factory LoginRecord.fromJson(Map<String, dynamic> json) {
    return LoginRecord(
      loginTime: DateTime.parse(json['loginTime']),
    );
  }
}

class GenderRecord {
  final String gender;

  GenderRecord({
    required this.gender,
  });

  factory GenderRecord.fromJson(Map<String, dynamic> json) {
    return GenderRecord(
      gender: json['gender'],
    );
  }
}

class GenderData {
  final String gender;
  final int count;

  GenderData({required this.gender, required this.count});
}

class PostRecord {
  final DateTime postTime;
  final String day;
  final String hour;
  final int postCount;

  PostRecord({
    required this.postTime,
    this.day = '',
    this.hour = '',
    this.postCount = 0,
  });

  factory PostRecord.fromJson(Map<String, dynamic> json) {
    final postTime = json['postTime'];
    if (postTime != null && postTime is String) {
      return PostRecord(
        postTime: DateTime.parse(postTime),
      );
    } else {
      return PostRecord(
        postTime: DateTime.now(),
      );
    }
  }
}
