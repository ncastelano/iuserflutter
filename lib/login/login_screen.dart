import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iuser/iuser_effect/iuser_effect.dart';
import 'package:iuser/registration/registration_screen.dart';
import 'package:iuser/widgets/input_text_widget.dart';
import '../authentication/authentication_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final TextEditingController emailTextEditingController = TextEditingController();
  final TextEditingController passwordTextEditingController = TextEditingController();
  final authenticationController = AuthenticationController.instanceAuth;
  bool _imageLoaded = false;
  late AnimationController _controller;
  bool showProgressBar = false;
  bool isLoginButtonActive = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();



    emailTextEditingController.addListener(_validateInputs);
    passwordTextEditingController.addListener(_validateInputs);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Só faz preload se ainda não carregou
    if (!_imageLoaded) {
      precacheImage(const AssetImage('images/logocorinverso.png'), context).then((_) {
        setState(() {
          _imageLoaded = true;
        });
      });
    }
  }


  void _validateInputs() {
    setState(() {
      isLoginButtonActive =
          emailTextEditingController.text.isNotEmpty &&
              passwordTextEditingController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    emailTextEditingController.dispose();
    passwordTextEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 100),
              if (!_imageLoaded)
                const SizedBox(height: 140) // espaço reservado (opcional)
              else
                AnimatedBuilder(
                  animation: _controller,
                  builder: (_, __) {
                    final angle = 2 * pi * _controller.value;
                    final dx = 6 * cos(angle);
                    final dy = 6 * sin(angle);

                    return Container(
                      width: 140,
                      height: 140,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: const [
                            Colors.white54,
                            Colors.white70,
                            Colors.white,
                            Colors.white60,
                            Colors.white38,
                          ],
                          transform: GradientRotation(angle),
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 1,
                            offset: Offset(dx, dy),
                          ),
                        ],
                      ),
                      child: Center(
                        child: OverflowBox(
                          maxWidth: 160,
                          maxHeight: 160,
                          child: Image.asset(
                            'images/logocorinverso.png',
                            width: 160,
                            height: 160,
                          ),
                        ),
                      ),
                    );
                  },
                ),


              const SizedBox(height: 30),

              Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: InputTextWidget(
                  textEditingController: emailTextEditingController,
                  lableString: "Email",
                  iconData: Icons.email_outlined,
                  isObscure: false,
                ),
              ),

              const SizedBox(height: 25),

              Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: InputTextWidget(
                  textEditingController: passwordTextEditingController,
                  lableString: "Senha",
                  iconData: Icons.lock_outline,
                  isObscure: true,
                ),
              ),

              const SizedBox(height: 30),
              Hero(
                tag: 'iusereffect',
                flightShuttleBuilder: (flightContext, animation, flightDirection, fromContext, toContext) {
                  final Widget heroWidget = flightDirection == HeroFlightDirection.pop
                      ? fromContext.widget
                      : toContext.widget;

                  return DefaultTextStyle(
                    style: Theme.of(flightContext).textTheme.labelLarge!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    child: heroWidget,
                  );
                },
                child: SizedBox(
                  width: 250,
                  height: 55,
                  child: IUserEffect(
                    onTap: showProgressBar || !isLoginButtonActive
                        ? null
                        : () {
                      setState(() {
                        showProgressBar = true;
                      });
                      authenticationController.loginUserNow(
                        emailTextEditingController.text,
                        passwordTextEditingController.text,
                      );
                    },
                    child: const Center(
                      child: Text(
                        "Entrar",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),





              const SizedBox(height: 30),
              const Text("Não está no iUser?", style: TextStyle(fontSize: 16, color: Colors.grey)),
              InkWell(
                onTap: () => Get.to(() => RegistrationScreen(), transition: Transition.fadeIn, duration: const Duration(milliseconds: 2000)),
                child: const Text(
                  "Faça uma conta agora!",
                  style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 30),
              const Text("utilize seu email...", style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => authenticationController.signInWithGoogle(),
                child: Image.asset("images/google.png", width: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
