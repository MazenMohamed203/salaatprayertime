import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

GridLayout {
    id: pluginRoot
    
    // Injected by the Loader
    property var compactRoot

    // In a vertical panel the two blocks are stacked instead of being shown side
    // by side, and the separator is rotated to match.
    readonly property bool stacked: compactRoot ? compactRoot.verticalPanel === true : false

    anchors {
        horizontalCenter: parent.horizontalCenter
        verticalCenter: parent.verticalCenter
    }
    width: stacked ? parent.width : implicitWidth
    height: stacked ? parent.height : Math.min(implicitHeight, parent.height)

    columns: stacked ? 1 : 3
    columnSpacing: Kirigami.Units.largeSpacing
    rowSpacing: Kirigami.Units.smallSpacing

    Label {
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        Layout.fillHeight: true
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        font.pointSize: compactRoot ? (compactRoot.customFontSize - 1) : 10
        fontSizeMode: Text.Fit
        minimumPixelSize: 5

        color: (compactRoot && compactRoot.isPrePrayerAlertActive) ?
               Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.9) :
               Kirigami.Theme.textColor

        font.weight: (compactRoot && compactRoot.isPrePrayerAlertActive) ? Font.Bold : Font.Medium

        text: compactRoot ? (compactRoot.nextPrayerName + "\n" + compactRoot.nextPrayerTime) : ""
    }

    Rectangle {
        Layout.fillWidth: stacked
        Layout.fillHeight: !stacked
        Layout.preferredWidth: stacked ? -1 : 1
        Layout.preferredHeight: stacked ? 1 : -1
        Layout.topMargin: Kirigami.Units.smallSpacing
        Layout.bottomMargin: Kirigami.Units.smallSpacing
        Layout.leftMargin: stacked ? Kirigami.Units.smallSpacing : 0
        Layout.rightMargin: stacked ? Kirigami.Units.smallSpacing : 0

        color: (compactRoot && compactRoot.isPrePrayerAlertActive) ?
               Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.9) :
               Kirigami.Theme.textColor

        opacity: 0.4
    }

    Label {
        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
        Layout.fillHeight: true
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        font.pointSize: compactRoot ? (compactRoot.customFontSize - 1) : 10
        fontSizeMode: Text.Fit
        minimumPixelSize: 5

        color: (compactRoot && compactRoot.isPrePrayerAlertActive) ?
               Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.9) :
               Kirigami.Theme.textColor

        font.weight: (compactRoot && compactRoot.isPrePrayerAlertActive) ? Font.Bold : Font.Medium

        text: compactRoot ? (compactRoot.getRemainingText() + "\n" + compactRoot.countdownText.substring(0, 5)) : ""
    }
}
