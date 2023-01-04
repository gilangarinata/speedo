

class RouteModel {
  String terminal;
  double terminalLat;
  double terminalLong;
  String idBus;
  int noRute;

  RouteModel({required this.terminal, required this.terminalLat, required this.terminalLong, required this.idBus,
      required this.noRute});

  factory RouteModel.fromJson(Map<String, dynamic> json) => RouteModel(
    terminal: json["terminal"],
    terminalLat: json["terminalLat"],
    terminalLong: json["terminalLong"],
    idBus: json["idBus"],
    noRute: json["noRute"]
  );

  Map<String, dynamic> toJson() => {
    "terminal": terminal,
    "terminalLat": terminalLat,
    "terminalLong": terminalLong,
    "idBus": idBus,
    "noRute": noRute
  };
}