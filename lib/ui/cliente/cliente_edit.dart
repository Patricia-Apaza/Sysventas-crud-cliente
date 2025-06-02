import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sysventas/apis/cliente_api.dart';
import 'package:sysventas/modelo/ClienteModelo.dart';
import 'package:sysventas/util/TokenUtil.dart';

class ClienteFormEdit extends StatefulWidget {
  ClienteResp modelA;
  ClienteFormEdit({required this.modelA}):super();

  @override
  _ClienteFormEditState createState() => _ClienteFormEditState(modelA: modelA);
}

class _ClienteFormEditState extends State<ClienteFormEdit> {
  ClienteResp modelA;
  _ClienteFormEditState({required this.modelA}):super();

  final _formKey = GlobalKey<FormState>();

  late String _dniruc = "";
  late String _nombres = "";
  late String _repLegal = "";
  late String _tipoDocumento = "";
  late String _direccion = "";

  final tiposDocumento = [
    {'value': 'DNI', 'display': 'DNI'},
    {'value': 'RUC', 'display': 'RUC'},
    {'value': 'CE', 'display': 'Carnet de Extranjería'},
    {'value': 'PASAPORTE', 'display': 'Pasaporte'},
  ];

  @override
  void initState(){
    super.initState();
    _tipoDocumento = modelA.tipoDocumento;
  }

  void capturaDniruc(valor){ this._dniruc = valor;}
  void capturaNombres(valor){ this._nombres = valor;}
  void capturaRepLegal(valor){ this._repLegal = valor;}
  void capturaTipoDocumento(valor){ this._tipoDocumento = valor;}
  void capturaDireccion(valor){ this._direccion = valor;}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Form. Act. Cliente"),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          child: Container(
              margin: EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    _buildDatoCadena(capturaDniruc, modelA.dniruc, "DNI/RUC:"),
                    _buildDatoCadena(capturaNombres, modelA.nombres, "Nombres/Razón Social:"),
                    _buildDatoCadena(capturaRepLegal, modelA.repLegal, "Representante Legal:"),
                    _buildDatoLista(capturaTipoDocumento, _tipoDocumento, "Tipo de Documento:", tiposDocumento),
                    _buildDatoCadena(capturaDireccion, modelA.direccion, "Dirección:"),

                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context, true);
                              },
                              child: Text('Cancelar')
                          ),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Processing Data'),
                                  ),
                                );
                                _formKey.currentState!.save();

                                ClienteDto mc = new ClienteDto.unlaunched();
                                mc.dniruc = _dniruc;
                                mc.nombres = _nombres;
                                mc.repLegal = _repLegal;
                                mc.tipoDocumento = _tipoDocumento;
                                mc.direccion = _direccion;

                                try {
                                  var api = await Provider.of<ClienteApi>(
                                      context,
                                      listen: false)
                                      .updateCliente(TokenUtil.TOKEN, modelA.dniruc, mc);

                                  print("ver: ${api.toJson()}");

                                  if (api.toJson() != null) {
                                    Navigator.pop(context, () {
                                      setState(() {});
                                    });
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error al actualizar: $e')),
                                  );
                                }
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Complete todos los campos requeridos'),
                                  ),
                                );
                              }
                            },
                            child: const Text('Guardar'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
          )
      ),
    );
  }

  Widget _buildDatoCadena(Function obtValor, String _dato, String label) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      initialValue: _dato,
      keyboardType: TextInputType.text,
      validator: (String? value) {
        if (value!.isEmpty && (label.contains('DNI') || label.contains('Nombres'))) {
          return 'Campo Requerido!';
        }
        return null;
      },
      onSaved: (String? value) {
        obtValor(value!);
      },
    );
  }

  Widget _buildDatoLista(Function obtValor, _dato, String label, List<dynamic> listaDato) {
    return DropdownButtonFormField<String>(
      value: _dato.isEmpty ? null : _dato,
      items: listaDato.map((tipo) {
        return DropdownMenuItem<String>(
            value: tipo['value'],
            child: Text(tipo['display'])
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          obtValor(value);
        });
      },
      decoration: InputDecoration(labelText: label),
      validator: (value) => value == null ? 'Seleccione una opción' : null,
      onSaved: (value) {
        setState(() {
          obtValor(value);
        });
      },
    );
  }
}
