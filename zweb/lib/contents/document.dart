import 'package:flutter/material.dart';
import 'package:zweb/utils/utils.dart';

class DocumentContent extends StatelessWidget {
  const DocumentContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 1024,
        child: LayoutBuilder(
          builder: (context, constraints) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                          "Document",
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16.0),
                        Text(
                          "Zeal IoT has 2 parts; a progressive web application, stores data on Cloud services, and an edge/embedded system on IoT devices.",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          "The document has 2 parts",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          "1. Administrator document for deploying / managing Zeal IoT on Cloud services.",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          "2. Embedded developers, write firmware or ETL script to push data to Zeal IoT.",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16.0),
                        ElevatedButton(
                            onPressed: () {
                              launchURL("https://github.com/anoochit/zeal_iot/blob/master/doc/index.md");
                            },
                            child: const Text("Goto document page"))
                      ],
                    ),
                  ),
                  SizedBox(width: (1024 / 2), child: Image.asset('assets/images/undraw_my_files_swob.png')),
                ],
              ),
              // Container(
              //   width: (constraints.maxWidth < (1024)) ? (1024 / 2) : 1024,
              //   child: Wrap(
              //     children: [
              //       Padding(
              //         padding: const EdgeInsets.all(16.0),
              //         child: FutureBuilder(
              //           future: loadAsset("assets/doc/index.md"),
              //           builder: (BuildContext context, AsyncSnapshot snapshot) {
              //             if (snapshot.hasError) {
              //               return Center(child: Text("Cannot load document"));
              //             }
              //             if (snapshot.hasData) {
              //               return MarkdownBody(data: snapshot.data);
              //             }
              //             return Container();
              //           },
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
