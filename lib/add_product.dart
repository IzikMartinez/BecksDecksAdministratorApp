import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'constants.dart';
import 'main.dart';

class AddProductDB extends StatefulWidget {
  const AddProductDB({super.key});

  @override
  _AddProductDBState createState() => _AddProductDBState();
}

class _AddProductDBState extends State<AddProductDB> {
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _categoryController = TextEditingController();

  File? _selectedImage;
  Future<void> insertProduct() async {
    var uuid = const Uuid();
    var productId = uuid.v1();

    await supabase.from('PRODUCTS').insert({
      'id': productId,
      'name': _nameController.text,
      'desc': _descController.text,
      'price': _priceController.text,
      'category': _categoryController.text
    });
    print(productId);
    if (_selectedImage != null) {
      final String path = await supabase.storage.from('product_images').upload(
            '${productId}.jpg',
            _selectedImage!,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
    }
  }

  Future _pickImageFromGallery() async {
    final productImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (productImage == null) return;
    setState(() {
      _selectedImage = File(productImage.path);
    });
  }

  var _loading = false;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Product to Database'),
          backgroundColor: Colors.deepPurpleAccent,
        ),
        body: _loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
                child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 350,
                          height: 100,
                          child: TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                                labelText: 'Product Name'),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter the name of the product";
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(
                          width: 350,
                          height: 100,
                          child: TextFormField(
                            controller: _descController,
                            decoration: const InputDecoration(
                                labelText: "Product Description"),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter a description for the product";
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(
                          width: 350,
                          height: 100,
                          child: TextFormField(
                            controller: _priceController,
                            decoration: const InputDecoration(
                                labelText: "Product Price"),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Enter the price for the product (numbers only, no dollar signs)";
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(
                          width: 350,
                          height: 100,
                          child: TextFormField(
                            controller: _stockController,
                            decoration: const InputDecoration(
                                labelText: "OPTIONAL: Quantity in-stock"),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        DropdownMenu(
                          onSelected: (String? value) {
                            if (value != null) {
                              setState(() {
                                _categoryController.text = value;
                              });
                            }
                          },
                          label: const Text("Category"),
                          helperText:
                              "Select what category a product belongs to. Product will be autosorted on the app",
                          width: 350,
                          dropdownMenuEntries: const <DropdownMenuEntry<
                              String>>[
                            DropdownMenuEntry(value: "magic", label: "Magic"),
                            DropdownMenuEntry(
                                value: "fab", label: "Flesh & Blood"),
                            DropdownMenuEntry(
                                value: "yugioh", label: "Yu-Gi-Oh"),
                            DropdownMenuEntry(
                                value: "lorcana", label: "Lorcana"),
                            DropdownMenuEntry(
                                value: "pokemon", label: "Pokemon"),
                          ],
                        ),
                        ElevatedButton(
                            onPressed: () {
                              _pickImageFromGallery();
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.all(8.0)),
                            child: const Text(
                              "Upload product image",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            )),
                        const SizedBox(
                          height: 20,
                        ),
                        _selectedImage != null
                            ? Image.file(_selectedImage!)
                            : const Text("Please select an image"),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(content: Text('''
                          Created new product with following properties:
                          Name: ${_nameController.text}
                          Desc: ${_descController.text}
                          Price: ${_priceController.text}
                          Category: ${_categoryController.text}
                    ''')));
                              insertProduct();
                              setState(() {
                                _nameController.text = '';
                                _descController.text = '';
                                _priceController.text = '';
                                _categoryController.text = '';
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                          ),
                          child: const Text("Submit Product"),
                        )
                      ],
                    ))));
  }
}
