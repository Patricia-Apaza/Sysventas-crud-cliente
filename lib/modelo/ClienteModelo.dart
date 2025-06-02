class ClienteResp {
  ClienteResp({
    required this.dniruc,
    required this.nombres,
    required this.repLegal,
    required this.tipoDocumento,
    required this.direccion,
  });

  final String dniruc;
  final String nombres;
  final String repLegal;
  final String tipoDocumento;
  final String direccion;

  factory ClienteResp.fromJson(Map<String, dynamic> json){
    return ClienteResp(
      dniruc: json["dniruc"] ?? "",
      nombres: json["nombres"] ?? "",
      repLegal: json["repLegal"] ?? "",
      tipoDocumento: json["tipoDocumento"] ?? "",
      direccion: json["direccion"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "dniruc": dniruc,
    "nombres": nombres,
    "repLegal": repLegal,
    "tipoDocumento": tipoDocumento,
    "direccion": direccion,
  };

  static ClienteResp crear() {
    return ClienteResp(
      dniruc: "",
      nombres: "",
      repLegal: "",
      tipoDocumento: "",
      direccion: "",
    );
  }
}

class ClienteDto {
  ClienteDto({
    required this.dniruc,
    required this.nombres,
    required this.repLegal,
    required this.tipoDocumento,
    required this.direccion,
  });

  late final String dniruc;
  late final String nombres;
  late final String repLegal;
  late final String tipoDocumento;
  late final String direccion;

  ClienteDto.unlaunched();

  factory ClienteDto.fromJson(Map<String, dynamic> json){
    return ClienteDto(
      dniruc: json["dniruc"] ?? "",
      nombres: json["nombres"] ?? "",
      repLegal: json["repLegal"] ?? "",
      tipoDocumento: json["tipoDocumento"] ?? "",
      direccion: json["direccion"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "dniruc": dniruc,
    "nombres": nombres,
    "repLegal": repLegal,
    "tipoDocumento": tipoDocumento,
    "direccion": direccion,
  };
}
