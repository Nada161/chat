import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _fireStore = FirebaseFirestore.instance;
late User sigIndUser;

class ChatScreen extends StatefulWidget {
  static const String screenRoute = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageController = TextEditingController();
  final _auth=FirebaseAuth.instance;
  String? messageText;
  void getCurrentUser(){
    try{
      final user = _auth.currentUser;
      if(user!=null){
        sigIndUser=user;
      }
    }catch(e){
      print(e);
    }

}
  @override
  void initState(){
    super.initState();
    getCurrentUser();
  }

  void messagesStream()async{
    await for(var snapshot in _fireStore.collection('messeges').snapshots()){
      for(var message in snapshot.docs){
        print(message.data());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.yellow[900],
        title: Row(
          children: [
            Image.asset('images/logo.png', height: 25),
            SizedBox(width: 10),
            Text('MessageMe')
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
           _auth.signOut();
           Navigator.pop(context);
            },
            icon: Icon(Icons.close),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MessageStreamBuilder(),
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.orange,
                    width: 2,
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      onChanged: (value) {
                        messageText=value;
                      },
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 20,
                        ),
                        hintText: 'Write your message here...',
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      messageController.clear();
                      _fireStore.collection('messeges').add(
                        {
                          'text': messageText,
                          'email': sigIndUser.email,
                          'time': FieldValue.serverTimestamp()
                        }
                      );
                    },
                    child: Text(
                      'send',
                      style: TextStyle(
                        color: Colors.blue[800],
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
    
  }
}
class MessageLine extends StatelessWidget {

  String? sender;
  String? text;
  bool isMe;

  MessageLine({this.text,this.sender, required this.isMe ,Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment:
        isMe? CrossAxisAlignment.end: CrossAxisAlignment.start,
        children: [
          Text('$sender',
            style:TextStyle(
              fontSize: 12,
              color: Colors.yellow[900]
            ) ,),
          Material(
            elevation: 5,
            borderRadius: isMe? BorderRadius.only(
              topLeft: Radius.circular(30),
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ):BorderRadius.only(
              topRight: Radius.circular(30),
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
              color: isMe? Colors.blue[800] : Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 10),
                child: Text('$text',
                style: TextStyle(
                  fontSize: 15,
                  color: isMe? Colors.white: Colors.black45
                ),
                ),
              )

          ),
        ],
      ),
    );
  }
}
class MessageStreamBuilder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _fireStore.collection('messeges').orderBy('time').snapshots(),
        builder: (context,snapshot){
          List <MessageLine> messagesWidgets=[];
          if(!snapshot.hasData){
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.blue,
              ),
            );
          }
          final messages = snapshot.data!.docs.reversed;
          for(var message in messages){
            final messageText =message.get('text');
            final messageEmail =message.get('email');
            final currentUser = sigIndUser.email;
            final messageWidget = MessageLine(
              isMe: currentUser==messageEmail,
              sender: messageEmail,
              text: messageText,);
            messagesWidgets.add(messageWidget);

          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(horizontal:10,vertical: 20 ),
              children: messagesWidgets,
            ),
          );
        }
    );
  }
}


