# TakipVox

Türkçe, mobil uyumlu GitHub Pages + Supabase başlangıç paneli.

## Kurulum
1. Supabase Dashboard > Project Settings > API Keys > Publishable key bölümündeki `sb_publishable_...` anahtarını `config.js` içine yazın. **Secret/service_role anahtarlarını asla eklemeyin.**
2. Supabase > SQL Editor bölümünde `setup.sql` içeriğini çalıştırın.
3. Supabase Authentication > URL Configuration altında Site URL değerini `https://resul2147.github.io/Smm-panel-/` olarak belirleyin ve Redirect URLs listesine aynı adresi ekleyin.
4. GitHub deposunda Settings > Pages > Deploy from a branch > main / root seçeneğiyle yayını etkinleştirin.
5. Siteye kaydolun. Yönetici erişimi için `setup.sql` dosyasının en altındaki açıklamalı yönetici SQL komutunu kendi e-posta adresinizle çalıştırın.
6. Yönetici panelinden hizmet ekleyin.

## Sınırlar
Bu sürümde ödeme alma, bakiye yükleme ve otomatik sosyal medya teslimatı **yoktur**. Siparişler yalnızca taleptir. Gerçek hizmetler için yasal ve yetkili bir sağlayıcı API'si, güvenli sunucu tarafı entegrasyon ve ödeme altyapısı gerekir.

## Güvenlik
RLS ve sipariş fiyatının veritabanında hesaplanması `setup.sql` içindedir. `config.js` yalnızca Supabase publishable key içermelidir. Testleri tamamlamadan gerçek müşteri veya ödeme kabul etmeyin.

## Marka
Çalışma adı: TakipVox. Alan adı/marka tescil uygunluğu doğrulanmadı; herhangi bir alan adı satın alınmadı.

## Tamamlama durumu
GitHub kodları güncellendi. Supabase publishable API anahtarı ve SQL kurulumu tamamlanmadan üyelik/siparişler canlı çalışmaz. GitHub Pages yayını ayrıca etkin olmalıdır. Marka ve alan adı uygunluğu doğrulanmadı.
