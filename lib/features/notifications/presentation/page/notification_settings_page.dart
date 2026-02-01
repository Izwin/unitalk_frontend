import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:unitalk/core/ui/common/bottom_sheet_header.dart';
import 'package:unitalk/core/ui/common/empty_state_widget.dart';
import 'package:unitalk/core/ui/common/error_state_widget.dart';
import 'package:unitalk/core/ui/widgets/default_text_widget.dart';
import 'package:unitalk/features/notifications/model/notification_settings_model.dart';
import 'package:unitalk/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:unitalk/features/notifications/presentation/bloc/notification_event.dart';
import 'package:unitalk/features/notifications/presentation/bloc/notification_state.dart';
import 'package:unitalk/features/university/data/models/university_model.dart';
import 'package:unitalk/features/university/presentation/manager/university_bloc.dart';
import 'package:unitalk/features/university/presentation/manager/university_event.dart';
import 'package:unitalk/features/university/presentation/manager/university_state.dart';
import 'package:unitalk/l10n/app_localizations.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: false,
        title: Text(
          l10n.notificationSettings,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 1,
            color: theme.colorScheme.onSurface.withOpacity(0.08),
          ),
          Expanded(
            child: BlocBuilder<NotificationBloc, NotificationState>(
              buildWhen: (previous, current) =>
              previous.settings != current.settings ||
                  previous.status != current.status,
              builder: (context, state) {
                if (state.status == NotificationStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state.settings == null) {
                  return ErrorStateWidget(
                    message: l10n.errorLoadingSettings,
                    onRetry: () {
                      context
                          .read<NotificationBloc>()
                          .add(GetNotificationSettingsEvent());
                    },
                    retryButtonText: l10n.retry,
                  );
                }

                final settings = state.settings!;

                return ListView(
                  key: const PageStorageKey<String>('notification_settings_list'),
                  controller: _scrollController,
                  primary: false,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  children: [
                    // Master switch
                    _MasterSwitchWidget(settings: settings),

                    const SizedBox(height: 24),

                    // Posts section
                    _SectionHeaderWidget(
                      title: l10n.posts,
                      icon: Icons.post_add_rounded,
                    ),
                    _SettingsGroupWidget(
                      settings: settings,
                      items: [
                        _SettingData(
                          title: l10n.newPosts,
                          subtitle: l10n.newPostsDescription,
                          value: settings.newPosts,
                          onChanged: (value) {
                            context.read<NotificationBloc>().add(
                                UpdateNotificationSettingsEvent(
                                    newPosts: value));
                          },
                        ),
                        _SettingData(
                          title: l10n.newComments,
                          subtitle: l10n.newCommentsDescription,
                          value: settings.newComments,
                          onChanged: (value) {
                            context.read<NotificationBloc>().add(
                                UpdateNotificationSettingsEvent(
                                    newComments: value));
                          },
                        ),
                        _SettingData(
                          title: l10n.newLikes,
                          subtitle: l10n.newLikesDescription,
                          value: settings.newLikes,
                          onChanged: (value) {
                            context.read<NotificationBloc>().add(
                                UpdateNotificationSettingsEvent(
                                    newLikes: value));
                          },
                        ),
                      ],
                    ),

                    // Post notification filter section
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      alignment: Alignment.topCenter,
                      child: (settings.newPosts && settings.enabled)
                          ? Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: _PostFilterSectionWidget(settings: settings),
                      )
                          : const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 32),

                    // Comments section
                    _SectionHeaderWidget(
                      title: l10n.comments,
                      icon: Icons.chat_bubble_outline,
                    ),
                    _SettingsGroupWidget(
                      settings: settings,
                      items: [
                        _SettingData(
                          title: l10n.commentReplies,
                          subtitle: l10n.commentRepliesDescription,
                          value: settings.commentReplies,
                          onChanged: (value) {
                            context.read<NotificationBloc>().add(
                                UpdateNotificationSettingsEvent(
                                    commentReplies: value));
                          },
                        ),
                        _SettingData(
                          title: l10n.mentions,
                          subtitle: l10n.mentionsDescription,
                          value: settings.mentions,
                          onChanged: (value) {
                            context.read<NotificationBloc>().add(
                                UpdateNotificationSettingsEvent(
                                    mentions: value));
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Chat section
                    _SectionHeaderWidget(
                      title: l10n.chat,
                      icon: Icons.forum_outlined,
                    ),
                    _SettingsGroupWidget(
                      settings: settings,
                      items: [
                        _SettingData(
                          title: l10n.chatMessages,
                          subtitle: l10n.chatMessagesDescription,
                          value: settings.chatMessages,
                          onChanged: (value) {
                            context.read<NotificationBloc>().add(
                                UpdateNotificationSettingsEvent(
                                    chatMessages: value));
                          },
                        ),
                        _SettingData(
                          title: l10n.chatMentions,
                          subtitle: l10n.chatMentionsDescription,
                          value: settings.chatMentions,
                          onChanged: (value) {
                            context.read<NotificationBloc>().add(
                                UpdateNotificationSettingsEvent(
                                    chatMentions: value));
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Master Switch Widget
// ============================================================================

class _MasterSwitchWidget extends StatelessWidget {
  final NotificationSettingsModel settings;

  const _MasterSwitchWidget({required this.settings});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: settings.enabled
            ? theme.colorScheme.primary.withOpacity(0.08)
            : theme.colorScheme.onSurface.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: settings.enabled
              ? theme.colorScheme.primary.withOpacity(0.2)
              : theme.colorScheme.onSurface.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: settings.enabled
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              settings.enabled
                  ? Icons.notifications_active
                  : Icons.notifications_off_outlined,
              color: settings.enabled
                  ? Colors.white
                  : theme.colorScheme.onSurface.withOpacity(0.4),
              size: 22,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.enableNotifications,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.enableNotificationsDescription,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                    letterSpacing: 0.1,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(
            value: settings.enabled,
            onChanged: (value) {
              context
                  .read<NotificationBloc>()
                  .add(UpdateNotificationSettingsEvent(enabled: value));
            },
            activeColor: theme.colorScheme.primary,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Section Header Widget
// ============================================================================

class _SectionHeaderWidget extends StatelessWidget {
  final String title;
  final IconData icon;

  const _SectionHeaderWidget({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Post Filter Section Widget
// ============================================================================

class _PostFilterSectionWidget extends StatelessWidget {
  final NotificationSettingsModel settings;

  const _PostFilterSectionWidget({required this.settings});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Icon(
                  Icons.filter_list_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.postNotificationFilter,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // All universities
          _FilterOptionWidget(
            icon: Icons.public_rounded,
            title: l10n.allUniversities,
            subtitle: l10n.allUniversitiesDescription,
            isSelected: settings.newPostsFilter == NewPostsFilter.all,
            onTap: () {
              context.read<NotificationBloc>().add(
                UpdateNotificationSettingsEvent(
                  newPostsFilter: NewPostsFilter.all,
                ),
              );
            },
          ),

          _buildDivider(theme),

          // My university only
          _FilterOptionWidget(
            icon: Icons.school_rounded,
            title: l10n.myUniversity,
            subtitle: l10n.myUniversityDescription,
            isSelected: settings.newPostsFilter == NewPostsFilter.myUniversity,
            onTap: () {
              context.read<NotificationBloc>().add(
                UpdateNotificationSettingsEvent(
                  newPostsFilter: NewPostsFilter.myUniversity,
                ),
              );
            },
          ),

          _buildDivider(theme),

          // Friends only
          _FilterOptionWidget(
            icon: Icons.people_rounded,
            title: l10n.friendsOnly,
            subtitle: l10n.friendsOnlyDescription,
            isSelected: settings.newPostsFilter == NewPostsFilter.friends,
            onTap: () {
              context.read<NotificationBloc>().add(
                UpdateNotificationSettingsEvent(
                  newPostsFilter: NewPostsFilter.friends,
                ),
              );
            },
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      color: theme.colorScheme.onSurface.withOpacity(0.06),
    );
  }
}

// ============================================================================
// Filter Option Widget
// ============================================================================

class _FilterOptionWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? trailing;

  const _FilterOptionWidget({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : theme.colorScheme.onSurface.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.5),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
            Radio<bool>(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onTap(),
              activeColor: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Settings Group Widget
// ============================================================================

class _SettingsGroupWidget extends StatelessWidget {
  final NotificationSettingsModel settings;
  final List<_SettingData> items;

  const _SettingsGroupWidget({
    required this.settings,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.onSurface.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _SettingTileWidget(
              data: items[i],
              enabled: settings.enabled,
            ),
            if (i < items.length - 1)
              Container(
                height: 1,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                color: theme.colorScheme.onSurface.withOpacity(0.06),
              ),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// Setting Tile Widget
// ============================================================================

class _SettingTileWidget extends StatelessWidget {
  final _SettingData data;
  final bool enabled;

  const _SettingTileWidget({
    required this.data,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: enabled ? () => data.onChanged(!data.value) : null,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0,
                      color: enabled
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: enabled
                          ? theme.colorScheme.onSurface.withOpacity(0.6)
                          : theme.colorScheme.onSurface.withOpacity(0.3),
                      letterSpacing: 0.1,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Switch.adaptive(
              value: data.value,
              onChanged: enabled ? data.onChanged : null,
              activeColor: theme.colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Setting Data Model
// ============================================================================

class _SettingData {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  _SettingData({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
}

// ============================================================================
// Multi-University Selection Sheet
// ============================================================================

class _MultiUniversitySelectionSheet extends StatefulWidget {
  final List<String> selectedUniversityIds;
  final Function(List<String>) onSave;

  const _MultiUniversitySelectionSheet({
    required this.selectedUniversityIds,
    required this.onSave,
  });

  @override
  State<_MultiUniversitySelectionSheet> createState() =>
      _MultiUniversitySelectionSheetState();
}

class _MultiUniversitySelectionSheetState
    extends State<_MultiUniversitySelectionSheet> {
  late Set<String> _selectedIds;
  final TextEditingController _searchController = TextEditingController();
  List<UniversityModel> _filteredUniversities = [];

  @override
  void initState() {
    super.initState();
    _selectedIds = Set.from(widget.selectedUniversityIds);
    _searchController.addListener(_filterUniversities);
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

    setState(() {
      if (query.isEmpty) {
        _filteredUniversities = List.from(universities);
      } else {
        _filteredUniversities = universities.where((university) {
          final nameAz = (university.name['az'] ?? '').toLowerCase();
          final nameRu = (university.name['ru'] ?? '').toLowerCase();
          final nameEn = (university.name['en'] ?? '').toLowerCase();

          return nameAz.contains(query) ||
              nameRu.contains(query) ||
              nameEn.contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
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
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.cancel),
                    ),
                    Text(
                      l10n.selectUniversities,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.onSave(_selectedIds.toList());
                        Navigator.pop(context);
                      },
                      child: Text(
                        l10n.done,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Selected count & Clear button
              if (_selectedIds.isNotEmpty)
                Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          l10n.universitiesSelected(
                              _selectedIds.length.toString()),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedIds.clear();
                          });
                        },
                        child: Text(
                          l10n.clearAll,
                          style: TextStyle(
                            color: theme.colorScheme.error,
                          ),
                        ),
                      ),
                    ],
                  ),
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
                    // Load universities if not loaded
                    if (state.universities.isEmpty &&
                        state.status != UniversityStatus.loading &&
                        state.status != UniversityStatus.failure) {
                      context
                          .read<UniversityBloc>()
                          .add(LoadUniversitiesEvent());
                    }

                    if (state.status == UniversityStatus.loading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (state.status == UniversityStatus.failure) {
                      return ErrorStateWidget(
                        message: state.errorMessage ??
                            l10n.errorLoadingUniversities,
                        onRetry: () {
                          context
                              .read<UniversityBloc>()
                              .add(LoadUniversitiesEvent());
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

                    final displayList = _filteredUniversities.isEmpty &&
                        _searchController.text.isEmpty
                        ? state.universities
                        : _filteredUniversities;

                    if (displayList.isEmpty &&
                        _searchController.text.isNotEmpty) {
                      return EmptyStateWidget(
                        icon: Icons.search_off_rounded,
                        title: l10n.noUniversitiesFound,
                        subtitle: l10n.tryDifferentSearchTerm,
                      );
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 8,
                      ),
                      itemCount: displayList.length,
                      itemBuilder: (context, index) {
                        final university = displayList[index];
                        final isSelected = _selectedIds.contains(university.id);

                        return _UniversityCheckboxTile(
                          university: university,
                          isSelected: isSelected,
                          locale: locale,
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedIds.remove(university.id);
                              } else {
                                _selectedIds.add(university.id);
                              }
                            });
                          },
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(height: 8);
                      },
                    );
                  },
                ),
              ),

              // Bottom save button
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        widget.onSave(_selectedIds.toList());
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.done,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UniversityCheckboxTile extends StatelessWidget {
  final UniversityModel university;
  final bool isSelected;
  final String locale;
  final VoidCallback onTap;

  const _UniversityCheckboxTile({
    required this.university,
    required this.isSelected,
    required this.locale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localizedName = university.getLocalizedName(locale);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.1),
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.05)
              : theme.colorScheme.surface,
        ),
        child: Row(
          children: [
            // University logo
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child:
              university.logoUrl != null && university.logoUrl!.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: university.logoUrl!,
                width: 48,
                height: 48,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    _buildPlaceholder(theme),
                errorWidget: (context, url, error) =>
                    _buildPlaceholder(theme),
              )
                  : _buildPlaceholder(theme),
            ),

            const SizedBox(width: 12),

            // University name
            Expanded(
              child: Text(
                localizedName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(width: 8),

            // Checkbox
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isSelected
                    ? theme.colorScheme.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(ThemeData theme) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.school_rounded,
        color: theme.colorScheme.primary,
        size: 24,
      ),
    );
  }
}
