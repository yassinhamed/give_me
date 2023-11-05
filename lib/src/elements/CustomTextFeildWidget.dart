import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:string_validator/string_validator.dart';

import '../repository/user_repository.dart';

class CustomTextField extends StatelessWidget {
  const CustomTextField(
      {Key key, this.title, this.onSave, this.activeSuffix = false})
      : super(key: key);
  final String title;
  final void Function(String value) onSave;
  final bool activeSuffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: TextFormField(
        onSaved: onSave,
        validator: activeSuffix ? priceValidation : validation,
        style: Theme.of(context).textTheme.subtitle1,
        textAlignVertical: TextAlignVertical.top,
        cursorHeight: 30,
        decoration: InputDecoration(
            suffix: Text(activeSuffix ? 'جنيه' : ''),
            labelText: title,
            labelStyle:
                Theme.of(context).textTheme.subtitle1.copyWith(fontSize: 20),
            enabledBorder: OutlineInputBorder(),
            focusColor: Colors.deepOrangeAccent,
            hoverColor: Colors.deepOrangeAccent,
            border: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).accentColor)),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).accentColor)),
            constraints: BoxConstraints(minHeight: 10)),
      ),
    );
  }

  String priceValidation(String value) {
    if (value == null || value.isEmpty) {
      return 'هذا الحقل مطلوب';
    } else if (!isNumeric(value)) {
      return 'أدخل قيمة رقمية فقط';
    }
    return null;
  }

  String validation(String value) {
    if (value == null || value.isEmpty) return 'هذا الحقل مطلوب';
    return null;
  }
}
