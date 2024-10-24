
CREATE DATABASE RESIDENCIAL;

CREATE TABLE PESSOA
(
	Id_pessoa SERIAL PRIMARY KEY,
	Nome_pessoa VARCHAR(80),
	data_nasci DATE,
	Sexo CHAR(3),
	BI VARCHAR(15),
	Tel_pessoa INT,
	Email_pessoa VARCHAR(50),
	Profissao VARCHAR(50)
);


CREATE TABLE PROPRIETARIO
(
	Cod_proprietario SERIAL PRIMARY KEY,
	id_pessoa INT,
	FOREIGN KEY (id_pessoa) REFERENCES PESSOA(id_pessoa),
	Data_aquisicao DATE
);

CREATE TABLE APARTAMENTO
(
	Cod_aparta SERIAL PRIMARY KEY,
	N_quarto INT,
	Bloco INT,
	Andar INT,	
	Tel_apartamento INT,
	Cod_proprietario INT,
	FOREIGN KEY (Cod_proprietario) REFERENCES PROPRIETARIO(Cod_proprietario),
	preco MONEY
);

CREATE TABLE MORADOR
(
	Cod_morador SERIAL PRIMARY KEY,
	Id_pessoa int,
	FOREIGN KEY (Id_pessoa) REFERENCES PESSOA(Id_pessoa),
	Cod_aparta int,
	FOREIGN KEY (Cod_aparta) REFERENCES APARTAMENTO(Cod_aparta),
	Data_entrada DATE,
	Data_saida DATE
);


CREATE TABLE PAGAMENTO
(
	Cod_paga SERIAL PRIMARY KEY,
	Data_paga DATE,
	Cod_morador INT,
	FOREIGN KEY (Cod_morador) REFERENCES MORADOR(Cod_morador),	
	Valor_pagamento MONEY,
	Taxa_multa MONEY,
	Taxa_condominio MONEY,
	Mes VARCHAR(30)
);


INSERT INTO PESSOA(Nome_pessoa, data_nasci, Sexo, BI, Tel_pessoa, Email_pessoa, Profissao)
VALUES ('Mbuaki', '08-09-1984', 'F', '12889900', 933667811, 'maria@gmail.com', 'Estudante'),
('Paulino', '14-01-2000', 'M', '39044400', 922338999, 'paulino@gmail.com', 'Tecnico Informatico'),
('Kisangala', '09-05-1989', 'F', '79899993', 922668379, 'kisangala@gmail.com', 'Enfermeira'),
('Anselmo', '04-04-1999', 'M', '78993722', 934882892, 'anselmo@gmail.com', 'Medico');

INSERT INTO PESSOA(Nome_pessoa, data_nasci, Sexo, BI, Tel_pessoa, Email_pessoa, Profissao)
VALUES ('Mengawaku', '05-09-2000', 'M', '55589900', 922363915, 'mengawaku@gmail.com', 'Estudante');

INSERT INTO PROPRIETARIO(id_pessoa, Data_aquisicao)
VALUES (1, '12-12-2010'), (2, '10-12-2004'), (3, '11-09-2013');

INSERT INTO APARTAMENTO(N_quarto, Bloco, Andar, Tel_apartamento, Cod_proprietario, preco)
VALUES (3, 1, 1, 097887888, 3,  1200), (3, 1, 1, 993889999, 1, 1300),(2, 2, 2, 892999999, 2, 1000),
(2, 2, 2, 898098999, 1, 900),(2, 2, 2, 893448889, 3, 900);

INSERT INTO MORADOR(Id_pessoa, Cod_aparta, Data_entrada, Data_saida)
VALUES (4, 2, '12-12-2018', '12-12-2021'),(1, 3, '10-12-2011', null),
(2, 4, '11-09-2020', '21-12-2023'),(3, 1, '12-12-2022', null);
														  
INSERT INTO MORADOR(Id_pessoa, Cod_aparta, Data_entrada, Data_saida)			-- MORADOR QUE NAO POSSUI APARTAMENTO
VALUES (5, null, '12-12-2018', '12-12-2021');										  

INSERT INTO PAGAMENTO(Data_paga, Cod_morador)
VALUES ('06-12-2023', 1),('15-12-2023', 2),('03-12-2023', 3),
('05-01-2024', 4),('11-01-2024', 3),('12-01-2024', 4);

-- 2) VISUALIZA TODOS OS APARTAMENTOS QUE NAO TEM MORADORES.

SELECT *
FROM APARTAMENTO AS A
WHERE NOT EXISTS
(
	SELECT *
	FROM MORADOR AS M
	WHERE A.Cod_aparta = M.Cod_aparta
);

-- 3) VISUALIZA OS NOMES DOS PROPRIETARIOS QUE TEM MAIS DE UM APARTAMENTOS.

SELECT PS.Nome_pessoa
FROM PESSOA AS PS
INNER JOIN PROPRIETARIO AS P
ON PS.Id_pessoa = P.Id_pessoa
INNER JOIN APARTAMENTO AS A
ON A.Cod_proprietario = P.Cod_proprietario
GROUP BY PS.Nome_pessoa
HAVING COUNT(P.Cod_proprietario) > 1;

-- 4) SELECIONE O NOME DOS MORADORES QUE JA VIVERAM A MAIS DE DOIS APARTAMENTOS.
														  
