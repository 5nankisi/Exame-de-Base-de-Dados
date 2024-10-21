CREATE DATABASE Prova;
USE Prova;


CREATE TABLE Pessoa(
id_pessoa int IDENTiTY,
nome_pessoa varchar(30) UNIQUE NOT NULL,
data_nasci date,
sexo char(1),
bi varchar(15),
tel_pessoa varchar(15),
email_pessoa varchar(100),
profissao varchar(20),

PRIMARY KEY(id_pessoa)
);

CREATE TABLE Proprietario(
cod_proprietario int IDENTITY,
id_pessoa int,
data_aquisicao date,

PRIMARY KEY(cod_proprietario),
FOREIGN KEY(id_pessoa) REFERENCES Pessoa(id_pessoa)
);

CREATE TABLE Apartamento(
cod_aparta int IDENTITY,
n_quarto tinyint,
bloco smallint,
andar smallint,
tel_apartamento varchar(15),
proprietario int,
preco money,

PRIMARY KEY(cod_aparta),
FOREIGN KEY(proprietario ) REFERENCES Proprietario(cod_proprietario)
);

CREATE TABLE Morador(
cod_morador int IDENTITY,
id_pessoa int,
apartamento int,
data_entrada date,
data_saida date,

PRIMARY KEY(cod_morador),
FOREIGN KEY(id_pessoa) REFERENCES Pessoa(id_pessoa),
FOREIGN KEY(apartamento) REFERENCES Apartamento(cod_aparta),
);

CREATE TABLE Pagamento(
cod_paga int IDENTITY,
data_paga date,
morador int,
valor_pagamento money,
taxa_multa money,
taxa_condominio money,
mes varchar(10),

PRIMARY KEY(cod_paga),
FOREIGN KEY(morador) REFERENCES Morador(cod_morador)
);


INSERT INTO Pessoa VALUES('Mbuaki', '1984-09-08', 'M', '12889900', '933667811', 'mbuaki@gmail.com', 'Estudante'),
						 ('Paulinna', '2000-01-14', 'F', '39044400', '922338099', 'paulina@gmail.com', 'Tecnico Informatico'),
						 ('Kisangala', '1989-05-09', 'F', '79890903', '922668379', 'kisangala@gmail.com', 'Enfermeira'),
						 ('Anselmo', '1999-04-04', 'M', '78993722', '934882892', 'anselmo@gmail.com', 'Medico');

INSERT INTO Proprietario VALUES(1, '2010-12-12'),
							   (2, '2004-12-10'),
							   (3, '2013-09-11');

INSERT INTO Apartamento VALUES(3, 1, 1, '097887888', 3, 1200),
							  (3, 1, 1, '993889100', 1, 1300),
							  (2, 2, 2, '892123456', 2, 1000),
							  (2, 2, 2, '898098128', 1, 900),
							  (2, 1, 1, '893488045', 3, 900);

INSERT INTO Morador(id_pessoa, apartamento, data_entrada) VALUES(3, 1, '2022-12-12');


SELECT * FROM Pessoa;
SELECT * FROM Proprietario;
SELECT * FROM Apartamento;
SELECT * FROM Morador;

-- 1. Visualize todos os apartamentos que não têm moradores.
SELECT * FROM Apartamento WHERE cod_aparta NOT IN (SELECT apartamento FROM Morador);

-- 2. Visualize os nomes dos proprietarios que têm mais de um apartamento.
SELECT P.nome_pessoa FROM Pessoa AS P INNER JOIN Proprietario AS Pr ON P.id_pessoa = Pr.id_pessoa
									  INNER JOIN Apartamento AS Ap ON Ap.proprietario = Pr.cod_proprietario
									  GROUP BY P.nome_pessoa HAVING COUNT(Ap.proprietario) > 1;

-- 3. Selecione os nomes dos moradores que já viveram a mais de dois apartamentos.
SELECT P.nome_pessoa FROM Pessoa AS P INNER JOIN Morador AS M ON P.id_pessoa = M.id_pessoa GROUP BY P.nome_pessoa HAVING COUNT(M.apartamento) > 2;

