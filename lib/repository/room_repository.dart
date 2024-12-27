//database operations

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eksaminiaia/models/room.dart';
import 'package:flutter/widgets.dart';

import 'package:get/get.dart'; // Required for GetxController

class RoomRepository extends GetxController{ //create,update,...
  static RoomRepository get instance => Get.find();
  final _db = FirebaseFirestore.instance;

  createRoom(Game game) async{
   await _db.collection("Game").add(game.toJson())
    .whenComplete(
      () => Get.snackbar("success", "room created",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Color.fromARGB(0, 29, 29, 182),
      colorText: Color.fromARGB(0, 34, 150, 26),
      
    ));
    
    

  }
}