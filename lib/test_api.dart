// lib/test_api.dart - ARCHIVO TEMPORAL
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TestApiPage extends StatefulWidget {
  @override
  _TestApiPageState createState() => _TestApiPageState();
}

class _TestApiPageState extends State<TestApiPage> {
  String _result = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test API Proyecto'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testProjectAPI,
              child: _isLoading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Probar API del Proyecto'),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _isLoading ? null : _testAuthAPI,
              child: Text('Probar Endpoints de Auth'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            ),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _result.isEmpty ? 'Presiona un botón para probar' : _result,
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testProjectAPI() async {
    setState(() {
      _isLoading = true;
      _result = '🚀 PROBANDO ENDPOINTS PÚBLICOS\n';
    });

    // Lista de URLs públicas a probar (basado en documentación Swagger)
    final publicUrls = [
      'https://adamix.net/medioambiente/servicios',
      'https://adamix.net/medioambiente/noticias',
      'https://adamix.net/medioambiente/areas_protegidas',
      'https://adamix.net/medioambiente/medidas',
      'https://adamix.net/medioambiente/equipo',
      'https://adamix.net/medioambiente/videos',
      // Test con parámetros
      'https://adamix.net/medioambiente/videos?categoria=reciclaje',
      'https://adamix.net/medioambiente/areas_protegidas?tipo=parque_nacional',
    ];

    for (String url in publicUrls) {
      await _testSingleURL(url);
    }

    // Probar endpoints protegidos (sin auth, solo para ver la respuesta)
    _addResult('\n🔐 PROBANDO ENDPOINTS PROTEGIDOS (sin auth)');
    final protectedUrls = [
      'https://adamix.net/medioambiente/normativas',
      'https://adamix.net/medioambiente/reportes',
    ];

    for (String url in protectedUrls) {
      await _testSingleURL(url);
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testAuthAPI() async {
    setState(() {
      _isLoading = true;
      _result = '🔐 PROBANDO ENDPOINTS DE AUTENTICACIÓN\n';
    });

    // Test de registro con datos ficticios (siguiendo el schema de Swagger)
    await _testRegister();

    // Test de login con datos ficticios
    await _testLogin();

    // Test de recuperación de contraseña
    await _testRecover();

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _testRegister() async {
    _addResult(
      '\n📍 Probando REGISTER: https://adamix.net/medioambiente/auth/register',
    );

    try {
      final response = await http
          .post(
            Uri.parse('https://adamix.net/medioambiente/auth/register'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              "cedula": "00100000000",
              "nombre": "Juan",
              "apellido": "Pérez",
              "correo": "juan@example.com", // ⚠️ Nota: usa "correo" no "email"
              "password": "123456",
              "telefono": "8095551234",
              "matricula": "2021-0123",
            }),
          )
          .timeout(Duration(seconds: 15));

      _addResult('✅ Status: ${response.statusCode}');

      try {
        final jsonData = json.decode(response.body);
        _addResult('📝 Response: ${json.encode(jsonData)}');

        if (response.statusCode == 201) {
          _addResult('🎉 ¡REGISTRO EXITOSO!');
          if (jsonData['token'] != null) {
            _addResult(
              '🔑 Token recibido: ${jsonData['token'].toString().substring(0, 20)}...',
            );
          }
        } else if (response.statusCode == 409) {
          _addResult('⚠️  Usuario ya existe (conflicto)');
        }
      } catch (e) {
        _addResult('📝 Raw Response: ${response.body}');
      }
    } catch (e) {
      _addResult('❌ Error: $e');
    }
  }

  Future<void> _testLogin() async {
    _addResult(
      '\n📍 Probando LOGIN: https://adamix.net/medioambiente/auth/login',
    );

    try {
      final response = await http
          .post(
            Uri.parse('https://adamix.net/medioambiente/auth/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({
              "correo": "juan@example.com", // ⚠️ Nota: usa "correo" no "email"
              "password": "123456",
            }),
          )
          .timeout(Duration(seconds: 15));

      _addResult('✅ Status: ${response.statusCode}');

      try {
        final jsonData = json.decode(response.body);
        _addResult('📝 Response: ${json.encode(jsonData)}');

        if (response.statusCode == 200) {
          _addResult('🎉 ¡LOGIN EXITOSO!');
          if (jsonData['token'] != null) {
            _addResult(
              '🔑 Token recibido: ${jsonData['token'].toString().substring(0, 20)}...',
            );
          }
          if (jsonData['usuario'] != null) {
            _addResult(
              '👤 Usuario: ${jsonData['usuario']['nombre']} ${jsonData['usuario']['apellido']}',
            );
          }
        } else if (response.statusCode == 401) {
          _addResult('❌ Credenciales incorrectas');
        }
      } catch (e) {
        _addResult('📝 Raw Response: ${response.body}');
      }
    } catch (e) {
      _addResult('❌ Error: $e');
    }
  }

  Future<void> _testRecover() async {
    _addResult(
      '\n📍 Probando RECOVER: https://adamix.net/medioambiente/auth/recover',
    );

    try {
      final response = await http
          .post(
            Uri.parse('https://adamix.net/medioambiente/auth/recover'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: json.encode({"correo": "juan@example.com"}),
          )
          .timeout(Duration(seconds: 15));

      _addResult('✅ Status: ${response.statusCode}');

      try {
        final jsonData = json.decode(response.body);
        _addResult('📝 Response: ${json.encode(jsonData)}');

        if (response.statusCode == 200) {
          _addResult('📧 Código de recuperación enviado');
          if (jsonData['codigo'] != null) {
            _addResult('🔢 Código: ${jsonData['codigo']}');
          }
        }
      } catch (e) {
        _addResult('📝 Raw Response: ${response.body}');
      }
    } catch (e) {
      _addResult('❌ Error: $e');
    }
  }

  Future<void> _testSingleURL(String url) async {
    final endpoint = url.split('/').last.split('?').first;
    _addResult('\n📍 [$endpoint] $url');

    try {
      final response = await http
          .get(
            Uri.parse(url),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'User-Agent': 'MedioAmbienteApp/1.0',
            },
          )
          .timeout(Duration(seconds: 15));

      _addResult('✅ Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        _addResult(
          '📄 Content-Type: ${response.headers['content-type'] ?? 'unknown'}',
        );

        // Intentar parsear JSON
        try {
          final jsonData = json.decode(response.body);
          _addResult('✅ JSON válido!');

          if (jsonData is List) {
            _addResult('📋 Lista con ${jsonData.length} elementos');
            if (jsonData.isNotEmpty && jsonData.first is Map) {
              final firstItem = jsonData.first as Map;
              _addResult(
                '🏷️ Keys del primer item: ${firstItem.keys.take(5).join(', ')}',
              );

              // Verificar campos específicos según el endpoint
              if (endpoint == 'servicios' && firstItem.containsKey('nombre')) {
                _addResult('🔧 Servicio: ${firstItem['nombre']}');
              } else if (endpoint == 'noticias' &&
                  firstItem.containsKey('titulo')) {
                _addResult('📰 Noticia: ${firstItem['titulo']}');
              } else if (endpoint == 'areas_protegidas' &&
                  firstItem.containsKey('nombre')) {
                _addResult(
                  '🏞️ Área: ${firstItem['nombre']} (${firstItem['tipo']})',
                );
              } else if (endpoint == 'equipo' &&
                  firstItem.containsKey('nombre')) {
                _addResult(
                  '👤 Miembro: ${firstItem['nombre']} - ${firstItem['cargo']}',
                );
              }
            }
          } else if (jsonData is Map) {
            _addResult(
              '📋 Objeto con keys: ${jsonData.keys.take(5).join(', ')}',
            );
          }
        } catch (e) {
          _addResult('⚠️  No es JSON válido');
          final bodyPreview = response.body.length > 200
              ? response.body.substring(0, 200) + '...'
              : response.body;
          _addResult('📝 Body preview: $bodyPreview');
        }
      } else if (response.statusCode == 401) {
        _addResult(
          '🔐 401 - Requiere autenticación (normal para endpoints protegidos)',
        );
        try {
          final jsonData = json.decode(response.body);
          _addResult('💬 Error: ${jsonData['error'] ?? 'Sin mensaje'}');
        } catch (e) {
          _addResult('📝 Body: ${response.body}');
        }
      } else if (response.statusCode == 404) {
        _addResult('❌ 404 - Endpoint no existe');
      } else if (response.statusCode >= 500) {
        _addResult('❌ Error del servidor (${response.statusCode})');
        _addResult('📝 Body: ${response.body}');
      } else {
        _addResult('⚠️  Status inesperado: ${response.statusCode}');
        try {
          final jsonData = json.decode(response.body);
          _addResult('📝 Response: ${json.encode(jsonData)}');
        } catch (e) {
          _addResult('📝 Body: ${response.body}');
        }
      }
    } catch (e) {
      _addResult('❌ Error: $e');
    }
  }

  void _addResult(String text) {
    setState(() {
      _result += text + '\n';
    });
  }
}
