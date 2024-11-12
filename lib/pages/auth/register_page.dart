import 'package:build_growth_mobile/assets/style.dart';
import 'package:build_growth_mobile/bloc/auth/auth_bloc.dart';
import 'package:build_growth_mobile/services/location_helper.dart';
import 'package:build_growth_mobile/widget/bug_app_bar.dart';
import 'package:build_growth_mobile/widget/bug_button.dart';
import 'package:build_growth_mobile/widget/bug_text_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _telController = TextEditingController(text: "+60");
  final _addressController = TextEditingController();
  final _stateController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _codeController = TextEditingController();

  final _focusNode = FocusNode();

  String state_value = '';
  int _currentStep = 1;
  int _newStep = 1;

  // Define your list of states along with divisions
  final List<String> states_list = [
    // Peninsular Malaysia States
    "Johor",
    "Kedah",
    "Kelantan",
    "Kuala Lumpur",
    "Labuan",
    "Melaka",
    "Negeri Sembilan",
    "Pahang",
    "Perak",
    "Perlis",
    "Penang",
    "Putrajaya",
    "Selangor",
    "Terengganu",

    // Sarawak Divisions
    "Sarawak - Kuching",
    "Sarawak - Sri Aman",
    "Sarawak - Sibu",
    "Sarawak - Miri",
    "Sarawak - Limbang",
    "Sarawak - Sarikei",
    "Sarawak - Kapit",
    "Sarawak - Samarahan",
    "Sarawak - Bintulu",
    "Sarawak - Betong",
    "Sarawak - Mukah",
    "Sarawak - Serian",

    "Sabah - Beaufort",
    "Sabah - Keningau",
    "Sabah - Kuala Penyu",
    "Sabah - Membakut",
    "Sabah - Nabawan",
    "Sabah - Sipitang",
    "Sabah - Tambunan",
    "Sabah - Tenom",
    "Sabah - Kota Marudu",
    "Sabah - Pitas",
    "Sabah - Beluran",
    "Sabah - Kinabatangan",
    "Sabah - Sandakan",
    "Sabah - Telupid",
    "Sabah - Tongod",
    "Sabah - Kalabakan",
    "Sabah - Kunak",
    "Sabah - Lahad Datu",
    "Sabah - Semporna",
    "Sabah - Tawau",
    "Sabah - Kota Belud",
    "Sabah - Kota Kinabalu",
    "Sabah - Papar",
    "Sabah - Penampang",
    "Sabah - Putatan",
    "Sabah - Ranau",
    "Sabah - Tuaran",
  ];

  @override
  void initState() {
    super.initState();
    states_list.sort((a, b) => a.compareTo(b));

    _nameController.text = "mx";
    _emailController.text = "gg@gmail.com";
    _telController.text = "+601111051705";
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _telController.dispose();
    _addressController.dispose();
    _stateController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void fetchAddress() async {
    var addr = await LocationHelper.getAddress();

    if (addr.isEmpty) {
      return;
    }
    _addressController.text = addr.join(',');

    var list = states_list.where((e) => e.contains(addr.last)).toList();

    if (list.isEmpty) {
      return;
    }

    if (list.length == 1) {
      _stateController.text = list.first;
      state_value = _stateController.text;

      return;
    }

    list = states_list.where((e) => e.contains(addr[addr.length - 2])).toList();

    if (list.isNotEmpty) {
      _stateController.text = list.first;
      state_value = _stateController.text;

      return;
    }
  }

  void _nextStep() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      if (_newStep == 1) {
        ScaffoldMessenger.of(context).showSnackBar(BugSnackBar('Try Locate Your Address Instead Enter Address Manually', 5));
      }
      if (_currentStep <= 3) {
        setState(() {
          _currentStep++;
          _newStep = _currentStep;
        });
      } else {
        // Final step - register the user
        BlocProvider.of<AuthBloc>(context).add(
          RegisterRequested(
            name: _nameController.text,
            email: _emailController.text,
            telno: _telController.text,
            address: _addressController.text,
            state: _stateController.text,
            password: _passwordController.text,
          ),
        );

        if (true) {
          ScaffoldMessenger.of(context).showSnackBar(
              BugSnackBar('Register Successfully. Please Log In now.', 8));
          Navigator.of(context).pop();
        }
      }
    }
  }

  bool _isPasswordMatch() {
    return _passwordController.text == _confirmPasswordController.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Container(
                  color: RM50_COLOR,
                  child: Padding(
                    padding: EdgeInsets.all(ResStyle.spacing),
                    child: Center(
                      child: Card(
                        color: HIGHTLIGHT_COLOR,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(2 * ResStyle.spacing),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Register',
                                  style: TextStyle(
                                      fontSize: ResStyle.header_font,
                                      color: TEXT_COLOR,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: ResStyle.spacing),
                                _buildProgressIndicator(),
                                SizedBox(height: ResStyle.spacing),
                                if (_currentStep == 1) _buildStep1(),
                                if (_currentStep == 2) _buildStep2(),
                                if (_currentStep == 3) _buildStep3(),
                                if (_currentStep == 4) _buildStep4(),
                                SizedBox(height: ResStyle.spacing),
                                BugPrimaryButton(
                                  text: _currentStep != 3 ? 'Next' : 'Register',
                                  onPressed: _nextStep,
                                ),
                                SizedBox(height: ResStyle.spacing),
                                BugDoubleTapButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  text: 'Back To Log In',
                                  underline: true,
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildCircleIndicator(1),
        SizedBox(width: ResStyle.spacing),
        _buildCircleIndicator(2),
        SizedBox(width: ResStyle.spacing),
        _buildCircleIndicator(3),
        SizedBox(width: ResStyle.spacing),
        _buildCircleIndicator(4),
      ],
    );
  }

  Widget _buildCircleIndicator(int step) {
    return GestureDetector(
      onTap: () {
        if (_currentStep == 4) {
          return;
        }
        if (step < _newStep) {
          _currentStep = step;
        } else if (_newStep >= step && _formKey.currentState!.validate()) {
          _currentStep = step;
        }

        setState(() {});
      },
      child: Container(
        width: 2 * ResStyle.spacing,
        height: 2 * ResStyle.spacing,
        decoration: BoxDecoration(
          color: _currentStep == step ? Colors.blue : Colors.grey,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            step.toString(),
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildStep1() {
    return Column(
      children: [
        BugTextInput(
          controller: _nameController,
          label: "Name",
          hint: "Enter your full name",
          prefixIcon: Icon(Icons.person),
        ),
        SizedBox(height: ResStyle.spacing),
        BugTextInput(
          controller: _emailController,
          label: "Email",
          hint: "Enter your email",
          prefixIcon: Icon(Icons.email),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            final emailRegex =
                RegExp(r'^[\w\.-]+@[a-zA-Z\d\.-]+\.[a-zA-Z]{2,}$');
            if (value == null || value.isEmpty) {
              return 'Email is required';
            } else if (!emailRegex.hasMatch(value)) {
              return 'Enter a valid email';
            }
            return null;
          },
        ),
        SizedBox(height: ResStyle.spacing),
        BugTextInput(
          controller: _telController,
          label: "Telephone Number",
          hint: "Enter your telephone number",
          keyboardType: TextInputType.phone,
          prefixIcon: Icon(Icons.phone),
          maxLength: 13,
          validator: (value) {
            final phoneRegex = RegExp(r'^\+60\d{9,11}$');
            if (value == null || value.isEmpty) {
              return 'Phone number is required';
            } else if (value.length < 12 || value.length > 13) {
              return 'Invalid Phone Number';
            } else if (!phoneRegex.hasMatch(value)) {
              return 'Phone number must start with +60';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RawAutocomplete<String>(
          textEditingController: _stateController,
          focusNode: _focusNode,
          optionsBuilder: (TextEditingValue textEditingValue) {
            var list = states_list
                .where((state) =>
                    state
                        .toLowerCase()
                        .contains(textEditingValue.text.toLowerCase()) ||
                    textEditingValue.text
                        .toLowerCase()
                        .contains(state.toLowerCase()))
                .toList();

            if (list.isEmpty) {
              list = states_list;
            }
            return list;
          },
          onSelected: (selection) {
            var modification = (state_value != selection);
            _stateController.text = state_value = selection;

            if (modification) {
              _addressController.text = '';
            }
            _focusNode.unfocus();
          },
          fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
            return BugTextInput(
              controller: controller,
              focusNode: focusNode,
              label: "State",
              hint: "Enter your state name",
              prefixIcon: const Icon(Icons.map_outlined),
              suffixIcon: IconButton(
                icon: const Icon(Icons.search),
                onPressed: fetchAddress
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Enter your state name';
                } else if (!states_list.contains(value)) {
                  return 'Invalid State';
                }
                return null;
              },
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            final list = options.toList();

            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: 200,
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    shrinkWrap: true,
                    itemCount: list.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final option = list[index];
                      final isExactMatch = option.toLowerCase() ==
                          _stateController.text.toLowerCase();

                      return InkWell(
                        onTap: () => onSelected(option),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResStyle.spacing,
                            vertical: ResStyle.spacing,
                          ),
                          color: HIGHTLIGHT_COLOR,
                          child: Text(
                            option,
                            style: TextStyle(
                              fontSize: ResStyle.body_font,
                              color: TEXT_COLOR,
                              fontWeight: isExactMatch
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      
        SizedBox(height: ResStyle.spacing),
        BugTextInput(
          controller: _addressController,
          label: "Address",
          hint: "Enter your address",
          prefixIcon: const Icon(Icons.location_on_outlined),
          maxLine: 3,
          fontSize: ResStyle.medium_font,
        ),
        SizedBox(height: ResStyle.spacing),

        BugPrimaryButton(text: 'Locate Address', onPressed: fetchAddress,color: SECONDARY_COLOR)
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        BugTextInput(
          controller: _passwordController,
          label: "Password",
          hint: "Enter your password",
          obscureText: true,
          prefixIcon: Icon(Icons.lock),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password is required';
            }
            bool hasUppercase = value.contains(RegExp(r'[A-Z]'));
            bool hasLowercase = value.contains(RegExp(r'[a-z]'));
            bool hasDigits = value.contains(RegExp(r'\d'));
            bool hasSpecialCharacters = value.contains(RegExp(r'[@$!%*?&]'));
            bool hasMinLength = value.length >= 8;

            List<String> errors = [];

            if (!hasUppercase) {
              errors.add('At least one uppercase letter');
            }
            if (!hasLowercase) {
              errors.add('At least one lowercase letter');
            }
            if (!hasDigits) {
              errors.add('At least one number');
            }
            if (!hasSpecialCharacters) {
              errors.add('At least one special character');
            }
            if (!hasMinLength) {
              errors.add('At least 8 characters long');
            }

            if (errors.isNotEmpty) {
              return errors
                  .join('\n'); // Join all error messages with new lines
            }

            return null; // Return null if there are no errors
          },
        ),
        SizedBox(height: ResStyle.spacing),
        BugTextInput(
          controller: _confirmPasswordController,
          label: "Confirm Password",
          hint: "Confirm Password",
          obscureText: true,
          prefixIcon: Icon(Icons.lock),
          validator: (value) {
            if (!_isPasswordMatch()) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      children: [
        Text(
          "Please enter the verification code sent to your email",
          style: TextStyle(
            fontSize: ResStyle.medium_font,
            color: PRIMARY_COLOR,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: ResStyle.spacing),
        PinCodeTextField(
          appContext: context,
          length: 6,
          controller: _codeController,
          keyboardType: TextInputType.number,
          animationType: AnimationType.fade,
          pinTheme: PinTheme(
            shape: PinCodeFieldShape.box,
            borderRadius: BorderRadius.circular(12),
            fieldHeight: ResStyle.spacing * 2.5,
            fieldWidth: ResStyle.spacing * 2.5,
            activeFillColor: HIGHTLIGHT_COLOR,
            inactiveFillColor: HIGHTLIGHT_COLOR,
            selectedFillColor: HIGHTLIGHT_COLOR,
            activeColor: ALTERNATIVE_COLOR,
            inactiveColor: PRIMARY_COLOR,
            selectedColor: ALTERNATIVE_COLOR,
            borderWidth: 1,
          ),
          animationDuration: Duration(milliseconds: 300),
          enableActiveFill: true,
          onCompleted: (value) {
            // Handle completion
            print("Verification Code: $value");
            // TODO: Add your verification logic here
          },
          onChanged: (value) {
            // You can handle changes here if needed
          },
          beforeTextPaste: (text) {
            // Return true if you want to allow pasting
            return true;
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Verification code is required';
            }
            if (value.length != 6) {
              return 'Code must be 6 digits';
            }
            if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
              return 'Code must contain only numbers';
            }
            return null;
          },
        ),
        SizedBox(height: ResStyle.spacing),
        TextButton(
          onPressed: () {
            // TODO: Implement resend logic
          },
          child: Text(
            "Didn't receive the code? Resend",
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
