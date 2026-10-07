class Qarzdor {
  final String id;
  final String ismi;
  final String telefon;
  final String rasmPath;
  final double qarzMiqdori;
  final DateTime olinganSana;
  final DateTime qaytarishSana;
  final bool smsYuborildi;

  const Qarzdor({
    required this.id,
    required this.ismi,
    required this.telefon,
    required this.rasmPath,
    required this.qarzMiqdori,
    required this.olinganSana,
    required this.qaytarishSana,
    this.smsYuborildi = false,
  });

  Qarzdor copyWith({
    String? id,
    String? ismi,
    String? telefon,
    String? rasmPath,
    double? qarzMiqdori,
    DateTime? olinganSana,
    DateTime? qaytarishSana,
    bool? smsYuborildi,
  }) {
    return Qarzdor(
      id: id ?? this.id,
      ismi: ismi ?? this.ismi,
      telefon: telefon ?? this.telefon,
      rasmPath: rasmPath ?? this.rasmPath,
      qarzMiqdori: qarzMiqdori ?? this.qarzMiqdori,
      olinganSana: olinganSana ?? this.olinganSana,
      qaytarishSana: qaytarishSana ?? this.qaytarishSana,
      smsYuborildi: smsYuborildi ?? this.smsYuborildi,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ismi': ismi,
      'telefon': telefon,
      'rasmPath': rasmPath,
      'qarzMiqdori': qarzMiqdori,
      'olinganSana': olinganSana.toIso8601String(),
      'qaytarishSana': qaytarishSana.toIso8601String(),
      'smsYuborildi': smsYuborildi,
    };
  }

  factory Qarzdor.fromJson(Map<String, dynamic> json) {
    return Qarzdor(
      id: json['id'] as String,
      ismi: json['ismi'] as String,
      telefon: json['telefon'] as String,
      rasmPath: json['rasmPath'] as String,
      qarzMiqdori: (json['qarzMiqdori'] as num).toDouble(),
      olinganSana: DateTime.parse(json['olinganSana'] as String),
      qaytarishSana: DateTime.parse(json['qaytarishSana'] as String),
      smsYuborildi: json['smsYuborildi'] as bool? ?? false,
    );
  }
}
