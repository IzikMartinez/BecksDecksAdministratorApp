import 'dart:io';
import 'dart:typed_data';

import 'package:becks_decks_admin/add_product.dart';
import 'package:becks_decks_admin/constants.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
      url: Constants.supabaseUrl, anonKey: Constants.supabaseAnonKey);
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

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
  final productStream = supabase.from('PRODUCTS').stream(primaryKey: ['id']);

  Future<void> updateName(String productId, String updatedNote) async {
    await supabase
        .from('PRODUCTS')
        .update({'name': updatedNote}).match({'id': productId});
  }

  Future<void> updateDesc(String productId, String updatedNote) async {
    await supabase
        .from('PRODUCTS')
        .update({'desc': updatedNote}).match({'id': productId});
  }

  Future<void> updatePrice(String productId, String updatedNote) async {
    await supabase
        .from('PRODUCTS')
        .update({'price': updatedNote}).match({'id': productId});
  }

  Future<void> updateCategory(String productId, String updatedNote) async {
    await supabase
        .from('PRODUCTS')
        .update({'category': updatedNote}).match({'id': productId});
  }

  Future<void> deleteProduct(String productId) async {
    await supabase.from('PRODUCTS').delete().match({'id': productId});
  }

  Future<Uint8List> fetchImage(String productId) async {
    final Uint8List productImage = await supabase.storage
        .from('product_images')
        .download("$productId.jpg");
    return productImage;
  }

  String _imageUrl = "";

  Future<void> fetchImageUrl(String productId) async {
    final imageUrl = await supabase.storage
        .from('product_images')
        .createSignedUrl('$productId.jpg', 60 * 60);
    print("URL from fetcher ${imageUrl}\n id: ${productId}");
    if (imageUrl.isEmpty) {
      setState(() {
        _imageUrl = "";
      });
    } else {
      setState(() {
        _imageUrl = imageUrl;
      });
    }
  }

  Future<void> deleteImage(String productId) async {
    final Uint8List productImage = fetchImage(productId) as Uint8List;
    if (productImage.isEmpty) return;
    final List<FileObject> imageObjects = await supabase.storage
        .from('product_images')
        .remove(['$productId.jpg']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.green,
          title: const Text("Beck's Decks Admin App")),
      body: StreamBuilder(
        stream: productStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: ((context, index) {
              final product = products[index];
              final productId = product['id'];
              return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0)),
                  elevation: 3,
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 35,
                      child: FittedBox(
                        child: Text('\$${product['price']}'),
                      ),
                    ),
                    title: Text("${product['name']}"),
                    trailing: Container(
                      width: 100,
                      height: 40,
                      child: Row(
                        children: <Widget>[
                          IconButton(
                            onPressed: () {
                              print("On Press: ${productId}");
                              fetchImageUrl(productId);
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return SimpleDialog(
                                      title: const Text('Edit a product'),
                                      children: [
                                        Image.network(
                                          _imageUrl,
                                          width: 125,
                                          height: 250,
                                        ),
                                        Text(productId),
                                        TextFormField(
                                          initialValue: product['name'],
                                          onFieldSubmitted: (value) async {
                                            await updateName(productId, value);
                                            if (mounted) Navigator.pop(context);
                                          },
                                        ),
                                        TextFormField(
                                          initialValue: product['desc'],
                                          onFieldSubmitted: (value) async {
                                            await updateDesc(productId, value);
                                            if (mounted) Navigator.pop(context);
                                          },
                                        ),
                                        TextFormField(
                                          keyboardType: TextInputType.number,
                                          initialValue:
                                              product['price'].toString(),
                                          onFieldSubmitted: (value) async {
                                            await updatePrice(productId, value);
                                            if (mounted) Navigator.pop(context);
                                          },
                                        )
                                      ],
                                    );
                                  });
                            },
                            icon: const Icon(Icons.edit),
                            color: Theme.of(context).primaryColor,
                          ),
                          IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext) {
                                    return AlertDialog(
                                      title: const Text('Confirm Deletion'),
                                      content: const Text(
                                          'Are you sure you want to delete this product from the database? No takebackies'),
                                      actions: <Widget>[
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            fixedSize:
                                                const Size.fromWidth(100),
                                            padding: const EdgeInsets.all(10),
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Cancel'),
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // close dialog
                                          },
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            fixedSize:
                                                const Size.fromWidth(100),
                                            padding: const EdgeInsets.all(10),
                                            backgroundColor: Colors.red,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: const Text('Yes'),
                                          onPressed: () async {
                                            deleteProduct(productId);
                                            deleteImage(productId);
                                            Navigator.of(context)
                                                .pop(); // close dialog
                                          },
                                        )
                                      ],
                                    );
                                  });
                            },
                            icon: const Icon(Icons.delete),
                            color: Colors.red,
                          )
                        ],
                      ),
                    ),
                  ));
            }),
          );
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () {
              // Add your onPressed code here!
              print("You pressed it alright");
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddProductDB()),
              );
            },
            backgroundColor: Colors.green,
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}

final _formKey = GlobalKey<FormState>();

class AddProduct extends StatelessWidget {
  const AddProduct({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter something';
                  }
                  return null;
                },
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter something';
                  }
                  return null;
                },
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter something';
                  }
                  return null;
                },
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter something';
                  }
                  return null;
                },
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter something';
                  }
                  return null;
                },
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter something';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text("Neat!")));
                  }
                },
                child: const Text("Validate"),
              ),
            ],
          )),
    ));
  }
}

class RemoveProduct extends StatelessWidget {
  const RemoveProduct({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
