import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  Future<void> insertProduct() async {
    await supabase
        .from('PRODUCTS')
        .insert({
          'name': _nameController.text,
          'desc': _descController.text,
          'price': _priceController.text,
          'category': _categoryController.text
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
          ? const Center(child: CircularProgressIndicator(),)
          : Padding(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(
                width: 500,
                height: 100,
                child:
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return "Enter the name of the product";
                  }
                  return null;
                },
              ),),
              SizedBox(
                width: 500,
                height: 100,
                child: TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: "Product Description"),
                validator: (value) {
                  if(value == null || value.isEmpty) {
                    return "Enter a description for the product";
                  }
                  return null;
                },
              ),
              ),
              SizedBox(
                width: 500,
                height: 100,
                child: TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: "Product Price"),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if(value == null || value.isEmpty) {
                      return "Enter the price for the product (numbers only, no dollar signs)";
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(
                width: 500,
                height: 100,
                child: TextFormField(
                  controller: _stockController,
                  decoration: const InputDecoration(labelText: "OPTIONAL: Quantity in-stock"),
                  keyboardType: TextInputType.number,
                ),
              ),
              DropdownMenu(
                onSelected: (String? value) {
                  if(value != null) {
                    setState(() {
                      _categoryController.text = value;
                    });
                  }
                },
                label: const Text("Category"),
                helperText: "Select what category a product belongs to. Product will be autosorted on the app",
                width: 500,
                dropdownMenuEntries: const <DropdownMenuEntry<String>>[
                  DropdownMenuEntry(value: "magic", label: "Magic"),
                  DropdownMenuEntry(value: "fab", label: "Flesh & Blood"),
                  DropdownMenuEntry(value: "yugioh", label: "Yu-Gi-Oh"),
                  DropdownMenuEntry(value: "lorcana", label: "Lorcana"),
                  DropdownMenuEntry(value: "pokemon", label: "Pokemon"),
                ],
              ),
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
                  }
                },
                child: const Text("Validate"),
              )
          ],
      )
      )
      )
    );
  }
}

/*
class MyFormState extends State<MyForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
              decoration: const InputDecoration(
            labelText: 'ID (uuid)',
          )),
          TextFormField(
              decoration: const InputDecoration(
            labelText: 'Name (text)',
          )),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Price (float4)',
            ),
            keyboardType: TextInputType.number,
          ),
          TextFormField(
              decoration: const InputDecoration(
            labelText: 'Desc (text)',
          )),
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'In Stock (int4)',
            ),
            keyboardType: TextInputType.number,
          ),
          TextFormField(
              decoration: const InputDecoration(
            labelText: 'Category (text)',
          )),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Processing Data')));
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
*/
