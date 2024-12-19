import 'dart:io';

import 'package:alarm/alarm.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:compras_jim_25_2/blocs/base_bloc.dart';
import 'package:compras_jim_25_2/blocs/observer.dart';
import 'package:compras_jim_25_2/models/search_text_data.dart';
import 'package:compras_jim_25_2/utils/anotation_utils.dart';
import 'package:compras_jim_25_2/utils/general_utils.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:rxdart/rxdart.dart';

@JsonSerializable()
class AnotationModelResult {

  List<AnotationModel> models;

  AnotationModelResult.create({required this.models});

  factory AnotationModelResult.fromJson(Map<String, dynamic> json) => AnotationModelResult.create(
    models: json['models']==null?[]:(json['models'] as List<Map<String, dynamic>>).map((e) => AnotationModel.fromJson(e)).toList()
  );

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['models'] = models.map((e) => e.toJson()).toList();
    return json;
  }

}



@JsonSerializable()
class AnotationModel {
  final String texto;
  bool completada;
  final DateTime createdDate;
  DateTime? alarmDate;
  bool showItems;
  final List<AnotationItemModel> items;

  AnotationModel({required this.texto, required this.completada, List<AnotationItemModel>? items}):
  createdDate = DateTime.now(),
  items = items ?? [],
  alarmDate = null,
  showItems = false;

  AnotationModel.create({
    required this.texto, 
    required this.completada, 
    required this.createdDate, 
    required this.alarmDate, 
    required this.showItems, 
    required this.items});

  String get key => createdDate.toIso8601String() + '|' + texto;

  factory AnotationModel.fromJson(Map<String, dynamic> json) => AnotationModel.create(
    texto: json['texto'] as String,
    completada: json['completada'] as bool,
    createdDate: DateTime.parse(json['createdDate'] as String),
    alarmDate: json['alarmDate']==null?null:DateTime.parse(json['alarmDate'] as String),
    showItems: false, 
    items: json['items']==null?[]:(json['items'] as List<Map<String, dynamic>>).map((e) => AnotationItemModel.fromJson(e)).toList()
  );

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['texto'] = texto;
    json['completada'] = completada.toString();
    json['createdDate'] = createdDate.toIso8601String();
    json['alarmDate'] = alarmDate?.toIso8601String();
    json['showItems'] = showItems.toString();
    json['items'] = items.map((e) => e.toJson()).toList();
    return json;
  }

}


@JsonSerializable()
class AnotationItemModel {
  final String texto;
  bool completada;
  final DateTime createdDate;

  AnotationItemModel({required this.texto, required this.completada}):
  createdDate = DateTime.now();

  AnotationItemModel.create({
    required this.texto, 
    required this.completada, 
    required this.createdDate
  });

  String get key => createdDate.toIso8601String() + '|' + texto;

  factory AnotationItemModel.fromJson(Map<String, dynamic> json) => AnotationItemModel.create(
    texto: json['texto'] as String,
    completada: json['completada'] as bool,
    createdDate: DateTime.parse(json['createdDate'] as String),
  );

  Map<String, dynamic> toJson() {
    Map<String, dynamic> json = {};
    json['texto'] = texto;
    json['completada'] = completada.toString();
    json['createdDate'] = createdDate.toIso8601String();
    return json;
  }

}



class AnotationsItemBloc extends BaseBloc {
  final BehaviorSubject<bool?> _showDatePickerSubject =  BehaviorSubject.seeded(false);

  Stream<bool?> get outShowDatePicker => _showDatePickerSubject.stream;

  DateTime? datePickerConfirm;

  void updateShowDatePicker({required bool value}){
    _showDatePickerSubject.sink.add(value);
  }

  @override
  void dispose() {
    _showDatePickerSubject.close();
  }
}


class AnotationsBloc extends BaseBloc {

