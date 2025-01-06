import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product List',
      home: ProductListScreen(),
    );
  }
}

class ProductListScreen extends StatefulWidget {
  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  List<dynamic> products = [];
  List<String> categories = [];
  String? selectedCategory;
  bool _isLoading = true;
  String _errorMessage = '';
  String _searchQuery = '';
  String _sortBy = 'name'; // Default sorting by name

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse('http://localhost/flut_proj/getProducts.php'));
      if (response.statusCode == 200) {
        List<dynamic> loadedProducts = jsonDecode(response.body);
        setState(() {
          products = loadedProducts;
          categories = loadedProducts.map((product) => product['category'] as String).toSet().toList();
          categories.sort();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load products: ${response.statusCode}';
        });
        print('Failed to load products: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred: $e';
      });
      print('Error loading products: $e');
    }
  }

  List<dynamic> getFilteredProducts() {
    List<dynamic> filteredByCategory = selectedCategory == null
        ? products
        : products.where((product) => product['category'] == selectedCategory).toList();

    List<dynamic> filteredBySearch = filteredByCategory.where((product) =>
        product['name'].toLowerCase().contains(_searchQuery.toLowerCase())).toList();

    // Sort logic
    if (_sortBy == 'name') {
      filteredBySearch.sort((a, b) => a['name'].compareTo(b['name']));
    } else if (_sortBy == 'priceAsc') {
      filteredBySearch.sort((a, b) {
        double priceA = double.tryParse(a['price']) ?? 0;
        double priceB = double.tryParse(b['price']) ?? 0;
        return priceA.compareTo(priceB);
      });
    } else if (_sortBy == 'priceDesc') {
      filteredBySearch.sort((a, b) {
        double priceA = double.tryParse(a['price']) ?? 0;
        double priceB = double.tryParse(b['price']) ?? 0;
        return priceB.compareTo(priceA);
      });
    }

    return filteredBySearch;
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredProducts = getFilteredProducts();

    return Scaffold(
      appBar: AppBar(
        title: Text('Product List'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search products...',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Select Category',
                        ),
                        value: selectedCategory,
                        onChanged: (newValue) {
                          setState(() {
                            selectedCategory = newValue;
                          });
                        },
                        items: [
                          DropdownMenuItem<String>(
                            value: null,
                            child: Text('All Categories'),
                          ),
                          for (var category in categories)
                            DropdownMenuItem<String>(
                              value: category,
                              child: Text(category),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Sort By',
                        ),
                        value: _sortBy,
                        onChanged: (newValue) {
                          setState(() {
                            _sortBy = newValue!;
                          });
                        },
                        items: const [
                          DropdownMenuItem(
                            value: 'name',
                            child: Text('Name'),
                          ),
                          DropdownMenuItem(
                            value: 'priceAsc',
                            child: Text('Price Ascending'),
                          ),
                          DropdownMenuItem(
                            value: 'priceDesc',
                            child: Text('Price Descending'),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: filteredProducts.isEmpty
                          ? Center(
                              child: selectedCategory != null || _searchQuery.isNotEmpty
                                  ? Text("No products found")
                                  : Container(),
                            )
                          : ListView.builder(
                              itemCount: filteredProducts.length,
                              itemBuilder: (context, index) {
                                final product = filteredProducts[index];
                                return Card(
                                  margin: EdgeInsets.all(8.0),
                                  child: ListTile(
                                    title: Text(product['name']),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('PID: ${product['pid']}'),
                                        Text('Quantity: ${product['quantity']}'),
                                        Text('Price: ${product['price']}'),
                                        Text('Category: ${product['category']}'),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}