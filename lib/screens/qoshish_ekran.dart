import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/qarzdor.dart';
import '../services/saqlash_xizmati.dart';

class QoshishEkran extends StatefulWidget {
  const QoshishEkran({super.key});

  @override
  State<QoshishEkran> createState() => _QoshishEkranState();
}

class _QoshishEkranState extends State<QoshishEkran> {
  final _formaKaliti = GlobalKey<FormState>();
  final _ismKontroller = TextEditingController();
  final _telefonKontroller = TextEditingController(text: '998');
  final _summaKontroller = TextEditingController();
  final _saqlash = SaqlashXizmati();
  final _picker = ImagePicker();

  String? _rasmPath;
  DateTime _qaytarishSana = DateTime.now().add(const Duration(days: 7));
  bool _rasmOlinmoqda = false;
  bool _saqlanmoqda = false;

  @override
  void dispose() {
    _ismKontroller.dispose();
    _telefonKontroller.dispose();
    _summaKontroller.dispose();
    super.dispose();
  }

  Future<void> _kameraniOch() async {
    setState(() => _rasmOlinmoqda = true);
    try {
      final rasm = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (rasm == null) {
        return;
      }
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final yol = await _saqlash.rasmniSaqla(rasm.path, id);
      if (!mounted) {
        return;
      }
      setState(() => _rasmPath = yol);
    } on PlatformException catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kamerani ochib bo‘lmadi: ${e.message ?? e.code}')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Rasm saqlanmadi: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _rasmOlinmoqda = false);
      }
    }
  }

  Future<void> _sananiTanla() async {
    final bugun = DateTime.now();
    final tanlangan = await showDatePicker(
      context: context,
      initialDate: _qaytarishSana.isBefore(bugun) ? bugun : _qaytarishSana,
      firstDate: DateTime(bugun.year, bugun.month, bugun.day),
      lastDate: DateTime(bugun.year + 5, bugun.month, bugun.day),
      helpText: 'Qaytarish muddati',
      cancelText: 'Bekor',
      confirmText: 'Tanlash',
    );
    if (tanlangan != null) {
      setState(() => _qaytarishSana = tanlangan);
    }
  }

  String? _ismTekshir(String? qiymat) {
    final matn = qiymat?.trim() ?? '';
    if (matn.isEmpty) {
      return 'Ismni kiriting';
    }
    if (matn.length < 2) {
      return 'Ism kamida 2 belgidan iborat bo‘lsin';
    }
    return null;
  }

  String? _telefonTekshir(String? qiymat) {
    final matn = (qiymat ?? '').replaceAll(' ', '');
    final andoza = RegExp(r'^998\d{9}$');
    if (!andoza.hasMatch(matn)) {
      return 'Telefon 998XXXXXXXXX formatida bo‘lsin';
    }
    return null;
  }

  String? _summaTekshir(String? qiymat) {
    final matn = (qiymat ?? '').trim().replaceAll(',', '.');
    if (matn.isEmpty) {
      return 'Qarz miqdorini kiriting';
    }
    final son = double.tryParse(matn);
    if (son == null) {
      return 'To‘g‘ri son kiriting';
    }
    if (son <= 0) {
      return 'Miqdor 0 dan katta bo‘lsin';
    }
    return null;
  }

  Future<void> _saqlashniBajar() async {
    final forma = _formaKaliti.currentState;
    if (forma == null || !forma.validate()) {
      return;
    }
    if (_rasmPath == null || _rasmPath!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avval kamera orqali rasm oling')),
      );
      return;
    }

    setState(() => _saqlanmoqda = true);
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final summa = double.parse(_summaKontroller.text.trim().replaceAll(',', '.'));
    final qarzdor = Qarzdor(
      id: id,
      ismi: _ismKontroller.text.trim(),
      telefon: _telefonKontroller.text.replaceAll(' ', ''),
      rasmPath: _rasmPath!,
      qarzMiqdori: summa,
      olinganSana: DateTime.now(),
      qaytarishSana: DateTime(
        _qaytarishSana.year,
        _qaytarishSana.month,
        _qaytarishSana.day,
      ),
    );

    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(qarzdor);
  }

  String _sanaYoz(DateTime s) {
    final kun = s.day.toString().padLeft(2, '0');
    final oy = s.month.toString().padLeft(2, '0');
    return '$kun.$oy.${s.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yangi qarzdor'),
      ),
      body: SafeArea(
        child: Form(
          key: _formaKaliti,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 56,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      backgroundImage: _rasmPath != null && File(_rasmPath!).existsSync()
                          ? FileImage(File(_rasmPath!))
                          : null,
                      child: _rasmPath == null
                          ? Icon(
                              Icons.person,
                              size: 56,
                              color: Theme.of(context).colorScheme.onPrimaryContainer,
                            )
                          : null,
                    ),
                    const SizedBox(height: 12),
                    FilledButton.tonalIcon(
                      onPressed: _rasmOlinmoqda ? null : _kameraniOch,
                      icon: _rasmOlinmoqda
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.photo_camera),
                      label: Text(_rasmPath == null ? 'Kamera' : 'Qayta olish'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _ismKontroller,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Ismi',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
                validator: _ismTekshir,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _telefonKontroller,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                decoration: const InputDecoration(
                  labelText: 'Telefon raqami',
                  hintText: '998XXXXXXXXX',
                  prefixIcon: Icon(Icons.phone_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: _telefonTekshir,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _summaKontroller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Qarz miqdori',
                  suffixText: "so'm",
                  prefixIcon: Icon(Icons.payments_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: _summaTekshir,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                ),
                leading: const Padding(
                  padding: EdgeInsets.only(left: 12),
                  child: Icon(Icons.event),
                ),
                title: const Text('Qaytarish muddati'),
                subtitle: Text(_sanaYoz(_qaytarishSana)),
                trailing: const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.calendar_month),
                ),
                onTap: _sananiTanla,
              ),
              const SizedBox(height: 28),
              FilledButton.icon(
                onPressed: _saqlanmoqda ? null : _saqlashniBajar,
                icon: const Icon(Icons.save),
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('Saqlash'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
