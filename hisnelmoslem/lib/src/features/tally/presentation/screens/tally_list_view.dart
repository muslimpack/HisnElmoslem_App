import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/components/tally_card.dart';
import 'package:hisnelmoslem/src/features/tally/presentation/controller/bloc/tally_bloc.dart';

class TallyListView extends StatelessWidget {
  const TallyListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TallyBloc, TallyState>(
      builder: (context, state) {
        if (state is! TallyLoadedState) {
          return const Loading();
        }
        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: state.allCounters.length,
            itemBuilder: (context, index) {
              return TallyCard(dbTally: state.allCounters[index]);
            },
            separatorBuilder: (BuildContext context, int index) {
              return const Divider(height: 0);
            },
          ),
        );
      },
    );
  }
}
