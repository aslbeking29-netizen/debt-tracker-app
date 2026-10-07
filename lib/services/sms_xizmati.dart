import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/qarzdor.dart';

class SmsXizmati {
  /// Eskiz.uz kabinetidagi token. O'zingiznikiga almashtiring.
  static const String eskizToken = 'SIZNING_TOKENINGIZ';

  static const String _yuborishManzili =
      'https://notify.eskiz.uz/api/message/sms/send';

  String smsMatni(Qarzdor qarzdor) {
    final summa = _summaYoz(qarzdor.qarzMiqdori);
    return "Hurmatli ${qarzdor.ismi}, do'kondagi $summa so'mlik qarzingizni qaytarish muddati ertaga. Iltimos, to'lab qo'ying.";
  }

  Future<bool> smsYubor(Qarzdor qarzdor) async {
    final javob = await http.post(
      Uri.parse(_yuborishManzili),
      headers: {
        'Authorization': 'Bearer $eskizToken',
      },
      body: {
        'mobile_phone': qarzdor.telefon,
        'message': smsMatni(qarzdor),
        'from': '4546',
      },
    ).timeout(const Duration(seconds: 25));

    if (javob.statusCode < 200 || javob.statusCode >= 300) {
      return false;
    }

    final tanasi = javob.body.trim();
    if (tanasi.isEmpty) {
      return true;
    }

    try {
      final decoded = jsonDecode(tanasi);
      if (decoded is Map<String, dynamic>) {
        final status = decoded['status']?.toString().toLowerCase();
        if (status == 'error' || status == 'fail' || status == 'failed') {
          return false;
        }
      }
    } on FormatException {
      return javob.statusCode == 200;
    }

    return true;
  }

  /// Qaytarish sanasiga aynan 1 kun qolgan va hali SMS yuborilmagan mijozlarga
  /// Eskiz.uz orqali SMS yuboradi. Muvaffaqiyatli yuborilganlarda
  /// [Qarzdor.smsYuborildi] qiymati `true` bo'ladi.
  Future<SmsTekshiruvNatija> eslatmalarniYubor(List<Qarzdor> royxat) async {
    final bugun = _faqatSana(DateTime.now());
    final yangilangan = <Qarzdor>[];
    var yuborildi = 0;
    var xato = 0;

    for (final qarzdor in royxat) {
      final qaytarish = _faqatSana(qarzdor.qaytarishSana);
      final kunFarqi = qaytarish.difference(bugun).inDays;
      final kerak = kunFarqi == 1 && qarzdor.smsYuborildi == false;

      if (!kerak) {
        yangilangan.add(qarzdor);
        continue;
      }

      try {
        final muvaffaqiyat = await smsYubor(qarzdor);
        if (muvaffaqiyat) {
          yuborildi += 1;
          yangilangan.add(qarzdor.copyWith(smsYuborildi: true));
        } else {
          xato += 1;
          yangilangan.add(qarzdor);
        }
      } catch (_) {
        xato += 1;
        yangilangan.add(qarzdor);
      }
    }

    return SmsTekshiruvNatija(
      royxat: yangilangan,
      yuborilganSoni: yuborildi,
      xatoSoni: xato,
    );
  }

  DateTime _faqatSana(DateTime s) => DateTime(s.year, s.month, s.day);

  String _summaYoz(double qiymat) {
    if (qiymat == qiymat.roundToDouble()) {
      return qiymat.toStringAsFixed(0);
    }
    return qiymat.toStringAsFixed(2);
  }
}

class SmsTekshiruvNatija {
  final List<Qarzdor> royxat;
  final int yuborilganSoni;
  final int xatoSoni;

  const SmsTekshiruvNatija({
    required this.royxat,
    required this.yuborilganSoni,
    required this.xatoSoni,
  });
}
