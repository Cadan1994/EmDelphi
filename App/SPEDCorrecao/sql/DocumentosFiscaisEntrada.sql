SELECT 
       'E' "Tipo",
       t1.codproduto "Codigo",
       t3.desccompleta "Descricao",
       SUM (t1.quantidade) "EQuantidade",
       (
       SELECT a.CODPRODUTO, SUM(a.quantidade)
       FROM implantacao.rf_notaitem a
       INNER JOIN implantacao.rf_notamestre b ON b.nroempresa = 1 AND b.seqnota = a.seqnota
       WHERE 1=1
       AND EXTRACT(YEAR FROM b.dtalancamento) = 2020
       AND EXTRACT(MONTH FROM b.dtalancamento) = 01 
       AND b.dtacancelamento IS NULL
       AND b.entradasaida = 'S'
       AND a.codproduto = t1.codproduto
       GROUP BY a.codproduto
       ) "SQuantidade"
FROM implantacao.rf_notaitem t1
INNER JOIN implantacao.rf_notamestre t2 ON (t2.nroempresa = 1) AND (t2.seqnota = t1.seqnota)
LEFT JOIN implantacao.map_produto t3 ON t3.seqproduto = t1.codproduto
WHERE 1=1
AND EXTRACT(YEAR FROM t2.dtalancamento) = 2020
AND EXTRACT(MONTH FROM t2.dtalancamento) = 01
AND (t2.dtacancelamento IS NULL)
AND (t2.entradasaida = 'E')
AND t1.cfop not in (1923,2923)
GROUP BY t1.codproduto, t3.desccompleta
ORDER BY t1.codproduto ASC