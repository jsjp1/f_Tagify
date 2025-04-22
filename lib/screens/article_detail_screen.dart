import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/api/comment.dart';
import 'package:tagify/api/common.dart';
import 'package:tagify/components/contents/common.dart';
import 'package:tagify/components/explore/article_edit_modal.dart';
import 'package:tagify/components/explore/comment_container.dart';
import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/screens/content_detail_screen.dart';
import 'package:tagify/utils/smart_network_image.dart';
import 'package:tagify/utils/util.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;
  late List<Content> contents;

  ArticleDetailScreen({super.key, required this.article}) {
    // encoded content를 decode
    Map<String, dynamic> contentsMap =
        decodeBase64AndDecompress(article.encodedContent);

    contents = (contentsMap["contents"] as List<dynamic>)
        .map((item) => Content.fromJson(item))
        .toList();
  }

  @override
  ArticleDetailScreenState createState() => ArticleDetailScreenState();
}

class ArticleDetailScreenState extends State<ArticleDetailScreen> {
  late List<Comment> comments = [];
  final commentsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchArticleAllComments(widget.article.id);
  }

  Future<void> _fetchArticleAllComments(int articleId) async {
    final provider = Provider.of<TagifyProvider>(context, listen: false);

    ApiResponse<List<Comment>> _comments = await fetchArticleAllComments(
        articleId, provider.loginResponse!["access_token"]);

    if (_comments.success) {
      setState(() {
        comments = _comments.data!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final provider = Provider.of<TagifyProvider>(context, listen: false);
    final double widgetWidth = MediaQuery.of(context).size.width * (0.95);

    return Scaffold(
      appBar: AppBar(
        surfaceTintColor:
            isDarkMode ? lightBlackBackgroundColor : whiteBackgroundColor,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              articleInstanceEditBottomModal(context, widget.article);
            },
            icon: Icon(Icons.more_vert_outlined),
          ),
        ],
      ),
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 작성자 정보, 제목, 본문 부분
                    SizedBox(
                      width: widgetWidth,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(10.0),
                                child: SizedBox(
                                  width: profileImageHeightInArticleDetail,
                                  height: profileImageHeightInArticleDetail,
                                  child: widget
                                          .article.userProfileImage.isNotEmpty
                                      ? ClipOval(
                                          child: Image(
                                            image: CachedNetworkImageProvider(
                                              widget.article.userProfileImage,
                                            ),
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Icon(
                                          CupertinoIcons
                                              .person_crop_circle_fill,
                                          size:
                                              profileImageHeightInArticleDetail,
                                          color: Colors.grey),
                                ),
                              ),
                              SizedBox(
                                width:
                                    MediaQuery.of(context).size.width * (0.8),
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 5.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: GlobalText(
                                          localizeText: widget.article.title,
                                          textSize: 23.0,
                                          isBold: true,
                                          overflow: TextOverflow.ellipsis,
                                          localization: false,
                                        ),
                                      ),
                                      GlobalText(
                                        localizeText: widget.article.userName,
                                        textSize: 10.0,
                                        textColor: Colors.grey,
                                        isBold: false,
                                        overflow: TextOverflow.ellipsis,
                                        localization: false,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 250.0,
                            child: Align(
                              alignment: Alignment.topLeft,
                              child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: GlobalText(
                                  localizeText: widget.article.body,
                                  textSize: 15.0,
                                  localization: false,
                                  overflow: TextOverflow.visible,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 컨텐츠 썸네일 부분
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: articleDetailScreenThumbnailsHeight,
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          // 컨텐츠 나열 부분 (좌우 스크롤)
                          child: Row(
                            children: widget.contents.map((content) {
                              return SizedBox(
                                height:
                                    articleDetailScreenThumbnailsHeight * (0.9),
                                width:
                                    articleDetailScreenContentHeight * (16 / 9),
                                child: Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10.0),
                                  // 컨텐츠 썸네일과 제목
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ContentDetailScreen(
                                            content: content,
                                            isArticleContent: true,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          height:
                                              articleDetailScreenContentHeight,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey, width: 0.5),
                                          ),
                                          // 컨텐츠 썸네일
                                          child: ClipRRect(
                                            child: AspectRatio(
                                              aspectRatio: 16 / 9,
                                              child: SmartNetworkImage(
                                                url: content.thumbnail,
                                                fit: BoxFit.cover,
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Container(
                                                  color: Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // 컨텐츠 제목
                                        Expanded(
                                          child: GlobalText(
                                            localizeText: content.title,
                                            textSize: 13.0,
                                            overflow: TextOverflow.ellipsis,
                                            localization: false,
                                            isBold: true,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    const Divider(
                      color: moreNoticeWidgetColor,
                      height: 0.0,
                      thickness: 1.0,
                    ),
                    // 등록된 댓글 부분
                    Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 10.0),
                      child: Row(
                        children: [
                          GlobalText(
                            localizeText: comments.length.toString(),
                            textSize: 17.0,
                            isBold: true,
                            localization: false,
                          ),
                          const SizedBox(width: 5.0),
                          GlobalText(
                            localizeText:
                                "article_detail_screen_comments_length",
                            textSize: 17.0,
                            localization: true,
                          ),
                          const Expanded(child: SizedBox.shrink()),
                          const Icon(Icons.thumb_up_alt_outlined,
                              color: mainColor),
                          const SizedBox(width: 6.0),
                          GlobalText(
                            localizeText: widget.article.upCount.toString(),
                            textSize: 15.0,
                            localization: false,
                          ),
                          const SizedBox(width: 10.0),
                          const Icon(Icons.download, color: mainColor),
                          const SizedBox(width: 3.0),
                          GlobalText(
                            localizeText: widget.article.downCount.toString(),
                            textSize: 15.0,
                            localization: false,
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 0.1, thickness: 0.5),
                    SizedBox(
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: comments.length,
                        itemBuilder: (context, index) {
                          return CommentContainer(
                            comment: comments[index],
                            onDelete: () {
                              setState(() {
                                comments.removeAt(index);
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 댓글 입력 창 및 등록 버튼
            Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? lightBlackBackgroundColor
                        : whiteBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10.0),
                      topRight: Radius.circular(10.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(25),
                        offset: const Offset(0, -4),
                        blurRadius: 6.0,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding:
                            const EdgeInsets.fromLTRB(5.0, 10.0, 0.0, 10.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.77,
                          // 댓글 입력 창
                          child: TextField(
                            controller: commentsController,
                            textInputAction: TextInputAction.done,
                            autocorrect: false,
                            autofocus: false,
                            cursorColor: mainColor,
                            decoration: InputDecoration(
                              hintText:
                                  tr("article_detail_screen_comment_hint_text"),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: mainColor),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: mainColor, width: 2.0),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              isDense: true,
                              contentPadding: const EdgeInsets.all(10.0),
                            ),
                            onSubmitted: (String comment) async {
                              if (commentsController.text == "") return;

                              await postArticleComment(
                                provider.loginResponse!["id"],
                                widget.article.id,
                                comment,
                                provider.loginResponse!["access_token"],
                              );
                              commentsController.clear();
                              FocusScope.of(context).unfocus();
                              _fetchArticleAllComments(widget
                                  .article.id); // 등록하고 바로 확인할 수 있도록 다시 fetch
                            },
                          ),
                        ),
                      ),
                      // 댓글 등록 버튼
                      GestureDetector(
                        onTap: () async {
                          if (commentsController.text == "") return;

                          await postArticleComment(
                            provider.loginResponse!["id"],
                            widget.article.id,
                            commentsController.text,
                            provider.loginResponse!["access_token"],
                          );
                          commentsController.clear();
                          FocusScope.of(context).unfocus();
                          _fetchArticleAllComments(
                              widget.article.id); // 등록하고 바로 확인할 수 있도록 다시 fetch
                        },
                        child: Container(
                          width: 50.0,
                          height: 37.0,
                          decoration: BoxDecoration(
                            color: mainColor,
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Center(
                            child: GlobalText(
                                localizeText:
                                    "article_detail_screen_comment_upload_button_text",
                                textSize: 14.0,
                                isBold: true,
                                textColor:
                                    whiteBackgroundColor), // TODO: localization
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 25.0,
                  color: isDarkMode
                      ? lightBlackBackgroundColor
                      : whiteBackgroundColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