SELECT PS.Nome_pessoa
FROM PESSOA AS PS
INNER JOIN MORADOR AS M
ON PS.Id_pessoa = M.Id_pessoa
INNER JOIN APARTAMENTO AS A
ON A.Cod_aparta = M.Cod_aparta
GROUP BY PS.Nome_pessoa
HAVING COUNT(M.Cod_aparta) > 2;														  
														  
-- 5) VISUALIZA TODOS OS PROPRIETARIOS QUE NAO VIVEM NOS SEUS APARTAMENTOS.
														  
SELECT * FROM Proprietario AS Pr WHERE Pr.id_pessoa IN
	(SELECT M.id_pessoa FROM MORADOR AS M WHERE M.id_pessoa NOT IN
	(SELECT A.proprietario FROM APARTAMENTO AS A WHERE
			A.proprietario = Pr.cod_proprietario and M.apartamento = A.cod_aparta));

/* SELECT * FROM Proprietario AS Pr WHERE Pr.id_pessoa IN
								 (SELECT M.id_pessoa FROM Morador AS M WHERE M.id_pessoa NOT IN
								 (SELECT Pr.id_pessoa FROM Proprietario AS Pr WHERE Pr.cod_proprietario IN
								 (SELECT Ap.proprietario FROM Apartamento AS Ap WHERE Pr.id_pessoa = M.id_pessoa AND M.apartamento = Ap.cod_aparta))); */

/* 6) CALCULE A TAXA DE MULTA DE 5% PARA OS MORADORES QUE EFECTUARAM O PAGAMENTO
	  DEPOIS DO DIA 10 DO MES E VISUALIZA O NOME DO MORADOR, VALOR DO PAGAMENTO, A TAXA DO CONDOMINIO E O MES. */

ALTER TABLE Pagamento ALTER COLUMN mes tinyint;
ALTER TABLE Pagamento ALTER COLUMN taxa_multa decimal(5,2);
ALTER TABLE Pagamento ALTER COLUMN taxa_condominio decimal(5,2);

UPDATE PAGAMENTO SET taxa_multa = 0.05 WHERE (TO_CHAR(Pg.data_paga, 'dd') > '10' OR CAST(TO_CHAR(Pg.data_paga, 'mm') AS int) > Pg.mes); 

-- VER OS MORADORES QUE EFECTUARAM O PAGAMENTO DEPOIS DO DIA 10 DO MES.

SELECT P.nome_pessoa, Pg.valor_pagamento, Pg.taxa_condominio, Pg.mes FROM PAGAMENTO AS Pg INNER JOIN PESSOA AS P
	ON Pg.moradores = P.id_pessoa
	WHERE (TO_CHAR(Pg.data_paga, 'dd') > '10' OR CAST(TO_CHAR(Pg.data_paga, 'mm') AS int) > Pg.mes);
														  
/* 7) EM FUNCAO DO EXE6, FAZ A SOMA DO VALOR A PAGAR (VALOR DO PAGAMENTO + TAXA DA MULTA + TAXA DO CONDOMINIO) 
 	  E VISUALIZA O NOME DO MORADOR, ANO DO PAGAMENTO E O VALOR A SE PAGAR.	*/

SELECT P.nome_pessoa, TO_CHAR(Pg.data_paga, 'yyyy') AS Ano_Pagamento,
	   (CAST(Pg.valor_pagamento AS NUMERIC) + Pg.taxa_multa * CAST(Pg.valor_pagamento AS NUMERIC) + Pg.taxa_condominio) AS Valor_a_Pagar
	   FROM PAGAMENTO AS Pg INNER JOIN PESSOA AS P ON Pg.moradores = P.id_pessoa
	   WHERE (TO_CHAR(Pg.data_paga, 'dd') > '10' OR CAST(TO_CHAR(Pg.data_paga, 'mm') AS int) > Pg.mes);	
														  
-- 8) ACTUALIZA A TAXA DE MULTA DE 7% PARA TODOS OS MORADORES QUE VIVEM NOS SEUS APARTAMENTOS.														  

INSERT INTO Pagamento(data_paga, morador, valor_pagamento, taxa_condominio, mes) VALUES('2023-11-06', 4, 250, 0.03, 11);
SELECT * FROM Pagamento;

UPDATE Pagamento SET taxa_multa = 0.07 WHERE morador IN
				 (SELECT M.cod_morador FROM Morador AS M WHERE M.id_pessoa IN
				 (SELECT Ap.proprietario FROM Apartamento AS Ap WHERE M.id_pessoa = Ap.proprietario AND M.apartamento = Ap.cod_aparta));												  
														  
														  														  
-- 9) ELIMINA TODOS OS MORADORES QUE VIVEM NOS SEUS APARTAMENTOS.
DELETE FROM Morador WHERE cod_morador IN
				    (SELECT M.cod_morador FROM Morador AS M WHERE M.id_pessoa IN
				    (SELECT Pr.id_pessoa FROM Proprietario AS Pr WHERE Pr.cod_proprietario IN
					(SELECT Ap.proprietario FROM Apartamento AS Ap WHERE Pr.id_pessoa = M.id_pessoa AND M.apartamento = Ap.cod_aparta)));												  
														  
														  
SELECT * FROM PESSOA;
SELECT * FROM PROPRIETARIO;
SELECT * FROM APARTAMENTO;
SELECT * FROM MORADOR;
SELECT * FROM PAGAMENTO;
													  
















