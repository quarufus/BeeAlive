import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:bee_alive/widgets/apiary_marker.dart';
import 'package:bee_alive/tools/appdata.dart';
import 'package:weather/weather.dart';
import 'package:weather_icons/weather_icons.dart';

class ApiaryPage extends StatefulWidget {
  final Apiary apiary;

  ApiaryPage({
    required this.apiary,
    Key? key,
  });

  @override
  ApiaryPageState createState() => ApiaryPageState();
}

class ApiaryPageState extends State<ApiaryPage> {
  WeatherFactory weatherFactory =
      WeatherFactory("8034a55d9f844cb5090f21c401460ec7");
  Weather? test;
  var temp;
  var feelsLike;

  @override
  void initState() {
    getWeather(weatherFactory, widget.apiary.latlng.latitude,
            widget.apiary.latlng.longitude)
        .then((value) => setState(() {
              test = value;
              temp = test?.temperature;
              feelsLike = test?.tempFeelsLike;
            }));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (test != null)
        ? getPage(
            apiary: widget.apiary,
            temp: test?.temperature?.celsius.toString().substring(0, 5) ?? "--",
            feelsLike:
                test?.tempFeelsLike?.celsius.toString().substring(0, 5) ?? "--")
        : Container();
  }
}

Center getPage(
    {required Apiary apiary, String temp = "--", String feelsLike = "--"}) {
  final PageController controller = PageController();

  return Center(
    child: PageView(
        controller: controller,
        scrollDirection: Axis.vertical,
        children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(
                  apiary.name,
                  style: TextStyle(fontSize: 30),
                ),
                Text(
                  temp + " °C",
                  style: TextStyle(fontSize: 35),
                ),
                Icon(
                  WeatherIcons.day_cloudy,
                  size: 100,
                ),
                Text("feels like : " + feelsLike + " °C"),
                Container(
                  alignment: Alignment.center,
                  height: 70,
                  width: 250,
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: ListTile(
                        title: Text("Δείκτης\nΕπικινδυνότητας"),
                        trailing: Text(
                          "2",
                          style: TextStyle(fontSize: 40),
                        ),
                      )),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: Color(0xffE28525),
                      )),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Icon(WeatherIcons.day_cloudy),
                    Icon(WeatherIcons.day_cloudy),
                    Icon(WeatherIcons.day_light_wind),
                    Icon(WeatherIcons.day_sunny),
                    Icon(WeatherIcons.day_sunny_overcast),
                  ],
                ),
                /*TableCalendar(
              focusedDay: DateTime.now(),
              firstDay: DateTime.utc(2022),
              lastDay: DateTime.utc(2050)),*/
              ],
            ),
          ),
          Center(
            child: TableCalendar(
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                  titleTextStyle:
                      TextStyle(color: Color(0xffE28525), fontSize: 25),
                ),
                daysOfWeekHeight: 50,
                daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(fontSize: 20),
                    weekendStyle: TextStyle(fontSize: 20),
                    decoration: BoxDecoration(
                        border: BorderDirectional(
                            bottom: BorderSide(
                                width: 2, color: Color(0xffE28525))))),
                focusedDay: DateTime.now(),
                firstDay: DateTime.utc(2022),
                lastDay: DateTime.utc(2050)),
          )
        ]),
  );
}

List<Widget> getPages(int index) {
  List<Widget> results =
      []; // = apiariesData.map((e) => getPage(apiary: e)).toList();
  for (Apiary apiary in apiariesData) {
    results.add(ApiaryPage(apiary: apiary));
  }
  var first = results[index];
  results.remove(first);
  results.insert(0, first);
  return results;
}

Future<Weather> getWeather(weatherFactory, lat, long) async {
  Weather weather = await weatherFactory.currentWeatherByLocation(lat, long);
  return weather;
}
