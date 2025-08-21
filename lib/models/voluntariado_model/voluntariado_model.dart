class VoluntariadoModel {
  String? cedula, nombre, apellido, correo, password, telefono;

  VoluntariadoModel({
    this.cedula,
    this.nombre,
    this.apellido,
    this.correo,
    this.password,
    this.telefono,
  });

  Map<String, dynamic> toJson() {
    return {
      "cedula": cedula,
      "nombre": nombre,
      "apellido": apellido,
      "correo": correo,
      "password": password,
      "telefono": telefono,
    };
  }
}
