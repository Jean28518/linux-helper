import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:linux_assistant/enums/desktops.dart';
import 'package:linux_assistant/enums/softwareManagers.dart';
import 'package:linux_assistant/layouts/after_installation/after_installation_entry.dart';
import 'package:linux_assistant/layouts/disk_cleaner/cleaner_select_disk.dart';
import 'package:linux_assistant/layouts/after_installation/activate_hotkey.dart';
import 'package:linux_assistant/layouts/greeter/introduction.dart';
import 'package:linux_assistant/layouts/linux_health/overview.dart';
import 'package:linux_assistant/layouts/power_mode/power_mode.dart';
import 'package:linux_assistant/layouts/run_command_queue.dart';
import 'package:linux_assistant/layouts/security_check/overview.dart';
import 'package:linux_assistant/layouts/shutdown/shutdown_dialog.dart';
import 'package:linux_assistant/layouts/uninstaller/uninstaller_question.dart';
import 'package:linux_assistant/models/action_entry.dart';
import 'package:linux_assistant/models/linux_command.dart';
import 'package:linux_assistant/services/config_handler.dart';
import 'package:linux_assistant/services/linux.dart';
import 'package:linux_assistant/services/main_search_loader.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ActionHandler {
  /// The callback is usually the clear function.
  static Future<void> handleActionEntry(ActionEntry actionEntry,
      VoidCallback callback, BuildContext context) async {
    if (actionEntry.action.isEmpty) {
      if (actionEntry.handlerFunction != null) {
        actionEntry.handlerFunction!(callback, context);
      }
      return;
    }

    print(actionEntry.action);

    // Save opened for intelligent search
    ConfigHandler configHandler = ConfigHandler();
    if (configHandler.getValueUnsafe("self_learning_search", true)) {
      String newDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
      String oldList =
          configHandler.getValueUnsafe("opened.${actionEntry.action}", "");
      configHandler.setValue(
          "opened.${actionEntry.action}", "$oldList$newDate;");
    }

    switch (actionEntry.action) {
      case "change_user_password":
        Linux.changeUserPasswordDialog();
        callback();
        break;
      case "open_systeminformation":
        Linux.openSystemInformation();
        callback();
        break;
      case "open_usersettings":
        Linux.openUserSettings();
        callback();
        break;
      case "open_introduction":
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const GreeterIntroduction(forceOpen: true)),
        );
        break;
      case "setup_linux_assistant_shortcut":
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ActivateHotkeyQuestion(
                    route: const MainSearchLoader(),
                  )),
        );
        break;
      case "send_files_via_warpinator":
        Linux.openOrInstallWarpinator(context, callback);
        break;
      case "hard_info":
        Linux.openOrInstallHardInfo(context, callback);
        break;
      case "redshift":
        Linux.openOrInstallRedshift(context, callback);
        break;
      case "shutdown":
        showDialog(context: context, builder: (context) => ShutdownDialog());
        break;
      case "exit":
        exit(0);
      case "power_mode":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PowerMode()),
        );
        break;
      case "security_check":
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const SecurityCheckOverview()),
        );
        break;
      case "linux_health":
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LinuxHealthOverview()),
        );
        break;
      case "disk_cleaner":
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const CleanerSelectDiskPage()),
        );
        break;
      case "after_installation":
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const AfterInstallationEntry()),
        );
        break;
      default:
    }

    if (actionEntry.action.startsWith("websearch:")) {
      Linux.openWebbrowserSeach(
          actionEntry.action.replaceFirst("websearch:", ""));
      callback();
    }

    if (actionEntry.action.startsWith("openwebsite:")) {
      Linux.openWebbrowserWithSite(
          actionEntry.action.replaceFirst("openwebsite:", ""));
      callback();
    }

    if (actionEntry.action.startsWith("openfolder:")) {
      Linux.runCommandWithCustomArguments(
          "xdg-open", [actionEntry.action.replaceFirst("openfolder:", "")]);
      callback();
    }

    if (actionEntry.action.startsWith("openfile:")) {
      String file = actionEntry.action.replaceFirst("openfile:", "");
      bool isExecutable = await Linux.isFileExecutable(file);
      if (isExecutable) {
        // TODO: Ask the user, if the file should be run (possible security risk).
        // TODO: Ask the user, if the file should be run in a terminal.

        // Run the file without terminal.
        //Linux.runCommand(file);

        // Run the file in a terminal (default for now).
        Linux.runExecutableInTerminal(file);
      } else {
        Linux.runCommandWithCustomArguments("xdg-open", [file]);
      }

      callback();
    }

    if (actionEntry.action == "update_system") {
      Linux.updateAllPackages();
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => RunCommandQueue(
              title: AppLocalizations.of(context)!.update,
              message: AppLocalizations.of(context)!.updateSystemDescription,
              offerShutdownAfterwards: true,
              route: const MainSearchLoader())));
    }

    if (actionEntry.action == "install_multimedia_codecs") {
      Linux.installMultimediaCodecs();
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => RunCommandQueue(
              title: AppLocalizations.of(context)!.installMultimediaCodecs,
              message: AppLocalizations.of(context)!
                  .installMultimediaCodecsDescription,
              route: const MainSearchLoader())));
    }

    if (actionEntry.action == "enable_automatic_updates") {
      await Linux.enableAutomaticUpdates();
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => RunCommandQueue(
              title: AppLocalizations.of(context)!
                  .automaticUpdateManagerConfiguration,
              message: AppLocalizations.of(context)!
                  .automaticUpdateManagerConfigurationDescription,
              route: const MainSearchLoader())));
    }

    if (actionEntry.action == "enable_automatic_snapshots") {
      await Linux.enableAutomaticSnapshots();
      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => RunCommandQueue(
              title: AppLocalizations.of(context)!
                  .automaticUpdateManagerConfiguration,
              message: AppLocalizations.of(context)!
                  .automaticUpdateManagerConfigurationDescription,
              route: const MainSearchLoader())));
    }

    if (actionEntry.action.startsWith("apt-install:")) {
      String pkg = actionEntry.action.replaceFirst("apt-install:", "");
      await Linux.installApplications([pkg],
          preferredSoftwareManager: SOFTWARE_MANAGERS.APT);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RunCommandQueue(
                  title: "APT",
                  message: "Your package will be installed in a few moments...",
                  route: MainSearchLoader(),
                )),
      );
    }

    if (actionEntry.action.startsWith("apt-uninstall:")) {
      String pkg = actionEntry.action.replaceFirst("apt-uninstall:", "");
      await Linux.removeApplications([pkg],
          softwareManager: SOFTWARE_MANAGERS.APT);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                UninstallerQuestion(action: actionEntry.action),
          ));
    }

    if (actionEntry.action.startsWith("zypper-install:")) {
      String pkg = actionEntry.action.replaceFirst("zypper-install:", "");
      Linux.commandQueue.add(LinuxCommand(
          userId: 0,
          command:
              "${Linux.getExecutablePathOfSoftwareManager(SOFTWARE_MANAGERS.ZYPPER)} --non-interactive install $pkg"));
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RunCommandQueue(
                  title: "Zypper",
                  message: "Your package will be installed in a few moments...",
                  route: MainSearchLoader(),
                )),
      );
    }

    if (actionEntry.action.startsWith("zypper-uninstall:")) {
      String pkg = actionEntry.action.replaceFirst("zypper-uninstall:", "");
      await Linux.removeApplications([pkg],
          softwareManager: SOFTWARE_MANAGERS.ZYPPER);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                UninstallerQuestion(action: actionEntry.action),
          ));
    }

    if (actionEntry.action.startsWith("dnf-install:")) {
      String pkg = actionEntry.action.replaceFirst("dnf-install:", "");
      Linux.commandQueue.add(LinuxCommand(
          userId: 0,
          command:
              "${Linux.getExecutablePathOfSoftwareManager(SOFTWARE_MANAGERS.DNF)} install $pkg -y"));
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RunCommandQueue(
                  title: "DNF",
                  message: "Your package will be installed in a few moments...",
                  route: MainSearchLoader(),
                )),
      );
    }

    if (actionEntry.action.startsWith("dnf-uninstall:")) {
      String pkg = actionEntry.action.replaceFirst("dnf-uninstall:", "");
      await Linux.removeApplications([pkg],
          softwareManager: SOFTWARE_MANAGERS.DNF);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                UninstallerQuestion(action: actionEntry.action),
          ));
    }

    if (actionEntry.action.startsWith("pacman-install:")) {
      String pkg = actionEntry.action.replaceFirst("pacman-install:", "");
      Linux.commandQueue.add(LinuxCommand(
          userId: 0,
          command:
              "${Linux.getExecutablePathOfSoftwareManager(SOFTWARE_MANAGERS.PACMAN)} -S --needed --noconfirm $pkg"));
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RunCommandQueue(
                  title: "Pacman",
                  message: AppLocalizations.of(context)!.packageWillBeInstalled,
                  route: const MainSearchLoader(),
                )),
      );
    }

    if (actionEntry.action.startsWith("pacman-uninstall:")) {
      String pkg = actionEntry.action.replaceFirst("pacman-uninstall:", "");
      Linux.commandQueue.add(LinuxCommand(
          userId: 0,
          command:
              "${Linux.getExecutablePathOfSoftwareManager(SOFTWARE_MANAGERS.PACMAN)} -Rs --noconfirm $pkg"));
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                UninstallerQuestion(action: actionEntry.action),
          ));
    }

    if (actionEntry.action.startsWith("flatpak-install:")) {
      String pkg = actionEntry.action.replaceFirst("flatpak-install:", "");
      Linux.commandQueue.add(LinuxCommand(
          userId: 0,
          command:
              "${Linux.getExecutablePathOfSoftwareManager(SOFTWARE_MANAGERS.FLATPAK)} install $pkg -y --noninteractive"));
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RunCommandQueue(
                  title: "Flatpak",
                  message: AppLocalizations.of(context)!.packageWillBeInstalled,
                  route: const MainSearchLoader(),
                )),
      );
    }

    if (actionEntry.action.startsWith("flatpak-uninstall:")) {
      String pkg = actionEntry.action.replaceFirst("flatpak-uninstall:", "");
      await Linux.removeApplications([pkg],
          softwareManager: SOFTWARE_MANAGERS.FLATPAK);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RunCommandQueue(
                  title: actionEntry.name,
                  message: AppLocalizations.of(context)!
                      .uninstallingXDescription(pkg),
                  route: const MainSearchLoader(),
                )),
      );
    }

    if (actionEntry.action.startsWith("snap-install:")) {
      String pkg = actionEntry.action.replaceFirst("snap-install:", "");
      Linux.commandQueue.add(LinuxCommand(
        userId: 0,
        command:
            "${Linux.getExecutablePathOfSoftwareManager(SOFTWARE_MANAGERS.SNAP)} install $pkg",
        environment: {"DEBIAN_FRONTEND": "noninteractive"},
      ));
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RunCommandQueue(
                  title: "Snap",
                  message: AppLocalizations.of(context)!.packageWillBeInstalled,
                  route: const MainSearchLoader(),
                )),
      );
    }

    if (actionEntry.action.startsWith("snap-uninstall:")) {
      String pkg = actionEntry.action.replaceFirst("snap-uninstall:", "");
      await Linux.removeApplications([pkg],
          softwareManager: SOFTWARE_MANAGERS.SNAP);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => RunCommandQueue(
                  title: actionEntry.name,
                  message: AppLocalizations.of(context)!
                      .uninstallingXDescription(pkg),
                  route: const MainSearchLoader(),
                )),
      );
    }

    if (actionEntry.action.startsWith("openapp:")) {
      if (Linux.currentenvironment.desktop == DESKTOPS.KDE) {
        Linux.runCommandWithCustomArguments("kioclient",
            ["exec", actionEntry.action.replaceFirst("openapp:", "")]);
      } else {
        String filepath = actionEntry.action.replaceFirst("openapp:", "");
        String file = filepath.split("/").last;
        Linux.runCommandWithCustomArguments("/usr/bin/gtk-launch", [file]);
      }

      callback();
    }

    if (actionEntry.action.startsWith("just_callback")) {
      callback();
    }

    if (actionEntry.action.startsWith("fix_package_manager")) {
      Linux.fixPackageManager(context);
    }

    if (actionEntry.action.startsWith("bash:")) {
      String command = actionEntry.action.replaceFirst("bash:", "");
      Linux.openCommandInTerminal(command);
      callback();
    }

    if (actionEntry.action.startsWith("setup_snap")) {
      Linux.setupSnapAndSnapStore(context);
    }

    if (actionEntry.action.startsWith("make_administrator")) {
      Linux.makeCurrentUserToAdministrator(context);
    }

    if (actionEntry.action.startsWith("open_software_center")) {
      Linux.openSoftwareCenter(context);
      callback();
    }
  }
}
