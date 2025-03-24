import 'package:flutter/material.dart';

class Help {
  static OverlayEntry? _overlayEntry;
  static int _currentPage = 1; // Keeps track of the last page
  static const int _maxPage = 5;

  static final List<String> _imagePaths = [
    "lib/assets/board1.png",
    "lib/assets/board2.png",
    "lib/assets/board3.png",
    "lib/assets/board4.png",
    "lib/assets/board5.png",
  ];

  static void show(BuildContext context) {
    if (_overlayEntry != null) return;

    OverlayState overlayState = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () => hide(),
              child: Container(color: Colors.black54),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: 20,
            right: 20,
            child: StatefulBuilder(
              builder: (context, setState) => Material(
                color: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  height: 500,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 10, spreadRadius: 2),
                    ],
                  ),
                  child: Column(
                    children: [
                      // ✅ Centered Help Guide Title with X Button on the Right
                      Stack(
                        children: [
                          Center(
                            child: Text(
                              "Help Guide",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            child: IconButton(
                              icon: Icon(Icons.close, color: Colors.red, size: 28),
                              onPressed: () => hide(),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 5),

                      // ✅ Image (Centered)
                      Expanded(
                        child: Center(
                          child: Image.asset(
                            _imagePaths[_currentPage - 1],
                            fit: BoxFit.contain,
                            width: double.infinity,
                          ),
                        ),
                      ),

                      const SizedBox(height: 5),

                      // ✅ Description (Centered)
                      Text(
                        "Page $_currentPage description goes here.",
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 10),

                      // ✅ Pagination Controls (Centered)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios, size: 24),
                            onPressed: _currentPage > 1
                                ? () {
                                    setState(() {
                                      _currentPage--;
                                    });
                                  }
                                : null,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              "$_currentPage / $_maxPage",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.arrow_forward_ios, size: 24),
                            onPressed: _currentPage < _maxPage
                                ? () {
                                    setState(() {
                                      _currentPage++;
                                    });
                                  }
                                : null,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    overlayState.insert(_overlayEntry!);
  }

  static void hide() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
