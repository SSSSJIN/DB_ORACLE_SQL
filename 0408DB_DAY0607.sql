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
SELECT BRAND_CD
       ,ITEM_CD
       ,SUM(ORDER_QTY) AS SUM_QTY
       
       
       ,(
        SELECT ITEM_NM
            FROM A_ITEM S1           
           WHERE S1.BRAND_CD = M1.BRAND_CD
             AND S1.ITEM_CD  = M1.ITEM_CD
        ) AS ITEM_NM
        ,(
        SELECT QTY_IN_BOX
            FROM A_ITEM S1           
           WHERE S1.BRAND_CD = M1.BRAND_CD
             AND S1.ITEM_CD  = M1.ITEM_CD
        ) AS QTY_IN_BOX
       
    FROM A_OUT_D M1
  GROUP BY BRAND_CD, ITEM_CD;
--1. JOIN 활용한 1번 풀이 : 브랜드/상품별 주문수량의 합계 구하기 + 상품명, 박스입수 가져오기
SELECT M1.BRAND_CD, M1.ITEM_CD, SUM(M1.ORDER_QTY) AS SUM_QTY
      ,C1.ITEM_NM, C1.QTY_IN_BOX
    FROM A_OUT_D M1
        JOIN A_ITEM C1 ON C1.BRAND_CD   = M1.BRAND_CD
                      AND C1.ITEM_CD    = M1.ITEM_CD
  GROUP BY M1.BRAND_CD, M1.ITEM_CD, C1.ITEM_NM, C1.QTY_IN_BOX;                      
  
  --2
  /* ERROR - ORA-01476: 제수가 0 입니다
01476. 00000 -  "divisor is equal to zero"
*Cause:    
*Action:*/
SELECT BRAND_CD, ITEM_CD, SUM_QTY, ITEM_NM, QTY_IN_BOX
      ,TRUNC(SUM_QTY / QTY_IN_BOX) AS BOX_CNT        --박스수
      ,MOD(SUM_QTY, QTY_IN_BOX) AS PCS_CNT            --낱개수량
  FROM (
       SELECT M1.BRAND_CD, M1.ITEM_CD, SUM(M1.ORDER_QTY) AS SUM_QTY
    ,C1.ITEM_NM, C1.QTY_IN_BOX
  FROM A_OUT_D M1
      JOIN A_ITEM C1 ON C1.BRAND_CD   = M1.BRAND_CD
                    AND C1.ITEM_CD    = M1.ITEM_CD
GROUP BY M1.BRAND_CD, M1.ITEM_CD, C1.ITEM_NM, C1.QTY_IN_BOX
       );   
         
  
  --2번 내가 풀다 포기한 풀이
  /*
  SELECT TRUNC(SUM(ORDER_QTY) / QTY_IN_BOX) 
         ,MOD(SUM(ORDER_QTY), QTY_IN_BOX) 
    FROM (
         SELECT BRAND_CD
       ,ITEM_CD
       ,SUM(ORDER_QTY)
       ,(
        SELECT ITEM_NM
            FROM A_ITEM S1           
           WHERE S1.BRAND_CD = M1.BRAND_CD
             AND S1.ITEM_CD  = M1.ITEM_CD
        )
        ,(
        SELECT QTY_IN_BOX
            FROM A_ITEM S1           
           WHERE S1.BRAND_CD = M1.BRAND_CD
             AND S1.ITEM_CD  = M1.ITEM_CD
        )        
    FROM A_OUT_D M1
  GROUP BY BRAND_CD, ITEM_CD
         )
   */
SELECT *
    FROM (
         SELECT BRAND_CD, ITEM_CD, SUM_QTY, ITEM_NM, QTY_IN_BOX
      ,TRUNC(SUM_QTY / QTY_IN_BOX) AS BOX_CNT        --박스수
      ,MOD(SUM_QTY, QTY_IN_BOX) AS PCS_CNT            --낱개수량
  FROM (
       SELECT M1.BRAND_CD, M1.ITEM_CD, SUM(M1.ORDER_QTY) AS SUM_QTY
    ,C1.ITEM_NM, C1.QTY_IN_BOX
  FROM A_OUT_D M1
      JOIN A_ITEM C1 ON C1.BRAND_CD   = M1.BRAND_CD
                    AND C1.ITEM_CD    = M1.ITEM_CD
GROUP BY M1.BRAND_CD, M1.ITEM_CD, C1.ITEM_NM, C1.QTY_IN_BOX
       )  
           ORDER BY BOX_CNT DESC
         )
  WHERE ROWNUM <= 3
