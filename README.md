# LuceBella - Yapay Zekâ Destekli Makyaj ve 3D Yüz Simülasyon Uygulaması

LuceBella, mobil cihazlar üzerinden kullanıcıların yüz analizi ve kişisel renk tahlillerini gerçekleştirerek onlara özel ürün önerileri sunan ve 3 boyutlu yüz modeli üzerinde sanal makyaj simülasyonu sağlayan bir mezuniyet çalışması projesidir. Proje, tek bir 2B portre fotoğrafından 3B yüz modeli üretmekte ve uygulanan makyajı bu model üzerinde 360 derece etkileşimli olarak göstermektedir.

## Özellikler

*   **Cilt ve Alt Ton Analizi:** Kullanıcının yanak ve alın bölgelerinden renk örneklemesi yapılarak cilt tonu (Açık, Buğday, Esmer, Koyu) ve cilt alt tonu (Pembe/Soğuk, Sarı/Sıcak, Nötr) belirlenir.
*   **Yüz Şekli Tespiti:** Yüzün en/boy oranları ölçülerek yüz şekli (Oval, Yuvarlak, Kare, Dikdörtgen, Kalp, Elmas) tespit edilir ve kullanıcıya uygun makyaj uygulama rehberi sunulur.
*   **3B Yüz Rekonstrüksiyonu:** Tek bir fotoğraftan yüzün 3B derinlik haritası hesaplanarak yüz yapısına özel `.obj` uzantılı 3 boyutlu kafa modeli oluşturulur.
*   **Dijital Makyaj Motoru:** Dudak, yanak (allık), göz kapağı (far), eyeliner, fondöten, kapatıcı ve bronzlaştırıcı maskeleme algoritmaları kullanılarak uygulanır. Makyajın doğal durması için kenar yumuşatma (Gaussian Blur) ve şeffaf harmanlama (Alpha Blending) teknikleri uygulanır.
*   **Etkinlik Bazlı Makyaj Kombinasyonları:** Günlük, iş, akşam, düğün, parti ve plaj gibi farklı etkinlikler için kullanıcının cilt profiline en uygun makyaj tarzı ve yoğunluk seviyeleri tek tıkla otomatik olarak uygulanabilir.
*   **Etkileşimli 3D Görselleştirici:** Mobil cihaz üzerinde 3 boyutlu model parmak hareketleriyle döndürülebilir, yakınlaştırılıp uzaklaştırılabilir.

## Sistem Mimarisi

Proje, istemci-sunucu (Client-Server) mimarisiyle çalışmaktadır:

### Mobil Uygulama (İstemci)
*   `mobiluygulama` klasöründe yer almaktadır.
*   **Flutter (Dart)** kullanılarak geliştirilmiştir. hem Android hem iOS cihazlarda çalışabilir.
*   3D yüz modelini cihaz üzerinde yüksek performanslı görselleştirmek için OpenGL tabanlı **Flutter-Cube** kütüphanesi entegre edilmiştir.

### Web Sunucusu (Arka Plan)
*   `3boyutsonhal` klasöründe yer almaktadır.
*   **Python (FastAPI)** ile geliştirilmiştir.
*   Yüz tespiti için **FaceBoxes**, 3D yüz modeli oluşturmak için **3DDFA-V2** ve yüz hatlarını maskelemek için **MediaPipe Face Mesh** ile **OpenCV** kütüphaneleri kullanılmıştır.

## Kurulum ve Çalıştırma

### Sunucu Kurulumu (Python)
1. `3boyutsonhal` klasörüne geçiş yapın.
2. Gerekli kütüphaneleri yükleyin:
   ```bash
   pip install -r requirements.txt
   ```
3. FastAPI sunucusunu başlatın:
   ```bash
   uvicorn server:app --host 0.0.0.0 --port 8000
   ```

### Mobil Uygulama Kurulumu (Flutter)
1. `mobiluygulama` klasörüne geçiş yapın.
2. Paketleri yükleyin:
   ```bash
   flutter pub get
   ```
3. Uygulamayı çalıştırın:
   ```bash
   flutter run
   ```
