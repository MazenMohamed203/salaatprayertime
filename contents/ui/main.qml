import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid
import org.kde.notification
import Qt.labs.settings
import QtMultimedia
import org.kde.plasma.core as PlasmaCore

PlasmoidItem {
    id: root

    Layout.minimumWidth: Kirigami.Units.gridUnit * 7
    Layout.preferredWidth: Kirigami.Units.gridUnit * 7
    Plasmoid.backgroundHints: (Plasmoid.configuration.showBackground === undefined || Plasmoid.configuration.showBackground) ? PlasmaCore.Types.StandardBackground : PlasmaCore.Types.NoBackground




    // =========================================================================
    // PROPERTIES & DATA
    // =========================================================================

    property var surahData: [
        ["Al-Fatiha", "الفاتحة", 7], ["Al-Baqarah", "البقرة", 286], ["Al-Imran", "آل عمران", 200], ["An-Nisa", "النساء", 176],
        ["Al-Ma'idah", "المائدة", 120], ["Al-An'am", "الأنعام", 165], ["Al-A'raf", "الأعراف", 206], ["Al-Anfal", "الأنفال", 75],
        ["At-Tawbah", "التوبة", 129], ["Yunus", "يونس", 109], ["Hud", "هود", 123], ["Yusuf", "يوسف", 111],
        ["Ar-Ra'd", "الرعد", 43], ["Ibrahim", "إبراهيم", 52], ["Al-Hijr", "الحجر", 99], ["An-Nahl", "النحل", 128],
        ["Al-Isra", "الإسراء", 111], ["Al-Kahf", "الكهف", 110], ["Maryam", "مريم", 98], ["Ta-Ha", "طه", 135],
        ["Al-Anbiya", "الأنبياء", 112], ["Al-Hajj", "الحج", 78], ["Al-Mu'minun", "المؤمنون", 118], ["An-Nur", "النور", 64],
        ["Al-Furqan", "الفرقان", 77], ["Ash-Shu'ara", "الشعراء", 227], ["An-Naml", "النمل", 93], ["Al-Qasas", "القصص", 88],
        ["Al-Ankabut", "العنكبوت", 69], ["Ar-Rum", "الروم", 60], ["Luqman", "لقمان", 34], ["As-Sajdah", "السجدة", 30],
        ["Al-Ahzab", "الأحزاب", 73], ["Saba", "سبأ", 54], ["Fatir", "فاطر", 45], ["Ya-Sin", "يس", 83],
        ["As-Saffat", "الصافات", 182], ["Sad", "ص", 88], ["Az-Zumar", "الزمر", 75], ["Ghafir", "غافر", 85],
        ["Fussilat", "فصلت", 54], ["Ash-Shura", "الشورى", 53], ["Az-Zukhruf", "الزخرف", 89], ["Ad-Dukhan", "الدخان", 59],
        ["Al-Jathiyah", "الجاثية", 37], ["Al-Ahqaf", "الأحقاف", 35], ["Muhammad", "محمد", 38], ["Al-Fath", "الفتح", 29],
        ["Al-Hujurat", "الحجرات", 18], ["Qaf", "ق", 45], ["Ad-Dhariyat", "الذاريات", 60], ["At-Tur", "الطور", 49],
        ["An-Najm", "النجم", 62], ["Al-Qamar", "القمر", 55], ["Ar-Rahman", "الرحمن", 78], ["Al-Waqi'ah", "الواقعة", 96],
        ["Al-Hadid", "الحديد", 29], ["Al-Mujadila", "المجادلة", 22], ["Al-Hashr", "الحشر", 24], ["Al-Mumtahanah", "الممتحنة", 13],
        ["As-Saff", "الصف", 14], ["Al-Jumu'ah", "الجمعة", 11], ["Al-Munafiqun", "المنافقون", 11], ["At-Taghabun", "التغابن", 18],
        ["At-Talaq", "الطلاق", 12], ["At-Tahrim", "التحريم", 12], ["Al-Mulk", "الملك", 30], ["Al-Qalam", "القلم", 52],
        ["Al-Haqqah", "الحاقة", 52], ["Al-Ma'arij", "المعارج", 44], ["Nuh", "نوح", 28], ["Al-Jinn", "الجن", 28],
        ["Al-Muzzammil", "المزمل", 20], ["Al-Muddaththir", "المدثر", 56], ["Al-Qiyamah", "القيامة", 40], ["Al-Insan", "الإنسان", 31],
        ["Al-Mursalat", "المرسلات", 50], ["An-Naba", "النبأ", 40], ["An-Nazi'at", "النازعات", 46], ["Abasa", "عبس", 42],
        ["At-Takwir", "التكوير", 29], ["Al-Infitar", "الانفطار", 19], ["Al-Mutaffifin", "المطففين", 36], ["Al-Inshiqaq", "الانشقاق", 25],
        ["Al-Buruj", "البروج", 22], ["At-Tariq", "الطارق", 17], ["Al-A'la", "الأعلى", 19], ["Al-Ghashiyah", "الغاشية", 26],
        ["Al-Fajr", "الفجر", 30], ["Al-Balad", "البلد", 20], ["Ash-Shams", "الشمس", 15], ["Al-Layl", "الليل", 21],
        ["Ad-Duha", "الضحى", 11], ["Ash-Sharh", "الشرح", 8], ["At-Tin", "التين", 8], ["Al-Alaq", "العلق", 19],
        ["Al-Qadr", "القدر", 5], ["Al-Bayyinah", "البينة", 8], ["Az-Zalzalah", "الزلزلة", 8], ["Al-Adiyat", "العاديات", 11],
        ["Al-Qari'ah", "القارعة", 11], ["At-Takathur", "التكاثر", 8], ["Al-Asr", "العصر", 3], ["Al-Humazah", "الهمزة", 9],
        ["Al-Fil", "الفيل", 5], ["Quraysh", "قريش", 4], ["Al-Ma'un", "الماعون", 7], ["Al-Kawthar", "الكوثر", 3],
        ["Al-Kafirun", "الكافرون", 6], ["An-Nasr", "النصر", 3], ["Al-Masad", "المسد", 5], ["Al-Ikhlas", "الإخلاص", 4],
        ["Al-Falaq", "الفلق", 5], ["An-Nas", "الناس", 6]
    ]

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
    property string nextPrayerNameForDisplay: ""
    property string nextPrayerTimeForDisplay: ""

    property string lastActivePrayer: ""
    property string activePrayer: ""
    property var preNotifiedPrayers: ({})

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

    property var quranReciterIdentifiers: [
        "ar.minshawi", "ar.alafasy", "ar.husary", "ar.abdurrahmaansudais",
        "ar.mahermuaiqly", "ar.shaatree", "ar.abdullahbasfar",
        "ar.abdulbasitmurattal", "ar.hudhaify", "ar.muhammadjibreel",
        "ar.husarymujawwad", "ar.minshawimujawwad", "ar.ahmedajamy"
    ]

    property var quranReciterNames: [
        i18n("Minshawi (Murattal)"), i18n("Alafasy"), i18n("Husary (Murattal)"),
        i18n("Abdurrahmaan As-Sudais"), i18n("Maher Al Muaiqly"), i18n("Abu Bakr Ash-Shaatree"),
        i18n("Abdullah Basfar"), i18n("Abdulbasit (Murattal)"), i18n("Hudhaify"), i18n("Muhammad Jibreel"),
        i18n("Husary (Mujawwad)"), i18n("Minshawi (Mujawwad)"), i18n("Ahmed ibn Ali al-Ajamy")
    ]

    property var quranReciterNames_ar: [
        "المنشاوي (مرتل)", "العفاسي", "الحصري (مرتل)", "عبد الرحمن السديس",
        "ماهر المعيقلي", "أبو بكر الشاطري", "عبد الله بصفر", "عبد الباسط (مرتل)",
        "الحذيفي", "محمد جبريل",
        "الحصري (مجود)", "المنشاوي (مجود)", "أحمد بن علي العجمي"
    ]

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
        interval: 30000; running: true; repeat: true;
        onTriggered: {
            if (root.times && Object.keys(root.times).length > 0 && root.displayPrayerTimes.apiGregorianDate && getFormattedDate(new Date()) === root.displayPrayerTimes.apiGregorianDate) {
                if (Object.keys(root.displayPrayerTimes).length > 0) {
                    root.highlightActivePrayer(root.displayPrayerTimes);
                    root.checkPreNotifications(root.displayPrayerTimes);
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
                root.timeUntilNextPrayer = String(hours).padStart(2, '0') + ":" + String(minutes).padStart(2, '0');
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

    // OPTIMIZATION: 10ms interval for Turbo-Seek
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

                // Turbo: Set Position BEFORE Play to force Range Request
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

    fullRepresentation: Kirigami.Page {
        id: fullView
        background: Rectangle { color: "transparent" }

        Shortcut { sequence: StandardKey.MediaTogglePlayPause; onActivated: root.togglePlayback() }
        Shortcut { sequence: StandardKey.MediaPlay; onActivated: { var p = root.isPlayerA_the_active_verse_player ? playerA : playerB; p.play() } }
        Shortcut { sequence: StandardKey.MediaPause; onActivated: { var p = root.isPlayerA_the_active_verse_player ? playerA : playerB; p.pause() } }
        Shortcut { sequence: StandardKey.MediaStop; onActivated: { root.continuousPlayActive = false; playerA.stop(); playerB.stop(); root.isAdhanPlaying = false } }

        onVisibleChanged: {
            if (visible && Object.keys(root.displayPrayerTimes).length > 0) root.highlightActivePrayer(root.displayPrayerTimes);
        }
        implicitWidth: Kirigami.Units.gridUnit * 22

        Column {
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
                    height: Kirigami.Units.gridUnit * 2.0
                    radius: 8
                    color: root.activePrayer === modelData ? Kirigami.Theme.highlightColor : "transparent"
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: Kirigami.Units.largeSpacing
                        anchors.rightMargin: Kirigami.Units.largeSpacing
                        Label {
                            text: getPrayerName(root.languageIndex, modelData)
                            color: parent.parent.color === Kirigami.Theme.highlightColor ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                            font.weight: Font.Bold
                            font.pointSize: Kirigami.Theme.defaultFont.pointSize
                        }
                        Item { Layout.fillWidth: true }
                        Label {
                            text: root.to12HourTime(root.displayPrayerTimes[modelData], Plasmoid.configuration.hourFormat)
                            color: parent.parent.color === Kirigami.Theme.highlightColor ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                            font.pointSize: Kirigami.Theme.defaultFont.pointSize
                        }
                    }
                }
            }

            PlasmaComponents.MenuSeparator {
                width: parent.width - (parent.padding * 2)
                topPadding: Kirigami.Units.smallSpacing
                bottomPadding: Kirigami.Units.smallSpacing
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                width: parent.width - (parent.padding * 2)
                text: root.languageIndex === 1 ? "القرآن الكريم" : "Quran"
                onClicked: {
                    var dialog = quoteDialogComponent.createObject(fullView);
                    if (dialog) dialog.open();
                    else console.error("Failed to create dialog");
                }
            }
        }
    }

    // =========================================================================
    // POPUP DIALOG
    // =========================================================================

    Component {
        id: quoteDialogComponent
        Dialog {
            id: dialog
            title: (root.languageIndex === 1 ? "القرآن الكريم" : "Quran Player") + " (" + root.activeReciterName + ")"
            modal: true
            standardButtons: Dialog.Close
            property int dialogWidth: Kirigami.Units.gridUnit * 22
            width: dialogWidth
            padding: Kirigami.Units.largeSpacing

            Connections {
                target: root
                function onCurrentSurahNumberChanged() {
                    let idx = root.currentSurahNumber - 1
                    if (idx >= 0 && idx < surahCombo.count && surahCombo.currentIndex !== idx) {
                        surahCombo.currentIndex = idx
                        verseSpin.to = root.surahData[idx][2]
                    }
                }
                function onCurrentAyahNumberChanged() {
                    if (verseSpin.value !== root.currentAyahNumber) {
                        verseSpin.value = root.currentAyahNumber
                    }
                }
            }

            contentItem: ScrollView {
                id: scroller
                width: dialog.width - (dialog.padding * 2)
                Layout.maximumHeight: Kirigami.Units.gridUnit * 40
                ScrollBar.vertical.policy: ScrollBar.AsNeeded
                ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                clip: true

                ColumnLayout {
                    width: scroller.availableWidth
                    spacing: Kirigami.Units.largeSpacing

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing

                        ComboBox {
                            id: surahCombo
                            Layout.fillWidth: true
                            Layout.preferredWidth: 2
                            model: root.surahData.map(function(s, index) {
                                let surahNum = index + 1
                                return (root.languageIndex === 1) ? (surahNum + ". " + s[1]) : (surahNum + ". " + s[0])
                            })

                            onActivated: {
                                verseSpin.to = root.surahData[currentIndex][2]
                                verseSpin.value = 1
                            }

                            delegate: ItemDelegate {
                                width: parent.width
                                contentItem: Text {
                                    text: modelData
                                    font: parent.font
                                    color: Kirigami.Theme.textColor
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                }
                                highlighted: ComboBox.isCurrentItem
                            }

                            popup.background: Rectangle {
                                color: Kirigami.Theme.backgroundColor
                                border.color: Kirigami.Theme.frameColor
                                border.width: 1
                                radius: 2
                            }

                            Component {
                                id: myDelegateComponent
                                ItemDelegate {
                                    id: delegateItem
                                    width: (surahCombo) ? surahCombo.width : 200
                                    highlighted: ListView.isCurrentItem || false
                                    contentItem: Text {
                                        text: modelData
                                        font: parent.font
                                        color: delegateItem.highlighted ? (Kirigami.Theme.highlightedTextColor || "white") : (Kirigami.Theme.textColor || "black")
                                        elide: Text.ElideRight
                                        verticalAlignment: Text.AlignVCenter
                                    }
                                    background: Rectangle {
                                        color: delegateItem.highlighted ? (Kirigami.Theme.highlightColor || "blue") : "transparent"
                                        radius: 2
                                    }
                                }
                            }
                            Component.onCompleted: {
                                if (popup && popup.contentItem) {
                                    try { popup.contentItem.delegate = myDelegateComponent } catch (e) {}
                                }
                            }
                        }

                        SpinBox {
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

                        Button {
                            Layout.fillWidth: true
                            text: root.languageIndex === 1 ? i18n("تشغيل") : i18n("Play")
                            icon.name: "media-playback-start"
                            enabled: !root.isAnyAudioPlaying && !root.isFetchingVerse
                            onClicked: {
                                root.continuousPlayActive = false
                                root.isAdhanPlaying = false
                                root.isPlayingBasmalahGap = false
                                root.nextTrackIsBasmalah = false
                                adhanStopTimer.stop()
                                playerA.stop(); playerB.stop()

                                let surahIndex = surahCombo.currentIndex + 1
                                let ayahIndex = verseSpin.value
                                playSpecificVerse(surahIndex, ayahIndex)
                            }
                        }

                        Button {
                            Layout.fillWidth: true
                            property var activePlayer: root.isPlayerA_the_active_verse_player ? playerA : playerB
                            text: activePlayer.playbackState === MediaPlayer.PlayingState ? (root.languageIndex === 1 ? i18n("إيقاف مؤقت") : i18n("Pause")) : (root.languageIndex === 1 ? i18n("استئناف") : i18n("Resume"))
                            icon.name: activePlayer.playbackState === MediaPlayer.PlayingState ? "media-playback-pause" : "media-playback-start"
                            enabled: (activePlayer.playbackState === MediaPlayer.PlayingState || activePlayer.playbackState === MediaPlayer.PausedState)
                            onClicked: root.togglePlayback()
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: Kirigami.Units.smallSpacing
                        Label {
                            property var activePlayer: root.isPlayerA_the_active_verse_player ? playerA : playerB
                            text: formatTime(activePlayer.position)
                            font.pointSize: Kirigami.Theme.smallFont.pointSize
                        }
                        Slider {
                            Layout.fillWidth: true
                            property var activePlayer: root.isPlayerA_the_active_verse_player ? playerA : playerB
                            from: 0
                            to: activePlayer.duration > 0 ? activePlayer.duration : 1
                            value: activePlayer.position
                            onMoved: activePlayer.position = value
                            Connections {
                                target: root
                                function onIsPlayerA_the_active_verse_playerChanged() {
                                    parent.activePlayer = root.isPlayerA_the_active_verse_player ? playerA : playerB;
                                }
                            }
                        }
                        Label {
                            property var activePlayer: root.isPlayerA_the_active_verse_player ? playerA : playerB
                            text: formatTime(activePlayer.duration)
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
                        Slider {
                            id: verseVolumeSlider
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignVCenter
                            from: 0.0; to: 1.0; stepSize: 0.05
                            value: root.quranVolume
                            onValueChanged: root.quranVolume = value
                        }
                        Label {
                            text: Math.round(verseVolumeSlider.value * 100) + "%"
                            Layout.alignment: Qt.AlignVCenter
                            font.pointSize: Kirigami.Theme.smallFont.pointSize
                        }
                    }

                    Label {
                        text: root.dailyVerseArabic
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize + 2
                        font.weight: Font.Medium
                        font.family: "Noto Sans Arabic"
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        color: Kirigami.Theme.textColor
                    }
                    Label {
                        text: root.dailyVerseTranslation
                        font.pointSize: Kirigami.Theme.defaultFont.pointSize
                        font.italic: true
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        opacity: 0.9
                        color: Kirigami.Theme.textColor
                    }
                    Label {
                        text: root.dailyVerseReference
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
                let sIndex = root.currentSurahNumber - 1
                if (sIndex < 0) sIndex = 0
                    if (sIndex > 113) sIndex = 113
                        surahCombo.currentIndex = sIndex
                        verseSpin.to = root.surahData[sIndex][2]
                        verseSpin.value = root.currentAyahNumber
            }
        }
    }

    // =========================================================================
    // LOGIC & HELPER FUNCTIONS
    // =========================================================================

    function playSpecificVerse(surahNum, ayahNum) {
        if (root.isFetchingVerse) return;
        root.isFetchingVerse = true;

        console.log("Fetching Surah " + surahNum + " Verse " + ayahNum)
        let targetReciter = root.activeReciterIdentifier
        let URL = `https://api.alquran.cloud/v1/ayah/${surahNum}:${ayahNum}/editions/quran-uthmani,en.sahih,${targetReciter}`

        let xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                root.isFetchingVerse = false;
                if (xhr.status === 200) {
                    try {
                        let data = JSON.parse(xhr.responseText).data
                        let arabicData = data.find(ed => ed.edition.identifier === "quran-uthmani")
                        let translationData = data.find(ed => ed.edition.identifier === "en.sahih")
                        let audioData = data.find(ed => ed.edition.identifier === targetReciter)

                        if (audioData && arabicData) {
                            root.dailyVerseArabic = arabicData.text
                            root.dailyVerseTranslation = translationData.text
                            root.dailyVerseReference = "Surah " + arabicData.surah.englishName + " (" + arabicData.surah.number + ":" + arabicData.numberInSurah + ")"
                            root.dailyVerseGlobalAyahNumber = arabicData.number

                            root.currentSurahNumber = arabicData.surah.number
                            root.currentAyahNumber = arabicData.numberInSurah

                            let finalUrl = audioData.audio.replace("https:", "http:")

                            root.continuousPlayActive = true
                            playerA.source = finalUrl
                            playerA.play()
                            root.isPlayerA_the_active_verse_player = true
                        }
                    } catch (e) { console.log("Error parsing specific verse:", e.toString()) }
                }
            }
        }
        xhr.open("GET", URL, true); xhr.send()
    }

    function formatTime(ms) {
        if (ms <= 0) return "00:00"
            let totalSeconds = Math.floor(ms / 1000)
            let minutes = Math.floor(totalSeconds / 60)
            let seconds = totalSeconds % 60
            return String(minutes).padStart(2, '0') + ":" + String(seconds).padStart(2, '0')
    }

    function initCache() { console.log("Prayer Times Widget: Cache initialized.") }

    function to12HourTime(timeString, isActive) {
        if (!timeString || timeString === "--:--") return "--:--"
            if (isActive) {
                let parts = timeString.split(':')
                let hours = parseInt(parts[0], 10)
                let minutes = parseInt(parts[1], 10)
                let period = hours >= 12 ? i18n("PM") : i18n("AM")
                hours = hours % 12 || 12
                return `${hours}:${String(minutes).padStart(2, '0')} ${period}`
            }
            return timeString
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
        if (!Plasmoid.configuration.preNotificationMinutes || Plasmoid.configuration.preNotificationMinutes <= 0) return
            if (!currentTimingsToUse || !currentTimingsToUse.Fajr) return

                const now = new Date()
                const notificationWindow = Plasmoid.configuration.preNotificationMinutes
                const prayerKeys = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"]

                for (const prayerName of prayerKeys) {
                    const prayerTimeStr = currentTimingsToUse[prayerName]
                    if (!prayerTimeStr || prayerTimeStr === "--:--") continue

                        let prayerTime = parseTime(prayerTimeStr)
                        if (prayerName === "Fajr" && prayerTime < now) prayerTime.setDate(prayerTime.getDate() + 1)

                            let diffMs = prayerTime.getTime() - now.getTime()
                            const minutesUntil = Math.floor(diffMs / (1000 * 60))

                            if (minutesUntil > 0 && minutesUntil <= notificationWindow) {
                                const todayKey = getYYYYMMDD(now)
                                const notificationKey = prayerName + "-" + todayKey

                                if (!root.preNotifiedPrayers[notificationKey]) {
                                    var notification = notificationComponent.createObject(root)
                                    notification.title = i18n("%1 in %2 minutes", getPrayerName(root.languageIndex, prayerName), minutesUntil)
                                    notification.text = i18n("Prayer time reminder")
                                    notification.eventId = "notification"

                                    if (root.playPreAdhanSound) {
                                        notification.hints = { "sound-name": "message-new-instant" }
                                    }

                                    notification.sendEvent()
                                    root.preNotifiedPrayers[notificationKey] = true
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
                        if (Plasmoid.configuration.notifications) {
                            var notification = notificationComponent.createObject(root)
                            notification.title = i18n("It's %1 time", getPrayerName(root.languageIndex, root.activePrayer))
                            notification.sendEvent()
                        }
                        if (root.activePrayer !== "Sunrise") playAdhanAudio(root.activePrayer)
                    }
                }
    }

    function resetPreNotifications() { root.preNotifiedPrayers = {} }
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
            // 1. Get raw values from API
            let rawDay = parseInt(hijriDataObject.day, 10)
            let rawMonth = parseInt(hijriDataObject.month.number, 10)
            let rawYear = parseInt(hijriDataObject.year, 10)

            // 2. Apply the Offset from Settings locally
            let offset = Plasmoid.configuration.hijriOffset || 0
            let adjustedDay = rawDay + offset

            // 3. Handle simple rollovers (Assuming 30 days/month for safety)
            // This ensures we don't show "31 Ramadan" or "0 Ramadan"
            if (adjustedDay > 30) {
                adjustedDay -= 30
                rawMonth += 1
                if (rawMonth > 12) { rawMonth = 1; rawYear += 1 }
            } else if (adjustedDay < 1) {
                adjustedDay += 30
                rawMonth -= 1
                if (rawMonth < 1) { rawMonth = 12; rawYear -= 1 }
            }

            // 4. Save to Root Properties
            root.currentHijriDay = adjustedDay
            root.currentHijriMonth = rawMonth
            root.currentHijriYear = rawYear

            // 5. Get the Month Name (We can't use the API's string anymore because the month might have changed)
            // We use a local array to ensure the name matches the new calculated month
            let arMonths = ["محرم", "صفر", "ربيع الأول", "ربيع الآخر", "جمادى الأولى", "جمادى الآخرة", "رجب", "شعبان", "رمضان", "شوال", "ذو القعدة", "ذو الحجة"]
            let enMonths = ["Muharram", "Safar", "Rabi Al-Awwal", "Rabi Al-Thani", "Jumada Al-Awwal", "Jumada Al-Thani", "Rajab", "Sha'ban", "Ramadan", "Shawwal", "Dhu Al-Qi'dah", "Dhu Al-Hijjah"]

            // Adjust index (Month 1 is index 0)
            let mIndex = rawMonth - 1
            if (mIndex < 0) mIndex = 0
                if (mIndex > 11) mIndex = 11

                    let monthName = (root.languageIndex === 1) ? arMonths[mIndex] : enMonths[mIndex]

                    // 6. Display
                    root.hijriDateDisplay = `${root.currentHijriDay} ${monthName} ${root.currentHijriYear}`
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
        let todayForAPI = getFormattedDate(new Date())
        let method = Plasmoid.configuration.method || 4
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

                    update5DayCache()
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

    function update5DayCache() {
        const now = new Date()
        const cacheKey = "last_5day_update"
        const lastUpdate = Number(cachedData[cacheKey] || 0)
        const daysSinceUpdate = (now.getTime() - lastUpdate) / (1000 * 60 * 60 * 24)

        if (daysSinceUpdate >= 5 || Object.keys(cachedData).length <= 1) {
            const year = now.getFullYear(); const month = now.getMonth() + 1
            const method = (Plasmoid.configuration.method !== undefined) ? Plasmoid.configuration.method : 4
            const school = (Plasmoid.configuration.school !== undefined) ? Plasmoid.configuration.school : 0
            let URL = ""
            if (root.useCoordinates && root.latitude && root.longitude) {
                URL = `https://api.aladhan.com/v1/calendar/${year}/${month}?latitude=${encodeURIComponent(root.latitude)}&longitude=${encodeURIComponent(root.longitude)}&method=${method}&school=${school}`
            } else {
                if (!Plasmoid.configuration.city || !Plasmoid.configuration.country) { saveTodayToCache(); return }
                URL = `https://api.aladhan.com/v1/calendarByCity/${year}/${month}?city=${encodeURIComponent(Plasmoid.configuration.city)}&country=${encodeURIComponent(Plasmoid.configuration.country)}&method=${method}&school=${school}`
            }
            const xhr = new XMLHttpRequest()
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4 && xhr.status === 200) {
                    try {
                        const monthlyData = JSON.parse(xhr.responseText).data
                        if (monthlyData && monthlyData.length > 0) {
                            const updatedCache = Object.assign({}, cachedData)
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
                            updatedCache[cacheKey] = now.getTime()
                            cacheSettings.cacheData = JSON.stringify(updatedCache)
                            cacheSettings.lastCacheUpdate = now.getTime()
                        }
                    } catch (e) { console.log("Monthly cache parse error:", e.toString()) }
                }
            }
            xhr.open("GET", URL, true); xhr.send()
        }
        saveTodayToCache()
    }

    function loadFromCache() {
        const todayKey = getYYYYMMDD(new Date()); let loaded = false
        if (cachedData[todayKey]) {
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
        if (!loaded) {
            root.times = {}; processRawTimesAndApplyOffsets()
            root.hijriDateDisplay = i18n("Offline - No data")
            root.specialIslamicDateMessage = ""
        }
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
        let URL = `https://api.alquran.cloud/v1/ayah/${randomAyahNumber}/editions/quran-uthmani,en.sahih,${root.activeReciterIdentifier}`
        let xhr = new XMLHttpRequest()
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    try {
                        let data = JSON.parse(xhr.responseText).data
                        let arabicData = data.find(ed => ed.edition.identifier === "quran-uthmani")
                        let translationData = data.find(ed => ed.edition.identifier === "en.sahih")
                        let audioData = data.find(ed => ed.edition.identifier === root.activeReciterIdentifier)

                        root.dailyVerseArabic = arabicData.text
                        root.dailyVerseTranslation = translationData.text
                        root.dailyVerseReference = "Surah " + arabicData.surah.englishName + " (" + arabicData.surah.number + ":" + arabicData.numberInSurah + ")"
                        root.dailyVerseAudioUrl = audioData.audio
                        root.dailyVerseGlobalAyahNumber = arabicData.number
                        root.currentSurahNumber = arabicData.surah.number
                        root.currentAyahNumber = arabicData.numberInSurah

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
            let URL = `https://api.alquran.cloud/v1/ayah/${ayahNumber}/editions/quran-uthmani,en.sahih,${targetReciter}`

            let xhr = new XMLHttpRequest()
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        try {
                            let data = JSON.parse(xhr.responseText).data
                            let arabicData = data.find(ed => ed.edition.identifier === "quran-uthmani")
                            let translationData = data.find(ed => ed.edition.identifier === "en.sahih")
                            let audioData = data.find(ed => ed.edition.identifier === targetReciter)

                            if (audioData && audioData.audio && arabicData && translationData) {
                                root.nextQueuedArabic = arabicData.text
                                root.nextQueuedTranslation = translationData.text
                                root.nextQueuedReference = "Surah " + arabicData.surah.englishName + " (" + arabicData.surah.number + ":" + arabicData.numberInSurah + ")"
                                root.nextQueuedSurahNumber = arabicData.surah.number
                                root.nextQueuedAyahNumber = arabicData.numberInSurah

                                // OPTIMIZATION: Use HTTP to reduce TLS overhead and connection time
                                let finalUrl = audioData.audio.replace("https:", "http:")

                                if (audioData.numberInSurah === 1 && audioData.surah.number !== 1 && audioData.surah.number !== 9) {
                                    root.storedVerseUrlForAfterBasmalah = finalUrl;
                                    root.nextTrackIsBasmalah = true;
                                    let baseUrl = finalUrl.substring(0, finalUrl.lastIndexOf('/'));
                                    let basmalahUrl = baseUrl + "/1.mp3";
                                    standbyPlayer.source = basmalahUrl;
                                } else {
                                    root.nextTrackIsBasmalah = false;
                                    console.log("Prefetching fresh URL:", finalUrl)
                                    standbyPlayer.source = finalUrl
                                }
                            }
                        } catch(e) { console.log("Error parsing prefetch", e.toString()) }
                    } else {
                        console.log("Prefetch API error:", xhr.status)
                        root.continuousPlayActive = false
                    }
                }
            }
            xhr.open("GET", URL, true); xhr.send()
    }

    Component.onCompleted: {
        initCache()
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
                            fetchTimes()

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
