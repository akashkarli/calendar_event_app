import 'package:calendar_event_app/helper/utils.dart';
import 'package:calendar_event_app/provider/CalenderEventProvider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:intl/intl.dart';


class CreateScreen extends StatefulWidget {
  @override
  _CreateScreenState createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  late TextEditingController textControllerDate;
  late TextEditingController textControllerStartTime;
  late TextEditingController textControllerEndTime;
  late TextEditingController textControllerTitle;
  late TextEditingController textControllerDesc;
  late TextEditingController textControllerLocation;
  late TextEditingController textControllerAttendee;

  late FocusNode textFocusNodeTitle;
  late FocusNode textFocusNodeDesc;
  late FocusNode textFocusNodeLocation;
  late FocusNode textFocusNodeAttendee;

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedStartTime = TimeOfDay.now();
  TimeOfDay selectedEndTime = TimeOfDay.now();

  late String currentTitle = "";
  late String currentDesc = "";
  late String currentLocation = "";
  late String currentEmail = "";
  String errorString = '';
  // List<String> attendeeEmails = [];
  List<calendar.EventAttendee> attendeeEmails = [];

  bool isEditingDate = false;
  bool isEditingStartTime = false;
  bool isEditingEndTime = false;
  bool isEditingBatch = false;
  bool isEditingTitle = false;
  bool isEditingEmail = false;
  bool isEditingLink = false;
  bool isErrorTime = false;
  bool shouldNofityAttendees = false;
  bool hasConferenceSupport = false;

