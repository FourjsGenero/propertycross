import fgl nestoria
import fgl propertylisting

define arr dynamic array of record
    major, minor, img string
end record
define w ui.window
define f ui.form



function execute()
define i integer
define l_result,l_error_text string

    open window searchresults with form "searchresults"
    let w = ui.window.getcurrent()
    let f = w.getform()

    call arr.clear()
    call populate()
    
    display array arr to scr.* attributes(accept=false, doubleclick=select, ACCESSORYTYPE=disclosureindicator)
        before display
            call state(dialog)
            
        on action select
            # Bypasses the system call that sets the back button to the window title
            #call w.setText("Back")
            
            call propertylisting.execute(nestoria.listing_arr[arr_curr()].*)
            call state(dialog)

        on action load
            call nestoria.next_page() returning l_result, l_error_text
            if l_result = "ok" then
                call populate()
            else
                call fgl_winmessage(%"popup.heading.error", l_error_text,"")
            end if
            call state(dialog)
    end display

    close window searchresults

end function



private function populate()
define i integer
    for i = 1 to nestoria.listing_arr.getlength()
        let arr[i].major = nestoria.listing_arr[i].price_formatted
        let arr[i].minor = nestoria.listing_arr[i].summary
        let arr[i].img = nestoria.listing_arr[i].thumb_url
    end for

end function



private function state(d)
define d ui.dialog
    #call w.setText(sfmt("%1 of %2 matches", arr.getlength() using "<<<&", nestoria.listing_total using "<<<&"))
call f.setElementText("g1",sfmt("%1 of %2 matches", arr.getlength() using "<<<&", nestoria.listing_total using "<<<&"))
    
    call d.setactionactive("load", nestoria.listing_total > arr.getlength())
end function