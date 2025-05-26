
import 'package:flutter/material.dart';


class ThanhtoanScreen extends StatefulWidget{
  const ThanhtoanScreen( {super.key, required this.title, required this.sotien});
  final String title;
  final String sotien;
  @override
  State<StatefulWidget> createState() => _ThanhtoanScreen();

}

class _ThanhtoanScreen extends State<ThanhtoanScreen>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
      color: Color(0xFFFAFBF3),
        child: create_thanhtoan(),
      ),
    );
  }

  Widget create_thanhtoan(){
    return Padding(padding: EdgeInsets.all(10),
    child: 
    Center(
      child: 
      Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/qrthanhtoan.jpg',
          height: 300,
          fit: BoxFit.contain,
        ),
        SizedBox(height: 20,),
        Text("Le Dai Hiep", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        SizedBox(height: 20,),
        Text("So tien: ${widget.sotien}",style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),

        SizedBox(height: 20,),
        ElevatedButton(onPressed: () {
          Navigator.pop(context);
        }, child: Text("Xong")),
      
      ],
      
    ),
    
    ),
    );
  }

}