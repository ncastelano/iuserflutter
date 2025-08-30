import 'package:flutter/material.dart';
import 'package:get/get.dart';

class QuestionnaireController extends GetxController {
  // Etapa atual
  var step = 0.obs;

  // Tipo escolhido
  var choice = ''.obs;

  // Valor digitado
  var inputValue = ''.obs;

  void selectChoice(String value) {
    choice.value = value;
    step.value = 1;
  }

  void confirmInput() {
    if (inputValue.value.trim().isNotEmpty) {
      step.value++;
    }
  }
}

class Questionnaire extends StatelessWidget {
  Questionnaire({super.key});

  final controller = Get.put(QuestionnaireController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Obx(() {
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            transitionBuilder: (child, animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: _buildStep(controller.step.value),
          );
        }),
      ),
    );
  }

  Widget _buildStep(int step) {
    switch (step) {
      case 0:
        return _choiceStep();
      case 1:
        return _inputStep();
      default:
        return _finalStep();
    }
  }

  Widget _choiceStep() {
    return Column(
      key: const ValueKey("choiceStep"),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "O que deseja fazer?",
          style: TextStyle(color: Colors.white, fontSize: 22),
        ),
        const SizedBox(height: 20),
        _choiceButton("Adicionar um Flash"),
        _choiceButton("Adicionar um Produto"),
        _choiceButton("Criar uma Loja"),
      ],
    );
  }

  Widget _choiceButton(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: () => controller.selectChoice(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        child: Text(text),
      ),
    );
  }

  Widget _inputStep() {
    String label = "";
    if (controller.choice.value == "Adicionar um Flash") {
      label = "Descrição do Flash";
    } else if (controller.choice.value == "Adicionar um Produto") {
      label = "Nome do Produto ou Serviço";
    } else {
      label = "Nome da Loja";
    }

    return Column(
      key: const ValueKey("inputStep"),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 220,
              child: TextField(
                style: const TextStyle(color: Colors.white),
                onChanged: (value) => controller.inputValue.value = value,
                decoration: InputDecoration(
                  hintText: "Digite aqui...",
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green, size: 36),
              onPressed: controller.confirmInput,
            ),
          ],
        ),
      ],
    );
  }

  Widget _finalStep() {
    return Column(
      key: const ValueKey("finalStep"),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.check_circle, color: Colors.green, size: 80),
        const SizedBox(height: 20),
        Text(
          "Pronto! Você escolheu:\n${controller.choice.value}\nCom valor:\n${controller.inputValue.value}",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
      ],
    );
  }
}
