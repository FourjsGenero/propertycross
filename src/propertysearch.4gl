import fgl nestoria
import fgl searchresults
import fgl favourite_listing


define m_state string
define w ui.window
define f ui.form

define recent_arr dynamic array of record
    text string,
    url string
end record


function execute()
define search string

define location_arr dynamic array of nestoria.locationtype
define l_result string
define l_error_text string
define i integer

    let m_state = "initial"

    open window propertysearch with form "propertysearch"
    let w = ui.window.getcurrent()
    let f = w.getform()

    display %"propertysearch.instruction.text" to instruction

    dialog attributes(unbuffered) 
        input by name search 
        end input

        display array recent_arr to search_scr.*  attributes(accessorytype=disclosureindicator, doubleclick=select)
            on action select
                call nestoria.search(recent_arr[arr_curr()].url) returning l_result, l_error_text
                goto lbl_go
        end display

        display array location_arr to location_scr.* attributes(accessorytype=disclosureindicator, doubleclick=select)
            on action select
        end display

        before dialog
            call state(dialog)
        
        on action go
            call nestoria.search(search) returning l_result, l_error_text
            
        label lbl_go:
            case
                when l_result = "error"
                    let m_state = "error"
                    display l_error_text to error_text
                    
                when l_result = "zero"
                    let m_state = "error"
                    display %"error.zeroproperties" to error_text
                    
                when l_result = "location"
                    let m_state = "location"
                    call location_arr.clear()
                    for i = 1 to nestoria.location_arr.getlength()
                        let location_arr[i].* = nestoria.location_arr[i].*
                    end for
                    call state(dialog)

                when l_result = "ok"
                    call searchresults.execute()
                    call populate_recent()
                    let m_state = "initial"
            end case
            call state(dialog)
            
        on action my_location
            call nestoria.latlong() returning l_result, l_error_text
            goto lbl_go

        on action favourite
            call favourite_listing.execute()
    end dialog
    close window propertysearch

end function



private function state(d)
define d ui.dialog

    call f.setelementhidden("grprecentsearch", m_state != "initial")
    call f.setelementhidden("grperror", m_state != "error")
    call f.setelementhidden("grplocationlist", m_state != "location")
end function



private function populate_recent()
define i integer

    call recent_arr.clear()
    for i = 1 to nestoria.recent_arr.getLength()
        let recent_arr[i].text = sfmt("%1 (%2)", nestoria.recent_arr[i].text, nestoria.recent_arr[i].count)
        let recent_arr[i].url = nestoria.recent_arr[i].url
    end for
end function