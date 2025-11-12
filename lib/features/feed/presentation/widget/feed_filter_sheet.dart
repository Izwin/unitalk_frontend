// lib/features/feed/presentation/widget/feed_filter_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/core/ui/common/bottom_sheet_header.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/features/faculty/data/models/faculty_model.dart';
import 'package:unitalk/features/university/data/models/university_model.dart';
import 'package:unitalk/features/university/presentation/manager/university_bloc.dart';
import 'package:unitalk/features/university/presentation/manager/university_event.dart';
import 'package:unitalk/features/university/presentation/manager/university_state.dart';
import 'package:unitalk/l10n/app_localizations.dart';
import 'package:unitalk/l10n/bloc/locale_cubit.dart';

// Filter Models
class FeedFilters {
  final String sortBy;
  final Sector? sector;
  final String? facultyId;

  const FeedFilters({
    this.sortBy = 'new',
    this.sector,
    this.facultyId,
  });

  factory FeedFilters.empty() => const FeedFilters();

  bool get hasActiveFilters => sector != null || facultyId != null;

  int get activeFiltersCount {
    int count = 0;
    if (sector != null) count++;
    if (facultyId != null) count++;
    return count;
  }

  String? get sectorCode => sector?.code;

  FeedFilters copyWith({
    String? sortBy,
    Sector? sector,
    String? facultyId,
    bool clearSector = false,
    bool clearFaculty = false,
  }) {
    return FeedFilters(
      sortBy: sortBy ?? this.sortBy,
      sector: clearSector ? null : (sector ?? this.sector),
      facultyId: clearFaculty ? null : (facultyId ?? this.facultyId),
    );
  }
}

// Main Filter Sheet Widget
class FeedFilterSheet extends StatefulWidget {
  final FeedFilters currentFilters;
  final UniversityModel? university;
  final Function(FeedFilters) onApply;

  const FeedFilterSheet({
    Key? key,
    required this.currentFilters,
    required this.university,
    required this.onApply,
  }) : super(key: key);

  @override
  State<FeedFilterSheet> createState() => _FeedFilterSheetState();
}

class _FeedFilterSheetState extends State<FeedFilterSheet> {
  late FeedFilters _filters;
  List<FacultyModel> _faculties = [];

  @override
  void initState() {
    super.initState();
    _filters = widget.currentFilters;

    if (widget.university != null) {
      context.read<UniversityBloc>().add(
        LoadFacultiesEvent(widget.university!.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final locale = context.read<LocaleCubit>().state.languageCode;
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              // Minimalist Header
              _MinimalistHeader(
                title: l10n.filters,
                activeCount: _filters.activeFiltersCount,
                onClose: () => Navigator.pop(context),
              ),

              // Divider
              Container(
                height: 1,
                color: isDark
                    ? Colors.white.withOpacity(0.08)
                    : Colors.black.withOpacity(0.06),
              ),

              Expanded(
                child: BlocConsumer<UniversityBloc, UniversityState>(
                  listener: (context, state) {
                    if (state.status == UniversityStatus.success) {
                      setState(() => _faculties = state.faculties);
                    }
                  },
                  builder: (context, universityState) {
                    return ListView(
                      controller: scrollController,
                      padding: EdgeInsets.all(24),
                      children: [
                        // Sort Section
                        _Label(l10n.sortBy),
                        SizedBox(height: 16),
                        _SortOptions(
                          selected: _filters.sortBy,
                          onChanged: (value) {
                            setState(() {
                              _filters = _filters.copyWith(sortBy: value);
                            });
                          },
                        ),

                        SizedBox(height: 40),

                        // Sector Filter
                        _Label(l10n.sector),
                        SizedBox(height: 16),
                        _SectorFilter(
                          selected: _filters.sector,
                          onChanged: (sector) {
                            setState(() {
                              _filters = _filters.copyWith(
                                sector: sector,
                                clearSector: sector == null,
                              );
                            });
                          },
                        ),

                        SizedBox(height: 40),

                        // Faculty Filter
                        if (widget.university != null) ...[
                          _Label(l10n.faculty),
                          SizedBox(height: 16),
                          if (universityState.status == UniversityStatus.loading)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.all(24),
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                              ),
                            )
                          else
                            _FacultyFilter(
                              faculties: _faculties,
                              selectedId: _filters.facultyId,
                              locale: locale,
                              onChanged: (facultyId) {
                                setState(() {
                                  _filters = _filters.copyWith(
                                    facultyId: facultyId,
                                    clearFaculty: facultyId == null,
                                  );
                                });
                              },
                            ),
                        ],

                        SizedBox(height: 100),
                      ],
                    );
                  },
                ),
              ),

              // Bottom Actions
              _BottomActions(
                hasFilters: _filters.hasActiveFilters,
                onClear: () {
                  setState(() {
                    _filters = FeedFilters.empty();
                  });
                },
                onApply: () {
                  widget.onApply(_filters);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// Minimalist Header
class _MinimalistHeader extends StatelessWidget {
  final String title;
  final int activeCount;
  final VoidCallback onClose;

  const _MinimalistHeader({
    required this.title,
    required this.activeCount,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 12, 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.3,
                    height: 1.2,
                  ),
                ),
                if (activeCount > 0) ...[
                  SizedBox(height: 4),
                  Text(
                    '$activeCount active',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close, size: 22),
            style: IconButton.styleFrom(
              backgroundColor: isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.black.withOpacity(0.04),
            ),
          ),
        ],
      ),
    );
  }
}

// Label
class _Label extends StatelessWidget {
  final String text;

  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        height: 1.2,
      ),
    );
  }
}

