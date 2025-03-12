/*
-- Aula 02
-- Json no MYSQL
create table foo (oldjson char(250));
insert into foo values ('{"name":"Bond","first":"James","ID":"007"}');
select * from foo;

create table bar(our_data JSON);
insert into bar values ('{"name":"Bond","first":"James","ID":"007"}');
select * from bar;

insert into foo values  ('{"name":"Smart","first":"Maxwell","ID":"86"');
insert into bar values  ('{"name":"Smart","first":"Maxwell","ID":"86"'); -- Erro, json inválido
INSERT INTO bar VALUES ('{"name":"Smart","first":"Maxwell","ID":"86"}');
select * from bar;
select json_pretty(our_data) from bar -- Json formatado no ctrl+c e ctrl+v

-- JSON KEYS e Extract
select * from countryinfo;
select doc from countryinfo where _id = 'USA';
select json_keys(doc) from countryinfo where _id = 'USA'; -- Obtém os nomes das propriedades do json
select json_keys(doc, '$.geography') from countryinfo where _id = 'USA'; -- $.'propriedade' = Obtém os nomes das propriedades de uma propriedade específica do json

select json_extract(doc) from countryinfo where _id = 'USA'; -- Erro, precisa informar o nome da propriedade

select json_extract(doc, '$.government') from countryinfo where _id = 'USA';

select json_extract(doc, '$.IdenpYear') from countryinfo where _id = 'USA'; -- Erro, nome da propriedade errado, vem com o valor nulo

select json_extract(doc, '$.IndepYear') from countryinfo where _id = 'USA';

select json_extract(doc, '$.government.HeadOfState') from countryinfo where _id = 'USA'; -- Busca uma subpropriedade de um json

select json_extract(doc, '$.government.HeadOfState') as HeadOfState  from countryinfo;

select json_extract(doc, '$.government.HeadOfState') as HeadOfState, json_extract(doc, '$.IndepYear') as IdenpYear  from countryinfo; -- Parsear = mostrar as propriedades de forma isolada

SELECT JSON_EXTRACT(doc, "$.GNP") as GNP
  , JSON_EXTRACT(doc, "$.Code") as Code
  , JSON_EXTRACT(doc, "$.Name") as Name
  , JSON_EXTRACT(doc, "$.IndepYear") as IndepYear
  , JSON_EXTRACT(doc, "$.geography.Region") as Region
  , JSON_EXTRACT(doc, "$.geography.Continent") as Continent
  , JSON_EXTRACT(doc, "$.geography.SurfaceArea") as SurfaceArea
  , JSON_EXTRACT(doc, "$.government.HeadOfState") as HeadOfState
  , JSON_EXTRACT(doc, "$.government.GovernmentForm") as GovernmentForm
  , JSON_EXTRACT(doc, "$.demographics.Population") as Population
  , JSON_EXTRACT(doc, "$.demographics.LifeExpectancy") as LifeExpectancy
  FROM countryinfo;

SELECT JSON_EXTRACT(doc, "$.Code") as Code, replace(JSON_EXTRACT(doc, "$.Code"), '"', '') as code2 from countryinfo;

-- Aplicando filtros e agrupamentos
SELECT 
	JSON_EXTRACT(doc, "$.geography.Continent") as Continent, 
    sum(JSON_EXTRACT(doc, "$.demographics.Population")) as Population,
    avg(JSON_EXTRACT(doc, "$.demographics.LifeExpectancy"))
from countryinfo
where JSON_EXTRACT(doc, "$.government.GovernmentForm")  LIKE ('%Monarchy%')
and JSON_EXTRACT(doc, "$.demographics.Population") >= 10000000
group by JSON_EXTRACT(doc, "$.geography.Continent")
order by 2;

-- JSON contains Path
create table x (y JSON);
insert into x values ('{"nome":"João",  "telefone": "2293-3343"}');
insert into x values ('{"nome":"Jonas"}');

select * from x;

select json_contains_path(Y, 'ONE', '$.telefone') from x; -- Checar a estrutura do json

insert into x values ('{"nome":"Alberto",  "endereco": "Rua X numero Y"}');
select json_contains_path(Y, 'ONE', '$.telefone', '$.endereco') from x; 

select Y from x;

insert into x values ('{"nome":"Maria",  "endereco": "Rua X numero Y", "telefone": "2293-3343"}');

select json_contains_path(Y, 'ONE', '$.telefone', '$.telefone', '$.endereco') from x; -- Um dos campos pesquisado

select json_contains_path(Y, 'ALL', '$.telefone', '$.telefone', '$.endereco') from x; -- Apenas se todos os campos pesquisados houver


-- JSON contains e Search

select * from x;

select JSON_CONTAINS(Y, '"2293-3343"', '$.telefone') from x; -- pesquisar o valor em uma determinada propriedade, precisa colocar as aspas duplas em campos textos

select * from x where JSON_CONTAINS(Y, '"2293-3343"', '$.telefone') = 1;
select * from x where JSON_extract(Y, '$.telefone') = '2293-3343';

select JSON_search(Y, 'ONE', '2293-3343'), y from x; -- pesquisar o valor nas propriedades do json e retorna a primeira propriedades que tem


insert into x values ('{"nome":"Katia",  "endereco": "Rua X numero Y", "telefone": "2293-3343", "telefone2": "2293-3343"}');

select * from x;

select JSON_search(Y, 'ONE', '2293-3343'), y from x;

select JSON_search(Y, 'ALL', '2293-3343'), y from x; -- pesquisar o valor nas propriedades do json e retornatodas as propriedades que tem


-- Aula 03
-- Array Update e Array Insert

create database testjson;
use testjson

create table x (y json);

insert into x values ('["A","B","C"]');

select * from x;

delete from x;
insert into x values (json_array("A","B","C")); -- Para arrays mais complexos

select * from x;

update x set y = json_array_append(y, "$[0]", "A1");-- Inseres um dado na posição especificada, tranforma o valor em um array

select * from x;

update x set y = json_array_append(y, "$[1]", "B1", "$[2]", "C1");

select * from x;
update x set y = json_array_append(y, "$", "D1");

select * from x;

update x set y = json_array_insert(y, "$[3]", "E1"); -- Inseres um dado antes da posição especificada

select * from x;

update x set y = json_array_insert(y, "$[0]", "AX");

select * from x;
update x set y = json_array_insert(y, "$[1][1]", "K");

select * from x;

-- JSON Insert, Replace e Remove

truncate x;
insert into x values ('{"key1" : "value1"}');
select * from x;
update x set y = json_insert(y, "$.key2", "value2"); -- insere uma nova propriedade no json
select * from x;
update x set y = json_insert(y, "$.key3", "value3", "$.key4", "value4");
select * from x;
update x set y = json_insert(y, "$.key1", "value1x", "$.key5", "value5"); -- não altera o valor de uma propriedade
select * from x;
update x set y = json_replace(y, "$.key1", "value1x"); -- altera o valor de uma propriedade já existente
select * from x;
update x set y = json_replace(y, "$.key2", "value2x", "$.key6", "value6x"); -- ignora caso a propriedade não exista
select * from x;
update x set y = json_remove(y, "$.key1");
select * from x;
update x set y = json_remove(y, "$.key7"); -- ignora caso a propriedade não exista
select * from x;
update x set y = json_remove(y, "$.key5", "$.key3");
select * from x;
update x set y = json_set(y, "$.key1", "value1y", "$.key5", "value5y"); -- Vria uma propriedade caso não exista e atualiza uma propriedade caso ela exista
select * from x;

-- JSON MERGE PRESERVE
-- world_x 
select json_merge_preserve('[1,2]', '[true, false]'); -- junta dois array
select json_merge_preserve('[1,2]', '[3, 4]');
select json_merge_preserve('[1,2]', '[2, 4]'); -- não agrupa valores iguais

select json_merge_preserve('{"nome" : "James", "sobrenome":"Bond"}', '{"nome" : "Maxwell", "sobrenome":"Smart"}'); -- propriedades em comum e transformada em array

select json_merge_preserve('{"nome" : "James", "sobrenome":"Bond"}', '{"nome" : "Maxwell", "sobrenome":"Smart", "salario":1000}'); -- segundo json tem uma propriedade que não tem no primeiro

select json_merge_preserve('{"id":"007", "nome" : "James", "sobrenome":"Bond"}', '{"nome" : "Maxwell", "sobrenome":"Smart", "salario":1000}'); 

select json_merge_preserve('{"id":"007", "nome" : "James", "sobrenome":"Bond"}', '{"nome" : "Maxwell", "sobrenome":"Smart", "salario":1000}', '{"nome" : "Bárbara", "cidade": "Riod e janeiro"}'); 

-- JSON MERGE PATCH
-- existe no primeiro e não existe no segundo
-- existe no segundo e não existe no primeiro
-- propriedades em comum vale as propriedades do segundo



select json_merge_patch('{"nome": "James", "sobrenome": "Bond"}', '{"salario": 10000, "cidade": "Rio de Janeiro"}');

select json_merge_patch('{"nome": "James", "sobrenome": "Bond"}', '{"nome": "Maxwell", "cidade": "Rio de Janeiro"}'); -- manter a propriedade do segundo valor

select json_merge_patch('{"nome": "James", "sobrenome": "Bond"}', '{"salario": 10000, "cidade": "Rio de Janeiro"}'),
json_merge_preserve('{"nome": "James", "sobrenome": "Bond"}', '{"salario": 10000, "cidade": "Rio de Janeiro"}');


select json_merge_patch('{"nome": "James", "sobrenome": "Bond"}', '{"nome": "Maxwell", "cidade": "Rio de Janeiro"}'),
json_merge_preserve('{"nome": "James", "sobrenome": "Bond"}', '{"nome": "Maxwell", "cidade": "Rio de Janeiro"}');


select json_merge_patch('[1,2]', '[true, false]');
select json_merge_patch('{"array1" : [1,2]}', '{"array2" : [true, false]}');
select json_merge_patch('{"array2" : [1,2]}', '{"array2" : [true, false]}');

-- Aula 04
-- JSON DEPTH
-- ver a profundidade do json, nivel a nivel

select json_depth('{}');
select json_depth('{"nome":"João"}');
select json_depth('{"nome":"João", "filho":{}}'); -- abrir e fechar {} só conta no ínício
select json_depth('{"nome":"João", "filho":{"nome":"Pedro"}}');
select json_depth('{"nome":"João", "filho":{"nome":"Pedro", "neto": {"nome":"Julio"}}}');

select doc from countryinfo;
select json_depth(doc) from countryinfo;
select doc from countryinfo where json_depth(doc) <> 3;

-- JSON LENGTH
select json_length('{}');
select json_length('{"nome":"João"}');
select json_length('{"nome":"João", "sobrenome":"Machado"}');
select json_length('{"nome":"João", "sobrenome":"Machado", "hobby":["proaia"]}');
select json_length('{"nome":"João", "sobrenome":"Machado", "hobby":["proaia", "volei"]}');
select json_length('{"nome":"João", "sobrenome":"Machado", "hobby":["proaia", "volei"], "filho":{"nome":"Carlos"}}');
select json_length('["praia", "volei", "futebol"]');
select json_length('{"hobby":["praia", "volei", "futebol"]}');

select doc from countryinfo;
select json_length(doc) from countryinfo;
select doc from countryinfo where  json_length(doc) <> 8;

-- JSON TYPE e JSON VALID

select json_type('{"a":[10,true]}');
select json_extract('{"a":[10,true]}', '$.a');
select json_type(json_extract('{"a":[10,true]}', '$.a'));
select json_extract('{"a":[10,true]}', '$.a[0]');
select json_type(json_extract('{"a":[10,true]}', '$.a[0]'));
select json_type(json_extract('{"a":[10,true]}', '$.a[1]'));


select json_valid('{"a":[10,true]}');
select json_valid('{"a":[10,true]'); -- json inválido
-- Aula 05
create database empresa
select * from tb_object_funcionario;
select json_pretty(json) from tb_object_funcionario;

select 
replace(json_extract(JSON, '$.Primeiro_Nome'), '"', ''), 
replace(json_extract(JSON, '$.Data_Nascimento'), '"', ''), 
json_extract(JSON, '$.Salario')
from tb_object_funcionario;


select 
json_unquote(json_extract(JSON, '$.Primeiro_Nome')), 
json_unquote(json_extract(JSON, '$.Data_Nascimento')), 
json_extract(JSON, '$.Salario')
from tb_object_funcionario;

select 
json_type(json_extract(JSON, '$.Primeiro_Nome')), 
json_type(json_extract(JSON, '$.Data_Nascimento')), 
json_type(json_extract(JSON, '$.Salario'))
from tb_object_funcionario;


select 
json_unquote(json_extract(JSON, '$.Primeiro_Nome')), 
json_unquote(json_extract(JSON, '$.Data_Nascimento')), 
json_extract(JSON, '$.Salario')
from tb_object_funcionario
where year(json_extract(JSON, '$.Data_Nascimento')) >= 1980;


select '["praia", "futebol", "cinema"]';
select json_extract('["praia", "futebol", "cinema"]','$[1]');

select '{"hobby":["praia", "futebol", "cinema"]}';
select json_extract('{"hobby":["praia", "futebol", "cinema"]}','$[1]');
select json_extract('{"hobby":["praia", "futebol", "cinema"]}','$.hobby[1]');  
select json_extract('{"hobby":[{"nome":"praia","local":"Ar Lire"}, {"nome":"futebol","local":"Ar Lire"}, {"nome":"cinema","local":"fechado"}]}', "$.hobby[1]");
select json_extract('{"hobby":[{"nome":"praia","local":"Ar Lire"}, {"nome":"futebol","local":"Ar Lire"}, {"nome":"cinema","local":"fechado"}]}', "$.hobby[1].nome");

select json_extract('{"hobby":[{"nome":"praia","local":"Ar Lire"}, {"nome":"futebol","local":"Ar Lire"}, {"nome":"cinema","local":"fechado"}]}', "$.hobby[0].nome")
union
select json_extract('{"hobby":[{"nome":"praia","local":"Ar Lire"}, {"nome":"futebol","local":"Ar Lire"}, {"nome":"cinema","local":"fechado"}]}', "$.hobby[1].nome")
union 
select json_extract('{"hobby":[{"nome":"praia","local":"Ar Lire"}, {"nome":"futebol","local":"Ar Lire"}, {"nome":"cinema","local":"fechado"}]}', "$.hobby[2].nome");

create table x (y JSON)

insert into x values ('{"hobby":[{"nome":"praia","local":"Ar Lire"}, {"nome":"futebol","local":"Ar Lire"}, {"nome":"cinema","local":"fechado"}]}');
select y from x;

select json_extract(y, "$.hobby[0].nome") as nome,json_extract(y, "$.hobby[0].local") as local from x
union
select json_extract(y, "$.hobby[1].nome") as nome,json_extract(y, "$.hobby[1].local") as local from x
union 
select json_extract(y, "$.hobby[2].nome") as nome,json_extract(y, "$.hobby[2].local") as local from x;

update x set y = '{"hobby":[{"nome":"praia","local":"Ar Lire"}, {"nome":"futebol","local":"Ar Lire"}, {"nome":"cinema","local":"fechado"}, {"nome":"piscina","local":"Ar Livre"}]}';

select json_extract(y, "$.hobby[0].nome") as nome,json_extract(y, "$.hobby[0].local") as local from x
union
select json_extract(y, "$.hobby[1].nome") as nome,json_extract(y, "$.hobby[1].local") as local from x
union 
select json_extract(y, "$.hobby[2].nome") as nome,json_extract(y, "$.hobby[2].local") as local from x
union 
select json_extract(y, "$.hobby[3].nome") as nome,json_extract(y, "$.hobby[3].local") as local from x;

select T2.nome, T2.local from x
cross join 
JSON_TABLE (json_extract(y, '$.hobby'), '$[*]'
columns (nome varchar(10) path '$.nome',local varchar(10) path '$.local')) T2;

update x set y = '{"hobby":[{"nome":"praia","local":"Ar Lire"}, {"nome":"futebol","local":"Ar Lire"}, {"nome":"cinema","local":"fechado"}, {"nome":"piscina","local":"Ar Livre"}, {"nome":"tenis","local":"Ar Livre"}]}';

select T2.nome, T2.local from x
cross join 
JSON_TABLE (json_extract(y, '$.hobby'), '$[*]'
columns (nome varchar(10) path '$.nome',local varchar(10) path '$.local')) T2;

*/

select 
	json_unquote(json_extract(json, '$.Cpf')) as CPF,
    json_unquote(json_extract(json, '$.Primeiro_Nome')) as primeiro_nome,
    json_unquote(json_extract(json, '$.Nome_Meio')) as nome_meio,
    json_unquote(json_extract(json, '$.Ultimo_Nome')) as ultimo_nome,
    TD.NOME_DEPARTAMENTO,
T1.nome_dependente, T1.sexo, T1.parentesco, T1.data_nascimento from tb_object_funcionario
cross join 
JSON_TABLE (json_extract(json, '$.Dependentes'), '$[*]'
columns (
	nome_dependente varchar(30) path '$.Nome_Dependente',
    sexo varchar(2) path '$.Sexo',
    parentesco varchar(20) path '$.Parentesco',
    data_nascimento datetime path '$.Data_Nascimento'
	)
) T1
inner join tb_departamento TD on TD.NUMERO_DEPARTAMENTO = json_unquote(json_extract(json, '$.Numero_Departamento'));