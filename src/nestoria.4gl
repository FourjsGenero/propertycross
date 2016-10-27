IMPORT com
IMPORT util

PUBLIC TYPE locationType RECORD
    center_lat FLOAT,
    center_long FLOAT,
    long_title STRING,
    place_name STRING,
    title STRING
END RECORD

PUBLIC TYPE listingType RECORD
            bathroom_number FLOAT,
            bedroom_number FLOAT,
            car_spaces FLOAT,
            commission FLOAT,
            construction_year FLOAT,
            datasource_name STRING,
            img_height FLOAT,
            img_url STRING,
            img_width FLOAT,
            keywords STRING,
            latitude FLOAT,
            lister_name STRING,
            lister_url STRING,
            listing_type STRING,
            location_accuracy FLOAT,
            longitude FLOAT,
            price FLOAT,
            price_currency STRING,
            price_formatted STRING,
            price_high FLOAT,
            price_low FLOAT,
            price_type STRING,
            property_type STRING,
            size FLOAT,
            size_type STRING,
            summary STRING,
            thumb_height FLOAT,
            thumb_url STRING,
            thumb_width FLOAT,
            title STRING,
            updated_in_days FLOAT,
            updated_in_days_formatted STRING
END RECORD

TYPE nestoriaResponseType RECORD    
    request RECORD
        country STRING,
        language STRING,
        location STRING,
        num_res STRING,
        offset FLOAT,
        output STRING,
        page FLOAT,
        pretty STRING,
        product_type STRING,
        property_type STRING,
        size_type STRING,
        size_unit STRING,
        sort STRING,
        listing_type STRING
    END RECORD,    
    response RECORD
        application_response_code STRING,
        application_response_text STRING,
        attribution RECORD
            img_height FLOAT,
            img_url STRING,
            img_width FLOAT,
            link_to_img STRING
        END RECORD,
        created_http STRING,
        created_unix FLOAT,
        link_to_url STRING,
        listings DYNAMIC ARRAY OF listingType,
        locations DYNAMIC ARRAY OF locationType,
        page FLOAT,
        sort STRING,
        status_code STRING,
        status_text STRING,
        thanks STRING,
        total_pages FLOAT,
        total_results FLOAT,
        listing_type STRING
    END RECORD
END RECORD 


PUBLIC DEFINE recent_arr DYNAMIC ARRAY OF RECORD
    text STRING,
    url STRING,
    count integer
END RECORD 

DEFINE m_last_url STRING

PUBLIC DEFINE location_arr DYNAMIC ARRAY OF locationType
PUBLIC DEFINE listing_arr DYNAMIC ARRAY OF listingType
PUBLIC DEFINE listing_total INTEGER

function init()
     let recent_arr[1].text="Leeds"
    let recent_arr[1].url = "leeds"

     let recent_arr[2].text="Teddington"
    let recent_arr[2].url = "teddington"
end function


FUNCTION search(l_search)
DEFINE l_search STRING
DEFINE l_url STRING
define req com.HttpRequest
define resp com.HttpResponse

define s string
define i integer
define l_response nestoriaResponseType

    call listing_arr.clear()
    call location_arr.clear()
    
    LET l_url = SFMT("http://api.nestoria.co.uk/api?country=uk&pretty=1&action=search_listings&encoding=json&listing_type=buy&page=1&place_name=%1", l_search)
    LET m_last_url = l_url
    
    LET req = com.HttpRequest.Create(l_url)
    CALL req.setTimeOut(5)
    CALL req.doRequest()
    LET resp = req.getResponse()
    if resp.getStatusCode() = 200 then
        #ok
    else
        return "error", resp.getStatusDescription()
    end if

    let s = resp.getTextResponse()
    #display util.json.proposetype(s)
    display s
    call util.Json.parse(s, l_response)

    case 
        when l_response.response.application_response_code = "200" 
        OR l_response.response.application_response_code = "202"
            for i = 1 to l_response.response.locations.getLength()
                let location_arr[i].* = l_response.response.locations[i].*
            end for
            return "location",""
        when l_response.response.application_response_code = "100" 
        OR l_response.response.application_response_code = "101" 
        OR l_response.response.application_response_code = "110"
            if l_response.response.listings.getLength() > 0 then
                for i = 1 TO l_response.response.listings.getLength() 
                    let listing_arr[i].* = l_response.response.listings[i].*
                end for
                let listing_total = l_response.response.total_results
                call recent_arr.insertElement(1)
                let recent_arr[1].text = l_response.response.locations[1].long_title
                let recent_arr[1].url = l_response.response.locations[1].place_name
                let recent_arr[1].count = l_response.response.total_results
                call trim_recent()
                return "ok", ""
            else
                return "zero", ""
            end if
    end case
    return "error", l_response.response.application_response_text
END FUNCTION



