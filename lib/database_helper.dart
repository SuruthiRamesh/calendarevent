//@dart=2.9
import 'dart:io';
import 'package:flutter/services.dart';
import 'event.dart';
import 'eventDTO.dart';
import 'package:sqflite/sqflite.dart';
import 'package:synchronized/synchronized.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database _database;
  DatabaseHelper._();
  static DatabaseHelper _databaseHelper;
  factory DatabaseHelper() {
    if (_databaseHelper == null) {
      _databaseHelper = DatabaseHelper._();
      return _databaseHelper;
    } else {
      return _databaseHelper;
    }
  }
  Future<Database> get _getDatabase async{
    if(_database != null){
      return _database;
    }
    _database = await _initializeDataBase();
    return _database;
  }
  Future<Database> _initializeDataBase() async{
    return await openDatabase(join(await getDatabasesPath(), 'calendar.db'),
        onCreate: (db,version) async{
          await db.execute('''
      CREATE TABLE task (id INTEGER PRIMARY KEY AUTOINCREMENT,title Text, description Text, eventDate Text, time Text )
      ''');
        },
        version: 1
    );

  }
  Future<List<Map<String, dynamic>>> getTasks() async {
    var db = await _getDatabase;
    var result = await db.query("task", orderBy: "time ASC");
    return result;
  }

  Future<List<EventModel>> getTaskList() async {
    var taskMapList = await getTasks();
    var taskList = List<EventModel>();
    for (Map map in taskMapList) {
      taskList.add(EventModel.fromMap(map));
    }
    return taskList;
  }

  Future<int> addTask(EventModel eventModel) async {
    EventDTO eventDTO = EventDTO();
    eventDTO.title = eventModel.title;
    eventDTO.description = eventModel.description;
    eventDTO.eventDate = eventModel.eventDate.toString();
    eventDTO.time = (eventModel.time.hour.toString() +
        ':' +
        eventModel.time.minute.toString());
    // eventDTO.time = eventModel.time.toString();

    var db = await _getDatabase;
    var result = await db.insert("task", eventDTO.toMap());

    print(eventDTO.time.toString() + " --- " + eventDTO.eventDate.toString());
    return result;
  }

  Future<int> updateTask(EventModel eventModel) async {
    EventDTO eventDTO = EventDTO();
    eventDTO.id = eventModel.id;
    eventDTO.title = eventModel.title;
    eventDTO.description = eventModel.description;
    eventDTO.eventDate = eventModel.eventDate.toString();
    eventDTO.time = (eventModel.time.hour.toString() +
        ':' +
        eventModel.time.minute.toString());

    var db = await _getDatabase;
    var result = await db.update("task", eventDTO.toMap(),
        where: 'id = ?', whereArgs: [eventModel.id]);
    return result;
  }

  Future<int> deleteTask(int id) async {
    var db = await _getDatabase;
    var result = await db.delete("task", where: 'id = ?', whereArgs: [id]);
    return result;
  }
}