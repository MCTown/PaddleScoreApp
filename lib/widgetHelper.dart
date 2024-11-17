import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class WidgetHelper {
  static Widget buildLoading() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  static Widget createDropdownButton(String title, List<String> options,
      String selectedValue, Function(String?) onChanged) {
    return SizedBox(
      width:230,
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 15),
          Expanded(
              child: DropdownButtonFormField<String>(
                value: selectedValue,
                items: options.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: onChanged,
                decoration: InputDecoration(
                  // fillColor: Theme.of(context).primaryColor,
                  filled: true,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  // contentPadding: EdgeInsets.symmetric(horizontal: 10),
                ),
              ),)

        ],
      ),
    );
  }
}