// Sort Options
class _SortOptions extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _SortOptions({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: _MinimalChip(
            label: l10n.newest,
            isSelected: selected == 'new',
            onTap: () => onChanged('new'),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: _MinimalChip(
            label: l10n.popular,
            isSelected: selected == 'popular',
            onTap: () => onChanged('popular'),
          ),
        ),
      ],
    );
  }
}

// Sector Filter
class _SectorFilter extends StatelessWidget {
  final Sector? selected;
  final ValueChanged<Sector?> onChanged;

  const _SectorFilter({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _MinimalChip(
          label: l10n.all,
          isSelected: selected == null,
          onTap: () => onChanged(null),
        ),
        _MinimalChip(
          label: '${Sector.azerbaijani.flagEmoji} ${l10n.sectorAzerbaijani}',
          isSelected: selected == Sector.azerbaijani,
          onTap: () => onChanged(Sector.azerbaijani),
        ),
        _MinimalChip(
          label: '${Sector.russian.flagEmoji} ${l10n.sectorRussian}',
          isSelected: selected == Sector.russian,
          onTap: () => onChanged(Sector.russian),
        ),
        _MinimalChip(
          label: '${Sector.english.flagEmoji} ${l10n.sectorEnglish}',
          isSelected: selected == Sector.english,
          onTap: () => onChanged(Sector.english),
        ),
      ],
    );
  }
}

// Faculty Filter
class _FacultyFilter extends StatelessWidget {
  final List<FacultyModel> faculties;
  final String? selectedId;
  final String locale;
  final ValueChanged<String?> onChanged;

  const _FacultyFilter({
    required this.faculties,
    required this.selectedId,
    required this.locale,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _MinimalChip(
          label: l10n.allFaculties,
          isSelected: selectedId == null,
          onTap: () => onChanged(null),
        ),
        SizedBox(height: 10),
        ...faculties.map((faculty) {
          return Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: _FacultyOption(
              faculty: faculty,
              locale: locale,
              isSelected: selectedId == faculty.id,
              onTap: () => onChanged(faculty.id),
            ),
          );
        }).toList(),
      ],
    );
  }
}

// Minimal Chip (Flat Design)
class _MinimalChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _MinimalChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.primaryColor.withOpacity(isDark ? 0.15 : 0.08)
                : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? theme.primaryColor
                  : isDark
                  ? Colors.white.withOpacity(0.12)
                  : Colors.black.withOpacity(0.08),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? theme.primaryColor : null,
              letterSpacing: -0.1,
              height: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

// Faculty Option
class _FacultyOption extends StatelessWidget {
  final FacultyModel faculty;
  final String locale;
  final bool isSelected;
  final VoidCallback onTap;

