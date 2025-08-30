import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iuser/home/personal_card/profile_agenda.dart';
import 'package:iuser/home/personal_card/profile_comment.dart';
import 'package:iuser/home/personal_card/profile_flash_list.dart';
import 'package:iuser/home/personal_card/profile_links.dart';
import 'package:iuser/home/personal_card/profile_location.dart';
import 'package:iuser/home/personal_card/profile_store_or_product.dart';
import '../bottom_bar/bottom_bar.dart';
import 'personal_card_controller.dart';

class PersonalCard extends StatelessWidget {
  final String uid;

  const PersonalCard({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    // Inicializa e registra o controller no GetX
    final controller = Get.put(
      PersonalCardController(uid: uid, currentUserId: FirebaseAuth.instance.currentUser!.uid),
      tag: uid,
    );

    return Obx(() {
      if (controller.isLoading.value) {
        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        );
      }

      if (controller.userData.value == null) {
        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Text(
              'Usuário não encontrado',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }

      final data = controller.userData.value!;

      return Scaffold(
        backgroundColor: Colors.black,
        bottomNavigationBar: BottomNavBar(selectedIndex: 2),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ProfileLocation(location: data['location'] ?? 'Não informado'),

              // FOTO + NOME
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(
                        data['image'] ?? 'https://via.placeholder.com/150',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "@${data['name'] ?? 'usuario'}",
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // INFO
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        controller.followersCount.value.toString(),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Text('Seguidores', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        controller.followingCount.value.toString(),
                        style: const TextStyle(
                            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Text('Seguindo', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        data['position']?.toString() ?? '0',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Text('#Posição', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // BOTÕES
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (controller.isFollowing.value) {
                          controller.unfollow();
                        } else {
                          controller.follow();
                        }
                      },
                      child: Text(controller.isFollowing.value ? 'Deixar de seguir' : 'Seguir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.isFollowing.value ? Colors.red : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.pix, color: Colors.green),
                      label: const Text('PIX', style: TextStyle(color: Colors.green)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.green),
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              ProfileLinks(),
              ProfileAgenda(),
              ProfileFlashList(videos: controller.videos),
              ProfileStoreOrProduct(),
              ProfileComment(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    });
  }
}
