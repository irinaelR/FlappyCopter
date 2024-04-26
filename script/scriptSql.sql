--DROP DATABASE HelicoptereGame;
CREATE DATABASE HelicoptereGame;

USE HelicoptereGame;

CREATE TABLE batiment(
    id_batiment INT PRIMARY KEY auto_increment,
    liste_point VARCHAR(255),
    typeBatiment VARCHAR(255)
);


CREATE TABLE helicoptere(
    id_helicoptere INT PRIMARY KEY auto_increment,
    nom VARCHAR(255),
    posiX DOUBLE,
    posiY DOUBLE
);
--format liste point x,y-x,y


INSERT INTO batiment (liste_point, typeBatiment) VALUES 
    ('50-600,50-620,150-620,150-600', 'H-depart'),

    
    ('200-100,200-800,250-800,250-100', 'obstacle'),
    ('400-100,400-800,450-800,450-100', 'obstacle'),
    ('600-70,600-800,650-800,650-70', 'obstacle'),


    ('700-100,700-120,750-120,750-100', 'H-arriver');


INSERT INTO helicoptere (nom, posiX, posiY) VALUES 
    ('Helico1', 70.0, 600.0);


CREATE TABLE TANKS (
    id_tank int PRIMARY KEY auto_increment,
    x_pos DOUBLE,
    y_pos DOUBLE,
    points INT
);

INSERT INTO TANKS (X_POS, Y_POS, POINTS) VALUES
    (300, 745, 50),
    (500, 745, 120),
    (25, 745, 10),
    (700, 745, 200);

