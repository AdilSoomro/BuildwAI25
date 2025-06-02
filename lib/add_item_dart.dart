import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({Key? key}) : super(key: key);

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Image file
  File? _selectedImage;

  // Class level array for item types
  final List<String> _itemTypes = ['Fashion', 'Toys', 'Electronics', 'Books', 'Home', 'Sports', "Fruits"];

  // List of additional features tags
  final List<String> _additionalFeatures = [];

  // Controller for the tag input field
  final TextEditingController _tagController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  // Class level map to track all inputs
  final Map<String, dynamic> _formData = {
    'image': null,
    'location': '',
    'itemType': '', // Default value
    'price': '',
    'title': '',
    'description': '',
    'additionalFeatures': <String>[],
  };

  // Method to pick image from gallery
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _formData['image'] = image.path;
      });
    }
  }

  // Method to get location from Google Places (placeholder)
  void _pickLocation() async {
    // In a real implementation, this would integrate with Google Places API
    // For now, just show a placeholder dialog
    void _selectLocation(String location) {
      setState(() {
        _formData['location'] = location;
        _locationController.text = location;
      });
      Navigator.of(context).pop();
    }
    showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Location'),
        children: [
          SimpleDialogOption(
            onPressed: () => _selectLocation('Johar Town, Lahore'),
            child: const Text('Johar Town, Lahore'),
          ),
          SimpleDialogOption(
            onPressed: () => _selectLocation('Model Town, Lahore'),
            child: const Text('Model Town, Lahore'),
          ),
          SimpleDialogOption(
            onPressed: () => _selectLocation('Gulberg 3, Lahore'),
            child: const Text('Gulberg 3, Lahore'),
          ),
        ],
      ),
    );
  }

  // Method to add a tag to additional features
  void _addTag(String tag) {
    if (tag.isNotEmpty && !_additionalFeatures.contains(tag)) {
      setState(() {
        _additionalFeatures.add(tag);
        _formData['additionalFeatures'] = _additionalFeatures;
      });
      _tagController.clear();
    }
  }

  // Method to remove a tag from additional features
  void _removeTag(String tag) {
    setState(() {
      _additionalFeatures.remove(tag);
      _formData['additionalFeatures'] = _additionalFeatures;
    });
  }

  // Method to submit the form
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Validate image
      if (_formData['image'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please upload an image')),
        );
        return;
      }

      // Display loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      try {
        // Convert image to MultipartFile
        final imageFile = _formData['image'];

        // Create FormData object
        final formData = {
          'image': imageFile,
          'location': _formData['location'],
          'itemType': _formData['itemType'],
          'price': _formData['price'],
          'title': _formData['title'],
          'description': _formData['description'],
          'additionalFeatures': _formData['additionalFeatures'],
        };

        // Hide loading indicator
        Navigator.of(context).pop();


        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item added successfully')),
        );
      } catch (e) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(left: 24.0, right: 24.0, bottom: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add Image Section
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 188,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: const Color(0xFF25ADDE),
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                      : const Center(
                    child: Text(
                      'Upload Image',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF25ADDE),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Location Field
              const Text(
                'Location',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3643),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: 'Your location here',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFABB5C5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(color: Color(0xFFD3D5DA)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.my_location,
                      color: Color(0xFF25ADDE),
                    ),
                    onPressed: _pickLocation,
                  ),
                ),
                onSaved: (value) {
                  _formData['location'] = value ?? '';
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),


              // Price Dropdown
              const Text(
                'Price',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3643),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  hintText: 'Price for item',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFABB5C5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(color: Color(0xFFD3D5DA)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                ),
                onSaved: (value) {
                  _formData['price'] = value ?? '';
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: generateAIContent,
                child: const Text(
                  'Generate AI Content',
                ),
              ),
              const SizedBox(height: 20),
              // Item Type Dropdown



              // Title Field
              const Text(
                'Title',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3643),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'Title for item',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFABB5C5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(color: Color(0xFFD3D5DA)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                ),
                onSaved: (value) {
                  _formData['title'] = value ?? '';
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),

              // Description Field
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3643),
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: 'Description here',
                  hintStyle: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFABB5C5),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: const BorderSide(color: Color(0xFFD3D5DA)),
                  ),
                  contentPadding: const EdgeInsets.all(15),
                ),
                maxLines: 10,
                onSaved: (value) {
                  _formData['description'] = value ?? '';
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              const Text(
                'Item Type',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3643),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD3D5DA)),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: DropdownButtonFormField<String>(
                  value: _formData['itemType'].isNotEmpty ? _formData['itemType'] : null,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 15),
                    border: InputBorder.none,
                  ),
                  hint: const Text(
                    'Select the item type',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFABB5C5),
                    ),
                  ),
                  items: _itemTypes.map((String type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _formData['itemType'] = newValue!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 10),
              // Additional Features
              const Text(
                'Additional Features',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3643),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD3D5DA)),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Column(
                  children: [
                    // Display tags
                    Wrap(
                      spacing: 10,
                      children: _additionalFeatures.map((tag) {
                        return Chip(label: Text(tag,
                          style: TextStyle(
                              fontSize: 10
                          ),));
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    // Input for new tags
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _tagController,
                            decoration: const InputDecoration(
                              hintText: 'Add a feature tag',
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Color(0xFFABB5C5),
                              ),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (value) => _addTag(value),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle_outline,
                          ),
                          onPressed: () => _addTag(_tagController.text),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Add Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: _submitForm,

                      child: const Text(
                        'Add',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tagController.dispose();
    super.dispose();
  }

  var _model;
  final apiKey = "Your-API-KEY";
  @override
  void initState() {
    super.initState();

    _model = GenerativeModel(
        model: "gemini-2.5-pro-preview-05-06",
        apiKey: apiKey,
        generationConfig: GenerationConfig(
            responseMimeType: "application/json",
            responseSchema: Schema.object(
              properties: {
                "title" : Schema.string(),
                "description" : Schema.string(),
                "type" : Schema.enumString(
                    enumValues: _itemTypes,
                    description: "The type of the item"
                ),
                "features" : Schema.array(items: Schema.string())
              },
              // Crucially, define which properties MUST be in the response:
              requiredProperties: [
                "title",
                "description",
                "features",
                "type",
              ],
            )

        )
    );
  }
  void  generateAIContent() async {
    if (_selectedImage == null) return;

    String prompt = "I'm listing this item for sale at online market";
    if (_formData["location"] != null && _formData["location"].isNotEmpty) {
      prompt = "$prompt. Its location is ${_formData["location"]}.";
    }

    if (_priceController.text.isNotEmpty) {
      prompt = "$prompt. Its price is ${_priceController.text} pkr.";
    }

    prompt = "$prompt. Help me write a appealing title, 10 lines of description, type and features of this item."
        " The tone should be natural.";
    print("gemini prompt is $prompt");


    final content = Content.multi(
        [
          TextPart(prompt),
          DataPart("image/png", _selectedImage!.readAsBytesSync())
        ]
    );
    var response = await _model.generateContent([content]);
    var responseJson = jsonDecode(response.text);

    _titleController.text = responseJson["title"] ?? "";
    _formData["itemType"] = responseJson["type"] ?? "";
    _descriptionController.text = responseJson["description"] ?? "";
    if (responseJson["features"] != null && responseJson["features"].isNotEmpty ) {
      _additionalFeatures.clear();
      for (String feature in responseJson["features"]) {
        _additionalFeatures.add(feature);
      }
    }
    setState(() {
      //to refresh UI
    });
  }
}