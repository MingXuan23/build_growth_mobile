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
  final int maxLine;
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
      this.maxLine = 1,
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
    if (widget.fontSize != null) {
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

    if (widget.fontSize != null) {
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
      cursorColor: SECONDARY_COLOR,
      onChanged: (value) => _update(value),
      style: TextStyle(fontSize: _fontSize, color: widget.readOnly?SECONDARY_COLOR:TEXT_COLOR),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,

        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: SECONDARY_COLOR, // Set your desired color here
            width: 2.0, // Set border width if needed
          ),
        ),
        prefixIcon: Icon(
          widget.prefixIcon.icon,
          size: ResStyle.body_font,
        ),
        border: const OutlineInputBorder(),
        hintStyle: TextStyle(fontSize: ResStyle.font),
        floatingLabelStyle: TextStyle(color: TEXT_COLOR,fontSize: ResStyle.font),
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
      maxLines: widget.maxLine,
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

class BugSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const BugSwitch({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Define thumbIcon using `MaterialStateProperty`
    final WidgetStateProperty<Icon?> thumbIcon =
        WidgetStateProperty.resolveWith<Icon?>(
      (Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return const Icon(
            Icons.check,
            color: HIGHTLIGHT_COLOR,
          );
        }
        return const Icon(Icons.close);
      },
    );

    return Switch(
      thumbIcon: thumbIcon,
      activeColor: SUCCESS_COLOR,
      inactiveTrackColor: PRIMARY_COLOR,
      inactiveThumbColor: TITLE_COLOR,
      value: value,
      onChanged: onChanged,
    );
  }
}
