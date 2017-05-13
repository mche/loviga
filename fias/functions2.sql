CREATE OR REPLACE FUNCTION fias.search_address_1(text)
RETURNS  TABLE("AOGUID" uuid[], "PARENTGUID" uuid[], "AOLEVEL" int2[], "FORMALNAME" text[], "SHORTNAME" varchar(10)[],  id int[])--, "CENTSTATUS" int2[],
AS $func$
-- на входе массив регулярок (сам приводи к нижнему регистру)
select
--distinct
  Array["l7AOGUID", "l6AOGUID", "l5AOGUID", "l4AOGUID", "l3AOGUID"],
  array["l7PARENTGUID", "l6PARENTGUID", "l5PARENTGUID", "l4PARENTGUID", "l3PARENTGUID"],
  array["l7AOLEVEL", "l6AOLEVEL", "l5AOLEVEL", "l4AOLEVEL", "l3AOLEVEL"],
  Array["l7FORMALNAME", "l6FORMALNAME", "l5FORMALNAME", "l4FORMALNAME", "l3FORMALNAME"],
  Array["l7SHORTNAME", "l6SHORTNAME", "l5SHORTNAME", "l4SHORTNAME", "l3SHORTNAME"],
  --Array["l7CENTSTATUS", "l6CENTSTATUS", "l5CENTSTATUS", "l4CENTSTATUS", "l3CENTSTATUS"],
  array[l7id, l6id, l5id, l4id, l3id]
  
from (
SELECT 
  l3.id as l3id,
  l3."FORMALNAME" AS "l3FORMALNAME",
  l3."SHORTNAME" AS "l3SHORTNAME",
  l3."AOLEVEL" AS "l3AOLEVEL",
  --l3."CENTSTATUS" AS "l3CENTSTATUS",
  --l3."AOID" AS "l3AOID",
  l3."AOGUID" AS "l3AOGUID",
  l3."PARENTGUID" AS "l3PARENTGUID",

  l4.*
FROM (SELECT
  l4.id AS l4id,
  l4."FORMALNAME" AS "l4FORMALNAME",
  -- l4.OFFNAME as l4OFFNAME,
  l4."SHORTNAME" AS "l4SHORTNAME",
  l4."AOGUID" AS "l4AOGUID",
  l4."PARENTGUID" AS "l4PARENTGUID",
  l4."AOLEVEL" AS "l4AOLEVEL",
  --l4."CENTSTATUS" AS "l4CENTSTATUS",
  --l4."AOID" AS "l4AOID",
  --fias.match_weight(l4."FORMALNAME", $1) as "l4PARENT_MATCH",
  -- 
  
  l5.*
FROM (SELECT
  l5.id AS l5id,
  l5."FORMALNAME" AS "l5FORMALNAME",
  -- l5.OFFNAME as l5OFFNAME,
  l5."SHORTNAME" AS "l5SHORTNAME",
  l5."AOGUID" AS "l5AOGUID",
  l5."PARENTGUID" AS "l5PARENTGUID",
  l5."AOLEVEL" AS "l5AOLEVEL",
  --l5."CENTSTATUS" AS "l5CENTSTATUS",
  --l5."AOID" AS "l5AOID",
  --fias.match_weight(l5."FORMALNAME", $1) as "l5PARENT_MATCH",
  
  l6.*
FROM (SELECT
  l6.id AS l6id,
  l6."FORMALNAME" AS "l6FORMALNAME",
  -- l6.OFFNAME as l6OFFNAME,
  l6."SHORTNAME" AS "l6SHORTNAME",
  l6."AOGUID" AS "l6AOGUID",
  l6."PARENTGUID" AS "l6PARENTGUID",
  l6."AOLEVEL" AS "l6AOLEVEL",
  --l6."CENTSTATUS" AS "l6CENTSTATUS",
  --l6."AOID" AS "l6AOID",
  --fias.match_weight(l6."FORMALNAME", $1) as "l6PARENT_MATCH",
  
  l7.*
FROM (SELECT
  id AS l7id,
  "FORMALNAME" AS "l7FORMALNAME",
  "SHORTNAME" AS "l7SHORTNAME",
  "AOGUID" AS "l7AOGUID",
  "PARENTGUID" AS "l7PARENTGUID",
  "AOLEVEL" AS "l7AOLEVEL"
  --"CENTSTATUS" AS "l7CENTSTATUS",
  --"AOID" AS "l7AOID"
        FROM
          fias."AddressObjects"
        WHERE -- не надо lower($1[1]) для регулярки!
        lower("FORMALNAME") ~ $1-- or lower("FORMALNAME") ~ lower($2) --[1] or (array_length($1, 1) > 1 and lower("FORMALNAME") ~ $1[array_length($1, 1)])
        --and "ACTSTATUS" = 1
) l7
LEFT JOIN fias."AddressObjects" l6 	ON l7."l7PARENTGUID" = l6."AOGUID" --AND l6.id<>l7.l7id -- AND (a.AOGUID<>@ParentGUID)
) l6
LEFT JOIN fias."AddressObjects" l5 	ON l6."l6PARENTGUID" = l5."AOGUID" --AND l5.id<>l6.l6id 
) l5
LEFT JOIN fias."AddressObjects" l4 	ON l5."l5PARENTGUID" = l4."AOGUID" --AND l4.id<>l5.l5id
) l4
LEFT JOIN fias."AddressObjects" l3 	ON l4."l4PARENTGUID" = l3."AOGUID" --AND l3.id<>l4.l4id --  AND l3.REGIONCODE = regcode 
) a;
$func$ LANGUAGE SQL;