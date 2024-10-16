import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

const String tableFolders = 'folders';
const String tableCards = 'cards';

class FolderModel {
  final int id;
  final String name;
  final int cardCount;

  FolderModel({required this.id, required this.name, required this.cardCount});

  factory FolderModel.fromJson(Map<String, dynamic> json) {
    return FolderModel(
      id: json['id'],
      name: json['name'],
      cardCount: json['cardCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'cardCount': cardCount};
  }
}

class CardModel {
  final int id;
  final String name;
  final String suit;
  final String imageUrl;
  final int folderId;

  CardModel({
    required this.id,
    required this.name,
    required this.suit,
    required this.imageUrl,
    required this.folderId,
  });

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'],
      name: json['name'],
      suit: json['suit'],
      imageUrl: json['imageUrl'],
      folderId: json['folderId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'suit': suit,
      'imageUrl': imageUrl,
      'folderId': folderId,
    };
  }
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<void> init() async {
    if (_database != null) return;
    _database = await _initDatabase();
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'cards_db.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableFolders (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableCards (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        suit TEXT NOT NULL,
        imageUrl TEXT NOT NULL,
        folderId INTEGER NOT NULL,
        FOREIGN KEY (folderId) REFERENCES $tableFolders(id)
      )
    ''');

    // Insert pre-defined folders
    await db.insert(tableFolders, {'name': 'Hearts'});
    await db.insert(tableFolders, {'name': 'Spades'});
    await db.insert(tableFolders, {'name': 'Diamonds'});
    await db.insert(tableFolders, {'name': 'Clubs'});
  }

  // Folder CRUD operations
  Future<List<FolderModel>> getFolders() async {
    final result = await _database!.query(tableFolders);
    return result.map((json) => FolderModel.fromJson(json)).toList();
  }

  Future<int> getFolderIdByName(String folderName) async {
    final result = await _database!.query(
      tableFolders,
      columns: ['id'],
      where: 'name = ?',
      whereArgs: [folderName],
    );
    return result.first['id'] as int;
  }

  // Card CRUD operations
  Future<List<CardModel>> getCardsByFolder(String folderName) async {
    final folderId = await getFolderIdByName(folderName);
    final result = await _database!.query(
      tableCards,
      where: 'folderId = ?',
      whereArgs: [folderId],
    );
    return result.map((json) => CardModel.fromJson(json)).toList();
  }

  Future<int> insertCard(CardModel card) async {
    return await _database!.insert(tableCards, card.toJson());
  }

  Future<int> updateCard(CardModel card) async {
    return await _database!.update(
      tableCards,
      card.toJson(),
      where: 'id = ?',
      whereArgs: [card.id],
    );
  }

  Future<int> deleteCard(int id) async {
    return await _database!.delete(
      tableCards,
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
