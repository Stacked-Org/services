import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stacked_shared/stacked_shared.dart' as sc;
import 'package:stacked_services/src/exceptions/custom_snackbar_exception.dart';
import 'package:stacked_services/src/snackbar/snackbar_config.dart';

import 'stacked_snackbar_customizations.dart';

/// A service that allows the user to show the snackbar from a ViewModel
class SnackbarService {
  Map<dynamic, SnackbarConfig?> _customSnackbarConfigs =
      Map<dynamic, SnackbarConfig?>();

  Map<dynamic, SnackbarConfig Function()?> _customSnackbarConfigBuilders =
      Map<dynamic, SnackbarConfig Function()?>();

  Map<dynamic, Widget Function(String?, Function?)?> _mainButtonBuilder =
      Map<dynamic, Widget Function(String?, Function?)?>();

  SnackbarConfig? _snackbarConfig;
  SnackbarConfig? _snackbarConfigLight;
  SnackbarConfig? _snackbarConfigDark;

  /// Checks if there is a snackbar open
  bool? get isOpen => Get.isSnackbarOpen;

  /// Saves the [snackbarConfig] or [snackbarConfigLight] and [snackbarConfigDark] to be used for the [showSnackbar] function.
  /// Use either snackbarConfig or both snackbarConfigLight and snackbarConfigDark.
  void registerSnackbarConfig({
    SnackbarConfig? snackbarConfig,
    SnackbarConfig? snackbarConfigLight,
    SnackbarConfig? snackbarConfigDark,
  }) {
    assert(
      (snackbarConfig != null)
          ? (snackbarConfigLight == null && snackbarConfigDark == null)
          : (snackbarConfigLight != null && snackbarConfigDark != null),
      'You have to supply either snackbarConfig or both snackbarConfigLight and snackbarConfigDark.',
    );

    _snackbarConfig = snackbarConfig;
    _snackbarConfigLight = snackbarConfigLight;
    _snackbarConfigDark = snackbarConfigDark;
  }

  /// Registers a builder that will be used when showing a matching variant value. The builder
  /// function takes in a [String] to display as the title and a `Function` to be used to the
  /// onTap callback
  void registerCustomMainButtonBuilder({
    @required dynamic variant,
    @required Widget Function(String?, Function?)? builder,
  }) =>
      _mainButtonBuilder[variant] = builder;

  /// Saves the [config] against the value of [variant]. A [configBuilder] can also be
  /// supplied which will be chosen over the config for the same variant when requested.
  void registerCustomSnackbarConfig({
    required dynamic variant,
    SnackbarConfig? config,
    SnackbarConfig Function()? configBuilder,
  }) {
    _customSnackbarConfigs[variant] = config;
    _customSnackbarConfigBuilders[variant] = configBuilder;
  }

  /// Check if snackbar is open
  bool get isSnackbarOpen => Get.isSnackbarOpen;

