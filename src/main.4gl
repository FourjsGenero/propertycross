IMPORT FGL propertysearch

SCHEMA propertycross

MAIN
DEFINE screen STRING

    OPTIONS FIELD ORDER FORM
    OPTIONS INPUT WRAP
    CLOSE WINDOW SCREEN
    
    CONNECT TO "propertycross"
    CALL ui.Interface.loadStyles("propertycross")
    CALL ui.Interface.loadActionDefaults("propertycross")

    LET screen = "propertysearch"

    WHILE TRUE
        CASE screen
            WHEN "propertysearch"
                CALL propertysearch.execute()
            
            OTHERWISE
                EXIT PROGRAM 
        END CASE
    END WHILE
END MAIN
