import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() =>
      _ProfileScreenState();
}

class _ProfileScreenState
    extends State<ProfileScreen> {

  bool notificationsEnabled = true;

  String companyName = "HireNova AI";
  String companyId = "HR-2026";

  @override
  Widget build(BuildContext context) {

    final user =
        FirebaseAuth.instance.currentUser;

    final themeProvider =
        Provider.of<ThemeProvider>(context);

    final isDark =
        themeProvider.isDarkMode;

    final name =
        user?.displayName ?? "HR Manager";

    final email =
        user?.email ?? "No Email";

    return Scaffold(

      backgroundColor:
          Theme.of(context)
              .scaffoldBackgroundColor,

      body: Container(

        decoration: BoxDecoration(

          gradient: LinearGradient(

            begin: Alignment.topLeft,
            end: Alignment.bottomRight,

            colors: isDark

                ? [

                    const Color(0xFF0F172A),
                    const Color(0xFF111827),
                    const Color(0xFF1E293B),
                  ]

                : [

                    const Color(0xFFF8FAFC),
                    const Color(0xFFE2E8F0),
                    const Color(0xFFCBD5E1),
                  ],
          ),
        ),

        child: SafeArea(

          child: SingleChildScrollView(

            padding: const EdgeInsets.all(20),

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                // ===========================
                // TOP BAR
                // ===========================

                Row(

                  children: [

                    Container(

                      decoration: BoxDecoration(

                        color: isDark
                            ? Colors.white.withOpacity(0.08)
                            : Colors.black.withOpacity(0.05),

                        borderRadius:
                            BorderRadius.circular(16),
                      ),

                      child: IconButton(

                        onPressed: () {

                          Navigator.pop(context);
                        },

                        icon: Icon(

                          Icons.arrow_back_ios_new_rounded,

                          color: isDark
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),

                    const Spacer(),

                    Text(

                      "Profile",

                      style: TextStyle(

                        color: isDark
                            ? Colors.white
                            : Colors.black,

                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Spacer(),
                  ],
                ),

                const SizedBox(height: 35),

                // ===========================
                // PROFILE CARD
                // ===========================

                Container(

                  width: double.infinity,

                  padding: const EdgeInsets.all(25),

                  decoration: BoxDecoration(

                    borderRadius:
                        BorderRadius.circular(30),

                    gradient: LinearGradient(

                      colors: isDark

                          ? [

                              Colors.white.withOpacity(0.12),
                              Colors.white.withOpacity(0.05),
                            ]

                          : [

                              Colors.white.withOpacity(0.9),
                              Colors.white.withOpacity(0.7),
                            ],
                    ),

                    border: Border.all(

                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.08),
                    ),
                  ),

                  child: Column(

                    children: [

                      // AVATAR

                      Container(

                        width: 110,
                        height: 110,

                        decoration: BoxDecoration(

                          shape: BoxShape.circle,

                          gradient:
                              AppColors.brandGradient,

                          boxShadow: [

                            BoxShadow(

                              color: AppColors.secondary
                                  .withOpacity(0.4),

                              blurRadius: 25,
                              spreadRadius: 2,
                            ),
                          ],
                        ),

                        child: Center(

                          child: Text(

                            name.isNotEmpty
                                ? name[0].toUpperCase()
                                : "H",

                            style: const TextStyle(

                              fontSize: 42,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      Text(

                        name,

                        style: TextStyle(

                          color: isDark
                              ? Colors.white
                              : Colors.black,

                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(

                        email,

                        style: TextStyle(

                          color: isDark
                              ? Colors.white70
                              : Colors.black54,

                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 22),

                      Container(

                        padding:
                            const EdgeInsets.symmetric(

                          horizontal: 18,
                          vertical: 10,
                        ),

                        decoration: BoxDecoration(

                          color: AppColors.secondary
                              .withOpacity(0.15),

                          borderRadius:
                              BorderRadius.circular(100),
                        ),

                        child: const Row(

                          mainAxisSize:
                              MainAxisSize.min,

                          children: [

                            Icon(

                              Icons.verified_rounded,

                              color:
                                  AppColors.secondary,

                              size: 18,
                            ),

                            SizedBox(width: 8),

                            Text(

                              "HR Administrator",

                              style: TextStyle(

                                color:
                                    AppColors.secondary,

                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // ===========================
                // SETTINGS
                // ===========================

                Text(

                  "Workspace Settings",

                  style: TextStyle(

                    color: isDark
                        ? Colors.white
                        : Colors.black,

                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 18),

                // DARK MODE

                _buildTile(

                  isDark: isDark,

                  icon:
                      Icons.dark_mode_rounded,

                  title: "Dark Mode",

                  subtitle:
                      "Switch between light and dark workspace",

                  trailing: Switch(

                    value:
                        themeProvider.isDarkMode,

                    onChanged: (value) {

                      themeProvider.toggleTheme();
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // EDIT COMPANY DETAILS

                _buildTile(

                  isDark: isDark,

                  icon:
                      Icons.edit_rounded,

                  title:
                      "Edit Company Details",

                  subtitle:
                      "Update company information",

                  onTap: () {

                    _showEditDialog(
                      context,
                    );
                  },
                ),

                const SizedBox(height: 16),

                // APP INFO

                _buildTile(

                  isDark: isDark,

                  icon:
                      Icons.security_rounded,

                  title:
                      "App Information",

                  subtitle:
                      "License, privacy policy, and agreement",

                  onTap: () {

                    _showAppInfo(context);
                  },
                ),

                const SizedBox(height: 16),

                // NOTIFICATIONS

                _buildTile(

                  isDark: isDark,

                  icon:
                      Icons.notifications_active_rounded,

                  title:
                      "Notifications",

                  subtitle:
                      notificationsEnabled
                          ? "Notifications enabled"
                          : "Notifications muted",

                  trailing: Switch(

                    value:
                        notificationsEnabled,

                    onChanged: (value) {

                      setState(() {

                        notificationsEnabled =
                            value;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 40),

                // LOGOUT BUTTON

                SizedBox(

                  width: double.infinity,

                  child: ElevatedButton(

                    style:
                        ElevatedButton.styleFrom(

                      backgroundColor:
                          AppColors.error,

                      padding:
                          const EdgeInsets.symmetric(

                        vertical: 18,
                      ),

                      shape:
                          RoundedRectangleBorder(

                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),
                    ),

                    onPressed: () async {

                      await context
                          .read<AppAuthProvider>()
                          .logout();

                      if (!context.mounted) {
                        return;
                      }

                      Navigator.pushAndRemoveUntil(

                        context,

                        MaterialPageRoute(

                          builder: (_) =>
                              const LoginScreen(),
                        ),

                        (route) => false,
                      );
                    },

                    child: const Row(

                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [

                        Icon(

                          Icons.logout_rounded,

                          color: Colors.white,
                        ),

                        SizedBox(width: 10),

                        Text(

                          "Logout",

                          style: TextStyle(

                            color: Colors.white,

                            fontSize: 18,

                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================================
  // TILE
  // ==================================

  Widget _buildTile({

    required bool isDark,
    required IconData icon,
    required String title,
    required String subtitle,

    Widget? trailing,

    VoidCallback? onTap,

  }) {

    return InkWell(

      onTap: onTap,

      borderRadius:
          BorderRadius.circular(22),

      child: Container(

        padding: const EdgeInsets.all(18),

        decoration: BoxDecoration(

          color: isDark
              ? Colors.white.withOpacity(0.06)
              : Colors.white.withOpacity(0.7),

          borderRadius:
              BorderRadius.circular(22),

          border: Border.all(

            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.08),
          ),
        ),

        child: Row(

          children: [

            Container(

              padding:
                  const EdgeInsets.all(14),

              decoration: BoxDecoration(

                gradient:
                    AppColors.brandGradient,

                borderRadius:
                    BorderRadius.circular(16),
              ),

              child: Icon(

                icon,
                color: Colors.white,
              ),
            ),

            const SizedBox(width: 18),

            Expanded(

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(

                    title,

                    style: TextStyle(

                      color: isDark
                          ? Colors.white
                          : Colors.black,

                      fontSize: 17,

                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(

                    subtitle,

                    style: TextStyle(

                      color: isDark
                          ? Colors.white70
                          : Colors.black54,

                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            trailing ??

                Icon(

                  Icons.arrow_forward_ios_rounded,

                  color: isDark
                      ? Colors.white70
                      : Colors.black54,

                  size: 18,
                ),
          ],
        ),
      ),
    );
  }

  // ==================================
  // EDIT DIALOG
  // ==================================

  void _showEditDialog(
      BuildContext context) {

    final nameController =
        TextEditingController();

    final companyController =
        TextEditingController(
      text: companyName,
    );

    final companyIdController =
        TextEditingController(
      text: companyId,
    );

    showDialog(

      context: context,

      builder: (_) {

        return AlertDialog(

          title:
              const Text("Edit Company Details"),

          content: Column(

            mainAxisSize: MainAxisSize.min,

            children: [

              TextField(
                controller: nameController,
                decoration:
                    const InputDecoration(
                  labelText: "Name",
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: companyController,
                decoration:
                    const InputDecoration(
                  labelText: "Company Name",
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: companyIdController,
                decoration:
                    const InputDecoration(
                  labelText: "Company ID",
                ),
              ),
            ],
          ),

          actions: [

            TextButton(

              onPressed: () {

                Navigator.pop(context);
              },

              child: const Text("Cancel"),
            ),

            ElevatedButton(

              onPressed: () {

                setState(() {

                  companyName =
                      companyController.text;

                  companyId =
                      companyIdController.text;
                });

                Navigator.pop(context);
              },

              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  // ==================================
  // APP INFO
  // ==================================

  void _showAppInfo(
      BuildContext context) {

    showModalBottomSheet(

      context: context,

      builder: (_) {

        return Padding(

          padding: const EdgeInsets.all(20),

          child: Column(

            mainAxisSize: MainAxisSize.min,

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: const [

              Text(

                "HireNova AI",

                style: TextStyle(

                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: 12),

              Text(
                "Version: 1.0.0",
              ),

              SizedBox(height: 10),

              Text(
                "AI Powered Recruitment Platform",
              ),

              SizedBox(height: 20),

              Text(
                "License: MIT License",
              ),

              SizedBox(height: 10),

              Text(
                "User Agreement:",
              ),

              Text(
                "Candidates must follow examination rules and malpractice may terminate assessments.",
              ),
            ],
          ),
        );
      },
    );
  }
}