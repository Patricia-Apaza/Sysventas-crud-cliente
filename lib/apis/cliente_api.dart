import 'package:dio/dio.dart';
import 'package:sysventas/util/UrlApi.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:retrofit/http.dart';
import 'package:retrofit/retrofit.dart';
import 'package:sysventas/modelo/MessageModelo.dart';
import 'package:sysventas/modelo/ClienteModelo.dart';

part 'cliente_api.g.dart';

@RestApi(baseUrl: UrlApi.urlApix)
abstract class ClienteApi{
  factory ClienteApi(Dio dio, {String baseUrl})=_ClienteApi;

  static ClienteApi create(){
    final dio=Dio();
    dio.interceptors.add(PrettyDioLogger());
    return ClienteApi(dio);
  }

  @GET("/clientes")
  Future<List<ClienteResp>> getCliente(@Header("Authorization") String token);

  @POST("/clientes")
  Future<Message> crearCliente(@Header("Authorization") String token, @Body() ClienteDto cliente);

  @GET("/clientes/{id}")
  Future<ClienteResp> findCliente(@Header("Authorization") String token, @Path("id") String id);

  @DELETE("/clientes/{id}")
  Future<Message> deleteCliente(@Header("Authorization") String token, @Path("id") String id);

  @PUT("/clientes/{id}")
  Future<ClienteResp> updateCliente(@Header("Authorization") String token, @Path("id") String id, @Body() ClienteDto cliente);
}
