
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // SocketIO _socketIO;
  Socket socket;
  List<String> _listMessage;
  double _height, _width;
  TextEditingController _messageController;
  ScrollController _scrollController;

  @override
  void initState() {
    _listMessage = <String>[];
    _messageController = TextEditingController();
    _scrollController = ScrollController();
    connectToServer();
    // _socketIO = SocketIOManager()
    //     .createSocketIO("https://frozen-meadow-52398.herokuapp.com", "/");
    // print('Created');
    // _socketIO.init();
    // print('Initialized');
    // _socketIO.subscribe('receive_message', (jsonData) {
    //   print("subscribed");
    //   Map<String, dynamic> data = json.decode(jsonData);
    //   setState(() {
    //     _listMessage.add(data['message']);
    //   });
    //   _scrollController.animateTo(_scrollController.position.maxScrollExtent,
    //       duration: Duration(
    //         milliseconds: 600,
    //       ),
    //       curve: Curves.ease);
    // });
    // _socketIO.connect();
    super.initState();
  }

  Widget buildSingleMessage(int index) {
    return Container(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(20.0),
        margin: const EdgeInsets.only(bottom: 20.0, left: 20.0),
        decoration: BoxDecoration(
          color: Colors.deepPurple,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Text(
          _listMessage[index],
          style: TextStyle(color: Colors.white, fontSize: 15.0),
        ),
      ),
    );
  }

  Widget buildMessageList() {
    return Container(
      height: _height * 0.8,
      width: _width,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _listMessage.length,
        itemBuilder: (BuildContext context, int index) {
          return buildSingleMessage(index);
        },
      ),
    );
  }

  Widget buildChatInput() {
    return Container(
      width: _width * 0.7,
      padding: const EdgeInsets.all(2.0),
      margin: const EdgeInsets.only(left: 40.0),
      child: TextField(
        decoration: InputDecoration.collapsed(
          hintText: 'Send a message... chat node',
        ),
        controller: _messageController,
      ),
    );
  }

  Widget buildSendButton() {
    return FloatingActionButton(
      backgroundColor: Colors.deepPurple,
      onPressed: () async {
        //Check if the textfield has text or not
        if (_messageController.text.isNotEmpty) {
          //Send the message as JSON data to send_message event
          socket.emit('send_message', {'message': _messageController.text},);
          // socket.on('receive_message', handleMessage);
          // _socketIO
          //     .sendMessage('send_message',
          //         json.encode({'message': _messageController.text}), _onReceiveChatMessage)
          //     .then((value) => print("Sukses Kirim pesan"))
          //     .catchError((error) => log(error.toString()));
          //Add the message to the list
          this.setState(() => _listMessage.add(_messageController.text));
          _messageController.text = '';
          //Scrolldown the list to show the latest message
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 600),
            curve: Curves.ease,
          );
        }
      },
      child: Icon(
        Icons.send,
        size: 30,
      ),
    );
  }

  Widget buildInputArea() {
    return Container(
      height: _height * 0.1,
      width: _width,
      child: Row(
        children: <Widget>[
          buildChatInput(),
          buildSendButton(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _height = MediaQuery.of(context).size.height;
    _width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: _height * 0.1),
            buildMessageList(),
            buildInputArea(),
          ],
        ),
      ),
    );
  }

  void connectToServer() {
    try {
      print("masuk try");
      // Configure socket transports must be sepecified
      socket = io('https://frozen-meadow-52398.herokuapp.com', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });

      // Connect to websocket
      socket.connect();

      // Handle socket events
      socket.on('connect', (_) => print('connect: ${socket.id}'));
      socket.on('receive_message', handleMessage);
      socket.on('disconnect', (_) => print('disconnect'));
      socket.on('fromServer', (_) => print(_));

    } catch (e) {
      print(e.toString());
    }


  }

  // void _onReceiveChatMessage(dynamic message) {
  //   print("Message from UFO: " + message);
  // }

  handleMessage(data) {
      print("subscribed $data");
      // Map<String, dynamic> jsonData = json.decode(data);
      setState(() {
        _listMessage.add(data['message']);
      });
      print(_listMessage);
      _scrollController.animateTo(_scrollController.position.maxScrollExtent,
          duration: Duration(
            milliseconds: 600,
          ),
          curve: Curves.ease);
  }
}
