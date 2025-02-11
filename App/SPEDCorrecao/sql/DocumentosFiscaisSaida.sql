-- Documentos fiscais (Saida) movimentação
SELECT 'SAIDA' "Tipo",
       b.CODPRODUTO "Cod Produto",
       c.DESCCOMPLETA "Descrição Produto",
       b.cfop "CFOP",
       SUM (b.quantidade) "Quant. Saida",
       sum (b.vlrtotal) "Valor Total",
       sum (b.vlrbaseicmsprop) "Base ICMS",
       sum (b.vlricms) "ICMS",
       sum (b.vlrtotal - b.vlricms) as "Valor Liq. Total",
       to_char (a.dtalancamento, 'MM/yyyy') "Mes/Ano"
FROM implantacao.RF_NOTAITEM b
LEFT JOIN implantacao.MAP_PRODUTO c ON b.CODPRODUTO = c.SEQPRODUTO
INNER JOIN implantacao.RF_NOTAMESTRE a ON (a.nroempresa = 1) AND (a.seqnota = b.seqnota)
where 1=1
and EXTRACT(YEAR FROM a.dtalancamento) = 2020
AND (a.dtacancelamento IS NULL)
AND (a.entradasaida = 'S')
--and b.cfop not in (1923,2923)
--and b.codproduto in :Produto
GROUP BY 
       b.cfop,
       b.CODPRODUTO,
       c.DESCCOMPLETA,
        to_char (a.dtalancamento, 'MM/yyyy')
order by b.CODPRODUTO