  final BehaviorSubject<List<AnotationModel>?> _anotationSubject = BehaviorSubject();
  final BehaviorSubject<bool?> _showSearchSubject =  BehaviorSubject.seeded(false);
  final BehaviorSubject<SearchTextData?> _textSearchSubject =  BehaviorSubject.seeded(SearchTextData(textSearch: '', clearData: false));
  final BehaviorSubject<String> _audioAlarmSubject = BehaviorSubject.seeded('assets/predator.mp3');
  //final BehaviorSubject<bool> _flagManualAnotations = BehaviorSubject.seeded(MapExtraData.profileData?.flagManualAnotations ?? false);
  

  Stream<List<AnotationModel>?> get outAnotation => _anotationSubject.stream;
  Stream<SearchTextData?> get outTextSearch => _textSearchSubject.stream;
  Stream<bool?> get outShowSearch => _showSearchSubject.stream;
  Stream<String> get outAudioAlarm => _audioAlarmSubject.stream;
  //Stream<bool> get outFlagManualAnotations => _flagManualAnotations.stream;

  final List<AnotationsItemBloc> itemBlocList = [];

  //bool get flagManualAnotations => _flagManualAnotations.value;

  void updateAudioAlarm(String event){
    _audioAlarmSubject.sink.add(event);
  }

  /*void updateFlagManualAnotations(bool event){
    _flagManualAnotations.sink.add(event);
  }*/

  AnotationsItemBloc buildItemBloc(){
    AnotationsItemBloc newItemBloc = AnotationsItemBloc();
    itemBlocList.add(newItemBloc);
    return newItemBloc;
  }

  void updateAnotations(List<AnotationModel> event) async{
    for (AnotationsItemBloc itembloc in itemBlocList){
      itembloc.dispose();
    }
    await AnotationUtils.saveFile(data: event, add: false);
    _anotationSubject.sink.add(event);
  }

  void removeAnotation(AnotationModel anotation){
    List<AnotationModel> aux = _anotationSubject.value ?? [];
    aux.remove(anotation);
    updateAnotations(aux);
  }

  void removeAnotationItem(AnotationModel anotation, AnotationItemModel anotationItem){
    List<AnotationModel> aux = _anotationSubject.value ?? [];
    List<AnotationItemModel> itemsAux = List<AnotationItemModel>.from(aux[aux.indexOf(anotation)].items);
    aux[aux.indexOf(anotation)].items.clear();
    for (AnotationItemModel auxItem in itemsAux){
      if (auxItem.key.compareTo(anotationItem.key) != 0){
        aux[aux.indexOf(anotation)].items.add(auxItem);
      }
    }
    updateAnotations(aux);
  }

  void completeAnotationItem(AnotationModel anotation, AnotationItemModel anotationItem, {bool value = true}){
    List<AnotationModel> aux = _anotationSubject.value ?? [];
    aux[aux.indexOf(anotation)].items[aux[aux.indexOf(anotation)].items.indexOf(anotationItem)].completada = value;
    bool isCompleted = true;
    for (AnotationItemModel itemAux in aux[aux.indexOf(anotation)].items){
      if (!itemAux.completada){
        isCompleted = false;
      }
    }
    aux[aux.indexOf(anotation)].completada = isCompleted;
    updateAnotations(aux);
  }

  void addDataItem(AnotationModel anotation, AnotationItemModel anotationItem, {bool priority = true}) {
    List<AnotationModel> aux = _anotationSubject.value ?? [];
    List<AnotationItemModel> itemsAux = List<AnotationItemModel>.from(aux[aux.indexOf(anotation)].items);
    aux[aux.indexOf(anotation)].items.clear();
    if (priority){
      aux[aux.indexOf(anotation)].items.add(anotationItem);
    }
    aux[aux.indexOf(anotation)].items.addAll(itemsAux);
    if (!priority){
      aux[aux.indexOf(anotation)].items.add(anotationItem);
    }
    updateAnotations(aux);
  }

