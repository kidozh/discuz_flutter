import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:html_unescape/html_unescape.dart';

class LoadingStateWidget extends StatelessWidget {
  final String? hintText;

  const LoadingStateWidget({this.hintText, super.key});

  @override
  Widget build(BuildContext context) {
    if (isCupertino(context)) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CupertinoActivityIndicator(radius: 12),
              if (hintText?.trim().isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Text(
                  HtmlUnescape().convert(hintText!),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: CupertinoTheme.of(context).textTheme.textStyle
                      .copyWith(
                        color: CupertinoColors.secondaryLabel.resolveFrom(
                          context,
                        ),
                        fontSize: 15,
                      ),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return PlatformCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 72),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 50,
            width: 50,
            child: PlatformCircularProgressIndicator(),
          ),
          if (hintText != null) SizedBox(height: 16),
          if (hintText != null)
            Text(
              HtmlUnescape().convert(hintText!),
              style: TextStyle(
                color: Theme.of(context).disabledColor,
                fontSize: 24,
                fontWeight: Theme.of(context).brightness == Brightness.dark
                    ? FontWeight.normal
                    : FontWeight.w300,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
