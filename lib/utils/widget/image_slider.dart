import 'package:flutter/material.dart';
class ImageSliderDialog extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const ImageSliderDialog({
    Key? key,
    required this.images,
    this.initialIndex = 0,
  }) : super(key: key);

  @override
  _ImageSliderDialogState createState() => _ImageSliderDialogState();
}

class _ImageSliderDialogState extends State<ImageSliderDialog> {
  late PageController _controller;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.all(0),
      child: Stack(
        children: [
          SizedBox(
            child: PageView.builder(
            
              controller: _controller,
              itemCount: widget.images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  child: Image.network(
                    widget.images[index],
                    fit: BoxFit.contain,
                    errorBuilder:
                        (context, error, stackTrace) => Center(
                          child: Icon(Icons.broken_image, color: Colors.white),
                        ),
                    loadingBuilder:
                        (context, child, progress) =>
                            progress == null
                                ? child
                                : Center(child: CircularProgressIndicator()),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 30,
            right: 30,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: Text(
              '${_currentIndex + 1} / ${widget.images.length}',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
