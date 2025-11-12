import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/l10n/app_localizations.dart';

class VerificationStatusWidget extends StatelessWidget {
  final UserModel user;

  VerificationStatusWidget({required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isVerified = user.isVerified == true;
    final verification = user.verification;

    if (isVerified) {
      return SizedBox.shrink();
    }

    final isPending = verification?.isPending == true;
    final isRejected = verification?.isRejected == true;

    Color bgColor;
    Color textColor;
    IconData icon;
    String title;
    String subtitle;

    if (isPending) {
      bgColor = Colors.orange.withOpacity(0.1);
      textColor = Colors.orange;
      icon = Icons.hourglass_empty;
      title = l10n.verificationPending;
      subtitle = l10n.verificationUnderReview;
    } else if (isRejected) {
      bgColor = Colors.red.withOpacity(0.1);
      textColor = Colors.red;
      icon = Icons.error_outline;
      title = l10n.verificationRejected;
      subtitle = verification?.rejectionReason ?? l10n.pleaseTryAgain;
    } else {
      bgColor = Theme.of(context).primaryColor.withOpacity(0.1);
      textColor = Theme.of(context).primaryColor;
      icon = Icons.badge_outlined;
      title = l10n.getVerified;
      subtitle = l10n.verifyStudentStatus;
    }

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          context.push('/profile-verification');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: textColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: textColor, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: textColor),
            ],
          ),
        ),
      ),
    );
  }
}