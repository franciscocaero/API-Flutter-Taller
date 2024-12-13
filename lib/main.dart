import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(PokemonApp());
}

class PokemonApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pokémon API',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PokemonSearch(),
    );
  }
}

class PokemonSearch extends StatefulWidget {
  @override
  _PokemonSearchState createState() => _PokemonSearchState();
}

class _PokemonSearchState extends State<PokemonSearch> {
  TextEditingController _controller = TextEditingController();
  Map<String, dynamic> _pokemonDetails = {};
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
  }

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
            'types': data['types'].map((type) => type['type']['name']).toList(),
            'height': data['height'],
            'weight': data['weight'],
            'abilities': data['abilities']
                .map((ability) => ability['ability']['name'])
                .toList(),
            'stats': data['stats']
                .map((stat) =>
                    '${stat['stat']['name']}: ${stat['base_stat']}')
                .toList(),
            'moves': data['moves']
                 
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
      appBar: AppBar(
        title: Text('Buscador de Pokémon'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [

            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Busca  Pokémon por ID o nombre',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) {
                fetchPokemon(value.toLowerCase());
              },
            ),
            SizedBox(height: 20),


            _isLoading
                ? CircularProgressIndicator()
                : _errorMessage.isNotEmpty
                    ? Text(_errorMessage, style: TextStyle(color: Colors.red))
                    : Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [

                              _pokemonDetails.isNotEmpty
                                  ? Image.network(_pokemonDetails['image'] ?? '')
                                  : Container(),

                              _pokemonDetails.isNotEmpty
                                  ? Text(
                                      _pokemonDetails['name'] ?? '',
                                      style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                                    )
                                  : Container(),


                              _pokemonDetails.isNotEmpty
                                  ? Text('Types : ${_pokemonDetails['types'].join(', ')}')
                                  : Container(),

      
                              _pokemonDetails.isNotEmpty
                                  ? Text('Height: ${_pokemonDetails['height']} ')
                                  : Container(),
                              _pokemonDetails.isNotEmpty
                                  ? Text('Weight: ${_pokemonDetails['weight']} ')
                                  : Container(),

                              _pokemonDetails.isNotEmpty
                                  ? Text('Abilities: ${_pokemonDetails['abilities'].join(', ')}')
                                  : Container(),

                              _pokemonDetails.isNotEmpty
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: 
                                      _pokemonDetails['stats']
                                          .map<Widget>((stat) => Text(stat))
                                          .toList(),
                                    )
                                  : Container(),

                              _pokemonDetails.isNotEmpty
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Movementss:'),
                                        ..._pokemonDetails['moves']
                                            .map<Widget>((move) => Text(move))
                                            .toList(),
                                      ],
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                      ),
          ],
        ),
      ),
    );
  }
}
