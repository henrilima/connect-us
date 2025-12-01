import 'package:connect/ui/app_color.dart';
import 'package:connect/ui/skeletons.dart';
import 'package:connect/widgets/fade_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomHeader extends StatelessWidget {
  final Function setPage;
  final bool hasBackPage;
  final String? title;
  final String? photoUrl;
  final List<Widget>? actions;
  final bool loading;
  const CustomHeader(
    this.setPage,
    this.hasBackPage, {
    this.actions,
    this.title,
    this.photoUrl,
    this.loading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: hasBackPage
              ? MainAxisAlignment.spaceBetween
              : MainAxisAlignment.end,
          children: [
            if (hasBackPage)
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: FaIcon(
                  Icons.arrow_back,
                  size: 28,
                  color: AppColors.textColorSecondary,
                ),
              ),
            if (title != null && title!.isNotEmpty)
              loading
                  ? const SkeletonText(width: 150, height: 24)
                  : Text(
                      title!,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textColorSecondary,
                      ),
                    ),
            if (actions == null && title == null)
              InkWell(
                onTap: () => loading ? null : setPage("settings"),
                child: loading
                    ? const SkeletonAvatar(radius: 24)
                    : CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.transparent,
                        child: ClipOval(
                          child: FadeNetworkImage(
                            imageUrl:
                                photoUrl ??
                                "https://avatar.iran.liara.run/public/38",
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
              )
            else if (actions != null)
              loading
                  ? Row(
                      spacing: 8,
                      children: List.generate(
                        actions!.length,
                        (index) => const Skeleton(
                          width: 24,
                          height: 24,
                          borderRadius: 4,
                        ),
                      ),
                    )
                  : Row(spacing: 2, children: actions!)
            else
              SizedBox(height: 24, width: 24),
          ],
        ),
      ),
    );
  }
}
