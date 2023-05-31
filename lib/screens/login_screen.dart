import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:ilayki/blocs/user/user_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ilayki/screens/register_screen.dart';

import '../app.dart';
import '../blocs/localization/localization_cubit.dart';

class LoginScreen extends StatefulWidget {
  // route name
  static const routeName = '/login';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Text Field Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Localization cubit
    final LocalizationCubit cubit = context.watch<LocalizationCubit>();

    /* Locales Dropdown */
    final SupportedLocales dropdownValue = SupportedLocales.values.firstWhere(
      (element) => describeEnum(element) == cubit.state.locale,
    );

    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return BlocListener<UserBloc, UserState>(
      listener: (context, state) {
        // In case of error
        switch (state.state) {
          case UserStates.signedIn:
            // clear the controllers
            _emailController.clear();
            _passwordController.clear();

            // Pop the progress indicator
            Navigator.of(context).popUntil(ModalRoute.withName(LoginScreen.routeName));
            // and push the screen
            Navigator.of(context).pushNamed(App.routeName);
            break;
          case UserStates.error:
            // Incase of error pop the routes (which will contain progress indicator mostly)
            // until login screen and show the snack bar with the error
            Navigator.of(context).popUntil(ModalRoute.withName(LoginScreen.routeName));
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                state.error!.message!,
                textAlign: TextAlign.center,
              ),
            ));
            break;
          case UserStates.processing:
            // Show the Dialog presenting progress indicator
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (_) => Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      ),
                    ));
            break;
          default:
            break;
        }
      },
      child: Scaffold(
        /* App Bar */
        appBar: AppBar(
          leading: Center(
            child: Text(
              AppLocalizations.of(context)!.welcome,
              style: TextStyle(
                fontSize: 22.spMax,
              ),
            ),
          ),
          leadingWidth: 0.3.sw,
          foregroundColor: const Color.fromARGB(255, 236, 201, 171),
          shadowColor: const Color.fromARGB(255, 244, 217, 185),

          // Locales
          actions: [
            /* Dropdown Button for changing the locale for the application */
            DropdownButton(
              iconSize: 16.spMax,
              elevation: 1,
              value: dropdownValue,

              // Update the cubit state with the locale selected by the user
              onChanged: (value) {
                if (value != null) cubit.updateLocale(value);
              },
              items: [
                DropdownMenuItem(
                  value: SupportedLocales.en,
                  child: Image.asset(
                    'lib/assets/flags/us.png',
                    fit: BoxFit.scaleDown,
                    height: 16.spMax,
                  ),
                ),
                DropdownMenuItem(
                  value: SupportedLocales.ar,
                  child: Image.asset(
                    'lib/assets/flags/sa.png',
                    fit: BoxFit.scaleDown,
                    height: 16.spMax,
                  ),
                ),
                DropdownMenuItem(
                  value: SupportedLocales.fr,
                  child: Image.asset(
                    'lib/assets/flags/fr.png',
                    fit: BoxFit.scaleDown,
                    height: 16.spMax,
                  ),
                ),
              ],
            ),
          ],
        ),
        body: // Form Global Key
            Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: !isLandscape ? 0.08.sw : 0.3.sw,
              vertical: 128.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Ilyaki',
                  style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                SizedBox(height: 172.h),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    label: Text(AppLocalizations.of(context)!.email),
                  ),
                ),
                SizedBox(height: 24.h),
                TextField(
                  obscureText: true,
                  controller: _passwordController,
                  decoration: InputDecoration(
                    label: Text(AppLocalizations.of(context)!.password),
                  ),
                ),
                SizedBox(height: 96.h),
                ElevatedButton(
                  onPressed: () {
                    context.read<UserBloc>().add(UserSignInWithEmailAndPassword(
                          email: _emailController.text,
                          password: _passwordController.text,
                        ));
                  },
                  style: TextButton.styleFrom(
                    elevation: 4,
                  ),
                  child: Text(AppLocalizations.of(context)!.signIn),
                ),
                // const Divider(height: 60),
                // Text(
                //   AppLocalizations.of(context)!.orElse,
                //   style: Theme.of(context).textTheme.titleLarge!.copyWith(
                //         color: Colors.black54,
                //       ),
                // ),
                // const SizedBox(height: 20),
                // ElevatedButton(
                //   onPressed: () => context.read<UserBloc>().add(UserSignInWithGoogle()),
                //   style: ButtonStyle(
                //     shadowColor: MaterialStateProperty.all(Colors.white),
                //     backgroundColor:
                //         MaterialStateProperty.all(const Color.fromARGB(255, 244, 217, 185)),
                //     padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 6)),
                //     fixedSize: MaterialStateProperty.all(const Size.fromWidth(200)),
                //     shape: MaterialStateProperty.all(
                //         RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //     crossAxisAlignment: CrossAxisAlignment.center,
                //     children: [
                //       Text(
                //         AppLocalizations.of(context)!.continueWithGoogle,
                //         style: const TextStyle(fontWeight: FontWeight.bold),
                //       ),
                //       CircleAvatar(
                //         radius: 14,
                //         backgroundColor: Colors.white,
                //         child: Image(
                //           isAntiAlias: true,
                //           image: Image.asset("lib/assets/icons/google_G_logo.png").image,
                //           fit: BoxFit.scaleDown,
                //           height: 20,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              ],
            ),
          ),
        ),
        persistentFooterButtons: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(AppLocalizations.of(context)!.notRegistered),
              TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const RegisterScreen(),
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.registerHere),
              )
            ],
          ),
        ],
      ),
    );
  }
}