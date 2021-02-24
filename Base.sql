-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2021-02-08 18:35:01.395

-- tables
-- Table: Person
CREATE TABLE Person (
    idPerson int  NOT NULL IDENTITY(1, 1),
    nickname nvarchar(30)  NOT NULL,
    firstName nvarchar(30)  NOT NULL,
    lastName nvarchar(30)  NOT NULL,
    country nvarchar(40)  NOT NULL,
    birthdate date  NOT NULL,
	age int NULL,
    CONSTRAINT Person_pk PRIMARY KEY  (idPerson)
);

-- Table: Person_Team
CREATE TABLE Person_Team (
	idPersonTeam int NOT NULL IDENTITY (1,1),
    Team_idTeam int  NOT NULL,
    Person_idPerson int  NOT NULL,
    role nvarchar(30)  NOT NULL,
    joinDate date  NOT NULL,
	leftDate date NULL, 
    CONSTRAINT Person_Team_pk PRIMARY KEY  (idPersonTeam, Team_idTeam, Person_idPerson)
);

Drop Table Person_Team 


-- Table: Team
CREATE TABLE Team (
    idTeam int  NOT NULL IDENTITY(1, 1),
    name nvarchar(40)  NOT NULL,
    base nvarchar(40)  NOT NULL,
    foundationYear int  NOT NULL,
    CONSTRAINT Team_pk PRIMARY KEY  (idTeam)
);

-- foreign keys
-- Reference: Person_Team_Person (table: Person_Team)
ALTER TABLE Person_Team ADD CONSTRAINT Person_Team_Person
    FOREIGN KEY (Person_idPerson)
    REFERENCES Person (idPerson);

-- Reference: Person_Team_Team (table: Person_Team)
ALTER TABLE Person_Team ADD CONSTRAINT Person_Team_Team
    FOREIGN KEY (Team_idTeam)
    REFERENCES Team (idTeam);

-- End of file.

--DBCC CHECKIDENT('Person', RESEED, 0)
Alter Table Person Add Continent nvarchar(40)
Alter Table Team Add Region nvarchar(40) NULL






