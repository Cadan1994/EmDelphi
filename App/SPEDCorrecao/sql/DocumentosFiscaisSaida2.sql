SELECT 
       t2.entradasaida "Tipo",
       TO_NUMBER(
       CASE 
       WHEN t1.codproduto = TO_CHAR(17024) THEN TO_CHAR(2743)
       WHEN t1.codproduto = TO_CHAR(17172) THEN TO_CHAR(2738)
       ELSE t1.codproduto
       END) "Codigo",
       SUM (t1.quantidade) "EQuantidade"
FROM implantacao.rf_notaitem t1
INNER JOIN implantacao.rf_notamestre t2 ON (t2.nroempresa = 1) AND (t2.seqnota = t1.seqnota)
LEFT JOIN implantacao.map_produto t3 ON t3.seqproduto = t1.codproduto AND t3.desccompleta NOT LIKE 'ZZ%'
WHERE 1=1
AND t2.dtacancelamento IS NULL
AND t2.entradasaida = 'S'
AND t2.dtalancamento between to_date('01/01/2020', 'dd/mm/yyyy') AND to_date('31/01/2020', TO_CHAR('dd/mm/yyyy'))
AND t1.codproduto in (2738,17172,2743,17024)
GROUP BY t2.entradasaida,
         TO_NUMBER(
         CASE 
         WHEN t1.codproduto = TO_CHAR(17024) THEN TO_CHAR(2743)
         WHEN t1.codproduto = TO_CHAR(17172) THEN TO_CHAR(2738)
         ELSE t1.codproduto
         END)
ORDER BY TO_NUMBER(
         CASE 
         WHEN t1.codproduto = TO_CHAR(17024) THEN TO_CHAR(2743)
         WHEN t1.codproduto = TO_CHAR(17172) THEN TO_CHAR(2738)
         ELSE t1.codproduto
         END) ASC