  bool isDataStorageInProgress = false;
  var _formKey = GlobalKey<FormState>();
  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        textControllerDate.text = DateFormat.yMMMMd().format(selectedDate);
      });
    }
  }

  _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedStartTime,
    );
    if (picked != null && picked != selectedStartTime) {
      setState(() {
        selectedStartTime = picked;
        textControllerStartTime.text = selectedStartTime.format(context);
      });
    } else {
      setState(() {
        textControllerStartTime.text = selectedStartTime.format(context);
      });
    }
  }

  _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedEndTime,
    );
    if (picked != null && picked != selectedEndTime) {
      setState(() {
        selectedEndTime = picked;
        textControllerEndTime.text = selectedEndTime.format(context);
      });
    } else {
      setState(() {
        textControllerEndTime.text = selectedEndTime.format(context);
      });
    }
  }

  @override
  void initState() {
    textControllerDate = TextEditingController();
    textControllerStartTime = TextEditingController();
    textControllerEndTime = TextEditingController();
    textControllerTitle = TextEditingController();
    textControllerDesc = TextEditingController();
    textControllerLocation = TextEditingController();
    textControllerAttendee = TextEditingController();

    textFocusNodeTitle = FocusNode();
    textFocusNodeDesc = FocusNode();
    textFocusNodeLocation = FocusNode();
    textFocusNodeAttendee = FocusNode();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        elevation: 0,
        title: Text(
          'Create Event',
          style: TextStyle(
            color: CustomColor.dark_cyan,
            fontSize: 22,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Stack(
          children: [
            Container(
              //color: Colors.white,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.0),
                      RichText(
                        text: TextSpan(
                          text: 'Select Date',
                          style: TextStyle(
                            color: CustomColor.dark_cyan,
                            fontFamily: 'Raleway',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: '*',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        cursorColor: CustomColor.sea_blue,
                        controller: textControllerDate,
                        textCapitalization: TextCapitalization.characters,
                        onTap: () => _selectDate(context),
                        readOnly: true,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        decoration: new InputDecoration(

                          disabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                color: CustomColor.sea_blue, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                color: CustomColor.sea_blue, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                color: CustomColor.dark_blue, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(color: Colors.redAccent, width: 2),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          contentPadding: EdgeInsets.only(
                            left: 16,
                            bottom: 16,
                            top: 16,
                            right: 16,
                          ),
                          hintText: 'eg: September 10, 2020',
                          hintStyle: TextStyle(
                            color: Colors.grey.withOpacity(0.6),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          errorText:
                              isEditingDate && textControllerDate.text != null
                                  ? textControllerDate.text.isNotEmpty
                                      ? null
                                      : 'Date can\'t be empty'
                                  : null,
                          errorStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      RichText(
                        text: TextSpan(
                          text: 'Start Time',
                          style: TextStyle(
                            color: CustomColor.dark_cyan,
                            fontFamily: 'Raleway',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: '*',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        cursorColor: CustomColor.sea_blue,
                        controller: textControllerStartTime,
                        onTap: () => _selectStartTime(context),
                        readOnly: true,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        decoration: new InputDecoration(
                          disabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                color: CustomColor.sea_blue, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                color: CustomColor.sea_blue, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                color: CustomColor.dark_blue, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(color: Colors.redAccent, width: 2),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          contentPadding: EdgeInsets.only(
                            left: 16,
                            bottom: 16,
                            top: 16,
                            right: 16,
                          ),
                          hintText: 'eg: 09:30 AM',
                          hintStyle: TextStyle(
                            color: Colors.grey.withOpacity(0.6),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          errorText: isEditingStartTime &&
                                  textControllerStartTime.text != null
                              ? textControllerStartTime.text.isNotEmpty
                                  ? null
                                  : 'Start time can\'t be empty'
                              : null,
                          errorStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      RichText(
                        text: TextSpan(
                          text: 'End Time',
                          style: TextStyle(
                            color: CustomColor.dark_cyan,
                            fontFamily: 'Raleway',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: '*',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        cursorColor: CustomColor.sea_blue,
                        controller: textControllerEndTime,
                        onTap: () => _selectEndTime(context),
                        readOnly: true,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        decoration: new InputDecoration(
                          disabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                color: CustomColor.sea_blue, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                color: CustomColor.sea_blue, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                color: CustomColor.dark_blue, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(color: Colors.redAccent, width: 2),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          contentPadding: EdgeInsets.only(
                            left: 16,
                            bottom: 16,
                            top: 16,
                            right: 16,
                          ),
                          hintText: 'eg: 11:30 AM',
                          hintStyle: TextStyle(
                            color: Colors.grey.withOpacity(0.6),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          errorText: isEditingEndTime &&
                                  textControllerEndTime.text != null
                              ? textControllerEndTime.text.isNotEmpty
                                  ? null
                                  : 'End time can\'t be empty'
                              : null,
                          errorStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      RichText(
                        text: TextSpan(
                          text: 'Title',
                          style: TextStyle(
                            color: CustomColor.dark_cyan,
                            fontFamily: 'Raleway',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: '*',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        enabled: true,
                        cursorColor: CustomColor.sea_blue,
                        focusNode: textFocusNodeTitle,
                        controller: textControllerTitle,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        onChanged: (value) {
                          setState(() {
                            isEditingTitle = true;
                            currentTitle = value;
                          });
                        },
                        onSubmitted: (value) {
                          textFocusNodeTitle.unfocus();
                          FocusScope.of(context)
                              .requestFocus(textFocusNodeDesc);
                        },
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        decoration: new InputDecoration(
                          disabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                color: CustomColor.sea_blue, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                color: CustomColor.dark_blue, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(color: Colors.redAccent, width: 2),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          contentPadding: EdgeInsets.only(
                            left: 16,
                            bottom: 16,
                            top: 16,
                            right: 16,
                          ),
                          hintText: 'eg: Birthday party of John',
                          hintStyle: TextStyle(
                            color: Colors.grey.withOpacity(0.6),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                          errorText: isEditingTitle
                              ? validateTitle(currentTitle)
                              : null,
                          errorStyle: TextStyle(
                            fontSize: 12,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      RichText(
                        text: TextSpan(
                          text: 'Description',
                          style: TextStyle(
                            color: CustomColor.dark_cyan,
                            fontFamily: 'Raleway',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: ' ',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        enabled: true,
                        maxLines: null,
                        cursorColor: CustomColor.sea_blue,
                        focusNode: textFocusNodeDesc,
                        controller: textControllerDesc,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.next,
                        onChanged: (value) {
                          setState(() {
                            currentDesc = value;
                          });
                        },
                        onSubmitted: (value) {
                          textFocusNodeDesc.unfocus();
                          FocusScope.of(context)
                              .requestFocus(textFocusNodeLocation);
                        },
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                        decoration: new InputDecoration(
                          disabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(color: Colors.grey, width: 1),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                color: CustomColor.sea_blue, width: 1),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide: BorderSide(
                                color: CustomColor.dark_blue, width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                            borderSide:
                                BorderSide(color: Colors.redAccent, width: 2),
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          contentPadding: EdgeInsets.only(
                            left: 16,
                            bottom: 16,
                            top: 16,
                            right: 16,
                          ),
                          hintText: 'eg: Some information about this event',
                          hintStyle: TextStyle(
                            color: Colors.grey.withOpacity(0.6),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      RichText(
                        text: TextSpan(
                          text: 'Attendees',
                          style: TextStyle(
                            color: CustomColor.dark_cyan,
                            fontFamily: 'Raleway',
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text: ' ',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: PageScrollPhysics(),
                        itemCount: attendeeEmails.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  attendeeEmails[index].email,
                                  style: TextStyle(
                                    color: CustomColor.neon_green,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.close),
                                  onPressed: () {
                                    setState(() {
                                      attendeeEmails.removeAt(index);
                                    });
                                  },
                                  color: Colors.red,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              enabled: true,
                              cursorColor: CustomColor.sea_blue,
                              focusNode: textFocusNodeAttendee,
                              controller: textControllerAttendee,
                              textCapitalization: TextCapitalization.none,
                              textInputAction: TextInputAction.done,
                              onChanged: (value) {
                                setState(() {
                                  currentEmail = value;
                                });
                              },
                              onSubmitted: (value) {
                                textFocusNodeAttendee.unfocus();
                              },
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                              decoration: new InputDecoration(
                                disabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide:
                                      BorderSide(color: Colors.grey, width: 1),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: BorderSide(
                                      color: CustomColor.sea_blue, width: 1),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: BorderSide(
                                      color: CustomColor.dark_blue, width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                  borderSide: BorderSide(
                                      color: Colors.redAccent, width: 2),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10.0)),
                                ),
                                contentPadding: EdgeInsets.only(
                                  left: 16,
                                  bottom: 16,
                                  top: 16,
                                  right: 16,
                                ),
                                hintText: 'Enter attendee email',
                                hintStyle: TextStyle(
                                  color: Colors.grey.withOpacity(0.6),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                                errorText: isEditingEmail
                                    ? validateEmail(currentEmail)
                                    : null,
                                errorStyle: TextStyle(
                                  fontSize: 12,
                                  color: Colors.redAccent,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.check_circle,
                              color: CustomColor.sea_blue,
                              size: 35,
                            ),
                            onPressed: () {
                              setState(() {
                                isEditingEmail = true;
                              });
                              if (validateEmail(currentEmail) == null) {
                                setState(() {
                                  textFocusNodeAttendee.unfocus();
                                  calendar.EventAttendee eventAttendee =
                                      calendar.EventAttendee();
                                  eventAttendee.email = currentEmail;

                                  attendeeEmails.add(eventAttendee);

                                  textControllerAttendee.text = '';
                                  currentEmail = "";
                                  isEditingEmail = false;
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Container(
                        width: double.maxFinite,
                        child: RaisedButton(
                          elevation: 0,
                          focusElevation: 0,
                          highlightElevation: 0,
                          color: CustomColor.sea_blue,
                          onPressed: isDataStorageInProgress
                              ? null
                              : () async {
                                  if (_formKey.currentState!.validate()) {
                                    _formKey.currentState?.save();

                                    setState(() {
                                      isErrorTime = false;
                                      isDataStorageInProgress = true;
                                    });

                                    textFocusNodeTitle.unfocus();
                                    textFocusNodeDesc.unfocus();
                                    textFocusNodeLocation.unfocus();
                                    textFocusNodeAttendee.unfocus();

                                    if (selectedDate != null &&
                                        selectedStartTime != null &&
                                        selectedEndTime != null &&
                                        currentTitle != null) {
                                      int startTimeInEpoch = DateTime(
                                        // selectedDate.year,
                                        // selectedDate.month,
                                        // selectedDate.day,
                                        selectedStartTime.hour,
                                        selectedStartTime.minute,
                                      ).millisecondsSinceEpoch;

                                      int endTimeInEpoch = DateTime(
                                        // selectedDate.year,
                                        // selectedDate.month,
                                        // selectedDate.day,
                                        selectedEndTime.hour,
                                        selectedEndTime.minute,
                                      ).millisecondsSinceEpoch;

                                      print(
                                          'DIFFERENCE: ${endTimeInEpoch - startTimeInEpoch}');

                                      print(
                                          'Start Time: ${DateTime.fromMillisecondsSinceEpoch(startTimeInEpoch)}');
                                      print(
                                          'End Time: ${DateTime.fromMillisecondsSinceEpoch(endTimeInEpoch)}');

                                      if (endTimeInEpoch - startTimeInEpoch >
                                          0) {
                                        print(
                                            'endTimeInEpoch: ${DateTime.fromMillisecondsSinceEpoch(endTimeInEpoch)}');

                                        if (validateTitle(currentTitle) ==
                                            null) {
                                          print("titiol");
                                          context
                                              .read<CalenderEventProvider>()
                                              .insertEvent(
                                                  context: context,
                                                  title: currentTitle,
                                                  date: selectedDate,
                                                  description: currentDesc,
                                                  location: currentLocation,
                                                  attendeeEmailList:
                                                      attendeeEmails,
                                                  startTime: DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          startTimeInEpoch),
                                                  endTime: DateTime
                                                      .fromMillisecondsSinceEpoch(
                                                          endTimeInEpoch));

                                          print("hiii");


                                          print("insertflagvv");
                                          setState(() {
                                            isDataStorageInProgress = false;
                                          });
                                          print(context.read<CalenderEventProvider>().insertFlag);
                                          if(context.read<CalenderEventProvider>().insertFlag){
                                            Navigator.pop(context);
                                          }
                                        } else {
                                          setState(() {
                                            isEditingTitle = true;
                                            isEditingLink = true;
                                          });
                                        }
                                      } else {
                                        setState(() {
                                          isErrorTime = true;
                                          errorString =
                                              'Invalid time! Please use a proper start and end time';
                                        });
                                      }
                                    } else {
                                      setState(() {
                                        isEditingDate = true;
                                        isEditingStartTime = true;
                                        isEditingEndTime = true;
                                        isEditingBatch = true;
                                        isEditingTitle = true;
                                        isEditingLink = true;
                                      });
                                      setState(() {
                                        isDataStorageInProgress = false;
                                      });
                                    }
                                    setState(() {
                                      isDataStorageInProgress = false;
                                    });

                                  }
                                },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                            child: isDataStorageInProgress
                                ? SizedBox(
                                    height: 28,
                                    width: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor:
                                          new AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                    ),
                                  )
                                : Text(
                                    'ADD',
                                    style: TextStyle(
                                      fontFamily: 'Raleway',
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: isErrorTime,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              errorString,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TextEditingController>(
        'textControllerEndTime', textControllerEndTime));
  }
}

