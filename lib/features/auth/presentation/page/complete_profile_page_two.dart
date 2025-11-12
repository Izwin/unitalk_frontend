import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/core/ui/common/common_text_field.dart';
import 'package:unitalk/features/auth/presentation/widget/select_university_widget.dart';
import 'package:unitalk/features/university/data/models/university_model.dart';
import 'package:unitalk/features/university/presentation/manager/university_bloc.dart';
import 'package:unitalk/features/university/presentation/manager/university_state.dart';
import 'package:unitalk/l10n/app_localizations.dart';
import 'package:unitalk/l10n/bloc/locale_cubit.dart';
import '../../../university/presentation/manager/university_event.dart';

class CompleteProfilePageTwo extends StatefulWidget {
  final UniversityModel? initialUniversity;
  final Function(UniversityModel?) onUniversitySelected;

  const CompleteProfilePageTwo({
    Key? key,
    this.initialUniversity,
    required this.onUniversitySelected,
  }) : super(key: key);

  @override
  State<CompleteProfilePageTwo> createState() => _CompleteProfilePageTwoState();
}

class _CompleteProfilePageTwoState extends State<CompleteProfilePageTwo> {
  UniversityModel? _selectedUniversity;
  final _universitySearchController = TextEditingController();
  List<UniversityModel> _filteredUniversities = [];

  @override
  void initState() {
    super.initState();
    _selectedUniversity = widget.initialUniversity;
    _universitySearchController.addListener(_filterUniversities);
    context.read<UniversityBloc>().add(LoadUniversitiesEvent());
  }

  @override
  void dispose() {
    _universitySearchController.dispose();
    super.dispose();
  }

  void _filterUniversities() {
    final state = context.read<UniversityBloc>().state;
    if (state.universities.isEmpty) return;

    final query = _universitySearchController.text.toLowerCase();
    final locale = context.read<LocaleCubit>().state.languageCode;

    setState(() {
      if (query.isEmpty) {
        _filteredUniversities = state.universities;
      } else {
        _filteredUniversities = state.universities.where((university) {
          final name = university.getLocalizedName(locale).toLowerCase();
          return name.contains(query);
        }).toList();
      }
    });
  }

  void _selectUniversity(UniversityModel university) {
    setState(() => _selectedUniversity = university);
    widget.onUniversitySelected(university);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.selectYourUniversity,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.chooseUniversityYouAttend,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 24),

                CommonTextField(
                  controller: _universitySearchController,
                  hint: l10n.searchUniversities,
                  icon: Icons.search,
                ),
              ],
            ),
          ),
          _buildUniversityList(theme, l10n),
        ],
      ),
    );
  }

  Widget _buildUniversityList(ThemeData theme, AppLocalizations l10n) {
    return BlocConsumer<UniversityBloc, UniversityState>(
      listener: (context, state) {
        if (state.status == UniversityStatus.success &&
            state.universities.isNotEmpty) {
          if (_filteredUniversities.isEmpty) {
            setState(() {
              _filteredUniversities = state.universities;
            });
          }
        }
      },
      builder: (context, state) {
        if (state.status == UniversityStatus.loading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(48.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state.status == UniversityStatus.failure) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? l10n.failedToLoadUniversities,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<UniversityBloc>().add(LoadUniversitiesEvent());
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(l10n.retry),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(120, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (_filteredUniversities.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off_rounded,
                    size: 64,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.noUniversitiesFound,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: _filteredUniversities.length,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemBuilder: (context, index) {
            final university = _filteredUniversities[index];
            final isSelected = _selectedUniversity?.id == university.id;

            return SelectUniversityWidget(
              universityModel: university,
              isSelected: isSelected,
              onTap: (university) => _selectUniversity(university),
            );
          },
          separatorBuilder: (context, index) {
            return const SizedBox(height: 10);
          },
        );
      },
    );
  }
}