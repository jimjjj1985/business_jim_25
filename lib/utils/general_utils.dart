import 'package:compras_jim_25_2/settings/global_settings.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GeneralUtils {

  static Future<String?> showTextField(BuildContext context, {required String label}) async {
    return await showDialog(
      barrierDismissible: false,
      useSafeArea: true,
      context: context,
      builder: (context) {
        TextEditingController textController = TextEditingController();
        return AlertDialog(
          content: SingleChildScrollView( 
            child: Column(
              children: [
                TextField(
                  controller: textController,
                  decoration: InputDecoration(
                    labelText: label,
                  ),
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text("Cancelar"),
            ),
            IconButton(
              iconSize: 16,
              onPressed: () {
                if (textController.text.trim().isNotEmpty){
                  Navigator.of(context).pop(textController.text.trim());
                }else{
                  Navigator.of(context).pop(null);
                }
              },
              icon: Icon(Icons.save, color: Colors.green,),
            )
          ],
        );                
      }
    );
  }

  static String capitalizeFirstLetter(String text) {
    if (text.isEmpty) {
      return '';
    }
    return text[0].toUpperCase() + text.substring(1);
  }

  static Color devMainColor(BuildContext context) => Theme.of(context).primaryColor;

  static String removeAccents(String text) {
    return text.toLowerCase().replaceAll('á','a').replaceAll('é', 'e').
      replaceAll('í', 'i').replaceAll('ó', 'o').replaceAll('ú', 'u');
  }

  static String clearText(String text, {bool removeSpaces = false}){
    String aux = removeAccents(text.toLowerCase()).trim();
    if (removeSpaces){
      //TODO:
    }
    return aux;
  }

  static DateTime? justDate({required DateTime? time}){
    if (time != null){
      return DateTime.parse(DateFormat(GlobalSettings.dateFormat).format(time));
    }
    return null;    
  }

  static int devDateDifference(DateTime one, DateTime two){
    return GeneralUtils.justDate(time: one)!.difference(GeneralUtils.justDate(time:two)!).inDays;
  }
}