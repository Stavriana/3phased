//import 'package:cloud_firestore/cloud_firestore.dart';

class Game{
 final String? id; //4digit code
 final int numofteams;
 final int numofplayers;

 const Game({
  this.id,
  required this.numofteams,
  required this.numofplayers,

 }

 );
  //gia save

  toJson(){
    return{
      "numofplayers" : numofplayers,
      "numofteams" :numofteams,
    };
  }
}
  
