import fgl nestoria
import fgl favourite

define m_listing nestoria.listingtype



function execute(l_listing)
define l_listing nestoria.listingtype

    let m_listing.* = l_listing.*
    
    open window propertylisting with form "propertylisting"

    display l_listing.price_formatted to price
    display shorten_title() to location
    display l_listing.img_url to img
    display bed_and_bath() to detail
    display l_listing.summary to summary
    
    menu ""
        before menu
            call state(dialog)
            
        on action cancel
            exit menu
            
        on action favourite_add
            call favourite.add(l_listing.*)
            call state(dialog)

        on action favourite_remove
            call favourite.remove(l_listing.*)
            call state(dialog)
    end menu
    
    close window propertylisting
end function



private function state(d)
define d ui.dialog
define is_favourite boolean

    let is_favourite = favourite.is_favourite(m_listing.*)
    
    call d.setactionactive("favourite_remove", is_favourite)
    call d.setactionactive("favourite_add", not is_favourite)
end function



private function shorten_title()
define l_pos integer

    let l_pos = m_listing.title.getindexof(",",1)
    if l_pos > 0 then
        let l_pos = m_listing.title.getindexof(",",l_pos+1)
        if l_pos > 0 then
            return m_listing.title.substring(1, l_pos)
        end if
    end if
    return m_listing.title
end function



private function bed_and_bath()

    case
        when m_listing.bedroom_number > 1 and m_listing.bathroom_number > 1 
            return sfmt("%1 bedrooms, %2 bathrooms", m_listing.bedroom_number using "<<", m_listing.bathroom_number  using "<<")
        when m_listing.bedroom_number > 1 and m_listing.bathroom_number =1  
            return sfmt("%1 bedrooms, %2 bathroom", m_listing.bedroom_number  using "<<", m_listing.bathroom_number  using "<<")
         when m_listing.bedroom_number = 1 and m_listing.bathroom_number > 1  
            return sfmt("%1 bed, %2 bathrooms", m_listing.bedroom_number  using "<<", m_listing.bathroom_number  using "<<")
        when m_listing.bedroom_number = 1 and m_listing.bathroom_number = 1
            return sfmt("%1 bed, %2 bathroom", m_listing.bedroom_number  using "<<", m_listing.bathroom_number  using "<<")
        when m_listing.bedroom_number > 1
            return sfmt("%1 bedrooms", m_listing.bedroom_number  using "<<")
        when m_listing.bedroom_number = 1
            return "1 bedroom"
        when m_listing.bathroom_number > 1
            return sfmt("%1 bathrooms", m_listing.bathroom_number  using "<<")
        when m_listing.bathroom_number = 1
            return "1 bathroom"
        otherwise
            return ""
    end case
end function