import 'dart:developer';

import 'package:discuz_flutter/client/MobileApiClient.dart';
import 'package:discuz_flutter/generated/l10n.dart';
import 'package:discuz_flutter/provider/DiscuzAndUserNotifier.dart';
import 'package:discuz_flutter/utility/NetworkUtils.dart';
import 'package:discuz_flutter/utility/PlatformAdaptiveWidgets.dart';
import 'package:discuz_flutter/utility/VibrationUtils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';

enum ReportReason {
  trashAdvertisement,
  illegalContent,
  spam,
  duplicatePost,
  others,
}

class ReportContentPage extends StatefulWidget {
  final String authorName;
  final int rid;
  final int fid;
  final String formhash;

  const ReportContentPage(
    this.authorName,
    this.rid,
    this.fid,
    this.formhash, {
    super.key,
  });

  @override
  State<ReportContentPage> createState() => _ReportContentPageState();
}

class _ReportContentPageState extends State<ReportContentPage> {
  ReportReason? selectedReason;
  final TextEditingController reportDetailReasonTextController =
      TextEditingController();
  bool _isSubmitting = false;

  bool get _canSubmit {
    if (_isSubmitting || selectedReason == null) return false;
    return selectedReason != ReportReason.others ||
        reportDetailReasonTextController.text.trim().isNotEmpty;
  }

  Map<ReportReason, String> _reasonLabels(BuildContext context) => {
        ReportReason.trashAdvertisement: S.of(context).trashAd,
        ReportReason.illegalContent: S.of(context).illegalContent,
        ReportReason.spam: S.of(context).spam,
        ReportReason.duplicatePost: S.of(context).duplicatedPost,
        ReportReason.others: S.of(context).other,
      };

  @override
  void dispose() {
    reportDetailReasonTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = S.of(context).reportContentTitle(widget.authorName);
    final primary = Theme.of(context).colorScheme.primary;
    final reasons = _reasonLabels(context);

    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(
        liquidGlassTitle: title,
        title: Text(title),
        automaticallyImplyLeading: true,
      ),
      body: PlatformLiquidGlassPageBackdrop(
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final entry in reasons.entries)
                  PlatformCard(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    color: selectedReason == entry.key
                        ? (isCupertino(context)
                            ? primary
                            : Theme.of(context).colorScheme.primaryContainer)
                        : null,
                    child: PlatformListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 5,
                      ),
                      title: Text(
                        entry.value,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: selectedReason == entry.key
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                      ),
                      trailing: selectedReason == entry.key
                          ? Icon(
                              PlatformIcons(context).checkMark,
                              size: 18,
                              color: primary,
                            )
                          : const SizedBox(width: 18),
                      onTap: () {
                        VibrationUtils.vibrateWithClickIfPossible();
                        setState(() => selectedReason = entry.key);
                      },
                    ),
                  ),
                if (selectedReason == ReportReason.others) ...[
                  const SizedBox(height: 7),
                  PlatformTextField(
                    hintText: S.of(context).reportOtherReasonHint,
                    controller: reportDetailReasonTextController,
                    minLines: 3,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    onChanged: (_) => setState(() {}),
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: PlatformElevatedButton(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 13,
                    ),
                    onPressed: _canSubmit ? _reportContent : null,
                    child: Text(title),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _reportContent() async {
    if (!_canSubmit) return;
    setState(() => _isSubmitting = true);

    try {
      final notifier =
          Provider.of<DiscuzAndUserNotifier>(context, listen: false);
      final discuz = notifier.discuz!;
      final dio = await NetworkUtils.getDioWithPersistCookieJar(notifier.user);
      final client = MobileApiClient(dio, baseUrl: discuz.baseURL);
      if (!mounted) return;
      final reportSelect = _reasonLabels(context)[selectedReason]!;

      await client.reportContent(
        widget.formhash,
        reportSelect,
        reportDetailReasonTextController.text.trim(),
        'post',
        widget.rid,
      );
      if (!mounted) return;
      EasyLoading.showSuccess(
          S.of(context).reportSuccessfully(discuz.siteName));
      Navigator.of(context).pop();
    } catch (error, stackTrace) {
      log('Failed to report content', error: error, stackTrace: stackTrace);
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
