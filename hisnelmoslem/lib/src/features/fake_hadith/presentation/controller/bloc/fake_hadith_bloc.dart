import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/src/core/utils/email_manager.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/data/models/fake_haith.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/data/repository/fake_hadith_database_helper.dart';
import 'package:share_plus/share_plus.dart';

part 'fake_hadith_event.dart';
part 'fake_hadith_state.dart';

class FakeHadithBloc extends Bloc<FakeHadithEvent, FakeHadithState> {
  final FakeHadithDBHelper fakeHadithDBHelper;
  FakeHadithBloc(this.fakeHadithDBHelper) : super(FakeHadithLoadingState()) {
    _initHandlers();
  }

  void _initHandlers() {
    on<FakeHadithStartEvent>(_start);

    on<FakeHadithToggleHadithEvent>(_toggle);
    on<FakeHadithShareHadithEvent>(_copy);
    on<FakeHadithCopyHadithEvent>(_share);
    on<FakeHadithReportHadithEvent>(_report);
  }

  FutureOr<void> _start(
    FakeHadithStartEvent event,
    Emitter<FakeHadithState> emit,
  ) async {
    final allHadith = await fakeHadithDBHelper.getAllFakeHadiths();

    emit(FakeHadithLoadedState(allHadith: allHadith));
  }

  FutureOr<void> _toggle(
    FakeHadithToggleHadithEvent event,
    Emitter<FakeHadithState> emit,
  ) async {
    final state = this.state;
    if (state is! FakeHadithLoadedState) return;

    final List<DbFakeHaith> allHadith =
        List<DbFakeHaith>.from(state.allHadith).map((e) {
      if (e.id == event.fakeHadith.id) {
        return event.fakeHadith.copyWith(isRead: event.isRead);
      }
      return e;
    }).toList();

    if (event.isRead) {
      await fakeHadithDBHelper.markFakeHadithAsRead(
        dbFakeHaith: event.fakeHadith,
      );
    } else {
      await fakeHadithDBHelper.markFakeHadithAsUnRead(
        dbFakeHaith: event.fakeHadith,
      );
    }

    emit(state.copyWith(allHadith: allHadith));
  }

  FutureOr<void> _copy(
    FakeHadithShareHadithEvent event,
    Emitter<FakeHadithState> emit,
  ) async {
    final DbFakeHaith fakeHadith = event.fakeHadith;
    await Clipboard.setData(
      ClipboardData(
        text: "${fakeHadith.text}\n${fakeHadith.darga}",
      ),
    );
  }

  FutureOr<void> _share(
    FakeHadithCopyHadithEvent event,
    Emitter<FakeHadithState> emit,
  ) async {
    final DbFakeHaith fakeHadith = event.fakeHadith;
    Share.share("${fakeHadith.text}\n${fakeHadith.darga}");
  }

  FutureOr<void> _report(
    FakeHadithReportHadithEvent event,
    Emitter<FakeHadithState> emit,
  ) async {
    EmailManager.sendMisspelledInFakeHadith(
      fakeHaith: event.fakeHadith,
    );
  }
}
