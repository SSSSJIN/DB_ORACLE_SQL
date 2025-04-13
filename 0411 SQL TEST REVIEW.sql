--0411 SQL TEST REVIEW
--1
SELECT BRAND_CD
      ,ITEM_CD
      ,SUM(ORDER_QTY) AS SUM_QTY
    FROM A_OUT_D
   GROUP BY BRAND_CD
            ,ITEM_CD
  HAVING SUM(ORDER_QTY) BETWEEN 2 AND 6          
  ;
  
--2
SELECT *
    FROM A_OUT_D
    ;
SELECT *
    FROM A_OUT_M    
    ;
SELECT BRAND_CD
      ,COUNT(INVOICE_NO) AS INV_CNT
      ,SUM(ORDER_QTY) AS SUM_QTY
    FROM A_OUT_D
   WHERE (BRAND_CD, INVOICE_NO) IN ( 
                                    SELECT BRAND_CD
                                          ,INVOICE_NO      
                                        FROM A_OUT_M
                                       WHERE OUTBOUND_DATE BETWEEN '2023-01-01' AND '2023-01-04'
                                         AND OUT_TYPE_DIV IN ('M11', 'M21')                                           
                                    )
  GROUP BY BRAND_CD                                  
     ;
     
-- JOIN 쓴 다른 풀이
SELECT d.BRAND_CD, COUNT(d.INVOICE_NO) AS INV_CNT, SUM(d.ORDER_QTY) AS SUM_QTY
FROM A_OUT_D d
JOIN A_OUT_M m
  ON d.BRAND_CD = m.BRAND_CD AND d.INVOICE_NO = m.INVOICE_NO
WHERE m.OUTBOUND_DATE BETWEEN '2023-01-01' AND '2023-01-04'
  AND m.OUT_TYPE_DIV IN ('M11', 'M21')
GROUP BY d.BRAND_CD
;

--3     
SELECT TO_CHAR(OUTBOUND_DATE, 'DY') AS DY
      ,OUT_TYPE_DIV
      ,COUNT(DISTINCT INVOICE_NO) AS INV_CNT                            
    FROM A_OUT_M
   GROUP BY TO_CHAR(OUTBOUND_DATE, 'DY')
            ,OUT_TYPE_DIV            
   ORDER BY CASE TO_CHAR(OUTBOUND_DATE, 'DY')
                                           WHEN '일' THEN 1
                                           WHEN '월' THEN 2
                                           WHEN '화' THEN 3
                                           WHEN '수' THEN 4
                                           WHEN '목' THEN 5
                                           WHEN '금' THEN 6
                                           WHEN '토' THEN 7
             END 
             ,OUT_TYPE_DIV      
            ;

0411 SQL TEST REVIEW
	0413 REVIEWING DATE

--1
SELECT BRAND_CD
	 ,ITEM_CD
	 ,SUM(ORDER_QTY) AS SUM_QTY
	FROM A_OUT_D
       GROUP BY BRAND_CD
  		     ,ITEM_CD 		
      HAVING SUM(ORDER_QTY) BETWEEN 2 AND 6   --별칭 쓰지말고 다 쓰기   
	; 

--2
SELECT 	BRAND_CD
		,INVOICE_NO
    	,SUM(ORDER_QTY) AS SUM_QTY
	FROM (
			SELECT 	BRAND_CD
					,INVOICE_NO
				FROM A_OUT_M
				WHERE OUTBOUND_DATE BETWEEN '2023-01-01' AND '2023-01-04'
				  AND OUT_TYPE_DIV IN ('M11', 'M21')	
		 )
   GROUP BY BRAND_CD
			,INVOICE_NO
   ORDER BY SUM_QTY DESC
   ;

