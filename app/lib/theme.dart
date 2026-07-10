import 'package:flutter/material.dart';

// Wayfinding palette, shared across the app.
const ink = Color(0xFF14181F);
const paper = Color(0xFFECEEF0);
const signal = Color(0xFFE8A317);
const active = Color(0xFF0E7C66);
const muted = Color(0xFF6B7480);
const line = Color(0xFFD3D8DE);

BoxDecoration get cardDecoration => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: line),
    );
