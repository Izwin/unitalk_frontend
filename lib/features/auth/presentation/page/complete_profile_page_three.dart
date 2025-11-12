import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/core/ui/common/common_text_field.dart';
import 'package:unitalk/features/auth/presentation/widget/select_faculty_widget.dart';
import 'package:unitalk/features/faculty/data/models/faculty_model.dart';
import 'package:unitalk/features/university/presentation/manager/university_bloc.dart';
import 'package:unitalk/features/university/presentation/manager/university_state.dart';
import 'package:unitalk/l10n/app_localizations.dart';
import 'package:unitalk/l10n/bloc/locale_cubit.dart';

class CompleteProfilePageThree extends StatefulWidget {
  final FacultyModel? initialFaculty;
  final Function(FacultyModel?) onFacultySelected;

  const CompleteProfilePageThree({
    Key? key,
    this.initialFaculty,
    required this.onFacultySelected,
  }) : super(key: key);

  @override
  State<CompleteProfilePageThree> createState() =>
      _CompleteProfilePageThreeState();
}

class _CompleteProfilePageThreeState extends State<CompleteProfilePageThree> {
  FacultyModel? _selectedFaculty;
  final _facultySearchController = TextEditingController();
  List<FacultyModel> _filteredFaculties = [];

  @override
  void initState() {
    super.initState();
    _selectedFaculty = widget.initialFaculty;
    _facultySearchController.addListener(_filterFaculties);
  }

  @override
  void dispose() {
    _facultySearchController.dispose();
    super.dispose();
  }

  void _filterFaculties() {
    final state = context.read<UniversityBloc>().state;
    if (state.faculties.isEmpty) return;

    final query = _facultySearchController.text.toLowerCase();
    final locale = context.read<LocaleCubit>().state.languageCode;

    setState(() {
      if (query.isEmpty) {
        _filteredFaculties = state.faculties;
      } else {
        _filteredFaculties = state.faculties.where((faculty) {
          final name = faculty.getLocalizedName(locale).toLowerCase();
          return name.contains(query);
        }).toList();
      }
    });
  }

  void _selectFaculty(FacultyModel faculty) {
    setState(() => _selectedFaculty = faculty);
    widget.onFacultySelected(faculty);
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
                  l10n.selectYourFaculty,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.chooseYourFieldOfStudy,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 24),

                CommonTextField(
                  controller: _facultySearchController,
                  hint: l10n.searchFaculties,
                  icon: Icons.search,
                ),
              ],
            ),
          ),
          _buildFacultyList(theme, l10n),
        ],
      ),
    );
  }

  Widget _buildFacultyList(ThemeData theme, AppLocalizations l10n) {
    return BlocConsumer<UniversityBloc, UniversityState>(
      listener: (context, state) {
        if (state.status == UniversityStatus.success &&
            state.faculties.isNotEmpty) {
          if (_filteredFaculties.isEmpty) {
            setState(() {
              _filteredFaculties = state.faculties;
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
                    state.errorMessage ?? l10n.failedToLoadFaculties,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Retry requires university ID from parent
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

        if (_filteredFaculties.isEmpty) {
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
                    l10n.noFacultiesFound,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: _filteredFaculties.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final faculty = _filteredFaculties[index];
            final isSelected = _selectedFaculty?.id == faculty.id;

            return SelectFacultyWidget(
              facultyModel: faculty,
              isSelected: isSelected,
              onTap: (faculty) => _selectFaculty(faculty),
            );
          },
        );
      },
    );
  }
}