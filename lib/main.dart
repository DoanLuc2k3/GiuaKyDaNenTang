import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCeXlPMW9APC644I-vx3rAzybIK5T1CelA",
      projectId: "giuakydanentang",
      messagingSenderId: "1038815283257",
      appId: "1:1038815283257:web:4d5d06ed8f2e976f1125e8",
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản Lý Sản Phẩm',
      theme: ThemeData(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.blue[50],
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontFamily: 'Arial', color: Colors.black),
          bodyMedium: TextStyle(fontFamily: 'Arial', color: Colors.black),
          titleLarge: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Arial',
          ),
        ),
      ),
      home: LoginScreen(), // Màn hình đăng nhập
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _errorMessage = '';

  void _login() {
    String username = _usernameController.text;
    String password = _passwordController.text;

    if (username == 'admin' && password == '12345') {
      // Điều hướng đến màn hình quản lý sản phẩm
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => ProductManagement()),
      );
    } else {
      setState(() {
        _errorMessage = 'Tên tài khoản hoặc mật khẩu không đúng!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Đăng Nhập')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Tên tài khoản',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity, // Kéo dài nút ra 1 chút
              child: ElevatedButton.icon(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800], // Màu xanh dương đậm hơn
                ),
                icon: Icon(Icons.login, color: Colors.white), // Biểu tượng login
                label: Text(
                  'Đăng Nhập',
                  style: TextStyle(color: Colors.white), // Màu chữ trắng
                ),
              ),
            ),
            SizedBox(height: 10),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}

class ProductManagement extends StatefulWidget {
  @override
  _ProductManagementState createState() => _ProductManagementState();
}

class _ProductManagementState extends State<ProductManagement> {
  final CollectionReference _products =
  FirebaseFirestore.instance.collection('sanpham'); // Collection sanpham

  final CollectionReference _favorites =
  FirebaseFirestore.instance.collection('yeuthich'); // Collection yeuthich

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  Future<void> _addProduct() async {
    if (_nameController.text.isEmpty ||
        _typeController.text.isEmpty ||
        _priceController.text.isEmpty) {
      return;
    }

    await _products.add({
      'ten_san_pham': _nameController.text,
      'loai_san_pham': _typeController.text,
      'gia': double.parse(_priceController.text),
    });

    _nameController.clear();
    _typeController.clear();
    _priceController.clear();
  }
//yeuthich
  Future<void> _toggleFavorite(String id, Map<String, dynamic> productData) async {
    DocumentSnapshot favoriteSnapshot = await _favorites.doc(id).get();
    if (favoriteSnapshot.exists) {
      await _favorites.doc(id).delete();
    } else {
      await _favorites.doc(id).set(productData);
    }
  }

  Future<void> _updateProduct(String id, String name, String type, double price) async {
    await _products.doc(id).update({
      'ten_san_pham': name,
      'loai_san_pham': type,
      'gia': price,
    });
  }

  Future<void> _deleteProduct(String id) async {
    await _products.doc(id).delete();
  }

  Future<void> _showEditDialog(String id, String name, String type, double price) {
    _nameController.text = name;
    _typeController.text = type;
    _priceController.text = price.toString();
//capnhat
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cập nhật sản phẩm'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Tên sản phẩm',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _typeController,
                  decoration: InputDecoration(
                    labelText: 'Loại sản phẩm',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Giá',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _updateProduct(
                  id,
                  _nameController.text,
                  _typeController.text,
                  double.parse(_priceController.text),
                );
                Navigator.of(context).pop();
              },
              child: Text('Cập nhật'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
          ],
        );
      },
    );
  }
// hien thi danh sach
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Quản Lý Sản Phẩm',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildInputForm(),
          Expanded(child: _buildProductList()),
        ],
      ),
    );
  }
// form input
  Widget _buildInputForm() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Tên sản phẩm',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _typeController,
            decoration: InputDecoration(
              labelText: 'Loại sản phẩm',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _priceController,
            decoration: InputDecoration(
              labelText: 'Giá',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity, // Kéo dài nút ra 1 chút
            child: ElevatedButton(
              onPressed: _addProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800], // Màu nền xanh dương đậm
              ),
              child: Text(
                'Thêm Sản Phẩm',
                style: TextStyle(color: Colors.white), // Màu chữ trắng
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList() {
    return StreamBuilder<QuerySnapshot>(
      stream: _products.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        final products = snapshot.data!.docs;

        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            var product = products[index];
            var productData = product.data() as Map<String, dynamic>;

            return Card(
              margin: EdgeInsets.all(8.0),
              child: ListTile(
                title: Text(productData['ten_san_pham']),
                subtitle: Text('Loại: ${productData['loai_san_pham']}\nGiá: ${productData['gia']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Thêm kiểm tra sản phẩm có trong yêu thích không
                    StreamBuilder<DocumentSnapshot>(
                      stream: _favorites.doc(product.id).snapshots(),
                      builder: (context, favoriteSnapshot) {
                        bool isFavorite = favoriteSnapshot.data?.exists ?? false;
                        return IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.pink : Colors.grey,
                          ),
                          onPressed: () {
                            _toggleFavorite(product.id, productData); // Toggle yêu thích
                          },
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.green),
                      onPressed: () {
                        _showEditDialog(
                          product.id,
                          productData['ten_san_pham'],
                          productData['loai_san_pham'],
                          productData['gia'],
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteProduct(product.id);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