  void completeAnotation(AnotationModel anotation, {bool value = true}){
    List<AnotationModel> aux = _anotationSubject.value ?? [];
    aux[aux.indexOf(anotation)].completada = value;
    for (AnotationItemModel itemAux in aux[aux.indexOf(anotation)].items){
      itemAux.completada = value;
    }
    updateAnotations(aux);
  }

  void sortAnotations(){
    List<AnotationModel> aux = _anotationSubject.value ?? [];
    aux.sort((a, b) {
      if (a.alarmDate == null && b.alarmDate == null){
        return 0;
      }
      if (a.alarmDate == null && b.alarmDate != null){
        return 1;
      }
      if (a.alarmDate != null && b.alarmDate == null){
        return -1;
      }
      return a.alarmDate!.compareTo(b.alarmDate!);
    });
    updateAnotations(aux);
  }

  void updateShowItems(AnotationModel anotation, {required bool showItems}){
    List<AnotationModel> aux = _anotationSubject.value ?? [];
    aux[aux.indexOf(anotation)].showItems = showItems;
    updateAnotations(aux);
  }

  void alarmAnotation(AnotationModel anotation, DateTime alarm){
    List<AnotationModel> aux = _anotationSubject.value ?? [];
    aux[aux.indexOf(anotation)].alarmDate = alarm;
    updateAnotations(aux);
  }

  Future<int> addData(List<AnotationModel> datas, {bool replace = true, bool priority = true}) async {
    if (_anotationSubject.hasValue && _anotationSubject.value != null && _anotationSubject.value!.isNotEmpty){
      List<AnotationModel> dataAux2 = [];
      List<AnotationModel> dataAux3 = [];
      List<AnotationModel> dataAux = List<AnotationModel>.from(_anotationSubject.value!);
      int news = 0;
      for (AnotationModel dataIn in datas){
        dataAux2.add(dataIn);
        news++;
      }   
      if (priority){
        dataAux3.addAll(dataAux2);
        dataAux3.addAll(dataAux);
      }else{
        dataAux3.addAll(dataAux);
        dataAux3.addAll(dataAux2);        
      }
      updateAnotations(dataAux3);
      return news;
    }else{
      updateAnotations(datas);
      return datas.length;
    }   
  }


  void updateTextSearch(SearchTextData event){
    _textSearchSubject.sink.add(event);
  }

  void changueShowSearch(bool event){
    _showSearchSubject.sink.add(event);
  }

  void deleteData() async {
    _anotationSubject.sink.add([]);  
  }

  void loadData() async {
    List<AnotationModel> data = await AnotationUtils.readFileLikeData();
    _anotationSubject.sink.add(data);
  }

  @override
  void dispose() {
    _anotationSubject.close();
    _showSearchSubject.close();
    _textSearchSubject.close();
  }


}

class AnotationsPageData {

  final AnotationsBloc bloc = AnotationsBloc();
  final TextEditingController textSearchController = TextEditingController(text: '');


  AnotationsPageData.init();

}

class AnotationsPage extends StatelessWidget {
  
  final AnotationsPageData _modelData;

  AnotationsPage():
  _modelData = AnotationsPageData.init();

