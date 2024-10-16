import 'package:flutter/material.dart';
import 'database_helper.dart';

class CardsScreen extends StatefulWidget {
  final String folderName;
  const CardsScreen({super.key, required this.folderName});

  @override
  _CardsScreenState createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  late List<CardModel> cards;

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

  void _addCard() async {
    CardModel newCard = CardModel(
      id: 0,
      name: 'New Card',
      suit: widget.folderName,
      imageUrl: 'assets/hearts.png', // Replace with actual image
      folderId:
          await DatabaseHelper.instance.getFolderIdByName(widget.folderName),
    );

    await DatabaseHelper.instance.insertCard(newCard);
    _loadCards(); // Reload the cards
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
              children: [
                Image.asset(card.imageUrl, width: 80, height: 80),
                Text(card.name),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _updateCard(card),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteCard(card.id),
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
