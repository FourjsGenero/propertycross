IMPORT FGL nestoria

DEFINE favourite_arr DYNAMIC ARRAY OF nestoria.listingType


FUNCTION init()
    CALL favourite_arr.clear()
END FUNCTION



FUNCTION add(l_listing)
DEFINE l_listing nestoria.listingType

    CALL favourite_arr.appendElement()
    LET favourite_arr[favourite_arr.getLength()].* = l_listing.*
END FUNCTION



FUNCTION remove(l_listing)
DEFINE l_listing nestoria.listingType
DEFINE i INTEGER

    FOR i = 1 TO favourite_arr.getLength()
        IF favourite_arr[i].* = l_listing.* THEN
            CALL favourite_Arr.deleteElement(i)
            EXIT FOR
        END IF
    END FOR
END FUNCTION


FUNCTION is_favourite(l_listing)
DEFINE l_listing nestoria.listingType
DEFINE i INTEGER
    FOR i = 1 TO favourite_arr.getLength()
        IF favourite_arr[i].* = l_listing.* THEN
            RETURN TRUE
        END IF
    END FOR
    RETURN FALSE
END FUNCTION


FUNCTION get(i)
DEFINE i INTEGER
    RETURN favourite_arr[i].*
END FUNCTION


FUNCTION count()
    RETURN favourite_arr.getLength()
END FUNCTION