-- 4. Visualize todos os proprietários que não vivem nos seus apartamentos.
SELECT * FROM Proprietario AS Pr WHERE Pr.id_pessoa IN
		 (SELECT M.id_pessoa FROM Morador AS M WHERE M.id_pessoa NOT IN
		 (SELECT Ap.proprietario FROM Apartamento AS Ap WHERE Pr.cod_proprietario = Ap.proprietario AND M.apartamento = Ap.cod_aparta));

/* SELECT * FROM Proprietario AS Pr WHERE Pr.id_pessoa IN
								 (SELECT M.id_pessoa FROM Morador AS M WHERE M.id_pessoa NOT IN
								 (SELECT Pr.id_pessoa FROM Proprietario AS Pr WHERE Pr.cod_proprietario IN
								 (SELECT Ap.proprietario FROM Apartamento AS Ap WHERE Pr.id_pessoa = M.id_pessoa AND M.apartamento = Ap.cod_aparta))); */

-- 5. Calcule a taxa de multa de 5% para os moradores que efectuaram o pgamento depois do dia 10 do mês e visualize o nome do morador,
--	  valor de pagamento, a taxa de condominio e o mês.
ALTER TABLE Pagamento ALTER COLUMN mes tinyint;
ALTER TABLE Pagamento ALTER COLUMN taxa_multa decimal(5,2);
ALTER TABLE Pagamento ALTER COLUMN taxa_condominio decimal(5,2);

INSERT INTO Pagamento(data_paga, morador, valor_pagamento, taxa_condominio, mes) VALUES('2023-12-06', 1, 300, 0.03, 11);
SELECT * FROM Pagamento;

UPDATE Pagamento SET taxa_multa = 0.05 WHERE DAY(data_paga) > 10 OR MONTH(data_paga) > mes;
UPDATE Pagamento SET taxa_condominio = 0.03;

SELECT P.nome_pessoa, Pg.valor_pagamento, Pg.taxa_condominio, Pg.mes FROM Pagamento AS Pg INNER JOIN Morador AS M
																	 ON Pg.morador = M.cod_morador INNER JOIN Pessoa AS P ON M.id_pessoa = P.id_pessoa
																	 WHERE DAY(Pg.data_paga) > 10 OR MONTH(Pg.data_paga) > mes;

-- 6. Em função do exercício nº 5 faz a soma do valor à pagar (Valor do pagamento + taxa de multa + taxa de condominio), por fim,
--	  visualize o nome do morador, ano de pagamento e o valor a pagar.
SELECT P.nome_pessoa, Year(Pg.data_paga), (Pg.valor_pagamento + Pg.taxa_multa * Pg.valor_pagamento + Pg.taxa_condominio * Pg.valor_pagamento) AS 'Valor a Pagar'
	FROM Pagamento AS Pg INNER JOIN Morador AS M
	ON Pg.morador = M.cod_morador INNER JOIN Pessoa AS P ON M.id_pessoa = P.id_pessoa
	WHERE DAY(Pg.data_paga) > 10 OR MONTH(Pg.data_paga) > mes;

-- 7. Atualiza a taxa_multa de 7% para todos os moradores que vivem nos seus apartamentos.
INSERT INTO Pagamento(data_paga, morador, valor_pagamento, taxa_condominio, mes) VALUES('2023-11-06', 4, 250, 0.03, 11);
SELECT * FROM Pagamento;

UPDATE Pagamento SET taxa_multa = 0.07 WHERE morador IN
									   (SELECT M.cod_morador FROM Morador AS M WHERE M.id_pessoa IN
									   (SELECT Ap.proprietario FROM Apartamento AS Ap WHERE M.id_pessoa = Ap.proprietario AND M.apartamento = Ap.cod_aparta));

-- 8. Elimina todos os mordores que vivem nos seus apartamentos
DELETE FROM Morador WHERE cod_morador IN
				    (SELECT M.cod_morador FROM Morador AS M WHERE M.id_pessoa IN
				    (SELECT Pr.id_pessoa FROM Proprietario AS Pr WHERE Pr.cod_proprietario IN
					(SELECT Ap.proprietario FROM Apartamento AS Ap WHERE Pr.id_pessoa = M.id_pessoa AND M.apartamento = Ap.cod_aparta)));
