
import 'package:flutter/material.dart';
import '../widgets/app_button.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userEmail;
  final bool isGuest;

  const HomeScreen({
    super.key,
    this.userEmail = '',
    this.isGuest = false,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const purple = Color(0xFF6941C6);
  static const darkPurple = Color(0xFF35245E);
  static const lightPurple = Color(0xFFF2EDFC);

  String? selectedTransport;
  String? selectedRoute;

  bool hasDemoQueue = false;

  final Map<String, List<String>> transportRoutes = {
    'Multicab': [
      'Route 1 - Sample Route',
      'Route 2 - Sample Route',
      'Route 3 - Sample Route',
    ],
    'Tricycle': [
      'Route 1 - Sample Route',
      'Route 2 - Sample Route',
    ],
  };

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  void openJoinQueue() {
    if (widget.isGuest) {
      showMessage('Please login before joining the queue.');
      return;
    }

    selectedTransport = null;
    selectedRoute = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final availableRoutes =
                selectedTransport == null
                    ? <String>[]
                    : transportRoutes[selectedTransport] ?? [];

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                22,
                24,
                22,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  const Text(
                    'Join Queue',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: darkPurple,
                    ),
                  ),

                  const SizedBox(height: 7),

                  const Text(
                    'Select your transportation and route.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Transportation',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    value: selectedTransport,
                    isExpanded: true,
                    decoration: InputDecoration(
                      hintText: 'Select transportation',
                      prefixIcon: const Icon(
                        Icons.directions_transit_rounded,
                        color: purple,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Multicab',
                        child: Text('Multicab'),
                      ),
                      DropdownMenuItem(
                        value: 'Tricycle',
                        child: Text('Tricycle'),
                      ),
                    ],
                    onChanged: (value) {
                      setSheetState(() {
                        selectedTransport = value;
                        selectedRoute = null;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Route',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  DropdownButtonFormField<String>(
                    value: selectedRoute,
                    isExpanded: true,
                    decoration: InputDecoration(
                      hintText: selectedTransport == null
                          ? 'Select transportation first'
                          : 'Select your route',
                      prefixIcon: const Icon(
                        Icons.route_rounded,
                        color: purple,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    items: availableRoutes.map((route) {
                      return DropdownMenuItem<String>(
                        value: route,
                        child: Text(
                          route,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: selectedTransport == null
                        ? null
                        : (value) {
                            setSheetState(() {
                              selectedRoute = value;
                            });
                          },
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Sample routes only. Actual routes will come '
                    'from the ParkKeys backend.',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),

                  const SizedBox(height: 26),

                  AppButton(
                    text: 'Submit Join Queue',
                    onPressed: () {
                      if (selectedTransport == null ||
                          selectedRoute == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Please select your transport and route.',
                            ),
                          ),
                        );
                        return;
                      }

                      setState(() {
                        hasDemoQueue = true;
                      });

                      Navigator.pop(sheetContext);

                      showDialog(
                        context: this.context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            icon: const Icon(
                              Icons.check_circle_rounded,
                              color: purple,
                              size: 56,
                            ),
                            title: const Text('Form Submitted'),
                            content: Text(
                              'Transport: $selectedTransport\n'
                              'Route: $selectedRoute\n\n'
                              'Demo only: no queue entry was saved '
                              'to the database.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext);
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  AppButton(
                    text: 'Cancel',
                    isOutlined: true,
                    onPressed: () {
                      Navigator.pop(sheetContext);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              color: purple,
              size: 30,
            ),
            SizedBox(width: 8),
            Text(
              'ParkKeys',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: darkPurple,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: logout,
            icon: const Icon(
              Icons.logout_rounded,
              color: purple,
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isGuest
                        ? 'Welcome, Passenger!'
                        : 'Welcome back!',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: darkPurple,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    widget.isGuest
                        ? 'You are exploring as a guest.'
                        : widget.userEmail,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // DASHBOARD BANNER
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: purple,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.directions_transit_rounded,
                          color: Colors.white,
                          size: 42,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Your journey starts here.',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 23,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Find your route and manage your queue '
                          'with ParkKeys.',
                          style: TextStyle(
                            color: Color(0xFFE7DFFF),
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  const Text(
                    'Passenger Dashboard',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkPurple,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // QUEUE SUMMARY
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFEAE5F2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 25,
                          backgroundColor: lightPurple,
                          child: Icon(
                            Icons.groups_rounded,
                            color: purple,
                            size: 28,
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Queue Summary',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: darkPurple,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                hasDemoQueue
                                    ? 'Demo queue: $selectedTransport'
                                    : 'You have no queue entry yet.',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              if (hasDemoQueue) ...[
                                const SizedBox(height: 5),
                                Text(
                                  selectedRoute ?? '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: purple,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  const Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: darkPurple,
                    ),
                  ),

                  const SizedBox(height: 14),

                  actionCard(
                    icon: Icons.confirmation_number_outlined,
                    title: 'Join Queue',
                    subtitle: 'Select transportation and route.',
                    onTap: openJoinQueue,
                  ),

                  const SizedBox(height: 12),

                  actionCard(
                    icon: Icons.access_time_rounded,
                    title: 'Queue Status',
                    subtitle: 'View your queue status and position.',
                    onTap: () {
                      showMessage(
                        hasDemoQueue
                            ? 'Demo entry only. Actual queue position '
                                'requires backend integration.'
                            : 'You have no queue entry yet.',
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  actionCard(
                    icon: Icons.map_outlined,
                    title: 'Routes',
                    subtitle: 'Explore available transport routes.',
                    onTap: () {
                      showMessage(
                        'Actual routes will be loaded from the API.',
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // GUEST ACCESS NOTICE
                  if (widget.isGuest)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: lightPurple,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Guest Access',
                            style: TextStyle(
                              color: darkPurple,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Login to access passenger features.',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 14),
                          AppButton(
                            text: 'Go to Login',
                            onPressed: logout,
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 24),

                  const Center(
                    child: Text(
                      'ParkKeys • Passenger Dashboard',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget actionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFEAE5F2),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: lightPurple,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: purple,
                  size: 27,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: darkPurple,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.chevron_right_rounded,
                color: purple,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
