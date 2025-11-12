import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:unitalk/core/theme/bloc/theme_bloc.dart';
import 'package:unitalk/core/theme/bloc/theme_event.dart';
import 'package:unitalk/core/theme/bloc/theme_state.dart';
import 'package:unitalk/core/theme/domain/entity/app_theme_mode.dart';
import 'package:unitalk/features/auth/data/model/user_model.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_state.dart';
import 'package:unitalk/features/auth/presentation/bloc/auth_event.dart';
import 'package:unitalk/features/auth/presentation/edit_profile_page.dart';
import 'package:unitalk/features/auth/presentation/widget/profile_drawer.dart';
import 'package:unitalk/features/auth/presentation/widget/student_id_card_widget.dart';
import 'package:unitalk/features/feed/presentation/bloc/post/post_bloc.dart';
import 'package:unitalk/features/feed/presentation/bloc/post/post_event.dart';
import 'package:unitalk/features/feed/presentation/bloc/post/post_state.dart';
import 'package:unitalk/features/feed/domain/repository/posts_repository.dart';
import 'package:unitalk/features/feed/presentation/widget/post_item.dart';
import 'package:unitalk/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:unitalk/features/notifications/presentation/bloc/notification_state.dart';
import 'package:unitalk/features/notifications/presentation/bloc/notification_event.dart';
import 'package:unitalk/features/university/data/models/university_model.dart';
import 'package:unitalk/features/university/presentation/manager/university_bloc.dart';
import 'package:unitalk/features/university/presentation/manager/university_event.dart';
import 'package:unitalk/features/university/presentation/manager/university_state.dart';
import 'package:unitalk/l10n/app_localizations.dart';
import 'package:unitalk/l10n/bloc/locale_cubit.dart';
import 'package:intl/intl.dart';

import 'widget/verification_status_widget.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _ProfilePageContent();
  }
}

class _ProfilePageContent extends StatefulWidget {
  @override
  State<_ProfilePageContent> createState() => _ProfilePageContentState();
}

class _ProfilePageContentState extends State<_ProfilePageContent> {
  @override
  void initState() {
    super.initState();
    context.read<PostBloc>().add(GetPostsEvent(authorId: context.read<AuthBloc>().state.user!.id));
  }

  Future<void> _onRefresh() async {
    final userId = context.read<AuthBloc>().state.user?.id;
    if (userId == null) return;

    context.read<PostBloc>().add(GetPostsEvent(authorId: userId));
    context.read<AuthBloc>().add(GetCurrentUserEvent());


  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      endDrawer: ProfileDrawer(),
      body: SafeArea(
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final user = authState.user;
            print('sdfsfsd ${user?.verification?.status}');
            print('sdfsfsd ${user?.isVerified}');

            if (user == null) {
              return Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
              onRefresh: _onRefresh,
              color: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.surface,
              child: CustomScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: 0,
                    pinned: false,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    title: Text(l10n.profile),
                    actions: [
                      IconButton(
                        icon: Icon(Icons.edit_outlined),
                        tooltip: l10n.editProfile,
                        onPressed: () {
                          context.push('/edit-profile');
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.menu),
                        onPressed: () => Scaffold.of(context).openEndDrawer(),
                      ),
                    ],
                  ),
                  SliverPadding(
                    padding: EdgeInsets.all(20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Student Card
                        StudentIdCardWidget(user: user),
                        SizedBox(height: 24),

                        // Verification Status
                        VerificationStatusWidget(user: user),
                        SizedBox(height: 24),

                        // Posts Section Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              l10n.myPosts,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            BlocBuilder<PostBloc, PostState>(
                              builder: (context, state) {
                                return Text(
                                  l10n.postsCount(state.posts.length),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color
                                        ?.withOpacity(0.6),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ]),
                    ),
                  ),

                  // Posts List
                  BlocBuilder<PostBloc, PostState>(
                    builder: (context, state) {
                      if (state.status == PostStatus.loading && state.posts.isEmpty) {
                        return SliverFillRemaining(
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (state.posts.isEmpty) {
                        return SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.article_outlined,
                                  size: 64,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color
                                      ?.withOpacity(0.3),
                                ),
                                SizedBox(height: 16),
                                Text(
                                  l10n.noPostsYet,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.color
                                        ?.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            final post = state.posts[index];
                            return PostItem(post: post);
                          },
                          childCount: state.posts.length,
                        ),
                      );
                    },
                  ),

                  SliverPadding(padding: EdgeInsets.only(bottom: 40)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}