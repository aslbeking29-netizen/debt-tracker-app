import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/qarzdor.dart';

class SaqlashXizmati {
  static const String _faylNomi = 'qarzdorlar.json';

  Future<Directory> hujjatlarPapkasi() async {
    return getApplicationDocumentsDirectory();
  }

  Future<File> _malumotFayli() async {
    final dir = await hujjatlarPapkasi();
    return File(p.join(dir.path, _faylNomi));
  }

  Future<Directory> rasmlarPapkasi() async {
    final dir = await hujjatlarPapkasi();
    final rasmlar = Directory(p.join(dir.path, 'rasmlar'));
    if (!await rasmlar.exists()) {
      await rasmlar.create(recursive: true);
    }
    return rasmlar;
  }

  Future<String> rasmniSaqla(String vaqtinchalikYol, String id) async {
    final papka = await rasmlarPapkasi();
    final kengaytma = p.extension(vaqtinchalikYol).isEmpty
        ? '.jpg'
        : p.extension(vaqtinchalikYol);
    final manzil = File(p.join(papka.path, '$id$kengaytma'));
    final nusxa = await File(vaqtinchalikYol).copy(manzil.path);
    return nusxa.path;
  }

  Future<List<Qarzdor>> yukla() async {
    final fayl = await _malumotFayli();
    if (!await fayl.exists()) {
      return [];
    }
    final matn = await fayl.readAsString();
    if (matn.trim().isEmpty) {
      return [];
    }
    final decoded = jsonDecode(matn);
    if (decoded is! List) {
      return [];
    }
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Qarzdor.fromJson)
        .toList();
  }

  Future<void> saqla(List<Qarzdor> royxat) async {
    final fayl = await _malumotFayli();
    final jsonRoyxat = royxat.map((q) => q.toJson()).toList();
    await fayl.writeAsString(const JsonEncoder.withIndent('  ').convert(jsonRoyxat));
  }
}
