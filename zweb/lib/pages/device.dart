import 'dart:developer';

import 'package:beamer/beamer.dart';
import 'package:clipboard/clipboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:zweb/const.dart';
import 'package:zweb/controller/app_controller.dart';
import 'package:zweb/utils/utils.dart';
import 'package:zweb/widgets/dashboard_menu.dart';
import 'package:zweb/widgets/textheader.dart';

class DevicePage extends StatefulWidget {
  DevicePage({Key? key}) : super(key: key);

  @override
  _DevicePageState createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  AppController controller = Get.find<AppController>();

  creatDevice() {
    // create dashboard dialog
    showDialog(
      context: context,
      builder: (BuildContext context) => Dialog(
        shape: kCardBorderRadius,
        insetPadding: EdgeInsets.all(10),
        child: AddDevice(),
      ),
    );
  }

  addDeviceTemplate() {
    FirebaseFirestore.instance.collection("device_templates").get().then((value) {
      log(value.docs.length.toString());
      if (value.docs.length == 0) {
        // create mock template
        FirebaseFirestore.instance.collection("device_templates").add({
          "name": "Temp Sensor",
          "description": "Temp Sensor",
          "data": ["temp", "humid"],
          "control": ["c1"]
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    // Fix Me : mock device template
    addDeviceTemplate();
  }

  @override
  Widget build(BuildContext context) {
    double scWidth = MediaQuery.of(context).size.width;
    return SelectionArea(
      child: Scaffold(
        appBar: AppBar(
          title: DashboardMenu(),
          automaticallyImplyLeading: false,
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TextHeader(title: "Device"),
                Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: (scWidth > 412)
                      ? TextButton.icon(
                          icon: Icon(Icons.add_circle),
                          label: Text("Add Device"),
                          onPressed: () {
                            // create device dialog
                            creatDevice();
                          },
                        )
                      : IconButton(
                          icon: Icon(Icons.add_circle),
                          onPressed: () {
                            // create device dialog
                            creatDevice();
                          }),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('devices')
                        .where('user', isEqualTo: controller.userUid.value)
                        .snapshots(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      // has error
                      if (snapshot.hasError) {
                        return Center(child: Text("Something, went wrong!"));
                      }

                      // has data
                      if (snapshot.hasData) {
                        var docs = snapshot.data!.docs;

                        if (docs.length > 0) {
                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: getGridSized(scWidth)),
                            itemCount: docs.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Container(
                                child: LayoutBuilder(
                                  builder: (context, constraints) => Card(
                                    shape: kCardBorderRadius,
                                    child: Stack(
                                      children: [
                                        // icon
                                        Positioned.fill(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              InkWell(
                                                hoverColor: Colors.transparent,
                                                child: Icon(
                                                  Icons.developer_board,
                                                  size: constraints.maxWidth * 0.65,
                                                  color: Theme.of(context).primaryColor.withOpacity(0.6),
                                                ),
                                                onTap: () {
                                                  // open dashboard
                                                  Get.toNamed('/device/' + docs[index].id);
                                                },
                                              ),
                                              Container(
                                                alignment: Alignment.center,
                                                width: constraints.maxWidth * 0.8,
                                                child: Text(
                                                  docs[index]['name'],
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  //style: kTextItemTitle,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // popup
                                        Positioned(
                                          right: 1,
                                          child: Padding(
                                            padding: const EdgeInsets.all(0.0),
                                            child: PopupMenuButton(
                                              icon: Icon(Icons.more_vert, size: 16),
                                              itemBuilder: (context) => <PopupMenuEntry>[
                                                PopupMenuItem(child: Text("Info"), value: 'info'),
                                                PopupMenuItem(
                                                    child: Text("Delete", style: kTextWarning), value: 'delete'),
                                              ],
                                              onSelected: (value) {
                                                if (value == "delete") {
                                                  // delete device
                                                  FirebaseFirestore.instance
                                                      .collection('devices')
                                                      .doc(docs[index].id)
                                                      .delete();
                                                }
                                                if (value == "info") {
                                                  // control
                                                  List<dynamic> listDeviceControl = docs[index]['control'];
                                                  // data
                                                  List<dynamic> listDeviceData = docs[index]['data'];
                                                  // show dialog
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) => Dialog(
                                                      shape: kCardBorderRadius,
                                                      insetPadding: EdgeInsets.all(10),
                                                      child: Container(
                                                        width: 375,
                                                        padding: EdgeInsets.all(24),
                                                        child: Column(
                                                          mainAxisSize: MainAxisSize.min,
                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                          children: [
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                              child: Text(
                                                                docs[index]['name'],
                                                                style: Theme.of(context).textTheme.headline5,
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                              child: Text(docs[index]['description']),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                              child: Row(
                                                                children: [
                                                                  Text("ID : "),
                                                                  Chip(label: SelectableText(docs[index].id)),
                                                                  IconButton(
                                                                    icon: Icon(Icons.copy, size: 16),
                                                                    onPressed: () {
                                                                      FlutterClipboard.copy(docs[index].id);
                                                                    },
                                                                  )
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                              child: Wrap(
                                                                children: [
                                                                  Text("Control : "),
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                              child: Wrap(
                                                                children: [
                                                                  for (int i = 0; i < listDeviceControl.length; i++)
                                                                    Chip(
                                                                      label: SelectableText(
                                                                        docs[index]['control'][i],
                                                                      ),
                                                                    ),
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                              child: Wrap(
                                                                children: [
                                                                  Text("Data : "),
                                                                ],
                                                              ),
                                                            ),
                                                            Padding(
                                                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                                                              child: Wrap(
                                                                children: [
                                                                  for (int i = 0; i < listDeviceData.length; i++)
                                                                    Chip(
                                                                      label: SelectableText(
                                                                        docs[index]['data'][i],
                                                                      ),
                                                                    ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        } else {
                          // document snapshot is 0
                          return Center(child: Text("No device, please create a new one"));
                        }
                      }

                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddDevice extends StatefulWidget {
  const AddDevice({
    Key? key,
  }) : super(key: key);

  @override
  _AddDeviceState createState() => _AddDeviceState();
}

class _AddDeviceState extends State<AddDevice> {
  int? selectDeviceType = 0;
  String? selectDeviceTemplateId;

  final _formKey = GlobalKey<FormState>();
  TextEditingController _textInputDeviceName = TextEditingController();
  TextEditingController _textInputDeviceDescription = TextEditingController();

  List<String> _listTagValueParam = [];
  List<String> _listTagControlParam = [];

  late List<QueryDocumentSnapshot> deviceTemplate;

  AppController controller = Get.find<AppController>();

  TextfieldTagsController _textfieldTagsControlParam = TextfieldTagsController();
  TextfieldTagsController _textfieldTagsControlValue = TextfieldTagsController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // unfocus textfield
        FocusScope.of(context).unfocus();
        new TextEditingController().clear();
      },
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Container(
            width: 375,
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // title
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    child: Text(
                      "Create Device",
                      style: Theme.of(context).textTheme.headline5,
                    ),
                  ),
                ),

                // drop down create device method
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: kContainerRecRoundDecoration,
                    child: DropdownButtonFormField(
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Select device",
                      ),
                      items: [
                        DropdownMenuItem<int>(
                          value: 0,
                          child: Text("Create from template"),
                        ),
                        DropdownMenuItem<int>(
                          value: 1,
                          child: Text("Create custom device"),
                        ),
                      ],
                      value: selectDeviceType,
                      onChanged: (value) {
                        // set value here
                        setState(() {
                          selectDeviceType = int.parse(value.toString());
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select device';
                        }
                        return null;
                      },
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: kContainerRecRoundDecoration,
                    child: TextFormField(
                      controller: _textInputDeviceName,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Device name',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter name";
                        }
                      },
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: kContainerRecRoundDecoration,
                    child: TextFormField(
                      controller: _textInputDeviceDescription,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Device Description',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter description";
                        }
                      },
                    ),
                  ),
                ),

                (selectDeviceType == 0)
                    ?
                    // dropdown list device from template
                    FutureBuilder(
                        future: FirebaseFirestore.instance.collection("device_templates").get(),
                        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text("Something went wrong!"),
                            );
                          }

                          if (snapshot.hasData) {
                            deviceTemplate = snapshot.data!.docs;
                            log("template total =" + deviceTemplate.length.toString());
                            // template drop down
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Container(
                                padding: EdgeInsets.all(8),
                                decoration: kContainerRecRoundDecoration,
                                child: DropdownButtonFormField(
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: "Select device template",
                                  ),
                                  items: deviceTemplate
                                      .map(
                                        (doc) => DropdownMenuItem<String>(
                                          value: doc.id,
                                          child: Text(doc['name']),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (value) {
                                    setState(() {
                                      selectDeviceTemplateId = value.toString();
                                    });
                                  },
                                  validator: (value) {
                                    if (value == null) {
                                      return 'Please select device template';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            );
                          }

                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                      )
                    : Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: kContainerRecRoundDecoration,
                              child: TextFieldTags(
                                textfieldTagsController: _textfieldTagsControlParam,
                                initialTags: _listTagControlParam,
                                textSeparators: const [' ', ','],
                                letterCase: LetterCase.normal,
                                // FIXME : validate field when not enter tag
                                validator: (tag) {
                                  if (_textfieldTagsControlParam.getTags!.contains(tag)) {
                                    return 'Already has field';
                                  }
                                  return null;
                                },
                                inputfieldBuilder: (context, tec, fn, error, onChanged, onSubmitted) {
                                  return ((context, sc, tags, onTagDelete) {
                                    return TextField(
                                      controller: tec,
                                      focusNode: fn,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                        hintText: 'Control params',
                                        helperText: 'Enter control field',
                                        errorText: error,
                                        prefixIcon: tags.isNotEmpty
                                            ? SingleChildScrollView(
                                                controller: sc,
                                                scrollDirection: Axis.horizontal,
                                                child: Row(
                                                    children: tags.map((String tag) {
                                                  return Container(
                                                    decoration: const BoxDecoration(
                                                      borderRadius: BorderRadius.all(
                                                        Radius.circular(20.0),
                                                      ),
                                                      color: Colors.blue,
                                                    ),
                                                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                                    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        InkWell(
                                                          child: Text(
                                                            ' $tag',
                                                            style: const TextStyle(color: Colors.white),
                                                          ),
                                                          onTap: () {
                                                            //print("$tag selected");
                                                          },
                                                        ),
                                                        const SizedBox(width: 4.0),
                                                        InkWell(
                                                          child: const Icon(
                                                            Icons.cancel,
                                                            size: 14.0,
                                                            color: Color.fromARGB(255, 233, 233, 233),
                                                          ),
                                                          onTap: () {
                                                            onTagDelete(tag);
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                }).toList()),
                                              )
                                            : null,
                                      ),
                                      onChanged: onChanged,
                                      onSubmitted: onSubmitted,
                                    );
                                  });
                                },
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: kContainerRecRoundDecoration,
                              child: TextFieldTags(
                                textfieldTagsController: _textfieldTagsControlValue,
                                initialTags: _listTagValueParam,
                                textSeparators: const [' ', ','],
                                letterCase: LetterCase.normal,
                                // FIXME : validate field when not enter tag
                                validator: (tag) {
                                  if (_textfieldTagsControlParam.getTags!.contains(tag)) {
                                    return 'Already has field';
                                  }
                                  return null;
                                },
                                inputfieldBuilder: (context, tev, fnv, error, onChanged, onSubmitted) {
                                  return ((context, sc, tags, onTagDelete) {
                                    return TextField(
                                      controller: tev,
                                      focusNode: fnv,
                                      decoration: InputDecoration(
                                        isDense: true,
                                        border: InputBorder.none,
                                        hintText: 'Data params',
                                        helperText: 'Enter value field',
                                        errorText: error,
                                        prefixIcon: tags.isNotEmpty
                                            ? SingleChildScrollView(
                                                controller: sc,
                                                scrollDirection: Axis.horizontal,
                                                child: Row(
                                                    children: tags.map((String tag) {
                                                  return Container(
                                                    decoration: const BoxDecoration(
                                                      borderRadius: BorderRadius.all(
                                                        Radius.circular(20.0),
                                                      ),
                                                      color: Colors.blue,
                                                    ),
                                                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                                                    padding: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
                                                    child: Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        InkWell(
                                                          child: Text(
                                                            ' $tag',
                                                            style: const TextStyle(color: Colors.white),
                                                          ),
                                                          onTap: () {
                                                            //print("$tag selected");
                                                          },
                                                        ),
                                                        const SizedBox(width: 4.0),
                                                        InkWell(
                                                          child: const Icon(
                                                            Icons.cancel,
                                                            size: 14.0,
                                                            color: Color.fromARGB(255, 233, 233, 233),
                                                          ),
                                                          onTap: () {
                                                            onTagDelete(tag);
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                }).toList()),
                                              )
                                            : null,
                                      ),
                                      onChanged: onChanged,
                                      onSubmitted: onSubmitted,
                                    );
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),

                Row(
                  children: [
                    Spacer(),
                    ElevatedButton(
                      child: Text("Submit"),
                      onPressed: () {
                        if (selectDeviceType == 0) {
                          // create device by template
                          if (_formKey.currentState!.validate()) {
                            log("submit device by template = " + selectDeviceTemplateId.toString());

                            var docTemplate = deviceTemplate.where((element) => element.id == selectDeviceTemplateId);
                            var docControl = docTemplate.first['control'];
                            var docData = docTemplate.first['data'];

                            FirebaseFirestore.instance.collection('devices').add({
                              'name': _textInputDeviceName.text.trim(),
                              'description': _textInputDeviceDescription.text.trim(),
                              'user': controller.userUid.value,
                              'control': docControl,
                              'data': docData,
                            }).then(
                              (value) => Get.back(),
                            );
                          }
                        } else {
                          // create device by custom param
                          if (_formKey.currentState!.validate()) {
                            log("submit device by params");
                            log('${_textfieldTagsControlParam.getTags}');
                            log('${_textfieldTagsControlValue.getTags}');

                            FirebaseFirestore.instance.collection('devices').add({
                              'name': _textInputDeviceName.text.trim(),
                              'description': _textInputDeviceDescription.text.trim(),
                              'user': controller.userUid.value,
                              'control': _listTagControlParam,
                              'data': _listTagValueParam,
                            }).then(
                              (value) => Get.back(),
                            );
                          }
                        }
                      },
                    ),
                    SizedBox(width: 8.0),
                    ElevatedButton(
                      style: kElevatedButtonRedButton,
                      child: Text("Close"),
                      onPressed: () {
                        Get.back();
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
