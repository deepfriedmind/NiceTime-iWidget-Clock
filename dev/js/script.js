(function(window, document, undefined){
    var oldMins = void 0,
        timeEl = document.getElementById('timeface'),
        h24 = (window.h24 ? true : false),
        cssStyles = [
            'color:' + (window.color ? '#' + window.color : '#fff'),
            'opacity:' + (window.opacity ? parseFloat(window.opacity, 10) : 1),
            'font-family:' + (window.fontFamily ? window.fontFamily : 'AppleSDGothicNeo-Thin'),
            'font-size:' + (window.fontSize ? parseInt(window.fontSize, 10) : 84)
        ];

    timeEl.style.cssText = cssStyles.join(';');

    if (!h24) {
        timeEl.childNodes[1].style.display = 'inline';
    }

    var setTime = function() {
        var dateObj = new Date(),
            currentHrs = dateObj.getHours(),
            currentMins = dateObj.getMinutes(),
            AMPM = (currentHrs < 12) ? 'AM' : 'PM',
            currentMinStr,
            currentHrsStr,
            timeStr;

        if (currentMins === oldMins) {
            setTimeout(setTime, 1000);
            return false;
        }

        oldMins = currentMins;

        if (!h24) {
            currentHrs = ( currentHrs > 12 ) ? currentHrs - 12 : currentHrs;
            currentHrs = ( currentHrs === 0 ) ? 12 : currentHrs;
        }

        currentHrs = ( currentHrs < 10 ? '0' : '' ) + currentHrs;
        currentMins = ( currentMins < 10 ? '0' : '' ) + currentMins;

        currentMinStr = currentMins.toString();
        currentHrsStr = currentHrs.toString();

        currentMinStr = currentMinStr.split('');
        currentHrsStr = currentHrsStr.split('');

        timeStr = currentHrsStr[0] + currentHrsStr[1] + ':' + currentMinStr[0] + currentMinStr[1];

        timeEl.firstChild.nodeValue = timeStr;

        if (!h24) {
            timeEl.childNodes[1].firstChild.nodeValue = AMPM;
        }

        return setTimeout(setTime, 1000);
    };

    return setTime();
}(this, document));
