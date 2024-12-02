import "dart:convert";
import "dart:developer";
import "dart:io" show Platform;

import "package:device_info_plus/device_info_plus.dart";
import "package:discuz_flutter/entity/Smiley.dart";
import "package:flutter/widgets.dart";
import "package:ios_utsname_ext/extension.dart";

import "../generated/l10n.dart";

class PostTextFieldUtils {
  static String getPostMessage(String message) {
    // filter smiley tag first [smiley].*?[/smiley]
    //String replaceRegexString = SmileyText.smileyStartFlag.replaceAll("", replace)+"(.*?)"+SmileyText.smileyEndFlag;
    RegExp replaceRegex =
        RegExp(r"\[smiley\](.*?)\[/smiley\]", multiLine: true);
    if (replaceRegex.hasMatch(message)) {
      // contain
      log("contains regex ${message}");
      String replacementString = message;
      for (var matchCase in replaceRegex.allMatches(message)) {
        if (matchCase.groupCount == 1) {
          String actualString = matchCase.group(0)!;
          String smileyJsonString = matchCase.group(1)!;
          // parse json to obj
          Smiley smiley = Smiley.fromJson(jsonDecode(smileyJsonString));
          String smileyCode =
              smiley.code.replaceAll(r"\", "").replaceAll("/", "");
          replacementString =
              replacementString.replaceAll(actualString, smileyCode);
        }
      }
      message = replacementString;
    }
    return message;
  }

  static List<String> getAttachmentAidList(String message) {
    List<String> aidList = [];
    RegExp replaceRegex =
        RegExp(r"\[attachimg\](\d*?)\[/attachimg\]", multiLine: true);
    if (replaceRegex.hasMatch(message)) {
      // contain
      log("contains attach aid regex ${message}");
      for (var matchCase in replaceRegex.allMatches(message)) {
        log("Match Case -> ${matchCase}");
        if (matchCase.groupCount == 1) {
          //String actualString = matchCase.group(0)!;
          String aid = matchCase.group(1)!;
          log("Obtain aid -> ${aid}");
          aidList.add(aid);
        }
      }
    }
    return aidList;
  }

  static Future<String> getDeviceName(BuildContext context) async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.model;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.utsname.machine.iOSProductName;
    } else if (Platform.isWindows) {
      WindowsDeviceInfo windowsDeviceInfo = await deviceInfo.windowsInfo;
      return S.of(context).windowsDeviceName(windowsDeviceInfo.computerName);
    } else if (Platform.isLinux) {
      LinuxDeviceInfo linuxDeviceInfo = await deviceInfo.linuxInfo;
      return S.of(context).linuxDeviceName(linuxDeviceInfo.name);
    } else if (Platform.isMacOS) {
      MacOsDeviceInfo macOsDeviceInfo = await deviceInfo.macOsInfo;
      return macOsDeviceInfo.model;
    }
    WebBrowserInfo webBrowserInfo = await deviceInfo.webBrowserInfo;

    return webBrowserInfo.userAgent == null ? "" : webBrowserInfo.userAgent!;
  }

  static const String USE_DEVICE_SIGNATURE = "USE_DEVICE_SIGNATURE";
  static const String USE_APP_SIGNATURE = "USE_APP_SIGNATURE";
  static const String NO_SIGNATURE = "";

  static const String EXAMPLE_HTML_LONG_DATA = r"""
<p id="top"><a href="#bottom">Scroll to bottom</a></p>
      <h1>Header 1</h1>
      <h2>Header 2</h2>
      <h3>Header 3</h3>
      <h4>Header 4</h4>
      <h5>Header 5</h5>
      <h6>Header 6</h6>
      
      <h2>Inline Styles:</h2>
      <p>The should be <span style="color: blue;">BLUE style="color: blue;"</span></p>
      <p>The should be <span style="color: red;">RED style="color: red;"</span></p>
      <p>The should be <span style="color: rgba(0, 0, 0, 0.10);">BLACK with 10% alpha style="color: rgba(0, 0, 0, 0.10);</span></p>
      <p>The should be <span style="color: rgb(0, 97, 0);">GREEN style="color: rgb(0, 97, 0);</span></p>
      <p>The should be <span style="background-color: red; color: rgb(0, 97, 0);">GREEN style="color: rgb(0, 97, 0);</span></p>
      
      <h2>Text Alignment</h2>
      <p style="text-align: center;"><span style="color: rgba(0, 0, 0, 0.95);">Center Aligned Text</span></p>
      <p style="text-align: right;"><span style="color: rgba(0, 0, 0, 0.95);">Right Aligned Text</span></p>
      <p style="text-align: justify;"><span style="color: rgba(0, 0, 0, 0.95);">Justified Text</span></p>
      <p style="text-align: center;"><span style="color: rgba(0, 0, 0, 0.95);">Center Aligned Text</span></p>
      
     
      
      <h2>Support for <code>sub</code>/<code>sup</code></h2>
      Solve for <var>x<sub>n</sub></var>: log<sub>2</sub>(<var>x</var><sup>2</sup>+<var>n</var>) = 9<sup>3</sup>
      <p>One of the most <span>common</span> equations in all of physics is <br /><var>E</var>=<var>m</var><var>c</var><sup>2</sup>.</p>
      
      <h2>Ruby Support:</h2>
      <p>
        <ruby>
          漢<rt>かん</rt>
          字<rt>じ</rt>
        </ruby>
        &nbsp;is Japanese Kanji.
      </p>
      
      <h2>Link support:</h2>
      <p>
        Linking to <a href="https://github.com">websites</a> has never been easier.
      </p>
      
      <h2 id="middle">SVG support:</h2>
      <svg id="svg1" viewBox="0 0 100 100" xmlns="http://www.w3.org/2000/svg">
            <circle r="32" cx="35" cy="65" fill="#F00" opacity="0.5"/>
            <circle r="32" cx="65" cy="65" fill="#0F0" opacity="0.5"/>
            <circle r="32" cx="50" cy="35" fill="#00F" opacity="0.5"/>
      </svg>
      
      <p id="bottom"><a href="#top">Scroll to top</a></p>
""";
}
