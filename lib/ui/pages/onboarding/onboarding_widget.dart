import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app/core/ops/lcl_db_ops.dart';
import 'package:flutter_app/ui/elements/dots_indicator.dart';
import 'package:flutter_app/ui/pages/onboarding/screens/page1.dart';
import 'package:flutter_app/ui/pages/onboarding/screens/page2.dart';
import 'package:flutter_app/ui/pages/onboarding/screens/page3.dart';
import 'package:flutter_app/ui/pages/onboarding/screens/page4.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:flutter_app/util/ui_constants.dart';
import 'package:provider/provider.dart';

class _OnboardingMainPageState extends State<OnboardingMainPage> {
  final _controller = new PageController();
  final Log log = new Log("OnboardingPage");
  final List<Widget> _pages = [
    Page1(),
    Page2(),
    Page3(),
    Page4(),
  ];
  int page = 0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(Duration(seconds: 4), (Timer timer) {
      if (page < 3) {
        page++;
      } else {
        page = 0;
      }

      _controller.animateToPage(
        page,
        duration: Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    });
  }


  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final onboardProvider = Provider.of<LocalDBModel>(context);
    bool isDone = page == _pages.length - 1;
    return new Scaffold(
        backgroundColor: Colors.transparent,
        body: new Stack(
          children: <Widget>[
            new Positioned.fill(
              child: new PageView.builder(
                physics: new AlwaysScrollableScrollPhysics(),
                controller: _controller,
                itemCount: _pages.length,
                itemBuilder: (BuildContext context, int index) {
                  return _pages[index % _pages.length];
                },
                onPageChanged: (int p){
                  setState(() {
                    page = p;
                  });
                },
              ),
            ),
            /*new Positioned(
              top: 0.0,
              left: 0.0,
              right: 0.0,
              child: new SafeArea(
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0.0,
                  primary: false,
                  title: Text('Onboarding Example'),
                  actions: <Widget>[
                    FlatButton(
                      child: Text(isDone ? 'DONE' : 'NEXT', style: TextStyle(color: Colors.white),),
                      onPressed: isDone ? (){
                        Navigator.pop(context);
                      } : (){
                        _controller.animateToPage(page + 1, duration: Duration(milliseconds: 300), curve: Curves.easeIn);
                      },
                    )
                  ],
                ),
              ),
            ),*/
            new Positioned(
              bottom: 30.0,
              left: 0.0,
              right: 0.0,
              child: new SafeArea(
                child: new Column(
                  children: <Widget>[
                    new Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new DotsIndicator(
                        controller: _controller,
                        itemCount: _pages.length,
                        onPageSelected: (int page) {
                          _controller.animateToPage(
                            page,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease,
                          );
                        },
                      ),
                    ),
                    SizedBox(height: 5.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        new Container(
                          width: 150.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                            gradient: new LinearGradient(
                                colors: [
                                    UiConstants.primaryColor,
                                    UiConstants.darkPrimaryColor,
//                                    Colors.green[400],
//                                    Colors.green[600],
//                                  Colors.orange[600],
//                                  Colors.orange[900],
                                ],
                                begin: Alignment(0.5, -1.0),
                                end: Alignment(0.5, 1.0)
                            ),
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                          child: new Material(
                            child: MaterialButton(
                              child: Text('LOGIN',
                                style: Theme.of(context).textTheme.button.copyWith(color: Colors.white),
                              ),
                              onPressed: (){
                                log.debug("Setting Onboarding flag to true.");
                                onboardProvider.saveOnboardStatus(true);
                                _controller.dispose();
                                Navigator.of(context).pop();
                                Navigator.of(context).pushReplacementNamed('/login');
                              },
                              highlightColor: Colors.orange.withOpacity(0.5),
                              splashColor: Colors.orange.withOpacity(0.5),
                            ),
                            color: Colors.transparent,
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                        ),
                        new Container(
                          width: 150.0,
                          height: 50.0,
                          decoration: BoxDecoration(
                            borderRadius: new BorderRadius.circular(30.0),
                            border: Border.all(color: UiConstants.primaryColor, width: 1.0),
                            color: Colors.transparent,
                          ),
                          child: new Material(
                            child: MaterialButton(
                              child: Text('SKIP',
                                style: Theme.of(context).textTheme.button.copyWith(color: UiConstants.primaryColor),
                              ),
                              onPressed: (){
                                log.debug("Setting Onboarding flag to true.");
                                onboardProvider.saveOnboardStatus(true);
                                Navigator.of(context).pop();
                                Navigator.of(context).pushReplacementNamed('/home');
                              },
                              highlightColor: Colors.white30,
                              splashColor: Colors.white30,
                            ),
                            color: Colors.transparent,
                            borderRadius: new BorderRadius.circular(30.0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
    );
  }
}

class OnboardingMainPage extends StatefulWidget {
  OnboardingMainPage({Key key}) : super(key: key);

  @override
  _OnboardingMainPageState createState() => new _OnboardingMainPageState();
}