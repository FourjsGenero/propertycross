import fgl nestoria
import fgl favourite

define m_listing nestoria.listingType

FUNCTION execute(l_listing)
define l_listing nestoria.listingType

    let m_listing.* = l_listing.*
    
    open window propertylisting with form "propertylisting"

    display m_listing.price_formatted TO price
    display shorten_title() TO location
    display m_listing.img_url TO img
    display bed_and_bath() TO detail
    display m_listing.summary TO summary
    menu ""
        before menu
            call state(DIALOG)
        on action cancel
            exit menu
        on action favourite_add
            call favourite.add(m_listing.*)
            call state(DIALOG)

        on action favourite_remove
            call favourite.remove(m_listing.*)
            call state(DIALOG)
    end menu
    close window propertylisting
end function

private function state(d)
define d ui.Dialog
define is_favourite boolean

    let is_favourite = favourite.is_favourite(m_listing.*)
    
    call d.setActionActive("favourite_remove", is_favourite)
    call d.setActionActive("favourite_add", NOT is_favourite)
    
end function






private function shorten_title()
define l_pos integer

    let l_pos = m_listing.title.getIndexOf(",",1)
    if l_pos > 0 then
        let l_pos = m_listing.title.getIndexOf(",",l_pos+1)
        if l_pos > 0 then
            return m_listing.title.subString(1, l_pos)
        end if
    end if
    return m_listing.title
end function

private function bed_and_bath()

    case
        when m_listing.bedroom_number > 1 and m_listing.bathroom_number > 1 
            return sfmt("%1 bedrooms, %2 bathrooms", m_listing.bedroom_number, m_listing.bathroom_number)
        when m_listing.bedroom_number > 1 and m_listing.bathroom_number =1  
            return sfmt("%1 bedrooms, %2 bathroom", m_listing.bedroom_number, m_listing.bathroom_number)
         when m_listing.bedroom_number = 1 and m_listing.bathroom_number > 1  
            return sfmt("%1 bed, %2 bathrooms", m_listing.bedroom_number, m_listing.bathroom_number)
        when m_listing.bedroom_number = 1 and m_listing.bathroom_number = 1
            return sfmt("%1 bed, %2 bathroom", m_listing.bedroom_number, m_listing.bathroom_number)
        when m_listing.bedroom_number > 1
            return sfmt("%1 bedrooms", m_listing.bedroom_number)
        when m_listing.bedroom_number = 1
            return "1 bedroom"
        when m_listing.bathroom_number > 1
            return sfmt("%1 bathrooms", m_listing.bathroom_number)
        when m_listing.bathroom_number = 1
            return "1 bathroom"
        otherwise
            return ""
    end case
end function