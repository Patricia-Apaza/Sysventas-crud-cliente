import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sysventas/apis/cliente_api.dart';
import 'package:sysventas/modelo/ClienteModelo.dart';
import 'package:sysventas/util/TokenUtil.dart';

class ClienteForm extends StatefulWidget {
  const ClienteForm({super.key});

  @override
  State<ClienteForm> createState() => _ClienteFormState();
}

class _ClienteFormState extends State<ClienteForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final dnirucController = TextEditingController();
  final nombresController = TextEditingController();
  final repLegalController = TextEditingController();
  final direccionController = TextEditingController();

  String? selectedTipoDocumento;
  final tiposDocumento = [
    {'value': 'DNI', 'display': 'DNI'},
    {'value': 'RUC', 'display': 'RUC'},
    {'value': 'CE', 'display': 'Carnet de Extranjería'},
    {'value': 'PASAPORTE', 'display': 'Pasaporte'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Cliente')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: dnirucController,
                decoration: const InputDecoration(labelText: 'DNI/RUC'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: nombresController,
                decoration: const InputDecoration(labelText: 'Nombres/Razón Social'),
                validator: (value) => value!.isEmpty ? 'Campo requerido' : null,
              ),
              TextFormField(
                controller: repLegalController,
                decoration: const InputDecoration(labelText: 'Representante Legal'),
              ),
              DropdownButtonFormField<String>(
                value: selectedTipoDocumento,
                items: tiposDocumento.map((tipo) {
                  return DropdownMenuItem(
                      value: tipo['value'],
                      child: Text(tipo['display']!)
                  );
                }).toList(),
                onChanged: (value) => setState(() => selectedTipoDocumento = value),
                decoration: const InputDecoration(labelText: 'Tipo de Documento'),
                validator: (value) => value == null ? 'Seleccione un tipo de documento' : null,
              ),
              TextFormField(
                controller: direccionController,
                decoration: const InputDecoration(labelText: 'Dirección'),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: (){
                      Navigator.pop(context, true);
                    },
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: _registrarCliente,
                    child: const Text('Guardar'),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void _registrarCliente() async{
    if (_formKey.currentState!.validate()) {
      final cliente = ClienteDto(
        dniruc: dnirucController.text,
        nombres: nombresController.text,
        repLegal: repLegalController.text,
        tipoDocumento: selectedTipoDocumento ?? '',
        direccion: direccionController.text,
      );

      try {
        var api = await Provider.of<ClienteApi>(context, listen: false)
            .crearCliente(TokenUtil.TOKEN, cliente);

        if (api.toJson() != null) {
          Navigator.pop(context, () {setState(() {}); });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Cliente registrado exitosamente')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al registrar cliente: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete todos los campos requeridos')),
      );
    }
  }
}
