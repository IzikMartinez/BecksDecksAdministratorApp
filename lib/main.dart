import 'package:becks_decks_admin/constants.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
      url: Constants.supabaseUrl, anonKey: Constants.supabaseAnonKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Countries',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _future = Supabase.instance.client.from('PRODUCTS').select();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text("Beck's Decks Admin App")),
      body: FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final countries = snapshot.data!;
          return ListView.builder(
            itemCount: countries.length,
            itemBuilder: ((context, index) {
              final country = countries[index];
              return ListTile(
                title: Text(
                    "PRODUCT: ${country['name']}, \n\t\t\tPRICE: \$${country['price']}"),
              );
            }),
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () {
              // Add your onPressed code here!
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.add),
          ),
          const SizedBox(
            width: 10,
          ),
          FloatingActionButton(
            onPressed: () {
              // Add your onPressed code here!
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.edit),
          ),
          const SizedBox(
            width: 10,
          ),
          FloatingActionButton(
            onPressed: () {
              // Add your onPressed code here!
            },
            backgroundColor: Colors.red,
            child: const Icon(Icons.delete),
          ),
        ],
      ),
    );
  }
}
