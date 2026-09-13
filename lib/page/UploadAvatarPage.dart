import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../client/ForumInteractionClient.dart';
import '../entity/Discuz.dart';
import '../entity/User.dart';
import '../generated/l10n.dart';
import '../provider/DiscuzAndUserNotifier.dart';
import '../utility/NetworkUtils.dart';
import '../utility/PlatformAdaptiveWidgets.dart';

/// Convert picker formats to PNG accepted by Discuz, with a bounded resolution.
Future<Uint8List> prepareAvatar(Uint8List source) async {
  if (source.isEmpty || source.length > 20 * 1024 * 1024)
    throw const FormatException('Invalid image size');
  final buffer = await ui.ImmutableBuffer.fromUint8List(source);
  ui.ImageDescriptor? descriptor;
  ui.Codec? codec;
  ui.Image? image;
  try {
    descriptor = await ui.ImageDescriptor.encoded(buffer);
    if (descriptor.width < 10 || descriptor.height < 10)
      throw const FormatException('Image too small');
    final scale =
        512 /
        (descriptor.width > descriptor.height
            ? descriptor.width
            : descriptor.height);
    codec = await descriptor.instantiateCodec(
      targetWidth: scale < 1
          ? (descriptor.width * scale).round().clamp(10, 512)
          : descriptor.width,
      targetHeight: scale < 1
          ? (descriptor.height * scale).round().clamp(10, 512)
          : descriptor.height,
    );
    image = (await codec.getNextFrame()).image;
    final png = await image.toByteData(format: ui.ImageByteFormat.png);
    if (png == null) throw const FormatException('Unsupported image');
    return png.buffer.asUint8List(png.offsetInBytes, png.lengthInBytes);
  } finally {
    image?.dispose();
    codec?.dispose();
    descriptor?.dispose();
    buffer.dispose();
  }
}

class UploadAvatarPage extends StatefulWidget {
  final Discuz discuz;
  final User user;
  final Future<Uint8List?> Function()? pickImage;
  final Future<ForumInteractionClient> Function()? createClient;
  const UploadAvatarPage({
    super.key,
    required this.discuz,
    required this.user,
    this.pickImage,
    this.createClient,
  });
  @override
  State<UploadAvatarPage> createState() => _UploadAvatarPageState();
}

class _UploadAvatarPageState extends State<UploadAvatarPage> {
  Uint8List? preview;
  bool busy = false;
  String? error;
  bool get sameAccount {
    final state = context.read<DiscuzAndUserNotifier>();
    return state.discuz?.baseURL == widget.discuz.baseURL &&
        state.user == widget.user &&
        state.user?.auth == widget.user.auth;
  }

  Future<void> pick() async {
    if (busy || !sameAccount) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      Uint8List? bytes;
      if (widget.pickImage != null) {
        bytes = await widget.pickImage!();
      } else {
        final file = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 90,
        );
        if (file != null) bytes = await file.readAsBytes();
      }
      if (bytes == null) return;
      final image = await prepareAvatar(bytes);
      if (mounted && sameAccount) setState(() => preview = image);
    } catch (_) {
      if (mounted) setState(() => error = S.of(context).avatarImageInvalid);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> upload() async {
    if (busy || preview == null || !sameAccount) return;
    setState(() {
      busy = true;
      error = null;
    });
    bool submitted = false;
    try {
      final client = widget.createClient != null
          ? await widget.createClient!()
          : ForumInteractionClient(
              await NetworkUtils.getDioWithPersistCookieJar(widget.user),
              widget.discuz.baseURL,
            );
      if (!mounted || !sameAccount) return;
      // A current profile response supplies a fresh CSRF token after preview.
      final current = await client.request('profile', {'uid': widget.user.uid});
      current.requireData('formhash');
      final hash = current.variables['formhash'];
      if (hash is! String ||
          hash.isEmpty ||
          '${current.variables['member_uid']}' != '${widget.user.uid}') {
        throw const ForumApiException('account_changed', '');
      }
      if (!mounted || !sameAccount) return;
      submitted = true;
      await client.uploadAvatar(preview!, hash);
      if (mounted && sameAccount) Navigator.pop(context, true);
    } catch (e) {
      if (mounted)
        setState(
          () => error = e is ForumApiException
              ? '${S.of(context).avatarUploadFailed} (${e.code})'
              : submitted
              ? S.of(context).forumSubmissionUnknown
              : S.of(context).forumLoadFailed,
        );
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    context.watch<DiscuzAndUserNotifier>();
    final s = S.of(context);
    return PlatformScaffold(
      appBar: PlatformAppBar(title: Text(s.changeAvatar)),
      body: !sameAccount
          ? Center(child: Text(s.forumAccountChanged))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  if (preview != null)
                    Image.memory(
                      preview!,
                      width: 200,
                      height: 200,
                      fit: BoxFit.contain,
                    ),
                  Text(s.avatarPreviewHint),
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(error!),
                    ),
                  PlatformTextButton(
                    onPressed: busy ? null : pick,
                    child: Text(s.chooseAvatar),
                  ),
                  PlatformTextButton(
                    onPressed: busy || preview == null ? null : upload,
                    child: Text(busy ? s.forumWorking : s.uploadAvatar),
                  ),
                ],
              ),
            ),
    );
  }
}
