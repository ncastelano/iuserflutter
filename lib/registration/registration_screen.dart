import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:simple_circular_progress_bar/simple_circular_progress_bar.dart';
import 'package:iuser/authentication/authentication_controller.dart';
import 'package:iuser/widgets/verification_namepage.dart';
import 'package:iuser/widgets/input_password_widget.dart';
import 'package:iuser/widgets/input_text_widget.dart';
import 'package:iuser/login/login_screen.dart';
import '../iuser_effect/iuser_effect.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({Key? key}) : super(key: key);

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final userNameTextEditingController = TextEditingController();
  final emailTextEditingController = TextEditingController();
  final passwordTextEditingController = TextEditingController();
  final confirmPasswordTextEditingController = TextEditingController();
  final authenticationController = AuthenticationController.instanceAuth;

  bool showProgressBar = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 100),

              // Imagem de perfil
              GestureDetector(
                onTap: () => authenticationController.chooseImageFromGallery(),
                child: Obx(() {
                  return CircleAvatar(
                    radius: 80,
                    backgroundColor: Colors.black,
                    backgroundImage: authenticationController.profileImage != null
                        ? FileImage(authenticationController.profileImage!)
                        : null,
                    child: authenticationController.profileImage == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.camera_alt, size: 50, color: Colors.white70),
                        SizedBox(height: 8),
                        Text(
                          'Selecionar\nimagem',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    )
                        : null,
                  );
                }),
              ),

              const SizedBox(height: 30),

              PageNameInputWidget(controller: userNameTextEditingController),

              const SizedBox(height: 25),

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
                child: InputPasswordWidget(
                  controller: passwordTextEditingController,
                ),
              ),

              const SizedBox(height: 20),

              // Confirmar senha com mesmo estilo
              Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: confirmPasswordTextEditingController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "Confirme sua senha",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: Icon(
                      confirmPasswordTextEditingController.text ==
                          passwordTextEditingController.text
                          ? Icons.check_circle
                          : Icons.error_outline,
                      color: confirmPasswordTextEditingController.text.isEmpty
                          ? Colors.grey
                          : confirmPasswordTextEditingController.text ==
                          passwordTextEditingController.text
                          ? Colors.green
                          : Colors.red,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  onChanged: (value) => setState(() {}),
                ),
              ),

              if (confirmPasswordTextEditingController.text.isNotEmpty &&
                  confirmPasswordTextEditingController.text !=
                      passwordTextEditingController.text)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    "As senhas não coincidem",
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                  ),
                ),

              const SizedBox(height: 30),

              // Botão Criar Conta
              if (!showProgressBar)
                Column(
                  children: [
                    Hero(
                      tag: 'iusereffect',
                      flightShuttleBuilder: (context, animation, direction, fromContext, toContext) {
                        final widget = direction == HeroFlightDirection.pop
                            ? fromContext.widget
                            : toContext.widget;
                        return DefaultTextStyle(
                          style: Theme.of(context).textTheme.labelLarge!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                          child: widget,
                        );
                      },
                      child: SizedBox(
                        width: 250,
                        height: 55,
                        child: IUserEffect(
                          onTap: () {
                            if (authenticationController.profileImage != null &&
                                userNameTextEditingController.text.isNotEmpty &&
                                emailTextEditingController.text.isNotEmpty &&
                                passwordTextEditingController.text.isNotEmpty &&
                                confirmPasswordTextEditingController.text ==
                                    passwordTextEditingController.text) {
                              setState(() => showProgressBar = true);

                              authenticationController.createAccountForNewUser(
                                authenticationController.profileImage!,
                                userNameTextEditingController.text.trim(),
                                emailTextEditingController.text.trim(),
                                passwordTextEditingController.text.trim(),
                              );
                            }
                          },
                          child: const Center(
                            child: Text(
                              'Criar conta',
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

                    InkWell(
                      onTap: () {
                        Get.to(LoginScreen(), transition: Transition.fadeIn, duration: const Duration(milliseconds: 2000));
                      },
                      child: const Text(
                        "Já tem uma conta?",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              else
                const SimpleCircularProgressBar(
                  progressColors: [
                    Colors.green,
                    Colors.blueAccent,
                    Colors.red,
                    Colors.amber,
                    Colors.purpleAccent,
                  ],
                  animationDuration: 3,
                  backColor: Colors.white38,
                ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
