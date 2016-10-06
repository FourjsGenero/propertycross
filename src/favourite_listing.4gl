IMPORT FGL favourite
IMPORT FGL propertylisting
IMPORT FGL nestoria

DEFINE arr DYNAMIC ARRAY OF RECORD
    major, minor, img STRING
END RECORD

FUNCTION execute()
DEFINE i INTEGER


DEFINE l_listing nestoria.listingType

    OPEN WINDOW favourites WITH FORM "favourite_listing"

    CALL populate()

    IF arr.getLength() = 0 THEN
        MENU "" ATTRIBUTES(STYLE="dialog", COMMENT="You have not added any properties to your favourites")
            ON ACTION accept
                EXIT MENU
        END MENU
    ELSE
        DISPLAY ARRAY arr TO scr.* ATTRIBUTES(ACCEPT=FALSE, DOUBLECLICK=select)
            ON ACTION select
                CALL favourite.get(arr_curr()) RETURNING l_listing.*
                CALL propertylisting.execute(l_listing.*)
                CALL populate()
        END DISPLAY
    END IF
    CLOSE WINDOW favourites
END FUNCTION


FUNCTION populate()
DEFINE i INTEGER
DEFINE l_listing nestoria.listingType

    FOR i = 1 To favourite.count()
        CALL favourite.get(i) RETURNING l_listing.*
        let arr[i].major = l_listing.price_formatted
        let arr[i].minor = l_listing.summary
        let arr[i].img = l_listing.thumb_url
    END FOR
END FUNCTION