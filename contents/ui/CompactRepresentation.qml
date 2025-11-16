import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

Item {
    id: root

    // Smart width calculation
    implicitWidth: {
        let baseWidth = (compactStyle === 3) ? Kirigami.Units.gridUnit * 9 : Kirigami.Units.gridUnit * 7
        return (mediaButton.visible) ? baseWidth + Kirigami.Units.iconSizes.small : baseWidth
    }

    // --- Properties passed from main.qml ---
    property var prayerTimesData: ({})
    property PlasmoidItem plasmoidItem
    property string nextPrayerName: ""
    property string nextPrayerTime: ""
    property string countdownText: ""
    property int compactStyle: 0

    // --- Properties for language and format ---
    property int languageIndex: 0
    property bool hourFormat: false

    // --- Internal Properties ---
    property bool isPrePrayerAlertActive: false
    property bool toggleViewIsPrayerTime: true
    readonly property int maxCompactLabelPixelSize: Kirigami.Theme.defaultFont.pixelSize
    readonly property int minCompactLabelPixelSize: 7

    // --- Helper functions ---
    function getRemainingText() { return (languageIndex === 1) ? "متبقي" : i18n("After"); }
    function getTimeLeftText() { return (languageIndex === 1) ? "الوقت المتبقي:" : i18n("Time Left:"); }

    function parseTimeToDate(timeString) {
        if (!timeString || timeString === "--:--") return null;
        let cleanTime = timeString.replace(/\s*(AM|PM|am|pm)\s*/g, '');
        let parts = cleanTime.split(':');
        if (parts.length < 2) return null;
        let hours = parseInt(parts[0], 10);
        let minutes = parseInt(parts[1], 10);
        if (timeString.toLowerCase().includes('pm') && hours !== 12) hours += 12;
        else if (timeString.toLowerCase().includes('am') && hours === 12) hours = 0;
        let dateObj = new Date();
        dateObj.setHours(hours); dateObj.setMinutes(minutes); dateObj.setSeconds(0); dateObj.setMilliseconds(0);
        return dateObj;
    }

    // --- Pre-Prayer Alert Timer ---
    Timer {
        id: prePrayerAlertTimer
        interval: 1000; running: true; repeat: true
        onTriggered: {
            if (!nextPrayerName || !nextPrayerTime || nextPrayerTime === "--:--") {
                root.isPrePrayerAlertActive = false; return;
            }
            let prayerTimeObj = parseTimeToDate(nextPrayerTime);
            if (!prayerTimeObj) { root.isPrePrayerAlertActive = false; return; }
            let now = new Date();
            if (nextPrayerName === "Fajr" && prayerTimeObj < now) prayerTimeObj.setDate(prayerTimeObj.getDate() + 1);
            let timeDiff = prayerTimeObj.getTime() - now.getTime();
            let newAlertState = (timeDiff > 0 && timeDiff <= 300000); // 5 mins
            if (root.isPrePrayerAlertActive && !newAlertState) {
                alertBackground.color = "transparent"; gradientBackground.opacity = 0.0;
            }
            root.isPrePrayerAlertActive = newAlertState;
        }
    }

    // --- Toggle Timers ---
    Timer {
        id: toggleTimer
        interval: 18000; running: root.compactStyle === 2; repeat: true
        onTriggered: { root.toggleViewIsPrayerTime = false; toggleReturnTimer.start(); }
    }
    Timer {
        id: toggleReturnTimer
        interval: 8000; repeat: false
        onTriggered: { root.toggleViewIsPrayerTime = true; }
    }

    // --- Backgrounds ---
    Rectangle {
        id: alertBackground
        anchors.fill: parent; color: "transparent"; radius: 4
        border.width: root.isPrePrayerAlertActive ? 1 : 0
        border.color: Qt.rgba(1.0, 0.84, 0.0, 0.3)
        SequentialAnimation on color {
            loops: Animation.Infinite; running: root.isPrePrayerAlertActive
            onRunningChanged: if (!running) alertBackground.color = "transparent"
            ColorAnimation { from: "transparent"; to: Qt.rgba(1.0, 0.84, 0.0, 0.15); duration: 2000; easing.type: Easing.InOutSine }
            ColorAnimation { from: Qt.rgba(1.0, 0.84, 0.0, 0.15); to: "transparent"; duration: 2000; easing.type: Easing.InOutSine }
        }
    }
    Rectangle {
        id: gradientBackground
        anchors.fill: parent; color: "transparent"; radius: 4
        visible: root.isPrePrayerAlertActive; opacity: 0.0
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(1.0, 0.84, 0.0, 0.05) }
            GradientStop { position: 0.5; color: Qt.rgba(1.0, 0.84, 0.0, 0.12) }
            GradientStop { position: 1.0; color: Qt.rgba(1.0, 0.84, 0.0, 0.05) }
        }
        SequentialAnimation on opacity {
            loops: Animation.Infinite; running: root.isPrePrayerAlertActive
            onRunningChanged: if (!running) gradientBackground.opacity = 0.0
            NumberAnimation { from: 0.0; to: 1.0; duration: 3000; easing.type: Easing.InOutQuad }
            NumberAnimation { from: 1.0; to: 0.0; duration: 3000; easing.type: Easing.InOutQuad }
        }
    }

    // --- MouseArea (Detects Hover) ---
    MouseArea {
        id: mouseArea
        property bool wasExpanded: false
        anchors.fill: parent
        hoverEnabled: true
        z: 0 // Ensure it is behind the button (which will be z: 99)
        onPressed: wasExpanded = root.plasmoidItem ? root.plasmoidItem.expanded : false
        onClicked: mouse => {
            if (root.plasmoidItem) root.plasmoidItem.expanded = !wasExpanded
        }
    }

    // --- MAIN LAYOUT ---
    RowLayout {
        anchors.fill: parent
        spacing: Kirigami.Units.smallSpacing

        // 1. The Text/Countdown Info
        StackLayout {
            id: layoutSwitcher
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: {
                if (root.compactStyle === 1) return 1;
                if (root.compactStyle === 3) return 2;
                return 0;
            }

            // Item 0: Normal & Toggle
            Label {
                horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                fontSizeMode: Text.Fit
                color: root.isPrePrayerAlertActive ? Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.9) : Kirigami.Theme.textColor
                font.weight: root.isPrePrayerAlertActive ? Font.Medium : Font.Normal
                text: (root.compactStyle === 2 && !root.toggleViewIsPrayerTime) ?
                (getTimeLeftText() + "\n" + root.countdownText.substring(0, 5)) :
                (root.nextPrayerName + "\n" + root.nextPrayerTime)
            }

            // Item 1: Countdown Side-by-Side
            RowLayout {
                spacing: Kirigami.Units.largeSpacing
                Label {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    color: root.isPrePrayerAlertActive ? Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.9) : Kirigami.Theme.textColor
                    text: root.nextPrayerName + "\n" + root.nextPrayerTime
                }
                Rectangle {
                    width: 1; Layout.fillHeight: true; Layout.topMargin: 4; Layout.bottomMargin: 4
                    color: Kirigami.Theme.textColor; opacity: 0.4
                }
                Label {
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    color: root.isPrePrayerAlertActive ? Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.9) : Kirigami.Theme.textColor
                    text: getRemainingText() + "\n" + root.countdownText.substring(0, 5)
                }
            }

            // Item 2: Horizontal (Merged Text)
            Label {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                color: root.isPrePrayerAlertActive ? Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.9) : Kirigami.Theme.textColor
                font.weight: root.isPrePrayerAlertActive ? Font.Medium : Font.Normal
                font.pointSize: Kirigami.Theme.defaultFont.pointSize
                text: root.nextPrayerName + "  " + root.nextPrayerTime
            }
        }

        // 2. The Play/Pause Button
        ToolButton {
            id: mediaButton
            Layout.preferredWidth: Kirigami.Units.iconSizes.small
            Layout.preferredHeight: Kirigami.Units.iconSizes.small
            Layout.alignment: Qt.AlignVCenter
            Layout.rightMargin: Kirigami.Units.smallSpacing

            flat: true
            hoverEnabled: true // IMPORTANT: Allows the button to detect hover too

            // Show if:
            // 1. Audio is Playing
            // 2. OR Mouse is over the general area (mouseArea)
            // 3. OR Mouse is over this button itself (mediaButton.hovered)
            visible: (root.plasmoidItem && root.plasmoidItem.isAnyAudioPlaying) || mouseArea.containsMouse || hovered

            icon.name: (root.plasmoidItem && root.plasmoidItem.isAnyAudioPlaying) ? "media-playback-pause" : "media-playback-start"

            onClicked: {
                if (root.plasmoidItem) {
                    root.plasmoidItem.togglePlayback()
                }
            }

            z: 99
        }
    }

    // --- Tooltip ---
    ToolTip {
        visible: mouseArea.containsMouse && root.isPrePrayerAlertActive
        text: (root.languageIndex === 1) ? "تنبيه: باقي 5 دقائق على " + root.nextPrayerName : "Alert: " + root.nextPrayerName + " in 5 minutes"
    }
}
