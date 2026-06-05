import 'package:flutter/material.dart';

class RulerValuePicker extends StatefulWidget {
  const RulerValuePicker({
    super.key,
    required this.min,
    required this.max,
    required this.value,
    required this.onChanged,
    this.labelBuilder,
    this.selectedLabelBuilder,
    this.itemWidth,
    this.pickerHeight = 132,
    this.selectedFontSize = 44,
  });

  final int min;
  final int max;
  final int value;
  final ValueChanged<int> onChanged;
  final String Function(int value)? labelBuilder;
  final String Function(int value)? selectedLabelBuilder;
  final double? itemWidth;
  final double pickerHeight;
  final double selectedFontSize;

  @override
  State<RulerValuePicker> createState() => _RulerValuePickerState();
}

class _RulerValuePickerState extends State<RulerValuePicker> {
  late final ScrollController _controller;
  bool _syncing = false;
  bool _snapping = false;
  double? _lastViewportWidth;

  static const _centerTickHeight = 28.0;

  @override
  void initState() {
    super.initState();
    _controller = ScrollController();
    _controller.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToValue(widget.value));
  }

  @override
  void didUpdateWidget(covariant RulerValuePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    final rangeChanged = oldWidget.min != widget.min || oldWidget.max != widget.max;
    final valueChanged = oldWidget.value != widget.value;
    if ((valueChanged || rangeChanged) && !_syncing && !_snapping) {
      _jumpToValue(widget.value);
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  double _itemWidthFor() {
    if (widget.itemWidth != null) return widget.itemWidth!;
    if (widget.labelBuilder != null) return 72;
    final digits = widget.max.toString().length;
    if (digits >= 3) return 56;
    if (digits == 2) return 48;
    return 40;
  }

  String _labelFor(int v, {required bool selected}) {
    if (selected && widget.selectedLabelBuilder != null) {
      return widget.selectedLabelBuilder!(v);
    }
    if (widget.labelBuilder != null) return widget.labelBuilder!(v);
    return '$v';
  }

  void _jumpToValue(int value) {
    if (!_controller.hasClients) return;
    _syncing = true;
    _controller.jumpTo(_offsetFor(value, _itemWidthFor()));
    _syncing = false;
  }

  double _offsetFor(int value, double itemWidth) =>
      (value - widget.min) * itemWidth;

  int _valueForOffset(double offset, double itemWidth) {
    final index = (offset / itemWidth).round();
    return (widget.min + index).clamp(widget.min, widget.max);
  }

  void _onScroll() {
    if (!_controller.hasClients || _syncing || _snapping) return;
    final itemWidth = _itemWidthFor();
    final next = _valueForOffset(_controller.offset, itemWidth);
    if (next != widget.value) {
      widget.onChanged(next);
    }
  }

  Future<void> _snap(double itemWidth) async {
    if (!_controller.hasClients || _snapping) return;

    final target = _offsetFor(_valueForOffset(_controller.offset, itemWidth), itemWidth);
    final delta = (_controller.offset - target).abs();

    if (delta < 0.5) return;

    _snapping = true;
    try {
      if (delta < itemWidth * 0.25) {
        _syncing = true;
        _controller.jumpTo(target);
        _syncing = false;
        return;
      }

      await _controller.animateTo(
        target,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
      );
    } finally {
      _snapping = false;
    }
  }

  void _handleScrollEnd(double itemWidth) {
    if (_snapping) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _snap(itemWidth);
    });
  }

  Widget _buildRuler(double viewportWidth) {
    final itemWidth = _itemWidthFor();
    final sidePadding = (viewportWidth / 2) - (itemWidth / 2);
    final count = widget.max - widget.min + 1;
    final selectedLabel = _labelFor(widget.value, selected: true);
    final reservedLabelHeight = widget.selectedFontSize * (selectedLabel.contains('\n') ? 2.2 : 1.2);

    return SizedBox(
      height: widget.pickerHeight,
      width: viewportWidth,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        alignment: Alignment.bottomCenter,
        children: [
          NotificationListener<ScrollEndNotification>(
            onNotification: (notification) {
              if (notification.depth == 0) {
                _handleScrollEnd(itemWidth);
              }
              return false;
            },
            child: ListView.builder(
              controller: _controller,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: sidePadding),
              itemCount: count,
              itemBuilder: (context, index) {
                final v = widget.min + index;
                final distance = (v - widget.value).abs();
                final isSelected = distance == 0;
                final opacity = isSelected
                    ? 0.0
                    : distance == 1
                        ? 0.45
                        : distance == 2
                            ? 0.22
                            : 0.12;

                final fontSize = distance == 1 ? 20.0 : 14.0;
                final tickHeight = isSelected ? 0.0 : distance <= 2 ? 16.0 : 10.0;

                return SizedBox(
                  width: itemWidth,
                  height: widget.pickerHeight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!isSelected)
                        SizedBox(
                          width: itemWidth,
                          height: reservedLabelHeight,
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Text(
                              _labelFor(v, selected: false),
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: opacity),
                                fontSize: fontSize,
                                fontWeight: FontWeight.w500,
                                height: 1.1,
                              ),
                            ),
                          ),
                        )
                      else
                        SizedBox(height: reservedLabelHeight),
                      const SizedBox(height: 8),
                      if (!isSelected)
                        Container(
                          width: 1,
                          height: tickHeight,
                          color: Colors.white.withValues(alpha: 0.25),
                        )
                      else
                        const SizedBox(height: _centerTickHeight),
                      const SizedBox(height: 10),
                    ],
                  ),
                );
              },
            ),
          ),
          IgnorePointer(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: viewportWidth * 0.9,
                    child: Text(
                      selectedLabel,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: widget.selectedFontSize,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 2,
                    height: _centerTickHeight,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewportWidth = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;

        if (_lastViewportWidth != viewportWidth) {
          _lastViewportWidth = viewportWidth;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _jumpToValue(widget.value);
          });
        }

        return _buildRuler(viewportWidth);
      },
    );
  }
}
