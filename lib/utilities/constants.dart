
import 'package:flutter/material.dart';

// Text Styles
const kHeadingTextStyle = TextStyle(
  fontSize: 24.0,
  fontWeight: FontWeight.bold,
);

const kSubheadingTextStyle = TextStyle(
  fontSize: 20.0,
  fontWeight: FontWeight.w600,
);

const kBodyTextStyle = TextStyle(
  fontSize: 16.0,
);

// Input Decorations
const kTextFieldInputDecoration = InputDecoration(
  filled: true,
  fillColor: Colors.white,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
    borderSide: BorderSide.none,
  ),
);

// Ebook Site Links
final kEbookSites = {
  'Project Gutenberg': 'https://www.gutenberg.org/',
  'Standard Ebooks': 'https://standardebooks.org/',
  'ManyBooks': 'https://manybooks.net/',
};
