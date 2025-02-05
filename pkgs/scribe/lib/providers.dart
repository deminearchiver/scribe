import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:scribe/brick/models/note.model.dart';
import 'package:scribe/brick/models/user.model.dart';
import 'package:scribe/brick/repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:brick_core/query.dart';
import 'package:rxdart/subjects.dart';

class UserController {
  UserController() {
    _supabase.auth.onAuthStateChange
        .map((state) => state.session)
        .listen(_sessionListener);
  }

  final _supabase = Supabase.instance.client;
  final _repository = Repository();

  Session? _session;

  StreamSubscription<AuthState>? _authSubscription;
  StreamSubscription<UserModel?>? _userSubscription;

  final _controller = BehaviorSubject<UserModel?>();
  Stream<UserModel?> get stream => _controller.stream;

  void dispose() {
    _userSubscription?.cancel();
    _authSubscription?.cancel();
  }

  void _sessionListener(Session? session) {
    _userSubscription?.cancel();
    if (session != null) {
      final users = _repository.subscribeToRealtime<UserModel>();
      _userSubscription = users
          .map((users) => users.singleOrNull)
          .listen(_userListener);
    } else {
      _controller.add(null);
    }
  }

  void _userListener(UserModel? user) {
    _controller.add(user);
  }
}

class NotesController {
  NotesController({UserModel? user}) {
    this.user = user;
  }

  final _repository = Repository();

  StreamSubscription<List<NoteModel>>? _subscription;

  final _controller = BehaviorSubject<List<NoteModel>>();
  Stream<List<NoteModel>> get stream => _controller.stream;

  UserModel? _user;
  UserModel? get user => _user;
  set user(UserModel? newUser) {
    _user = newUser;
    _subscription?.cancel();
    if (newUser != null) {
      final notes = _repository.subscribeToRealtime<NoteModel>(
        query: Query.where("user", newUser),
      );
      _subscription = notes.listen(_notesListener);
    } else {
      _controller.add([]);
    }
  }

  void dispose() {
    _subscription?.cancel();
  }

  void _notesListener(List<NoteModel> notes) {
    _controller.add(notes);
  }
}
