import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Label {
    id: pluginRoot
    
    // Injected by the Loader
    property var compactRoot

    anchors.fill: parent

    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    font.pointSize: compactRoot ? compactRoot.customFontSize : 10
    fontSizeMode: Text.Fit

    color: (compactRoot && compactRoot.isPrePrayerAlertActive) ? 
           Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.9) : 
           Kirigami.Theme.textColor

    font.weight: (compactRoot && compactRoot.isPrePrayerAlertActive) ? Font.Bold : Font.Medium

    text: compactRoot ? (compactRoot.nextPrayerName + "\n" + compactRoot.nextPrayerTime) : ""
}
