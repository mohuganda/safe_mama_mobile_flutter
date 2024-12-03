import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:khub_mobile/injection_container.dart';
import 'package:khub_mobile/models/country_model.dart';
import 'package:khub_mobile/models/job_model.dart';
import 'package:khub_mobile/models/option_item_model.dart';
import 'package:khub_mobile/models/preference_model.dart';
import 'package:khub_mobile/themes/main_theme.dart';
import 'package:khub_mobile/ui/elements/countries/countries_list_search.dart';
import 'package:khub_mobile/ui/elements/custom_button.dart';
import 'package:khub_mobile/ui/elements/dropdowns/custom_card_dropdown.dart';
import 'package:khub_mobile/ui/elements/jobs/job_list_search.dart';
import 'package:khub_mobile/ui/elements/labels.dart';
import 'package:khub_mobile/ui/elements/preferences/preferences_list_search.dart';
import 'package:khub_mobile/ui/elements/spacers.dart';
import 'package:khub_mobile/ui/elements/textFields/edit_text_field.dart';
import 'package:khub_mobile/ui/main_view_model.dart';
import 'package:khub_mobile/ui/screens/auth/signup/signup_view_model.dart';
import 'package:khub_mobile/ui/screens/success/success_screen.dart';
import 'package:khub_mobile/utils/alert_utils.dart';
import 'package:khub_mobile/utils/helpers.dart';
import 'package:khub_mobile/utils/l10n_extensions.dart';
import 'package:khub_mobile/utils/navigation/route_names.dart';
import 'package:khub_mobile/utils/validator.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _signupFormKey = GlobalKey<FormState>();

  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  late SignupViewModel viewModel;
  late MainViewModel mainViewModel;

  String _selectedJob = '';
  String _selectedCountry = '';
  final List<OptionItemModel> _selectedPreferences = [];
  bool _termsChecked = false;
  String _errors = '';
  bool _loading = false;

  @override
  void initState() {
    viewModel = Provider.of<SignupViewModel>(context, listen: false);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding:
              const EdgeInsets.only(top: 8, bottom: 20, right: 18, left: 18),
          width: double.infinity,
          height: double.infinity,
          color: Colors.white,
          child: Stack(children: [
            SingleChildScrollView(
              child: Form(
                key: _signupFormKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ySpacer(10),
                    Image.asset(
                      'assets/images/logo.png',
                      width: 200.0,
                      height: 90.0,
                    ),
                    Text(
                      context.localized.register,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 32),
                    ),
                    ySpacer(30),
                    editTextLabel(context.localized.firstName),
                    EditTextField(
                      containerColor: MainTheme.appColors.white200,
                      textController: _firstNameController,
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        return Validator.required(value);
                      },
                    ),
                    ySpacer(14),
                    editTextLabel(context.localized.lastName),
                    EditTextField(
                      containerColor: MainTheme.appColors.white200,
                      textController: _lastNameController,
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        return Validator.required(value);
                      },
                    ),
                    ySpacer(14),
                    editTextLabel(context.localized.email),
                    EditTextField(
                      containerColor: MainTheme.appColors.white200,
                      textHint: '',
                      textController: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        return Validator.validateEmail(value);
                      },
                    ),
                    ySpacer(14),
                    editTextLabel(context.localized.phoneNumber),
                    EditTextField(
                      containerColor: MainTheme.appColors.white200,
                      textController: _phoneController,
                      keyboardType: TextInputType.phone,
                      textHint: '+XXX XXXXXXXXXX',
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[\d+\s]')),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final formatted =
                              Helpers.formatPhoneNumber(newValue.text);
                          return TextEditingValue(
                            text: formatted ?? '',
                            selection: TextSelection.collapsed(
                                offset: formatted?.length ?? 0),
                          );
                        }),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return context.localized.fieldRequired;
                        }
                        // Ensure it matches the format: +XX XXXXXXXXXX
                        if (!RegExp(r'^\+\d{1,3}\s\d+$').hasMatch(value)) {
                          return context.localized.invalidPhoneNumber;
                        }

                        if (value.length < 11) {
                          return context.localized.invalidPhoneNumber;
                        }
                        return null;
                      },
                    ),
                    // EditTextField(
                    //   containerColor: MainTheme.appColors.white200,
                    //   textController: _phoneController,
                    //   keyboardType: TextInputType.phone,
                    //   validator: (value) {
                    //     return Validator.validatePhone(value);
                    //   },
                    // ),
                    ySpacer(14),
                    editTextLabel(context.localized.country),
                    CustomCardDropdown(
                      onTap: () {
                        _showCountries();
                      },
                      value: _selectedCountry,
                    ),
                    ySpacer(14),
                    editTextLabel(context.localized.jobTitle),
                    CustomCardDropdown(
                      onTap: () {
                        _showJobs();
                      },
                      value: _selectedJob,
                    ),
                    ySpacer(14),
                    editTextLabel(context.localized.preferences),
                    InkWell(
                      onTap: () {
                        _showPreferences();
                      },
                      child: SizedBox(
                        width: double.infinity,
                        child: Card(
                          elevation: 0,
                          color: MainTheme.appColors.white200,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16.0, horizontal: 12.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _selectedPreferences.isNotEmpty
                                          ? Wrap(
                                              spacing: 8.0,
                                              runSpacing: 4.0,
                                              children: _selectedPreferences
                                                  .map((item) {
                                                return Chip(
                                                  deleteIconColor:
                                                      Theme.of(context)
                                                          .primaryColor,
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .primaryColor
                                                          .withOpacity(0.1),
                                                  label: Text(item.name),
                                                  onDeleted: () {
                                                    setState(() {
                                                      _selectedPreferences
                                                          .remove(item);
                                                    });
                                                  },
                                                );
                                              }).toList(),
                                            )
                                          : const SizedBox.shrink(),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down,
                                    size: 24, color: Colors.black54)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    ySpacer(14),
                    editTextLabel(context.localized.password),
                    EditTextField(
                      obscureText: true,
                      containerColor: MainTheme.appColors.white200,
                      maxLines: 1,
                      textController: _passwordController,
                      validator: (value) {
                        return Validator.required(value);
                      },
                    ),
                    ySpacer(14),
                    editTextLabel(context.localized.confirmPassword),
                    EditTextField(
                      obscureText: true,
                      containerColor: MainTheme.appColors.white200,
                      maxLines: 1,
                      textController: _confirmPasswordController,
                      validator: (value) {
                        return Validator.required(value);
                      },
                    ),
                    ySpacer(16),
                    Row(
                      children: [
                        Checkbox(
                            value: _termsChecked,
                            onChanged: (value) {
                              setState(() {
                                _termsChecked = value ?? !_termsChecked;
                              });
                            }),
                        Expanded(
                          child: Text(
                            context.localized.acceptTermsAndConditions,
                            style: const TextStyle(fontSize: 14),
                          ),
                        )
                      ],
                    ),
                    _errors.isNotEmpty
                        ? Column(
                            children: [
                              ySpacer(30),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: Text(_errors,
                                    style: TextStyle(
                                        color: MainTheme.appColors.red400,
                                        fontSize: 14)),
                              )
                            ],
                          )
                        : const SizedBox.shrink(),
                    ySpacer(50),
                    CustomButton(
                        width: double.infinity,
                        loading: _loading,
                        onPressed: () {
                          if (_signupFormKey.currentState?.validate() ??
                              false) {
                            if (_passwordController.text !=
                                _confirmPasswordController.text) {
                              setState(() {
                                _errors = context.localized.passwordsDoNotMatch;
                              });
                            } else if (!_termsChecked) {
                              setState(() {
                                _errors =
                                    context.localized.agreeToTermsAndConditions;
                              });
                            } else if (_selectedCountry.isEmpty) {
                              setState(() {
                                _errors =
                                    context.localized.pleaseSelectACountry;
                              });
                            } else if (_selectedJob.isEmpty) {
                              setState(() {
                                _errors =
                                    context.localized.pleaseSelectAJobTitle;
                              });
                            } else if (_selectedPreferences.isEmpty) {
                              setState(() {
                                _errors = context
                                    .localized.pleaseSelectAtLeastOnePreference;
                              });
                            } else {
                              _signup();
                            }
                          }
                        },
                        child: Text(
                          context.localized.register,
                          style: const TextStyle(color: Colors.white),
                        )),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
                          child: InkWell(
                            onTap: () {
                              context.pushNamed(login);
                            },
                            child: Text(
                              context.localized.loginNow,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(0.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).primaryColor.withOpacity(0.1),
                      child: IconButton(
                        icon: Icon(Icons.close,
                            color: Theme.of(context).primaryColor),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _signup() async {
    setState(() {
      _loading = true;
    });

    LOGGER.d({
      'first_name': _firstNameController.text,
      'last_name': _lastNameController.text,
      'country_id': _selectedCountry,
      'job': _selectedJob,
      'phone_number': _phoneController.text.replaceAll(RegExp(r'[^\d+]'), ''),
      'preferences':
          _selectedPreferences.map((item) => int.parse(item.id)).toList(),
      'email': _emailController.text,
      'password': _passwordController.text,
      'confirmPassword': _confirmPasswordController.text,
    });

    SignupState state = await viewModel.signUp(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        email: _emailController.text,
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        phoneNumber: _phoneController.text.replaceAll(RegExp(r'[^\d+]'), ''),
        job: _selectedJob,
        countryId: int.parse(_selectedCountry),
        preferences:
            _selectedPreferences.map((item) => int.parse(item.id)).toList());

    if (!state.isSuccess && mounted) {
      setState(() {
        _loading = false;
      });
      AlertUtils.showError(context: context, errorMessage: state.errorMessage);
    } else {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        // context.pushNamed(home);
        context.pushNamed(success,
            extra: SuccessState(
                type: 'register',
                message: context.localized.accountCreatedSuccessfully));
      }
    }
  }

  void _showJobs() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: JobListSearch(
                onJobSelected: (JobModel job) {
                  setState(() {
                    _selectedJob = job.name;
                    _errors = '';
                  });
                  Navigator.pop(context);
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showCountries() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: CountriesListSearch(
                onCountrySelected: (CountryModel country) {
                  setState(() {
                    _selectedCountry = country.name;
                    _errors = '';
                  });
                  Navigator.pop(context);
                },
              ),
            );
          },
        );
      },
    );
  }

  void _showPreferences() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: PreferencesListSearch(
                onPreferenceSelected: (PreferenceModel preference) {
                  setState(() {
                    final newPreference = OptionItemModel(
                        preference.id.toString(), preference.name);
                    if (!_selectedPreferences.contains(newPreference)) {
                      _selectedPreferences.add(newPreference);
                    }
                    _errors = '';
                  });
                  Navigator.pop(context);
                },
              ),
            );
          },
        );
      },
    );
  }
}
