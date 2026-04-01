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
    property alias cfg_preNotificationMinutes: preNotificationSpinBox.value
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

    // ============================================================
    // SUPPRESS HARMFUL/BENIGN KCM WARNINGS
    // ============================================================
    property var cfg_adhanAudioPathDefault
    property var cfg_adhanPlaybackModeDefault
    property var cfg_adhanVolumeDefault
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
    property var cfg_showCompactMediaButtonDefault
    property var cfg_sunriseOffsetMinutesDefault
    property var cfg_useCoordinatesDefault
    property var cfg_useDynamicFont
    property var cfg_version
    property var cfg_versionDefault

    // ============================================================
    // INTERNAL DATA & LOGIC
    // ============================================================

    property var reciterNamesModel: [
        {en: "Minshawi (Murattal)", ar: "المنشاوي (مرتل)"},
        {en: "Alafasy", ar: "العفاسي"},
        {en: "Husary (Murattal)", ar: "الحصري (مرتل)"},
        {en: "Abdurrahmaan As-Sudais", ar: "عبد الرحمن السديس"},
        {en: "Maher Al Muaiqly", ar: "ماهر المعيقلي"},
        {en: "Abu Bakr Ash-Shaatree", ar: "أبو بكر الشاطري"},
        {en: "Abdullah Basfar", ar: "عبد الله بصفر"},
        {en: "Abdulbasit (Murattal)", ar: "عبد الباسط (مرتل)"},
        {en: "Hudhaify", ar: "الحذيفي"},
        {en: "Muhammad Jibreel", ar: "محمد جبريل"},
        {en: "Husary (Mujawwad)", ar: "الحصري (مجود)"},
        {en: "Minshawi (Mujawwad)", ar: "المنشاوي (مجود)"},
        {en: "Ahmed ibn Ali al-Ajamy", ar: "أحمد بن علي العجمي"}
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
        title: languageCombo.currentIndex === 1 ? "اختر ملف صوت الأذان" : "Select Adhan Audio File"
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

        // --- SECTION 1: LOCATION ---
        Kirigami.Separator { Kirigami.FormData.label: languageCombo.currentIndex === 1 ? "الموقع" : "Location"; Kirigami.FormData.isSection: true }

        CheckBox {
            id: useCoordsCheck
            text: languageCombo.currentIndex === 1 ? "استخدام الإحداثيات الدقيقة (موصى به)" : "Use Exact Coordinates (Recommended)"
            Kirigami.FormData.label: languageCombo.currentIndex === 1 ? "طريقة التحديد:" : "Method:"
        }

        RowLayout {
            visible: useCoordsCheck.checked
            Kirigami.FormData.label: languageCombo.currentIndex === 1 ? "الإحداثيات:" : "Coordinates:"
            TextField { id: latField; placeholderText: languageCombo.currentIndex === 1 ? "خط العرض" : "Latitude"; validator: DoubleValidator { bottom: -90.0; top: 90.0; decimals: 15 } }
            TextField { id: longField; placeholderText: languageCombo.currentIndex === 1 ? "خط الطول" : "Longitude"; validator: DoubleValidator { bottom: -180.0; top: 180.0; decimals: 15 } }
        }

        TextField {
            id: cityField
            visible: !useCoordsCheck.checked
            Kirigami.FormData.label: languageCombo.currentIndex === 1 ? "المدينة:" : "City:"
            placeholderText: languageCombo.currentIndex === 1 ? "مثال: القاهرة" : "e.g. Cairo"
        }
        TextField {
            id: countryField
            visible: !useCoordsCheck.checked
            Kirigami.FormData.label: languageCombo.currentIndex === 1 ? "الدولة:" : "Country:"
            placeholderText: languageCombo.currentIndex === 1 ? "مثال: مصر" : "e.g. Egypt"
        }

        Button {
            text: languageCombo.currentIndex === 1 ? "اكتشاف الموقع تلقائياً (عبر الإنترنت)" : "Auto-Detect Location (IP)"
            icon.name: "system-search"
            Kirigami.FormData.label: "" // Aligns it properly under the fields
            Layout.alignment: Qt.AlignLeft
            onClicked: {
                let xhr = new XMLHttpRequest();
                xhr.open("GET", "http://ip-api.com/json/", true);
                xhr.onreadystatechange = function() {
                    if (xhr.readyState === 4 && xhr.status === 200) {
                        try {
                            let data = JSON.parse(xhr.responseText);
                            cityField.text = data.city || "";
                            countryField.text = data.country || "";
                            if (data.lat && data.lon) {
                                latField.text = data.lat.toString();
                                longField.text = data.lon.toString();
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

        ComboBox {
            id: methodCombo
            Kirigami.FormData.label: languageCombo.currentIndex === 1 ? "طريقة الحساب:" : "Calculation Method:"
            textRole: languageCombo.currentIndex === 1 ? "ar" : "en"
            model: [
                { ar: "الشيعة الاثنا عشرية", en: "Shia Ithna-Ansari" },
                { ar: "جامعة العلوم الإسلامية بكراتشي", en: "University of Islamic Sciences, Karachi" },
                { ar: "الجمعية الإسلامية لأمريكا الشمالية", en: "Islamic Society of North America" },
                { ar: "رابطة العالم الإسلامي", en: "Muslim World League" },
                { ar: "جامعة أم القرى بمكة المكرمة", en: "Umm Al-Qura University, Makkah" },
                { ar: "الهيئة العامة المصرية للمساحة", en: "Egyptian General Authority of Survey" },
                { ar: "معهد الجيوفيزياء بجامعة طهران", en: "Institute of Geophysics, University of Tehran" },
                { ar: "منطقة الخليج", en: "Gulf Region" },
                { ar: "الكويت", en: "Kuwait" },
                { ar: "قطر", en: "Qatar" },
                { ar: "مجلس الشؤون الإسلامية بسنغافورة", en: "Majlis Ugama Islam Singapura, Singapore" },
                { ar: "اتحاد المنظمات الإسلامية بفرنسا", en: "Union Organization islamic de France" },
                { ar: "رئاسة الشؤون الدينية التركية", en: "Diyanet Isleri Baskanligi, Turkey" },
                { ar: "الإدارة الدينية لمسلمي روسيا", en: "Spiritual Administration of Muslims of Russia" },
                { ar: "المغرب", en: "Morocco" }
            ]
        }
        ComboBox { 
            id: schoolCombo
            Kirigami.FormData.label: languageCombo.currentIndex === 1 ? "المذهب الفقهي (العصر):" : "School (Juristic):"
            textRole: languageCombo.currentIndex === 1 ? "ar" : "en"
            model: [
                { ar: "الشافعي / الحنبلي / المالكي (القياسي)", en: "Shafi (Standard)" },
                { ar: "الحنفي", en: "Hanafi" }
            ]
        }

        // --- SECTION 2: APPEARANCE & NOTIFICATIONS ---
        Kirigami.Separator { Kirigami.FormData.label: languageCombo.currentIndex === 1 ? "الإعدادات العامة" : "General Settings"; Kirigami.FormData.isSection: true }

        ComboBox {
            id: compactStyleCombo
            Kirigami.FormData.label: languageCombo.currentIndex === 1 ? "شكل العرض المصغر:" : "Compact View Style:"
            textRole: languageCombo.currentIndex === 1 ? "ar" : "en"
            model: [
                { ar: "رأسي (قياسي)", en: "Vertical Standard" },
                { ar: "جنبا إلى جنب", en: "Side by Side" },
                { ar: "تبديل رأسي", en: "Toggle Vertical" },
                { ar: "تبديل أفقي", en: "Toggle Horizontal" },
                { ar: "أفقي متبقي", en: "Horizontal Remaining" },
                { ar: "أفقي(قياسي)", en: "Horizontal Single Line" }
            ]
        }
        ComboBox {
            id: languageCombo;
            Kirigami.FormData.label: languageCombo.currentIndex === 1 ? "اللغة:" : "Language:";
            model: ["English", "العربية (Arabic)"]
        }
        CheckBox {
            id: useArabicNumbersCheck
            text: languageCombo.currentIndex === 1 ? "تدوين الأرقام بالصيغة العربية (٠١٢٣٤٥٦٧٨٩)" : "Use Arabic-Indic Numerals for dates and times"
            Kirigami.FormData.label: ""
            visible: languageCombo.currentIndex === 1
        }
        CheckBox { id: hourFormatCheck; text: languageCombo.currentIndex === 1 ? "نظام ١٢ ساعة (ص/م)" : "Use 12-hour format (AM/PM)"; Kirigami.FormData.label: languageCombo.currentIndex === 1 ? "صيغة الوقت:" : "Time Format:" }

        Kirigami.Separator { Kirigami.FormData.label: languageCombo.currentIndex === 1 ? "التنبيهات" : "Notifications"; Kirigami.FormData.isSection: true }

        CheckBox {
            id: notificationsCheck
            text: languageCombo.currentIndex === 1 ? "إظهار إشعار عند دخول وقت الصلاة" : "Show notification on exact prayer time"
            Kirigami.FormData.label: languageCombo.currentIndex === 1 ? "التنبيه الأساسي:" : "Main Alert:"
        }

        ColumnLayout {
            Kirigami.FormData.label: languageCombo.currentIndex === 1 ? "قبل الأذان:" : "Pre-Adhan:"
            spacing: 0
            RowLayout {
                SpinBox { id: preNotificationSpinBox; from: 0; to: 60 }
                Label { text: languageCombo.currentIndex === 1 ? "دقيقة قبل الصلاة" : "minutes before" }
            }
            CheckBox {
                id: preAdhanSoundCheck
                text: languageCombo.currentIndex === 1 ? "تشغيل صوت التنبيه" : "Play notification sound"
                enabled: preNotificationSpinBox.value > 0
            }
        }

        ColumnLayout {
            Kirigami.FormData.label: languageCombo.currentIndex === 1 ? "الإقامة (بعد الأذان):" : "Iqamah (Post-Adhan):"
            spacing: 0
            RowLayout {
                SpinBox { id: postNotificationSpinBox; from: 0; to: 60 }
                Label { text: languageCombo.currentIndex === 1 ? "دقيقة بعد الأذان" : "minutes after" }
            }
            CheckBox {
                id: postAdhanSoundCheck
                text: languageCombo.currentIndex === 1 ? "تشغيل صوت التنبيه" : "Play notification sound"
                enabled: postNotificationSpinBox.value > 0
            }
        }

        // ==========================================
        // WIDGET FEATURES
        // ==========================================
        Kirigami.Separator { Kirigami.FormData.label: languageCombo.currentIndex === 1 ? "ميزات الإضافة" : "Widget Features"; Kirigami.FormData.isSection: true }

        ColumnLayout {
            Kirigami.FormData.label: languageCombo.currentIndex === 1 ? "القرآن الكريم:" : "Quran:"
            spacing: 0
            CheckBox {
                id: enableQuranCheck
                text: languageCombo.currentIndex === 1 ? "تفعيل مشغل القرآن والآية اليومية" : "Enable Quran Player & Daily Verse"
            }
            CheckBox {
                id: showCompactMediaCheck
                text: languageCombo.currentIndex === 1 ? "إظهار زر التشغيل/الإيقاف في العرض المصغر" : "Show Play/Pause button in compact view"
                enabled: enableQuranCheck.checked
            }
        }

        // --- SECTION 3: AUDIO & ADHAN ---
        Kirigami.Separator { Kirigami.FormData.label: languageCombo.currentIndex === 1 ? "الصوتيات والأذان" : "Audio & Adhan"; Kirigami.FormData.isSection: true }

        ComboBox {
            id: reciterCombo
            Kirigami.FormData.label: languageCombo.currentIndex === 1 ? "القارئ:" : "Quran Reciter:"
            textRole: languageCombo.currentIndex === 1 ? "ar" : "en"
            model: reciterNamesModel
        }

        RowLayout {
            Kirigami.FormData.label: languageCombo.currentIndex === 1 ? "ملف الأذان الصوتي:" : "Adhan Audio File:"
            TextField {
                id: adhanPathField
                Layout.fillWidth: true
                placeholderText: languageCombo.currentIndex === 1 ? "استخدام الأذان الافتراضي..." : "Using default adhan..."
            }
            Button {
                text: languageCombo.currentIndex === 1 ? "تصفح..." : "Browse..."; icon.name: "document-open"
                onClicked: fileDialog.open()
            }
            Button {
                text: languageCombo.currentIndex === 1 ? "استعادة" : "Reset"; icon.name: "edit-clear"
                onClicked: adhanPathField.text = defaultAdhanPath
            }
            Button {
                text: languageCombo.currentIndex === 1 ? "مسح" : "Clear"; enabled: adhanPathField.text.length > 0
                onClicked: adhanPathField.text = ""
            }
        }

        Button {
            text: previewPlayer.playbackState === MediaPlayer.PlayingState ? (languageCombo.currentIndex === 1 ? "إيقاف الأذان" : "Stop Adhan") : (languageCombo.currentIndex === 1 ? "تجربة صوت الأذان" : "Test Adhan Sound")
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
            Kirigami.FormData.label: languageCombo.currentIndex === 1 ? "مستوى صوت الأذان:" : "Adhan Volume:"
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
            Kirigami.FormData.label: languageCombo.currentIndex === 1 ? "صيغة التشغيل:" : "Adhan Playback:"
            textRole: languageCombo.currentIndex === 1 ? "ar" : "en"
            model: [
                { ar: "بدون أذان", en: "No Adhan" },
                { ar: "أذان كامل", en: "Full Adhan" },
                { ar: "قصير (40 ثانية)", en: "Short (40s)" },
                { ar: "قصير جداً (17 ثانية)", en: "Very Short (17s)" }
            ]
        }

        GridLayout {
            columns: 3; Kirigami.FormData.label: languageCombo.currentIndex === 1 ? "تشغيل الأذان لـ:" : "Play Adhan For:"
            CheckBox { id: playFajrCheck; text: languageCombo.currentIndex === 1 ? "الفجر" : "Fajr" }
            CheckBox { id: playDhuhrCheck; text: languageCombo.currentIndex === 1 ? "الظهر" : "Dhuhr" }
            CheckBox { id: playAsrCheck; text: languageCombo.currentIndex === 1 ? "العصر" : "Asr" }
            CheckBox { id: playMaghribCheck; text: languageCombo.currentIndex === 1 ? "المغرب" : "Maghrib" }
            CheckBox { id: playIshaCheck; text: languageCombo.currentIndex === 1 ? "العشاء" : "Isha" }
        }

        // --- SECTION 4: ADJUSTMENTS ---
        Kirigami.Separator { Kirigami.FormData.label: languageCombo.currentIndex === 1 ? "التعديلات اليدوية" : "Adjustments"; Kirigami.FormData.isSection: true }

        Label {
            text: languageCombo.currentIndex === 1 ? "تعديل أوقات الصلاة بالدقائق (+/-)" : "Adjust times in minutes (+/-)"
            font.italic: true
            Layout.fillWidth: true
            opacity: 0.7
        }

        GridLayout {
            columns: 4
            rowSpacing: Kirigami.Units.smallSpacing
            columnSpacing: Kirigami.Units.largeSpacing

            Label { text: languageCombo.currentIndex === 1 ? "الفجر:" : "Fajr:" }
            SpinBox { id: fajrOffset; from: -60; to: 60; editable: true }

            Label { text: languageCombo.currentIndex === 1 ? "الشروق:" : "Sunrise:" }
            SpinBox { id: sunriseOffset; from: -60; to: 60; editable: true }

            Label { text: languageCombo.currentIndex === 1 ? "الظهر:" : "Dhuhr:" }
            SpinBox { id: dhuhrOffset; from: -60; to: 60; editable: true }

            Label { text: languageCombo.currentIndex === 1 ? "العصر:" : "Asr:" }
            SpinBox { id: asrOffset; from: -60; to: 60; editable: true }

            Label { text: languageCombo.currentIndex === 1 ? "المغرب:" : "Maghrib:" }
            SpinBox { id: maghribOffset; from: -60; to: 60; editable: true }

            Label { text: languageCombo.currentIndex === 1 ? "العشاء:" : "Isha:" }
            SpinBox { id: ishaOffset; from: -60; to: 60; editable: true }
        }

        RowLayout {
            Kirigami.FormData.label: languageCombo.currentIndex === 1 ? "تعديل التاريخ الهجري:" : "Hijri Date Offset:"
            SpinBox {
                id: hijriOffsetSpin
                from: -5; to: 5
                editable: true
            }
            Label { text: languageCombo.currentIndex === 1 ? "أيام" : "days" }
        }

        CheckBox { id: showBackgroundCheck; text: languageCombo.currentIndex === 1 ? "إظهار الخلفية" : "Show background"; Kirigami.FormData.label: "" }
        Label {
            text: languageCombo.currentIndex === 1 ? "اتركه مفعلاً إذا لم تلاحظ فرقاً" : "Leave checked if no difference"
            font.italic: true
            Layout.fillWidth: true
            opacity: 0.7
        }

    }
}
