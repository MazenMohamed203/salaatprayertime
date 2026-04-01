import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.plasma.plasmoid
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami as Kirigami

Item {
    id: root

    // --- Master Toggles ---
    property bool quranEnabled: Plasmoid.configuration.enableQuran !== undefined ? Plasmoid.configuration.enableQuran : true
    property bool mediaBtnEnabled: Plasmoid.configuration.showCompactMediaButton !== undefined ? Plasmoid.configuration.showCompactMediaButton : true
    property bool showMediaBtn: quranEnabled && mediaBtnEnabled

    property real customFontSize: Kirigami.Theme.defaultFont.pointSize * 1.05

    property real baseWidth: (compactStyle === 1) ? Kirigami.Units.gridUnit * 7.5 :
    (compactStyle === 3 || compactStyle === 5) ? Kirigami.Units.gridUnit * 9.5 :
    (compactStyle === 4) ? Kirigami.Units.gridUnit * 8.5 :
    Kirigami.Units.gridUnit * 7.5

    implicitWidth: showMediaBtn ? baseWidth + Kirigami.Units.iconSizes.small + Kirigami.Units.smallSpacing : baseWidth

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

    // --- Helper function to get localized text ---
    function getRemainingText() {
        return (languageIndex === 1) ? "متبقي" : i18n("After");
    }

    function getTimeLeftText() {
        return (languageIndex === 1) ? "الوقت المتبقي:" : i18n("Time Left:");
    }

    function getCompactRemainingWord() {
        return (languageIndex === 1) ? "متبقي" : "left";
    }

    // --- Helper function to parse time string to Date object ---
    function parseTimeToDate(timeString) {
        if (!timeString || timeString === "--:--") return null;

        let cleanTime = timeString.replace(/\s*(AM|PM|am|pm)\s*/g, '');
        let parts = cleanTime.split(':');
        if (parts.length < 2) return null;

        let hours = parseInt(parts[0], 10);
        let minutes = parseInt(parts[1], 10);

        if (timeString.toLowerCase().includes('pm') && hours !== 12) {
            hours += 12;
        } else if (timeString.toLowerCase().includes('am') && hours === 12) {
            hours = 0;
        }

        let dateObj = new Date();
        dateObj.setHours(hours);
        dateObj.setMinutes(minutes);
        dateObj.setSeconds(0);
        dateObj.setMilliseconds(0);

        return dateObj;
    }

    // --- Timer for 5-minute pre-prayer alert ---
    Timer {
        id: prePrayerAlertTimer
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            if (!nextPrayerName || !nextPrayerTime || nextPrayerTime === "--:--") {
                root.isPrePrayerAlertActive = false;
                return;
            }

            let prayerTimeObj = parseTimeToDate(nextPrayerTime);
            if (!prayerTimeObj) {
                root.isPrePrayerAlertActive = false;
                return;
            }

            let now = new Date();

            if (nextPrayerName === "Fajr" && prayerTimeObj < now) {
                prayerTimeObj.setDate(prayerTimeObj.getDate() + 1);
            }

            let timeDiff = prayerTimeObj.getTime() - now.getTime();
            let fiveMinutesInMs = 5 * 60 * 1000;
            let newAlertState = (timeDiff > 0 && timeDiff <= fiveMinutesInMs);

            if (root.isPrePrayerAlertActive && !newAlertState) {
                alertBackground.color = "transparent";
                gradientBackground.opacity = 0.0;
            }

            root.isPrePrayerAlertActive = newAlertState;
        }
    }

    // --- Timers for Toggle Mode ---
    Timer {
        id: toggleTimer
        interval: 18000
        running: root.compactStyle === 2 || root.compactStyle === 4
        repeat: true
        onTriggered: {
            root.toggleViewIsPrayerTime = false;
            toggleReturnTimer.start();
        }
    }

    Timer {
        id: toggleReturnTimer
        interval: 8000
        repeat: false
        onTriggered: {
            root.toggleViewIsPrayerTime = true;
        }
    }


    Rectangle {
        id: alertBackground
        anchors.fill: parent

        anchors.margins: -8

        color: "transparent"

        radius: 10

        SequentialAnimation on color {
            id: subtleFlashAnimation
            loops: Animation.Infinite
            running: root.isPrePrayerAlertActive
            onRunningChanged: if (!running) alertBackground.color = "transparent"
            ColorAnimation { from: "transparent"; to: Qt.rgba(1.0, 0.84, 0.0, 0.15); duration: 2000; easing.type: Easing.InOutSine }
            ColorAnimation { from: Qt.rgba(1.0, 0.84, 0.0, 0.15); to: "transparent"; duration: 2000; easing.type: Easing.InOutSine }
        }

        border.width: root.isPrePrayerAlertActive ? 1.5 : 0
        border.color: Qt.rgba(1.0, 0.84, 0.0, 0.4)

        // Subtler outer shadow/glow
        Rectangle {
            id: shadowEffect
            anchors.fill: parent
            anchors.margins: -1.5
            color: "transparent"
            radius: parent.radius + 1
            border.width: root.isPrePrayerAlertActive ? 1 : 0
            border.color: Qt.rgba(1.0, 0.84, 0.0, 0.08)
            z: -1
        }
    }

    Rectangle {
        id: gradientBackground
        anchors.fill: parent

        anchors.margins: -8

        color: "transparent"
        radius: 10
        visible: root.isPrePrayerAlertActive
        opacity: 0.0

        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(1.0, 0.84, 0.0, 0.05) }
            GradientStop { position: 0.5; color: Qt.rgba(1.0, 0.84, 0.0, 0.12) }
            GradientStop { position: 1.0; color: Qt.rgba(1.0, 0.84, 0.0, 0.05) }
        }

        SequentialAnimation on opacity {
            loops: Animation.Infinite
            running: root.isPrePrayerAlertActive
            onRunningChanged: if (!running) gradientBackground.opacity = 0.0
            NumberAnimation { from: 0.0; to: 1.0; duration: 3000; easing.type: Easing.InOutQuad }
            NumberAnimation { from: 1.0; to: 0.0; duration: 3000; easing.type: Easing.InOutQuad }
        }
    }

    // --- MouseArea ---
    MouseArea {
        id: mouseArea
        property bool wasExpanded: false
        anchors.fill: parent
        hoverEnabled: true

        onPressed: wasExpanded = root.plasmoidItem ? root.plasmoidItem.expanded : false
        onClicked: mouse => {
            if (root.plasmoidItem) {
                root.plasmoidItem.expanded = !wasExpanded
            }
        }
    }

    // --- Layouts (YOUR ORIGINAL EXACT CODE) ---
    StackLayout {
        id: layoutSwitcher
        anchors.fill: parent
        anchors.leftMargin: 2
        anchors.topMargin: 2
        anchors.bottomMargin: 2

        anchors.rightMargin: root.showMediaBtn ? (Kirigami.Units.iconSizes.small + Kirigami.Units.smallSpacing + 2) : 2

        currentIndex: {
            if (root.compactStyle === 1) return 1; // Countdown view
            if (root.compactStyle === 3) return 2; // Horizontal view
            if (root.compactStyle === 4) return 3; // Compact Toggle view
            if (root.compactStyle === 5) return 4; // Horizontal remaining time
            return 0; // Normal & Toggle view
        }

        // Item 0: Normal & Toggle View
        Label {
            id: normalAndToggleLabel
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            // Apply new scaled font
            font.pointSize: root.customFontSize
            fontSizeMode: Text.Fit

            color: root.isPrePrayerAlertActive ?
            Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.9) :
            Kirigami.Theme.textColor

            // Bolder text
            font.weight: root.isPrePrayerAlertActive ? Font.Bold : Font.Medium

            text: {
                if (root.compactStyle === 2 && !root.toggleViewIsPrayerTime) {
                    return getTimeLeftText() + "\n" + root.countdownText.substring(0, 5);
                } else {
                    return root.nextPrayerName + "\n" + root.nextPrayerTime;
                }
            }
        }

        // Item 1: Countdown View (side-by-side)
        RowLayout {
            id: countdownView
            spacing: Kirigami.Units.largeSpacing
            anchors.centerIn: parent

            Label {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                horizontalAlignment: Text.AlignHCenter

                // Keep the relative size logic, just using our custom scaled base
                font.pointSize: root.customFontSize - 1

                color: root.isPrePrayerAlertActive ?
                Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.9) :
                Kirigami.Theme.textColor

                font.weight: root.isPrePrayerAlertActive ? Font.Bold : Font.Medium
                text: root.nextPrayerName + "\n" + root.nextPrayerTime
            }

            Rectangle {
                width: 1
                Layout.fillHeight: true
                Layout.topMargin: Kirigami.Units.smallSpacing
                Layout.bottomMargin: Kirigami.Units.smallSpacing
                color: root.isPrePrayerAlertActive ?
                Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.9) :
                Kirigami.Theme.textColor
                opacity: 0.4
            }

            Label {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                horizontalAlignment: Text.AlignHCenter

                font.pointSize: root.customFontSize - 1

                color: root.isPrePrayerAlertActive ?
                Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.9) :
                Kirigami.Theme.textColor

                font.weight: root.isPrePrayerAlertActive ? Font.Bold : Font.Medium
                text: getRemainingText() + "\n" + root.countdownText.substring(0, 5);
            }
        }

        // Item 2: NEW - Horizontal View (prayer name next to time)
        RowLayout {
            id: horizontalView
            spacing: Kirigami.Units.smallSpacing
            anchors.centerIn: parent

            Label {
                Layout.alignment: Qt.AlignVCenter
                horizontalAlignment: Text.AlignRight

                font.pointSize: root.customFontSize

                color: root.isPrePrayerAlertActive ?
                Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.9) :
                Kirigami.Theme.textColor

                font.weight: root.isPrePrayerAlertActive ? Font.Bold : Font.Medium
                text: root.nextPrayerName
            }

            Label {
                Layout.alignment: Qt.AlignVCenter
                horizontalAlignment: Text.AlignLeft

                font.pointSize: root.customFontSize

                color: root.isPrePrayerAlertActive ?
                Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.9) :
                Kirigami.Theme.textColor

                font.weight: root.isPrePrayerAlertActive ? Font.Bold : Font.Medium
                text: root.nextPrayerTime
            }
        }

        // Item 3: Compact Toggle (horizontal prayer/time, then compact remaining mode)
        RowLayout {
            id: compactToggleView
            spacing: Kirigami.Units.smallSpacing
            anchors.centerIn: parent

            Label {
                Layout.alignment: Qt.AlignVCenter
                horizontalAlignment: Text.AlignRight

                font.pointSize: root.customFontSize

                color: root.isPrePrayerAlertActive ?
                Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.9) :
                Kirigami.Theme.textColor

                font.weight: root.isPrePrayerAlertActive ? Font.Bold : Font.Medium
                text: (root.toggleViewIsPrayerTime ? root.nextPrayerName : getCompactRemainingWord())
            }

            Label {
                Layout.alignment: Qt.AlignVCenter
                horizontalAlignment: Text.AlignLeft

                font.pointSize: root.customFontSize

                color: root.isPrePrayerAlertActive ?
                Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.9) :
                Kirigami.Theme.textColor

                font.weight: root.isPrePrayerAlertActive ? Font.Bold : Font.Medium
                text: (root.toggleViewIsPrayerTime ? root.nextPrayerTime : root.countdownText.substring(0, 5))
            }
        }

        // Item 4: Horizontal (Remaining Time)
        RowLayout {
            id: horizontalRemainingView
            spacing: Kirigami.Units.smallSpacing
            anchors.centerIn: parent

            Label {
                Layout.alignment: Qt.AlignVCenter
                horizontalAlignment: Text.AlignRight

                font.pointSize: root.customFontSize

                color: root.isPrePrayerAlertActive ?
                Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.9) :
                Kirigami.Theme.textColor

                font.weight: root.isPrePrayerAlertActive ? Font.Bold : Font.Medium
                text: root.nextPrayerName
            }

            Label {
                Layout.alignment: Qt.AlignVCenter
                horizontalAlignment: Text.AlignLeft

                font.pointSize: root.customFontSize

                color: root.isPrePrayerAlertActive ?
                Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.9) :
                Kirigami.Theme.textColor

                font.weight: root.isPrePrayerAlertActive ? Font.Bold : Font.Medium
                text: root.countdownText.substring(0, 5)
            }
        }
    }

    // --- Media Button Overlay ---
    ToolButton {
        id: mediaButton
        visible: root.showMediaBtn

        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.rightMargin: 2

        width: Kirigami.Units.iconSizes.small
        height: Kirigami.Units.iconSizes.small

        flat: true
        hoverEnabled: true
        focusPolicy: Qt.NoFocus // NO YELLOW BOXES!

        property bool isAudioActive: (root.plasmoidItem && root.plasmoidItem.isAnyAudioPlaying)
        opacity: (isAudioActive || mouseArea.containsMouse || hovered) ? 1.0 : 0.0
        Behavior on opacity { NumberAnimation { duration: 150 } }

        icon.name: isAudioActive ? "media-playback-pause" : "media-playback-start"

        onClicked: {
            if (root.plasmoidItem) root.plasmoidItem.togglePlayback()
        }
    }

    // --- Subtle tooltip ---
    ToolTip {
        id: debugTooltip
        visible: mouseArea.containsMouse && root.isPrePrayerAlertActive
        text: {
            if (root.languageIndex === 1) {
                return "تنبيه: باقي 5 دقائق على " + root.nextPrayerName;
            } else {
                return "Alert: " + root.nextPrayerName + " in 5 minutes";
            }
        }
    }
}


