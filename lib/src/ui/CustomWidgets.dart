import 'package:flutter/material.dart';
import 'package:Argo/main.dart';

BorderSide greyBorderSide() {
  return BorderSide(color: theme == Brightness.dark ? Color.fromARGB(255, 100, 100, 100) : Color.fromARGB(255, 225, 225, 225), width: 1);
}

class ContentHeader extends StatelessWidget {
  final String text;

  ContentHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 15,
        top: 12.5,
        bottom: 12.5,
      ),
      child: Text(
        text,
        style: TextStyle(
          color: userdata.get("accentColor"),
        ),
      ),
    );
  }
}

class SeeCard extends Card {
  final Widget child;
  final EdgeInsets margin;
  final Color color;
  final Border border;
  final double width;
  final List<Widget> column;

  SeeCard({
    this.width,
    this.margin,
    this.child,
    this.color,
    this.border,
    this.column,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: border == null
          ? null
          : BoxDecoration(
              border: border,
            ),
      child: Card(
        margin: margin ?? EdgeInsets.zero,
        elevation: 0.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        color: color ?? null,
        child: column != null
            ? Column(
                children: column,
              )
            : child,
      ),
    );
  }
}

class ListTileBorder extends StatelessWidget {
  final Widget title;
  final Widget subtitle;
  final Widget leading;
  final Widget trailing;
  final Function onTap;
  final Border border;

  ListTileBorder({
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.border,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: border,
      ),
      child: ListTile(
        title: title,
        leading: leading,
        subtitle: subtitle,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