  @override
  Widget build(BuildContext context) {
    _modelData.bloc.loadData(); //TODO: DESCOMENTAR
    /*_modelData.bloc.updateAnotations([
      AnotationModel(texto: 'holafasfsdafsdafafdas holafasfsdafsdafafdas holafasfsdafsdafafdas holafasfsdafsdafafdas holafasfsdafsdafafdasholafasfsdafsdafafdasholafasfsdafsdafafdas holafasfsdafsdafafdas', completada: false),
      AnotationModel(texto: 'tereraew', 
        items: [
          AnotationItemModel(texto: 'subnata 1', completada: false),
          AnotationItemModel(texto: 'subnata 2', completada: false),
        ],
        completada: false),
      AnotationModel(texto: 'holafasfsdafsdafafdas holafasfsdafsdafafdas holafasfsdafsdafafdas holafasfsdafsdafafdas holafasfsdafsdafafdasholafasfsdafsdafafdasholafasfsdafsdafafdas holafasfsdafsdafafdas', completada: false),

    ]);*/
    return MaterialApp(
      theme: ThemeData(
        //primarySwatch: GeneralUtils.devProfileMaterialColor(context),
        dialogBackgroundColor: Colors.white,        
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
      appBar: AppBar(
        title: Observer<bool?>(
          stream: _modelData.bloc.outShowSearch, 
          onSuccess: (context, showSearch) {
            if (showSearch!){
              FocusNode focusNode = FocusNode();
              TextField textField = TextField(
                focusNode: focusNode,
                cursorColor: Theme.of(context).dialogBackgroundColor,
                controller: _modelData.textSearchController,
                style: TextStyle(
                  fontSize: 18.0, 
                  fontWeight: FontWeight.bold, 
                  color: Theme.of(context).dialogBackgroundColor, 
                )
              );
              focusNode.requestFocus();
              _modelData.textSearchController.selection = TextSelection.collapsed(offset: _modelData.textSearchController.text.length);
              return textField;
            }else{
              return Tooltip(
                message: _modelData.textSearchController.text.trim().isEmpty?'Sin Filtros':_modelData.textSearchController.text,
                child: Text('Anotaciones', style: GoogleFonts.getFont('Concert One').merge(TextStyle(fontSize: 26, color: Theme.of(context).dialogBackgroundColor))),
              );
            }
          },),
        actions: [
          Observer<bool?>(
            stream: _modelData.bloc.outShowSearch, 
            onSuccess: (context, showSearch) {
              if (showSearch!){
                return Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        AnotationUtils.onSearchCheck(logic: _modelData, text: _modelData.textSearchController.text);
                      }, 
                      icon: Icon(Icons.check, color: Theme.of(context).dialogBackgroundColor)),
                    IconButton(
                      onPressed: () {
                        AnotationUtils.onSearchDelete(logic: _modelData);
                      }, 
                      icon: Icon(Icons.delete_outline, color: Theme.of(context).dialogBackgroundColor)),
                  ],
                );
              }else{
                List<Widget> buttons = [];
                if (_modelData.textSearchController.text.trim().isNotEmpty){
                  buttons.add(IconButton(
                    onPressed: () {
                      _modelData.bloc.changueShowSearch(true);
                    }, 
                    icon: Icon(Icons.saved_search, color: Theme.of(context).dialogBackgroundColor)));
                  buttons.add(
                    IconButton(
                      onPressed: () {
                        AnotationUtils.onSearchDelete(logic: _modelData);
                      }, 
                      icon: Icon(Icons.delete_outline, color: Theme.of(context).dialogBackgroundColor)),
                  );
                }else{
                  buttons.add(IconButton(
                    onPressed: () {
                      _modelData.bloc.changueShowSearch(true);
                    }, 
                    icon: Icon(Icons.search, color: Theme.of(context).dialogBackgroundColor))
                  );
                }
                return Row(
                  children: buttons
                );
              }
            }
          ),
          /*AnotationUtils.buildMenuOptions(context,
            showUbication: true, 
            bloc: _modelData.bloc
          )*/
        ],
      ),
      body: Observer<Map<String,dynamic>?>(
        stream: CombineLatestStream.combine2(_modelData.bloc.outAnotation, _modelData.bloc.outTextSearch, (a, b) {
          if (a == null){
            return null;
          }
          return {'anotationData':a,'anotation_text_search':b};
        }).shareReplay(),
        onSuccess: (observerContext, Map<String,dynamic>? dataMap) {
          List<AnotationModel> anotations = dataMap!['anotationData'];
          SearchTextData? textSearch = dataMap['anotation_text_search'];
          List<AnotationModel> finalAnotations = AnotationUtils.filterForTextSearch(inData: anotations, textSearch: textSearch?.textSearch ?? '', clearData: textSearch?.clearData ?? false);
          if (finalAnotations.isNotEmpty) {
            List<AnotationModel> originalAnotations = List<AnotationModel>.from(finalAnotations);
            return Container(
              //color: HSVColor.fromColor(GeneralUtils.devMainColor(context)).withAlpha(0.5).toColor(), 
              child: ReorderableListView(              
                onReorder: (oldIndex, newIndex) {
                  if (textSearch?.textSearch.trim().isEmpty ?? true){
                    int newIndexAux = newIndex;
                    if (oldIndex < newIndex){
                      newIndexAux = newIndexAux - 1;
                    }
                    final anotacionMovida = originalAnotations.removeAt(oldIndex);
                    originalAnotations.insert(newIndexAux, anotacionMovida);
                    _modelData.bloc.updateAnotations(originalAnotations);
                  }
                },
                children: finalAnotations.map((AnotationModel anotation) {
                  AnotationsItemBloc itemBloc = _modelData.bloc.buildItemBloc();
                  List<Widget> items = [];
                  if (anotation.showItems){
                    for (AnotationItemModel item in anotation.items){
                      items.add(
                        Dismissible(
                          key: Key(anotation.key + '|||' + item.key),
                          onDismissed: (direction) {
                            _modelData.bloc.removeAnotationItem(anotation, item);
                          },
                          child: Card(
                            margin: EdgeInsets.only(top: 1.5, left: 15, right: 15),                         
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(       
                              leading: IconButton(
                                onPressed: () {
                                  _modelData.bloc.completeAnotationItem(anotation, item, value: !item.completada);
                                }, 
                                icon: Icon(item.completada?Icons.check_box:Icons.check_box_outline_blank, color: GeneralUtils.devMainColor(context),)
                              ),
                              title: Text(
                                item.texto,
                                maxLines: null, 
                                overflow: TextOverflow.visible, 
                                style: GoogleFonts.getFont('Architects Daughter').merge(TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                              )
                            )),                   
                          
                        )
                      );
                    }
                  }
                  return Dismissible(
                    key: Key(anotation.key),
                    onDismissed: (direction) {
                      _modelData.bloc.removeAnotation(anotation);
                    },
                    child: Column(
                      children: [
                        Card(
                          margin: EdgeInsets.only(top: 5, left: 10, right: 10),
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(top: 4, left: 4, right: 4),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(0),            
                              leading: IconButton(
                                onPressed: () {
                                  _modelData.bloc.completeAnotation(anotation, value: !anotation.completada);
                                }, 
                                icon: Icon(anotation.completada?
                                    anotation.items.length==0?Icons.check_box:Icons.library_add_check:
                                    anotation.items.length==0?Icons.check_box_outline_blank:Icons.filter_none, 
                                  color: GeneralUtils.devMainColor(context),)
                              ),
                              title: InkWell(
                                onDoubleTap: () {
                                  _modelData.bloc.updateShowItems(anotation, showItems: !anotation.showItems);
                                },
                                child: Text(
                                  anotation.texto,
                                  maxLines: null, 
                                  overflow: TextOverflow.visible, 
                                  style: GoogleFonts.getFont('Architects Daughter').merge(TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                                )
                              ),                   
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () async{
                                      itemBloc.updateShowDatePicker(value: true);
                                      List<DateTime?>? results = await showCalendarDatePicker2Dialog(
                                        context: context,                               
                                        config: CalendarDatePicker2WithActionButtonsConfig(),
                                        dialogSize: const Size(325, 400),
                                        value: [anotation.alarmDate ?? DateTime.now()],
                                        borderRadius: BorderRadius.circular(15),
                                      );                                    
                                      itemBloc.datePickerConfirm = results?.first;
                                      if (itemBloc.datePickerConfirm != null){                                      
                                        TimeOfDay? alarmTime = await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                          cancelText: 'Omitir',
                                          confirmText: 'Alarmar'
                                        );
                                        if (alarmTime != null){
                                          String alarmAudio = await showDialog(
                                            barrierDismissible: false,
                                            context: context,
                                            builder: (BuildContext context) {
                                              return Observer<String>(
                                                stream: _modelData.bloc.outAudioAlarm, 
                                                onSuccess: (context, data) {
                                                  return AlertDialog(
                                                    title: Text('Audio Alarma'),
                                                    content: Row(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        DropdownButton(
                                                          value: data,
                                                          items: [
                                                            DropdownMenuItem<String>(
                                                              value: 'assets/rings/predator.mp3',
                                                              child: Row(children: [Image.asset('assets/images/predator.png', height: 15, width: 15,), SizedBox(width: 10,), Text('Depredador')]),
                                                            ),
                                                            DropdownMenuItem<String>(
                                                              value: 'assets/rings/matrix.mp3',
                                                              child: Row(children: [Image.asset('assets/images/matrix.png', height: 15, width: 15), SizedBox(width: 10,), Text('Matrix')]),
                                                            ),
                                                            DropdownMenuItem<String>(
                                                              value: 'assets/rings/terminator.mp3',
                                                              child: Row(children: [Image.asset('assets/images/terminator.jpg', height: 15, width: 15), SizedBox(width: 10,), Text('Terminator')]),
                                                            ),
                                                            DropdownMenuItem<String>(
                                                              value: 'assets/rings/real_men.mp3',
                                                              child: Row(children: [Image.asset('assets/images/mitski.jpg', height: 15, width: 15), SizedBox(width: 10,), Text('Mitski')]),
                                                            )
                                                          ],
                                                          onChanged: (value) {
                                                            if (value != null){
                                                              _modelData.bloc.updateAudioAlarm(value);
                                                            }                                                      
                                                          },
                                                        )
                                                      ],
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(context, data!); 
                                                        },
                                                        child: Text('Ok'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            }
                                          );
                                          final id = DateTime.now().millisecondsSinceEpoch % 10000 + 1;
                                          final alarmSettings = AlarmSettings(
                                            id: id,
                                            dateTime: DateTime(
                                              itemBloc.datePickerConfirm!.year,
                                              itemBloc.datePickerConfirm!.month,
                                              itemBloc.datePickerConfirm!.day,
                                              alarmTime.hour,
                                              alarmTime.minute
                                            ),
                                            loopAudio: true,
                                            vibrate: true,
                                            assetAudioPath: alarmAudio,
                                            notificationTitle: 'Business JIM 25',
                                            notificationBody: anotation.texto,
                                            stopOnNotificationOpen: true,
                                            enableNotificationOnKill: Platform.isIOS,
                                          );
                                          await Alarm.set(alarmSettings: alarmSettings);
                                        } 
                                        _modelData.bloc.alarmAnotation(anotation, itemBloc.datePickerConfirm!);
                                        //GeneralUtils.scheduleAlarm(itemBloc.datePickerConfirm!);
                                      }else{
                                        itemBloc.updateShowDatePicker(value: false);
                                      }       
                                    },                     
                                    icon: Observer<bool?>(
                                      stream: itemBloc.outShowDatePicker, 
                                      onSuccess: (context, data) {
                                        Widget iconChild = Icon(Icons.alarm, color: GeneralUtils.devMainColor(context), size: 25);
                                        if (!data!){
                                          iconChild = Opacity(
                                            opacity: 0.25, 
                                            child: Icon(Icons.alarm_off, color: GeneralUtils.devMainColor(context), size: 15));
                                        }
                                        if (anotation.alarmDate != null){
                                          int dayDiff = GeneralUtils.devDateDifference(DateTime.now(), anotation.alarmDate!);
                                          String mssToolTip = DateFormat('EEEE dd  MMMM', 'es_AR').format(anotation.alarmDate!); 
                                          if (dayDiff == 0){
                                            mssToolTip = 'Hoy!';
                                            iconChild = Icon(Icons.hourglass_bottom, color: Colors.red, size: 35,);
                                            if (!data){
                                              iconChild = Icon(Icons.hourglass_bottom, color: Colors.red, size: 30);
                                            }
                                          }
                                          if (dayDiff == -1){
                                            mssToolTip = 'Mañana!';
                                            iconChild = Icon(Icons.hourglass_top, color: Color.fromARGB(255, 244, 220, 1), size: 33,);
                                            if (!data){
                                              iconChild = Icon(Icons.hourglass_top, color: Color.fromARGB(255, 244, 220, 1), size: 27);
                                            }
                                          }
                                          if (dayDiff < -1 && dayDiff >= -3){
                                            mssToolTip = 'Faltan ' + (dayDiff * -1).toString() + ' días (' + mssToolTip + ')' ;
                                            iconChild = Icon(Icons.hourglass_top, color: Colors.green, size: 33,);
                                            if (!data){
                                              iconChild = Icon(Icons.hourglass_top, color: Colors.green, size: 27);
                                            }
                                          }
                                          if (dayDiff < -3){
                                            mssToolTip = 'Faltan ' + (dayDiff * -1).toString() + ' días (' + mssToolTip + ')' ;
                                            iconChild = Icon(Icons.alarm, color: GeneralUtils.devMainColor(context), size: 25,);
                                            if (!data){
                                              iconChild = Icon(Icons.alarm, color: GeneralUtils.devMainColor(context), size: 15);
                                            }
                                          }
                                          if (dayDiff > 0){
                                            mssToolTip = 'Vencido! (' + mssToolTip + ')';
                                            iconChild = Icon(Icons.hourglass_disabled, color: Colors.red, size: 25,);
                                            if (!data){
                                              iconChild = Icon(Icons.hourglass_disabled, color: Colors.red, size: 15);
                                            }
                                          }
                                          return Tooltip(message: mssToolTip, child: iconChild);
                                        }else{
                                          return iconChild;
                                        }
                                        
                                      },
                                    )                      
                                  ),
                                  IconButton(
                                    iconSize: 16,
                                    icon: Icon(Icons.playlist_add, color: GeneralUtils.devMainColor(context), size: 20),
                                    onPressed: () async {
                                      String? anotationText = await GeneralUtils.showTextField(context, label: 'SubAnotación');
                                      if (anotationText != null){
                                        _modelData.bloc.addDataItem(anotation, AnotationItemModel(
                                          texto: GeneralUtils.capitalizeFirstLetter(anotationText),
                                          completada: false
                                        ), priority: true);
                                      }
                                    },
                                  ),
                                ],
                              )
                            ),
                          ),
                        ),
                        anotation.showItems?
                          Column(
                            children: items,
                          ):
                          SizedBox.shrink()
                      ],
                    )                 

                  );
                }).toList(),
              ));
          }else{
            return Center(child: Padding(padding: EdgeInsets.all(20), child: Text('Ingresa tus anotaciones por voz :D', 
              textAlign: TextAlign.center,
              style: 
                GoogleFonts.getFont('Permanent Marker').merge(TextStyle(fontSize: 32, fontWeight: FontWeight.normal, color: GeneralUtils.devMainColor(context)))
            )));
          }          
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          //bool isMicEnabled = !_modelData.bloc.flagManualAnotations;
          String? anotationText = await GeneralUtils.showTextField(context, label: 'Anotación');
          if (anotationText != null){
            _modelData.bloc.addData([AnotationModel(
              texto: GeneralUtils.capitalizeFirstLetter(anotationText),
              completada: false
            )], replace: false, priority: true); 
          }
        },
        child: Icon(Icons.edit, color: Theme.of(context).dialogBackgroundColor, size: 24,)  
         
      ),
    ));

  }
}