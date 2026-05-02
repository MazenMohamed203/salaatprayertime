.pragma library

// Mathematical Offline Prayer Time Calculator
// Based on standard astronomical algorithms to serve as a fallback when no internet is available.

function getTimes(date, lat, lng, timeZone, methodIndex, asrSchool) {
    lat = parseFloat(lat); lng = parseFloat(lng);
    // AlAdhan Method Mapping (Angles for Fajr and Isha)
    var methods = {
        0: {fajr: 18.0, isha: 17.0}, // Shia Ithna-Ashari (Jafari)
        1: {fajr: 15.0, isha: 15.0}, // Univ. of Islamic Sciences, Karachi
        2: {fajr: 18.0, isha: 18.0}, // ISNA
        3: {fajr: 18.0, isha: 17.0}, // Muslim World League (MWL)
        4: {fajr: 18.5, isha: 90.0}, // Umm Al-Qura
        5: {fajr: 19.5, isha: 17.5}, // Egyptian General
        7: {fajr: 18.0, isha: 18.0}, // Institute of Geophysics, U. of Tehran
        8: {fajr: 18.0, isha: 17.5}, // Gulf
        9: {fajr: 18.0, isha: 18.0}, // Kuwait
        10: {fajr: 18.0, isha: 18.0}, // Qatar
        11: {fajr: 18.0, isha: 18.0}, // Majlis Ugama Islam Singapura
        12: {fajr: 18.0, isha: 18.0}, // Union Organization
        13: {fajr: 18.0, isha: 17.0}, // Diyanet
        14: {fajr: 18.0, isha: 18.0}  // Spiritual Admin of Muslims of Russia
    };
    var m = methods[methodIndex] || methods[3];

    // Math Helpers
    var dtr = function(d) { return (d * Math.PI) / 180.0; };
    var rtd = function(r) { return (r * 180.0) / Math.PI; };
    var sin = function(d) { return Math.sin(dtr(d)); };
    var cos = function(d) { return Math.cos(dtr(d)); };
    var tan = function(d) { return Math.tan(dtr(d)); };
    var arcsin = function(d) { return rtd(Math.asin(d)); };
    var arccos = function(d) { return rtd(Math.acos(d)); };
    var arccot = function(x) { return rtd(Math.atan(1.0 / x)); };
    var fixangle = function(a) { a = a - 360.0 * Math.floor(a / 360.0); return a < 0 ? a + 360.0 : a; };
    var fixhour = function(a) { a = a - 24.0 * Math.floor(a / 24.0); return a < 0 ? a + 24.0 : a; };

    // Julian Date
    var JDate = function(year, month, day) {
        if (month <= 2) { year -= 1; month += 12; }
        var A = Math.floor(year / 100);
        var B = 2 - A + Math.floor(A / 4);
        var JD = Math.floor(365.25 * (year + 4716)) + Math.floor(30.6001 * (month + 1)) + day + B - 1524.5;
        return JD;
    };

    var jd = JDate(date.getFullYear(), date.getMonth() + 1, date.getDate()) - lng / (15 * 24);

    // Solar Position
    var sunPosition = function(jd) {
        var D = jd - 2451545.0;
        var g = fixangle(357.529 + 0.98560028 * D);
        var q = fixangle(280.459 + 0.98564736 * D);
        var L = fixangle(q + 1.915 * sin(g) + 0.020 * sin(2 * g));
        var e = 23.439 - 0.00000036 * D;
        var d = arcsin(sin(e) * sin(L));
        var RA = arccos(cos(L) / cos(d));
        RA = fixangle(RA);
        if (sin(L) < 0) RA = 360.0 - RA;
        var eqt = q / 15.0 - RA / 15.0;
        return { declination: d, equation: eqt };
    };

    var eqt = sunPosition(jd).equation;

    // Time calculations
    var computeTime = function(G, t) {
        var D = sunPosition(jd + t).declination;
        var Z = fixangle(arccos((sin(G) - sin(lat) * sin(D)) / (cos(lat) * cos(D))));
        return Z / 15.0;
    };

    var midDay = fixhour(12 - eqt - lng / 15.0);

    var sunrise = midDay - computeTime(-0.833, -0.25);
    var sunset = midDay + computeTime(-0.833, 0.25);
    var fajr = midDay - computeTime(-m.fajr, -0.3);
    var isha = midDay + computeTime(-m.isha, 0.3);

    var asrFactor = asrSchool === 1 ? 2 : 1;
    var asrAlt = arccot(asrFactor + tan(Math.abs(lat - sunPosition(jd + 0.1).declination)));
    var asr = midDay + computeTime(asrAlt, 0.1);

    // Formatting
    var formatTime = function(timeStr) {
        if (isNaN(timeStr)) return "--:--";
        timeStr = fixhour(timeStr + timeZone);
        var hours = Math.floor(timeStr);
        var minutes = Math.floor((timeStr - hours) * 60 + 0.5);
        if (minutes >= 60) { hours += 1; minutes -= 60; }
        return String(fixhour(hours)).padStart(2, '0') + ":" + String(minutes).padStart(2, '0');
    };

    // Special handler for Umm Al-Qura Isha (90 mins after Maghrib)
    var finalIsha = m.isha === 90 ? formatTime(sunset + (90/60)) : formatTime(isha);

    return {
        Fajr: formatTime(fajr),
        Sunrise: formatTime(sunrise),
        Dhuhr: formatTime(midDay),
        Asr: formatTime(asr),
        Maghrib: formatTime(sunset),
        Isha: finalIsha
    };
}

function getHijriDate(date, adjustment) {
    var day = date.getDate();
    var month = date.getMonth() + 1; // 1-12
    var year = date.getFullYear();

    var m = month;
    var y = year;
    if (m < 3) {
        y -= 1;
        m += 12;
    }
    
    var a = Math.floor(y / 100);
    var b = 2 - a + Math.floor(a / 4);
    if (y < 1583) b = 0;
    if (y === 1582) {
        if (m > 10) b = -10;
        if (m === 10) {
            b = 0;
            if (day > 4) b = -10;
        }
    }
    
    var jd = Math.floor(365.25 * (y + 4716)) + Math.floor(30.6001 * (m + 1)) + day + b - 1524;
    jd += Math.floor(adjustment || 0) - 1; // Internal -1 day offset

    b = 0;
    if (jd > 2299160) {
        a = Math.floor((jd - 1867216.25) / 36524.25);
        b = 1 + a - Math.floor(a / 4);
    }
    var bb = jd + b + 1524;
    var cc = Math.floor((bb - 122.1) / 365.25);
    var dd = Math.floor(365.25 * cc);
    var ee = Math.floor((bb - dd) / 30.6001);
    
    day = bb - dd - Math.floor(30.6001 * ee);
    month = ee - 1;
    if (ee > 13) {
        cc += 1;
        month = ee - 13;
    }
    year = cc - 4716;

    var iyear = 10631.0 / 30.0;
    var epochastro = 1948084;
    var shift1 = 8.01 / 60.0;
    var z = jd - epochastro;
    var cyc = Math.floor(z / 10631.0);
    z = z - 10631 * cyc;
    var j = Math.floor((z - shift1) / iyear);
    var iy = 30 * cyc + j;
    z = z - Math.floor(j * iyear + shift1);
    var im = Math.floor((z + 28.5001) / 29.5);
    if (im === 13) im = 12;
    var id = z - Math.floor(29.5001 * im - 29);
    
    return { day: Math.floor(id), month: Math.floor(im), year: Math.floor(iy) };
}
