import 'package:flutter/material.dart';

class VoluntariadoForm extends StatefulWidget {
  const VoluntariadoForm({super.key});

  @override
  State<VoluntariadoForm> createState() => _VoluntariadoFormState();
}

class _VoluntariadoFormState extends State<VoluntariadoForm> {
  final _formKey = GlobalKey<FormState>();

  // Controladores para los campos
  final TextEditingController cedulaCtrl = TextEditingController();
  final TextEditingController nombreCtrl = TextEditingController();
  final TextEditingController apellidoCtrl = TextEditingController();
  final TextEditingController correoCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  final TextEditingController telefonoCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Formulario Voluntariado",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 20),

                // Cedula
                TextFormField(
                  controller: cedulaCtrl,
                  decoration: const InputDecoration(
                    labelText: "Cédula",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Ingrese la cédula" : null,
                ),
                const SizedBox(height: 10),

                // Nombre
                TextFormField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(
                    labelText: "Nombre",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Ingrese el nombre" : null,
                ),
                const SizedBox(height: 10),

                // Apellido
                TextFormField(
                  controller: apellidoCtrl,
                  decoration: const InputDecoration(
                    labelText: "Apellido",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Ingrese el apellido" : null,
                ),
                const SizedBox(height: 10),

                // Correo
                TextFormField(
                  controller: correoCtrl,
                  decoration: const InputDecoration(
                    labelText: "Correo",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) =>
                      value!.isEmpty ? "Ingrese el correo" : null,
                ),
                const SizedBox(height: 10),

                // Password
                TextFormField(
                  controller: passwordCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Contraseña",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? "Ingrese la contraseña" : null,
                ),
                const SizedBox(height: 10),

                // Teléfono
                TextFormField(
                  controller: telefonoCtrl,
                  decoration: const InputDecoration(
                    labelText: "Teléfono",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) =>
                      value!.isEmpty ? "Ingrese el teléfono" : null,
                ),
                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Aquí puedes crear tu modelo y enviarlo a la API
                      final voluntario = {
                        "cedula": cedulaCtrl.text,
                        "nombre": nombreCtrl.text,
                        "apellido": apellidoCtrl.text,
                        "correo": correoCtrl.text,
                        "password": passwordCtrl.text,
                        "telefono": telefonoCtrl.text,
                      };
                      // ignore: avoid_print
                      print("📩 Datos capturados: $voluntario");
                    }
                  },
                  child: const Text("Enviar"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
