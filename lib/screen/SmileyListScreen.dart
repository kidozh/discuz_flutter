import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:discuz_flutter/JsonResult/SmileyResult.dart';
import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/dao/SmileyDao.dart';
import 'package:discuz_flutter/database/AppDatabase.dart';
import 'package:discuz_flutter/entity/Discuz.dart';
import 'package:discuz_flutter/entity/Smiley.dart';
import 'package:discuz_flutter/entity/User.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/screen/NullDiscuzScreen.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import '../utility/UserPreferencesUtils.dart';
import 'BlankScreen.dart';

typedef SmileyPressedFunc = void Function(Smiley);

class SmileyListScreen extends StatelessWidget {
  SmileyPressedFunc onSmileyPressed;

  SmileyListScreen(this.onSmileyPressed);

  @override
  Widget build(BuildContext context) {
    return SmileyListStatefulWidget(onSmileyPressed);
  }
}

class SmileyListStatefulWidget extends StatefulWidget {
  SmileyPressedFunc smileyValueGetter;

  SmileyListStatefulWidget(this.smileyValueGetter);

  @override
  State<SmileyListStatefulWidget> createState() {
    return SmileyListState(this.smileyValueGetter);
  }
}

class SmileyListState extends State<SmileyListStatefulWidget> {
  static const double _tabItemExtent = 84;
  static const double _tabGap = 4;

  SmileyPressedFunc smileyValueGetter;

  SmileyListState(this.smileyValueGetter);

