import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid
import org.kde.notification
import QtCore
import QtMultimedia
import org.kde.plasma.core as PlasmaCore
import "Constants.js" as Logic
import "OfflinePrayerCalc.js" as OfflineCalc
PlasmoidItem {
    id: root

    Layout.minimumWidth: Kirigami.Units.gridUnit * 6.5
    Layout.preferredWidth: Kirigami.Units.gridUnit * 6.5
    Plasmoid.backgroundHints: (Plasmoid.configuration.showBackground === undefined || Plasmoid.configuration.showBackground) ? PlasmaCore.Types.StandardBackground : PlasmaCore.Types.NoBackground




    // =========================================================================
    // PROPERTIES & DATA
    // =========================================================================

    property var surahData: Logic.surahData

    // --- Widget State ---
    property var times: ({})
    property var displayPrayerTimes: ({})
    property var rawHijriDataFromApi: null
    property string hijriDateDisplay: "..."
    property string specialIslamicDateMessage: ""

    // --- Retry & Resume Logic ---
    property int retryResumePosition: 0
    property bool isRetrySeekPending: false
    property int lastKnownPosA: 0
    property int lastKnownPosB: 0

    // --- Adhan Restore Logic ---
    property string storedQuranUrl: ""
    property int storedQuranPos: 0
    property bool storedWasPlayerA: true
    property bool storedContinuousActive: false
    property bool storedWasPlaying: false

    property var nextPrayerDateTime: null
    property string timeUntilNextPrayer: ""
    property bool blockAdhanOnFetch: false
    property string nextPrayerNameForDisplay: ""
    property string nextPrayerTimeForDisplay: ""

    property string lastActivePrayer: ""
    property string activePrayer: ""
    property var preNotifiedPrayers: ({})
    property var postNotifiedPrayers: ({})

    property int currentHijriDay: 0
    property int currentHijriMonth: 0
    property int currentHijriYear: 0

    // --- Verse Data ---
    property string dailyVerseArabic: i18n("Loading...")
    property string dailyVerseTranslation: ""
    property string dailyVerseReference: ""
    property string dailyVerseAudioUrl: ""
    property int dailyVerseGlobalAyahNumber: 0
    property bool isFetchingVerse: false
    property bool continuousPlayActive: false

    property int currentSurahNumber: 1
    property int currentAyahNumber: 1

    // --- Queue ---
    property string nextQueuedArabic: ""
    property string nextQueuedTranslation: ""
    property string nextQueuedReference: ""
    property int nextQueuedSurahNumber: 0
    property int nextQueuedAyahNumber: 0

    // --- Audio State ---
    property bool isPlayerA_the_active_verse_player: true
    property bool isAdhanPlaying: false
    property int audioRetryCount: 0
    property int maxAudioRetries: 2
    property var playerToRetry: null

    property bool isAnyAudioPlaying: (playerA.playbackState === MediaPlayer.PlayingState || playerB.playbackState === MediaPlayer.PlayingState)

    function togglePlayback() {
        var activePlayer = root.isPlayerA_the_active_verse_player ? playerA : playerB
        if (activePlayer.playbackState === MediaPlayer.PlayingState) activePlayer.pause()
            else activePlayer.play()
    }

    property bool isPlayingBasmalahGap: false
    property bool nextTrackIsBasmalah: false
    property string storedVerseUrlForAfterBasmalah: ""

    // --- Config ---
    property bool isSmall: width < (Kirigami.Units.gridUnit * 10) || height < (Kirigami.Units.gridUnit * 10)
    property int languageIndex: Plasmoid.configuration.languageIndex !== undefined ? Plasmoid.configuration.languageIndex : 0
    property bool useCoordinates: Plasmoid.configuration.useCoordinates || false
    property string latitude: Plasmoid.configuration.latitude || ""
    property string longitude: Plasmoid.configuration.longitude || ""

    property real quranVolume: 0.7
    property int adhanPlaybackMode: Plasmoid.configuration.adhanPlaybackMode || 0
    property real adhanVolume: Plasmoid.configuration.adhanVolume || 0.7
    property bool playPreAdhanSound: Plasmoid.configuration.playPreAdhanSound !== undefined ? Plasmoid.configuration.playPreAdhanSound : true

    property bool playAdhanForFajr: Plasmoid.configuration.playAdhanForFajr !== undefined ? Plasmoid.configuration.playAdhanForFajr : true
    property bool playAdhanForDhuhr: Plasmoid.configuration.playAdhanForDhuhr !== undefined ? Plasmoid.configuration.playAdhanForDhuhr : true
    property bool playAdhanForAsr: Plasmoid.configuration.playAdhanForAsr !== undefined ? Plasmoid.configuration.playAdhanForAsr : true
    property bool playAdhanForMaghrib: Plasmoid.configuration.playAdhanForMaghrib !== undefined ? Plasmoid.configuration.playAdhanForMaghrib : true
    property bool playAdhanForIsha: Plasmoid.configuration.playAdhanForIsha !== undefined ? Plasmoid.configuration.playAdhanForIsha : true

    property string defaultAdhanPath: {
        let widgetRootUrl = Qt.resolvedUrl("./").toString()
        return widgetRootUrl + "contents/audio/Adhan.mp3"
    }

    property string adhanAudioPath: {
        let customPath = Plasmoid.configuration.adhanAudioPath || ""
        return (customPath === "") ? defaultAdhanPath : customPath
    }

    property var quranReciterIdentifiers: Logic.quranReciterIdentifiers
    property var quranReciterNames: Logic.quranReciterNames
    property var quranReciterNames_ar: Logic.quranReciterNames_ar

    property int quranReciterIndex: Plasmoid.configuration.quranReciterIndex || 0
    property string activeReciterIdentifier: quranReciterIdentifiers[quranReciterIndex]

    property string activeReciterName: {
        if (root.languageIndex === 1) return quranReciterNames_ar[quranReciterIndex]
            return quranReciterNames[quranReciterIndex]
    }

    Component { id: notificationComponent; Notification { componentName: "plasma_workspace"; eventId: "notification"; autoDelete: true } }

    Settings {
        id: cacheSettings
        category: "PrayerCache"
        property string cacheData: "{}"
        property real lastCacheUpdate: 0
        property string verseCacheData: "{}"
        property string verseCacheDate: ""
    }

    property var cachedData: {
        try { return JSON.parse(cacheSettings.cacheData || "{}") }
        catch (e) { return {} }
    }

    Timer {
        id: startupTimer
        interval: 0; repeat: false
        onTriggered: {
            root.fetchTimes();
            root.fetchDailyVerse();
        }
    }

    Timer {
        id: configDebounceTimer
        interval: 500; repeat: false
        onTriggered: {
            root.fetchTimes();
        }
    }

    Timer {
        interval: 30000; running: true; repeat: true;
        onTriggered: {
            if (root.times && Object.keys(root.times).length > 0 && root.displayPrayerTimes.apiGregorianDate && getFormattedDate(new Date()) === root.displayPrayerTimes.apiGregorianDate) {
                if (Object.keys(root.displayPrayerTimes).length > 0) {
                    root.highlightActivePrayer(root.displayPrayerTimes);
                    root.checkPreNotifications(root.displayPrayerTimes);
                    root.checkPostNotifications(root.displayPrayerTimes);
                } else if (Object.keys(root.times).length > 0) processRawTimesAndApplyOffsets();
            } else {
                root.fetchTimes();
                root.fetchDailyVerse();
            }
        }
    }

    Timer {
        interval: 1000; repeat: true
        running: root.nextPrayerDateTime !== null && root.nextPrayerDateTime > new Date()
        onTriggered: {
            if (root.nextPrayerDateTime) {
                let now = new Date();
                let diffMs = root.nextPrayerDateTime.getTime() - now.getTime();
                if (diffMs < 0) {
                    root.timeUntilNextPrayer = i18n("Prayer time!");
                    root.fetchTimes();
                    return;
                }
                let totalMinutes = Math.floor(diffMs / (1000 * 60));
                let hours = Math.floor(totalMinutes / 60);
                let minutes = totalMinutes % 60;
                root.timeUntilNextPrayer = root.toNativeDigits(String(hours).padStart(2, '0') + ":" + String(minutes).padStart(2, '0'));
            }
        }
    }

    Timer {
        id: adhanStopTimer
        interval: 40000; repeat: false
        onTriggered: {
            console.log("Adhan stopped after timeout")
            restoreAfterAdhan()
        }
    }

    Timer {
        id: retryTimer
        interval: 10
        repeat: false
        onTriggered: {
            if (root.playerToRetry) {
                console.log("Retry: Reloading same player...");
                var currentUrl = root.playerToRetry.source;
                var resumePos = Math.max(0, root.retryResumePosition);

                root.playerToRetry.source = "";
                root.playerToRetry.source = currentUrl;
                root.isRetrySeekPending = true;

                root.playerToRetry.position = resumePos;
                root.playerToRetry.play();
            }
        }
    }

    function resetRetryCounter() {
        if (root.audioRetryCount > 0) {
            root.audioRetryCount = 0;
            console.log("Connection stabilized.");
        }
    }

    function onVerseFinished(nextPlayer) {
        if (root.continuousPlayActive) {
            var isSwitchingToBasmalah = false;
            if (root.nextTrackIsBasmalah) {
                root.isPlayingBasmalahGap = true;
                root.nextTrackIsBasmalah = false;
                isSwitchingToBasmalah = true;
            } else if (root.isPlayingBasmalahGap) {
                root.isPlayingBasmalahGap = false;
                root.dailyVerseGlobalAyahNumber++;
            } else {
                root.dailyVerseGlobalAyahNumber++;
            }

            if (!isSwitchingToBasmalah && root.nextQueuedArabic !== "") {
                root.dailyVerseArabic = root.nextQueuedArabic
                root.dailyVerseTranslation = root.nextQueuedTranslation
                root.dailyVerseReference = root.nextQueuedReference
                root.currentSurahNumber = root.nextQueuedSurahNumber
                root.currentAyahNumber = root.nextQueuedAyahNumber
                root.nextQueuedArabic = ""
            }
            root.isPlayerA_the_active_verse_player = (nextPlayer === playerA);
            nextPlayer.play();
        }
    }

    // =========================================================================
    // AUDIO PLAYERS
    // =========================================================================
    MediaDevices {
        id: mediaDevices
    }

    Connections {
        target: mediaDevices
        function onDefaultAudioOutputChanged() {
            console.log("System Default Changed. Updating outputs...")

            var wasPlayingA = (playerA.playbackState === MediaPlayer.PlayingState)


            audioOutputA.device = mediaDevices.defaultAudioOutput

            if (wasPlayingA) playerA.play()

                var wasPlayingB = (playerB.playbackState === MediaPlayer.PlayingState)


                audioOutputB.device = mediaDevices.defaultAudioOutput

                if (wasPlayingB) playerB.play()
        }
    }



    MediaPlayer {
        id: playerA
        audioOutput: audioOutputA
        objectName: "playerA"

        onPositionChanged: {
            if (playerA.playbackState === MediaPlayer.PlayingState && playerA.position > 100) {
                if (!root.isRetrySeekPending) root.lastKnownPosA = playerA.position
            }
        }

        onPlaybackStateChanged: function(state) {
            if (state === MediaPlayer.PlayingState) {
                if (root.isRetrySeekPending && root.playerToRetry === playerA) {
                    var resumePos = Math.max(0, root.retryResumePosition);
                    if (Math.abs(playerA.position - resumePos) > 2000) {
                        console.log("Correction Jump (A) to " + resumePos);
                        playerA.position = resumePos;
                    }
                    root.isRetrySeekPending = false;
                }

                if (!root.isRetrySeekPending && position > 2000) root.resetRetryCounter();

                if (root.continuousPlayActive && !root.isRetrySeekPending) {
                    if (root.isPlayingBasmalahGap) playerB.source = root.storedVerseUrlForAfterBasmalah;
                    else prefetchNextVerse(playerB, root.dailyVerseGlobalAyahNumber + 1);
                }
            }
            else if (state === MediaPlayer.StoppedState && playerA.error === MediaPlayer.NoError) {
                root.lastKnownPosA = 0
                onVerseFinished(playerB)
            }
            else if (state === MediaPlayer.StoppedState && root.audioRetryCount === 0) {
                if (root.isAdhanPlaying) {
                    restoreAfterAdhan()
                }
            }
        }

        onErrorOccurred: function(error, errorString) {
            console.log("PlayerA Error:", errorString);
            if (root.audioRetryCount < root.maxAudioRetries) {
                var resumePos = Math.max(0, root.lastKnownPosA - 1000);
                root.retryResumePosition = resumePos;
                root.audioRetryCount++;
                root.playerToRetry = playerA;
                playerA.stop();
                retryTimer.start();
                return;
            }
            handleAudioFailure();
        }
    }
    AudioOutput {
        id: audioOutputA
        volume: root.isAdhanPlaying ? root.adhanVolume : root.quranVolume
        device: mediaDevices.defaultAudioOutput
    }
    MediaPlayer {
        id: playerB
        audioOutput: audioOutputB
        objectName: "playerB"

        onPositionChanged: {
            if (playerB.playbackState === MediaPlayer.PlayingState && playerB.position > 100) {
                if (!root.isRetrySeekPending) root.lastKnownPosB = playerB.position
            }
        }

        onPlaybackStateChanged: function(state) {
            if (state === MediaPlayer.PlayingState) {
                if (root.isRetrySeekPending && root.playerToRetry === playerB) {
                    var resumePos = Math.max(0, root.retryResumePosition);
                    if (Math.abs(playerB.position - resumePos) > 2000) {
                        console.log("Correction Jump (B) to " + resumePos);
                        playerB.position = resumePos;
                    }
                    root.isRetrySeekPending = false;
                }

                if (!root.isRetrySeekPending && position > 2000) root.resetRetryCounter()

                    if (root.continuousPlayActive && !root.isRetrySeekPending) {
                        if (root.isPlayingBasmalahGap) playerA.source = root.storedVerseUrlForAfterBasmalah;
                        else prefetchNextVerse(playerA, root.dailyVerseGlobalAyahNumber + 1);
                    }
            }
            else if (state === MediaPlayer.StoppedState && playerB.error === MediaPlayer.NoError) {
                root.lastKnownPosB = 0
                onVerseFinished(playerA)
            }
        }

        onErrorOccurred: function(error, errorString) {
            console.log("PlayerB Error:", errorString);
            if (root.audioRetryCount < root.maxAudioRetries) {
                var resumePos = Math.max(0, root.lastKnownPosB - 1000);
                root.retryResumePosition = resumePos;
                root.audioRetryCount++;
                root.playerToRetry = playerB;
                playerB.stop();
                retryTimer.start();
                return;
            }
            handleAudioFailure();
        }
    }
    AudioOutput {
        id: audioOutputB
        volume: root.quranVolume
        device: mediaDevices.defaultAudioOutput
    }
    function handleAudioFailure() {
        console.log("Skipping verse...");
        var notification = notificationComponent.createObject(root);
        notification.title = i18n("Network Error");
        notification.text = i18n("Skipping verse after %1 attempts.", root.maxAudioRetries);
        notification.sendEvent();
        root.resetRetryCounter();
        if (root.isAdhanPlaying) root.isAdhanPlaying = false;

        if (root.playerToRetry) root.playerToRetry.stop();

        if (root.continuousPlayActive) {
            root.isRetrySeekPending = false;
            if (root.isPlayerA_the_active_verse_player) onVerseFinished(playerB);
            else onVerseFinished(playerA);
        }
    }

    // =========================================================================
    // VISUAL REPRESENTATIONS
    // =========================================================================

    preferredRepresentation: isSmall ? compactRepresentation : fullRepresentation

    compactRepresentation: CompactRepresentation {
        nextPrayerName: root.nextPrayerNameForDisplay
        nextPrayerTime: root.nextPrayerTimeForDisplay
        countdownText: root.timeUntilNextPrayer
        isPrePrayerAlertActive: false
        plasmoidItem: root
        languageIndex: root.languageIndex
        hourFormat: Plasmoid.configuration.hourFormat
        compactStyle: Plasmoid.configuration.compactStyle || 0
    }

    fullRepresentation: Item {
        id: fullView

        Shortcut { sequence: StandardKey.MediaTogglePlayPause; onActivated: root.togglePlayback() }
        Shortcut { sequence: StandardKey.MediaPlay; onActivated: { var p = root.isPlayerA_the_active_verse_player ? playerA : playerB; p.play() } }
        Shortcut { sequence: StandardKey.MediaPause; onActivated: { var p = root.isPlayerA_the_active_verse_player ? playerA : playerB; p.pause() } }
        Shortcut { sequence: StandardKey.MediaStop; onActivated: { root.continuousPlayActive = false; playerA.stop(); playerB.stop(); root.isAdhanPlaying = false } }

        onVisibleChanged: {
            if (visible && Object.keys(root.displayPrayerTimes).length > 0) root.highlightActivePrayer(root.displayPrayerTimes);
        }
        implicitWidth: Kirigami.Units.gridUnit * 23.3
        implicitHeight: mainColumn.implicitHeight

        Column {
            id: mainColumn
            width: parent.width
            padding: Kirigami.Units.largeSpacing
            spacing: Kirigami.Units.smallSpacing
            anchors.centerIn: parent

            Label {
                text: "{صّلِ عَلۓِ مُحَمد ﷺ}"
                font.pointSize: Kirigami.Theme.defaultFont.pointSize + 3
                font.weight: Font.Bold
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Label {
                text: root.hijriDateDisplay
                width: parent.width - (Kirigami.Units.largeSpacing * 2)
                fontSizeMode: (Plasmoid.configuration.useDynamicFont === undefined || Plasmoid.configuration.useDynamicFont) ? Text.Fit : Text.FixedSize
                minimumPixelSize: 10
                font.pixelSize: (Plasmoid.configuration.useDynamicFont === undefined || Plasmoid.configuration.useDynamicFont) ? Math.min(parent.width * 0.04, 32) : Kirigami.Theme.smallFont.pixelSize

                font.weight: Font.Bold
                opacity: 0.9
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
            }

            Label {
                text: root.specialIslamicDateMessage
                visible: root.specialIslamicDateMessage !== ""
                width: parent.width - (Kirigami.Units.largeSpacing * 2)
                fontSizeMode: (Plasmoid.configuration.useDynamicFont === undefined || Plasmoid.configuration.useDynamicFont) ? Text.Fit : Text.FixedSize
                minimumPixelSize: 10
                font.pixelSize: (Plasmoid.configuration.useDynamicFont === undefined || Plasmoid.configuration.useDynamicFont) ? Math.min(parent.width * 0.035, 27) : Kirigami.Theme.smallFont.pixelSize
                font.weight: Font.Bold
                opacity: 0.85
                anchors.horizontalCenter: parent.horizontalCenter
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }

            Label {
                text: {
                    if (!root.timeUntilNextPrayer) return "";
                    if (root.languageIndex === 1) return i18n("الوقت المتبقي على الصلاة : %1", root.timeUntilNextPrayer);
                    else return i18n("Time until next prayer: %1", root.timeUntilNextPrayer);
                }
                visible: root.timeUntilNextPrayer !== "" && root.timeUntilNextPrayer !== i18n("Prayer time!")


                width: parent.width - (Kirigami.Units.largeSpacing * 2)
                fontSizeMode: (Plasmoid.configuration.useDynamicFont === undefined || Plasmoid.configuration.useDynamicFont) ? Text.Fit : Text.FixedSize
                minimumPixelSize: 10
                font.pixelSize: (Plasmoid.configuration.useDynamicFont === undefined || Plasmoid.configuration.useDynamicFont) ? Math.min(parent.width * 0.048, 34) : Kirigami.Theme.smallFont.pixelSize

                font.weight: Font.Bold
                opacity: 0.95
                color: Kirigami.Theme.textColor
                anchors.horizontalCenter: parent.horizontalCenter
                horizontalAlignment: Text.AlignHCenter
            }
            PlasmaComponents.MenuSeparator {
                width: parent.width - (parent.padding * 2)
                topPadding: Kirigami.Units.moderateSpacing
                bottomPadding: Kirigami.Units.smallSpacing
            }

            Repeater {
                model: ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"]
                delegate: Rectangle {
                    width: parent.width - (Kirigami.Units.largeSpacing * 2)
                    height: Kirigami.Units.gridUnit * 2.3
                    radius: 8
                    color: root.activePrayer === modelData ? Kirigami.Theme.highlightColor : "transparent"
                    RowLayout {
                        anchors.fill: parent
                        LayoutMirroring.enabled: root.languageIndex === 1
                        LayoutMirroring.childrenInherit: true
                        anchors.leftMargin: Kirigami.Units.largeSpacing
                        anchors.rightMargin: Kirigami.Units.largeSpacing
                        Label {
                            text: getPrayerName(root.languageIndex, modelData) + " " + (Logic.prayerEmojis[modelData] || "")
                            color: parent.parent.color === Kirigami.Theme.highlightColor ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                            font.weight: Font.Bold
                            font.pointSize: Kirigami.Theme.defaultFont.pointSize + 3
                        }
                        Item { Layout.fillWidth: true }
                        Label {
                            text: root.to12HourTime(root.displayPrayerTimes[modelData], Plasmoid.configuration.hourFormat)
                            color: parent.parent.color === Kirigami.Theme.highlightColor ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                            font.pointSize: Kirigami.Theme.defaultFont.pointSize + 2
                        }
                    }
                }
            }

            PlasmaComponents.MenuSeparator {
                width: parent.width - (parent.padding * 2)
                topPadding: Kirigami.Units.smallSpacing
                bottomPadding: Kirigami.Units.smallSpacing
            }

            PlasmaComponents.Button {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - (parent.padding * 2)
                text: root.languageIndex === 1 ? "القرآن الكريم" : "Quran"
                visible: Plasmoid.configuration.enableQuran
                onClicked: {
                    var quranComp = Qt.createComponent("QuranDialog.qml");
                    if (quranComp.status === Component.Ready) {
                        var dialog = quranComp.createObject(fullView, {
                            widgetRoot: root,
                            playerA: playerA,
                            playerB: playerB,
                            adhanStopTimer: adhanStopTimer
                        });
                        if (dialog) dialog.open();
                        else console.error("Failed to create Quran dialog");
                    } else if (quranComp.status === Component.Error) {
                        console.error("Error loading Quran Dialog component:", quranComp.errorString());
                    }
                }
            }
        }
    }

    // =========================================================================
    // POPUP DIALOG
    // =========================================================================

    // Moved quoteDialogComponent into QuranDialog.qml

    // =========================================================================
    // LOGIC & HELPER FUNCTIONS
    // =========================================================================

    function playSpecificVerse(surahNum, ayahNum) {
        if (root.isFetchingVerse) return;
        root.isFetchingVerse = true;

        console.log("Fetching Surah " + surahNum + " Verse " + ayahNum)
        let targetReciter = root.activeReciterIdentifier
        
        let finalUrl = getPredictableAudioUrl(targetReciter, surahNum, ayahNum)
        if (ayahNum === 1 && surahNum !== 1 && surahNum !== 9) {
            let basmalahUrl = getPredictableAudioUrl(targetReciter, 1, 1);
            root.storedVerseUrlForAfterBasmalah = finalUrl;
            root.isPlayingBasmalahGap = true;
            playerA.source = basmalahUrl;
        } else {
            root.isPlayingBasmalahGap = false;
            playerA.source = finalUrl;
        }

        root.continuousPlayActive = true;
        root.isPlayerA_the_active_verse_player = true;
        playerA.play();

        let URL = `https://api.alquran.cloud/v1/ayah/${surahNum}:${ayahNum}/editions/quran-uthmani,en.sahih`

        let xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                root.isFetchingVerse = false;
                if (xhr.status === 200) {
                    try {
                        let data = JSON.parse(xhr.responseText).data
                        let arabicData = data.find(ed => ed.edition.identifier === "quran-uthmani")
                        let translationData = data.find(ed => ed.edition.identifier === "en.sahih")

                        if (arabicData) {
                            root.dailyVerseArabic = arabicData.text
                            root.dailyVerseTranslation = translationData ? translationData.text : ""
                            root.dailyVerseReference = "Surah " + arabicData.surah.englishName + " (" + arabicData.surah.number + ":" + arabicData.numberInSurah + ")"
                            root.dailyVerseGlobalAyahNumber = arabicData.number

                            root.currentSurahNumber = arabicData.surah.number
                            root.currentAyahNumber = arabicData.numberInSurah
                        }
                    } catch (e) { console.log("Error parsing specific verse text:", e.toString()) }
                }
            }
        }
        xhr.open("GET", URL, true); xhr.send()
    }

    function formatTime(ms) {
        if (ms <= 0) return root.toNativeDigits("00:00")
            let totalSeconds = Math.floor(ms / 1000)
            let minutes = Math.floor(totalSeconds / 60)
            let seconds = totalSeconds % 60
            return root.toNativeDigits(String(minutes).padStart(2, '0') + ":" + String(seconds).padStart(2, '0'))
    }

    function initCache() { console.log("Prayer Times Widget: Cache initialized.") }

    function toNativeDigits(numStr) {
        if (root.languageIndex !== 1 || !Plasmoid.configuration.useArabicNumbers) return numStr;
        let arabicDigits = ["٠", "١", "٢", "٣", "٤", "٥", "٦", "٧", "٨", "٩"];
        return String(numStr).replace(/[0-9]/g, function(w) { return arabicDigits[+w]; });
    }

    function to12HourTime(timeString, isActive) {
        if (!timeString || timeString === "--:--") return "--:--"
            if (isActive) {
                let parts = timeString.split(':')
                let hours = parseInt(parts[0], 10)
                let minutes = parseInt(parts[1], 10)
                let period = hours >= 12 ? (root.languageIndex === 1 ? "م" : "PM") : (root.languageIndex === 1 ? "ص" : "AM")
                hours = hours % 12 || 12
                return root.toNativeDigits(`${hours}:${String(minutes).padStart(2, '0')}`) + ` ${period}`
            }
            return root.toNativeDigits(timeString)
    }

    function parseTime(timeString) {
        if (!timeString || timeString === "--:--") return new Date(0)
            let parts = timeString.split(':')
            let dateObj = new Date()
            dateObj.setHours(parseInt(parts[0], 10))
            dateObj.setMinutes(parseInt(parts[1], 10))
            dateObj.setSeconds(0)
            dateObj.setMilliseconds(0)
            return dateObj
    }

    function getPrayerName(langIndex, prayerKey) {
        if (langIndex === 0) return prayerKey
            const arabicPrayers = { "Fajr": "الفجر", "Sunrise": "الشروق", "Dhuhr": "الظهر", "Asr": "العصر", "Maghrib": "المغرب", "Isha": "العشاء" }
            return arabicPrayers[prayerKey] || prayerKey
    }

    function playAdhanAudio(prayerName) {
        let audioPath = root.adhanAudioPath
        if (!audioPath || root.adhanPlaybackMode === 0) return

            let shouldPlay = false
            switch(prayerName) {
                case "Fajr": shouldPlay = root.playAdhanForFajr; break
                case "Dhuhr": shouldPlay = root.playAdhanForDhuhr; break
                case "Asr": shouldPlay = root.playAdhanForAsr; break
                case "Maghrib": shouldPlay = root.playAdhanForMaghrib; break
                case "Isha": shouldPlay = root.playAdhanForIsha; break
                case "Test": shouldPlay = true; break
            }

            if (!shouldPlay) return

                var activeP = root.isPlayerA_the_active_verse_player ? playerA : playerB
                root.storedWasPlaying = (activeP.playbackState === MediaPlayer.PlayingState)


                root.storedQuranUrl = activeP.source.toString()
                root.storedQuranPos = activeP.position
                root.storedWasPlayerA = root.isPlayerA_the_active_verse_player
                root.storedContinuousActive = root.continuousPlayActive

                root.continuousPlayActive = false
                playerA.stop()
                playerB.stop()

                root.isRetrySeekPending = false
                adhanStopTimer.stop()

                let sourceUrl = audioPath
                if (!sourceUrl.startsWith("file://") && !sourceUrl.startsWith("qrc:/")) {
                    sourceUrl = "file://" + sourceUrl
                }

                console.log("Playing Adhan:", sourceUrl)
                playerA.source = sourceUrl
                root.isAdhanPlaying = true
                playerA.play()

                if (root.adhanPlaybackMode === 2) {
                    adhanStopTimer.interval = 40000
                    adhanStopTimer.start()
                } else if (root.adhanPlaybackMode === 3) {
                    adhanStopTimer.interval = 17000
                    adhanStopTimer.start()
                }
    }

    function restoreAfterAdhan() {
        adhanStopTimer.stop()

        if (root.isAdhanPlaying) {
            console.log("Adhan finished. Auto-resuming Quran...")
            playerA.stop()
            root.isAdhanPlaying = false

            root.isPlayerA_the_active_verse_player = root.storedWasPlayerA
            root.continuousPlayActive = root.storedContinuousActive

            var quranPlayer = root.storedWasPlayerA ? playerA : playerB

            if (root.storedWasPlayerA) {
                quranPlayer.source = ""
                quranPlayer.source = root.storedQuranUrl
            }

            quranPlayer.position = root.storedQuranPos
            if (root.storedWasPlaying) {
                console.log("Resuming Quran...")
                quranPlayer.play()
            } else {
                console.log("Quran was paused before Adhan. Staying paused.")
            }
        }
    }

    function checkPreNotifications(currentTimingsToUse) {
        if (!Plasmoid.configuration.preNotificationMinutes || Plasmoid.configuration.preNotificationMinutes <= 0) return;
        if (!currentTimingsToUse || !currentTimingsToUse.Fajr) return;

        const now = new Date();
        const notificationWindow = Plasmoid.configuration.preNotificationMinutes;
        const prayerKeys = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];

        for (const prayerName of prayerKeys) {
            const prayerTimeStr = currentTimingsToUse[prayerName];
            if (!prayerTimeStr || prayerTimeStr === "--:--") continue;

            let prayerTime = parseTime(prayerTimeStr);
            if (prayerName === "Fajr" && prayerTime < now) prayerTime.setDate(prayerTime.getDate() + 1);

            let diffMs = prayerTime.getTime() - now.getTime();
            const minutesUntil = Math.floor(diffMs / (1000 * 60));

            if (minutesUntil > 0 && minutesUntil <= notificationWindow) {
                const todayKey = getYYYYMMDD(now);
                const notificationKey = prayerName + "-" + todayKey;

                if (!root.preNotifiedPrayers[notificationKey]) {
                    var notification = notificationComponent.createObject(root);

                    // Bilingual Pre-Adhan Logic
                    if (root.languageIndex === 1) {
                        notification.title = i18n("باقي %1 دقائق على صلاة %2", minutesUntil, getPrayerName(root.languageIndex, prayerName));
                        notification.text = i18n("تذكير بقرب موعد الأذان");
                    } else {
                        notification.title = i18n("%1 in %2 minutes", getPrayerName(root.languageIndex, prayerName), minutesUntil);
                        notification.text = i18n("Prayer time reminder");
                    }

                    notification.eventId = "notification";
                    if (root.playPreAdhanSound) {
                        notification.hints = { "sound-name": "message-new-instant" };
                    }

                    notification.sendEvent();
                    root.preNotifiedPrayers[notificationKey] = true;
                }
            }
        }
    }

    function checkPostNotifications(currentTimingsToUse) {
        if (!Plasmoid.configuration.postNotificationMinutes || Plasmoid.configuration.postNotificationMinutes <= 0) return;
        if (!currentTimingsToUse || !currentTimingsToUse.Fajr) return;

        const now = new Date();
        const notificationWindow = Plasmoid.configuration.postNotificationMinutes;
        const prayerKeys = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];

        for (const prayerName of prayerKeys) {
            const prayerTimeStr = currentTimingsToUse[prayerName];
            if (!prayerTimeStr || prayerTimeStr === "--:--") continue;

            let prayerTime = parseTime(prayerTimeStr);
            if (now < prayerTime) continue;

            let diffMs = now.getTime() - prayerTime.getTime();
            const minutesSince = Math.floor(diffMs / (1000 * 60));

            if (minutesSince === notificationWindow) {
                const todayKey = getYYYYMMDD(now);
                const notificationKey = prayerName + "-post-" + todayKey;

                if (!root.postNotifiedPrayers[notificationKey]) {
                    var notification = notificationComponent.createObject(root);

                    // Adjusted to focus on Iqamah and fixed pluralization
                    if (root.languageIndex === 1) {
                        notification.title = i18n("مرت %1 دقائق على صلاة %2", notificationWindow, getPrayerName(root.languageIndex, prayerName));
                        notification.text = i18n("تذكير: موعد الإقامة");
                    } else {
                        notification.title = i18n("%1 was %2 minutes ago", getPrayerName(root.languageIndex, prayerName), notificationWindow);
                        notification.text = i18n("Reminder: Time for Iqamah");
                    }

                    notification.eventId = "notification";
                    if (Plasmoid.configuration.playPostAdhanSound) {
                        notification.hints = { "sound-name": "message-new-instant" };
                    }

                    notification.sendEvent();
                    root.postNotifiedPrayers[notificationKey] = true;
                }
            }
        }
    }

    function highlightActivePrayer(currentTimingsToUse) {
        if (!currentTimingsToUse || !currentTimingsToUse.Fajr) {
            root.activePrayer = ""; return
        }
        var newActivePrayer = ""
        let now = new Date()
        const prayerCheckOrder = ["Isha", "Maghrib", "Asr", "Dhuhr", "Sunrise", "Fajr"]
        let foundActive = false

        for (const prayer of prayerCheckOrder) {
            if (currentTimingsToUse[prayer] && currentTimingsToUse[prayer] !== "--:--" && now >= parseTime(currentTimingsToUse[prayer])) {
                newActivePrayer = prayer; foundActive = true; break
            }
        }

        if (!foundActive && currentTimingsToUse["Fajr"] !== "--:--") newActivePrayer = "Isha"
            else if (!foundActive) newActivePrayer = ""

                if (root.activePrayer !== newActivePrayer) {
                    root.lastActivePrayer = root.activePrayer
                    root.activePrayer = newActivePrayer

                    if (root.lastActivePrayer !== "" && root.activePrayer !== "") {
                        if (root.blockAdhanOnFetch) {
                            console.log("Config changed, suppressing Adhan for new location")
                        } else {
                            if (Plasmoid.configuration.notifications) {
                                var notification = notificationComponent.createObject(root)
                                notification.title = i18n("It's %1 time", getPrayerName(root.languageIndex, root.activePrayer))
                                notification.sendEvent()
                            }
                            if (root.activePrayer !== "Sunrise") playAdhanAudio(root.activePrayer)
                        }
                    }
                }
        if (root.blockAdhanOnFetch) root.blockAdhanOnFetch = false
    }

    function resetPreNotifications() { root.preNotifiedPrayers = {}
        root.postNotifiedPrayers = {};
    }
    function getYYYYMMDD(dateObj) {
        let year = dateObj.getFullYear()
        let month = String(dateObj.getMonth() + 1).padStart(2, '0')
        let day = String(dateObj.getDate()).padStart(2, '0')
        return `${year}-${month}-${day}`
    }
    function getFormattedDate(givenDate) {
        const day = String(givenDate.getDate()).padStart(2, "0")
        const month = String(givenDate.getMonth() + 1).padStart(2, "0")
        const year = givenDate.getFullYear()
        return `${day}-${month}-${year}`
    }

    function applyOffsetToTime(timeStrHHMM, offsetMins) {
        if (!timeStrHHMM || timeStrHHMM === "--:--" || typeof offsetMins !== 'number' || offsetMins === 0) return timeStrHHMM
            let parts = timeStrHHMM.split(':')
            let hours = parseInt(parts[0], 10)
            let minutes = parseInt(parts[1], 10)
            if (isNaN(hours) || isNaN(minutes)) return timeStrHHMM
                let totalMinutes = (hours * 60) + minutes + offsetMins
                totalMinutes = ((totalMinutes % 1440) + 1440) % 1440
                let finalHours = Math.floor(totalMinutes / 60)
                let finalMinutes = totalMinutes % 60
                return String(finalHours).padStart(2, '0') + ":" + String(finalMinutes).padStart(2, '0')
    }

    function calculateNextPrayer() {
        const prayerData = root.displayPrayerTimes
        if (!prayerData || !prayerData.Fajr || prayerData.Fajr === "--:--") {
            root.nextPrayerDateTime = null; root.timeUntilNextPrayer = "";
            root.nextPrayerNameForDisplay = i18n("N/A"); root.nextPrayerTimeForDisplay = "";
            return
        }
        const prayerKeys = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"]
        const now = new Date()
        const currentTimeStr = ("0" + now.getHours()).slice(-2) + ":" + ("0" + now.getMinutes()).slice(-2)

        let nextPrayerKey = "", nextPrayerRawTime = ""
        for (const key of prayerKeys) {
            if (prayerData[key] && prayerData[key] !== "--:--" && prayerData[key] > currentTimeStr) {
                nextPrayerKey = key; nextPrayerRawTime = prayerData[key]; break
            }
        }
        if (nextPrayerKey === "" && prayerData["Fajr"] && prayerData["Fajr"] !== "--:--") {
            nextPrayerKey = "Fajr"; nextPrayerRawTime = prayerData["Fajr"]
        } else if (nextPrayerKey === "") {
            root.nextPrayerDateTime = null; return
        }

        root.nextPrayerNameForDisplay = getPrayerName(root.languageIndex, nextPrayerKey)
        root.nextPrayerTimeForDisplay = to12HourTime(nextPrayerRawTime, Plasmoid.configuration.hourFormat)

        let nextPrayerDateObj = parseTime(nextPrayerRawTime)
        if (nextPrayerDateObj) {
            if (nextPrayerKey === "Fajr" && now > nextPrayerDateObj) nextPrayerDateObj.setDate(nextPrayerDateObj.getDate() + 1)
                root.nextPrayerDateTime = nextPrayerDateObj
        } else {
            root.nextPrayerDateTime = null
        }
    }

    function processRawTimesAndApplyOffsets() {
        const defaultTimesStructure = { Fajr: "--:--", Sunrise: "--:--", Dhuhr: "--:--", Asr: "--:--", Maghrib: "--:--", Isha: "--:--", apiGregorianDate: getFormattedDate(new Date()) }
        if (!root.times || Object.keys(root.times).length === 0 || !root.times.Fajr) {
            root.displayPrayerTimes = {defaultTimesStructure, apiGregorianDate: (root.times && root.times.apiGregorianDate) || defaultTimesStructure.apiGregorianDate }
        } else {
            let newDisplayTimes = {}
            const prayerKeys = ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"]
            for (const key of prayerKeys) {
                let offset = Plasmoid.configuration[key.toLowerCase() + "OffsetMinutes"] || 0
                newDisplayTimes[key] = root.times[key] ? applyOffsetToTime(root.times[key], offset) : "--:--"
            }
            if (root.times.apiGregorianDate) newDisplayTimes.apiGregorianDate = root.times.apiGregorianDate
                root.displayPrayerTimes = newDisplayTimes
        }
        root.highlightActivePrayer(root.displayPrayerTimes)
        calculateNextPrayer()
    }

    function _setProcessedHijriData(hijriDataObject) {
        if (!hijriDataObject || !hijriDataObject.month) {
            root.hijriDateDisplay = i18n("Date unavailable")
            root.currentHijriDay = 0; root.currentHijriMonth = 0; root.currentHijriYear = 0
        } else {
            let rawDay = parseInt(hijriDataObject.day, 10)
            let rawMonth = parseInt(hijriDataObject.month.number, 10)
            let rawYear = parseInt(hijriDataObject.year, 10)

            let offset = Plasmoid.configuration.hijriOffset || 0
            let adjustedDay = rawDay + offset


            if (adjustedDay > 30) {
                adjustedDay -= 30
                rawMonth += 1
                if (rawMonth > 12) { rawMonth = 1; rawYear += 1 }
            } else if (adjustedDay < 1) {
                adjustedDay += 30
                rawMonth -= 1
                if (rawMonth < 1) { rawMonth = 12; rawYear -= 1 }
            }

            root.currentHijriDay = adjustedDay
            root.currentHijriMonth = rawMonth
            root.currentHijriYear = rawYear


            let arMonths = ["محرم", "صفر", "ربيع الأول", "ربيع الآخر", "جمادى الأولى", "جمادى الآخرة", "رجب", "شعبان", "رمضان", "شوال", "ذو القعدة", "ذو الحجة"]
            let enMonths = ["Muharram", "Safar", "Rabi Al-Awwal", "Rabi Al-Thani", "Jumada Al-Awwal", "Jumada Al-Thani", "Rajab", "Sha'ban", "Ramadan", "Shawwal", "Dhu Al-Qi'dah", "Dhu Al-Hijjah"]

            let mIndex = rawMonth - 1
            if (mIndex < 0) mIndex = 0
                if (mIndex > 11) mIndex = 11

                    let monthName = (root.languageIndex === 1) ? arMonths[mIndex] : enMonths[mIndex]

                    root.hijriDateDisplay = root.toNativeDigits(root.currentHijriDay) + ` ${monthName} ` + root.toNativeDigits(root.currentHijriYear)
        }
        updateSpecialIslamicDateMessage()
    }

    function updateSpecialIslamicDateMessage() {
        let day = root.currentHijriDay;
        let month = root.currentHijriMonth;
        let message = ""

        if (month === 0 || day === 0) {
            root.specialIslamicDateMessage = "";
            return
        }

        if (month === 9) message = (root.languageIndex === 1) ? "شهر رمضان" : "Month of Ramadan"
            else if (month === 10 && day === 1) message = (root.languageIndex === 1) ? "عيد الفطر" : "Eid al-Fitr"
                else if (month === 12) {
                    if (day >= 1 && day <= 10) {
                        message = (root.languageIndex === 1) ? "العشر الأوائل من ذي الحجة" : "First 10 Days of Dhu al-Hijjah"
                        if (day === 9) message = (root.languageIndex === 1) ? "يوم عرفة" : "Day of Arafah"
                            if (day === 10) message = (root.languageIndex === 1) ? "عيد الأضحى" : "Eid al-Adha"
                    } else if (day >= 11 && day <= 13) message = (root.languageIndex === 1) ? "أيام التشريق" : "Days of Tashreeq"
                }
                else if (month === 1 && day === 1) message = (root.languageIndex === 1) ? "رأس السنة الهجرية" : "Islamic New Year"
                    else if (month === 1 && day === 10) message = (root.languageIndex === 1) ? "يوم عاشوراء" : "Day of Ashura"

                        if (message === "") {
                            if (day === 13 || day === 14 || day === 15) message = (root.languageIndex === 1) ? "الأيام البيض" : "Ayyām al-Bīḍ (The White Days)"
                                else if (day === 12) message = (root.languageIndex === 1) ? "غداً تبدأ الأيام البيض" : "White Days begin tomorrow"
                                    else if (day === 11) message = (root.languageIndex === 1) ? "باقي يومان على الأيام البيض" : "2 days until White Days"


                                        if (message === "" && (month === 1 || month === 7 || month === 11 || month === 12)) {
                                            message = (root.languageIndex === 1) ? "الأشهر الحرم" : "Al-Ashhur al-Ḥurum (The Sacred Months)";
                                        }
                        }

                        root.specialIslamicDateMessage = message
    }

    function fetchTimes() {
        if (Plasmoid.configuration.forceOfflineMode) {
            loadFromCache();
            return;
        }

        let todayForAPI = getFormattedDate(new Date())
        let methodMap = [0, 1, 2, 3, 4, 5, 7, 8, 9, 10, 11, 12, 13, 14, 21, 16, 17, 18, 19, 20, 22, 23];
        let configIndex = (Plasmoid.configuration.method !== undefined) ? Plasmoid.configuration.method : 3;
        let method = (methodMap[configIndex] !== undefined) ? methodMap[configIndex] : 3;
        let school = Plasmoid.configuration.school || 0
        let hijriAdj = Plasmoid.configuration.hijriOffset || 0

        let URL = ""

        if (root.useCoordinates && root.latitude && root.longitude) {
            URL = `https://api.aladhan.com/v1/timings/${todayForAPI}?latitude=${encodeURIComponent(root.latitude)}&longitude=${encodeURIComponent(root.longitude)}&method=${method}&school=${school}&adjustment=${hijriAdj}`
        } else {
            URL = `https://api.aladhan.com/v1/timingsByCity/${todayForAPI}?city=${encodeURIComponent(Plasmoid.configuration.city || "Makkah")}&country=${encodeURIComponent(Plasmoid.configuration.country || "Saudi Arabia")}&method=${method}&school=${school}&adjustment=${hijriAdj}`
        }

        let xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    let responseData = JSON.parse(xhr.responseText).data
                    root.times = responseData.timings
                    root.times.apiGregorianDate = responseData.date.gregorian.date

                    // The API has already applied the offset for us!
                    root.rawHijriDataFromApi = responseData.date.hijri

                    resetPreNotifications()
                    processRawTimesAndApplyOffsets()

                    // Directly set the data (No more complex nested requests)
                    _setProcessedHijriData(root.rawHijriDataFromApi)

                    update30DayCache()
                    Plasmoid.configuration.isOfflineFallback = false
                } else {
                    loadFromCache()
                }
            }
        }
        xhr.open("GET", URL, true)
        xhr.send()
    }
    function saveTodayToCache() {
        if (!root.times || !root.times.Fajr || !root.rawHijriDataFromApi) return
            let todayKey = getYYYYMMDD(new Date())
            let cleanTimings = {}
            const prayerKeysToSave = ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"]
            prayerKeysToSave.forEach(function(pKey) { if (root.times[pKey]) cleanTimings[pKey] = root.times[pKey] })
            if (Object.keys(cleanTimings).length === 0) return
                let updatedCache = cachedData
                updatedCache[todayKey] = { timings: cleanTimings, hijri: root.rawHijriDataFromApi }
                cacheSettings.cacheData = JSON.stringify(updatedCache)
    }

    function update30DayCache() {
        const now = new Date()
        const cacheKey = "last_30day_update"
        const lastUpdate = Number(cachedData[cacheKey] || 0)
        const daysSinceUpdate = (now.getTime() - lastUpdate) / (1000 * 60 * 60 * 24)

        if (daysSinceUpdate >= 30 || Object.keys(cachedData).length <= 1) {
            const year = now.getFullYear()
            let methodMap = [0, 1, 2, 3, 4, 5, 7, 8, 9, 10, 11, 12, 13, 14, 21, 16, 17, 18, 19, 20, 22, 23];
            let configIndex = (Plasmoid.configuration.method !== undefined) ? Plasmoid.configuration.method : 3;
            const method = (methodMap[configIndex] !== undefined) ? methodMap[configIndex] : 3;
            const school = (Plasmoid.configuration.school !== undefined) ? Plasmoid.configuration.school : 0
            let URL = ""
            if (root.useCoordinates && root.latitude && root.longitude) {
                URL = `https://api.aladhan.com/v1/calendar/${year}?latitude=${encodeURIComponent(root.latitude)}&longitude=${encodeURIComponent(root.longitude)}&method=${method}&school=${school}`
            } else {
                if (!Plasmoid.configuration.city || !Plasmoid.configuration.country) { saveTodayToCache(); return }
                URL = `https://api.aladhan.com/v1/calendarByCity/${year}?city=${encodeURIComponent(Plasmoid.configuration.city)}&country=${encodeURIComponent(Plasmoid.configuration.country)}&method=${method}&school=${school}`
            }
            const xhr = new XMLHttpRequest()
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    try {
                        const annualData = JSON.parse(xhr.responseText).data
                        if (annualData) {
                            const updatedCache = Object.assign({}, cachedData)
                            for (let m = 1; m <= 12; m++) {
                                let monthlyData = annualData[m.toString()]
                                if (!monthlyData) continue
                                for (let i = 0; i < monthlyData.length; i++) {
                                    const dayData = monthlyData[i]
                                    if (!dayData || !dayData.date || !dayData.date.gregorian || !dayData.date.hijri || !dayData.timings) continue
                                    const parts = dayData.date.gregorian.date.split('-'); if (parts.length !== 3) continue
                                    const dateKey = `${parts[2]}-${parts[1]}-${parts[0]}`
                                    const cleanTimings = {}
                                    const prayerKeys = ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"]
                                    for (const pKey of prayerKeys) { if (dayData.timings[pKey]) cleanTimings[pKey] = dayData.timings[pKey] }
                                    if (Object.keys(cleanTimings).length > 0) updatedCache[dateKey] = { timings: cleanTimings, hijri: dayData.date.hijri }
                                }
                            }
                            updatedCache[cacheKey] = now.getTime()
                            cacheSettings.cacheData = JSON.stringify(updatedCache)
                            cacheSettings.lastCacheUpdate = now.getTime()
                        }
                    } catch (e) { console.log("Annual cache parse error:", e.toString()) }
                }
            }
            xhr.open("GET", URL, true); xhr.send()
        }
        saveTodayToCache()
    }

    function loadFromCache() {
        const todayKey = getYYYYMMDD(new Date()); let loaded = false
        if (!Plasmoid.configuration.forceOfflineMode && cachedData[todayKey]) {
            try {
                const cachedEntry = cachedData[todayKey]
                root.times = cachedEntry.timings
                root.times.apiGregorianDate = getFormattedDate(new Date())
                const hijriDataFromCache = cachedEntry.hijri
                processRawTimesAndApplyOffsets()
                _setProcessedHijriData(hijriDataFromCache)
                loaded = true
            } catch (err) { console.log("Error loading from cache:", err.toString()) }
        }
        Plasmoid.configuration.isOfflineFallback = !loaded;
        if (!loaded) {
            let latStr = root.latitude !== undefined ? root.latitude.toString() : ""
            let lngStr = root.longitude !== undefined ? root.longitude.toString() : ""
            let lat = parseFloat(latStr); if (isNaN(lat)) lat = 21.4225
            let lng = parseFloat(lngStr); if (isNaN(lng)) lng = 39.8262

            if (true) {
                let timeZoneOffset = -new Date().getTimezoneOffset() / 60
                let method = Plasmoid.configuration.method !== undefined ? Plasmoid.configuration.method : 3
                let school = Plasmoid.configuration.school !== undefined ? Plasmoid.configuration.school : 0
                
                root.times = OfflineCalc.getTimes(new Date(), lat, lng, timeZoneOffset, method, school)
                root.times.apiGregorianDate = getFormattedDate(new Date())
                processRawTimesAndApplyOffsets()
                
                let hAdj = Plasmoid.configuration.hijriOffset || 0
                let hDate = OfflineCalc.getHijriDate(new Date(), hAdj)
                root.currentHijriDay = hDate.day
                root.currentHijriMonth = hDate.month
                root.currentHijriYear = hDate.year

                let arMonths = ["محرم", "صفر", "ربيع الأول", "ربيع الآخر", "جمادى الأولى", "جمادى الآخرة", "رجب", "شعبان", "رمضان", "شوال", "ذو القعدة", "ذو الحجة"]
                let enMonths = ["Muharram", "Safar", "Rabi Al-Awwal", "Rabi Al-Akhar", "Jumada Al-Awwal", "Jumada Al-Akhirah", "Rajab", "Shaban", "Ramadan", "Shawwal", "Dhu Al-Qidah", "Dhu Al-Hijjah"]
                let monthName = root.languageIndex === 1 ? arMonths[hDate.month - 1] : enMonths[hDate.month - 1]
                
                root.hijriDateDisplay = hDate.day + " " + monthName + " " + hDate.year + " " + (root.languageIndex === 1 ? "هـ" : "AH")
                updateSpecialIslamicDateMessage()
            } else {
                root.times = {}; processRawTimesAndApplyOffsets()
                root.hijriDateDisplay = i18n("Offline - Set Coordinates")
                root.specialIslamicDateMessage = ""
            }
        }
    }

    // =========================================================================
    // QURAN AUDIO PREDICTIVE ROUTING HELPERS
    // =========================================================================
    
    function padZero(num) {
        var s = num + "";
        while (s.length < 3) s = "0" + s;
        return s;
    }

    function getPredictableAudioUrl(reciterId, surahIdx, ayahNum) {
        let folder = Logic.everyAyahFolders[reciterId];
        if (!folder) folder = "Abdul_Basit_Murattal_192kbps";
        return "https://everyayah.com/data/" + folder + "/" + padZero(surahIdx) + padZero(ayahNum) + ".mp3";
    }

    function globalAyahToSurahAyah(globalAyahIndex) {
        let remaining = globalAyahIndex;
        for (let i = 0; i < root.surahData.length; i++) {
            let limit = root.surahData[i][2];
            if (remaining <= limit) {
                return { surahNumber: i + 1, ayahNumber: remaining };
            }
            remaining -= limit;
        }
        return { surahNumber: 114, ayahNumber: 6 };
    }

    function fetchDailyVerse() {
        let today = getYYYYMMDD(new Date())
        if (cacheSettings.verseCacheDate === today && cacheSettings.verseCacheData) {
            try {
                let cached = JSON.parse(cacheSettings.verseCacheData)
                root.dailyVerseArabic = cached.arabic
                root.dailyVerseTranslation = cached.translation
                root.dailyVerseReference = cached.reference
                root.dailyVerseAudioUrl = cached.audioUrl || ""
                root.dailyVerseGlobalAyahNumber = cached.globalAyah || 0
                root.currentSurahNumber = cached.surahNumber || 1
                root.currentAyahNumber = cached.ayahNumber || 1
                console.log("Loaded verse from cache for date:", today)
                return
            } catch (e) { console.log("Failed to parse cached verse, fetching new one.") }
        }
        console.log("Fetching new daily verse...")
        let randomAyahNumber = Math.floor(Math.random() * 6236) + 1
        let URL = `https://api.alquran.cloud/v1/ayah/${randomAyahNumber}/editions/quran-uthmani,en.sahih`
        let xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    try {
                        let data = JSON.parse(xhr.responseText).data
                        let arabicData = data.find(ed => ed.edition.identifier === "quran-uthmani")
                        let translationData = data.find(ed => ed.edition.identifier === "en.sahih")

                        root.dailyVerseArabic = arabicData.text
                        root.dailyVerseTranslation = translationData.text
                        root.dailyVerseReference = "Surah " + arabicData.surah.englishName + " (" + arabicData.surah.number + ":" + arabicData.numberInSurah + ")"
                        root.dailyVerseGlobalAyahNumber = arabicData.number
                        root.currentSurahNumber = arabicData.surah.number
                        root.currentAyahNumber = arabicData.numberInSurah
                        root.dailyVerseAudioUrl = getPredictableAudioUrl(root.activeReciterIdentifier, root.currentSurahNumber, root.currentAyahNumber)

                        let cachePayload = JSON.stringify({
                            arabic: root.dailyVerseArabic,
                            translation: root.dailyVerseTranslation,
                            reference: root.dailyVerseReference,
                            audioUrl: root.dailyVerseAudioUrl,
                            globalAyah: root.dailyVerseGlobalAyahNumber,
                            surahNumber: root.currentSurahNumber,
                            ayahNumber: root.currentAyahNumber
                        })
                        cacheSettings.verseCacheData = cachePayload
                        cacheSettings.verseCacheDate = today
                        console.log("Fetched and cached new verse for:", today)
                    } catch (e) {
                        console.log("Error parsing verse API response:", e.toString())
                        _loadVerseFallback()
                    }
                } else {
                    _loadVerseFallback()
                }
            }
        }
        xhr.open("GET", URL, true); xhr.send()
    }

    function _loadVerseFallback() {
        if (cacheSettings.verseCacheData) {
            try {
                let cached = JSON.parse(cacheSettings.verseCacheData)
                root.dailyVerseArabic = cached.arabic
                root.dailyVerseTranslation = cached.translation
                root.dailyVerseReference = cached.reference
                root.dailyVerseAudioUrl = cached.audioUrl || ""
                root.dailyVerseGlobalAyahNumber = cached.globalAyah || 0
                root.currentSurahNumber = cached.surahNumber || 1
                root.currentAyahNumber = cached.ayahNumber || 1
                console.log("Loaded fallback verse from cache.")
                return
            } catch (e) { }
        }
        root.dailyVerseArabic = "وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا"
        root.dailyVerseTranslation = "And whoever fears Allah - He will make for him a way out"
        root.dailyVerseReference = "Surah At-Talaq (65:2)"
        root.dailyVerseAudioUrl = ""
        root.dailyVerseGlobalAyahNumber = 5507
        root.currentSurahNumber = 65
        root.currentAyahNumber = 2
    }

    function prefetchNextVerse(standbyPlayer, ayahNumber) {
        if (!root.continuousPlayActive) return
        if (ayahNumber > 6236) {
            root.continuousPlayActive = false;
            console.log("Reached end of Quran.");
            return
        }
        let targetReciter = root.activeReciterIdentifier
        
        let coords = globalAyahToSurahAyah(ayahNumber);
        let sNum = coords.surahNumber;
        let aNum = coords.ayahNumber;
        
        let finalUrl = getPredictableAudioUrl(targetReciter, sNum, aNum);
        
        if (aNum === 1 && sNum !== 1 && sNum !== 9) {
            root.storedVerseUrlForAfterBasmalah = finalUrl;
            root.nextTrackIsBasmalah = true;
            let basmalahUrl = getPredictableAudioUrl(targetReciter, 1, 1);
            standbyPlayer.source = basmalahUrl;
        } else {
            root.nextTrackIsBasmalah = false;
            console.log("Prefetching fresh Predictable URL instantly:", finalUrl)
            standbyPlayer.source = finalUrl;
        }

        let URL = `https://api.alquran.cloud/v1/ayah/${ayahNumber}/editions/quran-uthmani,en.sahih`

        let xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    try {
                        let data = JSON.parse(xhr.responseText).data
                        let arabicData = data.find(ed => ed.edition.identifier === "quran-uthmani")
                        let translationData = data.find(ed => ed.edition.identifier === "en.sahih")

                        if (arabicData && translationData) {
                            root.nextQueuedArabic = arabicData.text
                            root.nextQueuedTranslation = translationData.text
                            root.nextQueuedReference = "Surah " + arabicData.surah.englishName + " (" + arabicData.surah.number + ":" + arabicData.numberInSurah + ")"
                            root.nextQueuedSurahNumber = arabicData.surah.number
                            root.nextQueuedAyahNumber = arabicData.numberInSurah
                        }
                    } catch(e) { console.log("Error parsing prefetch text", e.toString()) }
                } else {
                    console.log("Prefetch text API error:", xhr.status)
                }
            }
        }
        xhr.open("GET", URL, true); xhr.send()
    }

    Component.onCompleted: {
        initCache()

        if (!Plasmoid.configuration.forceOfflineMode && !Plasmoid.configuration.useCoordinates && (Plasmoid.configuration.city === "" || Plasmoid.configuration.city === undefined)) {
            console.log("First run detected. Auto-detecting location from IP...");
            let xhr = new XMLHttpRequest();
            xhr.open("GET", "http://ip-api.com/json/", true);
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    try {
                        let data = JSON.parse(xhr.responseText);
                        if (data.city) Plasmoid.configuration.city = data.city;
                        if (data.country) {
                            Plasmoid.configuration.country = data.country;
                            
                            let c = data.country.toLowerCase();
                            let methodIndex = 3; // Default to MWL
                            
                            if (c.includes("egypt")) methodIndex = 5;
                            else if (c.includes("morocco")) methodIndex = 14;
                            else if (c.includes("pakistan") || c.includes("bangladesh") || c.includes("india") || c.includes("afghanistan")) methodIndex = 1;
                            else if (c.includes("usa") || c.includes("america") || c.includes("canada") || c.includes("united states")) methodIndex = 2;
                            else if (c.includes("saudi")) methodIndex = 4;
                            else if (c.includes("iran")) methodIndex = 6;
                            else if (c.includes("gulf") || c.includes("bahrain") || c.includes("oman") || c.includes("yemen")) methodIndex = 7;
                            else if (c.includes("kuwait")) methodIndex = 8;
                            else if (c.includes("qatar")) methodIndex = 9;
                            else if (c.includes("singapore")) methodIndex = 10;
                            else if (c.includes("france")) methodIndex = 11;
                            else if (c.includes("turkey") || c.includes("turkiye")) methodIndex = 12;
                            else if (c.includes("russia")) methodIndex = 13;
                            else if (c.includes("uae") || c.includes("united arab emirates") || c.includes("dubai")) methodIndex = 15;
                            else if (c.includes("malaysia")) methodIndex = 16;
                            else if (c.includes("tunisia")) methodIndex = 17;
                            else if (c.includes("algeria")) methodIndex = 18;
                            else if (c.includes("indonesia")) methodIndex = 19;
                            else if (c.includes("portugal")) methodIndex = 20;
                            else if (c.includes("jordan")) methodIndex = 21;
                            
                            Plasmoid.configuration.method = methodIndex;
                        }
                        if (data.lat && data.lon) {
                            Plasmoid.configuration.latitude = data.lat.toString();
                            Plasmoid.configuration.longitude = data.lon.toString();
                            Plasmoid.configuration.useCoordinates = true;
                        }
                    } catch (e) { console.log("Error during first run IP fetch:", e.toString()) }
                }
            }
            xhr.send();
        }

        startupTimer.start()
        Plasmoid.configuration.valueChanged.connect(function(key) {
            if (key.endsWith("OffsetMinutes") && (Object.keys(root.times).length > 0 )) {
                processRawTimesAndApplyOffsets()
            } else if (key === "languageIndex" || key === "city" || key === "country" ||
                key === "method" || key === "school" || key === "hijriOffset" ||
                key === "useCoordinates" || key === "latitude" || key === "longitude") {

                if (key === "useCoordinates") root.useCoordinates = Plasmoid.configuration.useCoordinates || false
                else if (key === "latitude") root.latitude = Plasmoid.configuration.latitude || ""
                else if (key === "longitude") root.longitude = Plasmoid.configuration.longitude || ""
                
                // Invalidate cache and debounce the network fetch to avoid race condition and rate-limiting
                cacheSettings.cacheData = "{}"
                cacheSettings.lastCacheUpdate = 0
                root.blockAdhanOnFetch = true
                configDebounceTimer.restart()

                } else if (key === "adhanAudioPath") {
                    root.adhanAudioPath = Plasmoid.configuration.adhanAudioPath || ""
                } else if (key === "adhanPlaybackMode") {
                    root.adhanPlaybackMode = Plasmoid.configuration.adhanPlaybackMode || 0
                } else if (key === "adhanVolume") {
                    root.adhanVolume = Plasmoid.configuration.adhanVolume || 0.7
                } else if (key.startsWith("playAdhanFor")) {
                    switch(key) {
                        case "playAdhanForFajr": root.playAdhanForFajr = Plasmoid.configuration.playAdhanForFajr; break
                        case "playAdhanForDhuhr": root.playAdhanForDhuhr = Plasmoid.configuration.playAdhanForDhuhr; break
                        case "playAdhanForAsr": root.playAdhanForAsr = Plasmoid.configuration.playAdhanForAsr; break
                        case "playAdhanForMaghrib": root.playAdhanForMaghrib = Plasmoid.configuration.playAdhanForMaghrib; break
                        case "playAdhanForIsha": root.playAdhanForIsha = Plasmoid.configuration.playAdhanForIsha; break
                    }
                }
        })
    }

    onQuranReciterIndexChanged: {
        console.log("Reciter index changed to:", root.quranReciterIndex)
        // property activeReciterIdentifier automatically updates due to binding
        console.log("New identifier:", root.activeReciterIdentifier)
        cacheSettings.verseCacheData = "{}"
        cacheSettings.verseCacheDate = ""
        fetchDailyVerse()
    }
}
