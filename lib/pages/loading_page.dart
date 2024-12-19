import 'package:compras_jim_25_2/pages/anotation_page.dart';
import 'package:flutter/material.dart';

class LoadingPage extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'Compras Jim',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Compras Jim', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.orange)),
        ),
        body: Container(
          child: Center(          
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute<void>(
                      builder: (context) =>
                          AnotationsPage()));
                  },
                  splashColor: Colors.blue.withOpacity(0.2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/anotaciones.jpg',
                      width: MediaQuery.of(context).size.width,
                      height: (MediaQuery.of(context).size.height - 200) / 2,
                    ),
                  ),
                ),
                Divider(color: Colors.black), 
                InkWell(
                  onTap: () {
                    // ...
                  },
                  splashColor: Colors.blue.withOpacity(0.2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/images/mapa.jpg',
                      width: MediaQuery.of(context).size.width,
                      height: (MediaQuery.of(context).size.height - 200) / 2,
                    ),
                  ),
                ),
              ],
            )
          ),
        ),
    ));
  }


}