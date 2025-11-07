
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid
import org.kde.notification
import Qt.labs.settings
import QtMultimedia

PlasmoidItem {
    id: root

    Layout.minimumWidth: Kirigami.Units.gridUnit * 7
    Layout.preferredWidth: Kirigami.Units.gridUnit * 7
    // --- Properties ---
    property var times: ({})
    property var displayPrayerTimes: ({})
    property string hijriDateDisplay: "..."
    property var rawHijriDataFromApi: null

    // For special Islamic date logic
    property int currentHijriDay: 0
    property int currentHijriMonth: 0
    property int currentHijriYear: 0
    property string specialIslamicDateMessage: ""

    // Active prayer tracking
    property string lastActivePrayer: ""
    property string activePrayer: ""
    property var preNotifiedPrayers: ({})  // Tracks which prayers we've already sent pre-notifications for

    // Configuration dependent properties
    property bool isSmall: width < (Kirigami.Units.gridUnit * 10) || height < (Kirigami.Units.gridUnit * 10)
    property int languageIndex: Plasmoid.configuration.languageIndex !== undefined ? Plasmoid.configuration.languageIndex : 0



    // Add these new properties for audio functionality
    property string adhanAudioPath: {
        let customPath = Plasmoid.configuration.adhanAudioPath || ""
        if (customPath === "") {
            return defaultAdhanPath
        }
        return customPath
    }
    property int adhanPlaybackMode: Plasmoid.configuration.adhanPlaybackMode || 0
    property real adhanVolume: Plasmoid.configuration.adhanVolume || 0.7
    property bool playAdhanForFajr: Plasmoid.configuration.playAdhanForFajr !== undefined ? Plasmoid.configuration.playAdhanForFajr : true
    property bool playAdhanForDhuhr: Plasmoid.configuration.playAdhanForDhuhr !== undefined ? Plasmoid.configuration.playAdhanForDhuhr : true
    property bool playAdhanForAsr: Plasmoid.configuration.playAdhanForAsr !== undefined ? Plasmoid.configuration.playAdhanForAsr : true
    property bool playAdhanForMaghrib: Plasmoid.configuration.playAdhanForMaghrib !== undefined ? Plasmoid.configuration.playAdhanForMaghrib : true
    property bool playAdhanForIsha: Plasmoid.configuration.playAdhanForIsha !== undefined ? Plasmoid.configuration.playAdhanForIsha : true
    property bool useCoordinates: Plasmoid.configuration.useCoordinates || false
    property string latitude: Plasmoid.configuration.latitude || ""
    property string longitude: Plasmoid.configuration.longitude || ""


    property string defaultAdhanPath: {
        // Get the widget's root directory
        let widgetRootUrl = Qt.resolvedUrl("./").toString()

        // Construct the path to the audio file
        let audioFileUrl = widgetRootUrl + "contents/audio/Adhan.mp3"

        console.log("Widget root URL:", widgetRootUrl)
        console.log("Audio file URL:", audioFileUrl)

        return audioFileUrl
    }

    property var nextPrayerDateTime: null // Will hold the full Date object for the next prayer
    property string timeUntilNextPrayer: ""   // Will hold the formatted countdown string "HH:MM:SS"
    property string nextPrayerNameForDisplay: ""
    property string nextPrayerTimeForDisplay: ""
    // --- Timers and Components ---
    Component { id: notificationComponent; Notification { componentName: "plasma_workspace"; eventId: "notification"; autoDelete: true } }

    Timer { // Startup delay timer
        id: startupTimer
        interval: 500
        repeat: false
        onTriggered: root.fetchTimes()
    }

    Settings {
        id: cacheSettings
        category: "PrayerTimesCache"

        property string cacheData: "{}"
        property real lastCacheUpdate: 0
    }

    property var cachedData: {
        try {
            return JSON.parse(cacheSettings.cacheData || "{}")
        } catch (e) {
            return {}
        }
    }


    Timer { // Main 30-second refresh timer
        interval: 30000; running: true; repeat: true;
        onTriggered: {
            if (root.times && Object.keys(root.times).length > 0 && root.displayPrayerTimes.apiGregorianDate && getFormattedDate(new Date()) === root.displayPrayerTimes.apiGregorianDate) {
                if (Object.keys(root.displayPrayerTimes).length > 0) {
                    root.highlightActivePrayer(root.displayPrayerTimes);
                    root.checkPreNotifications(root.displayPrayerTimes);  // ← Add your new function here
                } else if (Object.keys(root.times).length > 0) {
                    processRawTimesAndApplyOffsets();
                }
            } else {
                root.fetchTimes();
            }
        }
    }

    //  Timer for the countdown display
    Timer {
        interval: 1000 // Run every second
        running: root.nextPrayerDateTime !== null && root.nextPrayerDateTime > new Date()
        repeat: true
        onTriggered: {
            if (root.nextPrayerDateTime) {
                let now = new Date();
                let diffMs = root.nextPrayerDateTime.getTime() - now.getTime();

                if (diffMs < 0) { // Time has passed
                    root.timeUntilNextPrayer = i18n("Prayer time!");
                    root.fetchTimes(); // Re-fetch to find the next prayer after this one
                    return;
                }
                let totalMinutes = Math.floor(diffMs / (1000 * 60));
                let hours = Math.floor(totalMinutes / 60);
                let minutes = totalMinutes % 60;

                root.timeUntilNextPrayer = String(hours).padStart(2, '0') + ":" +
                String(minutes).padStart(2, '0');
            }
        }
    }

    MediaPlayer {
        id: adhanPlayer
        audioOutput: adhanAudioOutput // Link player to the output

        onPlaybackStateChanged: {
            // This now handles the stopped state
            if (playbackState === MediaPlayer.StoppedState) {
                console.log("Adhan playback stopped")
                // Ensure the 15-second timer is also stopped
                adhanStopTimer.stop()
            }
        }

        onErrorOccurred: {
            console.log("Adhan playback error:", error, errorString)
        }
    }

    AudioOutput {
        id: adhanAudioOutput
        volume: root.adhanVolume // Volume is controlled here
    }


    Timer {
        id: adhanStopTimer
        interval: 40000
        repeat: false
        onTriggered: {

            if (adhanPlayer.playbackState === MediaPlayer.PlayingState) {
                adhanPlayer.stop()
                console.log("Adhan stopped after 40 seconds")
            }
        }
    }




    // --- Helper Functions ---
    function initCache() {
        console.log("Prayer Times Widget: Cache system initialized with", Object.keys(cachedData).length, "entries.")
    }
    function to12HourTime(timeString, isActive) { if (!timeString || timeString === "--:--") return timeString; if (isActive) { let parts = timeString.split(':'); let hours = parseInt(parts[0], 10); let minutes = parseInt(parts[1], 10); let period = hours >= 12 ? i18n("PM") : i18n("AM"); hours = hours % 12 || 12; return `${hours}:${String(minutes).padStart(2, '0')} ${period}`; } else { return timeString; } }
    function parseTime(timeString) { if (!timeString || timeString === "--:--") return new Date(0); let parts = timeString.split(':'); let dateObj = new Date(); dateObj.setHours(parseInt(parts[0], 10)); dateObj.setMinutes(parseInt(parts[1], 10)); dateObj.setSeconds(0); dateObj.setMilliseconds(0); return dateObj; }
    function getPrayerName(langIndex, prayerKey) { if (langIndex === 0) { return prayerKey; } else { const arabicPrayers = { "Fajr": "الفجر", "Sunrise": "الشروق", "Dhuhr": "الظهر", "Asr": "العصر", "Maghrib": "المغرب", "Isha": "العشاء" }; return arabicPrayers[prayerKey] || prayerKey; } }

    function saveCacheToSettings() {
        try {

            let cutoffDate = new Date()
            cutoffDate.setDate(cutoffDate.getDate() - 10)
            let cutoffKey = getYYYYMMDD(cutoffDate)

            let cleanedCache = {}
            for (let key in cachedData) {
                if (key >= cutoffKey || key === "last_5day_update") {
                    cleanedCache[key] = cachedData[key]
                }
            }

            cacheSettings.cacheData = JSON.stringify(cleanedCache)
            console.log("Cache saved with", Object.keys(cleanedCache).length, "entries")
        } catch (error) {
            console.log("Could not save cache:", error.toString())
        }
    }


    function testAdhanPlayback() {
        if (root.adhanAudioPath && root.adhanPlaybackMode > 0) {
            playAdhanAudio("Test")
        }
    }

    // Add this function to play adhan audio
    function playAdhanAudio(prayerName) {
        let audioPath = root.adhanAudioPath

        // If no audio path is available, try to use the default
        if (!audioPath || audioPath === "") {
            audioPath = root.defaultAdhanPath
            console.log("Using default adhan path:", audioPath)
        }

        if (!audioPath || root.adhanPlaybackMode === 0) {
            console.log("No audio path available or playback disabled")
            return
        }

        let shouldPlay = false;
        switch(prayerName) {
            case "Fajr":
                shouldPlay = root.playAdhanForFajr;
                break;
            case "Dhuhr":
                shouldPlay = root.playAdhanForDhuhr;
                break;
            case "Asr":
                shouldPlay = root.playAdhanForAsr;
                break;
            case "Maghrib":
                shouldPlay = root.playAdhanForMaghrib;
                break;
            case "Isha":
                shouldPlay = root.playAdhanForIsha;
                break;
            case "Test":
                shouldPlay = true;
                break;
            default:
                shouldPlay = false;
                break;
        }

        if (!shouldPlay) {
            console.log("Adhan playback disabled for", prayerName);
            return;
        }

        // Stop any currently playing audio
        if (adhanPlayer.playbackState === MediaPlayer.PlayingState) {
            adhanPlayer.stop()
        }
        adhanStopTimer.stop()

        // Set the audio source - ensure it's a proper URL
        let sourceUrl = audioPath
        if (!sourceUrl.startsWith("file://") && !sourceUrl.startsWith("qrc:/")) {
            sourceUrl = "file://" + sourceUrl
        }

        console.log("Setting MediaPlayer source to:", sourceUrl)
        adhanPlayer.source = sourceUrl

        // Volume is already bound on AudioOutput, but we ensure it's current
        adhanAudioOutput.volume = root.adhanVolume

        // Play the audio
        adhanPlayer.play()

        // If playback mode is "First 40 seconds only" (mode 2), start the stop timer
        if (root.adhanPlaybackMode === 2) {
            adhanStopTimer.interval = 40000  // 40 seconds
            adhanStopTimer.start()
        } else if (root.adhanPlaybackMode === 3) {  // Add this condition
            adhanStopTimer.interval = 17000  // 10 seconds
            adhanStopTimer.start()
        }

        console.log("Playing adhan for", prayerName, "from:", sourceUrl, "- Mode:", root.adhanPlaybackMode, "Volume:", root.adhanVolume)
    }

   function checkPreNotifications(currentTimingsToUse) {
    // Only proceed if pre-notifications are enabled
    if (!Plasmoid.configuration.preNotificationMinutes || 
        Plasmoid.configuration.preNotificationMinutes <= 0) {
        return;
    }
    
    if (!currentTimingsToUse || !currentTimingsToUse.Fajr) {
        return;
    }
    
    const now = new Date();
    const notificationWindow = Plasmoid.configuration.preNotificationMinutes;
    const prayerKeys = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"]; // Exclude Sunrise
    
    for (const prayerName of prayerKeys) {
        const prayerTimeStr = currentTimingsToUse[prayerName];
        if (!prayerTimeStr || prayerTimeStr === "--:--") continue;
        
        // Use the existing parseTime function
        let prayerTime = parseTime(prayerTimeStr);
        
        // Handle Fajr crossing midnight (same logic as calculateNextPrayer)
        if (prayerName === "Fajr" && prayerTime < now) {
            prayerTime.setDate(prayerTime.getDate() + 1);
        }
        
        // Calculate difference in milliseconds
        let diffMs = prayerTime.getTime() - now.getTime();
        
        // Convert to minutes (1000ms * 60s = 1 minute)
        const minutesUntil = Math.floor(diffMs / (1000 * 60));
        
        // Check if within notification window
        // For example: if window is 10 minutes, notify when between 1-10 minutes remain
        if (minutesUntil > 0 && minutesUntil <= notificationWindow) {
            // Create a unique key: prayer name + today's date
            // This ensures we only notify once per prayer per day
            const todayKey = getYYYYMMDD(now);
            const notificationKey = prayerName + "-" + todayKey;
            
            // Check if we haven't already notified for this prayer today
            if (!root.preNotifiedPrayers[notificationKey]) {
                // Send the notification
                var notification = notificationComponent.createObject(root);
                notification.title = i18n("%1 in %2 minutes", 
                    getPrayerName(root.languageIndex, prayerName), 
                    minutesUntil);
                notification.text = i18n("Prayer time reminder");
                notification.sendEvent();
                
                // Mark this prayer as notified
                root.preNotifiedPrayers[notificationKey] = true;
                
                console.log("Pre-notification sent for", prayerName, "with", minutesUntil, "minutes remaining");
            }
        }
    }
} 
    function highlightActivePrayer(currentTimingsToUse) {
        if (!currentTimingsToUse || !currentTimingsToUse.Fajr) {
            root.activePrayer = ""
            return
        }

        var newActivePrayer = ""
        let now = new Date()
        const prayerCheckOrder = ["Isha", "Maghrib", "Asr", "Dhuhr", "Sunrise", "Fajr"]
        let foundActive = false

        for (const prayer of prayerCheckOrder) {
            if (currentTimingsToUse[prayer] && currentTimingsToUse[prayer] !== "--:--" && now >= parseTime(currentTimingsToUse[prayer])) {
                newActivePrayer = prayer
                foundActive = true
                break
            }
        }

        if (!foundActive && currentTimingsToUse["Fajr"] !== "--:--") {
            newActivePrayer = "Isha"
        } else if (!foundActive) {
            newActivePrayer = ""
        }

        if (root.activePrayer !== newActivePrayer) {
            root.lastActivePrayer = root.activePrayer
            root.activePrayer = newActivePrayer

            if (root.lastActivePrayer !== "" && root.activePrayer !== "") {
                // Send notification if enabled
                if (Plasmoid.configuration.notifications) {
                    var notification = notificationComponent.createObject(root)
                    notification.title = i18n("It's %1 time", getPrayerName(root.languageIndex, root.activePrayer))
                    notification.sendEvent()
                }

                // Play adhan audio for valid prayer times (excluding Sunrise)
                if (root.activePrayer !== "Sunrise") {
                    playAdhanAudio(root.activePrayer)
                }
            }
        }
    }
    function resetPreNotifications() {
        root.preNotifiedPrayers = {};
        console.log("Pre-notification tracking reset for new day");
    }

    function getYYYYMMDD(dateObj) { let year = dateObj.getFullYear(); let month = String(dateObj.getMonth() + 1).padStart(2, '0'); let day = String(dateObj.getDate()).padStart(2, '0'); return `${year}-${month}-${day}`; }
    function getFormattedDate(givenDate) { const day = String(givenDate.getDate()).padStart(2, "0"); const month = String(givenDate.getMonth() + 1).padStart(2, "0"); const year = givenDate.getFullYear(); return `${day}-${month}-${year}`; }
    function applyOffsetToTime(timeStrHHMM, offsetMins) {
        if (!timeStrHHMM || timeStrHHMM === "--:--" || typeof offsetMins !== 'number' || offsetMins === 0) { return timeStrHHMM; }
        let parts = timeStrHHMM.split(':'); let hours = parseInt(parts[0], 10); let minutes = parseInt(parts[1], 10);
        if (isNaN(hours) || isNaN(minutes)) return timeStrHHMM;
        let totalMinutes = (hours * 60) + minutes + offsetMins;
        totalMinutes = ((totalMinutes % 1440) + 1440) % 1440;
        let finalHours = Math.floor(totalMinutes / 60); let finalMinutes = totalMinutes % 60;
        return String(finalHours).padStart(2, '0') + ":" + String(finalMinutes).padStart(2, '0');
    }

    function calculateNextPrayer() {
        const prayerData = root.displayPrayerTimes;
        if (!prayerData || !prayerData.Fajr || prayerData.Fajr === "--:--") {
            root.nextPrayerDateTime = null;
            root.timeUntilNextPrayer = "";
            root.nextPrayerNameForDisplay = i18n("N/A"); // Default text
            root.nextPrayerTimeForDisplay = "";
            return;
        }

        const prayerKeys = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha"];
        const now = new Date();
        const currentTimeStr = ("0" + now.getHours()).slice(-2) + ":" + ("0" + now.getMinutes()).slice(-2);

        let nextPrayerKey = "";
        let nextPrayerRawTime = "";

        for (const key of prayerKeys) {
            if (prayerData[key] && prayerData[key] !== "--:--" && prayerData[key] > currentTimeStr) {
                nextPrayerKey = key;
                nextPrayerRawTime = prayerData[key];
                break;
            }
        }

        if (nextPrayerKey === "" && prayerData["Fajr"] && prayerData["Fajr"] !== "--:--") {
            nextPrayerKey = "Fajr";
            nextPrayerRawTime = prayerData["Fajr"];
        } else if (nextPrayerKey === "") { // No valid prayers found at all
            root.nextPrayerDateTime = null;
            root.timeUntilNextPrayer = "";
            root.nextPrayerNameForDisplay = i18n("N/A");
            root.nextPrayerTimeForDisplay = "";
            return;
        }

        // Set the properties needed for display
        root.nextPrayerNameForDisplay = getPrayerName(root.languageIndex, nextPrayerKey);
        root.nextPrayerTimeForDisplay = to12HourTime(nextPrayerRawTime, Plasmoid.configuration.hourFormat);

        let nextPrayerDateObj = parseTime(nextPrayerRawTime);
        if (nextPrayerDateObj) {
            if (nextPrayerKey === "Fajr" && now > nextPrayerDateObj) {
                nextPrayerDateObj.setDate(nextPrayerDateObj.getDate() + 1);
            }
            root.nextPrayerDateTime = nextPrayerDateObj;
        } else {
            root.nextPrayerDateTime = null;
        }
    }

    function processRawTimesAndApplyOffsets() {
        const defaultTimesStructure = { Fajr: "--:--", Sunrise: "--:--", Dhuhr: "--:--", Asr: "--:--", Maghrib: "--:--", Isha: "--:--", apiGregorianDate: getFormattedDate(new Date()) };
        if (!root.times || Object.keys(root.times).length === 0 || !root.times.Fajr) {
            root.displayPrayerTimes = {defaultTimesStructure, apiGregorianDate: (root.times && root.times.apiGregorianDate) || defaultTimesStructure.apiGregorianDate };
        } else {
            let newDisplayTimes = {};
            const prayerKeys = ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"];
            for (const key of prayerKeys) {
                let offset = Plasmoid.configuration[key.toLowerCase() + "OffsetMinutes"] || 0;
                newDisplayTimes[key] = root.times[key] ? applyOffsetToTime(root.times[key], offset) : "--:--";
            }
            if (root.times.apiGregorianDate) {
                newDisplayTimes.apiGregorianDate = root.times.apiGregorianDate;
            }
            root.displayPrayerTimes = newDisplayTimes;
        }
        root.highlightActivePrayer(root.displayPrayerTimes);
        // Call the new calculation after prayer times are processed
        calculateNextPrayer();
    }

    function _setProcessedHijriData(hijriDataObject) {
        if (!hijriDataObject || !hijriDataObject.month) {
            root.hijriDateDisplay = i18n("Date unavailable");
            root.currentHijriDay = 0; root.currentHijriMonth = 0; root.currentHijriYear = 0;
        } else {
            root.currentHijriDay = parseInt(hijriDataObject.day, 10);
            root.currentHijriMonth = parseInt(hijriDataObject.month.number, 10);
            root.currentHijriYear = parseInt(hijriDataObject.year, 10);
            let monthNameToDisplay = (root.languageIndex === 1) ? hijriDataObject.month.ar : hijriDataObject.month.en;
            root.hijriDateDisplay = `${root.currentHijriDay} ${monthNameToDisplay} ${root.currentHijriYear}`;
        }
        updateSpecialIslamicDateMessage();
    }

    function updateSpecialIslamicDateMessage() {
        let day = root.currentHijriDay;
        let month = root.currentHijriMonth;
        let message = "";
        if (month === 0 || day === 0) { root.specialIslamicDateMessage = ""; return; }
        if (month === 9) { message = (root.languageIndex === 1) ? "شهر رمضان" : "Month of Ramadan"; }
        else if (month === 10 && day === 1) { message = (root.languageIndex === 1) ? "عيد الفطر" : "Eid al-Fitr"; }
        else if (month === 12) {
            if (day >= 1 && day <= 10) { message = (root.languageIndex === 1) ? "العشر الأوائل من ذي الحجة" : "First 10 Days of Dhu al-Hijjah";
                if (day === 9) { message = (root.languageIndex === 1) ? "يوم عرفة" : "Day of Arafah"; }
                if (day === 10) { message = (root.languageIndex === 1) ? "عيد الأضحى" : "Eid al-Adha"; }
            } else if (day >= 11 && day <= 13) { message = (root.languageIndex === 1) ? "أيام التشريق" : "Days of Tashreeq"; }
        }
        else if (month === 1 && day === 1) { message = (root.languageIndex === 1) ? "رأس السنة الهجرية" : "Islamic New Year"; }
        else if (month === 1 && day === 10) { message = (root.languageIndex === 1) ? "يوم عاشوراء" : "Day of Ashura"; }
        if (message === "") { if (day === 13 || day === 14 || day === 15) { message = (root.languageIndex === 1) ? "الأيام البيض" : "Ayyām al-Bīḍ (The White Days)"; } }
        root.specialIslamicDateMessage = message;
    }

    function fetchTimes() {
        let todayForAPI = getFormattedDate(new Date());
        let URL = "";

        if (root.useCoordinates && root.latitude && root.longitude) {
            // Use coordinates API endpoint
            URL = `https://api.aladhan.com/v1/timings/${todayForAPI}?latitude=${encodeURIComponent(root.latitude)}&longitude=${encodeURIComponent(root.longitude)}&method=${Plasmoid.configuration.method || 4}&school=${Plasmoid.configuration.school || 0}`;
            console.log("Fetching prayer times using coordinates:", root.latitude, root.longitude);
        } else {
            // Use city/country API endpoint (fallback or default)
            URL = `https://api.aladhan.com/v1/timingsByCity/${todayForAPI}?city=${encodeURIComponent(Plasmoid.configuration.city || "Makkah")}&country=${encodeURIComponent(Plasmoid.configuration.country || "Saudi Arabia")}&method=${Plasmoid.configuration.method || 4}&school=${Plasmoid.configuration.school || 0}`;
            console.log("Fetching prayer times using city/country:", Plasmoid.configuration.city, Plasmoid.configuration.country);
        }

        let xhr = new XMLHttpRequest();
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    let responseData = JSON.parse(xhr.responseText).data;
                    root.times = responseData.timings;
                    root.times.apiGregorianDate = responseData.date.gregorian.date;
                    root.rawHijriDataFromApi = responseData.date.hijri;
                    resetPreNotifications();
                    processRawTimesAndApplyOffsets();
                    let offset = Plasmoid.configuration.hijriOffset || 0;
                    if (offset !== 0) {
                        let parts = responseData.date.gregorian.date.split('-');
                        let originalJsDate = new Date(parseInt(parts[2]), parseInt(parts[1]) - 1, parseInt(parts[0]));
                        originalJsDate.setDate(originalJsDate.getDate() + offset);
                        let adjustedGregorianDateStr = getFormattedDate(originalJsDate);
                        let hijriApiURL = `https://api.aladhan.com/v1/gToH?date=${adjustedGregorianDateStr}`;
                        let hijriXhrNested = new XMLHttpRequest();
                        hijriXhrNested.onreadystatechange = function() {
                            if (hijriXhrNested.readyState === 4) {
                                if (hijriXhrNested.status === 200) {
                                    _setProcessedHijriData(JSON.parse(hijriXhrNested.responseText).data.hijri);
                                } else { _setProcessedHijriData(root.rawHijriDataFromApi); }
                            }
                        };
                        hijriXhrNested.open("GET", hijriApiURL, true);
                        hijriXhrNested.send();
                    } else {
                        _setProcessedHijriData(root.rawHijriDataFromApi);
                    }
                    update5DayCache();
                } else {
                    loadFromCache();
                }
            }
        };
        xhr.open("GET", URL, true);
        xhr.send();
    }

    function saveTodayToCache() {
        if (!root.times || !root.times.Fajr || !root.rawHijriDataFromApi) { return; }
        let todayKey = getYYYYMMDD(new Date());
        let cleanTimings = {};
        const prayerKeysToSave = ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"];
        prayerKeysToSave.forEach(function(pKey) { if (root.times[pKey]) cleanTimings[pKey] = root.times[pKey]; });
        if (Object.keys(cleanTimings).length === 0) return;
        let updatedCache = cachedData
        updatedCache[todayKey] = {
            timings: cleanTimings,
            hijri: root.rawHijriDataFromApi
        };
        cacheSettings.cacheData = JSON.stringify(updatedCache)
    }

    function update5DayCache() {
        const now = new Date();
        const cacheKey = "last_5day_update";
        const lastUpdate = Number(cachedData[cacheKey] || 0);
        const daysSinceUpdate = (now.getTime() - lastUpdate) / (1000 * 60 * 60 * 24);

        if (daysSinceUpdate >= 5 || Object.keys(cachedData).length <= 1) {
            const year = now.getFullYear();
            const month = now.getMonth() + 1;

            // Ensure defaults so we never pass 'undefined' to the API
            const method = (Plasmoid.configuration.method !== undefined) ? Plasmoid.configuration.method : 4;
            const school = (Plasmoid.configuration.school !== undefined) ? Plasmoid.configuration.school : 0;

            let URL = "";
            if (root.useCoordinates && root.latitude && root.longitude) {
                // Use coordinates for monthly cache
                URL = `https://api.aladhan.com/v1/calendar/${year}/${month}` +
                `?latitude=${encodeURIComponent(root.latitude)}` +
                `&longitude=${encodeURIComponent(root.longitude)}` +
                `&method=${method}&school=${school}`;
            } else {
                // Use city/country for monthly cache
                if (!Plasmoid.configuration.city || !Plasmoid.configuration.country) {
                    // we still save today's data below
                    saveTodayToCache();
                    return;
                }
                URL = `https://api.aladhan.com/v1/calendarByCity/${year}/${month}` +
                `?city=${encodeURIComponent(Plasmoid.configuration.city)}` +
                `&country=${encodeURIComponent(Plasmoid.configuration.country)}` +
                `&method=${method}&school=${school}`;
            }

            const xhr = new XMLHttpRequest();
            xhr.onreadystatechange = function() {
                if (xhr.readyState === 4) {
                    if (xhr.status === 200) {
                        try {
                            const monthlyData = JSON.parse(xhr.responseText).data;
                            if (monthlyData && monthlyData.length > 0) {
                                // clone to avoid mutating the binding object in place
                                const updatedCache = Object.assign({}, cachedData);

                                for (let i = 0; i < monthlyData.length; i++) {
                                    const dayData = monthlyData[i];
                                    if (!dayData || !dayData.date || !dayData.date.gregorian ||
                                        !dayData.date.hijri || !dayData.timings) continue;

                                    const gregorianApiDate = dayData.date.gregorian.date; // "DD-MM-YYYY"
                                    const parts = gregorianApiDate.split('-');
                                    if (parts.length !== 3) continue;

                                    const dateKey = `${parts[2]}-${parts[1]}-${parts[0]}`; // "YYYY-MM-DD"

                                    const cleanTimings = {};
                                    const prayerKeysToSave = ["Fajr", "Sunrise", "Dhuhr", "Asr", "Maghrib", "Isha"];
                                    for (const pKey of prayerKeysToSave) {
                                        if (dayData.timings[pKey]) cleanTimings[pKey] = dayData.timings[pKey];
                                    }

                                    if (Object.keys(cleanTimings).length > 0) {
                                        updatedCache[dateKey] = {
                                            timings: cleanTimings,
                                            hijri: dayData.date.hijri
                                        };
                                    }
                                }
                                // Record the update moment inside the cache object so the next run sees it
                                updatedCache[cacheKey] = now.getTime();
                                cacheSettings.cacheData = JSON.stringify(updatedCache);
                                cacheSettings.lastCacheUpdate = now.getTime();
                            }
                        } catch (e) {
                            console.log("Monthly cache parse error:", e.toString());
                        }
                    } else {
                        console.log("Monthly cache request failed with status:", xhr.status);
                    }
                }
            };
            xhr.open("GET", URL, true);
            xhr.send();
        }

        saveTodayToCache();
    }

    function loadFromCache() {
        const todayKey = getYYYYMMDD(new Date());
        let loaded = false;

        if (cachedData[todayKey]) {
            try {
                const cachedEntry = cachedData[todayKey];
                root.times = cachedEntry.timings;
                root.times.apiGregorianDate = getFormattedDate(new Date());
                const hijriDataFromCache = cachedEntry.hijri;

                processRawTimesAndApplyOffsets();
                _setProcessedHijriData(hijriDataFromCache);

                loaded = true;
            } catch (err) {
                console.log("Error loading from cache:", err.toString());
            }
        }

        if (!loaded) {
            root.times = {};
            processRawTimesAndApplyOffsets();
            root.hijriDateDisplay = i18n("Offline - No data");
            root.specialIslamicDateMessage = "";
        }
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
                if (key === "useCoordinates") {
                    root.useCoordinates = Plasmoid.configuration.useCoordinates || false
                } else if (key === "latitude") {
                    root.latitude = Plasmoid.configuration.latitude || ""
                } else if (key === "longitude") {
                    root.longitude = Plasmoid.configuration.longitude || ""
                }
                fetchTimes()
                } else if (key === "adhanAudioPath") {
                    root.adhanAudioPath = Plasmoid.configuration.adhanAudioPath || ""
                } else if (key === "adhanPlaybackMode") {
                    root.adhanPlaybackMode = Plasmoid.configuration.adhanPlaybackMode || 0
                } else if (key === "adhanVolume") {
                    root.adhanVolume = Plasmoid.configuration.adhanVolume || 0.7
                } else if (key.startsWith("playAdhanFor")) {
                    // Update individual prayer adhan settings
                    switch(key) {
                        case "playAdhanForFajr":
                            root.playAdhanForFajr = Plasmoid.configuration.playAdhanForFajr
                            break
                        case "playAdhanForDhuhr":
                            root.playAdhanForDhuhr = Plasmoid.configuration.playAdhanForDhuhr
                            break
                        case "playAdhanForAsr":
                            root.playAdhanForAsr = Plasmoid.configuration.playAdhanForAsr
                            break
                        case "playAdhanForMaghrib":
                            root.playAdhanForMaghrib = Plasmoid.configuration.playAdhanForMaghrib
                            break
                        case "playAdhanFo   rIsha":
                            root.playAdhanForIsha = Plasmoid.configuration.playAdhanForIsha
                            break
                    }
                }
        })
    }

    // --- REPRESENTATIONS ---
    preferredRepresentation: isSmall ? compactRepresentation : fullRepresentation
    compactRepresentation: CompactRepresentation {
        nextPrayerName: root.nextPrayerNameForDisplay
        nextPrayerTime: root.nextPrayerTimeForDisplay
        countdownText: root.timeUntilNextPrayer
        isPrePrayerAlertActive: false // The compact view will calculate its own alert now

        // Pass essential system settings
        plasmoidItem: root
        languageIndex: root.languageIndex
        hourFormat: Plasmoid.configuration.hourFormat
        compactStyle: Plasmoid.configuration.compactStyle || 0
    }

    fullRepresentation: Kirigami.Page {
        id: fullView
        background: Rectangle { color: "transparent" }
        onVisibleChanged: {
            if (visible && Object.keys(root.displayPrayerTimes).length > 0) {
                root.highlightActivePrayer(root.displayPrayerTimes);
            }
        }
        implicitWidth: Kirigami.Units.gridUnit * 22
        Column {
            width: parent.width; padding: Kirigami.Units.largeSpacing; spacing: Kirigami.Units.smallSpacing; anchors.centerIn: parent
            Label { id: arabicPhraseLabel; text: "{صّلِ عَلۓِ مُحَمد ﷺ}"; font.pointSize: Kirigami.Theme.defaultFont.pointSize + 1; font.weight: Font.Bold; wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter; anchors.horizontalCenter: parent.horizontalCenter; }
            Label { id: hijriDateLabel; text: root.hijriDateDisplay; font.pointSize: Kirigami.Theme.defaultFont.pointSize; font.weight: Font.Bold; opacity: 0.9; anchors.horizontalCenter: parent.horizontalCenter }
            Label { id: specialDateMessageLabel; text: root.specialIslamicDateMessage; visible: root.specialIslamicDateMessage !== ""; font.pointSize: Kirigami.Theme.smallFont.pointSize; font.italic: true; opacity: 0.85; anchors.horizontalCenter: parent.horizontalCenter; wrapMode: Text.WordWrap; horizontalAlignment: Text.AlignHCenter; }

            // NEW Label for the countdown
            Label {
                id: countdownLabel
                text: {
                    if (!root.timeUntilNextPrayer) return "";
                    if (root.languageIndex === 1) { // Arabic
                        return i18n("الوقت المتبقي على الصلاة : %1", root.timeUntilNextPrayer);
                    } else { // English
                        return i18n("Time until next prayer: %1", root.timeUntilNextPrayer);
                    }
                }

                visible: root.timeUntilNextPrayer !== "" && root.timeUntilNextPrayer !== i18n("Prayer time!")
                font.pointSize: Kirigami.Theme.smallFont.pointSize
                font.weight: Font.Bold
                opacity: 0.95
                color: Kirigami.Theme.textColor
                anchors.horizontalCenter: parent.horizontalCenter
            }
            PlasmaComponents.MenuSeparator { width: parent.width; topPadding: Kirigami.Units.moderateSpacing; bottomPadding: Kirigami.Units.smallSpacing }

            Rectangle { width: parent.width; height: Kirigami.Units.gridUnit * 2.0; radius: 8; color: root.activePrayer === 'Fajr' ? Kirigami.Theme.highlightColor : "transparent"; RowLayout { anchors.fill: parent; anchors.leftMargin: Kirigami.Units.largeSpacing; anchors.rightMargin: Kirigami.Units.largeSpacing; Label { text: getPrayerName(root.languageIndex, "Fajr"); color: parent.parent.color === Kirigami.Theme.highlightColor ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor; font.weight: Font.Bold; font.pointSize: Kirigami.Theme.defaultFont.pointSize } Item { Layout.fillWidth: true } Label { text: root.to12HourTime(root.displayPrayerTimes.Fajr, Plasmoid.configuration.hourFormat); color: parent.parent.color === Kirigami.Theme.highlightColor ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor; font.pointSize: Kirigami.Theme.defaultFont.pointSize } } }
            Rectangle { width: parent.width; height: Kirigami.Units.gridUnit * 2.0; radius: 8; color: root.activePrayer === 'Sunrise' ? Kirigami.Theme.highlightColor : "transparent"; RowLayout { anchors.fill: parent; anchors.leftMargin: Kirigami.Units.largeSpacing; anchors.rightMargin: Kirigami.Units.largeSpacing; Label { text: getPrayerName(root.languageIndex, "Sunrise"); color: parent.parent.color === Kirigami.Theme.highlightColor ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor; font.weight: Font.Bold; font.pointSize: Kirigami.Theme.defaultFont.pointSize } Item { Layout.fillWidth: true } Label { text: root.to12HourTime(root.displayPrayerTimes.Sunrise, Plasmoid.configuration.hourFormat); color: parent.parent.color === Kirigami.Theme.highlightColor ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor; font.pointSize: Kirigami.Theme.defaultFont.pointSize } } }
            Rectangle { width: parent.width; height: Kirigami.Units.gridUnit * 2.0; radius: 8; color: root.activePrayer === 'Dhuhr' ? Kirigami.Theme.highlightColor : "transparent"; RowLayout { anchors.fill: parent; anchors.leftMargin: Kirigami.Units.largeSpacing; anchors.rightMargin: Kirigami.Units.largeSpacing; Label { text: getPrayerName(root.languageIndex, "Dhuhr"); color: parent.parent.color === Kirigami.Theme.highlightColor ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor; font.weight: Font.Bold; font.pointSize: Kirigami.Theme.defaultFont.pointSize } Item { Layout.fillWidth: true } Label { text: root.to12HourTime(root.displayPrayerTimes.Dhuhr, Plasmoid.configuration.hourFormat); color: parent.parent.color === Kirigami.Theme.highlightColor ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor; font.pointSize: Kirigami.Theme.defaultFont.pointSize } } }
            Rectangle { width: parent.width; height: Kirigami.Units.gridUnit * 2.0; radius: 8; color: root.activePrayer === 'Asr' ? Kirigami.Theme.highlightColor : "transparent"; RowLayout { anchors.fill: parent; anchors.leftMargin: Kirigami.Units.largeSpacing; anchors.rightMargin: Kirigami.Units.largeSpacing; Label { text: getPrayerName(root.languageIndex, "Asr"); color: parent.parent.color === Kirigami.Theme.highlightColor ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor; font.weight: Font.Bold; font.pointSize: Kirigami.Theme.defaultFont.pointSize } Item { Layout.fillWidth: true } Label { text: root.to12HourTime(root.displayPrayerTimes.Asr, Plasmoid.configuration.hourFormat); color: parent.parent.color === Kirigami.Theme.highlightColor ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor; font.pointSize: Kirigami.Theme.defaultFont.pointSize } } }
            Rectangle { width: parent.width; height: Kirigami.Units.gridUnit * 2.0; radius: 8; color: root.activePrayer === 'Maghrib' ? Kirigami.Theme.highlightColor : "transparent"; RowLayout { anchors.fill: parent; anchors.leftMargin: Kirigami.Units.largeSpacing; anchors.rightMargin: Kirigami.Units.largeSpacing; Label { text: getPrayerName(root.languageIndex, "Maghrib"); color: parent.parent.color === Kirigami.Theme.highlightColor ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor; font.weight: Font.Bold; font.pointSize: Kirigami.Theme.defaultFont.pointSize } Item { Layout.fillWidth: true } Label { text: root.to12HourTime(root.displayPrayerTimes.Maghrib, Plasmoid.configuration.hourFormat); color: parent.parent.color === Kirigami.Theme.highlightColor ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor; font.pointSize: Kirigami.Theme.defaultFont.pointSize } } }
            Rectangle { width: parent.width; height: Kirigami.Units.gridUnit * 2.0; radius: 8; color: root.activePrayer === 'Isha' ? Kirigami.Theme.highlightColor : "transparent"; RowLayout { anchors.fill: parent; anchors.leftMargin: Kirigami.Units.largeSpacing; anchors.rightMargin: Kirigami.Units.largeSpacing; Label { text: getPrayerName(root.languageIndex, "Isha"); color: parent.parent.color === Kirigami.Theme.highlightColor ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor; font.weight: Font.Bold; font.pointSize: Kirigami.Theme.defaultFont.pointSize } Item { Layout.fillWidth: true } Label { text: root.to12HourTime(root.displayPrayerTimes.Isha, Plasmoid.configuration.hourFormat); color: parent.parent.color === Kirigami.Theme.highlightColor ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor; font.pointSize: Kirigami.Theme.defaultFont.pointSize } } }

            PlasmaComponents.MenuSeparator { width: parent.width; topPadding: Kirigami.Units.smallSpacing; bottomPadding: Kirigami.Units.smallSpacing }
            Button { anchors.horizontalCenter: parent.horizontalCenter; text: i18n("Refresh times"); onClicked: root.fetchTimes() }
        }
    }
}
