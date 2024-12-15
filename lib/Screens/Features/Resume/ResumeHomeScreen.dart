import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';


class HtmlStringLoader extends StatefulWidget {
  @override
  _HtmlStringLoaderState createState() => _HtmlStringLoaderState();
}

class _HtmlStringLoaderState extends State<HtmlStringLoader> {
  late final WebViewController _controller;

  final String htmlString = """
  <!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Complex Webpage</title>
  <style>
    /* General Reset */
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    body {
      font-family: 'Arial', sans-serif;
      line-height: 1.6;
      color: #333;
      background: #f4f4f9;
    }

    /* Header Section */
    header {
      background: linear-gradient(to right, #4facfe, #00f2fe);
      padding: 20px;
      text-align: center;
      color: white;
    }

    header h1 {
      font-size: 2.5rem;
      margin-bottom: 10px;
    }

    header p {
      font-size: 1.2rem;
    }

    /* Navigation Bar */
    nav {
      background: #333;
      padding: 10px 0;
      display: flex;
      justify-content: center;
    }

    nav ul {
      list-style: none;
      display: flex;
    }

    nav ul li {
      margin: 0 15px;
    }

    nav ul li a {
      color: white;
      text-decoration: none;
      font-size: 1.1rem;
      transition: color 0.3s ease;
    }

    nav ul li a:hover {
      color: #00f2fe;
    }

    /* Hero Section */
    .hero {
      text-align: center;
      padding: 50px 20px;
      background: #ffffff;
      border-bottom: 4px solid #00f2fe;
    }

    .hero h2 {
      font-size: 2.2rem;
      margin-bottom: 15px;
    }

    .hero p {
      font-size: 1.1rem;
      margin-bottom: 20px;
      color: #666;
    }

    .hero button {
      padding: 10px 20px;
      background: #4facfe;
      border: none;
      color: white;
      font-size: 1rem;
      border-radius: 5px;
      cursor: pointer;
      transition: background 0.3s ease;
    }

    .hero button:hover {
      background: #00f2fe;
    }

    /* Card Section */
    .cards {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
      gap: 20px;
      padding: 20px;
      margin: 20px;
    }

    .card {
      background: white;
      border-radius: 10px;
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
      overflow: hidden;
      transition: transform 0.3s ease, box-shadow 0.3s ease;
    }

    .card:hover {
      transform: translateY(-10px);
      box-shadow: 0 6px 12px rgba(0, 0, 0, 0.15);
    }

    .card img {
      width: 100%;
      height: 200px;
      object-fit: cover;
    }

    .card h3 {
      margin: 15px;
      font-size: 1.5rem;
      color: #333;
    }

    .card p {
      margin: 15px;
      font-size: 1rem;
      color: #666;
    }

    .card button {
      margin: 15px;
      padding: 10px 20px;
      background: #4facfe;
      border: none;
      color: white;
      font-size: 1rem;
      border-radius: 5px;
      cursor: pointer;
      transition: background 0.3s ease;
    }

    .card button:hover {
      background: #00f2fe;
    }

    /* Footer Section */
    footer {
      background: #333;
      color: white;
      text-align: center;
      padding: 20px;
      margin-top: 30px;
    }

    footer p {
      font-size: 0.9rem;
    }

    footer a {
      color: #00f2fe;
      text-decoration: none;
      font-weight: bold;
    }

    footer a:hover {
      text-decoration: underline;
    }
  </style>
</head>
<body>

  <!-- Header -->
  <header>
    <h1>Welcome to Our Website</h1>
    <p>Experience innovation and creativity like never before.</p>
  </header>

  <!-- Navigation -->
  <nav>
    <ul>
      <li><a href="#home">Home</a></li>
      <li><a href="#about">About</a></li>
      <li><a href="#services">Services</a></li>
      <li><a href="#contact">Contact</a></li>
    </ul>
  </nav>

  <!-- Hero Section -->
  <div class="hero">
    <h2>Empowering Your Ideas</h2>
    <p>Transform your vision into reality with our cutting-edge solutions.</p>
    <button>Get Started</button>
  </div>

  <!-- Cards Section -->
  <div class="cards">
    <div class="card">
      <img src="https://via.placeholder.com/300" alt="Card Image">
      <h3>Card Title 1</h3>
      <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit. Proin vitae urna vel lectus cursus feugiat.</p>
      <button>Learn More</button>
    </div>
    <div class="card">
      <img src="https://via.placeholder.com/300" alt="Card Image">
      <h3>Card Title 2</h3>
      <p>Suspendisse potenti. Ut semper auctor neque, et malesuada lorem imperdiet quis.</p>
      <button>Learn More</button>
    </div>
    <div class="card">
      <img src="https://via.placeholder.com/300" alt="Card Image">
      <h3>Card Title 3</h3>
      <p>Pellentesque euismod sem nec risus tincidunt, sed gravida libero pellentesque.</p>
      <button>Learn More</button>
    </div>
  </div>

  <!-- Footer -->
  <footer>
    <p>&copy; 2024 YourCompany. All rights reserved. | <a href="#privacy-policy">Privacy Policy</a></p>
  </footer>

</body>
</html>

  """;

  @override
  void initState() {
    super.initState();
    _initializeWebViewController();
  }

  void _initializeWebViewController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..addJavaScriptChannel(
        'FlutterChannel',
        onMessageReceived: (message) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Received from JS: ${message.message}')),
          );
        },
      )
      ..loadHtmlString(htmlString);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('HTML String Loader'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
