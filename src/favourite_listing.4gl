import fgl favourite
import fgl propertylisting
import fgl nestoria

define arr dynamic array of record
    major, minor, img string
end record

function execute()
define i integer
define l_listing nestoria.listingtype

    open window favourites with form "favourite_listing"

    call populate()

    if arr.getlength() = 0 then
        menu "" attributes(style="dialog", comment=%"menu.comment.nofavourites")
            on action accept
                exit menu
        end menu
    else
        display array arr to scr.* attributes(accept=false, doubleclick=select)
            on action select
                call favourite.get(arr_curr()) returning l_listing.*
                call propertylisting.execute(l_listing.*)
                call populate()
        end display
    end if
    close window favourites
end function



private function populate()
define i integer
define l_listing nestoria.listingtype

    for i = 1 to favourite.count()
        call favourite.get(i) returning l_listing.*
        let arr[i].major = l_listing.price_formatted
        let arr[i].minor = l_listing.summary
        let arr[i].img = l_listing.thumb_url
    end for
end function