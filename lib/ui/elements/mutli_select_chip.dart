import 'package:flutter/material.dart';
import 'package:flutter_app/util/ui_constants.dart';

class MultiSelectChip extends StatefulWidget {
  final List<String> rList;
  final List<String> initSelection;
  final Function(List<String>) onSelectionChanged;
  MultiSelectChip(this.rList, this.initSelection, {this.onSelectionChanged});
  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  List<String> selectedChoices = List();

  // this function will build and return the choice list
  _buildChoiceList() {
    List<Widget> choices = List();
    selectedChoices = widget.initSelection;
    widget.rList.forEach((item) {
      choices.add(Container(
        padding: const EdgeInsets.all(3.0),
        child: ChoiceChip(
//          selectedColor: UiConstants.chipColor,
//          elevation: 1.0,
//          labelStyle: TextStyle(
//            color: UiConstants.accentColor
//          ),
          label: Text(item),
        selected: selectedChoices.contains(item),
        onSelected: (selected) {
          setState(() {
            selectedChoices.contains(item)
                ? selectedChoices.remove(item)
                : selectedChoices.add(item);
            widget.onSelectionChanged(selectedChoices);
          });
        },
      ),
      ));
    });
    return choices;
  }

  @override
  Widget build(BuildContext context) {
    return Transform(alignment: Alignment.center,
      transform: new Matrix4.identity()..scale(1.3),
      child: Wrap(
        children: _buildChoiceList(),
      ),
    );
  }

}