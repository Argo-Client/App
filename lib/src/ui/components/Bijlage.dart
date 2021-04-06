import 'package:argo/src/utils/hive/adapters.dart';

import 'package:flutter/material.dart';

import 'package:filesize/filesize.dart';

import 'ListTileBorder.dart';

class BijlageItem extends StatelessWidget {
  final Bron bijlage;
  final Function onTap;
  final Border border;

  BijlageItem(this.bijlage, {this.onTap, this.border});
  Widget build(BuildContext context) {
    List<String> splittedNaam = bijlage.naam.split(".");
    return Tooltip(
      child: ListTileBorder(
        onTap: onTap,
        leading: bijlage.isFolder
            ? Icon(Icons.folder_outlined)
            : Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: 5,
                    ),
                    child: Icon(
                      Icons.insert_drive_file_outlined,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      top: 7.5,
                    ),
                    child: Text(
                      splittedNaam.length > 1 ? splittedNaam.last.toUpperCase() : bijlage.naam,
                      style: TextStyle(
                        fontSize: 12.5,
                      ),
                    ),
                  )
                ],
              ),
        subtitle: bijlage.isFolder
            ? null
            : Padding(
                child: Text(
                  filesize(bijlage.size),
                ),
                padding: EdgeInsets.only(
                  bottom: 5,
                ),
              ),
        title: Padding(
          child: Text(
            splittedNaam.length > 1 ? splittedNaam.take(splittedNaam.length - 1).join(".") : bijlage.naam,
            overflow: TextOverflow.ellipsis,
          ),
          padding: EdgeInsets.symmetric(
            vertical: 10,
          ),
        ),
        trailing: bijlage.isFolder
            ? Icon(
                Icons.arrow_forward_ios,
                size: 14,
              )
            : bijlage.downloadCount == bijlage.size
                ? Icon(
                    Icons.arrow_forward_ios,
                    size: 18,
                  )
                : bijlage.downloadCount == null
                    ? Icon(
                        Icons.cloud_download,
                        size: 22,
                      )
                    : CircularProgressIndicator(),
        border: border,
      ),
      message: bijlage.naam,
    );
  }
}