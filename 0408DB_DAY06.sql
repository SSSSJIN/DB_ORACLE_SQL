SELECT *
    FROM A_OUT_M
   WHERE BRAND_CD IN ('1001', '2001'); -- IN = OR(또는) ()안에 서브쿼리 쓰는 경우가 더 많다.
   
SELECT *
    FROM A_OUT_M
   WHERE (BRAND_CD, INVOICE_NO) IN (
                                    SELECT BRAND_CD, INVOICE_NO
                                        FROM A_OUT_D
                                       WHERE ORDER_QTY >= :ORDER_QTY
                                    );
                                    
--DAY 6.
--PAGE 14
--실전문제2                             

--2)연결한 두 개의 컬럼을 다시 분리하여 최종 결과를 구함
SELECT INVOICE_NO
       ,OUT_TYPE_DIV
       ,OUT_BOX_DIV
       ,TO_NUMBER(SUBSTR(VAL, 1, 10))  AS ORDER_QTY
       ,TO_NUMBER(SUBSTR(VAL,11))      AS LINE_NO
    FROM (
         SELECT INVOICE_NO
       ,OUT_TYPE_DIV
       ,OUT_BOX_DIV
       ,(--1)아이디어 : 2개의 컬럼을 연결하여 하나의 MAX값을 구함 -> 추후 분리       
        SELECT MAX(LPAD(ORDER_QTY, 10, '0') || LPAD(LINE_NO, 10, '0'))
            FROM LO_OUT_D S1    
           WHERE S1.INVOICE_NO = M1.INVOICE_NO
        ) AS VAL       
    FROM LO_OUT_M M1
   WHERE OUTBOUND_DATE = '2019-06-03' 
     AND OUTBOUND_NO BETWEEN 'D190603-897353' AND 'D190603-897360'    
         );
      
--DAY07
--PAGE 8
--1
SELECT BRAND_CD, INVOICE_NO, SUM(ORDER_QTY)
    FROM A_OUT_D
   GROUP BY BRAND_CD, INVOICE_NO
     