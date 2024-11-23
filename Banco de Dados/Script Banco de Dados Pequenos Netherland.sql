-- Ola professora obrigado por validar meu script/modelagem e desculpe incomoda-la nesse sabado 
-- O script fiz espelhado na modelagem e realizei comentarios para a senhora ter uma compreenção melhor, talvez nem precisasse porque o leigo aqui sou eu kkakakakaakakak mas fiz
-- a regra de negocio se baseia na seguinte visão
-- O usuario so pode existir se ele aceitar as permissoes
-- o usuario pode tanto aceitar quanto não os cookies podendo escolher um ou mais tipos de cookies mas os cokkies sao de apenas um usuario
-- o usuario pode ter uma e apenas uma ou nenhuma avaiação assim como a avaliação pode ser de apenas um unico usuario mas a avaliação depende do usuario para existir
-- a avaliação pode ter varias descriçoes e a descrição apenas de uma avaliação e a para ter uma descrição deve haver uma avaliação antes
-- as funcionalidades do script fiz pensando em que atividdes quero que a API realize se tiver algo e remover, melhorar ou revisar pode me dizer por email ou comentar aqui ou diretamente no script, o que for melhor para a senhora 
-- no script a senhora podera ver algumas tags que a senhora n ensinou mas eu pesquisei e implementei porque achei o conseito delas legal como o duplicate, o cascade, o enum, o TIMESTAMP/CURRENT_TIMESTAMP...
-- se por acaso eu tiver implementado algum de forma errada ou no contexto errado posso ter me equivocado na minha compreenção, então poderia dizer se devo remover ou algo do tipo e me explicar caso eu tenha entendido algum deles errado
-- se ficar com duvida pode entrar em contato aguardo retorno e gradesço novamente a atenção

CREATE DATABASE Pequenos_Netherland;
USE Pequenos_Netherland;

-- Criando a tabela Permissoes
CREATE TABLE Permissoes (
    idPermissoes INT AUTO_INCREMENT PRIMARY KEY,
    termosDeUso ENUM('aceito') NOT NULL DEFAULT 'aceito',  -- Valor padrão 'aceito'
    politicaPrivacidade ENUM('aceito') NOT NULL DEFAULT 'aceito'  -- Valor padrão 'aceito'
);

CREATE TABLE Usuario (
    idUsuario INT AUTO_INCREMENT PRIMARY KEY,
    nomeCompleto VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    dataCadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    idPermissoes INT NOT NULL,
    FOREIGN KEY (idPermissoes) REFERENCES Permissoes(idPermissoes) ON DELETE CASCADE
);


CREATE TABLE CookiesPersonalizados (
    idCookiePersonalizado INT AUTO_INCREMENT PRIMARY KEY,
    idUsuario INT NOT NULL,
    tipoCookie VARCHAR(255) NOT NULL,
    valor ENUM('aceito', 'recusado') NOT NULL,
    idPermissoes INT,  -- Nova coluna para a permissão
    FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario) ON DELETE CASCADE,
    FOREIGN KEY (idPermissoes) REFERENCES Permissoes(idPermissoes) ON DELETE SET NULL, -- Ajuste a ação ON DELETE conforme necessário
    UNIQUE (idUsuario, tipoCookie)
);

-- Criando a tabela Avaliacao
CREATE TABLE Avaliacao (
    idAvaliacao INT AUTO_INCREMENT PRIMARY KEY,
    idUsuario INT NOT NULL,
    idPermissoes INT NOT NULL,  -- Nova coluna para a permissão da avaliação
    nota TINYINT CHECK (nota BETWEEN 0 AND 10),
    dataHora TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario) ON DELETE CASCADE,
    FOREIGN KEY (idPermissoes) REFERENCES Permissoes(idPermissoes) ON DELETE RESTRICT
);

-- Criando a tabela DescricaoAvaliacao
CREATE TABLE DescricaoAvaliacao (
    idDescricao INT AUTO_INCREMENT PRIMARY KEY,
    idAvaliacao INT NOT NULL, 
    idUsuario INT NOT NULL,  -- Nova coluna para o usuário da descrição
    idPermissoes INT NOT NULL,  -- Nova coluna para a permissão da descrição
    descricao TEXT NOT NULL,
    dataHora TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (idAvaliacao) REFERENCES Avaliacao(idAvaliacao) ON DELETE CASCADE,
    FOREIGN KEY (idUsuario) REFERENCES Usuario(idUsuario) ON DELETE RESTRICT,
    FOREIGN KEY (idPermissoes) REFERENCES Permissoes(idPermissoes) ON DELETE RESTRICT
);



-- Inserir o usuário
INSERT INTO Usuario (nomeCompleto, email, senha, idPermissoes)
VALUES (?, ?, ?,?);

INSERT INTO Permissoes 
VALUES(default, default);

INSERT INTO CookiesPersonalizados (idUsuario, tipoCookie, valor)
VALUES (?, ?, ?)
ON DUPLICATE KEY UPDATE
    valor = VALUES(valor);

-- Inserir ou atualizar avaliação
INSERT INTO Avaliacao (idUsuario, nota, idPermissoes)
VALUES (?, ?)
ON DUPLICATE KEY UPDATE nota = VALUES(nota);

-- Inserir ou atualizar descrição
INSERT INTO DescricaoAvaliacao (idAvaliacao, idUsuario, idPermissoes, descricao)
VALUES (?, ?, ?, ?)
ON DUPLICATE KEY UPDATE descricao = VALUES(descricao);


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

SELECT a.nota, da.descricao
FROM Avaliacao a
INNER JOIN DescricaoAvaliacao da ON a.idAvaliacao = da.idAvaliacao;

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
SET senha = ?  -- Aqui, você usaria o hash gerado com bcrypt para a nova senha
WHERE email = ?;

-- Excluir o usuário e suas avaliações associadas
DELETE FROM Usuario WHERE idUsuario = ?;
DELETE FROM Avaliacao WHERE idUsuario = ?;
DELETE FROM DescricaoAvaliacao WHERE idAvaliacao IN (SELECT idAvaliacao FROM Avaliacao WHERE idUsuario = ?);