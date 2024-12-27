import 'package:eksaminiaia/models/room.dart';
import 'package:eksaminiaia/repository/room_repository.dart';
import 'package:flutter/material.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class JoinController extends GetxController{
  static JoinController get instance =>Get.find(); // searches for an existing instance of JoinController in GetX's dependency tree.

  final room = TextEditingController(); //iput to field
  final numofteams = TextEditingController();
  
  
  final gameRepo = Get.put(RoomRepository());
 
 Future <void> createRoom(Game game) async {
  await gameRepo.createRoom(game);}

 }