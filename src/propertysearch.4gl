IMPORT FGL nestoria
IMPORT FGL searchresults
import fgl favourite_listing


DEFINE m_state STRING
DEFINE w ui.Window
DEFINE f ui.Form

FUNCTION execute()

DEFINE search STRING
DEFINE search_arr DYNAMIC ARRAY OF RECORD
    search_result STRING,
    search_url STRING
END RECORD
DEFINE location_arr DYNAMIC ARRAY OF nestoria.locationType
DEFINE l_ok BOOLEAN
DEFINE l_error_text STRING
DEFINE i INTEGER

    LET m_state = "initial"

    OPEN WINDOW propertysearch WITH FORM "propertysearch"
    LET w = ui.Window.getCurrent()
    LET f = w.getForm()

    DISPLAY %"propertysearch.instruction.text" TO instruction

    DIALOG ATTRIBUTES(UNBUFFERED) 
        INPUT BY NAME search 
        
        END INPUT

        DISPLAY ARRAY search_arr TO search_scr.* 
            ON ACTION select
        END DISPLAY

        DISPLAY ARRAY location_arr TO location_scr.*
            ON ACTION select
        END DISPLAY

        BEFORE DIALOG
            CALL state(DIALOG)
        
        ON ACTION go

            call nestoria.search(search,1) returning l_ok, l_error_text
        label lbl_go:
            case
                when nestoria.m_location.response.application_response_code = "200" 
                or nestoria.m_location.response.application_response_code = "202" 
                    if nestoria.m_location.response.locations.getLength() > 0 then
                        let m_state = "location"
                        call location_arr.clear()
                        for i = 1 to nestoria.m_location.response.locations.getLength()
                            let location_arr[i].* = nestoria.m_location.response.locations[i].*
                        end for
                        call state(DIALOG)
                    else
                        let m_state = "error"
                        display "Zero properties returned" to error_text
                    end if
                when nestoria.m_location.response.application_response_code = "100" 
                or nestoria.m_location.response.application_response_code = "101" 
                or nestoria.m_location.response.application_response_code = "110" 
                    if nestoria.m_location.response.listings.getLength() >0 then
                        call searchresults.execute()
                        let m_state = "initial"
                    else
                        let m_state = "error"
                        display "Zero properties returned" to error_text
                    end if
            end case
            call state(dialog)
            
        ON ACTION my_location
            call nestoria.latlong(1) returning l_ok, l_error_text
            GOTO lbl_go

        ON ACTION favourite
            call favourite_listing.execute()
    END DIALOG
    CLOSE WINDOW propertysearch

END FUNCTION



PRIVATE FUNCTION state(d)
DEFINE d ui.Dialog

    CALL f.setElementHidden("grprecentsearch", m_state != "initial")
    CALL f.setElementHidden("grperror", m_state != "error")
    CALL f.setElementHidden("grplocationlist", m_state != "location")
END FUNCTION