  SmileyResult? result;
  late SmileyDao _smileyDao;
  final PageController _pageController = PageController();
  final ScrollController _tabScrollController = ScrollController();
  List<Smiley> _savedSmileyList = [];
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _tabScrollController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    await _initDB();
    if (mounted) {
      await _loadSmilesInfo();
    }
  }

  Future<void> _initDB() async {
    _smileyDao = await AppDatabase.getSmileyDao();
    if (!mounted) return;

    Discuz? discuz =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
    if (discuz == null) {
      return;
    }

    final smileyList = _smileyDao.findAllSmileyByDiscuz(discuz);
    // load cache first
    final smileyJson =
        await UserPreferencesUtils.getDiscuzSmileyCacheJson(discuz);
    SmileyResult? cachedResult;
    // Try to recover the cached smiley groups before loading the network data.
    try {
      if (smileyJson.trim().isNotEmpty) {
        cachedResult = SmileyResult.fromJson(jsonDecode(smileyJson));
      }
    } catch (e) {
      log("Loading smiley json error $smileyJson \n --- \n $e ");
    }

    if (!mounted) return;
    final shouldSelectFirstRemote = cachedResult != null &&
        _selectedTabIndex == 0 &&
        smileyList.isEmpty &&
        cachedResult.variables.smilies.isNotEmpty;
    setState(() {
      _savedSmileyList = smileyList;
      if (cachedResult != null) {
        result = cachedResult;
        if (shouldSelectFirstRemote) _selectedTabIndex = 1;
      }
    });
    if (shouldSelectFirstRemote) _syncSelectedPage(animate: false);
  }

  Future<void> _loadSmilesInfo() async {
    Discuz? discuz =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
    if (discuz == null) {
      return;
    }
    User? user =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).user;
    try {
      final dio = await NetworkUtils.getDioWithPersistCookieJar(user);
      final client = MobileApiClient(dio, baseUrl: discuz.baseURL);
      final value = await client.smileyResult();
      if (!mounted) return;

      final shouldSelectFirstRemote = _selectedTabIndex == 0 &&
          _savedSmileyList.isEmpty &&
          value.variables.smilies.isNotEmpty;
      setState(() {
        result = value;
        if (shouldSelectFirstRemote) _selectedTabIndex = 1;
      });
      if (shouldSelectFirstRemote) _syncSelectedPage(animate: false);
      await UserPreferencesUtils.putDiscuzSmileyCacheJson(
        discuz,
        jsonEncode(value.toJson()),
      );
    } catch (error, stackTrace) {
      log(
        "Loading smiley info failed",
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  void _selectTab(int index) {
    if (index == _selectedTabIndex) {
      _scrollSelectedTabIntoView(index);
      return;
    }
    VibrationUtils.vibrateWithClickIfPossible();
    setState(() => _selectedTabIndex = index);
    _syncSelectedPage(animate: true);
  }

  void _syncSelectedPage({required bool animate}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final index = _selectedTabIndex;
      if (_pageController.hasClients) {
        if (animate) {
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
          );
        } else {
          _pageController.jumpToPage(index);
        }
      }
      _scrollSelectedTabIntoView(index);
    });
  }

  void _scrollSelectedTabIntoView(int index) {
    if (!_tabScrollController.hasClients) return;
    final position = _tabScrollController.position;
    final itemCenter =
        index * (_tabItemExtent + _tabGap) + _tabItemExtent / 2 + _tabGap;
    final target = (itemCenter - position.viewportDimension / 2)
        .clamp(0.0, position.maxScrollExtent)
        .toDouble();
    _tabScrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
    );
  }

  Widget _buildScrollableGlassTabs(
    BuildContext context,
    List<String> labels,
    int selectedIndex,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    return PlatformLiquidGlassCard(
      borderRadius: BorderRadius.circular(22),
      padding: const EdgeInsets.all(3),
      child: SizedBox(
        height: 38,
        child: ListView.separated(
          controller: _tabScrollController,
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          padding: const EdgeInsets.symmetric(horizontal: _tabGap),
          itemCount: labels.length,
          separatorBuilder: (_, __) => const SizedBox(width: _tabGap),
          itemBuilder: (context, index) {
            final selected = index == selectedIndex;
            return Semantics(
              button: true,
              selected: selected,
              label: labels[index],
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => _selectTab(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  width: _tabItemExtent,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: selected
                        ? colorScheme.primary.withValues(alpha: 0.18)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(17),
                    border: selected
                        ? Border.all(
                            color: colorScheme.primary.withValues(alpha: 0.32),
                            width: 0.8,
                          )
                        : null,
                  ),
                  child: Text(
                    labels[index],
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: selected
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant,
                          fontWeight:
                              selected ? FontWeight.w600 : FontWeight.w400,
                        ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Discuz? discuz =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
    if (discuz == null) {
      return NullDiscuzScreen();
    } else {
      List<String> smileyTabLabels = [];
      List<List<Smiley>> smileyList = [];
      List<Widget> tabBarViewList = [];
      // add saved smiley first
      smileyTabLabels.add(S.of(context).savedSmileyTabTitle);

      tabBarViewList.add(SavedSmileyTabView(smileyValueGetter));
      if (result != null) {
        smileyList.addAll(result!.variables.smilies);
        for (int i = 0; i < smileyList.length; i++) {
          smileyTabLabels.add(S.of(context).smileyLabel(i + 1));
        }

        for (int i = 0; i < smileyList.length; i++) {
          List<Smiley> currentSmiley = smileyList[i];
          List<Widget> smileyImageList = [];

          for (int j = 0; j < currentSmiley.length; j++) {
            Smiley smiley = currentSmiley[j];
            smileyImageList.add(
              InkWell(
                  onTap: () async {
                    VibrationUtils.vibrateWithClickIfPossible();
                    smileyValueGetter(smiley);

                    // add to smiley
                    // check whether exist
                    Smiley? smileyInDb = _smileyDao.findSmileyByDiscuzIdAndCode(
                        discuz, smiley.code);
                    log("on tap smiley $smiley ${smileyInDb}");
                    if (smileyInDb != null) {
                      smileyInDb.dateTime = DateTime.now();
                      smiley.discuz = discuz;
                      _smileyDao.insertSmileyWithKey(
                          smileyInDb.key, smileyInDb);
                    } else {
                      smiley.discuz = discuz;
                      _smileyDao.insertSmiley(smiley);
                    }
                  },
                  child: CachedNetworkImage(
                    imageUrl: discuz.baseURL +
                        "/static/image/smiley/" +
                        currentSmiley[j].relativePath,
                    progressIndicatorBuilder:
                        (context, url, downloadProgress) =>
                            PlatformCircularProgressIndicator(
                      material: (context, platform) =>
                          MaterialProgressIndicatorData(
                              value: downloadProgress.progress),
                      cupertino: (context, platform) =>
                          CupertinoProgressIndicatorData(
                              color: Theme.of(context).colorScheme.primary),
                    ),
                    errorWidget: (context, url, error) =>
                        Icon(Icons.image_not_supported),
                  )),
            );
          }
          tabBarViewList.add(GridView.count(
            shrinkWrap: true,
            crossAxisCount: 6,
            padding: EdgeInsets.all(4.0),
            children: smileyImageList,
          ));
        }
      }
      final effectiveIndex =
          _selectedTabIndex.clamp(0, smileyTabLabels.length - 1).toInt();
      if (isMaterial(context)) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.25,
          child: DefaultTabController(
            key: ValueKey("smiley-tabs-${smileyTabLabels.length}"),
            length: smileyTabLabels.length,
            initialIndex: effectiveIndex,
            child: Column(
              children: [
                TabBar(
                  tabs: [
                    for (final label in smileyTabLabels) Tab(text: label),
                  ],
                  isScrollable: true,
                  labelColor: Theme.of(context).colorScheme.primary,
                  unselectedLabelColor: Colors.grey,
                ),
                Expanded(child: TabBarView(children: tabBarViewList)),
              ],
            ),
          ),
        );
      }

      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.28,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
              child: _buildScrollableGlassTabs(
                context,
                smileyTabLabels,
                effectiveIndex,
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  if (_selectedTabIndex != index) {
                    setState(() => _selectedTabIndex = index);
                    _scrollSelectedTabIntoView(index);
                  }
                },
                children: tabBarViewList,
              ),
            ),
          ],
        ),
      );
    }
  }
}

