
import 'package:calendar_event_app/helper/GoogleDataSource.dart';
import 'package:calendar_event_app/helper/LocalStorageService.dart';

import 'package:calendar_event_app/provider/CalenderEventProvider.dart';
import 'package:calendar_event_app/screen/EventAddScreen.dart';
import 'package:calendar_event_app/screen/SigninScreen.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarEvents extends StatefulWidget {
  CalendarEvents({Key? key}) : super(key: key);
  @override
  CalendarEventsState createState() => CalendarEventsState();
}

class CalendarEventsState extends State<CalendarEvents> {
  @override
  void initState() {
    // TODO: implement initState
    Provider.of<CalenderEventProvider>(context, listen: false)
        .getGoogleEventsDataList();
    super.initState();
  }

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Log out"),
          content: Text("Are you sure, do you want to log out ?"),
          actions: [
            MaterialButton(
              child: Text("No"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            MaterialButton(
              child: Text("Yes"),
              onPressed: () async {
                LocalStorageService.onLogout();
                await _googleSignIn.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => SignInScreen()),
                    (Route<dynamic> route) => false);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(

      child: Scaffold(
        appBar: new AppBar(
          title: Text('Event Calendar'),
          automaticallyImplyLeading: false,
          actions: [
            PopupMenuButton<int>(
              itemBuilder: (context) => [
                // PopupMenuItem 1
                PopupMenuItem(
                  value: 1,
                  // row with 2 children
                  child: Row(
                    children: [
                      Icon(Icons.login_outlined),
                      SizedBox(
                        width: 10,
                      ),
                      Text("Sign out")
                    ],
                  ),
                ),
              ],
              offset: Offset(0, 100),
              color: Colors.grey,
              elevation: 2,
              onSelected: (value) {
                if (value == 1) {
                  _showDialog(context);
                }
              },
            ),
          ],
        ),
        body: Consumer<CalenderEventProvider>(
            builder: (context, dataModel, child) {
          return SfCalendar(
            // allowedViews: [
            //   CalendarView.day,
            //   CalendarView.week,
            //   CalendarView.workWeek,
            //   CalendarView.month,
            //   CalendarView.schedule
            // ],
            view: CalendarView.month,
            initialDisplayDate: DateTime.now(),
            dataSource: GoogleDataSource(events: dataModel.googleEventList),
            monthViewSettings: MonthViewSettings(
                showAgenda: true,
                // showTrailingAndLeadingDates: false,
                appointmentDisplayMode:
                    MonthAppointmentDisplayMode.appointment),
          );
        }),
        floatingActionButton: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () =>

                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => CreateScreen()))),
      ),
    );
  }


}
