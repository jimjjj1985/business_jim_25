
import 'dart:convert';
import 'dart:io';

import 'package:compras_jim_25_2/models/search_text_data.dart';
import 'package:compras_jim_25_2/pages/anotation_page.dart';
import 'package:compras_jim_25_2/settings/global_settings.dart';
import 'package:compras_jim_25_2/utils/general_utils.dart';
import 'package:path_provider/path_provider.dart';

class AnotationUtils {

  static Future<bool> saveFile({required List<AnotationModel> data, bool add = false}) async {
    final directory = await getApplicationDocumentsDirectory();
    File file = File(directory.path + '/' + GlobalSettings.fileNameAnotations);
    AnotationModelResult modelsNew = AnotationModelResult.create(models: []);
    if (file.existsSync() && add){
      String contentOld = await file.readAsString();
      if (contentOld.isNotEmpty){
        modelsNew = AnotationModelResult.fromJson(jsonDecode(contentOld));
      }
    }
    modelsNew.models.addAll(data);
    await file.open(mode: FileMode.write);
    await file.writeAsString(jsonEncode(modelsNew.toJson()));
    return Future.value(true);
  }

  static void onSearchDelete({required AnotationsPageData logic}){
    logic.textSearchController.text = '';
    logic.bloc.updateTextSearch(SearchTextData(textSearch: '', clearData: true));
    logic.bloc.changueShowSearch(false);
  }

  static void onSearchCheck({required AnotationsPageData logic, required String text}){
    if (text.trim().isNotEmpty){
      logic.textSearchController.text = text;
      logic.bloc.updateTextSearch(SearchTextData(textSearch: GeneralUtils.clearText(text), clearData: false));
      logic.bloc.changueShowSearch(false);
    }
  }

  static List<AnotationModel> filterForTextSearch({required List<AnotationModel> inData, required String textSearch, required bool clearData}){
    List<AnotationModel> aux = [];
    if (textSearch.trim().isNotEmpty){
      List<String> searches = textSearch.trim().toLowerCase().split(',');
      List<String> finalSearches = [];
      for (String element in searches) {
        if (element.trim().isNotEmpty){
          finalSearches.add(element);
        }
      }
      for (AnotationModel element in inData) {
        int foundQty = 0;
        for (String search in finalSearches){
          bool found = false;
          if (element.texto.trim().toLowerCase().contains(search)){
            found = true;
          }
          if (found){
            foundQty++;
          }
        }
        if (foundQty == finalSearches.length){
          aux.add(element);
        }
      }
    } else{
      aux = inData;
    }
    return aux;
  }

  static Future<List<AnotationModel>> readFileLikeData({String? path}) async {
    AnotationModelResult modelResult = AnotationModelResult.create(models: []);
    String? finalPath = path;
    if (finalPath == null){
       final directory = await getApplicationDocumentsDirectory();
       finalPath = directory.path + '/' + GlobalSettings.fileNameAnotations;
    }
    File file = File(finalPath);
    if (file.existsSync()){
      String content = await file.readAsString();
      modelResult = AnotationModelResult.fromJson(jsonDecode(content));
    }
    return Future.value(modelResult.models);   
  }
}