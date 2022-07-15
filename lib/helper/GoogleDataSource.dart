import 'package:googleapis/calendar/v3.dart' as googleAPI;
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';


class GoogleDataSource extends CalendarDataSource {
  GoogleDataSource({List<googleAPI.Event>? events}) {
    this.appointments = events;
  }


  @override
  DateTime getStartTime(int index) {
    final googleAPI.Event event = appointments[index];
    return event.start.date ?? event.start.dateTime.toLocal();
  }

  @override
  bool isAllDay(int index) {
    return appointments[index].start.date != null;
  }

  @override
  DateTime getEndTime(int index) {
    final googleAPI.Event event = appointments[index];
    return event.endTimeUnspecified != null && event.endTimeUnspecified
        ? (event.start.date ?? event.start.dateTime.toLocal())
        : (event.end.date != null
        ? event.end.date.add(Duration(days: -1))
        : event.end.dateTime.toLocal());
  }

  @override
  String getLocation(int index) {
    return appointments[index].location;
  }

  @override
  String getNotes(int index) {
    return appointments[index].description;
  }

  @override
  String getSubject(int index) {
    final googleAPI.Event event = appointments[index];
    return event.summary == null || event.summary.isEmpty
        ? 'No Title'
        : event.summary;
  }
}

class GoogleAPIClient extends IOClient {
  Map<String, String> _headers;

  GoogleAPIClient(this._headers) : super();

  @override
  Future<IOStreamedResponse> send(BaseRequest request) =>
      super.send(request..headers.addAll(_headers));

// @override
// Future<Response> head(Object url, {Map<String, String>? headers}) =>
//     super.head(url, headers: headers?..addAll(_headers));
}