import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:tagify/global.dart';
import 'package:tagify/provider.dart';
import 'package:tagify/api/article.dart';

void exploreScreenUploadDialog(BuildContext context) {
  final double dialogWidth = MediaQuery.of(context).size.width * 0.8;
  final TextEditingController titleController = TextEditingController();
  final TextEditingController bodyController = TextEditingController();
  final TextEditingController base64Controller = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      final provider = Provider.of<TagifyProvider>(context, listen: false);

      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: SizedBox(
          width: dialogWidth,
          height: 300.0,
          child: Container(
            decoration: BoxDecoration(
              color: whiteBackgroundColor,
              border: Border.all(color: Colors.grey, width: 3.0),
            ),
            child: Column(
              children: [
                Text("Upload Dialog"),
                TextField(
                  controller: titleController,
                ),
                TextField(
                  controller: bodyController,
                ),
                TextField(
                  controller: base64Controller,
                ),
                IconButton(
                  icon: Icon(Icons.person_pin_circle),
                  onPressed: () async {
                    await postArticle(
                        provider.loginResponse!["id"],
                        titleController.text,
                        bodyController.text,
                        base64Controller.text);

                    await provider.fetchArticles();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
