

import 'package:calendar_event_app/helper/GoogleDataSource.dart';
import 'package:calendar_event_app/helper/LocalStorageService.dart';
import 'package:calendar_event_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:googleapis/calendar/v3.dart' as googleAPI;
import 'package:intl/intl.dart';

class CalenderEventProvider extends ChangeNotifier {

  List<googleAPI.Event> _eventList = [];


  List<googleAPI.Event> get googleEventList => _eventList;



  bool _insertFlag = false;

  bool get insertFlag => _insertFlag;

 Future insertEvent({context,title, date, startTime, endTime,description,location, attendeeEmailList}) async {
    String? token = await LocalStorageService.getToken();
    String? xGoogAuthuser = await LocalStorageService.getXGoodAuthUser();

   if(token != null && xGoogAuthuser != null){
     var map = {
       LocalStorageService.authorizationToken : token,
       LocalStorageService.XGoogAuthUser : xGoogAuthuser
     };
     print("map token $map");
     final GoogleAPIClient httpClient =
     GoogleAPIClient(map);
     final googleAPI.CalendarApi calendarAPI = googleAPI.CalendarApi(httpClient);


     String calendarId = "primary";
     googleAPI.Event event = googleAPI.Event(); // Create object of event

     event.summary = title;
     event.attendees = attendeeEmailList ?? [];
     event.description = description ?? "";
     event.location = location ?? "";

     String datetime1 = DateFormat("yyyy-MM-dd").format(date);
     final startT =  DateFormat.Hms().format(startTime);
     final endT =  DateFormat.Hms().format(endTime);

     DateTime startDateTime = DateTime.parse("$datetime1 $startT");
     googleAPI.EventDateTime start = new googleAPI.EventDateTime();
     start.dateTime = startDateTime;
     start.timeZone = "GMT+05:00";

     event.start = start;

     DateTime endDateTime = DateTime.parse("$datetime1 $endT");
     googleAPI.EventDateTime end = new googleAPI.EventDateTime();
     end.timeZone = "GMT+05:00";
     end.dateTime = endDateTime;

     event.end = end;
     _insertFlag = false;
     notifyListeners();
     try {
       calendarAPI.events.insert(event, calendarId).then((value) {
         print("ADDEDDD_________________${value.status}");
         if (value.status == "confirmed") {
           _insertFlag = true;
           notifyListeners();
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
             content: Text("Event added in google calendar"),
           ));
           Navigator.pop(context);

           getGoogleEventsDataList();
           print('Event added in google calendar');
         } else {
           _insertFlag = false;
           notifyListeners();
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
             content: Text("Unable to add event in google calendar"),
           ));
           print("Unable to add event in google calendar");
           // Dialogs().displayToast(
           //     context, "Unable to add event in google calendar", 0);
         }
       });
     } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
         content: Text("Error creating event $e"),
       ));
       print('Error creating event $e');
       // Dialogs().displayToast(context, e, 0);
     }

   }

  }



   getGoogleEventsDataList() async {
     String? token = await  LocalStorageService.getToken();
     String? xGoogAuthuser = await LocalStorageService.getXGoodAuthUser();
    print("getGoogleEventsDataList $token $xGoogAuthuser");
    if(token != null && xGoogAuthuser != null) {
      var map = {
        LocalStorageService.authorizationToken: token,
        LocalStorageService.XGoogAuthUser: xGoogAuthuser
      };
      print("map token $map");

      final GoogleAPIClient httpClient = GoogleAPIClient(map);

      final googleAPI.CalendarApi calendarAPI = googleAPI.CalendarApi(
          httpClient);
      final googleAPI.Events calEvents = await calendarAPI.events.list(
        "primary",
      );
      print("calEvents items :- ${calEvents.items}");
      print("calEvents accessRole :- ${calEvents.accessRole}");
      print("calEvents :- ${calEvents.toJson()}");
      final List<googleAPI.Event> appointments = <googleAPI.Event>[];
      if (calEvents != null && calEvents.items != null) {
        for (int i = 0; i < calEvents.items.length; i++) {
          final googleAPI.Event event = calEvents.items[i];
          if (event.start == null) {
            continue;
          }
          appointments.add(event);
        }
      }
      _eventList.clear();
      _eventList.addAll(appointments);
      notifyListeners();
    }}

}