import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:ilayki/screens/chat/chats_page.dart';
import 'package:ilayki/screens/home/notifications_page.dart';
import 'package:ilayki/screens/home/order_requests_screen.dart';

class UpdatesPage extends StatelessWidget {
  const UpdatesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: TabBar(
            unselectedLabelColor: const Color.fromARGB(255, 236, 201, 171),
            tabs: [
              Tab(
                  text: AppLocalizations.of(context)!.notifications,
                  icon: const Icon(Icons.notifications)),
              const Tab(text: "Requests", icon: Icon(Icons.request_page)),
              Tab(
                text: AppLocalizations.of(context)!.chat,
                icon: const Icon(Icons.chat),
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            NotificationsPage(),
            OrderRequestsScreen(),
            ChatsPage(),
          ],
        ),
      ),
    );
  }
}
