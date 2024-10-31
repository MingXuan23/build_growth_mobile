import 'package:build_growth_mobile/assets/style.dart';
import 'package:flutter/material.dart';

class BugTextInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final Icon prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const BugTextInput({
    Key? key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.prefixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  }) : super(key: key);

  @override
  _BugTextInputState createState() => _BugTextInputState();
}

class _BugTextInputState extends State<BugTextInput> {
  late double _fontSize;

  @override
  void initState() {
    super.initState();
    // Initialize font size based on initial controller text
    _fontSize = _calculateFontSize(widget.controller.text);

    // Add listener to update font size when text changes
    widget.controller.addListener(_updateFontSize);
  }

  @override
  void dispose() {
    // Remove listener to prevent memory leaks
    widget.controller.removeListener(_updateFontSize);
    super.dispose();
  }

  void _updateFontSize() {
    // Calculate and update font size
    setState(() {
      _fontSize = _calculateFontSize(widget.controller.text);
    });
  }

  double _calculateFontSize(String text) {
    if (widget.obscureText) {
      return ResStyle.font;
    }

    if (text.length <= ResStyle.spacing) {
      return ResStyle.body_font;
    }

    if (text.length <= ResStyle.spacing +8) {
      return ResStyle.font;
    }

    return ResStyle.medium_font;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      style: TextStyle(fontSize: _fontSize),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.prefixIcon,
        border: const OutlineInputBorder(),
        hintStyle: TextStyle(fontSize: ResStyle.body_font),
        labelStyle: TextStyle(fontSize: ResStyle.body_font),
      ),
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      validator: widget.validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return widget.hint;
            }
            return null;
          },
    );
  }
}
