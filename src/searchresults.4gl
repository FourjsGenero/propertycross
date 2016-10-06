IMPORT FGL nestoria
import fgl propertylisting

DEFINE arr DYNAMIC ARRAY OF RECORD
    major, minor, img STRING
END RECORD
DEFINE w ui.Window
define f ui.Form



FUNCTION execute()
DEFINE i INTEGER

    OPEN WINDOW searchresults WITH FORM "searchresults"
    LET w = ui.Window.getCurrent()
    LET f = w.getForm()

    call arr.clear()
    FOR i = 1 TO nestoria.m_location.response.listings.getLength()
        let arr[i].major = nestoria.m_location.response.listings[i].price_formatted
        let arr[i].minor = nestoria.m_location.response.listings[i].summary
        let arr[i].img = nestoria.m_location.response.listings[i].thumb_url
    end for
    DISPLAY ARRAY arr TO scr.* ATTRIBUTES(ACCEPT=FALSE, DOUBLECLICK=select)
        BEFORE DISPLAY
            call state(DIALOG)
        ON ACTION select
            call propertylisting.execute(nestoria.m_location.response.listings[arr_curr()].*)

        on action load
            call state(dialog)
    END DISPLAY

    CLOSE WINDOW searchresults

END FUNCTION



PRIVATE FUNCTION state(d)
define d ui.dialog
    call f.setElementText("grpheading", sfmt("%1 of %2 matches", arr.getLength() USING "<<<&", nestoria.m_location.response.total_results USING "<<<&"))
    #CALL w.setText(sfmt("%1 of %2 matches", arr.getLength() USING "<<<&", nestoria.m_location.response.total_results USING "<<<&"))
    CALL d.setActionActive("load", nestoria.m_location.response.total_results > arr.getLength())
end function