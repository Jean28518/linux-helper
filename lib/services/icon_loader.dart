import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';
import 'package:linux_helper/services/linux.dart';

class IconLoader {
  // handle IconLoader as a singleton
  static final IconLoader _instance = IconLoader._privateConstructor();
  factory IconLoader() {
    return _instance;
  }
  IconLoader._privateConstructor();

  Map cache = {};

  Future<Image> getIconForApp(appCode, {double iconSize = 48}) async {
    String cacheKeyword = "$appCode-$iconSize";
    if (cache.containsKey(cacheKeyword)) {
      return cache[cacheKeyword];
    }
    String iconPath = await Linux.runCommandWithCustomArgumentsAndGetStdOut(
        "/usr/bin/python3", [
      "${Linux.executableFolder}python/get_icon_path.py",
      "--icon=$appCode"
    ]);

    if (iconPath.contains("not found")) {
      if (cache.containsKey("!default!")) {
        cache[cacheKeyword] = cache['!default!'];
      } else {
        String defaultIconPath =
            await Linux.runCommandWithCustomArgumentsAndGetStdOut(
                "/usr/bin/python3", [
          "${Linux.executableFolder}python/get_icon_path.py",
          "--icon=applications-system"
        ]);
        Image image = Image.file(File(defaultIconPath.replaceAll("\n", "")));

        cache['!default!'] = image;
        cache[cacheKeyword] = image;
      }
      return cache[cacheKeyword];
    }

    File file = await File(iconPath.replaceAll("\n", ""));
    if (iconPath.contains(".svg")) {
      Image image = Image(
          width: iconSize,
          height: iconSize,
          image: Svg(iconPath.replaceAll("\n", "")));
      cache[cacheKeyword] = image;
      return image;
    } else {
      Image image = Image.file(
        file,
        height: iconSize,
        width: iconSize,
      );
      cache[cacheKeyword] = image;
      return image;
    }
  }

  bool isIconLoaded(appCode, {double iconSize = 48}) {
    String cacheKey = "$appCode-$iconSize";
    return (cache.containsKey(cacheKey));
  }

  Image getIconFromCache(appCode, {double iconSize = 48}) {
    String cacheKey = "$appCode-$iconSize";
    return cache[cacheKey];
  }
}
