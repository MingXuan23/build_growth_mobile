import 'package:build_growth_mobile/assets/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BugTextInput extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final Icon prefixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int? maxLength;
  final FocusNode? focusNode;
  final bool readOnly;
  final int maxLine ;
  final double? fontSize;
  final Widget? suffixIcon;
  final Function(String)? onChanged;
  const BugTextInput(
      {Key? key,
      required this.controller,
      required this.label,
      required this.hint,
      required this.prefixIcon,
      this.obscureText = false,
      this.keyboardType = TextInputType.text,
      this.validator,
      this.maxLength,
      this.readOnly = false,
      this.maxLine =1,
      this.fontSize,
      this.suffixIcon,
      this.onChanged,
      this.focusNode})
      : super(key: key);

  @override
  _BugTextInputState createState() => _BugTextInputState();
}

class _BugTextInputState extends State<BugTextInput> {
  late double _fontSize;

  bool view_password = false;

  @override
  void initState() {
    super.initState();
    // Initialize font size based on initial controller text
    if(widget.fontSize !=null){
      _fontSize = widget.fontSize!;
    }
    _updateFontSize();

    // Add listener to update font size when text changes
  }

  @override
  void dispose() {
    // Remove listener to prevent memory leaks

    super.dispose();
  }

  void _updateFontSize() {
    // Calculate and update font size

    if(widget.fontSize != null){
      return;
    }
    setState(() {
      _fontSize = _calculateFontSize(widget.controller.text);
    });
  }

  void _update(String value) {
    _updateFontSize();
    if (widget.onChanged != null) {
      widget.onChanged!(value); // Call onchangedfunction if provided
    }
  }

  double _calculateFontSize(String text) {
    if (widget.obscureText) {
      return ResStyle.font;
    }

    // if (text.length <= ResStyle.spacing) {
    //   return ResStyle.body_font;
    // }

    if (text.length <= ResStyle.spacing + 8) {
      return ResStyle.font;
    }

    return ResStyle.medium_font;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      onChanged: (value) => _update(value),
      style: TextStyle(fontSize: _fontSize),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: Icon(
          widget.prefixIcon.icon,
          size: ResStyle.body_font,
        ),
        border: const OutlineInputBorder(),
        hintStyle: TextStyle(fontSize: ResStyle.font),
        labelStyle: TextStyle(fontSize: ResStyle.font),
        errorStyle: TextStyle(
            fontSize: ResStyle.small_font, overflow: TextOverflow.clip),
        prefixStyle: TextStyle(fontSize: ResStyle.font),
        counterText: "",
        suffixIcon: widget.obscureText
            ? IconButton(
                icon: Icon(
                  view_password ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    view_password =
                        !view_password; // Toggle password visibility
                  });
                },
              )
            : widget.suffixIcon,
      ),
      keyboardType: widget.keyboardType,
      readOnly: widget.readOnly,
      obscureText: widget.obscureText && !view_password,
      maxLength: widget.maxLength,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      maxLines: widget.maxLine ,
      focusNode: widget.focusNode,
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

Widget BugComboBox(
    {required Function(int?) onChanged,
    required int selected_value,
    required List<DropdownMenuItem<int>> itemlist,
    required String labelText,
      String? Function(int?)? validator}) {
  return DropdownButtonFormField<int>(
    value: selected_value,
    items: itemlist,
    onChanged: (value) => onChanged(value),
    validator: validator,
    decoration: InputDecoration(
      labelText: labelText,
      border: const OutlineInputBorder(),
    ),
  );
}
