import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_event.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_state.dart';
import 'package:unitalk/features/auth/presentation/page/complete_profile_page_one.dart';
import 'package:unitalk/features/auth/presentation/page/complete_profile_page_three.dart';
import 'package:unitalk/features/auth/presentation/page/complete_profile_page_two.dart';
import 'package:unitalk/features/university/data/models/university_model.dart';
import 'package:unitalk/features/faculty/data/models/faculty_model.dart';
import 'package:unitalk/features/university/presentation/manager/university_bloc.dart';
import 'package:unitalk/features/university/presentation/manager/university_event.dart';
import 'package:unitalk/l10n/app_localizations.dart';

class CompleteProfilePage extends StatefulWidget {
  const CompleteProfilePage({Key? key}) : super(key: key);

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Shared data across pages
  String? _firstName;
  String? _lastName;
  Sector? _selectedSector;
  UniversityModel? _selectedUniversity;
  FacultyModel? _selectedFaculty;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _updateStepOneData({
    String? firstName,
    String? lastName,
    Sector? sector,
  }) {
    setState(() {
      if (firstName != null) _firstName = firstName;
      if (lastName != null) _lastName = lastName;
      if (sector != null) _selectedSector = sector;
    });
  }

  void _updateStepTwoData(UniversityModel? university) {
    setState(() {
      _selectedUniversity = university;
    });
  }

  void _updateStepThreeData(FacultyModel? faculty) {
    setState(() {
      _selectedFaculty = faculty;
    });
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _firstName != null &&
            _firstName!.trim().isNotEmpty &&
            _lastName != null &&
            _lastName!.trim().isNotEmpty &&
            _selectedSector != null;
      case 1:
        return _selectedUniversity != null;
      case 2:
        return _selectedFaculty != null;
      default:
        return false;
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      FocusScope.of(context).unfocus();
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );

      // Load faculties when moving to step 3
      if (_currentStep == 2 && _selectedUniversity != null) {
        context.read<UniversityBloc>().add(
          LoadFacultiesEvent(_selectedUniversity!.id),
        );
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeProfile() {
    if (!_canProceed()) return;

    context.read<AuthBloc>().add(
      UpdateProfileEvent(
        firstName: _firstName!,
        lastName: _lastName!,
        sector: _selectedSector!,
        universityId: _selectedUniversity!.id,
        facultyId: _selectedFaculty!.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.failure) {
          // Show error
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Failed to update profile'),
              backgroundColor: theme.colorScheme.error,
            ),
          );
        }
        if(state.status == AuthStatus.authenticated){
          context.go('/feed');
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Progress indicator
              _buildProgressIndicator(theme),

              // Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    CompleteProfilePageOne(
                      initialFirstName: _firstName,
                      initialLastName: _lastName,
                      initialSector: _selectedSector,
                      onDataChanged: _updateStepOneData,
                    ),
                    CompleteProfilePageTwo(
                      initialUniversity: _selectedUniversity,
                      onUniversitySelected: _updateStepTwoData,
                    ),
                    CompleteProfilePageThree(
                      initialFaculty: _selectedFaculty,
                      onFacultySelected: _updateStepThreeData,
                    ),
                  ],
                ),
              ),

              // Bottom buttons
              _buildBottomButtons(theme, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;

          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
              decoration: BoxDecoration(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomButtons(ThemeData theme, AppLocalizations l10n) {
    final canProceed = _canProceed();

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _previousStep,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Text(
                  l10n.back,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, state) {
                final isLoading = state.status == AuthStatus.loading;

                return ElevatedButton(
                  onPressed: canProceed && !isLoading
                      ? (_currentStep == 2 ? _completeProfile : _nextStep)
                      : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(0, 56),
                    backgroundColor: theme.colorScheme.primary,
                    disabledBackgroundColor: theme.colorScheme.primary
                        .withOpacity(0.5),
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : Text(
                          _currentStep == 2
                              ? l10n.complete
                              : l10n.continueButton,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
