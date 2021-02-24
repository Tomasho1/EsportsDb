--Exec Procedures
Exec TransferPerson 3, 3, N'Benched player', '2020-09-13', '2021-01-21'
Exec TransferPerson 3, 1, N'Player', '2021-01-21', null 

Exec TransferPerson 2, 1, N'Player', '2021-01-21', null


Exec TransferPerson 1, 3, N'Player', '2018-06-23', '2020-09-13'
Exec TransferPerson 1, 3, N'Benched player', '2020-09-13', '2021-01-09'
Exec TransferPerson 1, 2, N'Player', '2021-01-09', null

Exec TransferPerson 4, 3, N'Player', '2018-06-23', null
Exec TransferPerson 4, 3, N'Benched player', '2019-07-12', '2019-09-25'
Exec TransferPerson 4, 4, N'Player', '2019-09-25', null

Exec TransferPerson 5, 3, N'Player', '2018-06-23', '2018-12-21'
Exec TransferPerson 5, 2, N'Player', '2018-12-21', null

Exec ShowPersonHistory 1
Exec ShowCurrentLineup 1
Exec ShowAverageAge 1

--Exec Functions
Select * from ShowAverageAgeAllFunc() Order by Age, Name 

Select dbo.ShowAgeDifference(1) 



--Reseed Person_Team Table 
DBCC CHECKIDENT('Person_Team', RESEED, 16)
DBCC CHECKIDENT('Person', RESEED, 12)
Select * From Person_Team 

--Normal Selects

Select * from Person
Where Age <= All (Select Age From Person)

Select  Concat(firstName, ' "',nickname, '" ', lastName) as 'Player', country, age, joinDate, name From Person
Join Person_Team on Person.idPerson = Person_Team.Person_idPerson
Join Team on Team.idTeam = Person_Team.Team_idTeam 
Where idTeam = 3 and role = 'Player' and leftDate IS NULL and joinDate <= All (Select joinDate from
Person_Team where Team.idTeam = 3) 

Create Index RoleIndex on Person_Team(role) 