--3
SELECT TO_CHAR(OUTBOUND_DATE, 'DY') AS DY
      ,OUT_TYPE_DIV
      ,COUNT(INVOICE_NO) AS IVN_CNT
    FROM A_OUT_M
   ORDER BY CASE WHEN TO_CHAR(OUTBOUND_DATE, 'DY') = 일 THEN '1'
                 WHEN TO_CHAR(OUTBOUND_DATE, 'DY') = 월 THEN '2'
                 WHEN TO_CHAR(OUTBOUND_DATE, 'DY') = 화 THEN '3'
                 WHEN TO_CHAR(OUTBOUND_DATE, 'DY') = 수 THEN '4'
                 WHEN TO_CHAR(OUTBOUND_DATE, 'DY') = 목 THEN '5'
                 WHEN TO_CHAR(OUTBOUND_DATE, 'DY') = 금 THEN '6'
                 WHEN TO_CHAR(OUTBOUND_DATE, 'DY') = 토 THEN '7'
            END
            ,OUT_TYPE_DIV
    ;            
--3 수정본 안되는데??
SELECT TO_CHAR(OUTBOUND_DATE, 'DY', 'NLS_DATE_LANGUAGE=KOREAN') AS DY
      ,OUT_TYPE_DIV
      ,COUNT(INVOICE_NO) AS IVN_CNT
  FROM A_OUT_M
 ORDER BY CASE WHEN TO_CHAR(OUTBOUND_DATE, 'DY', 'NLS_DATE_LANGUAGE=KOREAN') = '일' THEN '1'
               WHEN TO_CHAR(OUTBOUND_DATE, 'DY', 'NLS_DATE_LANGUAGE=KOREAN') = '월' THEN '2'
               WHEN TO_CHAR(OUTBOUND_DATE, 'DY', 'NLS_DATE_LANGUAGE=KOREAN') = '화' THEN '3'
               WHEN TO_CHAR(OUTBOUND_DATE, 'DY', 'NLS_DATE_LANGUAGE=KOREAN') = '수' THEN '4'
               WHEN TO_CHAR(OUTBOUND_DATE, 'DY', 'NLS_DATE_LANGUAGE=KOREAN') = '목' THEN '5'
               WHEN TO_CHAR(OUTBOUND_DATE, 'DY', 'NLS_DATE_LANGUAGE=KOREAN') = '금' THEN '6'
               WHEN TO_CHAR(OUTBOUND_DATE, 'DY', 'NLS_DATE_LANGUAGE=KOREAN') = '토' THEN '7'
          END
          ,OUT_TYPE_DIV
;    

--4 CONNECT BY / LEVEL / 날짜 함수 / TRUNC 함수 
SELECT TRUNC(SYSDATE, 'MM') + LEVEL - 1 AS DAY
    FROM CS_NO
    CONNECT BY LEVEL <= TO_CHAR(LAST_DAY(SYSDATE), 'DD')
    ;
    
--5 HAVING : 1 조건 추가할때 쓰는 거 GROUP BY 에 붙어서 쓰는거 확인하는 문제  
        --   2 DESC = 내림차순  
        --   3 순위 구하는 방법 - RANK() OVER(ORDER BY 대상 DESC) AS RNK 
        --   4 서브쿼리로 감싸고 순위부여하기
        --   5 순위에 따라 CASE 문으로 GRADE 구하기
        --   6 최종적으로 한번 더 서브쿼리 써서 감싸서 CASE 붙이기
SELECT RNK
        ,BRAND_CD
        ,ITEM_CD
        ,SUM_QTY
        ,CASE WHEN RNK = 1 THEN 'TOP1'
              WHEN RNK = 2 THEN 'TOP2'
              ELSE 'etc'
         END AS GRADE
    FROM (         
SELECT RANK() OVER (ORDER BY SUM_QTY DESC) AS RNK
        ,BRAND_CD
        ,ITEM_CD
        ,SUM_QTY
    FROM (        
            SELECT 
              BRAND_CD,
              ITEM_CD,
              SUM(ORDER_QTY) AS SUM_QTY
            FROM A_OUT_D
            GROUP BY BRAND_CD, ITEM_CD
            HAVING SUM(ORDER_QTY) > 1
            ORDER BY SUM_QTY DESC
        )
   )
    ORDER BY SUM_QTY DESC         
    ;

                