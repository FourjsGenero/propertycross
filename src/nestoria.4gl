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

PUBLIC DEFINE m_location RECORD    
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

 


FUNCTION search(l_search, l_page)
DEFINE l_search STRING
define l_page integer
DEFINE l_url STRING
define req com.HttpRequest
define resp com.HttpResponse

define s string

    LET l_url = SFMT("http://api.nestoria.co.uk/api?country=uk&pretty=1&action=search_listings&encoding=json&listing_type=buy&page=%2&place_name=%1", l_search, l_page)

   LET req = com.HttpRequest.Create(l_url)
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
    call util.Json.parse(s, m_location)
    return true, ""
END FUNCTION


FUNCTION latlong(l_page)
define l_page integer
DEFINE l_url STRING
DEFINE l_lat, l_lon FLOAT
DEFINE l_result STRING
define l_error_text string
define req com.HttpRequest
define resp com.HttpResponse

define s string

    if l_page = 1 then
        INITIALIZE m_location.* TO NULL
        CALL ui.Interface.frontCall("mobile", "getGeolocation",[],[l_result, l_lat, l_lon])
        IF l_result = "ok" then
            if l_lat > 59 or l_lat <50 or l_lon < -2 or l_lon > 9 then
                let l_result = ""
                let l_error_text = "Geolocation is out of range"
            end if
        else
            let l_result = "error"
            let l_error_text = "Geolocation did not return a value"
        end if
        if l_result = "ok" then
            #OK
        else
            let l_error_text = l_error_text,"\n.  Do you want to use "
            menu "Error" attributes(style="dialog", comment=l_error_text)
                on action accept
                    let l_lat = 51
                    let l_lon = 0
                    let l_result = "ok"
                    exit menu
                on action cancel
                    exit menu
            end menu
        end if
    else
        # page > 2
        let l_lat = m_location.request.location
    end if
    if l_result = "ok" then
        LET l_url = SFMT("http://api.nestoria.co.uk/api?country=uk&pretty=1&action=search_listings&encoding=json&listing_type=buy&page=%3&centre_point=%1,%2", l_lat,l_lon, l_page)
        LET req = com.HttpRequest.Create(l_url)
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
        call util.Json.parse(s, m_location)
    end if
    
    if l_result = "ok" then
        return true, ""
    else
        return false, ""
    end if

    return true, ""
        
END FUNCTION