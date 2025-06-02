import 'package:dio/dio.dart';
import 'package:sysventas/apis/cliente_api.dart';
import 'package:sysventas/modelo/MessageModelo.dart';
import 'package:sysventas/modelo/ClienteModelo.dart';
import 'package:sysventas/util/TokenUtil.dart';

class ClienteRepository {
  ClienteApi? clienteApi;

  ClienteRepository() {
    Dio dio = Dio();
    dio.options.headers["Content-Type"] = "application/json";
    clienteApi = ClienteApi(dio);
  }

  Future<List<ClienteResp>> getEntidad() async {
    return await clienteApi!.getCliente(TokenUtil.TOKEN).then((value) => value);
  }

  Future<Message> deleteEntidad(String id) async {
    return await clienteApi!.deleteCliente(TokenUtil.TOKEN, id);
  }

  Future<ClienteResp> updateEntidad(String id, ClienteDto cliente) async {
    return await clienteApi!.updateCliente(TokenUtil.TOKEN, id, cliente);
  }

  Future<Message> createEntidad(ClienteDto cliente) async {
    return await clienteApi!.crearCliente(TokenUtil.TOKEN, cliente);
  }

  Future<ClienteResp> findEntidad(String id) async {
    return await clienteApi!.findCliente(TokenUtil.TOKEN, id);
  }
}
