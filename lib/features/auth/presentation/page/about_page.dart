import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:unitalk/features/about_config/data/model/about_config_model.dart';
import 'package:unitalk/features/about_config/presentation/bloc/about_config_bloc.dart';
import 'package:unitalk/features/about_config/presentation/bloc/about_config_event.dart';
import 'package:unitalk/features/about_config/presentation/bloc/about_config_state.dart';
import 'package:unitalk/l10n/app_localizations.dart';
import 'package:unitalk/l10n/bloc/locale_cubit.dart';


class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
    context.read<AboutConfigBloc>().add(LoadAboutConfigEvent());
  }

  Future<void> _loadPackageInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() => _version = packageInfo.version);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = context.watch<LocaleCubit>().state.languageCode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Theme.of(context).textTheme.bodyLarge?.color),
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
      body: BlocBuilder<AboutConfigBloc, AboutConfigState>(
        builder: (context, state) {
          if (state.status == AboutConfigStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == AboutConfigStatus.failure || state.config == null) {
            return _buildErrorState(context, state.errorMessage);
          }

          final config = state.config!;

          return RefreshIndicator(
            onRefresh: () async {
              context.read<AboutConfigBloc>().add(RefreshAboutConfigEvent());
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(24.0),
              child: config.isStudentProject
                  ? _buildStudentProjectMode(context, config, locale, isDark, l10n)
                  : _buildProductionMode(context, config, locale, isDark, l10n),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // СТУДЕНЧЕСКИЙ ПРОЕКТ
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildStudentProjectMode(
      BuildContext context,
      AboutConfigModel config,
      String locale,
      bool isDark,
      AppLocalizations l10n,
      ) {
    final student = config.studentProject!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, config),
        const SizedBox(height: 32),

        // Project Description
        if (student.projectDescription != null)
          _buildSection(
            context: context,
            icon: Icons.info_outline,
            title: l10n.projectDescription,
            content: student.projectDescription!.get(locale),
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
                label: l10n.university,
                value: student.universityName?.get(locale) ?? '',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                context: context,
                label: l10n.faculty,
                value: student.facultyName?.get(locale) ?? '',
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
                value: student.courseName?.get(locale) ?? '',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                context: context,
                label: l10n.group,
                value: student.groupNumber ?? '',
                isDark: isDark,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                context: context,
                label: l10n.teacher,
                value: student.teacherName?.get(locale) ?? '',
                isDark: isDark,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Team Members
        if (student.teamMembers != null && student.teamMembers!.isNotEmpty)
          _buildSection(
            context: context,
            icon: Icons.people_outline,
            title: l10n.projectTeam,
            isDark: isDark,
            customContent: Column(
              children: student.teamMembers!
                  .map((member) => _buildTeamMemberSimple(
                context: context,
                name: member.getName(locale),
                isDark: isDark,
              ))
                  .toList(),
            ),
          ),
        const SizedBox(height: 24),

        // Purpose
        if (student.projectPurpose != null)
          _buildSection(
            context: context,
            icon: Icons.flag_outlined,
            title: l10n.projectPurpose,
            content: student.projectPurpose!.get(locale),
            isDark: isDark,
          ),
        const SizedBox(height: 32),

        _buildFooter(
          context: context,
          text: student.footerText?.get(locale) ?? l10n.madeWithLove,
          year: student.projectYear ?? '2025',
          appName: config.appName ?? 'UniTalky',
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ПРОДАКШН
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildProductionMode(
      BuildContext context,
      AboutConfigModel config,
      String locale,
      bool isDark,
      AppLocalizations l10n,
      ) {
    final prod = config.production!;

    final features = [
      _FeatureItem(Icons.chat_bubble_outline, l10n.aboutFeatureChat),
      _FeatureItem(Icons.people_outline, l10n.aboutFeatureFriends),
      _FeatureItem(Icons.emoji_events_outlined, l10n.aboutFeatureBadges),
      _FeatureItem(Icons.article_outlined, l10n.aboutFeatureFeed),
      _FeatureItem(Icons.verified_user_outlined, l10n.aboutFeatureVerification),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context, config),
        const SizedBox(height: 32),

        // App Description
        if (prod.appDescription != null)
          _buildSection(
            context: context,
            icon: Icons.info_outline,
            title: l10n.aboutApp,
            content: prod.appDescription!.get(locale),
            isDark: isDark,
          ),
        const SizedBox(height: 24),

        // Features
        _buildSection(
          context: context,
          icon: Icons.star_outline,
          title: l10n.aboutWhatCanYouDo,
          isDark: isDark,
          customContent: Column(
            children: features
                .map((f) => _buildFeatureRow(
              context: context,
              icon: f.icon,
              text: f.text,
              isDark: isDark,
            ))
                .toList(),
          ),
        ),
        const SizedBox(height: 32),

        _buildFooter(
          context: context,
          text: prod.footerText?.get(locale) ?? '',
          year: prod.copyrightYear ?? '2025',
          appName: config.appName ?? 'UniTalky',
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // ВИДЖЕТЫ (с исправленным overflow)
  // ═══════════════════════════════════════════════════════════════════════════

  Widget _buildHeader(BuildContext context, AboutConfigModel config) {
    return Center(
      child: Column(
        children: [
          Image.asset('assets/icon/icon.png', height: 80, width: 80),
          const SizedBox(height: 16),
          Text(
            config.appName ?? 'UniTalky',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          if (config.showVersion == true && _version.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              _version,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
            ),
          ],
        ],
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
        color: isDark ? Theme.of(context).cardColor : Colors.grey[50],
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
          // Header row - FIXED OVERFLOW
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: Theme.of(context).primaryColor),
              ),
              const SizedBox(width: 12),
              Expanded(  // ← Добавлен Expanded
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  maxLines: 2,  // ← Ограничение строк
                  overflow: TextOverflow.ellipsis,  // ← На случай если всё равно не влезет
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

  // Info row - FIXED OVERFLOW (вертикальная раскладка)
  Widget _buildInfoRow({
    required BuildContext context,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  // Team member - FIXED OVERFLOW
  Widget _buildTeamMemberSimple({
    required BuildContext context,
    required String name,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
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
            Expanded(  // ← Добавлен Expanded
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Feature row - FIXED OVERFLOW
  Widget _buildFeatureRow({
    required BuildContext context,
    required IconData icon,
    required String text,
    required bool isDark,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,  // ← Выравнивание сверху
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: Theme.of(context).primaryColor),
          ),
          const SizedBox(width: 12),
          Expanded(  // ← Добавлен Expanded
            child: Padding(
              padding: const EdgeInsets.only(top: 10),  // ← Выравнивание по центру иконки
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter({
    required BuildContext context,
    required String text,
    required String year,
    required String appName,
  }) {
    return Center(
      child: Column(
        children: [
          if (text.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.5),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            '© $year $appName',
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String? message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64,
                color: Theme.of(context).colorScheme.error.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              message ?? 'An error occurred',
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<AboutConfigBloc>().add(LoadAboutConfigEvent()),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem {
  final IconData icon;
  final String text;
  _FeatureItem(this.icon, this.text);
}