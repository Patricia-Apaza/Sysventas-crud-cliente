import 'dart:io';
import 'package:animated_floating_buttons/animated_floating_buttons.dart';
import 'package:sysventas/apis/cliente_api.dart';
import 'package:sysventas/comp/TabItem.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:sysventas/modelo/ClienteModelo.dart';
import 'package:sysventas/theme/AppTheme.dart';
import 'package:sysventas/ui/cliente/cliente_edit.dart';
import 'package:sysventas/ui/cliente/cliente_form.dart';
import 'package:sysventas/util/TokenUtil.dart';
import '../help_screen.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

class MainCliente extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ClienteApi>(create: (_) => ClienteApi.create()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        themeMode: AppTheme.useLightMode ? ThemeMode.light : ThemeMode.dark,
        theme: AppTheme.themeDataLight,
        darkTheme: AppTheme.themeDataDark,
        home: ClienteUI(),
      ),
    );
  }
}

class ClienteUI extends StatefulWidget {
  @override
  _ClienteUIState createState() => _ClienteUIState();
}

class _ClienteUIState extends State<ClienteUI> {
  late ClienteApi apiService;
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  var api;
  late List<ClienteResp> clienteL;
  late List<ClienteResp> clienteXB = [];

  @override
  void initState() {
    super.initState();
    _loanData();
  }

  _loanData() async {
    setState(() {
      _isLoading = true;
      apiService = ClienteApi.create();
      clienteXB.clear();
      Provider.of<ClienteApi>(context, listen: false)
          .getCliente(TokenUtil.TOKEN)
          .then((data) {
        clienteXB = List.from(data);
      });
    });
    await Future.delayed(Duration(seconds: 1));
    setState(() {
      clienteL = List.from(clienteXB);
      _isLoading = false;
    });
    print("entro aqui");
  }

  final GlobalKey<AnimatedFloatingActionButtonState> key = GlobalKey<AnimatedFloatingActionButtonState>();

  String text = 'Clientes';
  String subject = '';
  List<String> imageNames = [];
  List<String> imagePaths = [];
  bool _isLoading = false;

  Future onGoBack(dynamic value) async {
    setState(() {
      _loanData();
      print(value);
    });
  }

  final _controller = TextEditingController();

  void updateList(String value) {
    setState(() {
      clienteL = clienteXB
          .where(
            (element){
          return element.nombres.toLowerCase().contains(value.toLowerCase()) ||
              element.dniruc.toLowerCase().contains(value.toLowerCase()) ||
              element.tipoDocumento.toLowerCase().contains(value.toLowerCase());
        },
      ).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: AppTheme.useLightMode ? ThemeMode.light : ThemeMode.dark,
      theme: AppTheme.themeDataLight,
      darkTheme: AppTheme.themeDataDark,
      home: Scaffold(
        appBar: new AppBar(
          title: Text(
            'Lista de Clientes',
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
          actions: <Widget>[
            Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  print("Si funciona");
                },
                child: Icon(
                  Icons.search,
                  size: 26.0,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  print("Si funciona 2");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ClienteForm()),
                  ).then(onGoBack);
                },
                child: Icon(Icons.add_box_sharp),
              ),
            )
          ],
        ),
        backgroundColor: AppTheme.nearlyWhite,

        body: _isLoading?Center(child: CircularProgressIndicator(),)
            :_buildListView(context),

