import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _desc = '';
  double _price = 0.0;
  int _quantity = 0;
  File? _imageFile;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _saveProduct() async {
    if (!_formKey.currentState!.validate() || _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Fill all fields & select an image")),
      );
      return;
    }
    _formKey.currentState!.save();

    final productProvider = context.read<ProductProvider>();

    await productProvider.addProduct(
      name: _name,
      description: _desc,
      price: _price,
      quantity: _quantity,
      imageFile: _imageFile!,
    );

    if (productProvider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(productProvider.errorMessage!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Product added successfully!")),
      );
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<ProductProvider>().isLoading;

    return Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: "Product Name"),
                  validator: (value) =>
                  value!.isEmpty ? "Enter product name" : null,
                  onSaved: (value) => _name = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Description"),
                  validator: (value) =>
                  value!.isEmpty ? "Enter description" : null,
                  onSaved: (value) => _desc = value!,
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Price"),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                  value!.isEmpty ? "Enter price" : null,
                  onSaved: (value) => _price = double.parse(value!),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: "Quantity"),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? "Enter quantity" : null,
                  onSaved: (value) => _quantity = int.parse(value!),
                ),
                const SizedBox(height: 20),

                // Image picker
                _imageFile != null
                    ? Image.file(_imageFile!, height: 150)
                    : const Text("No image selected"),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.image),
                  label: const Text("Pick Image"),
                ),
                const SizedBox(height: 20),

                isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _saveProduct,
                  child: const Text("Save Product"),
                ),
              ],
            ),
          ),
        ),
    );
  }
}
