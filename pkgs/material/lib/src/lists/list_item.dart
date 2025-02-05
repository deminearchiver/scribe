import 'package:material/material.dart';

class ListItem extends StatelessWidget {
  const ListItem({
    super.key,
    this.onTap,
    this.leading,
    this.headline,
    this.supportingText,
    this.trailing,
  });

  final VoidCallback? onTap;

  final Widget? leading;
  final Widget? headline;
  final Widget? supportingText;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: leading,
      title: headline,
      subtitle: supportingText,
      trailing: trailing,
    );
  }
}
