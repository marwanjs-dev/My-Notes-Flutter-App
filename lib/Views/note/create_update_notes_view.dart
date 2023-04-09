import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:mynotes/Services/auth/auth_service.dart';
import 'package:mynotes/Services/curd/notes_service.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:mynotes/utilities/generics/get_arguments.dart';

class CreateUpdateNotesView extends StatefulWidget {
  const CreateUpdateNotesView({Key? key}) : super(key: key);

  @override
  State<CreateUpdateNotesView> createState() => _CreateUpdateNotesViewState();
}

class _CreateUpdateNotesViewState extends State<CreateUpdateNotesView> {
  DataBaseNote? _note;
  late final NoteService _noteService;
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    _noteService = NoteService();
    _textEditingController = TextEditingController();
    super.initState();
  }

  // as the user is typing on the screen the listener is updating the note
  void _textControllerListener() async {
    final note = _note;
    if (note == null) {
      return;
    }
    final text = _textEditingController.text;
    await _noteService.updateNote(
      note: note,
      text: text,
    );
  }

  void _setupTextControllerListener() {
    _textEditingController.removeListener(_textControllerListener);
    _textEditingController.addListener(_textControllerListener);
  }

  Future<DataBaseNote> createOrGetExistingNote(
    BuildContext context, {
    bool newNote = true,
  }) async {
    final widgetNote = context.getArgument<DataBaseNote>();

    if (widgetNote != null) {
      _note = widgetNote;
      _textEditingController.text = widgetNote.text;
      return widgetNote;
    }

    final existingNote = _note;
    if (existingNote != null && existingNote.text != "") {
      return existingNote;
    }

    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _noteService.getOrCreateUser(email: email);
    final newNote = await _noteService.createNote(owner: owner);
    _note = newNote;
    return newNote;
  }

  void _deleteNoteIfTextIsEmpty() async {
    final note = _note;
    if (_textEditingController.text.isEmpty && note != null) {
      await _noteService.deleteNote(ID: note.id);
    }
  }

  void _saveNoteIfTextIsNotEmpty() async {
    final note = _note;
    final text = _textEditingController.text;
    if (text.isNotEmpty && note != null) {
      await _noteService.updateNote(note: note, text: text);
    }
  }

  @override
  void dispose() {
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextIsNotEmpty();
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ok"),
      ),
      body: FutureBuilder(
        future: createOrGetExistingNote(context),
        builder: (context, snapshot) {
          // if (snapshot.hasError) {
          //   print(snapshot.error);
          // }
          switch (snapshot.connectionState) {
            case ConnectionState.done:
            case ConnectionState.active:
              _setupTextControllerListener();
              return TextField(
                controller: _textEditingController,
                keyboardType: TextInputType.multiline,
                maxLines: 1,
                decoration: const InputDecoration(
                  hintText: "start typing your note",
                ),
              );
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
