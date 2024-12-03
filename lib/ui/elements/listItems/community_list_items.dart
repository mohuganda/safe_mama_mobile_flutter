import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:safe_mama/models/community_model.dart';
import 'package:safe_mama/themes/main_theme.dart';
import 'package:safe_mama/ui/elements/dialogs/info_dialog.dart';
import 'package:safe_mama/ui/screens/auth/auth_view_model.dart';
import 'package:safe_mama/ui/screens/communities/communities_view_model.dart';
import 'package:safe_mama/ui/screens/communities/detail/community_detail_screen.dart';
import 'package:safe_mama/utils/helpers.dart';
import 'package:safe_mama/utils/l10n_extensions.dart';
import 'package:safe_mama/utils/navigation/route_names.dart';
import 'package:provider/provider.dart';

class CommunityListItem extends StatelessWidget {
  final CommunityModel community;
  final VoidCallback? onClick;
  final double? borderRadius;

  const CommunityListItem(
      {super.key, required this.community, this.onClick, this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 0),
      child: InkWell(
        onTap: onClick,
        child: Card(
          elevation: 0,
          color: Colors.white,
          margin: const EdgeInsets.all(8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  community.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                community.description.isNotEmpty
                    ? Html(
                        data:
                            Helpers.truncateHtmlText(community.description, 4),
                        style: {
                          "body": Style(
                              maxLines: 5,
                              fontSize: FontSize(14),
                              textOverflow: TextOverflow.ellipsis,
                              padding: HtmlPaddings.zero),
                        },
                      )
                    // Text(
                    //     community.description,
                    //     style: const TextStyle(fontSize: 14),
                    //     maxLines: 2,
                    //     overflow: TextOverflow.ellipsis,
                    //   )

                    : const SizedBox.shrink(),
                const SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem(context, Icons.people,
                        '${community.membersCount} Members'),
                    _buildStatItem(context, Icons.forum,
                        '${community.forumsCount} Forums'),
                    _buildStatItem(context, Icons.book,
                        '${community.publicationsCount} Publications'),
                  ],
                ),

                const SizedBox(height: 12),

                if (community.userJoined)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                          child: _buildActionButton(context, 'Publications',
                              type: 3)),
                      Expanded(
                          child:
                              _buildActionButton(context, 'Forums', type: 4)),
                      Expanded(
                          child: _buildActionButton(context, 'Leave',
                              type: 2, color: Colors.red)),
                    ],
                  )
                else if (community.userPendingApproval)
                  _buildActionButton(context, 'Pending Approval',
                      color: Colors.orange, isFullWidth: true)
                else
                  _buildActionButton(context, 'Join Community',
                      type: 1,
                      color: Theme.of(context).primaryColor,
                      isFullWidth: true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).primaryColor, size: 20),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context, String label,
      {int? type, Color? color, bool isFullWidth = false}) {
    return OutlinedButton(
      onPressed: () {
        if (type == null) return;
        if (type == 1 || type == 2) {
          _showActionDialog(context, type);
        } else if (type == 3) {
          context.pushNamed(communityDetail,
              extra: CommunityDetailModel(
                  communityId: community.id,
                  title: community.name,
                  actionType: 1));
        } else if (type == 4) {
          context.pushNamed(communityDetail,
              extra: CommunityDetailModel(
                  communityId: community.id,
                  title: community.name,
                  actionType: 2));
        }
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: color ?? Theme.of(context).primaryColor,
        side: BorderSide(
          color: color ?? Theme.of(context).primaryColor,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
      ),
      child: community.isLoading
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                    strokeWidth: 2,
                  ),
                ),
                const SizedBox(width: 8),
                Text(context.localized.pleaseWait),
              ],
            )
          : SizedBox(
              width: isFullWidth ? double.infinity : null,
              child: Text(
                label,
                textAlign: TextAlign.center,
              ),
            ),
    );
  }

  void _showActionDialog(BuildContext context, int type) {
    showDialog(
        useSafeArea: false,
        context: context,
        builder: (BuildContext context) {
          return InfoDialog(
            title: context.localized.confirm,
            icon: Icons.logout,
            titleBackgroundColor:
                type == 2 ? MainTheme.appColors.red400 : Colors.orange,
            content: _buildDescription(context, type),
            confirmText: context.localized.confirm,
            confirmTextColor: Colors.white,
            confirmBackgroundColor:
                type == 2 ? MainTheme.appColors.red400 : Colors.orange,
            cancelText: context.localized.cancel,
            onConfirm: () {
              Navigator.of(context).pop(); // Close the dialog
              if (type == 1) {
                _joinCommunity(context);
              } else if (type == 2) {
                _leaveCommunity(context);
              }
            },
            onCancel: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          );
        });
  }

  _leaveCommunity(BuildContext context) {
    Provider.of<CommunitiesViewModel>(context, listen: false)
        .leaveCommunity(community.id);
  }

  _joinCommunity(BuildContext context) {
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    if (!authViewModel.state.isLoggedIn) {
      context.pushNamed(login);
    } else {
      // context.pop();
      Provider.of<CommunitiesViewModel>(context, listen: false)
          .joinCommunity(community.id);
    }
  }

  _buildDescription(BuildContext context, int type) {
    if (type == 1) {
      return context.localized.areYouSureYouWantToJoinThisCommunity;
    } else if (type == 2) {
      return context.localized.areYouSureYouWantToLeaveThisCommunity;
    }
  }
}
