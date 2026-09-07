import 'dart:math';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class GameColor {
  final int id;
  final String nameEs;
  final String nameEn;
  final String hexEs;
  final String hexEn;

  const GameColor({
    required this.id,
    required this.nameEs,
    required this.nameEn,
    required this.hexEs,
    required this.hexEn,
  });

  String nameFor(String lang) => lang.toUpperCase() == 'ES' ? nameEs : nameEn;

  String hexFor(String lang) => lang.toUpperCase() == 'ES' ? hexEs : hexEn;

  Color paintFor(String lang) {
    final raw = hexFor(lang).replaceFirst('#', '');
    return Color(int.parse('FF$raw', radix: 16));
  }

  factory GameColor.fromMap(Map<String, dynamic> map) {
    return GameColor(
      id: map['id'] as int,
      nameEs: map['name_es'] as String,
      nameEn: map['name_en'] as String,
      hexEs: map['hex_es'] as String,
      hexEn: map['hex_en'] as String,
    );
  }
}

class GameRound {
  final GameColor target;
  final List<GameColor> options;

  const GameRound({required this.target, required this.options});
}

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static List<GameColor>? _cachedColors;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('colors_game.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE game_data (
        id INTEGER PRIMARY KEY,
        name_es TEXT NOT NULL,
        name_en TEXT NOT NULL,
        hex_es TEXT NOT NULL,
        hex_en TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE app_scores (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        points INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    const seed = <List<String>>[
      ['1', 'ROJO', 'RED', '#FF0000', '#FF0000'],
      ['2', 'AZUL', 'BLUE', '#0000FF', '#0000FF'],
      ['3', 'VERDE', 'GREEN', '#3C8434', '#3C8434'],
      ['4', 'AMARILLO', 'YELLOW', '#FFFF00', '#FFFF00'],
      ['5', 'NEGRO', 'BLACK', '#000000', '#000000'],
      ['6', 'BLANCO', 'WHITE', '#FFFFFF', '#FFFFFF'],
      ['7', 'MORADO', 'PURPLE', '#800080', '#800080'],
      ['8', 'TOMATE', 'ORANGE', '#FFA500', '#FFA500'],
      ['9', 'ROSADO', 'PINK', '#FFC0CB', '#FFC0CB'],
      ['10', 'CAFE', 'BROWN', '#A52A2A', '#A52A2A'],
      ['11', 'AQUA', 'AQUA', '#00FFFF', '#00FFFF'],
      ['12', 'NARANJA ROJO', 'ORANGE RED', '#FF4500', '#FF4500'],
      ['13', 'PLOMO', 'SILVER', '#C0C0C0', '#C0C0C0'],
      ['14', 'GRIS', 'GRAY', '#808080', '#808080'],
      ['15', 'TURQUEZA', 'TURQUOISE', '#40E0D0', '#40E0D0'],
      ['16', 'VIOLETA', 'VIOLET', '#EE82EE', '#EE82EE'],
      ['17', 'ROJO OSCURO', 'DARK RED', '#8B0000', '#8B0000'],
      ['18', 'AZUL MARINO', 'NAVI BLUE', '#000080', '#000080'],
      ['19', 'VERDE LIMA', 'LIME GREEN', '#00FF00', '#00FF00'],
      ['20', 'AMARILLO MOSTAZA', 'MUSTARD YELLOW', '#FFDB58', '#FFDB58'],
      ['21', 'NARANJA CORAL', 'CORAL ORANGE', '#FF6F61', '#FF6F61'],
      ['22', 'BLANCO HUESO', 'DARK PURPLE', '#E3D2B3', '#4B0082'],
      ['23', 'CAFE CLARO', 'LIGTH BROWN', '#D2B48C', '#D2B48C'],
      ['24', 'AZUL CLARO', 'LIGHT BLUE', '#ADD8E6', '#ADD8E6'],
      ['25', 'AMARILLO CLARO', 'LIGHT YELLOW', '#FFFFE0', '#FFFFE0'],
      ['26', 'VERDE CLARO', 'LIGHT GREEN', '#90EE90', '#90EE90'],
      ['27', 'MOSTAZA', 'MUSTRARD', '#FFDB58', '#FFDB58'],
      ['28', 'CORAL', 'CORAL', '#FF6F61', '#FF6F61'],
      ['29', 'DORADO', 'GOLD', '#FFD700', '#FFD700'],
      ['30', 'AZUL MEDIANOCHE', 'MIDNIGHT BLUE', '#191970', '#191970'],
      ['31', 'CELESTE', 'SKY BLUE', '#87CEEB', '#87CEEB'],
      ['32', 'CREMA', 'CREAM', '#FFFDD0', '#FFFDD0'],
      ['33', 'CARMESI', 'CRIMSON', '#DC143C', '#DC143C'],
    ];

    for (final item in seed) {
      await db.insert('game_data', {
        'id': int.parse(item[0]),
        'name_es': item[1],
        'name_en': item[2],
        'hex_es': item[3],
        'hex_en': item[4],
      });
    }
  }

  Future<List<GameColor>> getAllColors() async {
    if (_cachedColors != null) return _cachedColors!;
    final db = await instance.database;
    final rows = await db.query('game_data', orderBy: 'id ASC');
    _cachedColors = rows.map(GameColor.fromMap).toList();
    return _cachedColors!;
  }

  Future<GameRound?> loadRandomRound({int optionCount = 6}) async {
    final all = await getAllColors();
    if (all.isEmpty) return null;

    final random = Random();
    final target = all[random.nextInt(all.length)];
    final others = all.where((color) => color.id != target.id).toList()
      ..shuffle(random);
    final take = max(0, optionCount - 1);
    final options = <GameColor>[target, ...others.take(take)]..shuffle(random);
    return GameRound(target: target, options: options);
  }

  Future<bool> isReady() async {
    try {
      final colors = await getAllColors();
      return colors.isNotEmpty;
    } catch (_) {
      return false;
    }
  }
}
