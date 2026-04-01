import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

RowLayout {
    id: pluginRoot
    
    // Injected by the Loader
    property var compactRoot

    anchors.centerIn: parent
    spacing: Kirigami.Units.smallSpacing

    Label {
        Layout.alignment: Qt.AlignVCenter
        horizontalAlignment: Text.AlignRight

        font.pointSize: compactRoot ? compactRoot.customFontSize : 10

        color: (compactRoot && compactRoot.isPrePrayerAlertActive) ?
               Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.9) :
               Kirigami.Theme.textColor

        font.weight: (compactRoot && compactRoot.isPrePrayerAlertActive) ? Font.Bold : Font.Medium

        text: compactRoot ? compactRoot.nextPrayerName : ""
    }

    Label {
        Layout.alignment: Qt.AlignVCenter
        horizontalAlignment: Text.AlignLeft

        font.pointSize: compactRoot ? compactRoot.customFontSize : 10

        color: (compactRoot && compactRoot.isPrePrayerAlertActive) ?
               Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.9) :
               Kirigami.Theme.textColor

        font.weight: (compactRoot && compactRoot.isPrePrayerAlertActive) ? Font.Bold : Font.Medium

        text: compactRoot ? compactRoot.nextPrayerTime : ""
    }
}
