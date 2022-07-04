import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mingo/view/shared/basic/action_button.dart';

class _ButtonOption extends StatefulWidget {
  final String label;
  final double width;
  final bool selected;
  final void Function() onTap;

  const _ButtonOption({
    required this.label,
    required this.width,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_ButtonOption> createState() => __ButtonOptionState();
}

class __ButtonOptionState extends State<_ButtonOption> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: _isHovering ? const Color(0xff16FFBD) : Colors.transparent,
        ),
        child: SizedBox(
          width: widget.width,
          height: 40,
          child: Padding(
            padding: MediaQuery.of(context).size.width < 500 ? EdgeInsets.zero : const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    widget.label,
                    maxLines: 1,
                    overflow: kIsWeb ? null : TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                if (widget.selected)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.check,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      onTap: widget.onTap,
      onHover: (value) => setState(() => _isHovering = value),
    );
  }
}

class DashboardPageAnimatedDropdown extends StatefulWidget {
  final String label;
  final List<String> children;
  final Function selectedIndex;
  final void Function(int)? onItemSelected;

  const DashboardPageAnimatedDropdown({
    super.key,
    required this.label,
    required this.children,
    required this.selectedIndex,
    this.onItemSelected,
  });

  @override
  State<DashboardPageAnimatedDropdown> createState() => _DashboardPageAnimatedDropdownState();
}

class _DashboardPageAnimatedDropdownState extends State<DashboardPageAnimatedDropdown> {
  final _widgetKey = GlobalKey();

  RenderBox? _renderBox;
  Offset? _widgetOffset;
  double get _fullItemsHeight => widget.children.length * 40;
  double get _heightCutoff => MediaQuery.of(context).size.height * .4;
  // double get _itemsHeight => _fullItemsHeight < _heightCutoff ? _fullItemsHeight : _heightCutoff;

  void _getWidgetInfo() {
    _renderBox = _widgetKey.currentContext!.findRenderObject() as RenderBox;
    _widgetOffset = _renderBox!.localToGlobal(Offset.zero);
    _widgetOffset = Offset(
      _widgetOffset!.dx,
      _widgetOffset!.dy -
          MediaQueryData.fromWindow(WidgetsBinding.instance.window).padding.top +
          (MediaQuery.of(context).size.width < 1000 ? 0 : 54),
    );
  }

  String? _selected;

  @override
  void initState() {
    super.initState();
    final selectedIndex = widget.selectedIndex();
    if (selectedIndex != null) {
      _selected = widget.children[selectedIndex];
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _getWidgetInfo());
  }

  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return MinGOActionButton(
      key: _widgetKey,
      label: _selected ?? widget.label,
      icon: Icons.arrow_drop_down,
      underlined: true,
      contentBlocking: false,
      onTap: () {
        FocusScope.of(context).unfocus();
        setState(() => _expanded = !_expanded);
        _getWidgetInfo();
        showGeneralDialog(
          context: context,
          barrierLabel: '',
          barrierDismissible: true,
          barrierColor: Colors.transparent,
          pageBuilder: (context, _, __) => SafeArea(
            child: Transform.translate(
              offset: _widgetOffset!,
              child: GestureDetector(
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              offset: Offset(0, 4),
                              blurRadius: 4,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: _renderBox!.size.width,
                          height: _fullItemsHeight + widget.children.length * 6 + 18,
                          child: ListView(
                            padding: MediaQuery.of(context).size.width < 1100
                                ? const EdgeInsets.fromLTRB(12, 12, 12, 6)
                                : MediaQuery.of(context).size.width < 1300
                                    ? const EdgeInsets.fromLTRB(16, 12, 16, 6)
                                    : const EdgeInsets.fromLTRB(30, 12, 30, 6),
                            physics: const ClampingScrollPhysics(),
                            children: [
                              for (int i = 0; i < widget.children.length; i++)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: _ButtonOption(
                                    label: widget.children[i],
                                    width: _renderBox!.size.width,
                                    selected: widget.selectedIndex() == i,
                                    onTap: () async {
                                      widget.onItemSelected!(i);
                                      setState(() => _selected = _selected == widget.children[i] ? null : widget.children[i]);
                                      Navigator.pop(context);
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ),
          ),
        ).whenComplete(() => setState(() => _expanded = !_expanded));
      },
    );
  }
}
