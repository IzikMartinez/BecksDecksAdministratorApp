import 'dart:io';
import 'dart:typed_data';

import 'package:becks_decks_admin/add_product.dart';
import 'package:becks_decks_admin/constants.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
      title: 'Beck\'s Decks Admin',
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

  String? _imageUrl = "";
  File? _selectedImage;

  Future _pickImageFromGallery(String productId) async {
    final productImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (productImage == null) {
      print("Failed to pick image");
      return;
    } else {
      print(
          "Attempting to call _updateImage() with ${File(productImage.path)}");
      _updateImage(productId, productImage);
    }
  }

  Future _updateImage(String productId, XFile? productImage) async {
    final String path = await supabase.storage.from('product_images').update(
          '$productId.jpg',
          File(productImage!.path),
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
  }

  Future<void> fetchImageUrl(String productId) async {
    final imageUrl = await supabase.storage
        .from('product_images')
        .createSignedUrl('$productId.jpg', 6);
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
                            onPressed: () async {
                              await fetchImageUrl(productId);
                              showDialog(
                                  // ignore: use_build_context_synchronously
                                  context: context,
                                  builder: (context) {
                                    return SimpleDialog(
                                      title: const Text(
                                          'Edit product (saves on enter)'),
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            _pickImageFromGallery(productId);
                                          },
                                          child: Image.network(
                                            _imageUrl.toString(),
                                            width: 125,
                                            height: 250,
                                          ),
                                        ),
                                        TextFormField(
                                          initialValue: product['name'],
                                          decoration: const InputDecoration(
                                            hintText: "Edit Name",
                                            contentPadding:
                                                EdgeInsets.all(10.0),
                                          ),
                                          keyboardType: TextInputType.multiline,
                                          minLines: 1,
                                          maxLines: 3,
                                          onFieldSubmitted: (value) async {
                                            await updateName(productId, value);
                                            if (mounted) Navigator.pop(context);
                                          },
                                        ),
                                        TextFormField(
                                          initialValue: product['desc'],
                                          decoration: const InputDecoration(
                                            hintText: "Edit Description",
                                            contentPadding:
                                                EdgeInsets.all(10.0),
                                          ),
                                          keyboardType: TextInputType.multiline,
                                          minLines: 1,
                                          maxLines: 5,
                                          onFieldSubmitted: (value) async {
                                            await updateDesc(productId, value);
                                            if (mounted) Navigator.pop(context);
                                          },
                                        ),
                                        TextFormField(
                                          keyboardType: TextInputType.number,
                                          initialValue:
                                              product['price'].toString(),
                                          decoration: const InputDecoration(
                                            hintText: "Edit Price",
                                            contentPadding:
                                                EdgeInsets.all(10.0),
                                          ),
                                          onFieldSubmitted: (value) async {
                                            await updatePrice(productId, value);
                                            if (mounted) Navigator.pop(context);
                                          },
                                        ),
                                        DropdownMenu(
                                          onSelected: (String? value) {
                                            if (value != null) {
                                              updateCategory(productId, value);
                                            }
                                          },
                                          label: const Text("Category"),
                                          helperText:
                                              "Select what category a product belongs to. Product will be autosorted on the app",
                                          width: 350,
                                          dropdownMenuEntries: const <DropdownMenuEntry<
                                              String>>[
                                            DropdownMenuEntry(
                                                value: "magic", label: "Magic"),
                                            DropdownMenuEntry(
                                                value: "fab",
                                                label: "Flesh & Blood"),
                                            DropdownMenuEntry(
                                                value: "yugioh",
                                                label: "Yu-Gi-Oh"),
                                            DropdownMenuEntry(
                                                value: "lorcana",
                                                label: "Lorcana"),
                                            DropdownMenuEntry(
                                                value: "pokemon",
                                                label: "Pokemon"),
                                          ],
                                        ),
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
