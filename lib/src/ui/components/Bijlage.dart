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
  final ValueNotifier<int> downloadCount = ValueNotifier(0);

  BijlageItem(
    this.bijlage, {
    this.onTap,
    this.download,
    this.border,
  });

  Widget build(BuildContext context) {
    List<String> splittedNaam = bijlage.naam.split(".");
    return Tooltip(
      message: bijlage.naam,
      child: ListTile(
        onTap: () {
          if (onTap != null) onTap();
          if (download != null) {
            downloadState.value = DownloadState.loading;

            download(
              bijlage,
              (count, total) {
                bijlage.downloadCount = count;
                downloadCount.value = count;
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
                child: ValueListenableBuilder(
                  valueListenable: downloadCount,
                  builder: (context, value, child) => downloadState.value == DownloadState.loading
                      ? Text(filesize(downloadCount.value) + "/" + filesize(bijlage.size))
                      : Text(
                          filesize(bijlage.size),
                        ),
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
            : ValueListenableBuilder<DownloadState>(
                valueListenable: downloadState,
                builder: (c, state, _) {
                  switch (state) {
                    case DownloadState.done:
                      return Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                      );

                      break;
                    case DownloadState.none:
                      return Icon(
                        Icons.cloud_download,
                        size: 22,
                      );
                      break;
                    case DownloadState.loading:
                      return CircularProgressIndicator();
                      break;
                  }
                  return Container();
                }),
      ),
    );
  }
}
