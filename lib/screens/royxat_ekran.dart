import 'dart:io';

import 'package:flutter/material.dart';

import '../models/qarzdor.dart';
import '../services/saqlash_xizmati.dart';
import '../services/sms_xizmati.dart';
import 'qoshish_ekran.dart';

class RoyxatEkran extends StatefulWidget {
  const RoyxatEkran({super.key});

  @override
  State<RoyxatEkran> createState() => _RoyxatEkranState();
}

class _RoyxatEkranState extends State<RoyxatEkran> {
  final _saqlash = SaqlashXizmati();
  final _sms = SmsXizmati();
  List<Qarzdor> _royxat = [];
  bool _yuklanmoqda = true;
  bool _smsTekshirilmoqda = false;

  @override
  void initState() {
    super.initState();
    _yukla();
  }

  Future<void> _yukla() async {
    try {
      final malumot = await _saqlash.yukla();
      if (!mounted) {
        return;
      }
      setState(() {
        _royxat = malumot;
        _yuklanmoqda = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _royxat = [];
        _yuklanmoqda = false;
      });
    }
  }

  Future<void> _yangiQosh() async {
    final natija = await Navigator.of(context).push<Qarzdor>(
      MaterialPageRoute(builder: (_) => const QoshishEkran()),
    );
    if (natija == null) {
      return;
    }
    final yangi = [..._royxat, natija];
    await _saqlash.saqla(yangi);
    if (!mounted) {
      return;
    }
    setState(() => _royxat = yangi);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${natija.ismi} saqlandi')),
    );
  }

  Future<void> _eslatmalarniYubor() async {
    if (_smsTekshirilmoqda) {
      return;
    }
    setState(() => _smsTekshirilmoqda = true);
    try {
      final natija = await _sms.eslatmalarniYubor(_royxat);
      await _saqlash.saqla(natija.royxat);
      if (!mounted) {
        return;
      }
      setState(() => _royxat = natija.royxat);

      final xabar = natija.yuborilganSoni == 0 && natija.xatoSoni == 0
          ? 'Ertaga muddati tugaydigan, SMS kutilayotgan mijoz yo‘q.'
          : 'Yuborildi: ${natija.yuborilganSoni}. Xato: ${natija.xatoSoni}.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(xabar)));
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('SMS yuborishda xato: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _smsTekshirilmoqda = false);
      }
    }
  }

  String _sanaYoz(DateTime s) {
    final kun = s.day.toString().padLeft(2, '0');
    final oy = s.month.toString().padLeft(2, '0');
    return '$kun.$oy.${s.year}';
  }

  String _summaYoz(double qiymat) {
    final butun = qiymat == qiymat.roundToDouble();
    final asos = butun ? qiymat.toStringAsFixed(0) : qiymat.toStringAsFixed(2);
    final qismlar = asos.split('.');
    final belgi = StringBuffer();
    final raqamlar = qismlar[0];
    for (var i = 0; i < raqamlar.length; i++) {
      final qolgan = raqamlar.length - i;
      if (i != 0 && qolgan % 3 == 0) {
        belgi.write(' ');
      }
      belgi.write(raqamlar[i]);
    }
    if (qismlar.length > 1) {
      belgi.write('.${qismlar[1]}');
    }
    return "${belgi.toString()} so'm";
  }

  Widget _avatar(Qarzdor q) {
    final fayl = File(q.rasmPath);
    if (q.rasmPath.isNotEmpty && fayl.existsSync()) {
      return CircleAvatar(backgroundImage: FileImage(fayl));
    }
    final harf = q.ismi.isNotEmpty ? q.ismi[0].toUpperCase() : '?';
    return CircleAvatar(child: Text(harf));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Qarz Daftari'),
        actions: [
          IconButton(
            tooltip: 'SMS eslatmalarini yuborish',
            onPressed: _smsTekshirilmoqda ? null : _eslatmalarniYubor,
            icon: _smsTekshirilmoqda
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.sms),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _yangiQosh,
        tooltip: 'Yangi qarzdor',
        child: const Icon(Icons.add),
      ),
      body: _yuklanmoqda
          ? const Center(child: CircularProgressIndicator())
          : _royxat.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.menu_book_outlined,
                          size: 72,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Hozircha qarzdor yo‘q',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Pastdagi + tugmasi orqali yangi yozuv qo‘shing.',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 96),
                  itemCount: _royxat.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final q = _royxat[index];
                    return Card(
                      elevation: 0,
                      color: Theme.of(context).colorScheme.surfaceContainerLow,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: _avatar(q),
                        title: Text(
                          q.ismi,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(q.telefon),
                              const SizedBox(height: 2),
                              Text('Qaytarish: ${_sanaYoz(q.qaytarishSana)}'),
                              const SizedBox(height: 4),
                              Text(
                                _summaYoz(q.qarzMiqdori),
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        isThreeLine: true,
                        trailing: Tooltip(
                          message: q.smsYuborildi
                              ? 'SMS yuborilgan'
                              : 'SMS kutilayotgan',
                          child: Icon(
                            q.smsYuborildi
                                ? Icons.mark_email_read
                                : Icons.sms_outlined,
                            color: q.smsYuborildi
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outline,
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
