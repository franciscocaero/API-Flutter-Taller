import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


void main() {
  runApp(const PokemonApp());
}

class PokemonApp extends StatelessWidget {
  const PokemonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    PokemonSearch(),
    DogBreedsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscador de Mascotas'),
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Pokémon',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pets),
            label: 'Dog Breeds',
          ),
        ],
      ),
    );
  }
}

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

class PokemonSearch extends StatefulWidget {
  const PokemonSearch({super.key});

  @override
  _PokemonSearchState createState() => _PokemonSearchState();
}

class _PokemonSearchState extends State<PokemonSearch> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic> _pokemonDetails = {};
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> fetchPokemon(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final url = Uri.parse('https://pokeapi.co/api/v2/pokemon/$query');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _pokemonDetails = {
            'name': data['name'],
            'image': data['sprites']['front_default'],
            'types': (data['types'] as List)
                .map((type) => type['type']['name'])
                .toList(),
            'height': data['height'],
            'weight': data['weight'],
            'abilities': (data['abilities'] as List)
                .map((ability) => ability['ability']['name'])
                .toList(),
            'stats': (data['stats'] as List)
                .map((stat) =>
                    '${stat['stat']['name']}: ${stat['base_stat']}')
                .toList(),
            'moves': (data['moves'] as List)
                .take(5)
                .map((move) => move['move']['name'])
                .toList(),
          };
        });
      } else {
        setState(() {
          _errorMessage = 'No se encontró el Pokémon ingresado.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error cargando la información del Pokémon.';
      });
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: 'Busca Pokémon por ID o nombre',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                fetchPokemon(value.toLowerCase());
              },
            ),
            const SizedBox(height: 16.0),
            if (_isLoading) 
              const CircularProgressIndicator(),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red),
              ),
            if (_pokemonDetails.isNotEmpty)
              Expanded(
                child: ListView(
                  children: [
                    if (_pokemonDetails['image'] != null)
                      Image.network(
                        _pokemonDetails['image'],
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    Text(
                      _pokemonDetails['name'] ?? '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Tipos: ${(_pokemonDetails['types'] as List).join(', ')}',
                    ),
                    Text('Altura: ${_pokemonDetails['height']} decímetros'),
                    Text('Peso: ${_pokemonDetails['weight']} hectogramos'),
                    const SizedBox(height: 8.0),
                    Text(
                      'Habilidades: ${(_pokemonDetails['abilities'] as List).join(', ')}',
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      'Estadísticas:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    for (String stat in _pokemonDetails['stats'])
                      Text(stat),
                    const SizedBox(height: 8.0),
                    Text(
                      'Movimientos (5 primeros):',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    for (String move in _pokemonDetails['moves'])
                      Text(move),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
