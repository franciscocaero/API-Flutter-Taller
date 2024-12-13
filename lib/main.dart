import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

// Función para obtener la URL de la imagen según la raza
Future<String> fetchDogImage(String breed) async {
  final url = Uri.parse('https://dog.ceo/api/breed/$breed/images/random');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final imageDog = jsonDecode(response.body);
    return imageDog['message'];
  } else {
    throw Exception('Error al obtener la imagen');
  }
}

// Función para obtener la lista de razas
Future<List<String>> fetchDogData() async {
  final url = Uri.parse('https://dog.ceo/api/breeds/list/all');
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final breedsData = jsonDecode(response.body);
    final Map<String, dynamic> breedsMap = breedsData['message'];
    return breedsMap.keys.toList();
  } else {
    throw Exception('Error al obtener la lista de razas');
  }
}

// Widget principal
class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('DogsApi'),
          centerTitle: true,
        ),
        body: const DogBreedsScreen(),
      ),
    );
  }
}

// Pantalla que muestra la lista de razas e imágenes
class DogBreedsScreen extends StatefulWidget {
  const DogBreedsScreen({super.key});
  @override
  _DogBreedsScreenState createState() => _DogBreedsScreenState();
}

class _DogBreedsScreenState extends State<DogBreedsScreen> {
  late Future<List<String>> _breedsFuture;
  String? _selectedBreed;
  String? _dogImageUrl;

  @override
  void initState() {
    super.initState();
    _breedsFuture = fetchDogData();
  }

  void _onBreedSelected(String breed) async {
    setState(() {
      _selectedBreed = breed;
      _dogImageUrl = null;
    });
    try {
      final imageUrl = await fetchDogImage(breed);
      setState(() {
        _dogImageUrl = imageUrl;
      });
    } catch (e) {
      setState(() {
        _dogImageUrl = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar la imagen: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscador'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FutureBuilder<List<String>>(
              future: _breedsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  final breeds = snapshot.data!;
                  return DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedBreed,
                    hint: const Text('Seleccione una raza'),
                    items: breeds.map((breed) {
                      return DropdownMenuItem(
                        value: breed,
                        child: Text(breed),
                      );
                    }).toList(),
                    onChanged: (breed) {
                      if (breed != null) {
                        _onBreedSelected(breed);
                      }
                    },
                  );
                } else {
                  return const Text('No existe la raza');
                }
              },
            ),
            const SizedBox(height: 20),
            if (_selectedBreed != null)
              Text(
                'Raza seleccionada: $_selectedBreed',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 20),
            if (_dogImageUrl != null)
              Image.network(
                _dogImageUrl!,
                height: 300,
                width: 300,
                fit: BoxFit.cover,
              ),
            if (_dogImageUrl == null && _selectedBreed != null)
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
