// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';
import 'package:hisnelmoslem/src/core/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/round_button.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/home/presentation/screens/home_screen.dart';
import 'package:hisnelmoslem/src/features/onboarding/presentation/controller/cubit/onboard_cubit.dart';

class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<OnboardCubit>()..start(),
      child: BlocConsumer<OnboardCubit, OnboardState>(
        listener: (context, state) {
          if (state is OnboardDoneState) {
            transitionAnimation.circleRevalPushReplacement(
              context: context,
              goToPage: const HomeScreen(),
            );
          }
        },
        builder: (context, state) {
          if (state is! OnboardLoadedState) {
            return const Loading();
          }
          return Scaffold(
            appBar: AppBar(
              title: Text(appVersion.toArabicNumber()),
              centerTitle: true,
            ),
            body: PageView.builder(
              physics: const BouncingScrollPhysics(),
              controller: context.read<OnboardCubit>().pageController,
              itemCount: state.pages.length,
              itemBuilder: (context, index) {
                return state.pages[index];
              },
            ),
            bottomNavigationBar: BottomAppBar(
              color: Theme.of(context).scaffoldBackgroundColor,
              child: SizedBox(
                height: 50,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          state.pages.length,
                          (index) => Dot(
                            index: index,
                            currentPageIndex: state.currentPageIndex,
                          ),
                        ),
                      ),
                    ),
                    if (state.isFinalPage)
                      Expanded(
                        child: RoundButton(
                          radius: 10,
                          text: Text(
                            'Start'.tr,
                          ),
                          onTap: () {
                            context.read<OnboardCubit>().done();
                          },
                        ),
                      )
                    else
                      !state.showSkipBtn
                          ? const SizedBox()
                          : Expanded(
                              child: RoundButton(
                                radius: 10,
                                isTransparent: true,
                                text: Text(
                                  "Skip".tr,
                                  style: const TextStyle(),
                                ),
                                onTap: () {
                                  context.read<OnboardCubit>().done();
                                },
                              ),
                            ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class Dot extends StatelessWidget {
  final int index;
  final int currentPageIndex;
  const Dot({
    super.key,
    required this.index,
    required this.currentPageIndex,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 10,
      width: currentPageIndex == index ? 25 : 10,
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