FUNCTION latlong()
DEFINE l_url STRING
DEFINE l_lat, l_lon FLOAT
DEFINE l_result STRING
define l_error_text string
define req com.HttpRequest
define resp com.HttpResponse

define s string
define l_response nestoriaResponseType
define i integer

    call listing_arr.clear()
    call location_arr.clear()
    
    INITIALIZE l_response.* TO NULL
    CALL ui.Interface.frontCall("mobile", "getGeolocation",[],[l_result, l_lat, l_lon])
    IF l_result = "ok" then
        if l_lat > 59 or l_lat <50 or l_lon < -2 or l_lon > 9 then
            let l_result = ""
            let l_error_text = "Geolocation is out of range."
        end if
    else
        let l_result = "error"
        let l_error_text = "Geolocation did not return a value."
    end if
    if l_result = "ok" then
        #OK
    else
        let l_error_text = l_error_text,"\nDo you want to use the 4Js UK office location? "
        menu "Error" attributes(style="dialog", comment=l_error_text)
            on action accept
                let l_lat = 51.45568979999999
                let l_lon = 0.2488582
                let l_result = "ok"
                exit menu
            on action cancel
                exit menu
        end menu
    end if
   

    if l_result = "ok" then
        LET l_url = SFMT("http://api.nestoria.co.uk/api?country=uk&pretty=1&action=search_listings&encoding=json&listing_type=buy&page=1&centre_point=%1,%2", l_lat,l_lon)
        LET m_last_url = l_url
        LET req = com.HttpRequest.Create(l_url)
        CALL req.setTimeOut(5)
        CALL req.doRequest()
        LET resp = req.getResponse()
        if resp.getStatusCode() = 200 then
            #ok
        else
            return false, resp.getStatusDescription()
        end if

        let s = resp.getTextResponse()
        #display util.json.proposetype(s)
        display s
        call util.Json.parse(s, l_response)

        case 
            when l_response.response.application_response_code = "100" 
            OR l_response.response.application_response_code = "101" 
            OR l_response.response.application_response_code = "110"
                if l_response.response.locations.getLength() > 0 then
                    for i = 1 TO l_response.response.listings.getLength() 
                        let listing_arr[i].* = l_response.response.listings[i].*
                    end for
                    let listing_total = l_response.response.total_results
                    call recent_arr.insertElement(1)
                    let recent_arr[1].text = l_response.response.locations[1].long_title
                    let recent_arr[1].url = l_response.response.locations[1].place_name
                    let recent_arr[1].count = l_response.response.total_results
                    call trim_recent()
                    return "ok", ""
                else
                    return "zero", ""
                end if
            otherwise
                return "error", l_response.response.application_response_text
        end case
    end if
    return "error", "Unable to detect current location. Please ensure location is turned on in your phone settings and try again"

END FUNCTION



FUNCTION next_page()
DEFINE l_url STRING
define req com.HttpRequest
define resp com.HttpResponse

define s string
define l_pos1, l_pos2 integer
define l_page integer
define l_response nestoriaResponseType
define i integer

    LET l_url = m_last_url
display l_url


    # append page number
    let l_pos1 = l_url.getIndexOf("&page=",1)
    if l_pos1 <=0 then
        return "error", ""
    end if
    let l_pos2 = l_url.getIndexOf("&", l_pos1 + 1)
    if l_pos2 <=0 then
        return "error", ""
    end if
    let l_page = l_url.subString(l_pos1+6, l_pos2-1)
    display l_page
    let l_page = l_page + 1
    display l_page
    let l_url = l_url.subString(1, l_pos1+5), l_page using "<<<", l_url.subString(l_pos2, l_url.getLength())
    display l_url
    
    # append page
    let m_last_url = l_url
    LET req = com.HttpRequest.Create(l_url)
    CALL req.setTimeOut(5)
    CALL req.doRequest()
    LET resp = req.getResponse()
    if resp.getStatusCode() = 200 then
        #ok
    else
        return "error", resp.getStatusDescription()
    end if

    let s = resp.getTextResponse()
    #display util.json.proposetype(s)
    display s
    call util.Json.parse(s, l_response)

    if l_response.response.application_response_code = "100" 
    OR l_response.response.application_response_code = "101" 
    OR l_response.response.application_response_code = "110" then
        if l_response.response.locations.getLength() > 0 then
                for i = 1 TO l_response.response.listings.getLength() 
                    let listing_arr[listing_arr.getLength()+1].* = l_response.response.listings[i].*
                end for
            return "ok", ""
        else
            return "zero", ""
        end if
    end if
    return "error", l_response.response.application_response_text
END FUNCTION

PRIVATE FUNCTION trim_recent()
DEFINE i integer

    for i = recent_arr.getLength() TO 2 STEP -1
        if recent_arr[i].url = recent_arr[1].url then
            call recent_arr.deleteElement(i)
        end if
    end for
end function