  const _FacultyOption({
    required this.faculty,
    required this.locale,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.primaryColor.withOpacity(isDark ? 0.15 : 0.08)
                : Colors.transparent,
            border: Border.all(
              color: isSelected
                  ? theme.primaryColor
                  : isDark
                  ? Colors.white.withOpacity(0.12)
                  : Colors.black.withOpacity(0.08),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  faculty.getLocalizedName(locale),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? theme.primaryColor : null,
                    letterSpacing: -0.1,
                    height: 1.4,
                  ),
                ),
              ),
              if (isSelected)
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// Bottom Actions
class _BottomActions extends StatelessWidget {
  final bool hasFilters;
  final VoidCallback onClear;
  final VoidCallback onApply;

  const _BottomActions({
    required this.hasFilters,
    required this.onClear,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: isDark
                ? Colors.white.withOpacity(0.08)
                : Colors.black.withOpacity(0.06),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            if (hasFilters) ...[
              Expanded(
                child: _ActionButton(
                  label: 'Clear',
                  onPressed: onClear,
                  isPrimary: false,
                ),
              ),
              SizedBox(width: 12),
            ],
            Expanded(
              flex: hasFilters ? 1 : 1,
              child: _ActionButton(
                label: 'Apply',
                onPressed: onApply,
                isPrimary: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Action Button
class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isPrimary;

  const _ActionButton({
    required this.label,
    required this.onPressed,
    required this.isPrimary,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: isPrimary ? theme.primaryColor : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: isPrimary
                ? null
                : Border.all(
              color: isDark
                  ? Colors.white.withOpacity(0.12)
                  : Colors.black.withOpacity(0.08),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isPrimary ? Colors.white : null,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}

// Filter Button (for AppBar)
class FilterButton extends StatelessWidget {
  final int activeFiltersCount;
  final VoidCallback onPressed;

  const FilterButton({
    Key? key,
    required this.activeFiltersCount,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFilters = activeFiltersCount > 0;

    return Stack(
      children: [
        IconButton(
          icon: Icon(
            Icons.tune,
            color: hasFilters ? theme.primaryColor : null,
          ),
          onPressed: onPressed,
        ),
        if (hasFilters)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.primaryColor,
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Center(
                child: Text(
                  activeFiltersCount.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// Active Filters Bar
class ActiveFiltersBar extends StatelessWidget {
  final FeedFilters filters;
  final Function(FeedFilters) onFilterRemoved;
  final VoidCallback onClearAll;

  const ActiveFiltersBar({
    Key? key,
    required this.filters,
    required this.onFilterRemoved,
    required this.onClearAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            if (filters.sector != null)
              _ActiveFilterChip(
                label: _getSectorLabel(filters.sector!, l10n),
                onRemove: () {
                  onFilterRemoved(filters.copyWith(clearSector: true));
                },
              ),
            if (filters.facultyId != null) ...[
              if (filters.sector != null) SizedBox(width: 8),
              _ActiveFilterChip(
                label: l10n.faculty,
                onRemove: () {
                  onFilterRemoved(filters.copyWith(clearFaculty: true));
                },
              ),
            ],
            if (filters.hasActiveFilters) ...[
              SizedBox(width: 8),
              TextButton(
                onPressed: onClearAll,
                style: TextButton.styleFrom(
                  foregroundColor: isDark
                      ? Colors.red[300]
                      : Colors.red[700],
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: Text('Clear all', style: TextStyle(fontSize: 13)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getSectorLabel(Sector sector, AppLocalizations l10n) {
    switch (sector) {
      case Sector.azerbaijani:
        return '${sector.flagEmoji} ${l10n.sectorAzerbaijani}';
      case Sector.russian:
        return '${sector.flagEmoji} ${l10n.sectorRussian}';
      case Sector.english:
        return '${sector.flagEmoji} ${l10n.sectorEnglish}';
    }
  }
}

class _ActiveFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _ActiveFilterChip({
    required this.label,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.primaryColor.withOpacity(isDark ? 0.15 : 0.08),
        border: Border.all(
          color: theme.primaryColor,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: theme.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 6),
          InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(8),
            child: Icon(
              Icons.close,
              size: 16,
              color: theme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}