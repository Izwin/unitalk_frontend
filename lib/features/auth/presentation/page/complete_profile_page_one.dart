import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/core/ui/common/common_text_field.dart';
import 'package:unitalk/core/ui/common/radio_selector_card.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/l10n/app_localizations.dart';
import 'package:unitalk/l10n/bloc/locale_cubit.dart';

class CompleteProfilePageOne extends StatefulWidget {
  final String? initialFirstName;
  final String? initialLastName;
  final Sector? initialSector;
  final Function({String? firstName, String? lastName, Sector? sector})
  onDataChanged;

  const CompleteProfilePageOne({
    Key? key,
    this.initialFirstName,
    this.initialLastName,
    this.initialSector,
    required this.onDataChanged,
  }) : super(key: key);

  @override
  State<CompleteProfilePageOne> createState() => _CompleteProfilePageOneState();
}

class _CompleteProfilePageOneState extends State<CompleteProfilePageOne> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  Sector? _selectedSector;

  late bool _hasFirstName;
  late bool _hasLastName;

  @override
  void initState() {
    super.initState();

    final names = _extractNamesFromFirebase();

    _hasFirstName = names.$1.isNotEmpty;
    _hasLastName = names.$2.isNotEmpty;

    _firstNameController = TextEditingController(text: names.$1);
    _lastNameController = TextEditingController(text: names.$2);
    _selectedSector = widget.initialSector;

    _firstNameController.addListener(_notifyParent);
    _lastNameController.addListener(_notifyParent);

    // Если имя и фамилия уже есть, сразу уведомляем родителя
    if (_hasFirstName && _hasLastName) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _notifyParent();
      });
    }
  }

  /// Улучшенная функция извлечения имени и фамилии
  (String, String) _extractNamesFromFirebase() {
    var user = FirebaseAuth.instance.currentUser;

    print('=== Apple Sign In Debug ===');
    print('User UID: ${user?.uid}');
    print('Display Name: ${user?.displayName}');
    print('Provider Data: ${user?.providerData.map((e) => '${e.providerId}: displayName="${e.displayName}"')}');

    String firstName = '';
    String lastName = '';

    // Стратегия 1: Проверяем displayName на уровне пользователя
    if (user?.displayName != null && user!.displayName!.trim().isNotEmpty) {
      final nameParts = user.displayName!.trim().split(RegExp(r'\s+'));
      firstName = nameParts.elementAtOrNull(0) ?? '';
      lastName = nameParts.skip(1).join(' '); // Все остальное - фамилия

      print('Strategy 1 (user.displayName): firstName="$firstName", lastName="$lastName"');

      if (firstName.isNotEmpty) {
        return (firstName, lastName);
      }
    }

    // Стратегия 2: Проверяем providerData для apple.com
    final appleProvider = user?.providerData
        .where((provider) => provider.providerId == 'apple.com')
        .firstOrNull;

    if (appleProvider?.displayName != null && appleProvider!.displayName!.trim().isNotEmpty) {
      final nameParts = appleProvider.displayName!.trim().split(RegExp(r'\s+'));
      firstName = nameParts.elementAtOrNull(0) ?? '';
      lastName = nameParts.skip(1).join(' ');

      print('Strategy 2 (apple.com provider): firstName="$firstName", lastName="$lastName"');

      if (firstName.isNotEmpty) {
        return (firstName, lastName);
      }
    }

    // Стратегия 3: Проверяем любого провайдера с displayName
    final anyProvider = user?.providerData
        .where((e) => e.displayName != null && e.displayName!.trim().isNotEmpty)
        .firstOrNull;

    if (anyProvider?.displayName != null) {
      final nameParts = anyProvider!.displayName!.trim().split(RegExp(r'\s+'));
      firstName = nameParts.elementAtOrNull(0) ?? '';
      lastName = nameParts.skip(1).join(' ');

      print('Strategy 3 (any provider): firstName="$firstName", lastName="$lastName"');
    }

    print('Final result: firstName="$firstName", lastName="$lastName"');
    print('=== End Debug ===');

    return (firstName, lastName);
  }

  /// Определяет язык для сектора
  Locale _getLocaleForSector(Sector sector) {
    switch (sector) {
      case Sector.english:
        return const Locale('en');
      case Sector.russian:
        return const Locale('ru');
      case Sector.azerbaijani:
        return const Locale('az');
    }
  }

  /// Автоматическая смена языка при выборе сектора
  void _onSectorSelected(Sector sector) {
    setState(() => _selectedSector = sector);

    // Меняем язык в соответствии с сектором
    final newLocale = _getLocaleForSector(sector);
    context.read<LocaleCubit>().changeLocale(newLocale);

    _notifyParent();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _notifyParent() {
    widget.onDataChanged(
      firstName: _firstNameController.text.trim().isEmpty
          ? null
          : _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim().isEmpty
          ? null
          : _lastNameController.text.trim(),
      sector: _selectedSector,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final showNameFields = !_hasFirstName || !_hasLastName;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            showNameFields ? l10n.welcome : l10n.selectSector,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            showNameFields
                ? l10n.completeProfileSubtitle
                : l10n.selectSector,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 40),

          if (!_hasFirstName) ...[
            CommonTextField(
              controller: _firstNameController,
              label: l10n.firstName,
              hint: l10n.firstNameHint,
              icon: Icons.person_outline,
              onChanged: (_) => _notifyParent(),
            ),
            const SizedBox(height: 20),
          ],

          if (!_hasLastName) ...[
            CommonTextField(
              controller: _lastNameController,
              label: l10n.lastName,
              hint: l10n.lastNameHint,
              icon: Icons.person_outline,
              onChanged: (_) => _notifyParent(),
            ),
            const SizedBox(height: 32),
          ],

          Text(
            l10n.sector,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),

          ...Sector.values.map((sector) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RadioSelectorItem(
              title: '${sector.flagEmoji}  ${sector.displayName}',
              isSelected: _selectedSector == sector,
              onTap: () => _onSectorSelected(sector),
            ),
          )),
        ],
      ),
    );
  }
}