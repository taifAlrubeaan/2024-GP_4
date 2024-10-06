import 'package:flutter/material.dart';

class ChoiceChipWidget extends StatefulWidget {
  final List<String> choices;
  final Function changeSelected;
  final int initialSelected;
  final Size? buttonSize;
  final Color? unselectedColor;
  final Color? selectedColor;

  const ChoiceChipWidget({
    super.key,
    required this.choices,
    required this.changeSelected,
    required this.initialSelected, this.buttonSize, this.unselectedColor, this.selectedColor,
  });

  @override
  ChoiceChipWidgetState createState() => ChoiceChipWidgetState();
}

class ChoiceChipWidgetState extends State<ChoiceChipWidget> {
  late int _selectedChoice;

  @override
  void initState() {
    super.initState();
    _selectedChoice = widget.initialSelected;
  }

  @override
  Widget build(BuildContext context) {
    List<String> choices = widget.choices;
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: choices.map((choice) {
        int index = choices.indexOf(choice);
        return ChoiceChip(
          label: Container(
            alignment: Alignment.center,
            width: widget.buttonSize?.width?? 60,
            height: widget.buttonSize?.height,
            child: Text(choice, textAlign: TextAlign.center),
          ),
          
          selected: _selectedChoice == index,
          selectedColor: widget.selectedColor,
          // labelStyle: Get.textTheme.bodyMedium!.copyWith(
          //   color: _selectedChoice == index ? Colors.white : Colors.black,
          // ),
          // checkmarkColor: Colors.white,
          backgroundColor: widget.unselectedColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          onSelected: (bool selected) {
            if (selected) {
              setState(() {
                print(":::::::::::::::::::selected $index");
                _selectedChoice = index;
                widget.changeSelected(_selectedChoice);
              });
            }
          },
        );
      }).toList(),
    );
  }
}
