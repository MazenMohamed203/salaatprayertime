import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import QtMultimedia
import "Constants.js" as Logic

Dialog {
    id: quranDialog
    property var widgetRoot
    property var playerA
    property var playerB
    property var adhanStopTimer

    title: (widgetRoot.languageIndex === 1 ? "القرآن الكريم" : "Quran Player") + " (" + widgetRoot.activeReciterName + ")"
    modal: true
    standardButtons: Dialog.Close
    property int dialogWidth: Kirigami.Units.gridUnit * 22
    width: Overlay.overlay ? Math.round(Overlay.overlay.width * 0.9) : dialogWidth
    anchors.centerIn: Overlay.overlay
    padding: Kirigami.Units.largeSpacing

    Connections {
        target: widgetRoot
        function onCurrentSurahNumberChanged() {
            let idx = widgetRoot.currentSurahNumber - 1
            if (idx >= 0 && idx < surahCombo.count && surahCombo.currentIndex !== idx) {
                surahCombo.currentIndex = idx
                verseSpin.to = Logic.surahData[idx][2]
            }
        }
        function onCurrentAyahNumberChanged() {
            if (verseSpin.value !== widgetRoot.currentAyahNumber) {
                verseSpin.value = widgetRoot.currentAyahNumber
            }
        }
    }

    contentItem: ScrollView {
        id: scroller
        width: quranDialog.availableWidth
        contentWidth: availableWidth
        clip: true

        ColumnLayout {
            id: mainColumn
            width: scroller.availableWidth
            spacing: Kirigami.Units.largeSpacing

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                PlasmaComponents.ComboBox {
                    id: surahCombo
                    Layout.fillWidth: true
                    Layout.preferredWidth: 2
                    model: Logic.surahData.map(function(s, index) {
                        let surahNum = index + 1
                        return (widgetRoot.languageIndex === 1) ? (surahNum + ". " + s[1]) : (surahNum + ". " + s[0])
                    })

                    onActivated: {
                        verseSpin.to = Logic.surahData[currentIndex][2]
                        verseSpin.value = 1
                    }
                }

                PlasmaComponents.SpinBox {
                    id: verseSpin
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 5
                    from: 1
                    to: 7
                    value: 1
                    editable: true
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                PlasmaComponents.Button {
                    Layout.fillWidth: true
                    text: widgetRoot.languageIndex === 1 ? i18n("تشغيل") : i18n("Play")
                    icon.name: "media-playback-start"
                    enabled: !widgetRoot.isAnyAudioPlaying && !widgetRoot.isFetchingVerse
                    onClicked: {
                        widgetRoot.continuousPlayActive = false
                        widgetRoot.isAdhanPlaying = false
                        widgetRoot.isPlayingBasmalahGap = false
                        widgetRoot.nextTrackIsBasmalah = false
                        adhanStopTimer.stop()
                        playerA.stop(); playerB.stop()

                        let surahIndex = surahCombo.currentIndex + 1
                        let ayahIndex = verseSpin.value
                        widgetRoot.playSpecificVerse(surahIndex, ayahIndex)
                    }
                }

                PlasmaComponents.Button {
                    Layout.fillWidth: true
                    property var activePlayer: widgetRoot.isPlayerA_the_active_verse_player ? playerA : playerB
                    text: activePlayer.playbackState === MediaPlayer.PlayingState ? (widgetRoot.languageIndex === 1 ? i18n("إيقاف مؤقت") : i18n("Pause")) : (widgetRoot.languageIndex === 1 ? i18n("استئناف") : i18n("Resume"))
                    icon.name: activePlayer.playbackState === MediaPlayer.PlayingState ? "media-playback-pause" : "media-playback-start"
                    enabled: (activePlayer.playbackState === MediaPlayer.PlayingState || activePlayer.playbackState === MediaPlayer.PausedState)
                    onClicked: widgetRoot.togglePlayback()
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing
                PlasmaComponents.Label {
                    property var activePlayer: widgetRoot.isPlayerA_the_active_verse_player ? playerA : playerB
                    text: widgetRoot.formatTime(activePlayer.position)
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                }
                PlasmaComponents.Slider {
                    Layout.fillWidth: true
                    property var activePlayer: widgetRoot.isPlayerA_the_active_verse_player ? playerA : playerB
                    from: 0
                    to: activePlayer.duration > 0 ? activePlayer.duration : 1
                    value: activePlayer.position
                    onMoved: activePlayer.position = value
                    Connections {
                        target: widgetRoot
                        function onIsPlayerA_the_active_verse_playerChanged() {
                            parent.activePlayer = widgetRoot.isPlayerA_the_active_verse_player ? playerA : playerB;
                        }
                    }
                }
                PlasmaComponents.Label {
                    property var activePlayer: widgetRoot.isPlayerA_the_active_verse_player ? playerA : playerB
                    text: widgetRoot.formatTime(activePlayer.duration)
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing
                Kirigami.Icon {
                    source: "audio-volume-medium"
                    Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                    Layout.alignment: Qt.AlignVCenter
                }
                PlasmaComponents.Slider {
                    id: verseVolumeSlider
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter
                    from: 0.0; to: 1.0; stepSize: 0.05
                    value: widgetRoot.quranVolume
                    onValueChanged: widgetRoot.quranVolume = value
                }
                PlasmaComponents.Label {
                    text: Math.round(verseVolumeSlider.value * 100) + "%"
                    Layout.alignment: Qt.AlignVCenter
                    font.pointSize: Kirigami.Theme.smallFont.pointSize
                }
            }

            PlasmaComponents.Label {
                text: widgetRoot.dailyVerseArabic
                font.pointSize: Kirigami.Theme.defaultFont.pointSize + 2
                font.weight: Font.Medium
                font.family: "Noto Sans Arabic"
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                color: Kirigami.Theme.textColor
            }
            PlasmaComponents.Label {
                text: widgetRoot.dailyVerseTranslation
                font.pointSize: Kirigami.Theme.defaultFont.pointSize
                font.italic: true
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
                opacity: 0.9
                color: Kirigami.Theme.textColor
            }
            PlasmaComponents.Label {
                text: widgetRoot.dailyVerseReference
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                opacity: 0.7
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                color: Kirigami.Theme.textColor
            }
        }
    }

    Component.onCompleted: {
        let sIndex = widgetRoot.currentSurahNumber - 1
        if (sIndex < 0) sIndex = 0
        if (sIndex > 113) sIndex = 113
        surahCombo.currentIndex = sIndex
        verseSpin.to = Logic.surahData[sIndex][2]
        verseSpin.value = widgetRoot.currentAyahNumber
    }
}
