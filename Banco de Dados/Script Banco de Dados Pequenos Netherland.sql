CREATE DATABASE Pequenos_Netherland;
USE Pequenos_Netherland;

-- Criando a tabela Permissoes
CREATE TABLE Permissoes (
    idPermissoes INT AUTO_INCREMENT PRIMARY KEY,
    termosDeUso ENUM('aceito') NOT NULL DEFAULT 'aceito',  -- Valor padrão 'aceito'
    politicaPrivacidade ENUM('aceito') NOT NULL DEFAULT 'aceito'  -- Valor padrão 'aceito'
);

-- Criando a tabela Usuario
CREATE TABLE Usuario (
    idUsuario INT AUTO_INCREMENT PRIMARY KEY,
    nomeCompleto VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    dataCadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    idPermissoes INT NOT NULL,
    FOREIGN KEY (idPermissoes) REFERENCES Permissoes(idPermissoes) ON DELETE RESTRICT
);

-- Criando a tabela CookiesPersonalizados
CREATE TABLE CookiesPersonalizados (
    idCookiesPersonalizados INT AUTO_INCREMENT PRIMARY KEY,
    tipoCookie VARCHAR(255) NOT NULL,
    valor ENUM('aceito', 'recusado') NOT NULL,
    idUsuario INT NOT NULL,
    idPermissoes INT NOT NULL,
    FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario) ON DELETE CASCADE,
    FOREIGN KEY (idPermissoes) REFERENCES Permissoes(idPermissoes) ON DELETE RESTRICT,
    UNIQUE (idUsuario, tipoCookie)
);


-- Criando a tabela Avaliacao (sem FK com Usuario)
CREATE TABLE Avaliacao (
    idAvaliacao INT AUTO_INCREMENT PRIMARY KEY,
    nota TINYINT CHECK (nota BETWEEN 0 AND 10),
    dataHora TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Criando a tabela DescricaoAvaliacao com as FKs especificadas
CREATE TABLE DescricaoAvaliacao (
    idDescricaoAvaliacao INT AUTO_INCREMENT PRIMARY KEY,
    idUsuario INT NOT NULL,
    idPermissoes INT NOT NULL,
    idAvaliacao INT NOT NULL,
    descricao TEXT NOT NULL,
    dataHora TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario) ON DELETE RESTRICT,
    FOREIGN KEY (idPermissoes) REFERENCES Permissoes(idPermissoes) ON DELETE RESTRICT,
    FOREIGN KEY (idAvaliacao) REFERENCES Avaliacao(idAvaliacao) ON DELETE RESTRICT
);




-- Inserir o usuário
INSERT INTO Usuario (nomeCompleto, email, senha, idPermissoes)
VALUES (?, ?, ?,?);

INSERT INTO Permissoes 
VALUES(default, default);

INSERT INTO CookiesPersonalizados (idUsuario, idPermissoes, tipoCookie, valor)
VALUES (?, ?, ?, ?);



-- Inserir ou atualizar avaliação
INSERT INTO Avaliacao (nota, dataHora)
VALUES (?, NOW());


-- Inserir ou atualizar descrição
INSERT INTO DescricaoAvaliacao (idUsuario, idPermissoes, idAvaliacao, descricao, dataHora)
VALUES (?, ?, ?, ?, NOW());




-- Atualizar o perfil do usuário (nome, email ou senha)
UPDATE Usuario u
INNER JOIN Permissoes p ON u.idPermissoes = p.idPermissoes
SET u.nomeCompleto = ?, u.email = ?, u.senha = ?
WHERE u.idUsuario = ?;


-- Consultar usuário para login
SELECT u.idUsuario, u.nomeCompleto, u.email, u.senha, p.idPermissoes
FROM Usuario u
INNER JOIN Permissoes p ON u.idPermissoes = p.idPermissoes
WHERE u.email = ? AND u.senha = ?;


--  calcular nota media e contar o numero de avaliaçoes
SELECT
    AVG(a.nota) AS nota_media,
    COUNT(*) AS total_avaliacoes
FROM Avaliacao a
INNER JOIN DescricaoAvaliacao da ON a.idAvaliacao = da.idAvaliacao;

-- encontrar as 5 melhores caracteristica
SELECT
    descricao,
    COUNT(*) AS contagem
FROM
    DescricaoAvaliacao
GROUP BY
    descricao
ORDER BY
    contagem DESC
LIMIT 5;

SELECT idUsuario, nomeCompleto, email
FROM Usuario
WHERE email = ?;

UPDATE Usuario 
SET senha = ?
WHERE email = ?;

-- Excluir o usuário e suas avaliações associadas
DELETE FROM Usuario WHERE idUsuario = ?;