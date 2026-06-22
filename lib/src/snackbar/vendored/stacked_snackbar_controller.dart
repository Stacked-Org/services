// This file is adapted from the `get` package (SnackbarController),
// Copyright (c) 2020 Jonny Borges, distributed under the MIT License
// (https://github.com/jonataslaw/getx/blob/master/LICENSE). It has been
// vendored into stacked_services to remove the runtime dependency on `get`.
// The overlay host now comes from [StackedService.navigatorKey] and a small
// internal queue replaces `GetQueue`.

import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:stacked_services/src/stacked_service.dart';

import '../stacked_snackbar_customizations.dart';
import 'stacked_snackbar.dart';

class StackedSnackbarController {
  static final _snackBarQueue = _SnackBarQueue();
  static bool get isSnackbarBeingShown => _snackBarQueue._isJobInProgress;
  final key = GlobalKey<StackedSnackbarState>();

  late Animation<double> _filterBlurAnimation;
  late Animation<Color?> _filterColorAnimation;

  final StackedSnackbar snackbar;
  final _transitionCompleter = Completer();

  late SnackbarStatusCallback? _snackbarStatus;
  late final Alignment? _initialAlignment;
  late final Alignment? _endAlignment;

  bool _wasDismissedBySwipe = false;

  bool _onTappedDismiss = false;

  Timer? _timer;

  late final Animation<Alignment> _animation;

  late final AnimationController _controller;

  SnackbarStatus? _currentStatus;

  final _overlayEntries = <OverlayEntry>[];

  OverlayState? _overlayState;

  StackedSnackbarController(this.snackbar);

  Future<void> get future => _transitionCompleter.future;

  /// Close the snackbar with animation
  Future<void> close({bool withAnimations = true}) async {
    if (!withAnimations) {
      _removeOverlay();
      return;
    }
    _removeEntry();
    await future;
  }

  /// Adds Snackbar to a view queue.
  /// Only one Snackbar will be displayed at a time, and this method returns
  /// a future to when the snackbar disappears.
  Future<void> show() {
    return _snackBarQueue._addJob(this);
  }

