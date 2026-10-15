import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

GridLayout {
    id: pluginRoot
    
    // Injected by the Loader
    property var compactRoot

    // A vertical panel is far too narrow for the two labels to sit side by side,
    // so they are stacked on top of each other instead.
    readonly property bool stacked: compactRoot ? compactRoot.verticalPanel === true : false

    anchors.centerIn: parent
    // The stacked labels keep their natural height, so they stay together in the
    // middle of the panel instead of being spread over its whole length.
    width: stacked ? parent.width : implicitWidth

    columns: stacked ? 1 : 2
    columnSpacing: Kirigami.Units.smallSpacing
    rowSpacing: Kirigami.Units.smallSpacing

    Label {
        Layout.alignment: Qt.AlignVCenter
        Layout.fillWidth: stacked
        horizontalAlignment: stacked ? Text.AlignHCenter : Text.AlignRight
        verticalAlignment: Text.AlignVCenter

        font.pointSize: compactRoot ? compactRoot.customFontSize : 10
        fontSizeMode: stacked ? Text.Fit : Text.FixedSize
        minimumPixelSize: 5

        color: (compactRoot && compactRoot.isPrePrayerAlertActive) ?
               Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.9) :
               Kirigami.Theme.textColor

        font.weight: (compactRoot && compactRoot.isPrePrayerAlertActive) ? Font.Bold : Font.Medium

        text: compactRoot ? compactRoot.nextPrayerName : ""
    }

    Label {
        Layout.alignment: Qt.AlignVCenter
        Layout.fillWidth: stacked
        horizontalAlignment: stacked ? Text.AlignHCenter : Text.AlignLeft
        verticalAlignment: Text.AlignVCenter

        font.pointSize: compactRoot ? compactRoot.customFontSize : 10
        fontSizeMode: stacked ? Text.Fit : Text.FixedSize
        minimumPixelSize: 5

        color: (compactRoot && compactRoot.isPrePrayerAlertActive) ?
               Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.9) :
               Kirigami.Theme.textColor

        font.weight: (compactRoot && compactRoot.isPrePrayerAlertActive) ? Font.Bold : Font.Medium

        text: compactRoot ? compactRoot.nextPrayerTime : ""
    }
}
