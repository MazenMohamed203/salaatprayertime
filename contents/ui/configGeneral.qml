import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import QtMultimedia
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: root

    // ============================================================
    // SAFE STORAGE FOR RECITER INDEX
    // This prevents the ComboBox from resetting the setting to 0
    // when the language (and thus the model) changes.
    // ============================================================
    property int internalReciterIndex: 0

    // ============================================================
    // PROPERTY ALIASES
    // ============================================================

    // Map the XML setting to our safe internal property
    property alias cfg_quranReciterIndex: root.internalReciterIndex

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
    property alias cfg_notifications: notificationsCheck.checked
    property alias cfg_preNotificationMinutes: preNotificationSpinBox.value
    property alias cfg_playPreAdhanSound: preAdhanSoundCheck.checked

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
    // INTERNAL DATA & LOGIC
    // ============================================================

    property var reciterNamesEn: [
        "Minshawi (Murattal)", "Alafasy", "Husary (Murattal)",
        "Abdurrahmaan As-Sudais", "Maher Al Muaiqly", "Abu Bakr Ash-Shaatree",
        "Abdullah Basfar", "Abdulbasit (Murattal)", "Hudhaify", "Muhammad Jibreel",
        "Husary (Mujawwad)", "Minshawi (Mujawwad)", "Ahmed ibn Ali al-Ajamy"
    ]

    property var reciterNamesAr: [
        "المنشاوي (مرتل)", "العفاسي", "الحصري (مرتل)",
        "عبد الرحمن السديس", "ماهر المعيقلي", "أبو بكر الشاطري",
        "عبد الله بصفر", "عبد الباسط (مرتل)", "الحذيفي", "محمد جبريل",
        "الحصري (مجود)", "المنشاوي (مجود)", "أحمد بن علي العجمي"
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
        title: i18n("Select Adhan Audio File")
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

        // --- SECTION 1: LOCATION ---
        Kirigami.Separator { Kirigami.FormData.label: i18n("Location"); Kirigami.FormData.isSection: true }

        CheckBox {
            id: useCoordsCheck
            text: i18n("Use Exact Coordinates (Recommended)")
            Kirigami.FormData.label: i18n("Method:")
        }

        RowLayout {
            visible: useCoordsCheck.checked
            Kirigami.FormData.label: i18n("Coordinates:")
            TextField { id: latField; placeholderText: i18n("Latitude"); validator: DoubleValidator { bottom: -90.0; top: 90.0; decimals: 15 } }
            TextField { id: longField; placeholderText: i18n("Longitude"); validator: DoubleValidator { bottom: -180.0; top: 180.0; decimals: 15 } }
        }

        TextField {
            id: cityField
            visible: !useCoordsCheck.checked
            Kirigami.FormData.label: i18n("City:")
            placeholderText: i18n("e.g. Cairo")
        }
        TextField {
            id: countryField
            visible: !useCoordsCheck.checked
            Kirigami.FormData.label: i18n("Country:")
            placeholderText: i18n("e.g. Egypt")
        }

        ComboBox {
            id: methodCombo; Kirigami.FormData.label: i18n("Calculation Method:")
            model: ["Shia Ithna-Ansari", "University of Islamic Sciences, Karachi", "Islamic Society of North America", "Muslim World League", "Umm Al-Qura University, Makkah", "Egyptian General Authority of Survey", "Institute of Geophysics, University of Tehran", "Gulf Region", "Kuwait", "Qatar", "Majlis Ugama Islam Singapura, Singapore", "Union Organization islamic de France", "Diyanet Isleri Baskanligi, Turkey", "Spiritual Administration of Muslims of Russia"]
        }
        ComboBox { id: schoolCombo; Kirigami.FormData.label: i18n("School (Juristic):"); model: ["Shafi (Standard)", "Hanafi"] }


        // --- SECTION 2: APPEARANCE & NOTIFICATIONS ---
        Kirigami.Separator { Kirigami.FormData.label: i18n("General Settings"); Kirigami.FormData.isSection: true }

        ComboBox {
            id: compactStyleCombo; Kirigami.FormData.label: i18n("Compact View Style:")
            model: [i18n("Vertical (Standard)"), i18n("Side-by-Side"), i18n("Toggle View"), i18n("Horizontal (Single Line)")]
        }
        ComboBox {
            id: languageCombo;
            Kirigami.FormData.label: i18n("Language:");
            model: ["English", "Arabic"]
        }
        CheckBox { id: hourFormatCheck; text: i18n("Use 12-hour format (AM/PM)"); Kirigami.FormData.label: i18n("Time Format:") }

        CheckBox { id: notificationsCheck; text: i18n("Show notification on prayer time"); Kirigami.FormData.label: i18n("Alerts:") }

        RowLayout {
            Kirigami.FormData.label: i18n("Pre-Notification:")
            SpinBox { id: preNotificationSpinBox; from: 0; to: 60 }
            Label { text: i18n("minutes before") }
        }
        CheckBox { id: preAdhanSoundCheck; text: i18n("Play sound for pre-Adhan reminder"); Kirigami.FormData.label: "" }


        // --- SECTION 3: AUDIO & ADHAN ---
        Kirigami.Separator { Kirigami.FormData.label: i18n("Audio & Adhan"); Kirigami.FormData.isSection: true }

        // === FIXED COMBOBOX WITH SAFE PROXY ===
        ComboBox {
            id: reciterCombo
            Kirigami.FormData.label: i18n("Quran Reciter:")

            // 1. Bind visual state to our SAFE property
            currentIndex: internalReciterIndex

            // 2. Switch models based on language
            model: (languageCombo.currentIndex === 1) ? reciterNamesAr : reciterNamesEn

            // 3. Only update the safe property when the user CLICKS
            onActivated: internalReciterIndex = currentIndex

            // 4. THE FIX: If the model swaps and forces index to 0, force it back immediately
            onModelChanged: {
                if (currentIndex !== internalReciterIndex) {
                    currentIndex = internalReciterIndex
                }
            }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Adhan Audio File:")
            TextField {
                id: adhanPathField
                Layout.fillWidth: true
                placeholderText: i18n("Using default adhan...")
            }
            Button {
                text: i18n("Browse..."); icon.name: "document-open"
                onClicked: fileDialog.open()
            }
            Button {
                text: i18n("Reset"); icon.name: "edit-clear"
                onClicked: adhanPathField.text = defaultAdhanPath
            }
            Button {
                text: i18n("Clear"); enabled: adhanPathField.text.length > 0
                onClicked: adhanPathField.text = ""
            }
        }

        Button {
            text: previewPlayer.playbackState === MediaPlayer.PlayingState ? i18n("Stop Adhan") : i18n("Test Adhan Sound")
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
            Kirigami.FormData.label: i18n("Adhan Volume:")
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
            id: adhanModeCombo; Kirigami.FormData.label: i18n("Adhan Playback:")
            model: [i18n("No Adhan"), i18n("Full Adhan"), i18n("Short (40s)"), i18n("Very Short (17s)")]
        }

        GridLayout {
            columns: 3; Kirigami.FormData.label: i18n("Play Adhan For:")
            CheckBox { id: playFajrCheck; text: i18n("Fajr") }
            CheckBox { id: playDhuhrCheck; text: i18n("Dhuhr") }
            CheckBox { id: playAsrCheck; text: i18n("Asr") }
            CheckBox { id: playMaghribCheck; text: i18n("Maghrib") }
            CheckBox { id: playIshaCheck; text: i18n("Isha") }
        }


        // --- SECTION 4: ADJUSTMENTS ---
        Kirigami.Separator { Kirigami.FormData.label: i18n("Adjustments"); Kirigami.FormData.isSection: true }

        Label {
            text: i18n("Adjust times in minutes (+/-)")
            font.italic: true
            Layout.fillWidth: true
            opacity: 0.7
        }

        GridLayout {
            columns: 4
            rowSpacing: Kirigami.Units.smallSpacing
            columnSpacing: Kirigami.Units.largeSpacing

            Label { text: i18n("Fajr:") }
            SpinBox { id: fajrOffset; from: -60; to: 60; editable: true }

            Label { text: i18n("Sunrise:") }
            SpinBox { id: sunriseOffset; from: -60; to: 60; editable: true }

            Label { text: i18n("Dhuhr:") }
            SpinBox { id: dhuhrOffset; from: -60; to: 60; editable: true }

            Label { text: i18n("Asr:") }
            SpinBox { id: asrOffset; from: -60; to: 60; editable: true }

            Label { text: i18n("Maghrib:") }
            SpinBox { id: maghribOffset; from: -60; to: 60; editable: true }

            Label { text: i18n("Isha:") }
            SpinBox { id: ishaOffset; from: -60; to: 60; editable: true }
        }

        RowLayout {
            Kirigami.FormData.label: i18n("Hijri Date Offset:")
            SpinBox {
                id: hijriOffsetSpin
                from: -5; to: 5
                editable: true
            }
            Label { text: i18n("days") }
        }
    }
}
