import 'package:argo/src/utils/hive/adapters.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';

import 'package:filesize/filesize.dart';

enum DownloadState { done, loading, none }

class BijlageItem extends StatelessWidget {
  final Bron bijlage;
  final Function onTap;
  final Border border;
  final ValueNotifier<DownloadState> downloadState = ValueNotifier(DownloadState.none);
  final Future Function(Bron, Function(int, int)) download;

  BijlageItem(
    this.bijlage, {
    this.onTap,
    this.download,
    this.border,
  });
  Widget build(BuildContext context) {
    List<String> splittedNaam = bijlage.naam.split(".");
    return Tooltip(
      child: ListTile(
        onTap: () {
          if (onTap != null) onTap();
          if (download != null) {
            download(
              bijlage,
              (count, total) {
                bijlage.downloadCount = count;
                if (count >= total) {
                  downloadState.value = DownloadState.done;
                }
              },
            );
          }
        },
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
            : ValueListenableBuilder(
                valueListenable: downloadState,
                builder: (c, state, _) {
                  if (state == DownloadState.done) {
                    return Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                    );
                  }
                  if (state == DownloadState.none) {
                    return Icon(
                      Icons.cloud_download,
                      size: 22,
                    );
                  }
                  return CircularProgressIndicator();
                }),
      ),
      message: bijlage.naam,
    );
  }
}
