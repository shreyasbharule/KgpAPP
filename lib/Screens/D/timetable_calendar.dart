import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:table_calendar/table_calendar.dart';

class TimetableEvent {
  const TimetableEvent({
    required this.title,
    required this.start,
    required this.end,
    required this.location,
    this.description,
  });

  final String title;
  final DateTime start;
  final DateTime end;
  final String location;
  final String? description;
}

class TimetableCalendarPage extends StatefulWidget {
  const TimetableCalendarPage({super.key});

  @override
  State<TimetableCalendarPage> createState() => _TimetableCalendarPageState();
}

class _TimetableCalendarPageState extends State<TimetableCalendarPage> {
  final DateTime _firstDay = DateTime.utc(2026, 1, 1);
  final DateTime _lastDay = DateTime.utc(2026, 12, 31);
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String _statusMessage = 'Tap “Download iCal” to save the timetable.';
  String _locationMessage = 'Location not collected yet.';

  final List<TimetableEvent> _events = <TimetableEvent>[
    TimetableEvent(
      title: 'CS101 Lecture',
      start: DateTime(2026, 2, 16, 9, 0),
      end: DateTime(2026, 2, 16, 10, 0),
      location: 'Main Building - Room 101',
      description: 'Introduction to Programming',
    ),
    TimetableEvent(
      title: 'MA102 Tutorial',
      start: DateTime(2026, 2, 16, 11, 0),
      end: DateTime(2026, 2, 16, 12, 0),
      location: 'Math Department - Hall 2',
      description: 'Linear Algebra practice session',
    ),
    TimetableEvent(
      title: 'PH103 Lab',
      start: DateTime(2026, 2, 17, 14, 0),
      end: DateTime(2026, 2, 17, 16, 0),
      location: 'Physics Lab Complex',
      description: 'Optics experiments',
    ),
    TimetableEvent(
      title: 'EE104 Lecture',
      start: DateTime(2026, 2, 18, 10, 0),
      end: DateTime(2026, 2, 18, 11, 0),
      location: 'Electrical Department - LT 3',
      description: 'Network theory basics',
    ),
  ];

  List<TimetableEvent> get _selectedDayEvents {
    final DateTime day = _selectedDay ?? _focusedDay;
    return _events.where((TimetableEvent event) {
      return event.start.year == day.year &&
          event.start.month == day.month &&
          event.start.day == day.day;
    }).toList();
  }

  Future<void> _downloadIcsFile() async {
    final String icsData = _buildIcsData();

    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/iitkgp_timetable.ics');
      await file.writeAsString(icsData);

      if (!mounted) {
        return;
      }
      setState(() {
        _statusMessage =
            'iCal file saved at: ${file.path}. You can import it in your calendar app.';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _statusMessage = 'Failed to save iCal file: $error';
      });
    }
  }

  Future<void> _collectLocation() async {
    final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _locationMessage =
            'Location services are disabled. Please enable GPS/location.';
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        _locationMessage =
            'Location permission denied. Allow it in settings to continue.';
      });
      return;
    }

    try {
      final Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _locationMessage =
            'Current location: lat ${position.latitude.toStringAsFixed(6)}, '
            'lng ${position.longitude.toStringAsFixed(6)}';
      });
    } catch (error) {
      setState(() {
        _locationMessage = 'Could not fetch location: $error';
      });
    }
  }

  String _buildIcsData() {
    final StringBuffer buffer = StringBuffer()
      ..writeln('BEGIN:VCALENDAR')
      ..writeln('VERSION:2.0')
      ..writeln('PRODID:-//IIT KGP Student App//Timetable//EN')
      ..writeln('CALSCALE:GREGORIAN');

    for (final TimetableEvent event in _events) {
      buffer
        ..writeln('BEGIN:VEVENT')
        ..writeln('UID:${event.title.replaceAll(' ', '_')}-${event.start.millisecondsSinceEpoch}@iitkgp.app')
        ..writeln('DTSTAMP:${_formatDateUtc(DateTime.now().toUtc())}')
        ..writeln('DTSTART:${_formatDateUtc(event.start.toUtc())}')
        ..writeln('DTEND:${_formatDateUtc(event.end.toUtc())}')
        ..writeln('SUMMARY:${event.title}')
        ..writeln('LOCATION:${event.location}')
        ..writeln('DESCRIPTION:${event.description ?? ''}')
        ..writeln('END:VEVENT');
    }

    buffer.writeln('END:VCALENDAR');
    return buffer.toString();
  }

  String _formatDateUtc(DateTime dateTime) {
    final String year = dateTime.year.toString().padLeft(4, '0');
    final String month = dateTime.month.toString().padLeft(2, '0');
    final String day = dateTime.day.toString().padLeft(2, '0');
    final String hour = dateTime.hour.toString().padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    final String second = dateTime.second.toString().padLeft(2, '0');
    return '${year}${month}${day}T${hour}${minute}${second}Z';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 5, 115, 134),
        title: const Text('Timetable Calendar'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TableCalendar<TimetableEvent>(
                firstDay: _firstDay,
                lastDay: _lastDay,
                focusedDay: _focusedDay,
                selectedDayPredicate: (DateTime day) =>
                    isSameDay(_selectedDay, day),
                eventLoader: (DateTime day) {
                  return _events.where((TimetableEvent event) {
                    return isSameDay(event.start, day);
                  }).toList();
                },
                onDaySelected: (DateTime selectedDay, DateTime focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
              ),
              const SizedBox(height: 16),
              const Text(
                'Classes for selected date',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._selectedDayEvents.map((TimetableEvent event) {
                return Card(
                  child: ListTile(
                    title: Text(event.title),
                    subtitle: Text(
                      '${event.location}\n${event.start.hour.toString().padLeft(2, '0')}:${event.start.minute.toString().padLeft(2, '0')} - '
                      '${event.end.hour.toString().padLeft(2, '0')}:${event.end.minute.toString().padLeft(2, '0')}',
                    ),
                    isThreeLine: true,
                  ),
                );
              }),
              if (_selectedDayEvents.isEmpty)
                const Text('No classes scheduled for this date.'),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _downloadIcsFile,
                icon: const Icon(Icons.download),
                label: const Text('Download iCal'),
              ),
              const SizedBox(height: 8),
              Text(_statusMessage),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _collectLocation,
                icon: const Icon(Icons.location_on),
                label: const Text('Collect My Location'),
              ),
              const SizedBox(height: 8),
              Text(_locationMessage),
            ],
          ),
        ),
      ),
    );
  }
}