        bottomNavigationBar: _buildBottomTab(),
        floatingActionButton: AnimatedFloatingActionButton(
          key: key,
          fabButtons: <Widget>[
            add(),
            exportExcel(),
            inbox(),
          ],
          colorStartAnimation: AppTheme.themeData.colorScheme.inversePrimary,
          colorEndAnimation: Colors.red,
          animatedIconData: AnimatedIcons.menu_close,
        ),
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric( horizontal: 8.0),
                child: TextFormField(
                  onChanged: (value) => updateList(value),
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: "Buscar Clientes...",
                    filled: true,
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.black,
                    ),
                    suffixIcon: IconButton(
                        icon: const Icon(
                          Icons.clear_sharp,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          _controller.clear();
                          updateList(_controller.value.text);
                        }),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),

              Container(
                height: MediaQuery.of(context).size.height,
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
                    child: ListView.builder(
                        itemCount: clienteL.length,
                        itemBuilder: (context, index) {
                          ClienteResp clientex = clienteL[index];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Card(
                              child: Container(
                                height: 120,
                                padding: const EdgeInsets.all(5.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    ListTile(
                                        title: Row(
                                          children: [
                                            Container(
                                              child: Text(clientex.nombres,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium),
                                            )
                                          ],
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: <Widget>[
                                                  Container(
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(8),
                                                        color: AppTheme.themeData.colorScheme.primaryContainer),
                                                    child: Padding(
                                                      padding: EdgeInsets.all(4.0),
                                                      child: Text(
                                                        '${clientex.tipoDocumento}: ${clientex.dniruc}',
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontSize: 14),
                                                      ),
                                                    ),
                                                  ),
                                                ]
                                            ),
                                            if (clientex.repLegal.isNotEmpty)
                                              Padding(
                                                padding: EdgeInsets.only(top: 4.0),
                                                child: Text(
                                                  'Rep. Legal: ${clientex.repLegal}',
                                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                                ),
                                              ),
                                            if (clientex.direccion.isNotEmpty)
                                              Padding(
                                                padding: EdgeInsets.only(top: 2.0),
                                                child: Text(
                                                  'Dir: ${clientex.direccion}',
                                                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                          ],
                                        ),
                                        leading: CircleAvatar(
                                          backgroundImage: AssetImage(
                                              "assets/imagen/man-icon.png"),
                                        ),
                                        trailing: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: <Widget>[
                                              Container(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Expanded(
                                                        child: IconButton(
                                                            icon: Icon(Icons.edit),
                                                            iconSize: 24,
                                                            padding: EdgeInsets.zero,
                                                            constraints: BoxConstraints(),
                                                            onPressed: () {
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        ClienteFormEdit(
                                                                            modelA: clientex)
                                                                ),
                                                              ).then(onGoBack);
                                                            })),
                                                    Expanded(
                                                        child: IconButton(
                                                            icon: Icon(Icons.delete),
                                                            iconSize: 24,
                                                            padding: EdgeInsets.zero,
                                                            constraints: BoxConstraints(),
                                                            onPressed: () {
                                                              showDialog(
                                                                  context: context,
                                                                  barrierDismissible: true,
                                                                  builder: (BuildContext context) {
                                                                    return AlertDialog(
                                                                      title: Text("Mensaje de confirmacion"),
                                                                      content: Text("¿Desea Eliminar el cliente ${clientex.nombres}?"),
                                                                      actions: [
                                                                        TextButton(
                                                                          child: const Text('CANCELAR'),
                                                                          onPressed: () {
                                                                            Navigator.of(context).pop('Failure');
                                                                          },
                                                                        ),
                                                                        TextButton(
                                                                            child: const Text('ACEPTAR'),
                                                                            onPressed: () {
                                                                              Navigator.of(context).pop('Success');
                                                                            })
                                                                      ],
                                                                    );
                                                                  }).then((value) {
                                                                if (value.toString() == "Success") {
                                                                  print(clientex.dniruc);
                                                                  Provider.of<ClienteApi>(context, listen: false)
                                                                      .deleteCliente(TokenUtil.TOKEN, clientex.dniruc)
                                                                      .then((value) => _loanData());
                                                                }
                                                              });
                                                            }))
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: IconButton(
                                                        icon: Icon(Icons.visibility),
                                                        padding: EdgeInsets.zero,
                                                        constraints: BoxConstraints(),
                                                        onPressed: () {
                                                          _showClienteDetails(clientex);
                                                        },
                                                      ),
                                                    ),
                                                    Expanded(child: Builder(
                                                      builder: (BuildContext context) {
                                                        return IconButton(
                                                          icon: Icon(Icons.send_and_archive_sharp),
                                                          padding: EdgeInsets.zero,
                                                          constraints: BoxConstraints(),
                                                          onPressed: () async {
                                                            //await exportClienteToExcel([clientex]);
                                                            await Future.delayed(const Duration(seconds: 1));
                                                            print("OJO:${imagePaths.isEmpty}");
                                                            text = "Exportando Cliente: ${clientex.nombres}";
                                                            if (!text.isEmpty && imagePaths.isNotEmpty) {
                                                              _onShare(context);
                                                              Fluttertoast.showToast(
                                                                  msg: "Exportado correctamente",
                                                                  toastLength: Toast.LENGTH_LONG,
                                                                  gravity: ToastGravity.CENTER,
                                                                  timeInSecForIosWeb: 1,
                                                                  backgroundColor: Colors.blue,
                                                                  textColor: Colors.white,
                                                                  fontSize: 16.0
                                                              );
                                                            } else {
                                                              Fluttertoast.showToast(
                                                                  msg: "Error al compartir",
                                                                  toastLength: Toast.LENGTH_LONG,
                                                                  gravity: ToastGravity.CENTER,
                                                                  timeInSecForIosWeb: 1,
                                                                  backgroundColor: Colors.red,
                                                                  textColor: Colors.white,
                                                                  fontSize: 16.0
                                                              );
                                                            }
                                                          },
                                                        );
                                                      },
                                                    ))
                                                  ],
                                                ),
                                              )
                                            ])),
                                  ],
                                ),
                              ),
                            ),
                          );
                        })),
              ),
            ])),
      ],
    );
  }

  void _showClienteDetails(ClienteResp cliente) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles del Cliente'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Nombre/Razón Social:', cliente.nombres),
                _buildDetailRow('Tipo Documento:', cliente.tipoDocumento),
                _buildDetailRow('DNI/RUC:', cliente.dniruc),
                if (cliente.repLegal.isNotEmpty)
                  _buildDetailRow('Rep. Legal:', cliente.repLegal),
                if (cliente.direccion.isNotEmpty)
                  _buildDetailRow('Dirección:', cliente.direccion),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value.isEmpty ? 'No especificado' : value),
          ),
        ],
      ),
    );
  }

  int selectedPosition = 0;
  final tabs = ['Home', 'Profile', 'Help', 'Settings'];

  _buildBottomTab() {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TabItem(
            icon: Icons.menu,
            text: tabs[0],
            isSelected: selectedPosition == 0,
            onTap: () {
              setState(() {
                selectedPosition = 0;
              });
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return HelpScreen();
              }));
            },
          ),
          TabItem(
            icon: Icons.person,
            text: tabs[1],
            isSelected: selectedPosition == 1,
            onTap: () {
              setState(() {
                selectedPosition = 1;
              });
            },
          ),
          TabItem(
            text: tabs[2],
            icon: Icons.help,
            isSelected: selectedPosition == 2,
            onTap: () {
              setState(() {
                selectedPosition = 2;
              });
            },
          ),
          TabItem(
            text: tabs[3],
            icon: Icons.settings,
            isSelected: selectedPosition == 3,
            onTap: () {
              setState(() {
                selectedPosition = 3;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget add() {
    return Container(
      child: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ClienteForm()),
          ).then(onGoBack);
          key.currentState?.closeFABs();
        },
        heroTag: "Add",
        tooltip: 'Agregar Cliente',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget exportExcel() {
    return Container(
      child: FloatingActionButton(
        onPressed: () async {
          //await exportClienteToExcel(clienteL);
          await Future.delayed(const Duration(seconds: 1));
          text = "Exportando todos los clientes";
          if (!text.isEmpty && imagePaths.isNotEmpty) {
            _onShare(context);
            Fluttertoast.showToast(
                msg: "Exportado correctamente",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.blue,
                textColor: Colors.white,
                fontSize: 16.0
            );
          } else {
            Fluttertoast.showToast(
                msg: "Error al exportar",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0
            );
          }
          key.currentState?.closeFABs();
        },
        heroTag: "Export",
        tooltip: 'Exportar Excel',
        child: Icon(Icons.table_chart),
      ),
    );
  }

  Widget inbox() {
    return Container(
      child: FloatingActionButton(
        onPressed: () {
          key.currentState?.closeFABs();
        },
        heroTag: "Inbox",
        tooltip: 'Inbox',
        child: Icon(Icons.inbox),
      ),
    );
  }

  /*Future<void> exportClienteToExcel(List<ClienteResp> clientes) async {
    try {
      // Limpiar rutas previas
      imagePaths.clear();
      imageNames.clear();

      // Crear un nuevo archivo Excel
      var excel = Excel.createExcel();

      // Crear una nueva hoja en el archivo Excel
      Sheet sheetObject = excel['Clientes'];

      // Escribir los encabezados de columna en la primera fila
      List<String> headers = ['Tipo Documento', 'DNI/RUC', 'Nombres/Razón Social', 'Representante Legal', 'Dirección'];
      for (var col = 0; col < headers.length; col++) {
        CellIndex cellIndex = CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0);
        sheetObject.cell(cellIndex).value = headers[col];
      }

      // Escribir los datos de clientes en las filas siguientes
      for (var row = 0; row < clientes.length; row++) {
        ClienteResp cliente = clientes[row];
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row + 1))
            .value = cliente.tipoDocumento;
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row + 1))
            .value = cliente.dniruc;
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row + 1))
            .value = cliente.nombres;
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row + 1))
            .value = cliente.repLegal;
        sheetObject
            .cell(CellIndex.indexByColumnRow(columnIndex: 4, rowIndex: row + 1))
            .value = cliente.direccion;
      }

      // Guardar el archivo Excel en el sistema de archivos
      await saveExcel(excel, 'clientes.xlsx');
    } catch (e) {
      print('Error al exportar clientes a Excel: $e');
      Fluttertoast.showToast(
          msg: "Error al exportar: $e",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
  }*/

  Future<void> saveExcel(Excel excel, String fileName) async {
    try {
      var bytes = excel.encode();
      var dir = await getExternalStorageDirectory();

      if (dir != null) {
        print('Directorio de almacenamiento externo: ${dir.path}');
        var nonbreakable = '${DateTime.now().toIso8601String()}-$fileName';

        var file = File('${dir.path}/$nonbreakable');

        if (!await dir.exists()) {
          await dir.create(recursive: true);
        }

        await file.writeAsBytes(bytes!);

        imagePaths.add(file.path);
        imageNames.add(nonbreakable);
        print('Archivo guardado correctamente en: ${file.path}');
      } else {
        print('No se pudo obtener el directorio de almacenamiento externo');
      }
    } catch (e) {
      print('Error al guardar el archivo Excel: $e');
    }
  }

  void _onShare(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    if (imagePaths.isNotEmpty) {
      final files = <XFile>[];
      for (var i = 0; i < imagePaths.length; i++) {
        files.add(XFile(imagePaths[i], name: imageNames[i]));
      }
      await Share.shareXFiles(files,
          text: text,
          subject: subject,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    } else {
      await Share.share(text,
          subject: subject,
          sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size);
    }
  }
}
