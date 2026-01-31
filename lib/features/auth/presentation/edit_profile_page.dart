import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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

  UniversityModel? _selectedUniversity;
  FacultyModel? _selectedFaculty;
  Sector? _selectedSector;
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

    _selectedUniversity = user.university;
    _selectedFaculty = user.faculty;
    _selectedSector = user.sector;

    _firstNameController.addListener(_onFieldChanged);
    _lastNameController.addListener(_onFieldChanged);

    if (_selectedUniversity != null) {
      context.read<UniversityBloc>().add(
        LoadFacultiesEvent(_selectedUniversity!.id),
      );
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    if (!_isModified) {
      setState(() => _isModified = true);
    }
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

// В EditProfilePage замените метод _showUniversityPicker на этот:

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
              final willLoseVerification = user.isVerified == true &&
                  user.university?.id != university.id;

              void selectUniversity() {
                setState(() {
                  _selectedUniversity = university;
                  _selectedFaculty = null;
                  _isModified = true;
                  _universityChanged = user.university?.id != university.id;
                });
                context.read<UniversityBloc>().add(
                  LoadFacultiesEvent(university.id),
                );
                Navigator.pop(modalContext); // Закрываем bottom sheet
              }

              if (willLoseVerification) {
                Navigator.pop(modalContext); // Сначала закрываем sheet
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
              final willLoseVerification = user.isVerified == true &&
                  user.faculty?.id != faculty.id;

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
      builder: (context) => Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      l10n.selectSector,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () => context.pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey.shade100,
                        shape: CircleBorder(),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              ...Sector.values.map((sector) {
                final isSelected = _selectedSector == sector;
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                  child: RadioSelectorItem(
                    title: sector.displayName,
                    isSelected: isSelected,
                    icon: Icons.language,
                    onTap: () {
                      setState(() {
                        _selectedSector = sector;
                        _isModified = true;
                      });
                      context.pop();
                    },
                  ),
                );
              }).toList(),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showVerificationWarning(VoidCallback onConfirm,BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await ConfirmationDialog.showVerificationWarning(
      context,
      l10n.verificationWarningTitle,
      l10n.verificationWarningMessage,
      l10n.continueButton,
      l10n.cancel,
    );

    if (confirmed) {
      onConfirm();
    }
  }

  void _saveChanges(BuildContext context) async {
    if (!_formKey.currentState!.validate()) return;

    final user = context.read<AuthBloc>().state.user!;
    final willLoseVerification = user.isVerified == true &&
        (_universityChanged || _facultyChanged);

    void performSave() async {
      if (_selectedImage != null) {
        context.read<AuthBloc>().add(UpdateAvatarEvent(_selectedImage!));
        await Future.delayed(Duration(milliseconds: 500));
      }

      context.read<AuthBloc>().add(
        UpdateProfileEvent(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          universityId: _selectedUniversity?.id,
          facultyId: _selectedFaculty?.id,
          sector: _selectedSector,
        ),
      );
      context.pop();
    }

    if (willLoseVerification) {
      _showVerificationWarning(performSave,context);
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
            icon: Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: Text(
            l10n.editProfile,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            if (_isModified)
              Padding(
                padding: EdgeInsets.only(right: 8),
                child: TextButton(
                  onPressed: () => _saveChanges(context),
                  style: TextButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    l10n.save,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(20),
            children: [
              // Avatar Section
              Center(
                child: Stack(
                  children: [
                    UserAvatar(
                      photoUrl: _selectedImage != null
                          ? null
                          : user.photoUrl,
                      firstName: user.firstName,
                      lastName: user.lastName,
                      size: 120,
                    ),
                    if (_selectedImage != null)
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: ClipOval(
                          child: Image.file(
                            _selectedImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
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
                            border: Border.all(
                              color: theme.scaffoldBackgroundColor,
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.photo_camera,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32),

              // Personal Information
              _buildSectionTitle(l10n.personalInformation),
              SizedBox(height: 12),
              CommonTextField(
                controller: _firstNameController,
                label: l10n.firstName,
                icon: Icons.person_outline,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return l10n.firstNameRequired;
                  }
                  return null;
                },
              ),
              SizedBox(height: 12),
              CommonTextField(
                controller: _lastNameController,
                label: l10n.lastName,
                icon: Icons.person_outline,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return l10n.lastNameRequired;
                  }
                  return null;
                },
              ),

              SizedBox(height: 32),

              // Academic Information
              _buildSectionTitle(l10n.academicInformation),
              SizedBox(height: 12),
              SelectorCard(
                label: l10n.university,
                value: _selectedUniversity?.getLocalizedName(locale) ?? l10n.selectUniversityPrompt,
                icon: Icons.school_outlined,
                onTap: ()=>_showUniversityPicker(context),
              ),
              SizedBox(height: 12),
              SelectorCard(
                label: l10n.faculty,
                value: _selectedFaculty?.getLocalizedName(locale) ?? l10n.selectFacultyPrompt,
                icon: Icons.account_balance_outlined,
                onTap: () => _showFacultyPicker(context),
                isEnabled: _selectedUniversity != null,
              ),
              SizedBox(height: 12),
              SelectorCard(
                label: l10n.sector,
                value: _selectedSector?.displayName ?? l10n.selectSectorPrompt,
                icon: Icons.language_outlined,
                onTap: _showSectorPicker,
              ),
              SizedBox(height: 32),
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
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withOpacity(0.08)
              : theme.cardColor,
          border: Border.all(
            color: isSelected
                ? theme.primaryColor
                : Colors.grey.shade200,
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
                child: Icon(
                  icon,
                  color: theme.primaryColor,
                  size: 24,
                ),
              ),
            if (icon != null) SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (isSelected)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}