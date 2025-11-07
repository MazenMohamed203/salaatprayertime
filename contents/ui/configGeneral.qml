import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import QtMultimedia

KCM.SimpleKCM {

    property alias cfg_city: cityField.text
    property alias cfg_country: countryField.text
    property alias cfg_notifications: notificationsCheckBox.checked
    property alias cfg_hourFormat: hourFormatCheckBox.checked
    property alias cfg_method: methodField.currentIndex
    property alias cfg_school: schoolField.currentIndex
    property alias cfg_languageIndex: languageField.currentIndex
    property alias cfg_compactStyle: compactStyleComboBox.currentIndex
    property alias cfg_preNotificationMinutes: preNotificationSpinBox.value
    property alias cfg_hijriOffset: hijriOffsetSpinBox.value
    property alias cfg_fajrOffsetMinutes: fajrOffsetSpin.value
    property alias cfg_sunriseOffsetMinutes: sunriseOffsetSpin.value
    property alias cfg_dhuhrOffsetMinutes: dhuhrOffsetSpin.value
    property alias cfg_asrOffsetMinutes: asrOffsetSpin.value
    property alias cfg_maghribOffsetMinutes: maghribOffsetSpin.value
    property alias cfg_ishaOffsetMinutes: ishaOffsetSpin.value
    property alias cfg_useCoordinates: useCoordinatesCheckBox.checked
    property alias cfg_latitude: latitudeField.text
    property alias cfg_longitude: longitudeField.text

    property alias cfg_adhanAudioPath: adhanAudioPathField.text
    property alias cfg_adhanPlaybackMode: adhanPlaybackModeComboBox.currentIndex
    property alias cfg_adhanVolume: adhanVolumeSlider.value
    property alias cfg_playAdhanForFajr: playAdhanForFajrCheckBox.checked
    property alias cfg_playAdhanForDhuhr: playAdhanForDhuhrCheckBox.checked
    property alias cfg_playAdhanForAsr: playAdhanForAsrCheckBox.checked
    property alias cfg_playAdhanForMaghrib: playAdhanForMaghribCheckBox.checked
    property alias cfg_playAdhanForIsha: playAdhanForIshaCheckBox.checked

    // Default adhan file path
    property string defaultAdhanPath: {

        let widgetRootUrl = Qt.resolvedUrl("../../").toString()

        // Construct the path to the audio file
        let audioFileUrl = widgetRootUrl + "contents/audio/Adhan.mp3"

        console.log("Config - Widget root URL:", widgetRootUrl)
        console.log("Config - Audio file URL:", audioFileUrl)

        return audioFileUrl
    }
    // ——— Invisible playback/test machinery lives here ———
    MediaPlayer {
        id: testPlayer
        audioOutput: testAudioOutput
        onErrorOccurred: console.log("KCM Test Player Error:", error, errorString)
        onPlaybackStateChanged: {
            if (playbackState === MediaPlayer.StoppedState) {
                testStopTimer.stop()
            }
        }
    }
    AudioOutput { id: testAudioOutput }
    Timer {
        id: testStopTimer
        interval: 40000; repeat: false
        onTriggered: {
            if (testPlayer.playbackState === MediaPlayer.PlayingState) {
                testPlayer.stop()
            }
        }
    }

    // ——— File dialog for choosing adhan audio ———
    FileDialog {
        id: adhanFileDialog
        title: i18n("Select Adhan Audio File")
        nameFilters: ["Audio files (*.mp3 *.wav *.m4a *.ogg *.flac)", "All files (*)"]
        fileMode: FileDialog.OpenFile

        onAccepted: {
            console.log("FileDialog accepted")

            // Try multiple properties to get the selected file
            let selectedPath = ""

            // Try the modern properties first
            if (typeof adhanFileDialog.selectedFile !== "undefined") {
                selectedPath = adhanFileDialog.selectedFile.toString()
                console.log("Using selectedFile:", selectedPath)
            } else if (typeof adhanFileDialog.fileUrl !== "undefined") {
                selectedPath = adhanFileDialog.fileUrl.toString()
                console.log("Using fileUrl:", selectedPath)
            } else if (typeof adhanFileDialog.currentFile !== "undefined") {
                selectedPath = adhanFileDialog.currentFile.toString()
                console.log("Using currentFile:", selectedPath)
            }

            // Clean up the path
            if (selectedPath) {
                // Remove file:// prefix if present
                if (selectedPath.startsWith("file://")) {
                    selectedPath = selectedPath.substring(7)
                }

                // Update the UI and configuration
                adhanAudioPathField.text = selectedPath
                cfg_adhanAudioPath = selectedPath

                console.log("Final selected path:", selectedPath)
            } else {
                console.error("Could not determine selected file path")
            }
        }

        onRejected: {
            console.log("File selection cancelled")
        }
    }

    // Initialize with default adhan if no custom path is set
    Component.onCompleted: {
        console.log("Default adhan path:", defaultAdhanPath)

        // Check if the default file exists and use it if no custom path is set
        if (!plasmoid.configuration.adhanAudioPath || plasmoid.configuration.adhanAudioPath === "") {
            adhanAudioPathField.text = defaultAdhanPath
            cfg_adhanAudioPath = defaultAdhanPath
            console.log("Using default adhan file:", defaultAdhanPath)
        }
    }

    Kirigami.FormLayout {
        anchors.fill: parent

        // — Location & Display —
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Location & Display")
        }
        CheckBox {
            id: useCoordinatesCheckBox
            Kirigami.FormData.label: i18n("Use Coordinates Instead of City/Country")
            checked: plasmoid.configuration.useCoordinates || false
        }

        // City/Country fields (only visible when not using coordinates)
        TextField {
            id: cityField
            Kirigami.FormData.label: i18n("City:")
            placeholderText: i18n("e.g. New York")
            text: plasmoid.configuration.city || ""
            visible: !useCoordinatesCheckBox.checked
            enabled: !useCoordinatesCheckBox.checked
        }
        TextField {
            id: countryField
            Kirigami.FormData.label: i18n("Country:")
            placeholderText: i18n("e.g. United States")
            text: plasmoid.configuration.country || ""
            visible: !useCoordinatesCheckBox.checked
            enabled: !useCoordinatesCheckBox.checked
        }

        // Coordinate fields (only visible when using coordinates)
        TextField {
            id: latitudeField
            Kirigami.FormData.label: i18n("Latitude:")
            placeholderText: i18n("e.g. 40.7128")
            text: plasmoid.configuration.latitude || ""
            visible: useCoordinatesCheckBox.checked
            enabled: useCoordinatesCheckBox.checked
            validator: DoubleValidator { bottom: -90.0; top: 90.0; decimals: 15 }
        }
        TextField {
            id: longitudeField
            Kirigami.FormData.label: i18n("Longitude:")
            placeholderText: i18n("e.g. -74.0060")
            text: plasmoid.configuration.longitude || ""
            visible: useCoordinatesCheckBox.checked
            enabled: useCoordinatesCheckBox.checked
            validator: DoubleValidator { bottom: -180.0; top: 180.0; decimals: 15 }
        }

        ComboBox {
            id: methodField
            Kirigami.FormData.label: i18n("Method:")
            model: [
                "Jafari / Shia Ithna-Ashari",
                "University of Islamic Sciences, Karachi",
                "Islamic Society of North America",
                "Muslim World League",
                "Umm Al-Qura University, Makkah",
                "Egyptian General Authority of Survey",
                "Institute of Geophysics, University of Tehran",
                "Gulf Region",
                "Kuwait",
                "Qatar",
                "Majlis Ugama Islam Singapura, Singapore",
                "Union Organization islamic de France",
                "Diyanet İşleri Başkanlığı, Turkey",
                "Spiritual Administration of Muslims of Russia",
                "Moonsighting Committee Worldwide",
                "Dubai (experimental)",
                "JAKIM, Malaysia",
                "Tunisia",
                "Algeria",
                "Indonesia",
                "Morocco",
                "Lisbon",
                "Jordan"
            ]
            currentIndex: plasmoid.configuration.method || 4
        }
        ComboBox {
            id: languageField
            Kirigami.FormData.label: i18n("Language:")
            model: [ i18n("English"), i18n("العربية") ]
            currentIndex: plasmoid.configuration.languageIndex || 0
        }
        ComboBox {
            id: schoolField
            Kirigami.FormData.label: i18n("School:")
            model: [ i18n("Shafi"), i18n("Hanafi") ]
            currentIndex: plasmoid.configuration.school || 0
        }
        ComboBox {
            id: compactStyleComboBox
            Kirigami.FormData.label: i18n("Compact View Style:")
            model: [
                i18n("Normal (Name/Time)"),
                i18n("Side-by-Side Countdown"),
                i18n("Toggle Every 18s"),
                i18n("Horizontal (Name next to Time)")  // NEW OPTION
            ]
            currentIndex: plasmoid.configuration.compactStyle || 0
            onCurrentIndexChanged: plasmoid.configuration.compactStyle = currentIndex
        }
        CheckBox {
            id: hourFormatCheckBox
            Kirigami.FormData.label: i18n("12-Hour Format")
            checked: plasmoid.configuration.hourFormat || false
        }
        CheckBox {
            id: notificationsCheckBox
            Kirigami.FormData.label: i18n("Enable Notifications")
            checked: plasmoid.configuration.notifications || false
        }

        // — Date & Time Adjustments —
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Date & Time Adjustments")
        }
        SpinBox{
            id: preNotificationSpinBox
            Kirigami.FormData.label: i18n("Pre-Adhan Notification (minutes)")
            from: 0 // 0 means turned off
            to: 60
            value: plasmoid.configuration.preNotificationMinutes || 10 
        }
        SpinBox {
            id: hijriOffsetSpinBox
            Kirigami.FormData.label: i18n("Hijri Date Adjustment (days):")
            from: -2; to: 2
            value: plasmoid.configuration.hijriOffset || 0
        }
        SpinBox {
            id: fajrOffsetSpin
            Kirigami.FormData.label: i18n("Fajr Offset (min):")
            from: -60; to: 60
            value: plasmoid.configuration.fajrOffsetMinutes || 0
        }
        SpinBox {
            id: sunriseOffsetSpin
            Kirigami.FormData.label: i18n("Sunrise Offset (min):")
            from: -60; to: 60
            value: plasmoid.configuration.sunriseOffsetMinutes || 0
        }
        SpinBox {
            id: dhuhrOffsetSpin
            Kirigami.FormData.label: i18n("Dhuhr Offset (min):")
            from: -60; to: 60
            value: plasmoid.configuration.dhuhrOffsetMinutes || 0
        }
        SpinBox {
            id: asrOffsetSpin
            Kirigami.FormData.label: i18n("Asr Offset (min):")
            from: -60; to: 60
            value: plasmoid.configuration.asrOffsetMinutes || 0
        }
        SpinBox {
            id: maghribOffsetSpin
            Kirigami.FormData.label: i18n("Maghrib Offset (min):")
            from: -60; to: 60
            value: plasmoid.configuration.maghribOffsetMinutes || 0
        }
        SpinBox {
            id: ishaOffsetSpin
            Kirigami.FormData.label: i18n("Isha Offset (min):")
            from: -60; to: 60
            value: plasmoid.configuration.ishaOffsetMinutes || 0
        }

        // — Adhan Audio Settings —
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Adhan Audio Settings")
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Adhan Audio File:")
            TextField {
                id: adhanAudioPathField
                Layout.fillWidth: true
                placeholderText: i18n("Using default adhan...")
                text: plasmoid.configuration.adhanAudioPath || defaultAdhanPath
                readOnly: true
            }
            Button { text: i18n("Browse…"); onClicked: adhanFileDialog.open() }
            Button {
                text: i18n("Reset to Default")
                onClicked: {
                    adhanAudioPathField.text = defaultAdhanPath
                    cfg_adhanAudioPath = defaultAdhanPath
                }
            }
            Button {
                text: i18n("Clear")
                enabled: adhanAudioPathField.text.length > 0
                onClicked: {
                    adhanAudioPathField.text = ""
                    cfg_adhanAudioPath = ""
                }
            }
        }
        ComboBox {
            id: adhanPlaybackModeComboBox
            Kirigami.FormData.label: i18n("Playback Mode:")
            model: [
                i18n("Off (No Audio)"),
                i18n("Full Adhan"),
                i18n("First 40 seconds only"),
                i18n("First 17 seconds only")
            ]
            currentIndex: plasmoid.configuration.adhanPlaybackMode || 4 // Default to "Full Adhan"
        }
        RowLayout {
            Kirigami.FormData.label: i18n("Volume:")
            Slider {
                id: adhanVolumeSlider
                Layout.fillWidth: true
                from: 0.0; to: 1.0; stepSize: 0.1
                value: plasmoid.configuration.adhanVolume || 0.7
                enabled: adhanPlaybackModeComboBox.currentIndex > 0
            }
            Label { text: Math.round(adhanVolumeSlider.value * 100) + "%" }
        }
        Kirigami.Separator {
            Kirigami.FormData.isSection: true
            Kirigami.FormData.label: i18n("Play Adhan For:")
        }
        CheckBox {
            id: playAdhanForFajrCheckBox
            Kirigami.FormData.label: i18n("Fajr")
            checked: plasmoid.configuration.playAdhanForFajr !== false
            enabled: adhanPlaybackModeComboBox.currentIndex > 0
        }
        CheckBox {
            id: playAdhanForDhuhrCheckBox
            Kirigami.FormData.label: i18n("Dhuhr")
            checked: plasmoid.configuration.playAdhanForDhuhr !== false
            enabled: adhanPlaybackModeComboBox.currentIndex > 0
        }
        CheckBox {
            id: playAdhanForAsrCheckBox
            Kirigami.FormData.label: i18n("Asr")
            checked: plasmoid.configuration.playAdhanForAsr !== false
            enabled: adhanPlaybackModeComboBox.currentIndex > 0
        }
        CheckBox {
            id: playAdhanForMaghribCheckBox
            Kirigami.FormData.label: i18n("Maghrib")
            checked: plasmoid.configuration.playAdhanForMaghrib !== false
            enabled: adhanPlaybackModeComboBox.currentIndex > 0
        }
        CheckBox {
            id: playAdhanForIshaCheckBox
            Kirigami.FormData.label: i18n("Isha")
            checked: plasmoid.configuration.playAdhanForIsha !== false
            enabled: adhanPlaybackModeComboBox.currentIndex > 0
        }
        Button {
            Kirigami.FormData.label: i18n("Test Audio:")
            text: i18n("Test Adhan Playback")
            enabled: adhanPlaybackModeComboBox.currentIndex > 0
            onClicked: {
                testStopTimer.stop()
                testPlayer.stop()
                let audioPath = adhanAudioPathField.text || defaultAdhanPath

                // Ensure proper URL format
                let sourceUrl = audioPath
                if (!sourceUrl.startsWith("file://") && !sourceUrl.startsWith("qrc:/")) {
                    sourceUrl = "file://" + sourceUrl
                }

                console.log("Test - Setting source to:", sourceUrl)
                testPlayer.source = sourceUrl
                testAudioOutput.volume = adhanVolumeSlider.value
                testPlayer.play()

                // Update this part to handle both 40-second and 10-second modes
                if (adhanPlaybackModeComboBox.currentIndex === 2) {
                    testStopTimer.start()  // 40 seconds
                } else if (adhanPlaybackModeComboBox.currentIndex === 3) {
                    testStopTimer.interval = 17000  // 10 seconds
                    testStopTimer.start()
                }
            }
        }
    }
}