class SavedSmileyTabView extends StatelessWidget {
  SmileyPressedFunc smileyValueGetter;
  SavedSmileyTabView(this.smileyValueGetter);

  @override
  Widget build(BuildContext context) {
    return SavedSmileyTabViewStatefulWidget(smileyValueGetter);
  }
}

class SavedSmileyTabViewStatefulWidget extends StatefulWidget {
  SmileyPressedFunc smileyValueGetter;
  SavedSmileyTabViewStatefulWidget(this.smileyValueGetter);
  @override
  SavedSmileyTabViewState createState() {
    return SavedSmileyTabViewState(this.smileyValueGetter);
  }
}

class SavedSmileyTabViewState extends State<SavedSmileyTabViewStatefulWidget> {
  SmileyPressedFunc smileyValueGetter;
  SmileyDao? _smileyDao;
  SavedSmileyTabViewState(this.smileyValueGetter);

  @override
  void initState() {
    super.initState();
    _initDB();
  }

  void _initDB() async {
    SmileyDao smileyDao = await AppDatabase.getSmileyDao();
    setState(() {
      _smileyDao = smileyDao;
    });

    Discuz? discuz =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
    if (discuz == null) {
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    Discuz? discuz =
        Provider.of<DiscuzAndUserNotifier>(context, listen: false).discuz;
    if (_smileyDao == null) {
      return BlankScreen();
    }
    if (discuz == null) {
      return NullDiscuzScreen();
    } else {
      return ValueListenableBuilder(
        valueListenable: _smileyDao!.smileyBox.listenable(),
        builder: (BuildContext context, Box<Smiley> value, Widget? child) {
          List<Smiley> smileyData = _smileyDao!.findAllSmileyByDiscuz(discuz);
          if (smileyData.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.arrow_forward),
                Text(S.of(context).noSmileyFoundInDB)
              ],
            );
          } else {
            List<Widget> smileyImageList = [];
            for (int j = 0; j < smileyData.length; j++) {
              Smiley smiley = smileyData[j];
              // log("on Database smiley $smiley");
              smileyImageList.add(
                InkWell(
                    onTap: () async {
                      VibrationUtils.vibrateWithClickIfPossible();
                      smileyValueGetter(smiley);
                      // add to smiley
                      // check whether exist
                      if (smiley.key != null) {
                        smiley.dateTime = DateTime.now();
                        _smileyDao!.insertSmileyWithKey(smiley.key, smiley);
                      }
                      log("pressed smiley ${smiley} ${smiley.key} ");
                    },
                    child: CachedNetworkImage(
                      imageUrl: discuz.baseURL +
                          "/static/image/smiley/" +
                          smiley.relativePath,
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) =>
                              CircularProgressIndicator(
                                  value: downloadProgress.progress),
                      errorWidget: (context, url, error) =>
                          Icon(Icons.image_not_supported),
                    )),
              );
            }
            return GridView.count(
              shrinkWrap: true,
              crossAxisCount: 6,
              padding: EdgeInsets.all(4.0),
              children: smileyImageList,
            );
          }
        },
      );
    }
  }
}
