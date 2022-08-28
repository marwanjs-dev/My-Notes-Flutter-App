import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:mynotes/extensions/list/filter.dart';
import 'package:mynotes/utilities/dialogs/error_dialog.dart';
import "package:sqflite/sqflite.dart";
import "package:path_provider/path_provider.dart";
import 'package:path/path.dart' show join;

import 'constants.dart';
import 'exceptions.dart';

class NoteService {
  DataBaseUser? _user;
  Database? _db;

  List<DataBaseNote> _notes = [];

  static final NoteService _shared = NoteService._sharedInstance();
  NoteService._sharedInstance() {
    _notesStreamController =
        StreamController<List<DataBaseNote>>.broadcast(onListen: () {
      _notesStreamController.sink.add(_notes);
    });
  }
  factory NoteService() => _shared;

  late final StreamController<List<DataBaseNote>> _notesStreamController;
  Stream<List<DataBaseNote>> get allNotes =>
      _notesStreamController.stream.filter((note) {
        final currentUser = _user;
        if (currentUser != null) {
          return note.userId == currentUser.id;
          //if the note in the database has the currentUser's id then return true for this note
        } else {
          throw UserShouldBeSetBeforeReadingAllNotes();
        }
      });

  Future<DataBaseUser> getOrCreateUser({
    required String email,
    bool setAsCurrentUser = true,
  }) async {
    await _ensureDbIsOpen();
    try {
      final user = await getUser(Email: email);
      if (setAsCurrentUser) {
        _user = user;
      }
      return user;
    } on UserNotFoundDatabaseException {
      final createdUser = await createUser(Email: email);
      if (setAsCurrentUser) {
        _user = createdUser;
      }
      return createdUser;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _cacheNotes() async {
    final allNotes = await getAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
  }

  Future<int> deleteAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final numberOfDeletions = await db.delete(notesTable);
    _notes = [];
    _notesStreamController.add(_notes);
    return numberOfDeletions;
  }

  Future<void> deleteNote({required int ID}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      notesTable,
      where: "id = ?",
      whereArgs: [ID],
    );
    if (deletedCount != 1) {
      throw CouldNotDeleteNoteException;
    } else {
      _notes.removeWhere((note) => note.id == ID);
      _notesStreamController.add(_notes);
    }
  }

  Future<Iterable<DataBaseNote>> getAllNotes() async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes = await db.query(notesTable);
    final result = notes.map((noteRow) => DataBaseNote.fromRow(noteRow));
    if (result.length == 0) {
      throw CouldNotFindAnyNotesException;
    } else {
      return result;
    }
  }

  Future<DataBaseNote> getNote({required int Id}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final notes =
        await db.query(notesTable, limit: 1, where: "id = ?", whereArgs: [Id]);
    if (notes.isEmpty) {
      throw CouldNotGetNoteException;
    } else {
      final note = DataBaseNote.fromRow(notes.first);
      _notes.removeWhere((note) => note.id == Id);
      _notesStreamController.add(_notes);
      return note;
    }
  }

  Future<DataBaseNote> updateNote({
    required DataBaseNote note,
    required String text,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    await getNote(Id: note.id);

    final updateCount = await db.update(
      notesTable,
      {
        textColumn: text,
        isSyncedWithCloudColumn: 0,
      },
      where: "id = ?",
      whereArgs: [note.id],
    );

    if (updateCount == 0) {
      throw CouldNotUpdateNoteException;
    } else {
      final updatedNote = await getNote(Id: note.id);
      _notes.removeWhere((note) => note.id == note.id);
      _notes.add(updatedNote);
      _notesStreamController.add(_notes);
      return updatedNote;
    }
  }

  Future<DataBaseNote> createNote({required DataBaseUser owner}) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();

    final dbUser = await getOrCreateUser(email: owner.email);
    if (dbUser != owner) {
      throw UserNotFoundDatabaseException();
    } else {
      final textt = "";
      final noteID = await db.insert(notesTable, {
        userIdColumn: owner.id,
        textColumn: textt,
        isSyncedWithCloudColumn: 1,
      });
      final note = DataBaseNote(
          id: noteID, userId: owner.id, text: textt, isSyncedWithCloud: true);

      _notes.add(note);
      _notesStreamController.add(_notes);

      return note;
    }
  }

  Future<DataBaseUser> getUser({required String Email}) async {
    await _ensureDbIsOpen();
    Database db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      where: "email = ?",
      whereArgs: [Email.toLowerCase()],
      limit: 1,
    );
    if (result.isEmpty) {
      throw UserNotFoundDatabaseException;
    } else {
      return DataBaseUser.fromRow(result.first); //important
    }
  }

  Future<DataBaseUser> createUser({
    required String Email,
  }) async {
    await _ensureDbIsOpen();
    final db = _getDatabaseOrThrow();
    final result = await db.query(
      userTable,
      where: "email = ?",
      whereArgs: [Email.toLowerCase()],
      limit: 1,
    );
    if (result.isNotEmpty) {
      throw UserAlreadyCreatedException;
    }
    final userId =
        await db.insert(userTable, {emailColumn: Email.toLowerCase()});
    DataBaseUser user = DataBaseUser(id: userId, email: Email);
    return user;
  }

  Future<void> deleteUser({required String email}) async {
    await _ensureDbIsOpen();
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpenException();
    } else {
      final deletedCount = await db.delete(userTable,
          where: "email = ?", whereArgs: [email.toLowerCase()]);
      if (deletedCount != 1) {
        throw CouldNotDeleteUserException;
      }
    }
  }

  Database _getDatabaseOrThrow() {
    _ensureDbIsOpen();
    final db = _db;
    if (db == null) {
      throw DatabaseNotOpenException();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DatabaseAlreadyCloseException();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> _ensureDbIsOpen() async {
    try {
      await open();
    } on DatabaseAlreadyOpenException {}
  }

  Future<void> open() async {
    if (_db != null) {
      throw DatabaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      //await db.execute(dropping);
      await db.execute(createNoteTable);
      await db.execute(createUserTable);
      await _cacheNotes();
    } on MissingPlatformDirectoryException {
      throw unableToGetDocumentDirectoryException();
    }
  }
}

class DataBaseUser {
  final int id;
  final String email;

  const DataBaseUser({
    required this.id,
    required this.email,
  });

  DataBaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  String toString() => 'Person, ID = ${id} email = $email';

  @override
  bool operator ==(covariant DataBaseUser other) => id == other.id;

  @override
  // TODO: implement hashCode
  int get hashCode => id.hashCode;
}

class DataBaseNote {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DataBaseNote(
      {required this.id,
      required this.userId,
      required this.text,
      required this.isSyncedWithCloud});

  DataBaseNote.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textColumn] as String,
        isSyncedWithCloud =
            (map[isSyncedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      "Note, ID= $id, userId =$userId, text = $text, isSyncedWithCloud = $isSyncedWithCloud";

  @override
  bool operator ==(covariant DataBaseNote other) => id == other.id;

  @override
  // TODO: implement hashCode
  int get hashCode => id.hashCode;
}
