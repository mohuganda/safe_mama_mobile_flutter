import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:khub_mobile/main.dart';
import 'package:khub_mobile/themes/main_theme.dart';
import 'package:khub_mobile/ui/elements/custom_button.dart';
import 'package:khub_mobile/ui/elements/labels.dart';
import 'package:khub_mobile/ui/elements/spacers.dart';
import 'package:khub_mobile/ui/elements/textFields/edit_text_field.dart';
import 'package:khub_mobile/ui/screens/auth/auth_view_model.dart';
import 'package:khub_mobile/ui/screens/auth/login/login_view_model.dart';
import 'package:khub_mobile/utils/alert_utils.dart';
import 'package:khub_mobile/utils/l10n_extensions.dart';
import 'package:khub_mobile/utils/navigation/route_names.dart';
import 'package:khub_mobile/utils/validator.dart';
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
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // @override
  // void didChangeDependencies() {
  //   super.didChangeDependencies();
  //   final provider = Provider.of<LoginViewModel>(context);
  //
  //   // Use post-frame callback to trigger navigation
  //   WidgetsBinding.instance.addPostFrameCallback((_) {
  //     if (provider.state.token.isNotEmpty) {
  //       context.pushNamed(home);
  //     }
  //   });
  // }

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
                      'assets/images/logo.png',
                      width: 200.0,
                      height: 90.0,
                    ),
                    Text(
                      context.localized.login,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 32),
                    ),
                    ySpacer(50),
                    editTextLabel(context.localized.email),
                    EditTextField(
                      containerColor: MainTheme.appColors.white200,
                      textController: _usernameController,
                      validator: (value) {
                        return Validator.required(value);
                      },
                    ),
                    ySpacer(20),
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
                    ySpacer(50),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20.0),
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
}
