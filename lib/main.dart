import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:travel_booking_app/transport_aggregator.dart';
import 'package:secure_db/secure_db.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initializeDateFormatting("Ru");
  await SecureDB.init();

  runApp(const TransportAggregator());
}
