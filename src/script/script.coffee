do (window = this, document) ->
    oldMins = undefined
    timeEl = document.getElementById 'timeface'
    opts =
        h24: (if window.h24 then true else false)
        showampm: (if window.showampm then true else false)
        cssStyles: [
            'color:' + if window.color then "##{window.color}" else '#fff'
            'opacity:' + if window.opacity then parseFloat(window.opacity, 10) else 1
            'font-family:' + if window.fontFamily then window.fontFamily else 'AppleSDGothicNeo-Thin'
            'font-size:' + if window.fontSize then parseInt(window.fontSize, 10) else 84
        ]

    console.log 'opts: ', JSON.stringify(opts, null, '\t')

    timeEl.style.cssText = opts.cssStyles.join ';'
    timeEl.childNodes[1].style.display = 'inline' if not opts.h24 and opts.showampm

    setTime = ->
        dateObj = new Date()
        currentHrs = dateObj.getHours()
        currentMins = dateObj.getMinutes()
        AMPM = if (currentHrs < 12) then 'AM' else 'PM'

        if currentMins is oldMins
            setTimeout setTime, 1000
            return false

        oldMins = currentMins

        console.log 'tick: ', dateObj.toLocaleTimeString()

        unless opts.h24
            currentHrs = if (currentHrs > 12) then currentHrs - 12 else currentHrs
            currentHrs = if (currentHrs is 0) then 12 else currentHrs

        currentHrs = (if currentHrs < 10 then '0' else '') + currentHrs
        currentMins = (if currentMins < 10 then '0' else '') + currentMins
        currentMinStr = currentMins.toString()
        currentHrsStr = currentHrs.toString()
        currentMinStr = currentMinStr.split ''
        currentHrsStr = currentHrsStr.split ''
        timeStr = "#{currentHrsStr[0]} #{currentHrsStr[1]} : #{currentMinStr[0]} #{currentMinStr[1]}"
        timeEl.firstChild.nodeValue = timeStr

        if not opts.h24 and opts.showampm
            timeEl.childNodes[1].firstChild.nodeValue = AMPM
        setTimeout setTime, 1000

    setTime()
