import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

RowLayout {
    id: pluginRoot
    
    // Injected by the Loader
    property var compactRoot

    anchors {
        horizontalCenter: parent.horizontalCenter
        verticalCenter: parent.verticalCenter
    }
    height: Math.min(implicitHeight, parent.height)
    spacing: Kirigami.Units.largeSpacing

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
        width: 1
        Layout.fillHeight: true
        Layout.topMargin: Kirigami.Units.smallSpacing
        Layout.bottomMargin: Kirigami.Units.smallSpacing

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
