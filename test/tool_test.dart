import 'package:flutter_test/flutter_test.dart';
import 'package:uyg_tansiyon_ve_seker_gunlugu/uyg_tansiyon_ve_seker_gunlugu.dart';

void main() {
  test('33 dilde ad ve açıklama, doğru kimlik', () {
    expect(tansiyonVeSekerGunluguTool.id, tansiyonVeSekerGunluguId);
    expect(tansiyonVeSekerGunluguTool.title.length, 33);
    expect(tansiyonVeSekerGunluguTool.tagline.length, 33);
  });
}
