import 'package:flutter/material.dart';

class DraggableFAB extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget child;

  const DraggableFAB({Key? key, required this.onPressed, required this.child})
      : super(key: key);

  @override
  State<DraggableFAB> createState() => _DraggableFABState();
}

class _DraggableFABState extends State<DraggableFAB> {
  Offset _position = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Draggable<Offset>(
        data: _position,
        feedback: Material(
          elevation: 4.0,
          child: widget.child,
        ),
        childWhenDragging: const SizedBox.shrink(),
        onDragStarted: () {},
        onDragEnd: (details) {
          RenderBox renderBox = context.findRenderObject() as RenderBox;
          Offset localOffset = renderBox.globalToLocal(details.offset); 
          setState(() {
            _position = localOffset; 
          });
        },
        child: GestureDetector(
          onTap: widget.onPressed,
          child: widget.child,
        ),
      ),
    );
  }
}