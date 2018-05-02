       IDENTIFICATION DIVISION.
       PROGRAM-ID. TAPE-COLLECTION.
       AUTHOR. MIKE DERUITER.
       
       ENVIRONMENT DIVISION.
       CONFIGURATION SECTION.
       SOURCE-COMPUTER. GNUCOBOL.
       
       INPUT-OUTPUT SECTION.
       FILE-CONTROL.
            SELECT IP-TAPES
                ASSIGN TO "/tmp/TAPES.DAT"
                ORGANIZATION IS LINE SEQUENTIAL.
            SELECT OP-COLLECTION
                ASSIGN TO "/tmp/tape-collection"
                ORGANIZATION IS LINE SEQUENTIAL.
            SELECT SW-TAPES
                ORGANIZATION IS LINE SEQUENTIAL.

       DATA DIVISION.
        
       FILE SECTION.
       FD  IP-TAPES.
       01  IP-TAPES-REC                 PIC X(52).

       SD  SW-TAPES.
       01  SW-TAPES-REC.
            05  SW-TAPES-ARTIST         PIC X(20).
            05  SW-TAPES-TITLE          PIC X(20).
            05  SW-TAPES-YEAR           PIC X(04).
            05  SW-TAPES-VALUE          PIC 999V99.
            05  SW-TAPES-RATING         PIC 9V99.

       FD  OP-COLLECTION.
       01  OP-COLLECTION-REC.              
            05                          PIC X(06).
            05  OP-TAPE-YEAR            PIC X(04).
            05                          PIC X(03).
            05  OP-TAPE-ARTIST          PIC X(20).
            05                          PIC X(02).
            05  OP-TAPE-TITLE           PIC X(20).
            05                          PIC X(03).
            05  OP-TAPE-VALUE           PIC $$$9.99.
            05                          PIC X(05).
            05  OP-TAPE-RATING          PIC 9.99.

       WORKING-STORAGE SECTION.
       01  WS-ACCUMULATORS.
            05  A-TOTAL-TAPE-VALUE      PIC 9999V99 VALUE ZERO.
            05  A-TOTAL-TAPE-RATING     PIC 999V99 VALUE ZERO.
            05  A-TOTAL-TAPE-NUM        PIC 9999 VALUE ZERO.
            05  A-YEAR-TAPE-VALUE       PIC 9999V99 VALUE ZERO.
            05  A-YEAR-TAPE-RATING      PIC 999V99 VALUE ZERO.
            05  A-YEAR-TAPE-NUM         PIC 9999 VALUE ZERO.

       01  WS-SWITCHES.
            05  EOF-IP-TAPES-SW         PIC X VALUE "N".
                88  EOF-IP-TAPES              VALUE "Y".            
        
       01  WS-AVERAGES.
            05  WS-AVG-TAPE-RATE        PIC 999V99 VALUE ZERO.
            05  WS-AVG-TAPE-VAL         PIC 9999V99 VALUE ZERO.
        
       01  WS-TEMPORARY.
            05  WS-PREV-YEAR            PIC X(04) VALUE ALL SPACES.
        
       01  YEAR-AVERAGE-REC.
            05                          PIC X(06) VALUE ALL SPACES.
            05  YA-YEAR                 PIC X(05) VALUE ALL SPACES.
            05                          PIC X(08) VALUE "AVERAGE:".
            05                          PIC X(40) VALUE ALL SPACES.
            05  YA-TAPE-VALUE           PIC $$9.99 VALUE ZERO.
            05                          PIC X(05) VALUE ALL SPACES.
            05  YA-TAPE-RATING          PIC 9.99 VALUE ZERO.
            
       01  YEAR-TOTAL-REC.
            05                          PIC X(06) VALUE ALL SPACES.
            05  YT-YEAR                 PIC X(05) VALUE ALL SPACES.
            05                          PIC X(06) VALUE "TOTAL:".
            05                          PIC X(40) VALUE ALL SPACES.
            05  YT-TAPE-VALUE           PIC $,$$9.99 VALUE ZERO.
        
       01  GRAND-AVERAGE-REC.
            05                          PIC X(06) VALUE ALL SPACES.
            05                          PIC X(06) VALUE "GRAND ".
            05                          PIC X(08) VALUE "AVERAGE:".
            05                          PIC X(39) VALUE ALL SPACES.
            05  GA-TAPE-VALUE           PIC $$9.99 VALUE ZERO.
            05                          PIC X(05) VALUE ALL SPACES.
            05  GA-TAPE-RATING          PIC 9.99 VALUE ZERO.

       01  GRAND-TOTAL-REC.
            05                          PIC X(06) VALUE ALL SPACES.
            05                          PIC X(06) VALUE "GRAND ".
            05                          PIC X(06) VALUE "TOTAL:".
            05                          PIC X(39) VALUE ALL SPACES.
            05  GT-TAPE-VALUE           PIC $,$$9.99 VALUE ZERO.
            
       01  TITLE-1.
            05                          PIC X(28) VALUE ALL SPACES.
            05                          PIC X(12) VALUE "MIKE'S TAPE ".
            05                          PIC X(10) VALUE "COLLECTION".

       01  HEADER-1.
            05                          PIC X(06) VALUE ALL SPACES.
            05                          PIC X(04) VALUE "YEAR".
            05                          PIC X(03) VALUE ALL SPACES.
            05                          PIC X(20) VALUE "ARTIST".
            05                          PIC X(02) VALUE ALL SPACES.
            05                          PIC X(20) VALUE "TITLE".
            05                          PIC X(05) VALUE ALL SPACES.
            05                          PIC X(05) VALUE "VALUE".
            05                          PIC X(03) VALUE ALL SPACES.
            05                          PIC X(06) VALUE "RATING".

       01  HEADER-DASHES.
            05                          PIC X(06) VALUE ALL SPACES.
            05                          PIC X(04) VALUE ALL "-".
            05                          PIC X(03) VALUE ALL SPACES.
            05                          PIC X(20) VALUE ALL "-".
            05                          PIC X(02) VALUE ALL SPACES.
            05                          PIC X(20) VALUE ALL "-".
            05                          PIC X(03) VALUE ALL SPACES.
            05                          PIC X(07) VALUE ALL "-".
            05                          PIC X(03) VALUE ALL SPACES.
            05                          PIC X(06) VALUE ALL "-".

       01  FOOTER-DASHES.
            05                          PIC X(58) VALUE ALL SPACES.
            05                          PIC X(07) VALUE ALL "-".
            05                          PIC X(03) VALUE ALL SPACES.
            05                          PIC X(06) VALUE ALL "-".
            
       01  GRAND-TOTAL-AVG-DASHES.
            05                          PIC X(06) VALUE ALL SPACES.
            05                          PIC X(68) VALUE ALL "-".

       PROCEDURE DIVISION.

       00000-MAIN.
            SORT SW-TAPES
                ASCENDING SW-TAPES-YEAR,
                          SW-TAPES-ARTIST,
                          SW-TAPES-TITLE
                USING IP-TAPES
                OUTPUT PROCEDURE OA1000-MAINLINE.

            STOP RUN.
            
       OA1000-MAINLINE.
            PERFORM OB1000-SETUP.
            PERFORM OB2000-PROCESS
                UNTIL EOF-IP-TAPES.
            PERFORM OB3000-WRAPUP.

       OB1000-SETUP.
            OPEN OUTPUT OP-COLLECTION.

            WRITE OP-COLLECTION-REC FROM TITLE-1.
            WRITE OP-COLLECTION-REC FROM HEADER-1
                AFTER ADVANCING 1 LINES.
            WRITE OP-COLLECTION-REC FROM HEADER-DASHES
                AFTER ADVANCING 1 LINE.

            MOVE SPACES TO OP-COLLECTION-REC.

            RETURN SW-TAPES
                AT END MOVE "Y" TO EOF-IP-TAPES-SW.
                
            MOVE SW-TAPES-YEAR          TO WS-PREV-YEAR.
            MOVE SW-TAPES-YEAR          TO OP-TAPE-YEAR.

       OB2000-PROCESS.
            IF SW-TAPES-YEAR IS NOT EQUAL TO WS-PREV-YEAR
                PERFORM OC2000-PRINT-PAGE-TOTAL-AVG
                MOVE SW-TAPES-YEAR      TO WS-PREV-YEAR
                MOVE SW-TAPES-YEAR      TO OP-TAPE-YEAR
            END-IF.
       
            MOVE SW-TAPES-TITLE         TO OP-TAPE-TITLE.
            MOVE SW-TAPES-ARTIST        TO OP-TAPE-ARTIST.
            MOVE SW-TAPES-VALUE         TO OP-TAPE-VALUE.
            MOVE SW-TAPES-RATING        TO OP-TAPE-RATING.

            ADD  SW-TAPES-VALUE         TO A-YEAR-TAPE-VALUE.
            ADD  SW-TAPES-RATING        TO A-YEAR-TAPE-RATING.
            ADD  1                      TO A-YEAR-TAPE-NUM.

            WRITE OP-COLLECTION-REC
                AFTER ADVANCING 1 LINE.

            MOVE SPACES                 TO OP-TAPE-YEAR.

            RETURN SW-TAPES
                AT END MOVE "Y" TO EOF-IP-TAPES-SW.

       OB3000-WRAPUP.
            PERFORM OC2000-PRINT-PAGE-TOTAL-AVG
            PERFORM OC3000-PRINT-GRAND-TOTAL-AVG.
            
            CLOSE OP-COLLECTION.
                
       OC2000-PRINT-PAGE-TOTAL-AVG.
            PERFORM OD1000-CALC-YEAR-TOTAL-AVG.
       
            MOVE WS-PREV-YEAR           TO YA-YEAR.
            MOVE WS-PREV-YEAR           TO YT-YEAR.
            
            WRITE OP-COLLECTION-REC FROM FOOTER-DASHES
                AFTER ADVANCING 1 LINE.
            WRITE OP-COLLECTION-REC FROM YEAR-AVERAGE-REC
                AFTER ADVANCING 1 LINE.
            WRITE OP-COLLECTION-REC FROM YEAR-TOTAL-REC
                AFTER ADVANCING 1 LINE.
                
            MOVE SPACES                 TO OP-COLLECTION-REC.
            
            WRITE OP-COLLECTION-REC
                AFTER ADVANCING 1 LINE.
                
       OC3000-PRINT-GRAND-TOTAL-AVG.
            PERFORM OD2000-CALC-GRAND-TOTAL-AVG.
            
            WRITE OP-COLLECTION-REC FROM GRAND-TOTAL-AVG-DASHES
                AFTER ADVANCING 1 LINE.
            WRITE OP-COLLECTION-REC FROM GRAND-TOTAL-AVG-DASHES
                AFTER ADVANCING 1 LINE.
            WRITE OP-COLLECTION-REC FROM GRAND-AVERAGE-REC
                AFTER ADVANCING 2 LINES.
            WRITE OP-COLLECTION-REC FROM GRAND-TOTAL-REC
                AFTER ADVANCING 1 LINE.

            MOVE SPACES                 TO OP-COLLECTION-REC.
                
       OD1000-CALC-YEAR-TOTAL-AVG.
            MOVE A-YEAR-TAPE-VALUE      TO YT-TAPE-VALUE.
            
            MOVE A-YEAR-TAPE-VALUE      TO WS-AVG-TAPE-VAL.
            MOVE A-YEAR-TAPE-RATING     TO WS-AVG-TAPE-RATE.
            
            DIVIDE A-YEAR-TAPE-NUM INTO WS-AVG-TAPE-VAL
                GIVING YA-TAPE-VALUE.
            DIVIDE A-YEAR-TAPE-NUM INTO WS-AVG-TAPE-RATE
                GIVING YA-TAPE-RATING.
                
            ADD  A-YEAR-TAPE-VALUE      TO A-TOTAL-TAPE-VALUE.
            ADD  A-YEAR-TAPE-RATING     TO A-TOTAL-TAPE-RATING.
            ADD  1                      TO A-TOTAL-TAPE-NUM.
                
            MOVE ZEROES                 TO A-YEAR-TAPE-VALUE.
            MOVE ZEROES                 TO A-YEAR-TAPE-RATING.
            MOVE ZEROES                 TO A-YEAR-TAPE-NUM.

                
       OD2000-CALC-GRAND-TOTAL-AVG.
            MOVE A-TOTAL-TAPE-VALUE TO GT-TAPE-VALUE.
            
            MOVE A-TOTAL-TAPE-VALUE     TO WS-AVG-TAPE-VAL.
            MOVE A-TOTAL-TAPE-RATING    TO WS-AVG-TAPE-RATE.
            
            DIVIDE A-TOTAL-TAPE-NUM INTO WS-AVG-TAPE-VAL
                GIVING GA-TAPE-VALUE.
            DIVIDE A-TOTAL-TAPE-NUM INTO WS-AVG-TAPE-RATE
                GIVING GA-TAPE-RATING.
