import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtMultimedia
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: root


    property int internalReciterIndex: 0

    // ============================================================
    // PROPERTY ALIASES
    // ============================================================

    property alias cfg_quranReciterIndex: reciterCombo.currentIndex

    // Location
    property alias cfg_method: methodCombo.currentIndex
    property alias cfg_school: schoolCombo.currentIndex
    property alias cfg_city: cityField.text
    property alias cfg_country: countryField.text
    property alias cfg_latitude: latField.text
    property alias cfg_longitude: longField.text
    property alias cfg_useCoordinates: useCoordsCheck.checked

    // General
    property alias cfg_compactStyle: compactStyleCombo.currentIndex
    property alias cfg_hourFormat: hourFormatCheck.checked
    property alias cfg_languageIndex: languageCombo.currentIndex
    property alias cfg_useArabicNumbers: useArabicNumbersCheck.checked
    property alias cfg_notifications: notificationsCheck.checked
    property alias cfg_preNotificationMinutes: preNotificationTextField.text
    property alias cfg_showMidnight: showMidnightCheck.checked
    property alias cfg_showLastThird: showLastThirdCheck.checked
    property alias cfg_showEmojis: showEmojisCheck.checked
    property alias cfg_enablePrePrayerGlow: enablePrePrayerGlowCheck.checked
    property alias cfg_playPreAdhanSound: preAdhanSoundCheck.checked
    property alias cfg_postNotificationMinutes: postNotificationSpinBox.value
    property alias cfg_playPostAdhanSound: postAdhanSoundCheck.checked
    property alias cfg_showBackground: showBackgroundCheck.checked
    property alias cfg_showCompactMediaButton: showCompactMediaCheck.checked
    property alias cfg_enableQuran: enableQuranCheck.checked

    // Audio
    property alias cfg_adhanAudioPath: adhanPathField.text
    property alias cfg_adhanPlaybackMode: adhanModeCombo.currentIndex
    property alias cfg_adhanVolume: adhanVolumeSlider.value

    // Adhan Toggles
    property alias cfg_playAdhanForFajr: playFajrCheck.checked
    property alias cfg_playAdhanForDhuhr: playDhuhrCheck.checked
    property alias cfg_playAdhanForAsr: playAsrCheck.checked
    property alias cfg_playAdhanForMaghrib: playMaghribCheck.checked
    property alias cfg_playAdhanForIsha: playIshaCheck.checked

    // Offsets
    property alias cfg_fajrOffsetMinutes: fajrOffset.value
    property alias cfg_sunriseOffsetMinutes: sunriseOffset.value
    property alias cfg_dhuhrOffsetMinutes: dhuhrOffset.value
    property alias cfg_asrOffsetMinutes: asrOffset.value
    property alias cfg_maghribOffsetMinutes: maghribOffset.value
    property alias cfg_ishaOffsetMinutes: ishaOffset.value
    property alias cfg_hijriOffset: hijriOffsetSpin.value
    property alias cfg_forceOfflineMode: forceOfflineCheck.checked
    property bool cfg_isOfflineFallback: false

    // ============================================================
    // SUPPRESS HARMFUL/BENIGN KCM WARNINGS
    // ============================================================
    property var cfg_adhanAudioPathDefault
    property var cfg_adhanPlaybackModeDefault
    property var cfg_adhanVolumeDefault
    property var cfg_forceOfflineModeDefault
    property var cfg_isOfflineFallbackDefault
    property var cfg_asrOffsetMinutesDefault
    property var cfg_author
    property var cfg_authorDefault
    property var cfg_citations
    property var cfg_citationsDefault
    property var cfg_cityDefault
    property var cfg_compactStyleDefault
    property var cfg_countryDefault
    property var cfg_dhuhrOffsetMinutesDefault
    property var cfg_email
    property var cfg_emailDefault
    property var cfg_enableQuranDefault
    property var cfg_fajrOffsetMinutesDefault
    property var cfg_hijriOffsetDefault
    property var cfg_hourFormatDefault
    property var cfg_ishaOffsetMinutesDefault
    property var cfg_languageIndexDefault
    property var cfg_useArabicNumbersDefault
    property var cfg_latitudeDefault
    property var cfg_longitudeDefault
    property var cfg_maghribOffsetMinutesDefault
    property var cfg_methodDefault
    property var cfg_notificationsDefault
    property var cfg_playAdhanForAsrDefault
    property var cfg_playAdhanForDhuhrDefault
    property var cfg_playAdhanForFajrDefault
    property var cfg_playAdhanForIshaDefault
    property var cfg_playAdhanForMaghribDefault
    property var cfg_playPostAdhanSoundDefault
    property var cfg_playPreAdhanSoundDefault
    property var cfg_postNotificationMinutesDefault
    property var cfg_preNotificationMinutesDefault
    property var cfg_quranReciterIndexDefault
    property var cfg_schoolDefault
    property var cfg_showBackgroundDefault
    property var cfg_showMidnightDefault
    property var cfg_showLastThirdDefault
    property var cfg_showEmojisDefault
    property var cfg_showCompactMediaButtonDefault
    property var cfg_sunriseOffsetMinutesDefault
    property var cfg_useCoordinatesDefault
    property var cfg_useDynamicFont
    property var cfg_version
    property var cfg_versionDefault

    // ============================================================
    // INTERNAL DATA & LOGIC
    // ============================================================

    function t(enText, arText, trText) {
        if (languageCombo.currentIndex === 1) return arText;
        if (languageCombo.currentIndex === 2) return trText;
        return enText;
    }

    function autoSelectMethod(country) {
        if (!country) return;
        let c = country.toLowerCase();
        let methodIndex = 3; // Default to MWL
        
        if (c.includes("egypt")) methodIndex = 5;
        else if (c.includes("morocco")) methodIndex = 14;
        else if (c.includes("pakistan") || c.includes("bangladesh") || c.includes("india") || c.includes("afghanistan")) methodIndex = 1;
        else if (c.includes("usa") || c.includes("america") || c.includes("canada") || c.includes("united states")) methodIndex = 2;
        else if (c.includes("saudi")) methodIndex = 4;
        else if (c.includes("iran")) methodIndex = 6;
        else if (c.includes("gulf") || c.includes("bahrain") || c.includes("oman") || c.includes("yemen")) methodIndex = 7;
        else if (c.includes("kuwait")) methodIndex = 8;
        else if (c.includes("qatar")) methodIndex = 9;
        else if (c.includes("singapore")) methodIndex = 10;
        else if (c.includes("france")) methodIndex = 11;
        else if (c.includes("turkey") || c.includes("turkiye")) methodIndex = 12;
        else if (c.includes("russia")) methodIndex = 13;
        else if (c.includes("uae") || c.includes("united arab emirates") || c.includes("dubai")) methodIndex = 15;
        else if (c.includes("malaysia")) methodIndex = 16;
        else if (c.includes("tunisia")) methodIndex = 17;
        else if (c.includes("algeria")) methodIndex = 18;
        else if (c.includes("indonesia")) methodIndex = 19;
        else if (c.includes("portugal")) methodIndex = 20;
        else if (c.includes("jordan")) methodIndex = 21;
        
        methodCombo.currentIndex = methodIndex;
    }

    function autoSelectMethodFromCoords(lat, lon) {
        if (!lat || !lon) return;
        let xhr = new XMLHttpRequest();
        xhr.open("GET", `https://api.bigdatacloud.net/data/reverse-geocode-client?latitude=${lat}&longitude=${lon}&localityLanguage=en`, true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4 && xhr.status === 200) {
                try {
                    let data = JSON.parse(xhr.responseText);
                    if (data.countryName) {
                        root.autoSelectMethod(data.countryName);
                    }
                } catch (e) {
                    console.log("Error parsing reverse geocoding data", e.toString());
                }
            }
        }
        xhr.send();
    }

    property var reciterNamesModel: [
        {en: "Minshawi (Murattal)", ar: "المنشاوي (مرتل)", tr: "Minşavi (Murattal)"},
        {en: "Alafasy", ar: "العفاسي", tr: "Afasi"},
        {en: "Husary (Murattal)", ar: "الحصري (مرتل)", tr: "Husari (Murattal)"},
        {en: "Abdurrahmaan As-Sudais", ar: "عبد الرحمن السديس", tr: "Abdurrahman es-Sudeys"},
        {en: "Maher Al Muaiqly", ar: "ماهر المعيقلي", tr: "Mahir el-Muaykili"},
        {en: "Abu Bakr Ash-Shaatree", ar: "أبو بكر الشاطري", tr: "Ebu Bekir eş-Şatri"},
        {en: "Abdullah Basfar", ar: "عبد الله بصفر", tr: "Abdullah Basfar"},
        {en: "Abdulbasit (Murattal)", ar: "عبد الباسط (مرتل)", tr: "Abdülbasit (Murattal)"},
        {en: "Hudhaify", ar: "الحذيفي", tr: "Huzeyfi"},
        {en: "Muhammad Jibreel", ar: "محمد جبريل", tr: "Muhammed Cibril"},
        {en: "Husary (Mujawwad)", ar: "الحصري (مجود)", tr: "Husari (Mücevved)"},
        {en: "Minshawi (Mujawwad)", ar: "المنشاوي (مجود)", tr: "Minşavi (Mücevved)"},
        {en: "Ahmed ibn Ali al-Ajamy", ar: "أحمد بن علي العجمي", tr: "Ahmed el-Acemi"}
    ]

    property string defaultAdhanPath: {
        return Qt.resolvedUrl("../../contents/audio/Adhan.mp3").toString()
    }

    // Test Player
    MediaPlayer {
        id: previewPlayer
        audioOutput: AudioOutput { volume: adhanVolumeSlider.value }
        onPlaybackStateChanged: {
            if (playbackState === MediaPlayer.StoppedState) {
                testAdhanStopTimer.stop()
            }
        }
    }

    Timer {
        id: testAdhanStopTimer
        repeat: false
        onTriggered: {
            console.log("Test Adhan stopped by timer")
            previewPlayer.stop()
        }
    }

    // File Dialog
    FileDialog {
        id: fileDialog
        title: t("Select Adhan Audio File", "اختر ملف صوت الأذان", "Ezan Ses Dosyası Seç")
        nameFilters: [ "Audio files (*.mp3 *.wav *.ogg *.m4a *.flac)", "All files (*)" ]
        onAccepted: {
            let path = selectedFile.toString()
            if (path.startsWith("file://")) path = path.substring(7)
                adhanPathField.text = path
        }
    }

    Component.onCompleted: {
        if (!plasmoid.configuration.adhanAudioPath || plasmoid.configuration.adhanAudioPath === "") {
            adhanPathField.text = defaultAdhanPath
        }
    }

    // ============================================================
    // UI LAYOUT
    // ============================================================
    Kirigami.FormLayout {
        id: form
        LayoutMirroring.enabled: languageCombo.currentIndex === 1
        LayoutMirroring.childrenInherit: true

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            visible: cfg_isOfflineFallback === true && !forceOfflineCheck.checked
            type: Kirigami.MessageType.Warning
            text: t("Offline Mode (First Run). Please enter your coordinates below to calculate prayer times locally, or connect to the internet.", "أنت في وضع عدم الاتصال (أول تشغيل). يرجى إدخال إحداثياتك أدناه لحساب أوقات الصلاة محلياً، أو الاتصال بالإنترنت.", "Çevrimdışı Mod (İlk Çalıştırma). Vakitleri yerel olarak hesaplamak için lütfen koordinatlarınızı girin veya internete bağlanın.")
        }

        // --- SECTION 1: LOCATION ---
        Kirigami.Separator { Kirigami.FormData.label: t("Location", "الموقع", "Konum"); Kirigami.FormData.isSection: true }

        CheckBox {
            id: useCoordsCheck
            text: t("Use Exact Coordinates (Recommended)", "استخدام الإحداثيات الدقيقة (موصى به)", "Hassas Koordinatları Kullan (Önerilen)")
            Kirigami.FormData.label: t("Method:", "طريقة التحديد:", "Yöntem:")
            enabled: !cfg_isOfflineFallback && !forceOfflineCheck.checked
            Component.onCompleted: {
                if (cfg_isOfflineFallback === true || forceOfflineCheck.checked) checked = true;
            }
        }

        RowLayout {
            visible: useCoordsCheck.checked
            Kirigami.FormData.label: t("Coordinates:", "الإحداثيات:", "Koordinatlar:")
            
            Timer {
                id: coordsDebounceTimer
                interval: 1000; repeat: false
                onTriggered: root.autoSelectMethodFromCoords(latField.text, longField.text)
            }

            TextField { 
                id: latField
                placeholderText: t("Latitude", "خط العرض", "Enlem")
                validator: DoubleValidator { bottom: -90.0; top: 90.0; decimals: 15 }
                onTextChanged: coordsDebounceTimer.restart()
                onEditingFinished: coordsDebounceTimer.restart()
            }
            TextField { 
                id: longField
                placeholderText: t("Longitude", "خط الطول", "Boylam")
                validator: DoubleValidator { bottom: -180.0; top: 180.0; decimals: 15 }
                onTextChanged: coordsDebounceTimer.restart()
                onEditingFinished: coordsDebounceTimer.restart()
            }
        }

        TextField {
            id: cityField
            visible: !useCoordsCheck.checked && !forceOfflineCheck.checked
            Kirigami.FormData.label: t("City:", "المدينة:", "Şehir:")
            placeholderText: t("e.g. Cairo", "مثال: القاهرة", "Örn: İstanbul")
        }
        TextField {
            id: countryField
            visible: !useCoordsCheck.checked && !forceOfflineCheck.checked
            Kirigami.FormData.label: t("Country:", "الدولة:", "Ülke:")
            placeholderText: t("e.g. Egypt", "مثال: مصر", "Örn: Türkiye")
            onTextChanged: root.autoSelectMethod(text)
        }

        Button {
            text: t("Auto-Detect Location (IP)", "اكتشاف الموقع تلقائياً (عبر الإنترنت)", "Konumu Otomatik Bul (IP)")
            icon.name: "system-search"
            enabled: !cfg_isOfflineFallback && !forceOfflineCheck.checked
            Kirigami.FormData.label: "" // Aligns it properly under the fields
            Layout.alignment: Qt.AlignLeft
            onClicked: {
                let xhr = new XMLHttpRequest();
                xhr.open("GET", "https://freeipapi.com/api/json", true);
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === 4 && xhr.status === 200) {
                        try {
                            let data = JSON.parse(xhr.responseText);
                            cityField.text = data.cityName || "";
                            countryField.text = data.countryName || "";
                            if (data.countryName) {
                                root.autoSelectMethod(data.countryName);
                            }
                            if (data.latitude && data.longitude) {
                                latField.text = data.latitude.toString();
                                longField.text = data.longitude.toString();
                                useCoordsCheck.checked = true;
                            }
                        } catch (e) {
                            console.log("Error parsing IP location data", e.toString());
                        }
                    }
                }
                xhr.send();
            }
        }

        // Moved to bottom

        ComboBox {
            id: methodCombo
            Kirigami.FormData.label: t("Calculation Method:", "طريقة الحساب:", "Hesaplama Yöntemi:")
            textRole: languageCombo.currentIndex === 1 ? "ar" : (languageCombo.currentIndex === 2 ? "tr" : "en")
            model: [
                { ar: "الشيعة الاثنا عشرية", en: "Shia Ithna-Ansari", tr: "Şii İsnaaşeriyye" },
                { ar: "جامعة العلوم الإسلامية بكراتشي", en: "University of Islamic Sciences, Karachi", tr: "Karaçi İslam İlimleri Üniversitesi" },
                { ar: "الجمعية الإسلامية لأمريكا الشمالية", en: "Islamic Society of North America", tr: "Kuzey Amerika İslam Toplumu (ISNA)" },
                { ar: "رابطة العالم الإسلامي", en: "Muslim World League", tr: "Dünya İslam Birliği (Rabıta)" },
                { ar: "جامعة أم القرى بمكة المكرمة", en: "Umm Al-Qura University, Makkah", tr: "Ümmü'l-Kurâ Üniversitesi, Mekke" },
                { ar: "الهيئة العامة المصرية للمساحة", en: "Egyptian General Authority of Survey", tr: "Mısır Genel Araştırma Kurumu" },
                { ar: "معهد الجيوفيزياء بجامعة طهران", en: "Institute of Geophysics, University of Tehran", tr: "Tahran Üniversitesi Jeofizik Enstitüsü" },
                { ar: "منطقة الخليج", en: "Gulf Region", tr: "Körfez Bölgesi" },
                { ar: "الكويت", en: "Kuwait", tr: "Kuveyt" },
                { ar: "قطر", en: "Qatar", tr: "Katar" },
                { ar: "مجلس الشؤون الإسلامية بسنغافورة", en: "Majlis Ugama Islam Singapura, Singapore", tr: "Singapur İslam Meclisi (MUIS)" },
                { ar: "اتحاد المنظمات الإسلامية بفرنسا", en: "Union Organization islamic de France", tr: "Fransa İslam Kuruluşları Birliği (UOIF)" },
                { ar: "رئاسة الشؤون الدينية التركية", en: "Diyanet Isleri Baskanligi, Turkey", tr: "Diyanet İşleri Başkanlığı, Türkiye" },
                { ar: "الإدارة الدينية لمسلمي روسيا", en: "Spiritual Administration of Muslims of Russia", tr: "Rusya Müslümanları Dini İdaresi" },
                { ar: "المغرب", en: "Morocco", tr: "Fas" },
                { ar: "دبي", en: "Dubai", tr: "Dubai" },
                { ar: "إدارة التنمية الإسلامية الماليزية", en: "Jabatan Kemajuan Islam Malaysia (JAKIM)", tr: "Malezya İslam Gelişimi Departmanı (JAKIM)" },
                { ar: "تونس", en: "Tunisia", tr: "Tunus" },
                { ar: "الجزائر", en: "Algeria", tr: "Cezayir" },
                { ar: "وزارة الشؤون الدينية في إندونيسيا", en: "Kementerian Agama Republik Indonesia", tr: "Endonezya Din İşleri Bakanlığı" },
                { ar: "الجماعة الإسلامية في لشبونة (البرتغال)", en: "Comunidade Islamica de Lisboa (Portugal)", tr: "Lizbon İslam Toplumu (Portekiz)" },
                { ar: "وزارة الأوقاف والشؤون والمقدسات الإسلامية الأردنية", en: "Ministry of Awqaf, Jordan", tr: "Ürdün Evkaf Bakanlığı" }
            ]
        }
        ComboBox { 
            id: schoolCombo
            Kirigami.FormData.label: t("School (Juristic):", "المذهب الفقهي (العصر):", "Mezhep (İkindi Vakti):")
            textRole: languageCombo.currentIndex === 1 ? "ar" : (languageCombo.currentIndex === 2 ? "tr" : "en")
            model: [
                { ar: "الشافعي / الحنبلي / المالكي (القياسي)", en: "Shafi (Standard)", tr: "Şafi / Hanbeli / Maliki (Standart)" },
                { ar: "الحنفي", en: "Hanafi", tr: "Hanefi" }
            ]
        }
        Label {
            text: t("This setting mainly affects Asr's time", "يؤثر على موعد صلاة العصر", "Bu ayar sadece ikindi vaktini etkiler")
            font.italic: true
            Layout.fillWidth: true
            opacity: 0.7
        }

        // --- SECTION 2: APPEARANCE & NOTIFICATIONS ---
        Kirigami.Separator { Kirigami.FormData.label: t("General Settings", "الإعدادات العامة", "Genel Ayarlar"); Kirigami.FormData.isSection: true }

        ComboBox {
            id: compactStyleCombo
            Kirigami.FormData.label: t("Compact View Style:", "شكل العرض المصغر:", "Panel Görünüm Stili:")
            textRole: languageCombo.currentIndex === 1 ? "ar" : (languageCombo.currentIndex === 2 ? "tr" : "en")
            model: [
                { ar: "رأسي (قياسي)", en: "Vertical Standard", tr: "Dikey (Standart)" },
                { ar: "جنبا إلى جنب", en: "Side by Side", tr: "Yan Yana" },
                { ar: "تبديل رأسي", en: "Toggle Vertical", tr: "Dikey Dönüşümlü" },
                { ar: "تبديل أفقي", en: "Toggle Horizontal", tr: "Yatay Dönüşümlü" },
                { ar: "أفقي متبقي", en: "Horizontal Remaining", tr: "Yatay Kalan Süre" },
                { ar: "أفقي(قياسي)", en: "Horizontal Single Line", tr: "Yatay Tek Satır" }
            ]
        }
        ComboBox {
            id: languageCombo;
            Kirigami.FormData.label: t("Language:", "اللغة:", "Dil:");
            model: ["English", "العربية (Arabic)", "Türkçe (Turkish)"]
        }
        CheckBox {
            id: useArabicNumbersCheck
            text: t("Use Arabic-Indic Numerals for dates and times", "تدوين الأرقام بالصيغة العربية (٠١٢٣٤٥٦٧٨٩)", "Arapça rakamları kullan")
            Kirigami.FormData.label: ""
            visible: languageCombo.currentIndex === 1
        }
        CheckBox { id: hourFormatCheck; text: t("Use 12-hour format (AM/PM)", "نظام 12 ساعة (ص/م)", "12 saat biçimini kullan (ÖÖ/ÖS)"); Kirigami.FormData.label: t("Time Format:", "تنسيق الوقت:", "Saat Biçimi:") }
        CheckBox {
            id: showEmojisCheck
            text: t("Show emojis in prayer list", "إظهار الرموز التعبيرية للصلوات (إيموجي) في القائمة المنسدلة", "Vakit listesinde emojileri göster")
            Kirigami.FormData.label: ""
        }
        CheckBox {
            id: enablePrePrayerGlowCheck
            text: t("Enable 5-minute pre-prayer yellow glow", "تفعيل الوميض الأصفر قبل الصلاة بـ 5 دقائق", "Vakitten 5 dakika önce sarı uyarı parlamasını etkinleştir")
            Kirigami.FormData.label: ""
        }

        Kirigami.Separator { Kirigami.FormData.label: t("Notifications", "التنبيهات", "Bildirimler"); Kirigami.FormData.isSection: true }

        CheckBox {
            id: notificationsCheck
            text: t("Show notification on exact prayer time", "إظهار إشعار عند دخول وقت الصلاة", "Vakit girdiğinde bildirim göster")
            Kirigami.FormData.label: t("Main Alert:", "التنبيه الأساسي:", "Ana Uyarı:")
        }

        ColumnLayout {
            Kirigami.FormData.label: t("Pre-Adhan:", "قبل الأذان:", "Ezandan Önce:")
            spacing: 0
            RowLayout {
                TextField {
                    id: preNotificationTextField
                    placeholderText: "5, 10, 20"
                }
                Label { text: t("minutes before", "دقائق قبل الصلاة", "dakika önce") }
            }
            Label { 
                text: t("to add multiple times type: 5, 10, 15", "لإضافة عدة تنبيهات اكتب: 5, 10, 15", "Birden fazla vakit için virgülle ayırın: 5, 10, 15")
                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                opacity: 0.7
            }
            CheckBox {
                id: preAdhanSoundCheck
                text: t("Play notification sound", "تشغيل صوت التنبيه", "Bildirim sesini çal")
                enabled: preNotificationTextField.text.trim().length > 0
            }
        }

        ColumnLayout {
            Kirigami.FormData.label: t("Iqamah (Post-Adhan):", "الإقامة (بعد الأذان):", "Kamet (Ezandan Sonra):")
            spacing: 0
            RowLayout {
                SpinBox { id: postNotificationSpinBox; from: 0; to: 60 }
                Label { text: t("minutes after", "دقيقة بعد الأذان", "dakika sonra") }
            }
            CheckBox {
                id: postAdhanSoundCheck
                text: t("Play notification sound", "تشغيل صوت التنبيه", "Bildirim sesini çal")
                enabled: postNotificationSpinBox.value > 0
            }
        }

        // ==========================================
        // WIDGET FEATURES
        // ==========================================
        Kirigami.Separator { Kirigami.FormData.label: t("Widget Features", "ميزات الإضافة", "Genişletilmiş Özellikler"); Kirigami.FormData.isSection: true }

        ColumnLayout {
            Kirigami.FormData.label: t("Quran:", "القرآن الكريم:", "Kur'an-ı Kerim:")
            spacing: 0
            CheckBox {
                id: enableQuranCheck
                text: t("Enable Quran Player & Daily Verse", "تفعيل مشغل القرآن والآية اليومية", "Kur'an Oynatıcıyı ve Günün Ayetini etkinleştir")
            }
            CheckBox {
                id: showCompactMediaCheck
                text: t("Show Play/Pause button in compact view", "إظهار زر التشغيل/الإيقاف في العرض المصغر", "Panel görünümünde Oynat/Duraklat butonunu göster")
                enabled: enableQuranCheck.checked
            }
        }

        ColumnLayout {
            Kirigami.FormData.label: t("Extra Prayer Times:", "أوقات الصلاة الإضافية:", "Ek Vakitler:")
            spacing: 0
            CheckBox {
                id: showMidnightCheck
                text: t("Show Midnight", "إظهار منتصف الليل", "Gece Yarısını Göster")
            }
            CheckBox {
                id: showLastThirdCheck
                text: t("Show Last Third of Night", "إظهار الثلث الأخير من الليل", "Gecenin Son Üçte Birini Göster")
            }
        }

        // --- SECTION 3: AUDIO & ADHAN ---
        Kirigami.Separator { Kirigami.FormData.label: t("Audio & Adhan", "الصوتيات والأذان", "Ses ve Ezan"); Kirigami.FormData.isSection: true }

        ComboBox {
            id: reciterCombo
            Kirigami.FormData.label: t("Quran Reciter:", "القارئ:", "Kur'an Okuyucusu:")
            textRole: languageCombo.currentIndex === 1 ? "ar" : (languageCombo.currentIndex === 2 ? "tr" : "en")
            model: reciterNamesModel
        }

        RowLayout {
            Kirigami.FormData.label: t("Adhan Audio File:", "ملف الأذان الصوتي:", "Ezan Ses Dosyası:")
            TextField {
                id: adhanPathField
                Layout.fillWidth: true
                placeholderText: t("Using default adhan...", "استخدام الأذان الافتراضي...", "Varsayılan ezan kullanılıyor...")
            }
            Button {
                text: t("Browse...", "تصفح...", "Gözat..."); icon.name: "document-open"
                onClicked: fileDialog.open()
            }
            Button {
                text: t("Reset", "استعادة", "Sıfırla"); icon.name: "edit-clear"
                onClicked: adhanPathField.text = defaultAdhanPath
            }
            Button {
                text: t("Clear", "مسح", "Temizle"); enabled: adhanPathField.text.length > 0
                onClicked: adhanPathField.text = ""
            }
        }

        Button {
            text: previewPlayer.playbackState === MediaPlayer.PlayingState ? t("Stop Adhan", "إيقاف الأذان", "Ezanı Durdur") : t("Test Adhan Sound", "تجربة صوت الأذان", "Ezan Sesini Sına")
            icon.name: previewPlayer.playbackState === MediaPlayer.PlayingState ? "media-playback-stop" : "media-playback-start"
            Kirigami.FormData.label: ""
            enabled: adhanModeCombo.currentIndex > 0

            onClicked: {
                if (previewPlayer.playbackState === MediaPlayer.PlayingState) {
                    previewPlayer.stop()
                    testAdhanStopTimer.stop()
                } else {
                    let rawPath = adhanPathField.text
                    if (rawPath === "") rawPath = defaultAdhanPath

                        let pathString = rawPath.toString()
                        if (!pathString.startsWith("file://") && !pathString.startsWith("qrc") && !pathString.startsWith("http")) {
                            pathString = "file://" + pathString
                        }

                        console.log("Testing Adhan:", pathString)
                        previewPlayer.source = pathString
                        previewPlayer.play()

                        let mode = adhanModeCombo.currentIndex
                        if (mode === 2) {
                            testAdhanStopTimer.interval = 40000
                            testAdhanStopTimer.start()
                        } else if (mode === 3) {
                            testAdhanStopTimer.interval = 17000
                            testAdhanStopTimer.start()
                        }
                }
            }
        }

        RowLayout {
            Kirigami.FormData.label: t("Adhan Volume:", "مستوى صوت الأذان:", "Ezan Ses Düzeyi:")
            Slider {
                id: adhanVolumeSlider
                Layout.fillWidth: true
                from: 0.0; to: 1.0; stepSize: 0.05
                value: 0.7
            }
            Label {
                text: Math.round(adhanVolumeSlider.value * 100) + "%"
                Layout.minimumWidth: Kirigami.Units.gridUnit * 2
            }
        }

        ComboBox {
            id: adhanModeCombo
            Kirigami.FormData.label: t("Adhan Playback:", "صيغة التشغيل:", "Ezan Oynatma:")
            textRole: languageCombo.currentIndex === 1 ? "ar" : (languageCombo.currentIndex === 2 ? "tr" : "en")
            model: [
                { ar: "بدون أذان", en: "No Adhan", tr: "Ezan Yok" },
                { ar: "أذان كامل", en: "Full Adhan", tr: "Tam Ezan" },
                { ar: "قصير (40 ثانية)", en: "Short (40s)", tr: "Kısa (40sn)" },
                { ar: "قصير جداً (17 ثانية)", en: "Very Short (17s)", tr: "Çok Kısa (17sn)" }
            ]
        }

        GridLayout {
            columns: 3; Kirigami.FormData.label: t("Play Adhan For:", "تشغيل الأذان لـ:", "Ezanın Okunacağı Vakitler:")
            CheckBox { id: playFajrCheck; text: t("Fajr", "الفجر", "İmsak") }
            CheckBox { id: playDhuhrCheck; text: t("Dhuhr", "الظهر", "Öğle") }
            CheckBox { id: playAsrCheck; text: t("Asr", "العصر", "İkindi") }
            CheckBox { id: playMaghribCheck; text: t("Maghrib", "المغرب", "Akşam") }
            CheckBox { id: playIshaCheck; text: t("Isha", "العشاء", "Yatsı") }
        }

        // --- SECTION 4: ADJUSTMENTS ---
        Kirigami.Separator { Kirigami.FormData.label: t("Adjustments", "التعديلات اليدوية", "Vakit Düzeltmeleri"); Kirigami.FormData.isSection: true }

        Label {
            text: t("Adjust times in minutes (+/-)", "تعديل أوقات الصلاة بالدقائق (+/-)", "Vakitleri dakika olarak düzelt (+/-)")
            font.italic: true
            Layout.fillWidth: true
            opacity: 0.7
        }

        GridLayout {
            columns: 4
            rowSpacing: Kirigami.Units.smallSpacing
            columnSpacing: Kirigami.Units.largeSpacing

            Label { text: t("Fajr:", "الفجر:", "İmsak:") }
            SpinBox { id: fajrOffset; from: -60; to: 60; editable: true }

            Label { text: t("Sunrise:", "الشروق:", "Güneş:") }
            SpinBox { id: sunriseOffset; from: -60; to: 60; editable: true }

            Label { text: t("Dhuhr:", "الظهر:", "Öğle:") }
            SpinBox { id: dhuhrOffset; from: -60; to: 60; editable: true }

            Label { text: t("Asr:", "العصر:", "İkindi:") }
            SpinBox { id: asrOffset; from: -60; to: 60; editable: true }

            Label { text: t("Maghrib:", "المغرب:", "Akşam:") }
            SpinBox { id: maghribOffset; from: -60; to: 60; editable: true }

            Label { text: t("Isha:", "العشاء:", "Yatsı:") }
            SpinBox { id: ishaOffset; from: -60; to: 60; editable: true }
        }

        RowLayout {
            Kirigami.FormData.label: t("Hijri Date Offset:", "تعديل التاريخ الهجري:", "Hicri Tarih Düzeltmesi:")
            SpinBox {
                id: hijriOffsetSpin
                from: -5; to: 5
                editable: true
            }
            Label { text: t("days", "أيام", "gün") }
        }

        CheckBox { id: showBackgroundCheck; text: t("Show background", "إظهار الخلفية", "Arka planı göster"); Kirigami.FormData.label: "" }
        Label {
            text: t("Leave checked if no difference", "اتركه مفعلاً إذا لم تلاحظ فرقاً", "Fark görmüyorsanız işaretli bırakın")
            font.italic: true
            Layout.fillWidth: true
            opacity: 0.7
        }

        // --- SECTION 5: PRIVACY ---
        Kirigami.Separator { Kirigami.FormData.label: t("Privacy", "الخصوصية", "Gizlilik"); Kirigami.FormData.isSection: true }

        CheckBox {
            id: forceOfflineCheck
            text: t("Force Offline Mode (Strictly Mathematical)", "فرض وضع عدم الاتصال (حساب رياضي فقط)", "Çevrimdışı Modu Zorla (Yalnızca Matematiksel)")
            Kirigami.FormData.label: ""
            onCheckedChanged: {
                if (checked) useCoordsCheck.checked = true;
            }
        }

    }
}
