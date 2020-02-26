function updatedet(index,trackid,showdet) {

    itemUpdStarted(index);
    console.log("UPD" + trackid);

    var db = dbConnection();
    var doc = new XMLHttpRequest();

    doc.onreadystatechange = function() {
        if (doc.readyState == XMLHttpRequest.DONE) {
            var header="";
            var det="";
            var phactive=0;
            var psactive=0;
            var psStr;
            var psRows;
            var strTapahtu;
            var resultsa=0;
            var retStr="";
            var okStr="ERR";
            var headrivi=999;
            var evtStr="";
            var evtStr2="";
            var psItmStr;
            var psItmVal;

            var rivit=doc.responseText.split("\n");
            for (var ii = 0; ii < rivit.length; ++ii) {
                var rivi=rivit[ii];
                if (rivi.match("<ol class=\"events-list\">")) {
                    phactive=1;
                }
                if (phactive == 1 && rivi.match("<\/ol>")) phactive=0;
                if (rivi.match("<div class=\"tracker-status\">")) okStr="OK";
                if (rivi.match("<dl class=\"tracker-info-list\">")) psactive=1;

                if (phactive == 1 && rivi.length > 2) strTapahtu=strTapahtu+rivi;

                if (psactive==1) {
                    if (rivi.match("</dl>")) {
                        psactive=0;
                        psRows=psStr.split("<\/d");

                        for (var iii = 0; iii < psRows.length; ++iii) {
                            if (psRows[iii].match("<dt>")) psItmStr=psRows[iii].replace(/<[^>]+>/gm,"").replace(/[a-z]>/gm,"").replace(/&nbsp;/gm,"").replace(/[\ ]{2,100}/gm," ").replace(/\t/gm,"").replace(/^\s\s*/, "").replace(/\s\s*$/,"").replace(/&nbsp/gm,"");
                            if (psRows[iii].match("<dd>")) psItmVal=psRows[iii].replace(/<[^>]+>/gm,"").replace(/[a-z]>/gm,"").replace(/&nbsp;/gm,"").replace(/[\ ]{2,100}/gm," ").replace(/\t/gm,"").replace(/^\s\s*/, "").replace(/\s\s*$/,"").replace(/&nbsp/gm,"");
                            if (psRows[iii].match("<dd>"))  {
                                insertShipdet(trackid,"HDR","99999999999"+headrivi,psItmStr,psItmVal);
                                headrivi--;
                            }
                        }
                    } else {
                        if (psStr) psStr=psStr+rivi;
                        else psStr=rivi;
                    }
                }

                if (phactive==1) {
                    if (rivi.match("<span class=\"timestamp\">")) {
                        var evtTime=Qt.formatDateTime(convertDate(rivi.replace(/<[^>]+>/gm,"").replace(/&nbsp;/gm,"").replace(/[\ ]{2,100}/gm," ").replace(/\t/gm,"").replace(/^\s\s*/, "").replace(/\s\s*$/,"").replace(/&nbsp/gm,"")), "yyyyMMddHHmmss");
                    }
                    if (rivi.match("<div class=\"event-details\">")) {
                        resultsa=1;
                    }
                    if (resultsa==1) {
                        if (rivi.match("<div>.+</div>")) {
                            var tmpStr=rivi.replace(/<[^>]+>/gm,"").replace(/&nbsp;/gm,"").replace(/[\ ]{2,100}/gm," ").replace(/\t/gm,"").replace(/^\s\s*/, "").replace(/\s\s*$/,"").replace(/&nbsp/gm,"");
                            if (evtStr=="") evtStr=tmpStr;
                            else evtStr2=tmpStr;
                        }
                        else if (rivi.match("</div>")) {
                            resultsa=0;
                            insertShipdet(trackid,"EVT",evtTime,evtStr,evtStr2);
                            okStr="HIT";
                            evtStr="";
                        }
                    }
                }
            }


            itemUpdReady(index,okStr,showdet);
        }



    }

    doc.open("GET", mhURL(trackid));
    doc.send();

}
