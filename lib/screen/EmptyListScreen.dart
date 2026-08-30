import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class EmptyListScreen extends StatelessWidget {
  final EmptyItemType emptyItemType;

  const EmptyListScreen(this.emptyItemType, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 72, horizontal: 16),
      child: PlatformCard(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Center(
          child: Text(
            getTitleString(context),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w300,
                ),
          ),
        ),
      ),
    );
  }

  Widget getSpinkitWidget(BuildContext context) {
    switch (emptyItemType) {
      case EmptyItemType.thread:
        return SpinKitChasingDots(
          color: Theme.of(context).colorScheme.primary,
          size: 25.0,
        );
      case EmptyItemType.post:
        return SpinKitFadingGrid(
          color: Theme.of(context).colorScheme.primary,
          size: 25.0,
        );
      case EmptyItemType.user:
        return SpinKitSquareCircle(
          color: Theme.of(context).colorScheme.primary,
          size: 25.0,
        );
      case EmptyItemType.forum:
        return SpinKitWanderingCubes(
          color: Theme.of(context).colorScheme.primary,
          size: 25.0,
        );
      case EmptyItemType.trustHost:
        return SpinKitWave(
          color: Theme.of(context).colorScheme.primary,
          size: 25.0,
        );
      case EmptyItemType.history:
        return SpinKitSpinningLines(
          color: Theme.of(context).colorScheme.primary,
          size: 25.0,
        );
      case EmptyItemType.notification:
        return SpinKitThreeBounce(
          color: Theme.of(context).colorScheme.primary,
          size: 25.0,
        );
      case EmptyItemType.others:
        return SpinKitWave(
          color: Theme.of(context).colorScheme.primary,
          size: 25.0,
        );
    }
  }

  String getTitleString(BuildContext context) {
    switch (emptyItemType) {
      case EmptyItemType.trustHost:
        return S.of(context).emptyTrustHost;
      case EmptyItemType.thread:
        return S.of(context).emptyThreads;
      case EmptyItemType.post:
        return S.of(context).emptyPosts;
      case EmptyItemType.user:
        return S.of(context).emptyUser;
      case EmptyItemType.forum:
        return S.of(context).emptyForum;
      case EmptyItemType.history:
        return S.of(context).emptyHistory;
      case EmptyItemType.others:
        return S.of(context).emptyListDescription;
      case EmptyItemType.notification:
        return S.of(context).emptyNotification;
    }
  }
}

enum EmptyItemType {
  thread,
  post,
  user,
  forum,
  trustHost,
  history,
  notification,
  others,
}
