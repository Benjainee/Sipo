import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';


Future<void> main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SEPO',
      theme: ThemeData(
        primaryColor: Color(0xFF63B2DC),
        fontFamily: 'Roboto',
      ),
      home: FirebaseAuth.instance.currentUser == null ? LoginScreen() : HomePage(),
      routes: {
        '/home': (context) => HomePage(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}


class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentSlide = 0;
  final ScrollController _scrollController = ScrollController();
  final List<Item> _cartItems = [];

  final List<String> _slides = [
    'assets/images/Grafica.png',
    'assets/images/Placa Madre.png',
    'assets/images/Audifonos.png',
    'assets/images/Procesador Intel.png',
    'assets/images/Procesador Amd.png',
  ];

  void _nextSlide() {
    setState(() {
      _currentSlide = (_currentSlide + 1) % _slides.length;
    });
  }

  void _prevSlide() {
    setState(() {
      _currentSlide = (_currentSlide - 1 + _slides.length) % _slides.length;
    });
  }

  void _scrollToSection(int sectionIndex) {
    double offset = sectionIndex == 0 ? 600.0 : 1200.0;
    _scrollController.animateTo(
      offset,
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut,
    );
  }

  void _addToCart(Item item) {
    setState(() {
      _cartItems.add(item);
    });
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item.title} añadido al carrito')),
    );
  }

  void _showProductPopup(Item item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(item.title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(item.image),
              SizedBox(height: 10),
              Text(
                'Precio Original: ${item.originalPrice}',
                style: TextStyle(
                  decoration: TextDecoration.lineThrough,
                  color: Colors.grey,
                ),
              ),
              Text(
                'Precio con Descuento: ${item.discountedPrice}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar'),
            ),
            ElevatedButton(
              onPressed: () => _addToCart(item),
              child: Text('Añadir al Carrito'),
            ),
          ],
        );
      },
    );
  }

  void _openCart() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Productos en el Carrito',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF003254),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (_cartItems.isEmpty)
                    Center(
                      child: Text(
                        'El carrito está vacío.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: _cartItems.map((item) {
                          return Card(
                            margin: EdgeInsets.only(bottom: 15),
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(10),
                              leading: Image.asset(
                                item.image,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                              title: Text(
                                item.title,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text('Precio: ${item.discountedPrice}'),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _cartItems.remove(item);  // Eliminar el producto al instante
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${item.title} ha sido eliminado.')),
                                  );
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  if (_cartItems.isNotEmpty) Divider(),
                  if (_cartItems.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        'Total: \$${_cartItems.fold(0, (sum, item) => sum + int.parse(item.discountedPrice.replaceAll('\$', '').replaceAll('.', '')))}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF003254),
                        ),
                      ),
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_cartItems.isNotEmpty)
                        ElevatedButton(
                          onPressed: () {
                            // Lógica de pago (agregar si es necesario)
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF63B2DC),
                            padding: EdgeInsets.symmetric(vertical: 12),
                            textStyle: TextStyle(fontSize: 18),
                          ),
                          child: Text(
                            'Proceder al Pago',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      if (_cartItems.isNotEmpty)
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _cartItems.clear(); // Vaciar el carrito al instante
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('El carrito ha sido vaciado.')),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                            textStyle: TextStyle(fontSize: 18),
                          ),
                          child: Text(
                            'Vaciar Carrito',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _goToProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sesión cerrada')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Image.asset('assets/images/LOGO PAGINA.png', height: 50),
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.computer),
                  onPressed: () => _scrollToSection(0),
                ),
                IconButton(
                  icon: Icon(Icons.keyboard),
                  onPressed: () => _scrollToSection(1),
                ),
                IconButton(
                  icon: Icon(Icons.shopping_cart),
                  onPressed: _openCart,
                ),
                IconButton(
                  icon: Icon(Icons.account_circle),
                  onPressed: _goToProfile,
                ),
                IconButton(
                  icon: Icon(Icons.logout),
                  onPressed: _signOut, // Agregado: Botón para cerrar sesión
                  tooltip: 'Cerrar sesión',
                ),
              ],
            ),
          ],
        ),
        backgroundColor: Color(0xFF63B2DC),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      _slides[_currentSlide],
                      width: double.infinity,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  top: 100,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                    onPressed: _prevSlide,
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 100,
                  child: IconButton(
                    icon: Icon(Icons.arrow_forward, color: Colors.white, size: 30),
                    onPressed: _nextSlide,
                  ),
                ),
              ],
            ),
            SectionTitle(title: 'Secciones'),
            SectionButton(title: 'Placas Madres', icon: Icons.hardware),
            SectionButton(title: 'Procesadores', icon: Icons.hardware),
            SectionButton(title: 'Tarjetas de Sonido', icon: Icons.speaker),
          ],
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;

  SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Color(0xFF003254),
        ),
      ),
    );
  }
}

class SectionButton extends StatelessWidget {
  final String title;
  final IconData icon;

  SectionButton({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ElevatedButton.icon(
        onPressed: () {}, // Lógica personalizada
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF63B2DC),
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          textStyle: TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}

class Item {
  final String title;
  final String image;
  final String originalPrice;
  final String discountedPrice;

  Item({
    required this.title,
    required this.image,
    required this.originalPrice,
    required this.discountedPrice,
  });
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
        backgroundColor: Color(0xFF63B2DC),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenido a tu perfil',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF003254),
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  'Nombre: Faviola Marcela Escudero Sepulveda',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  'RUT: 8744321',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  'Sucursal: Antofagasta',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Regresar a la página principal
                  },
                  child: Text('Volver a la Página Principal'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await FirebaseAuth.instance.signOut();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sesión cerrada')),
                      );
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MyApp()),
                      );
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al cerrar sesión: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: Text(
                    'Cerrar Sesión',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

