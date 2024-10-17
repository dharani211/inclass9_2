import 'package:flutter/material.dart';
import 'database_helper.dart';

class CardsScreen extends StatefulWidget {
  final String folderName;
  const CardsScreen({super.key, required this.folderName});

  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  late List<CardModel> cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  void _loadCards() async {
    final loadedCards =
        await DatabaseHelper.instance.getCardsByFolder(widget.folderName);
    setState(() {
      cards = loadedCards;
    });
  }

  // Dynamically select the image based on the suit
  String _getCardImage(String suit) {
    switch (suit) {
      case 'Hearts':
        return 'assets/hearts.png';
      case 'Spades':
        return 'assets/spades.png';
      case 'Diamonds':
        return 'assets/diamonds.png';
      case 'Clubs':
        return 'assets/club.jpg';
      default:
        return 'assets/hearts.png';
    }
  }

  Future<void> _addCard() async {
    final folderId =
        await DatabaseHelper.instance.getFolderIdByName(widget.folderName);
    final cardCount =
        await DatabaseHelper.instance.getCardCountByFolder(folderId);

    if (cardCount >= 6) {
      _showErrorDialog("This folder can only hold 6 cards.");
    } else {
      CardModel newCard = CardModel(
        name: 'New Card',
        suit: widget.folderName,
        imageUrl: _getCardImage(
            widget.folderName), // Dynamically set the image based on the suit
        folderId: folderId,
      );

      await DatabaseHelper.instance.insertCard(newCard);
      _loadCards(); // Reload the cards
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _updateCard(CardModel card) async {
    CardModel updatedCard = CardModel(
      id: card.id,
      name: 'Updated Card',
      suit: card.suit,
      imageUrl: card.imageUrl,
      folderId: card.folderId,
    );

    await DatabaseHelper.instance.updateCard(updatedCard);
    _loadCards(); // Reload the cards after update
  }

  void _deleteCard(int cardId) async {
    await DatabaseHelper.instance.deleteCard(cardId);
    _loadCards(); // Reload the cards after deletion
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.folderName} - Cards'),
      ),
      body: GridView.builder(
        itemCount: cards.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          final card = cards[index];
          return Card(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Ensure the column minimizes its height
              children: [
                // Image with proper constraints to avoid overflow
                Container(
                  width: 80,
                  height: 80,
                  child: Image.asset(card.imageUrl, fit: BoxFit.contain),
                ),

                // Text with Flexible widget to avoid overflow
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      card.name,
                      overflow: TextOverflow
                          .ellipsis, // Truncate text if it's too long
                    ),
                  ),
                ),

                // Buttons row with proper space management
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit,
                          size: 20), // Reduce button size if needed
                      onPressed: () => _updateCard(card),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete,
                          size: 20), // Reduce button size if needed
                      onPressed: () => _deleteCard(card.id!),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCard,
        child: const Icon(Icons.add),
      ),
    );
  }
}