  void _cancelTimer() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
  }

  void _configureAlignment(SnackPosition snackPosition) {
    switch (snackbar.snackPosition) {
      case SnackPosition.TOP:
        {
          _initialAlignment = const Alignment(-1.0, -2.0);
          _endAlignment = const Alignment(-1.0, -1.0);
          break;
        }
      case SnackPosition.BOTTOM:
        {
          _initialAlignment = const Alignment(-1.0, 2.0);
          _endAlignment = const Alignment(-1.0, 1.0);
          break;
        }
    }
  }

  void _configureOverlay() {
    _overlayState = StackedService.navigatorKey!.currentState!.overlay;
    _overlayEntries.clear();
    _overlayEntries.addAll(_createOverlayEntries(_getBodyWidget()));
    _overlayState!.insertAll(_overlayEntries);
    _configureSnackBarDisplay();
  }

  void _configureSnackBarDisplay() {
    assert(!_transitionCompleter.isCompleted,
        'Cannot configure a snackbar after disposing it.');
    _controller = _createAnimationController();
    _configureAlignment(snackbar.snackPosition);
    _snackbarStatus = snackbar.snackbarStatus;
    _filterBlurAnimation = _createBlurFilterAnimation();
    _filterColorAnimation = _createColorOverlayColor();
    _animation = _createAnimation();
    _animation.addStatusListener(_handleStatusChanged);
    _configureTimer();
    _controller.forward();
  }

  void _configureTimer() {
    if (snackbar.duration != null) {
      if (_timer != null && _timer!.isActive) {
        _timer!.cancel();
      }
      _timer = Timer(snackbar.duration!, _removeEntry);
    } else {
      if (_timer != null) {
        _timer!.cancel();
      }
    }
  }

  Animation<Alignment> _createAnimation() {
    assert(!_transitionCompleter.isCompleted,
        'Cannot create a animation from a disposed snackbar');
    return AlignmentTween(begin: _initialAlignment, end: _endAlignment).animate(
      CurvedAnimation(
        parent: _controller,
        curve: snackbar.forwardAnimationCurve,
        reverseCurve: snackbar.reverseAnimationCurve,
      ),
    );
  }

  AnimationController _createAnimationController() {
    assert(!_transitionCompleter.isCompleted,
        'Cannot create a animationController from a disposed snackbar');
    assert(snackbar.animationDuration >= Duration.zero);
    return AnimationController(
      duration: snackbar.animationDuration,
      debugLabel: '$runtimeType',
      vsync: _overlayState!,
    );
  }

  Animation<double> _createBlurFilterAnimation() {
    return Tween(begin: 0.0, end: snackbar.overlayBlur).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.35,
          curve: Curves.easeInOutCirc,
        ),
      ),
    );
  }

  Animation<Color?> _createColorOverlayColor() {
    return ColorTween(
            begin: const Color(0x00000000), end: snackbar.overlayColor)
        .animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.35,
          curve: Curves.easeInOutCirc,
        ),
      ),
    );
  }

  Iterable<OverlayEntry> _createOverlayEntries(Widget child) {
    return <OverlayEntry>[
      if (snackbar.overlayBlur > 0.0) ...[
        OverlayEntry(
          builder: (context) => GestureDetector(
            onTap: () {
              if (snackbar.isDismissible && !_onTappedDismiss) {
                _onTappedDismiss = true;
                close();
              }
            },
            child: AnimatedBuilder(
              animation: _filterBlurAnimation,
              builder: (context, child) {
                return BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: max(0.001, _filterBlurAnimation.value),
                    sigmaY: max(0.001, _filterBlurAnimation.value),
                  ),
                  child: Container(
                    constraints: const BoxConstraints.expand(),
                    color: _filterColorAnimation.value,
                  ),
                );
              },
            ),
          ),
          maintainState: false,
          opaque: false,
        ),
      ],
      OverlayEntry(
        builder: (context) => Semantics(
          focused: false,
          container: true,
          explicitChildNodes: true,
          child: AlignTransition(
            alignment: _animation,
            child: snackbar.isDismissible
                ? _getDismissibleSnack(child)
                : _getSnackbarContainer(child),
          ),
        ),
        maintainState: false,
        opaque: false,
      ),
    ];
  }

  Widget _getBodyWidget() {
    return Builder(builder: (_) {
      return GestureDetector(
        onTap: snackbar.onTap != null
            ? () => snackbar.onTap?.call(snackbar)
            : null,
        child: snackbar,
      );
    });
  }

  DismissDirection _getDefaultDismissDirection() {
    if (snackbar.snackPosition == SnackPosition.TOP) {
      return DismissDirection.up;
    }
    return DismissDirection.down;
  }

  Widget _getDismissibleSnack(Widget child) {
    return Dismissible(
      direction: snackbar.dismissDirection ?? _getDefaultDismissDirection(),
      resizeDuration: null,
      confirmDismiss: (_) {
        if (_currentStatus == SnackbarStatus.OPENING ||
            _currentStatus == SnackbarStatus.CLOSING) {
          return Future.value(false);
        }
        return Future.value(true);
      },
      key: const Key('dismissible'),
      onDismissed: (_) {
        _wasDismissedBySwipe = true;
        _removeEntry();
      },
      child: _getSnackbarContainer(child),
    );
  }

  Widget _getSnackbarContainer(Widget child) {
    return Container(
      margin: snackbar.margin,
      child: child,
    );
  }

  void _handleStatusChanged(AnimationStatus status) {
    switch (status) {
      case AnimationStatus.completed:
        _currentStatus = SnackbarStatus.OPEN;
        _snackbarStatus?.call(_currentStatus);
        if (_overlayEntries.isNotEmpty) _overlayEntries.first.opaque = false;

        break;
      case AnimationStatus.forward:
        _currentStatus = SnackbarStatus.OPENING;
        _snackbarStatus?.call(_currentStatus);
        break;
      case AnimationStatus.reverse:
        _currentStatus = SnackbarStatus.CLOSING;
        _snackbarStatus?.call(_currentStatus);
        if (_overlayEntries.isNotEmpty) _overlayEntries.first.opaque = false;
        break;
      case AnimationStatus.dismissed:
        assert(!_overlayEntries.first.opaque);
        _currentStatus = SnackbarStatus.CLOSED;
        _snackbarStatus?.call(_currentStatus);
        _removeOverlay();
        break;
    }
  }

  void _removeEntry() {
    assert(
      !_transitionCompleter.isCompleted,
      'Cannot remove entry from a disposed snackbar',
    );

    _cancelTimer();

    if (_wasDismissedBySwipe) {
      Timer(const Duration(milliseconds: 200), _controller.reset);
      _wasDismissedBySwipe = false;
    } else {
      _controller.reverse();
    }
  }

  void _removeOverlay() {
    for (var element in _overlayEntries) {
      element.remove();
    }

    assert(!_transitionCompleter.isCompleted,
        'Cannot remove overlay from a disposed snackbar');
    _controller.dispose();
    _overlayEntries.clear();
    _transitionCompleter.complete();
  }

  Future<void> _show() {
    _configureOverlay();
    return future;
  }

  static void cancelAllSnackbars() {
    _snackBarQueue._cancelAllJobs();
  }

  static Future<void> closeCurrentSnackbar() async {
    await _snackBarQueue._closeCurrentJob();
  }
}

class _SnackBarQueue {
  final _queue = _Queue();
  final _snackbarList = <StackedSnackbarController>[];

  StackedSnackbarController? get _currentSnackbar {
    if (_snackbarList.isEmpty) return null;
    return _snackbarList.first;
  }

  bool get _isJobInProgress => _snackbarList.isNotEmpty;

  Future<void> _addJob(StackedSnackbarController job) async {
    _snackbarList.add(job);
    final data = await _queue.add(job._show);
    _snackbarList.remove(job);
    return data;
  }

  Future<void> _cancelAllJobs() async {
    await _currentSnackbar?.close();
    _queue.cancelAllJobs();
    _snackbarList.clear();
  }

  Future<void> _closeCurrentJob() async {
    if (_currentSnackbar == null) return;
    await _currentSnackbar!.close();
  }
}

/// Minimal serial job queue, vendored from `get`'s GetQueue.
class _Queue {
  final List<_Item> _queue = [];
  bool _active = false;

  Future<T> add<T>(Function job) {
    var completer = Completer<T>();
    _queue.add(_Item(completer, job));
    _check();
    return completer.future;
  }

  void cancelAllJobs() {
    _queue.clear();
  }

  void _check() async {
    if (!_active && _queue.isNotEmpty) {
      _active = true;
      var item = _queue.removeAt(0);
      try {
        item.completer.complete(await item.job());
      } on Exception catch (e) {
        item.completer.completeError(e);
      }
      _active = false;
      _check();
    }
  }
}

class _Item {
  final dynamic completer;
  final dynamic job;

  _Item(this.completer, this.job);
}
