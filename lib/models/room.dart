//import 'package:cloud_firestore/cloud_firestore.dart';

class Game{
 final String? id;
 final int numofteams;
 final int room;

 const Game({
  this.id,
  required this.numofteams,
  required this.room,

 }

 );
  //gia save

  toJson(){
    return{
      "room" : room,
      "numofteams" :numofteams,
    };
  }
}
  
