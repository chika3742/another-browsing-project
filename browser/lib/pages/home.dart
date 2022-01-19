import 'package:another_browser/parser/parser.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: SizedBox(
            height: 40,
            child: TextFormField(
              decoration: const InputDecoration(
                filled: true,
              ),
              onEditingComplete: submit,
            ),
          ),
        ),
        body: Container(),
    );
  }

  void submit() async {
    FocusScope.of(context).unfocus();

    var response = await http.get(Uri.parse("https://another-browsing.web.app/template.abml"));
    var body = response.body;

    parse(body);
  }
}
