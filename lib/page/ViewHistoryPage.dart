import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/dao/ViewHistoryDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/ViewHistory.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/BlankScreen.dart';
import 'package:discuz_flutter/screen/EmptyListScreen.dart';
import 'package:discuz_flutter/utility/AppPlatformIcons.dart';
import 'package:discuz_flutter/utility/CustomizeColor.dart';
import 'package:discuz_flutter/utility/TimeDisplayUtils.dart';
import 'package:discuz_flutter/utility/URLUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'DisplayForumSliverPage.dart';
import 'ViewThreadSliverPage.dart';

class ViewHistoryPage extends StatefulWidget {
  final Discuz discuz;

  const ViewHistoryPage(this.discuz, {super.key});

  @override
  State<ViewHistoryPage> createState() => ViewHistoryState();
}

class ViewHistoryState extends State<ViewHistoryPage> {
  ViewHistoryDao? _viewHistoryDao;

  Discuz get discuz => widget.discuz;

  @override
  void initState() {
    super.initState();
    _initDb();
  }

  void _initDb() async {
    ViewHistoryDao viewHistoryDao = await AppDatabase.getViewHistoryDao();
    if (!mounted) return;
    setState(() {
      _viewHistoryDao = viewHistoryDao;
    });
  }

  void _showDeleteAllDialog(BuildContext context) {
    showPlatformAlert(
      context: context,
      title: S.of(context).clearAllViewHistories,
      message: S.of(context).deleteViewHistoryWarnContent,
      actions: [
        PlatformAlertAction(
          label: S.of(context).ok,
          isDestructiveAction: true,
          onPressed: () async {
            VibrationUtils.vibrateWithHeavyFeedbackIfPossible();
            await _clearAllViewHistory();
          },
        ),
        PlatformAlertAction(
          label: S.of(context).cancel,
          isCancelAction: true,
          onPressed: () {
            VibrationUtils.vibrateWithClickIfPossible();
          },
        ),
      ],
    );
  }

  Future<void> _clearAllViewHistory() async {
    ViewHistoryDao viewHistoryDao = await AppDatabase.getViewHistoryDao();
    await viewHistoryDao.deleteViewHistoryByDiscuz(discuz);
    //Navigator.pop(context);
  }

  Future<void> _deleteViewHistory(ViewHistory viewHistory) async {
    var viewHistoryDao = await AppDatabase.getViewHistoryDao();
    viewHistoryDao.deleteViewHistories([viewHistory]);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(S
            .of(context)
            .successfullyDeleteViewHistoryContent(viewHistory.subject)),
        action: SnackBarAction(
          label: S.of(context).undo,
          onPressed: () {
            viewHistoryDao.insertViewHistory(viewHistory);
          },
        )));
  }

  Widget getUserAvatar(int uid, String username) {
    return CachedNetworkImage(
      imageUrl: URLUtils.getAvatarURL(discuz, uid.toString()),
      progressIndicatorBuilder: (context, url, downloadProgress) =>
          PlatformCircularProgressIndicator(
        material: (context, platform) =>
            MaterialProgressIndicatorData(value: downloadProgress.progress),
      ),
      errorWidget: (context, url, error) => CircleAvatar(
        backgroundColor: CustomizeColor.getColorBackgroundById(uid),
        child: Text(
          username.isNotEmpty
              ? username[0].toUpperCase()
              : S.of(context).anonymous,
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      imageBuilder: (context, imageProvider) => Container(
        // width: 16.0,
        // height: 16.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_viewHistoryDao != null) {
      return PlatformScaffold(
          appBar: PlatformAppBar(
            title: Text(S.of(context).viewHistory),
            automaticallyImplyLeading: true,
            trailingActions: [
              PlatformIconButton(
                liquidGlassSymbol: 'trash',
                onPressed: () {
                  VibrationUtils.vibrateWithClickIfPossible();
                  _showDeleteAllDialog(context);
                },
                //label: S.of(context).clearAllViewHistories,
                icon: Icon(
                  AppPlatformIcons(context).deleteSolid,
                  size: 20,
                  semanticLabel: S.of(context).clearAllViewHistories,
                ),
              )
            ],
          ),
          body: PlatformLiquidGlassPageBackdrop(
            child: ValueListenableBuilder(
              valueListenable: _viewHistoryDao!.viewHistoryBox.listenable(),
              builder: (context, Box<ViewHistory> box, widget) {
                final viewHistoryList =
                    _viewHistoryDao!.findAllViewHistoriesByDiscuz(discuz);
                if (viewHistoryList.isEmpty) {
                  return EmptyListScreen(EmptyItemType.history);
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  itemBuilder: (context, index) {
                    final viewHistory = viewHistoryList[index];
                    return Dismissible(
                      key: Key(viewHistory.key.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        padding: const EdgeInsets.only(right: 20),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .error
                              .withValues(alpha: 0.84),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Icon(
                          AppPlatformIcons(context).deleteSolid,
                          color: Theme.of(context).colorScheme.onError,
                          size: 20,
                        ),
                      ),
                      child: PlatformCard(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        child: PlatformListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          leading: PlatformLiquidGlassAvatar(
                            size: 44,
                            child: viewHistory.type == 'thread'
                                ? getUserAvatar(
                                    viewHistory.authorId,
                                    viewHistory.author,
                                  )
                                : ColoredBox(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    child: Icon(
                                      AppPlatformIcons(context).forumOutlined,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimaryContainer,
                                      size: 18,
                                    ),
                                  ),
                          ),
                          title: Text(
                            viewHistory.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: RichText(
                            overflow: TextOverflow.ellipsis,
                            text: TextSpan(
                              text: '',
                              style: DefaultTextStyle.of(context).style,
                              children: [
                                if (viewHistory.author.isNotEmpty)
                                  TextSpan(
                                    text: viewHistory.author,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                if (viewHistory.author.isNotEmpty)
                                  const TextSpan(text: ' · '),
                                TextSpan(
                                  text: TimeDisplayUtils.getLocaledTimeDisplay(
                                    context,
                                    viewHistory.updateTime,
                                  ),
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          trailing: Icon(
                            PlatformIcons(context).forward,
                            size: 18,
                          ),
                          onTap: () => _openViewHistory(viewHistory),
                        ),
                      ),
                      onDismissed: (_) => _deleteViewHistory(viewHistory),
                    );
                  },
                  itemCount: viewHistoryList.length,
                );
              },
            ),
          ));
    } else {
      return BlankScreen();
    }
  }

  Future<void> _openViewHistory(ViewHistory viewHistory) async {
    VibrationUtils.vibrateWithClickIfPossible();
    final user =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    if (viewHistory.type == 'thread') {
      await Navigator.push(
        context,
        platformPageRoute(
          context: context,
          iosTitle: viewHistory.title,
          builder: (context) => ViewThreadSliverPage(
            discuz,
            user,
            viewHistory.identification,
          ),
        ),
      );
    } else if (viewHistory.type == 'forum') {
      await Navigator.push(
        context,
        platformPageRoute(
          context: context,
          iosTitle: viewHistory.title,
          builder: (context) => DisplayForumTwoPanePage(
            discuz,
            user,
            viewHistory.identification,
          ),
        ),
      );
    }
  }
}
