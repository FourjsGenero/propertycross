IMPORT FGL propertysearch

SCHEMA propertycross

MAIN

    OPTIONS FIELD ORDER FORM
    OPTIONS INPUT WRAP
    CLOSE WINDOW SCREEN
    
    CONNECT TO "propertycross"
    CALL ui.Interface.loadStyles("propertycross")
    CALL ui.Interface.loadActionDefaults("propertycross")

    CALL propertysearch.execute()
END MAIN
