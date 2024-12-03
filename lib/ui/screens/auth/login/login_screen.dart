import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:safe_mama/injection_container.dart';
import 'package:safe_mama/main.dart';
import 'package:safe_mama/models/user_model.dart';
import 'package:safe_mama/themes/main_theme.dart';
import 'package:safe_mama/ui/elements/buttons/social_login_buttons.dart';
import 'package:safe_mama/ui/elements/custom_button.dart';
import 'package:safe_mama/ui/elements/labels.dart';
import 'package:safe_mama/ui/elements/spacers.dart';
import 'package:safe_mama/ui/elements/textFields/edit_text_field.dart';
import 'package:safe_mama/ui/screens/auth/auth_view_model.dart';
import 'package:safe_mama/ui/screens/auth/login/login_view_model.dart';
import 'package:safe_mama/ui/screens/auth/signup/complete_registration_screen.dart';
import 'package:safe_mama/utils/alert_utils.dart';
import 'package:safe_mama/utils/helpers.dart';
import 'package:safe_mama/utils/l10n_extensions.dart';
import 'package:safe_mama/utils/navigation/route_names.dart';
import 'package:safe_mama/utils/validator.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginFormKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late LoginViewModel viewModel;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<LoginViewModel>(context, listen: false);

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(18),
        width: double.infinity,
        height: double.infinity,
        color: Colors.white,
        child: Stack(children: [
          SingleChildScrollView(
            child: Form(
                key: _loginFormKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ySpacer(100),
                    Image.asset(
                      'assets/images/logo.jpg',
                      width: 200.0,
                      height: 90.0,
                    ),
                    Text(
                      context.localized.login,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 32),
                    ),
                    ySpacer(30),
                    editTextLabel(context.localized.email),
                    EditTextField(
                      containerColor: MainTheme.appColors.white200,
                      textController: _usernameController,
                      validator: (value) {
                        return Validator.required(value);
                      },
                    ),
                    ySpacer(14),
                    editTextLabel(context.localized.password),
                    EditTextField(
                      obscureText: true,
                      maxLines: 1,
                      containerColor: MainTheme.appColors.white200,
                      textController: _passwordController,
                      validator: (value) {
                        return Validator.required(value);
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: InkWell(
                            onTap: () {
                              context.pushNamed(forgotPassword);
                            },
                            child: Text(
                              context.localized.forgotPassword,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ySpacer(35),
                    CustomButton(
                        width: double.infinity,
                        loading: _loading,
                        onPressed: () {
                          if (_loginFormKey.currentState?.validate() ?? false) {
                            _login();
                          }
                        },
                        child: Text(
                          context.localized.login,
                          style: const TextStyle(color: Colors.white),
                        )),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: SocialLoginButtons(
                        onGoogleSignIn: _handleGoogleSignIn,
                        onMicrosoftSignIn: _handleMicrosoftSignIn,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text('Not a member?'),
                        xSpacer(8),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          child: InkWell(
                            onTap: () => _goToSignup(),
                            child: Text(
                              context.localized.registerNow,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ySpacer(16),
                  ],
                )),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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
    );
  }

  void _goToSignup() {
    if (mounted) {
      context.pushNamed(signUp);
    }
  }

  void _login() async {
    setState(() {
      _loading = true;
    });

    final state = await viewModel.login(
        _usernameController.text, _passwordController.text);

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
        Provider.of<AuthViewModel>(context, listen: false).checkLoginStatus();
        Provider.of<AuthViewModel>(context, listen: false).getCurrentUser();
        // context.go('/$home');

        //  to restart app
        RestartWidget.restartApp(context);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _loading = true;
    });

    final state =
        await Provider.of<AuthViewModel>(context, listen: false).googleSignIn();

    setState(() {
      _loading = false;
    });
    if (!state.isSuccess && mounted) {
      AlertUtils.showError(context: context, errorMessage: state.errorMessage);
    } else {
      LOGGER.d(state.userDetails);
      await _socialSignin(state.userDetails);
    }
  }

  Future<void> _socialSignin(Map<String, dynamic> payload) async {
    final state = await viewModel.socialLogin(payload);

    if (!mounted) return;

    if (state.isSuccess) {
      LOGGER.d('Login success');
      UserModel user = state.user!;

      if (user.country == null) {
        _goToCompleteRegistration(context, payload);
      } else {
        _handleCompleteLogin();
      }
    } else {
      AlertUtils.showError(context: context, errorMessage: state.errorMessage);
    }
  }

  Future<void> _handleMicrosoftSignIn() async {
    setState(() {
      _loading = true;
    });

    final state = await Provider.of<AuthViewModel>(context, listen: false)
        .microsoftSignIn();

    setState(() {
      _loading = false;
    });

    if (!state.isSuccess && mounted) {
      AlertUtils.showError(context: context, errorMessage: state.errorMessage);
    } else {
      LOGGER.d(state.userDetails);
      await _socialSignin(state.userDetails);
    }
  }

  void _goToCompleteRegistration(
      BuildContext context, Map<String, dynamic> payload) {
    String? names = payload['name'];
    if (names != null && names.isNotEmpty) {
      Map<String, String> extractedNames = Helpers.extractNames(names);
      payload['firstName'] = extractedNames['firstName'];
      payload['lastName'] = extractedNames['lastName'];
    }

    context.pushNamed(completeRegistration,
        extra: CompleteRegistrationScreenState(
            isSocialSignup: true, socialSignupData: payload));
  }

  void _handleCompleteLogin() {
    Provider.of<AuthViewModel>(context, listen: false).checkLoginStatus();
    Provider.of<AuthViewModel>(context, listen: false).getCurrentUser();

    //  to restart app
    RestartWidget.restartApp(context);
  }
}
