.pragma library

const surahData = [
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
];

const quranReciterIdentifiers = [
    "ar.minshawi", "ar.alafasy", "ar.husary", "ar.abdurrahmaansudais",
    "ar.mahermuaiqly", "ar.shaatree", "ar.abdullahbasfar",
    "ar.abdulbasitmurattal", "ar.hudhaify", "ar.muhammadjibreel",
    "ar.husarymujawwad", "ar.minshawimujawwad", "ar.ahmedajamy"
];

const quranReciterNames = [
    "Minshawi (Murattal)", "Alafasy", "Husary (Murattal)",
    "Abdurrahmaan As-Sudais", "Maher Al Muaiqly", "Abu Bakr Ash-Shaatree",
    "Abdullah Basfar", "Abdulbasit (Murattal)", "Hudhaify", "Muhammad Jibreel",
    "Husary (Mujawwad)", "Minshawi (Mujawwad)", "Ahmed ibn Ali al-Ajamy"
];

const quranReciterNames_ar = [
    "المنشاوي (مرتل)", "العفاسي", "الحصري (مرتل)", "عبد الرحمن السديس",
    "ماهر المعيقلي", "أبو بكر الشاطري", "عبد الله بصفر", "عبد الباسط (مرتل)",
    "الحذيفي", "محمد جبريل",
    "الحصري (مجود)", "المنشاوي (مجود)", "أحمد بن علي العجمي"
];

const prayerEmojis = {
    "Fajr": "🕰️",
    "Sunrise": "🌅",
    "Dhuhr": "☀️",
    "Asr": "🌇",
    "Maghrib": "🌆",
    "Isha": "🌙"
};

const everyAyahFolders = {
    "ar.minshawi": "Minshawy_Murattal_128kbps",
    "ar.alafasy": "Alafasy_128kbps",
    "ar.husary": "Husary_128kbps",
    "ar.abdurrahmaansudais": "Abdurrahmaan_As-Sudais_192kbps",
    "ar.mahermuaiqly": "MaherAlMuaiqly128kbps",
    "ar.shaatree": "Abu_Bakr_Ash-Shaatree_128kbps",
    "ar.abdullahbasfar": "Abdullah_Basfar_192kbps",
    "ar.abdulbasitmurattal": "Abdul_Basit_Murattal_192kbps",
    "ar.hudhaify": "Hudhaify_128kbps",
    "ar.muhammadjibreel": "Muhammad_Jibreel_128kbps",
    "ar.husarymujawwad": "Husary_128kbps_Mujawwad",
    "ar.minshawimujawwad": "Minshawy_Mujawwad_192kbps",
    "ar.ahmedajamy": "ahmed_ibn_ali_al_ajamy_128kbps"
};
