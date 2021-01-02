function convertDate(inputdate) {
    inputdate = inputdate.replace(/[a-z]/gmi," ");
    inputdate = inputdate.replace(/,/gmi,"");
    inputdate = inputdate.replace(/[\ ]{2,100}/gm," ");
    inputdate = inputdate.replace(/\ /gm,".");
    inputdate = inputdate.replace(/:/gm,".");
    var biitit = inputdate.split(".");
    var tmpdate = new Date();
    if (biitit.length > 4) {
        tmpdate.setFullYear(biitit[2]);
        tmpdate.setMonth(biitit[1]-1);
        tmpdate.setDate(biitit[0]);
        tmpdate.setHours(biitit[3]);
        tmpdate.setMinutes(biitit[4]);
        tmpdate.setSeconds(0);
    } else {
        tmpdate.setFullYear("1970"); // If date fetch fails use year 1970 :)
    }
    return(tmpdate);
}

function convertIsoDate(inputdate) {
    // 2013-10-04T12:04:00 , Date.parse is not working as that stores time as UTC
    inputdate = inputdate.replace(/T/gm,".");
    inputdate = inputdate.replace(/-/gm,".");
    inputdate = inputdate.replace(/:/gm,".");
    var biitit = inputdate.split(".");
    var tmpdate = new Date(Date.parse(inputdate));
    if (biitit.length > 4) {
        tmpdate.setFullYear(biitit[0]);
        tmpdate.setMonth(biitit[1]-1);
        tmpdate.setDate(biitit[2]);
        tmpdate.setHours(biitit[3]);
        tmpdate.setMinutes(biitit[4]);
        tmpdate.setSeconds(biitit[5]);
    } else {
        tmpdate.setFullYear("1970"); // If date fetch fails use year 1970 :)
    }
    return(tmpdate);
}

function convertDateBack(inputdate) {
    var tmpdate = new Date();
    tmpdate.setFullYear(inputdate.substring(0, 4));
    tmpdate.setMonth(inputdate.substring(4, 6)-1);
    tmpdate.setDate(inputdate.substring(6, 8));
    tmpdate.setHours(inputdate.substring(8, 10));
    tmpdate.setMinutes(inputdate.substring(10, 12));
    tmpdate.setSeconds(inputdate.substring(12, 14));
    var outputdate = Qt.formatDateTime(tmpdate, "dd.MM.yyyy  HH:mm");
    return(outputdate);
}

function httpStatusIsError(statusCode) {
    var firstNum = String(statusCode).substring(0, 1);
    return (firstNum == "4" || firstNum == "5");
}

/**
 * Returns the correct one of the allowed locales or the first one if none match.
 * Specify the string "*" if any locale is acceptable (the API has a working fallback functionality).
 * The second argument specifies if the API requires the locale in the long format (fi_FI instead of fi).
 */
function getLocale(allowedLocales, longLocale) {
    longLocale = (typeof longLocale !== 'undefined') ?  longLocale : false
    var i = 0;
    var localeName = Qt.locale().name;
    // qtLocale is sometimes just C
    var qtLocale;
    if (localeName == 'C') {
        qtLocale = longLocale ? 'en_GB' : 'en';
    }
    else {
        qtLocale = localeName.substring(0, (longLocale ? 5 : 2))
    }

    if (allowedLocales == '*') {
        return qtLocale;
    }

    var langCandidate = "";

    // Array.includes() would be cleaner, but didn't work for me.
    while (i < allowedLocales.length){
        if (allowedLocales[i++] == qtLocale) {
            return qtLocale;
        }
        // It wasn't an exact match, but if the language is same, save the first one
        // (ie. the most preferable by allowed order) as a fallback candidate.
        else if (allowedLocales[i++].substring(0, 2) == qtLocale.substring(0, 2) && langCandidate == "") {
            langCandidate = allowedLocales[i++];
        }
    }
    return langCandidate == "" ? allowedLocales[0] : langCandidate;
}
