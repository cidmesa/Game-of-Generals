import 'package:flutter/material.dart';

class Help {
  static OverlayEntry? _overlayEntry;
  static int _currentPage = 1; // Keeps track of the last page
  static const int _maxPage = 5;

  static final List<String> _headers = [
    "Objective of the Game",
    "Board Set-Up",
    "Piece Movement",
    "Challenge Mechanic",
    "How the Game Ends",
  ];

  static final List<String> _imagePaths = [
    "lib/assets/objective_help.png",
    "lib/assets/board_setup_help.png",
    "lib/assets/movement_help.png",
    "lib/assets/challenge_help.png",
    "lib/assets/flag_help.png",
  ];

  static final List<String> _descriptions = [
    '''The objective of the game is to eliminate or capture the Flag of your opponent. 
    You may also win by successfully maneuvering your own Flag to the opposite end of the board.

    The player's set of pieces or soldiers with the corresponding ranks (arranged from the highest to lowest rank) and functions consists of the following 21 pieces:

    1.) Five-Star General (★★★★★) – Highest-ranking piece, can capture all lower ranks except the Spy.

    2.) Four-Star General (★★★★) – Second-highest rank, can eliminate all lower ranks except the Spy.

    3.) Three-Star General (★★★) – Can capture all lower ranks except the Spy.

    4.) Two-Star General (★★) – Can capture all lower ranks except the Spy.

    5.) One-Star General (★) – Can capture all lower ranks except the Spy.

    6.) Colonel (Col.) – Can capture Lieutenant Colonel and all lower ranks except the Spy.

    7.) Lieutenant Colonel (Lt. Col.) – Can capture Major and all lower ranks except the Spy.

    8.) Major (Maj.) – Can capture Captain and all lower ranks except the Spy.

    9.) Captain (Cpt.) – Can capture 1st Lieutenant and all lower ranks except the Spy.

    10.) 1st Lieutenant (1st Lt.) – Can capture 2nd Lieutenant and all lower ranks except the Spy.

    11.) 2nd Lieutenant (2nd Lt.) – Can capture Sergeant and Private but loses to higher ranks and the Spy.

    12.) Sergeant (Sgt.) – Can capture Private but loses to all higher ranks and the Spy.

    13.) Private (Pvt.) – Can capture the Spy but loses to all other ranks.

    14.) Spy – Can eliminate any rank except the Private.

    15.) Flag – The most important piece; losing it results in defeat.
    
    ''',
    '''Arrange your respective sets of pieces on the first three (3) rows on your end of the board with the printed sides facing you. 
    There is no predetermined place for any piece. You are therefore free to arrange the pieces according to your strategy of style of play.''',
    '''1.) Any player makes the first move. Players move alternately. 
      2.) A player is allowed to move only one piece at a time.
      3.) A move consists of pushing a piece to an adjacent square, either forward, backward or sideward. 
      A diagonal move or a move of more than one square is illegal.''',
    '''As the game progresses, challenges are made resulting in the elimination of soldiers.
  
    A challenge is made when a soldier moves into the same square occupied by an opposing soldier. 
    When a challenge is made, the following rules of elimination apply:

    a. A higher-ranked soldier eliminates a lower-ranked soldier.  
    b. If both soldiers are of equal rank, both are eliminated.  
    c. A spy eliminates any officer (from 5-star General down to Sergeant).  
    d. The Flag can be eliminated or captured by any piece, including the opponent's Flag.  
    e. Only a Private can eliminate the Spy.  
    f. A Flag that moves into the same square as the opponent’s Flag wins the game.''',
    '''1. The game ends:
    a. When the Flag is eliminated or captured.
    b. When a Flag reaches the opposite end of the board. (restrictions in rule 2)

    2. A Flag reaching the opposite end of the board may still be eliminated by an opposing piece occupying a square adjacent to the one reached by the Flag. 
    In order to win, the Flag should at least be two square or two ahead of any opposing piece. ''',
  ];

  static void show(BuildContext context) {
    if (_overlayEntry != null) return;

    OverlayState overlayState = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // ✅ Dimmed Background (Tap to Close)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => hide(),
              child: Container(color: Colors.black54),
            ),
          ),

          // ✅ Main Help Guide Overlay
          Center(
            child: StatefulBuilder(
              builder: (context, setState) => Material(
                color: Colors.transparent,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 100, horizontal: 50),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            spreadRadius: 2),
                      ],
                    ),
                    child: Column(
                      children: [
                        // ✅ Fixed "Help Guide" Title with Close Button
                        Stack(
                          children: [
                            Center(
                              child: Text(
                                "Help Guide", // Fixed title
                                style: TextStyle(
                                    fontFamily: 'Force Commander',
                                    fontSize: 32,
                                    color: Color(0xFF00267e)),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Positioned(
                              right: 0,
                              child: IconButton(
                                icon: Icon(Icons.close,
                                    color: Colors.red, size: 28),
                                onPressed: () => hide(),
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 5),

                        // ✅ Dynamic Page Header (Changes per Page)
                        Text(
                          _headers[_currentPage - 1], // Dynamic header
                          style: TextStyle(
                              fontFamily: 'Eurostile Bold',
                              fontSize: 18,
                              color: Colors.black),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 10),

                        // ✅ Scrollable Image & Description
                        Expanded(
                          child: SizedBox(
                            width: double.infinity,
                            child: Scrollbar(
                              thumbVisibility: false, // ✅ Shows the scrollbar
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    // ✅ Image (Hidden if no image)
                                    if (_imagePaths[_currentPage - 1] != "")
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        child: Image.asset(
                                          _imagePaths[_currentPage - 1],
                                          fit: BoxFit.contain,
                                          width: 300, // ✅ Adjust image size
                                          height: 200,
                                        ),
                                      ),

                                    // ✅ Description Text (Centered)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Text(
                                        _descriptions[_currentPage - 1],
                                        style: TextStyle(
                                            fontFamily: 'Eurostile',
                                            fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // ✅ Pagination Controls (Fixed at Bottom)
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                "$_currentPage / $_maxPage",
                                style: TextStyle(
                                    fontFamily: 'Eurostile Bold', fontSize: 16),
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
