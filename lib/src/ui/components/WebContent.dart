import 'package:flutter/material.dart';

import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:url_launcher/url_launcher.dart';

class WebContent extends StatelessWidget {
  final String htmlText;

  WebContent(this.htmlText);

  @override
  Widget build(BuildContext context) {
    return HtmlWidget(
      htmlText,
      onTapUrl: launch,
      customStylesBuilder: (e) {
        if (e.localName == "a") {
          return {'color': '#44b4fe'};
        }

        return null;
      },
    );
  }
}
