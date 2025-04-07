import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/api/common.dart';
import 'package:tagify/components/explore/comment_edit_modal.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';

class CommentContainer extends StatefulWidget {
  final Comment comment;
  final VoidCallback? onDelete;

  const CommentContainer(
      {super.key, required this.comment, required this.onDelete});

  @override
  CommentContainerState createState() => CommentContainerState();
}

class CommentContainerState extends State<CommentContainer> {
  bool isUpvotted = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TagifyProvider>(context, listen: false);

    return Container(
      padding: EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 3.0),
          Row(
            children: [
              SizedBox(
                width: profileImageHeightInComment,
                child: widget.comment.userProfileImage.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image(
                          image: CachedNetworkImageProvider(
                            widget.comment.userProfileImage,
                          ),
                          width: profileImageHeightInComment,
                          height: profileImageHeightInComment,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        CupertinoIcons.person_crop_circle_fill,
                        size: profileImageHeightInComment,
                        color: Colors.grey,
                      ),
              ),
              const SizedBox(width: 7.0),
              GlobalText(
                localizeText: widget.comment.userName,
                textSize: 14.0,
                isBold: true,
                localization: false,
              ),
              const Expanded(child: SizedBox.shrink()),
              widget.comment.userId == provider.loginResponse!["id"]
                  ? Row(
                      // TODO 버튼 추가
                      children: [
                        const SizedBox(width: 5.0),
                        GestureDetector(
                          onTap: () async {
                            final deleted = await commentEditBottomModal(
                                context, widget.comment);
                            if (deleted && widget.onDelete != null) {
                              widget.onDelete!();
                            }
                          },
                          child: Icon(Icons.more_vert_outlined, size: 20.0),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 15.0),
          GlobalText(
            localizeText: widget.comment.body,
            textSize: 13.0,
            localization: false,
          ),
          const SizedBox(height: 5.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GlobalText(
                localizeText:
                    DateFormat("MM/dd HH:mm").format(widget.comment.createdAt),
                textSize: 11.0,
                localization: false,
                isBold: true,
                textColor: Colors.grey,
              ),
              // TODO: up count?
            ],
          ),
          const SizedBox(height: 10.0),
          const Divider(height: 0.3, color: Color.fromARGB(90, 215, 215, 215)),
        ],
      ),
    );
  }
}
