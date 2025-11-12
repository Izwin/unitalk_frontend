// Bottom Sheet for University Selection
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unitalk/core/ui/common/bottom_sheet_header.dart';
import 'package:unitalk/core/ui/common/empty_state_widget.dart';
import 'package:unitalk/core/ui/common/error_state_widget.dart';
import 'package:unitalk/core/ui/widgets/default_text_widget.dart';
import 'package:unitalk/features/auth/presentation/widget/select_university_widget.dart';
import 'package:unitalk/features/university/data/models/university_model.dart';
import 'package:unitalk/features/university/presentation/manager/university_bloc.dart';
import 'package:unitalk/features/university/presentation/manager/university_event.dart';
import 'package:unitalk/features/university/presentation/manager/university_state.dart';
import 'package:unitalk/l10n/app_localizations.dart';
import 'package:unitalk/l10n/bloc/locale_cubit.dart';

class UniversitySelectionSheet extends StatefulWidget {
  final UniversityModel? currentUniversity;
  final Function(UniversityModel) onUniversitySelected;

  const UniversitySelectionSheet({
    super.key,
    required this.currentUniversity,
    required this.onUniversitySelected,
  });

  @override
  State<UniversitySelectionSheet> createState() =>
      UniversitySelectionSheetState();
}

class UniversitySelectionSheetState extends State<UniversitySelectionSheet> {
  final _searchController = TextEditingController();
  List<UniversityModel> _filteredUniversities = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterUniversities);
    // Инициализация будет в listener BlocConsumer
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterUniversities);
    _searchController.dispose();
    super.dispose();
  }

  void _filterUniversities() {
    final universityBloc = context.read<UniversityBloc>();
    final universities = universityBloc.state.universities;

    if (universities.isEmpty) return;

    final query = _searchController.text.toLowerCase().trim();
    final locale = context.read<LocaleCubit>().state.languageCode;

    setState(() {
      if (query.isEmpty) {
        _filteredUniversities = List.from(universities);
      } else {
        _filteredUniversities = universities.where((university) {
          final name = university.getLocalizedName(locale).toLowerCase();
          return name.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle bar + Header
              BottomSheetHeader(
                title: l10n.selectUniversity,
                subtitle: l10n.selectUniversitySubtitle,
                onClose: () => context.pop(),
              ),

              // Search field
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: DefaultTextWidget(
                  controller: _searchController,
                  hint: l10n.searchUniversities,
                ),
              ),

              const SizedBox(height: 16),

              // University list
              Expanded(
                child: BlocConsumer<UniversityBloc, UniversityState>(
                  listener: (context, state) {
                    if (state.status == UniversityStatus.success &&
                        state.universities.isNotEmpty) {
                      setState(() {
                        _filteredUniversities = List.from(state.universities);
                      });
                    }
                  },
                  builder: (context, state) {
                    // Загружаем университеты если их нет
                    if (state.universities.isEmpty &&
                        state.status != UniversityStatus.loading &&
                        state.status != UniversityStatus.failure) {
                      context.read<UniversityBloc>().add(LoadUniversitiesEvent());
                    }

                    if (state.status == UniversityStatus.loading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (state.status == UniversityStatus.failure) {
                      return ErrorStateWidget(
                        message: state.errorMessage ??
                            l10n.failedToLoadUniversities,
                        onRetry: () {
                          context.read<UniversityBloc>().add(
                            LoadUniversitiesEvent(),
                          );
                        },
                      );
                    }

                    if (state.universities.isEmpty) {
                      return EmptyStateWidget(
                        icon: Icons.school_outlined,
                        title: l10n.noUniversitiesFound,
                        subtitle: l10n.tryDifferentSearchTerm,
                      );
                    }

                    if (_filteredUniversities.isEmpty && _searchController.text.isNotEmpty) {
                      return EmptyStateWidget(
                        icon: Icons.search_off_rounded,
                        title: l10n.noUniversitiesFound,
                        subtitle: l10n.tryDifferentSearchTerm,
                      );
                    }

                    final displayList = _filteredUniversities.isEmpty
                        ? state.universities
                        : _filteredUniversities;

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      itemCount: displayList.length,
                      itemBuilder: (context, index) {
                        final university = displayList[index];
                        final isSelected =
                            widget.currentUniversity?.id == university.id;

                        return SelectUniversityWidget(
                          universityModel: university,
                          isSelected: isSelected,
                          onTap: (university) {
                            widget.onUniversitySelected(university);
                            //Navigator.pop(context);
                          },
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 10);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}