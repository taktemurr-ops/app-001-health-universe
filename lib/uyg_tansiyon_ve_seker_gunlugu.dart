/// Tansiyon ve Şeker Günlüğü · Blood Pressure & Sugar Log
///
/// Ölçümlerini kaydet, grafikte gör. Sağlık ve Spor merkez uygulamasında yer alır; gerçek
/// uygulama ortak motordadır (saglik_motoru), çatı studio_core/apps.
library;

import 'package:saglik_motoru/saglik_motoru.dart';
import 'package:studio_core/apps/apps.dart';

const String tansiyonVeSekerGunluguId = 'uyg-tansiyon-ve-seker-gunlugu';

/// Merkezin kullandığı araç tanımı (33 dilde ad ve açıklama).
final AppTool tansiyonVeSekerGunluguTool = saglikTool(tansiyonVeSekerGunluguId);
