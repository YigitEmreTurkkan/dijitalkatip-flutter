# Dijital Katip

Bu proje, kullanıcılardan aldığı bilgilerle hukuki dilekçeler oluşturan bir Flutter uygulamasıdır.

Proje, [orijinal React versiyonundan](https://github.com/YigitEmreTurkkan/dijitalkatip.github.io) Flutter'a dönüştürülmüştür.

## Özellikler

- **Sohbet Arayüzü:** Kullanıcıyla konuşarak gerekli bilgileri toplayan bir sohbet ekranı.
- **Belge Görüntüleyici:** Oluşturulan dilekçenin canlı önizlemesi.
- **Yapay Zeka Entegrasyonu:** Google Gemini API kullanarak konuşma ve belge oluşturma.
- **PDF Dışa Aktarma:** Oluşturulan dilekçeyi PDF olarak indirme.

## Kurulum ve Çalıştırma

1.  **Projeyi klonlayın:**
    ```sh
    git clone <repository_url>
    cd dk
    ```

2.  **Bağımlılıkları yükleyin:**
    ```sh
    flutter pub get
    ```

3.  **API Anahtarını Ekleyin:**
    `.env.example` dosyasını `.env` olarak kopyalayın ve kendi Google Gemini API anahtarınızı ekleyin:
    ```sh
    cp .env.example .env
    ```
    Ardından `.env` dosyasını açın ve `YOUR_GEMINI_API_KEY_HERE` kısmını kendi API anahtarınızla değiştirin.

4.  **Uygulamayı çalıştırın:**
    ```sh
    flutter run
    ```
