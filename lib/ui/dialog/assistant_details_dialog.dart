import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/core/model/assistant.dart';
import 'package:flutter_app/ui/elements/mutli_select_chip.dart';
import 'package:flutter_app/util/constants.dart';
import 'package:flutter_app/util/logger.dart';
import 'package:flutter_app/util/ui_constants.dart';

class AssistantDetailsDialog extends StatefulWidget {
  final Assistant assistant;
  AssistantDetailsDialog({
    @required this.assistant,
  });

  @override
  State createState() => _AssistantDetailsDialogState();
}


class _AssistantDetailsDialogState extends State<AssistantDetailsDialog> {
  Log log = new Log('AssistantDetailsDialog');
  final _formKey = GlobalKey<FormState>();
  List<String> serviceList = [Constants.CLEANING, Constants.UTENSILS, Constants.DUSTING];
  List<String> selectedServiceList = [Constants.CLEANING, Constants.UTENSILS, Constants.DUSTING];
  final fdbkController = TextEditingController();

//  Widget build(BuildContext context) {
////    httpProvider = Provider.of<HttpModel>(context);
////    baseProvider = Provider.of<BaseUtil>(context);
//    return Container(
//      margin: EdgeInsets.only(left: 18, right: 18),
//      decoration: BoxDecoration(
//        color: Colors.white,
//        borderRadius: BorderRadius.only(
//          topLeft: Radius.circular(18),
//          topRight: Radius.circular(18),
//        ),
//      ),
//      child: new Wrap(
//        children: <Widget>[
//          new Padding(
//            padding: const EdgeInsets.fromLTRB(25.0, 25.0, 25.0, 25.0),
//            child: dialogContent(context),
//          ),
//        ],
//      ),
//    );
//  }

  Widget build(BuildContext context) {
//    httpProvider = Provider.of<HttpModel>(context);
//    baseProvider = Provider.of<BaseUtil>(context);
    return dialogContent(context);
  }

//  @override
//  Widget build(BuildContext context) {
//    return Dialog(
//      shape: RoundedRectangleBorder(
//        borderRadius: BorderRadius.circular(UiConstants.padding),
//      ),
//      elevation: 0.0,
//      backgroundColor: Colors.transparent,
//      child: dialogContent(context),
//    );
//  }

  dialogContent(BuildContext context) {
    return Wrap(

    children: <Widget>[
     Stack(
      children: <Widget>[
        //...bottom card part,
        Container(

          padding: EdgeInsets.only(
            top: UiConstants.avatarRadius + UiConstants.padding,
            bottom: UiConstants.padding,
            left: UiConstants.padding,
            right: UiConstants.padding,
          ),
          margin: EdgeInsets.only(
              left: 18.0,
              right:18.0,
              top: UiConstants.avatarRadius
          ),
          //height: 00,
          decoration: new BoxDecoration(
            color: Colors.grey[50],
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // To make the card compact
            children: <Widget>[
              Text(
                widget.assistant.name,
                style: Theme.of(context).textTheme.display1.copyWith(color: Colors.grey[800]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.0),
              Text(
                widget.assistant.rating.toString().substring(0,4),
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 64.0)
              ),
              _buildRatingWidget(widget.assistant.rating),
              SizedBox(height: 16.0),
//              Container(
//                child: Container(
//                  padding: const EdgeInsets.all(3.0),
//                  child: ChoiceChip(
//                    label: Text('Cleaning'),  //TODO fix this!!
//                    selected: true,
//                    onSelected: (selected) {
//
//                    },
//                  ),
//                )
//              ),
              SizedBox(height: 16.0),
              Text(
                'Age: ${widget.assistant.age}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline.copyWith(color: Colors.grey[800])
              ),
              (widget.assistant.comp_visits > 2)?
              SizedBox(height: 16.0):SizedBox(height:2),
              (widget.assistant.comp_visits > 2)?Text(
                'Total completed visits: ${widget.assistant.comp_visits}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headline.copyWith(color: Colors.grey[800]),
              ):Container(),
              SizedBox(height: 16.0),
              SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0)),
                    elevation: 1.0,
                    child: Text(
                      'Reviews',
                      style: Theme.of(context)
                          .textTheme
                          .button
                          .copyWith(color: Colors.grey[800]),
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () {
                    },
                  )),
              SizedBox(
                height: 5,
              ),
              SizedBox(
                  width: double.infinity,
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0)),
                    elevation: 1.0,
                    child: Text(
                      'Daily Temperature',
                      style: Theme.of(context)
                          .textTheme
                          .button
                          .copyWith(color: Colors.grey[800]),
                      textAlign: TextAlign.center,
                    ),
                    onPressed: () {
                    },
                  )),
              SizedBox(
                height: 8,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: FlatButton(
                  onPressed: () {
                    HapticFeedback.vibrate();
                    log.debug('DialogAction clicked');
                    Navigator.of(context).pop();
                  },
                  child: Text('Close'),
                ),
              ),
            ],
          ),
        ),
        //...top circular image part,
        Positioned(
          left: UiConstants.padding,
          right: UiConstants.padding,
          child: CircleAvatar(
            //backgroundImage: CachedNetworkImageProvider(widget.assistant.url),
            child: CachedNetworkImage(
                imageUrl: widget.assistant.url,
                imageBuilder: (context, imageProvider) => Container(
                  width: 180.0,
                  height: 180.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                        image: imageProvider, fit: BoxFit.scaleDown),
                  ),
                ),
                placeholder: (context, url) => CircularProgressIndicator(),
                errorWidget: (context, url, error) => Icon(Icons.error)
            ),
            radius: UiConstants.avatarRadius,
          ),
        ),
      ],
    )
    ]);
  }

  Widget _buildRatingWidget(double rating) {
    List<Widget> stars = new List();
    for(int i=0; i<5; i++) {
      if(rating > 1)stars.add(Icon(Icons.star, color: Colors.amber, size: 48.0));
      else if(rating > 0.5) stars.add(Icon(Icons.star_half, color: Colors.amber, size: 48.0));
      else stars.add(Icon(Icons.star_border, color: Colors.amber, size: 48.0));
      rating--;
    }
    return Padding
      (
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      child: Row
        (
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: stars,
      ),
    );
  }
}