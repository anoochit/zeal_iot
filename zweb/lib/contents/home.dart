import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:zweb/const.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 1024,
        child: LayoutBuilder(
          builder: (context, constraints) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // jumbo tail
              const SizedBox(height: 16.0),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    width: 1024 / 2,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(
                          "Zeal IoT",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          "Zeal IoT is an IoT Platform that includes a web dashboard, example firmware, and also ETL module. Zeal IoT uses Cloud infrastructure includes computing services, database services that help service availability. Zeal IoT is a support device template or custom device which users can customize. The dashboard also supports many widget types eg: text, gauge, line chart, bar chart, spline chart, and more.",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16.0),
                        Row(
                          children: [
                            ElevatedButton(
                              style: kElevatedButtonGreenButton,
                              child: const Text("Sign Up"),
                              onPressed: () {
                                // goto signup
                                Beamer.of(context).beamToNamed('/signup');
                              },
                            ),
                            const SizedBox(width: 8.0),
                            ElevatedButton(
                              child: const Text("Learn more"),
                              onPressed: () {
                                // goto document
                                Beamer.of(context).beamToNamed('/document');
                              },
                            ),
                            const SizedBox(height: 16.0),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: (1024 / 2), child: Image.asset('assets/images/undraw_Segmentation_re_gduq.png')),
                ],
              ),

              // sample usecases
              const SizedBox(height: 16.0),
              Text(
                "Smart Home",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                alignment: Alignment.center,
                width: (constraints.maxWidth < (1024)) ? (1024 / 2) : 1024,
                child: const Text(
                  "Create a smart farm dashboard easily with your sensor data, switch on/off your light blub or integrate smart home devices.",
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                width: (constraints.maxWidth < (1024)) ? (1024 / 2) : 1024,
                child: Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Image.asset("assets/images/smarthome.png"),
                ),
              ),

              const SizedBox(height: 32.0),
              Text(
                "Smart Farm",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Container(
                alignment: Alignment.center,
                width: (constraints.maxWidth < (1024)) ? (1024 / 2) : 1024,
                padding: const EdgeInsets.all(16.0),
                child: const Text(
                  "Create a smart farm dashboard easily with environmental sensors. Control your water or fertilizer pump.",
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                width: (constraints.maxWidth < (1024)) ? (1024 / 2) : 1024,
                child: Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Image.asset("assets/images/smartfarm.png"),
                ),
              ),

              const SizedBox(height: 32.0),
              Text(
                "Smart Vehicle Tracking",
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              Container(
                alignment: Alignment.center,
                width: (constraints.maxWidth < (1024)) ? (1024 / 2) : 1024,
                padding: const EdgeInsets.all(16.0),
                child: const Text(
                  "Create a vihecle tracking dashboard easily with your GPS tracking device.",
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                width: (constraints.maxWidth < (1024)) ? (1024 / 2) : 1024,
                child: Card(
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Image.asset("assets/images/vehicletracking.png"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
