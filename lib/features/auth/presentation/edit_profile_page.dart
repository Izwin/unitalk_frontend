// lib/features/auth/presentation/edit_profile_page.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unitalk/core/ui/common/bottom_sheet_list_picker.dart';
import 'package:unitalk/core/ui/common/common_text_field.dart';
import 'package:unitalk/core/ui/common/confirmation_dialog.dart';
import 'package:unitalk/core/ui/common/image_source_picker.dart';
import 'package:unitalk/core/ui/common/selector_card.dart';
import 'package:unitalk/core/ui/common/university_selection_sheet.dart';
import 'package:unitalk/core/ui/common/user_avatar.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_event.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_state.dart';
import 'package:unitalk/features/faculty/data/models/faculty_model.dart';
import 'package:unitalk/features/university/data/models/university_model.dart';
import 'package:unitalk/features/university/presentation/manager/university_bloc.dart';
import 'package:unitalk/features/university/presentation/manager/university_event.dart';
import 'package:unitalk/features/university/presentation/manager/university_state.dart';
import 'package:unitalk/l10n/app_localizations.dart';
import 'package:unitalk/l10n/bloc/locale_cubit.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _bioController;
  late TextEditingController _instagramController;

  UniversityModel? _selectedUniversity;
  FacultyModel? _selectedFaculty;
  Sector? _selectedSector;
  Course? _selectedCourse;
  File? _selectedImage;

  bool _isModified = false;
  bool _universityChanged = false;
  bool _facultyChanged = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().state.user!;

    _firstNameController = TextEditingController(text: user.firstName);
    _lastNameController = TextEditingController(text: user.lastName);
    _bioController = TextEditingController(text: user.bio);
    _instagramController = TextEditingController(text: user.instagramUsername);

    _selectedUniversity = user.university;
    _selectedFaculty = user.faculty;
    _selectedSector = user.sector;
    _selectedCourse = user.course;

    _firstNameController.addListener(_onFieldChanged);
    _lastNameController.addListener(_onFieldChanged);
    _bioController.addListener(_onFieldChanged);
    _instagramController.addListener(_onFieldChanged);

    if (_selectedUniversity != null) {
      context.read<UniversityBloc>().add(LoadFacultiesEvent(_selectedUniversity!.id));
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _bioController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    if (!_isModified) setState(() => _isModified = true);
  }

  Future<void> _handleImageSelection() async {
    final l10n = AppLocalizations.of(context)!;
    final user = context.read<AuthBloc>().state.user;

    final image = await MediaSourcePicker.show(
      context,
      galleryText: l10n.chooseFromGallery,
      videoText: l10n.video,
      cameraText: l10n.takePhoto,
      removeText: l10n.removePhoto,
      canRemove: _selectedImage != null || user?.photoUrl != null,
      onRemove: () {
        setState(() {
          _selectedImage = null;
          _isModified = true;
        });
      },
    );

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _isModified = true;
      });
    }
  }

  Future<void> _showCoursePicker() async {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (_, scrollController) => Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      l10n.selectCourse,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    if (_selectedCourse != null)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selectedCourse = null;
                            _isModified = true;
                          });
                          Navigator.pop(ctx);
                        },
                        child: Text(l10n.clear),
                      ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  itemCount: Course.values.length,
                  itemBuilder: (context, index) {
                    final course = Course.values[index];
                    final isSelected = _selectedCourse == course;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: RadioSelectorItem(
                        title: course.getLocalizedName(l10n),
                        isSelected: isSelected,
                        icon: Icons.school_outlined,
                        onTap: () {
                          setState(() {
                            _selectedCourse = course;
                            _isModified = true;
                          });
                          Navigator.pop(ctx);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showUniversityPicker(BuildContext context) async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) => BlocProvider.value(
        value: context.read<UniversityBloc>(),
        child: BlocProvider.value(
          value: context.read<LocaleCubit>(),
          child: UniversitySelectionSheet(
            currentUniversity: _selectedUniversity,
            onUniversitySelected: (university) {
              final user = context.read<AuthBloc>().state.user!;
              final willLoseVerification =
                  user.isVerified == true && user.university?.id != university.id;

              void selectUniversity() {
                setState(() {
                  _selectedUniversity = university;
                  _selectedFaculty = null;
                  _isModified = true;
                  _universityChanged = user.university?.id != university.id;
                });
                context.read<UniversityBloc>().add(LoadFacultiesEvent(university.id));
                Navigator.pop(modalContext);
              }

              if (willLoseVerification) {
                Navigator.pop(modalContext);
                _showVerificationWarning(selectUniversity, context);
              } else {
                selectUniversity();
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _showFacultyPicker(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final locale = context.read<LocaleCubit>().state.languageCode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocBuilder<UniversityBloc, UniversityState>(
        builder: (_, state) {
          return BottomSheetListPicker<FacultyModel>(
            title: l10n.selectFaculty,
            items: state.faculties,
            selectedItem: _selectedFaculty,
            itemTitle: (faculty) => faculty.getLocalizedName(locale),
            defaultIcon: Icons.account_balance,
            customFilter: (faculty, query) => faculty.matchesQuery(query),
            onItemSelected: (faculty) {
              final user = context.read<AuthBloc>().state.user!;
              final willLoseVerification =
                  user.isVerified == true && user.faculty?.id != faculty.id;

              void selectFaculty() {
                setState(() {
                  _selectedFaculty = faculty;
                  _isModified = true;
                  _facultyChanged = user.faculty?.id != faculty.id;
                });
              }

              if (willLoseVerification) {
                _showVerificationWarning(selectFaculty, context);
              } else {
                context.pop();
                selectFaculty();
              }
            },
            searchHint: l10n.searchFaculties,
            emptyMessage: l10n.noFacultiesFound,
          );
        },
      ),
    );
  }

  Future<void> _showSectorPicker() async {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.85,
        builder: (_, scrollController) => Container(
          margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      l10n.selectSector,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                  itemCount: Sector.values.length,
                  itemBuilder: (context, index) {
                    final sector = Sector.values[index];
                    final isSelected = _selectedSector == sector;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: RadioSelectorItem(
                        title: sector.displayName,
                        isSelected: isSelected,
                        icon: Icons.language,
                        onTap: () {
                          setState(() {
                            _selectedSector = sector;
                            _isModified = true;
                          });
                          Navigator.pop(ctx);
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showVerificationWarning(VoidCallback onConfirm, BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await ConfirmationDialog.showVerificationWarning(
      context,
      l10n.verificationWarningTitle,
      l10n.verificationWarningMessage,
      l10n.continueButton,
      l10n.cancel,
    );

    if (confirmed) onConfirm();
  }

  void _saveChanges(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthBloc>().state.user!;
    final willLoseVerification = user.isVerified == true && (_universityChanged || _facultyChanged);

    void performSave() async {
      if (_selectedImage != null) {
        context.read<AuthBloc>().add(UpdateAvatarEvent(_selectedImage!));
        await Future.delayed(const Duration(milliseconds: 500));
      }

      context.read<AuthBloc>().add(
        UpdateProfileEvent(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          universityId: _selectedUniversity?.id,
          facultyId: _selectedFaculty?.id,
          sector: _selectedSector,
          bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
          course: _selectedCourse,
          instagramUsername: _instagramController.text.trim().isEmpty
              ? null
              : _instagramController.text.trim().replaceAll('@', ''),
        ),
      );
      context.pop();
    }

    if (willLoseVerification) {
      _showVerificationWarning(performSave, context);
    } else {
      performSave();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final user = context.read<AuthBloc>().state.user!;
    final locale = context.read<LocaleCubit>().state.languageCode;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? l10n.failedToUpdateProfile),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: Text(l10n.editProfile, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          actions: [
            if (_isModified)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: TextButton(
                  onPressed: () => _saveChanges(context),
                  style: TextButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(l10n.save, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    UserAvatar(
                      photoUrl: _selectedImage != null ? null : user.photoUrl,
                      firstName: user.firstName,
                      lastName: user.lastName,
                      size: 120,
                    ),
                    if (_selectedImage != null)
                      Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(shape: BoxShape.circle),
                        child: ClipOval(child: Image.file(_selectedImage!, fit: BoxFit.cover)),
                      ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _handleImageSelection,
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: theme.scaffoldBackgroundColor, width: 3),
                          ),
                          child: const Icon(Icons.photo_camera, color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Personal Info
              _buildSectionTitle(l10n.personalInformation),
              const SizedBox(height: 12),
              CommonTextField(
                controller: _firstNameController,
                label: l10n.firstName,
                icon: Icons.person_outline,
                validator: (value) => (value?.trim().isEmpty ?? true) ? l10n.firstNameRequired : null,
              ),
              const SizedBox(height: 12),
              CommonTextField(
                controller: _lastNameController,
                label: l10n.lastName,
                icon: Icons.person_outline,
                validator: (value) => (value?.trim().isEmpty ?? true) ? l10n.lastNameRequired : null,
              ),
              const SizedBox(height: 32),

              // About Me
              _buildSectionTitle(l10n.aboutMe),
              const SizedBox(height: 12),
              CommonTextField(
                controller: _bioController,
                label: l10n.bio,
                icon: Icons.info_outline,
                maxLines: 3,
                maxLength: 150,
                hintText: l10n.bioHint,
              ),
              const SizedBox(height: 12),
              CommonTextField(
                controller: _instagramController,
                label: 'Instagram',
                icon: Icons.camera_alt_outlined,
                prefixText: '@',
                hintText: 'username',
              ),
              const SizedBox(height: 32),

              // Academic Info
              _buildSectionTitle(l10n.academicInformation),
              const SizedBox(height: 12),
              SelectorCard(
                label: l10n.university,
                value: _selectedUniversity?.getLocalizedName(locale) ?? l10n.selectUniversityPrompt,
                icon: Icons.school_outlined,
                onTap: () => _showUniversityPicker(context),
              ),
              const SizedBox(height: 12),
              SelectorCard(
                label: l10n.faculty,
                value: _selectedFaculty?.getLocalizedName(locale) ?? l10n.selectFacultyPrompt,
                icon: Icons.account_balance_outlined,
                onTap: () => _showFacultyPicker(context),
                isEnabled: _selectedUniversity != null,
              ),
              const SizedBox(height: 12),
              SelectorCard(
                label: l10n.sector,
                value: _selectedSector?.displayName ?? l10n.selectSectorPrompt,
                icon: Icons.language_outlined,
                onTap: _showSectorPicker,
              ),
              const SizedBox(height: 12),
              SelectorCard(
                label: l10n.course,
                value: _selectedCourse?.getLocalizedName(l10n) ?? l10n.selectCourse,
                icon: Icons.timeline_outlined,
                onTap: _showCoursePicker,
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade600,
        letterSpacing: 0.5,
      ),
    );
  }
}

class RadioSelectorItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final IconData? icon;
  final VoidCallback onTap;

  const RadioSelectorItem({
    Key? key,
    required this.title,
    required this.isSelected,
    this.icon,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? theme.primaryColor.withOpacity(0.08) : theme.cardColor,
          border: Border.all(
            color: isSelected ? theme.primaryColor : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            if (icon != null)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: theme.primaryColor, size: 24),
              ),
            if (icon != null) const SizedBox(width: 16),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            if (isSelected)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: theme.primaryColor, shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 16),
              ),
          ],
        ),
      ),
    );
  }
}