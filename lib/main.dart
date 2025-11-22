import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:travel_booking_app/transport_aggregator.dart';

void main() {
  initializeDateFormatting("Ru");
  runApp(const TransportAggregator());
}