  /// Shows a snack bar with the details passed in
  void showSnackbar({
    String title = '',
    required String message,
    Function(dynamic)? onTap,
    Duration? duration,
    String? mainButtonTitle,
    void Function()? onMainButtonTapped,
  }) {
    final currentSnackbarConfig = _snackbarConfig ??
        (Get.isDarkMode ? _snackbarConfigDark : _snackbarConfigLight);

    final mainButtonWidget = _getMainButtonWidget(
      mainButtonTitle: mainButtonTitle,
      onMainButtonTapped: onMainButtonTapped,
      config: currentSnackbarConfig,
    );

    Get.snackbar(
      title,
      message,
      titleText: title.isNotEmpty
          ? Text(
              title,
              key: Key('snackbar_text_title'),
              style: TextStyle(
                color: currentSnackbarConfig?.titleColor ??
                    currentSnackbarConfig?.textColor ??
                    Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
              textAlign:
                  currentSnackbarConfig?.titleTextAlign ?? TextAlign.left,
            )
          : SizedBox.shrink(),
      messageText: message.isNotEmpty
          ? Text(
              message,
              key: Key('snackbar_text_message'),
              style: TextStyle(
                color: currentSnackbarConfig?.messageColor ??
                    currentSnackbarConfig?.textColor ??
                    Colors.white,
                fontWeight: FontWeight.w300,
                fontSize: 14,
              ),
              textAlign:
                  currentSnackbarConfig?.messageTextAlign ?? TextAlign.left,
            )
          : SizedBox.shrink(),
      shouldIconPulse: currentSnackbarConfig?.shouldIconPulse,
      onTap: onTap,
      barBlur: currentSnackbarConfig?.barBlur,
      isDismissible: currentSnackbarConfig?.isDismissible ?? true,
      duration: duration ?? currentSnackbarConfig?.duration,
      snackPosition: currentSnackbarConfig?.snackPosition.toGet,
      backgroundColor:
          currentSnackbarConfig?.backgroundColor ?? Colors.grey[800],
      margin: currentSnackbarConfig?.margin ??
          const EdgeInsets.symmetric(horizontal: 10, vertical: 25),
      mainButton: mainButtonWidget,
      icon: currentSnackbarConfig?.icon,
      maxWidth: currentSnackbarConfig?.maxWidth,
      padding: currentSnackbarConfig?.padding,
      borderRadius: currentSnackbarConfig?.borderRadius,
      borderColor: currentSnackbarConfig?.borderColor,
      borderWidth: currentSnackbarConfig?.borderWidth,
      leftBarIndicatorColor: currentSnackbarConfig?.leftBarIndicatorColor,
      boxShadows: currentSnackbarConfig?.boxShadows,
      backgroundGradient: currentSnackbarConfig?.backgroundGradient,
      dismissDirection: currentSnackbarConfig?.dismissDirection,
      showProgressIndicator: currentSnackbarConfig?.showProgressIndicator,
      progressIndicatorController:
          currentSnackbarConfig?.progressIndicatorController,
      progressIndicatorBackgroundColor:
          currentSnackbarConfig?.progressIndicatorBackgroundColor,
      progressIndicatorValueColor:
          currentSnackbarConfig?.progressIndicatorValueColor,
      snackStyle: currentSnackbarConfig?.snackStyle.toGet,
      forwardAnimationCurve: currentSnackbarConfig?.forwardAnimationCurve,
      reverseAnimationCurve: currentSnackbarConfig?.reverseAnimationCurve,
      animationDuration: currentSnackbarConfig?.animationDuration,
      overlayBlur: currentSnackbarConfig?.overlayBlur,
      overlayColor: currentSnackbarConfig?.overlayColor,
      userInputForm: currentSnackbarConfig?.userInputForm,
    );
  }

  Future? showCustomSnackBar({
    required String message,
    TextStyle? messageTextStyle,
    required dynamic variant,
    String? title,
    TextStyle? titleTextStyle,
    String? mainButtonTitle,
    ButtonStyle? mainButtonStyle,
    void Function()? onMainButtonTapped,
    Function? onTap,
    Duration? duration,
  }) async {
    final snackbarConfigSupplied = _customSnackbarConfigs[variant];
    final snackbarConfigBuilder = _customSnackbarConfigBuilders[variant];

    final snackbarConfig = snackbarConfigBuilder != null
        ? snackbarConfigBuilder()
        : snackbarConfigSupplied;

    if (snackbarConfig == null) {
      throw CustomSnackbarException(
        'No config found for $variant make sure you have called registerCustomConfig with a config or a builder. See [https://pub.dev/packages/stacked_services#custom-styles] for implementation details.',
      );
    }

    final mainButtonBuilder = _mainButtonBuilder[variant];
    final hasMainButtonBuilder = mainButtonBuilder != null;

    final mainButtonWidget = hasMainButtonBuilder
        ? mainButtonBuilder(
            mainButtonTitle,
            () => _handleOnMainButtonTapped(
              onMainButtonTapped,
              snackbarConfig.closeSnackbarOnMainButtonTapped,
            ),
          )
        : _getMainButtonWidget(
            mainButtonTitle: mainButtonTitle,
            mainButtonStyle: snackbarConfig.mainButtonStyle ?? mainButtonStyle,
            onMainButtonTapped: onMainButtonTapped,
            config: snackbarConfig,
          );

    final getBar = GetSnackBar(
      key: Key('snackbar_view'),
      titleText: title != null
          ? Text(
              title,
              key: Key('snackbar_text_title'),
              style: snackbarConfig.titleTextStyle ??
                  titleTextStyle ??
                  TextStyle(
                    color:
                        snackbarConfig.titleColor ?? snackbarConfig.textColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
              textAlign: snackbarConfig.titleTextAlign,
            )
          : snackbarConfig.titleText ?? null,
      messageText: message.isNotEmpty
          ? Text(
              message,
              key: Key('snackbar_text_message'),
              style: snackbarConfig.messageTextStyle ??
                  messageTextStyle ??
                  TextStyle(
                    color:
                        snackbarConfig.messageColor ?? snackbarConfig.textColor,
                    fontWeight: FontWeight.w300,
                    fontSize: 14,
                  ),
              textAlign: snackbarConfig.messageTextAlign,
            )
          : SizedBox.shrink(),
      icon: snackbarConfig.icon,
      shouldIconPulse: snackbarConfig.shouldIconPulse,
      maxWidth: snackbarConfig.maxWidth,
      margin: snackbarConfig.margin ?? EdgeInsets.zero,
      padding: snackbarConfig.padding,
      borderRadius: snackbarConfig.borderRadius,
      borderColor: snackbarConfig.borderColor,
      borderWidth: snackbarConfig.borderWidth,
      backgroundColor: snackbarConfig.backgroundColor,
      leftBarIndicatorColor: snackbarConfig.leftBarIndicatorColor,
      boxShadows: snackbarConfig.boxShadows,
      backgroundGradient: snackbarConfig.backgroundGradient,
      mainButton: mainButtonWidget,
      onTap: (snackbar) => onTap?.call(),
      duration: duration ?? snackbarConfig.duration,
      isDismissible: snackbarConfig.isDismissible,
      dismissDirection: snackbarConfig.dismissDirection,
      showProgressIndicator: snackbarConfig.showProgressIndicator,
      progressIndicatorController: snackbarConfig.progressIndicatorController,
      progressIndicatorBackgroundColor:
          snackbarConfig.progressIndicatorBackgroundColor,
      progressIndicatorValueColor: snackbarConfig.progressIndicatorValueColor,
      snackPosition: snackbarConfig.snackPosition.toGet,
      snackStyle: snackbarConfig.snackStyle.toGet,
      forwardAnimationCurve: snackbarConfig.forwardAnimationCurve,
      reverseAnimationCurve: snackbarConfig.reverseAnimationCurve,
      animationDuration: snackbarConfig.animationDuration,
      barBlur: snackbarConfig.barBlur,
      overlayBlur: snackbarConfig.overlayBlur,
      overlayColor: snackbarConfig.overlayColor,
      userInputForm: snackbarConfig.userInputForm,
    );

    if (snackbarConfig.instantInit) {
      return getBar.show();
    } else {
      Completer completer = Completer();
      sc.ambiguate(WidgetsBinding.instance)!.addPostFrameCallback((_) async {
        final result = getBar.show();
        completer.complete(result);
      });
      return completer.future;
    }
  }

  /// Close the current snack bar
  Future<void> closeSnackbar() async {
    if (isSnackbarOpen) {
      return Get.closeCurrentSnackbar();
    }
  }

  TextButton? _getMainButtonWidget({
    String? mainButtonTitle,
    ButtonStyle? mainButtonStyle,
    void Function()? onMainButtonTapped,
    SnackbarConfig? config,
  }) {
    if (mainButtonTitle == null) {
      return null;
    }

    return TextButton(
      key: Key('snackbar_touchable_mainButton'),
      style: mainButtonStyle,
      child: Text(
        mainButtonTitle,
        key: Key('snackbar_text_mainButtonTitle'),
        style: TextStyle(
          color:
              config?.mainButtonTextColor ?? config?.textColor ?? Colors.white,
        ),
      ),
      onPressed: () => _handleOnMainButtonTapped(
        onMainButtonTapped,
        config?.closeSnackbarOnMainButtonTapped ?? false,
      ),
    );
  }

  void _handleOnMainButtonTapped(
    void Function()? onMainButtonTapped,
    bool closeSnackbarOnMainButtonTapped,
  ) {
    if (onMainButtonTapped != null) {
      onMainButtonTapped();
      if (closeSnackbarOnMainButtonTapped) {
        closeSnackbar();
      }
    }
  }
}
