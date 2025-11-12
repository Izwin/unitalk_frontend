import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unitalk/l10n/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    PackageInfo;
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
      _buildNumber = packageInfo.buildNumber;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          l10n.aboutApp,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Icon and Name
            Center(
              child: Column(
                children: [
                  Image.asset('assets/icon/icon.png',height: 80,width: 80,),
                  const SizedBox(height: 16),
                  Text(
                    'UniTalky',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _version.isEmpty
                        ? l10n.appVersion
                        : _version,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Project Description
            _buildSection(
              context: context,
              icon: Icons.info_outline,
              title: l10n.projectDescription,
              content: l10n.aboutProjectText,
              isDark: isDark,
            ),
            const SizedBox(height: 24),

            // University Information
            _buildSection(
              context: context,
              icon: Icons.account_balance,
              title: l10n.universityInformation,
              isDark: isDark,
              customContent: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    context: context,
                    label: '${l10n.university}:',
                    value: l10n.universityName,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context: context,
                    label: '${l10n.faculty}:',
                    value: l10n.facultyName,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Course Information
            _buildSection(
              context: context,
              icon: Icons.book_outlined,
              title: l10n.courseInformation,
              isDark: isDark,
              customContent: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(
                    context: context,
                    label: l10n.subject,
                    value: l10n.brandAndAdvertising,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context: context,
                    label: l10n.group,
                    value: '787',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    context: context,
                    label: l10n.teacher,
                    value: l10n.teacherName,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Team Members
            _buildSection(
              context: context,
              icon: Icons.people_outline,
              title: l10n.projectTeam,
              isDark: isDark,
              customContent: Column(
                children: [
                  _buildTeamMember(
                    context: context,
                    name: l10n.studentName1,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildTeamMember(
                    context: context,
                    name: l10n.studentName2,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildTeamMember(
                    context: context,
                    name: l10n.studentName3,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildTeamMember(
                    context: context,
                    name: l10n.studentName4,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 12),
                  _buildTeamMember(
                    context: context,
                    name: l10n.studentName5,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Purpose
            _buildSection(
              context: context,
              icon: Icons.flag_outlined,
              title: l10n.projectPurpose,
              content: l10n.purposeText,
              isDark: isDark,
            ),
            const SizedBox(height: 32),

            // Footer
            Center(
              child: Column(
                children: [
                  Text(
                    l10n.madeWithLove,
                    style: TextStyle(
                      fontSize: 13,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2025 UniTalky',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required IconData icon,
    required String title,
    String? content,
    Widget? customContent,
    required bool isDark,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Theme.of(context).cardColor
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Theme.of(context).dividerColor.withOpacity(0.3)
              : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (content != null)
            Text(
              content,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.8),
                height: 1.6,
              ),
            ),
          if (customContent != null) customContent,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeamMember({
    required BuildContext context,
    required String name,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Theme.of(context).dividerColor.withOpacity(0.2)
              : Colors.grey[200]!,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person,
              size: 20,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            name,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }
}