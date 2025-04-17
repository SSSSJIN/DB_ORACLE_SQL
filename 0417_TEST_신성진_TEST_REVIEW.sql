--0417_TEST_신성진_TEST_REVIEW
--1
SELECT T0_CHAR(OUTBOUND_DATE, 'YYYY-MM') AS OUT_DATE
        ,COUNT(1) AS INV_CNT
        ,SUM(SET_QTY) AS SET_QTY
    FROM LO_OUT_M
   WHERE OUTBOUND_DATE BETWEEN '2019-06-01' AND '2019-08-31'
  GROUP BY T0_CHAR(OUTBOUND_DATE, 'YYYY-MM') 
  ORDER BY OUT_DATE
  ;

--2 : HAVING X
SELECT M1.OUT_TYPE_DIV
        ,SUM(M2.ORDER_QTY) AS SUM_QTY
    FROM LO_OUT_M M1    
        JOIN LO_OUT_D M2 ON M2.INVOICE_NO = M1. INVOICE_NO                                
   WHERE M1.OUTBOUND_DATE = '2019-09-03'                    
  GROUP BY M1.OUT_TYPE_DIV   
 HAVING SUM(M2.ORDER_QTY) >= '5000' 
  ORDER BY CASE WHEN M1.OUT_TYPE_DIV LIKE 'M1%' THEN 1 ELSE 2 END
          ,CASE WHEN M1.OUT_TYPE_DIV LIKE 'M1%' THEN SUM_QTY ELSE -SUM_QTY END
  ;          
  
--3
SELECT CASE WHEN ROWNUM <= 10 THEN TO_CHAR(OUR_DATE, 'YYYY-MM-DD') END AS OUT_DATE
      ,CASE WHEN ROWNUM <= 10 THEN ITEM_CD END AS ITEM_CD
      ,CASE WHEN ROWNUM <= 10 THEN ITEM_NM END AS ITEM_NM      
    FROM (
SELECT M1.OUTBOUND_DATE AS OUT_DATE
                    ,M2.ITEM_CD AS ITE_CD
                    ,M2.ITEM_NM
                    ,SUM(M2.ORDER_QTY) AS SUM_QTY                                        
                FROM LO_OUT_M M1
                    JOIN LO_OUT_D M2 ON M2.INVOICE_NO = M1.INVOICE_NO
               WHERE OUTBOUND_DATE BETWEEN '2019-06-01' AND '2019-06-30' 
                 AND ITEM_NM LIKE '%참치%'
              GROUP BY M1.OUTBOUND_DATE 
                        ,M2.ITEM_CD 
                        ,M2.ITEM_NM   
              ORDER BY SUM(M2.ORDER_QTY) DESC    
          )
   GROUP BY        
   
  ;
  
--4


--5
