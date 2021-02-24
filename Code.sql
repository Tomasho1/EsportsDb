--Triggers

Alter Trigger CalculateAge 
On Person
After Insert, Update
As
Declare @birthdate date = (Select birthdate from Inserted);
Declare @now date = (Select Cast(GetDate() As Date)); 
Declare @age int;
Begin
	Set @age = (Select(Cast(DateDiff(day, @birthdate, @now) / 365.25 as Int)));
	Update Person Set age = @age Where IdPerson = @@IDENTITY
End;

Enable Trigger CalculateAge on Person

go
Create Trigger AssignRegion
On Person_Team
After Insert, Update
As
	Declare @region nvarchar(40)
Begin 
	Select country, count(country) as 'Number' Into #CountriesCounted from Person
	Join Person_Team on Person.idPerson = Person_Team.Person_idPerson
	Join Team on Team.idTeam = Person_Team.Team_idTeam 
	Where idTeam = (Select Team_idTeam from Inserted) and role = 'Player' and leftDate IS NULL 			
	Group by country 

	Select continent, count(continent) as 'Number' Into #ContinentsCounted from Person
	Join Person_Team on Person.idPerson = Person_Team.Person_idPerson
	Join Team on Team.idTeam = Person_Team.Team_idTeam 
	Where idTeam = (Select Team_idTeam from Inserted) and role = 'Player' and leftDate IS NULL 			
	Group by continent 
Begin
If Exists (Select country from #CountriesCounted 
Where Number >=3) 
	Begin
		Set @region= (Select country from #CountriesCounted Where Number >=3) 
		Update Team Set Region = @region Where idTeam = (Select Team_idTeam from Inserted)
	End; 
Else 
	If Exists (Select continent from #ContinentsCounted Where Number >=3) 
	Begin
		Set @region = (Select continent from #ContinentsCounted Where Number >=3) 
		Update Team Set Region = @region Where idTeam = (Select Team_idTeam from Inserted)
	End;
Else 
	Begin
		Set @region = N'International'
		Update Team Set Region = @region Where idTeam = (Select Team_idTeam from Inserted)
	End;
End;
End;

Enable Trigger AssignRegion on Person_Team 

	

--Stored procedures
go 
Alter Procedure TransferPerson (@idPerson int, @idTeam int, @role nvarchar(30), @joinDate date, @leftDate date)
As
Declare @idPersonCheck int, 
@idTeamCheck int, 
@nickname nvarchar(30), 
@firstName nvarchar(30), 
@lastName nvarchar(30),
@name nvarchar(40),
@now date = (Select Cast(GetDate() As Date)); 
Begin
	Set @idPersonCheck = (Select Count(1) from Person Where idPerson = @idPerson)
	Set @idTeamCheck = (Select Count(1) from Team Where idTeam = @idTeam)
	Begin
		If (@idPersonCheck = 0) 
			Begin
				Raiserror('Person not found', 16, 1);
			End;
		Else If (@idTeamCheck = 0)
			Begin
				Raiserror('Team not found', 16, 1);
			End;
		Else If (@joinDate > @now)
			Begin
				Raiserror('Date is not valid', 16, 1);
			End;
		Else 
			Begin 
				Select @nickname = nickname, @firstName = firstName, @lastname = lastname from Person
				Where idPerson = @idPerson; 
				Select @name = name from Team
				Where idTeam = @idTeam; 
				If (@leftDate IS NULL) 
					Begin
						If (@role = 'Player')
						Begin 
							Insert into Person_Team (Team_idTeam, Person_idPerson, role, joinDate) Values (@idTeam, @idPerson, @role, @joinDate);
							Print('Moved ' + @firstName + ' "'+ @nickname + '" ' + @lastName + ' to ' +  @name);
						End;
						Else If (@role = 'Benched player')
						Begin 
							Update Top (1) Person_Team set leftDate = @joinDate 
							where Person_Team.Person_idPerson = @idPerson and Person_Team.Team_idTeam = @idTeam and role = 'Player'
							Insert into Person_Team (Team_idTeam, Person_idPerson, role, joinDate) Values (@idTeam, @idPerson, @role, @joinDate);
							Print('Benched ' + @firstName + ' "'+ @nickname + '" ' + @lastName + ' in ' +  @name);
						End;
					End;
				Else
					Begin
					If (@role = 'Player')
						Begin 
							Insert into Person_Team (Team_idTeam, Person_idPerson, role, joinDate, leftDate) Values (@idTeam, @idPerson, @role, @joinDate, @leftDate);
							Print('Released ' + @firstName + ' "'+ @nickname + '" ' + @lastName + ' from ' +  @name);
						End;
						Else If (@role = 'Benched player')
						Begin 
							Update Top (1) Person_Team set leftDate = @joinDate 
							where Person_Team.Person_idPerson = @idPerson and Person_Team.Team_idTeam = @idTeam and role = 'Player'
							Insert into Person_Team (Team_idTeam, Person_idPerson, role, joinDate, leftDate) Values (@idTeam, @idPerson, @role, @joinDate, @leftDate);
							Print('Released ' + @firstName + ' "'+ @nickname + '" ' + @lastName + ' from ' +  @name + ' bench');
						End;
					End;
			End;
	End;
End;

go

Alter Procedure ShowPersonHistory(@idPerson int)
As
Declare @name nvarchar(40),
@role nvarchar(30), 
@joinDate date,
@leftDate date;
Begin
	If (Select Count(1) from Person Where IdPerson = @idPerson) = 0
	Raiserror('Person not found', 16, 1);

	Else 
		Begin
			Select name, role, joinDate, leftDate from Person_Team
			Join Team on Person_Team.Team_idTeam = Team.idTeam
			Join Person on Person_Team.Person_idPerson = Person.idPerson
			Where idPerson = @idPerson
			Group by name, role, joinDate, leftDate
			Order by joinDate;
		End;
End;

go

Alter Procedure ShowCurrentLineup (@idTeam int) 
As
Declare @nickname nvarchar(30), 
@firstName nvarchar(30), 
@lastName nvarchar(30),
@country nvarchar(40),
@age int,
@joinDate date,
@leftDate date
Begin
	If (Select Count(1) from Team Where IdTeam = @idTeam) = 0
		Raiserror('Team not found', 16, 1);
	Else 
		Begin
		
			Select
			Case 
				When role = 'Player' Then Concat(firstName, ' "',nickname, '" ', lastName)
				When role = 'Coach' Then Concat(firstName, ' "',nickname, '" ', lastName, ' (C) ')
			End as person,
			country, age, joinDate, leftDate
			from Person
			Join Person_Team on Person.idPerson = Person_Team.Person_idPerson
			Join Team on Team.idTeam = Person_Team.Team_idTeam 
			Where idTeam = @idTeam and (role = 'Player' or role = 'Coach') and leftDate IS NULL 
			Order by role Desc, joinDate, nickname
		End;
End; 

go 
Alter Procedure ShowAverageAge (@idTeam int)
As
Begin
	If (Select Count(1) from Team where IdTeam = @idTeam) = 0
		Raiserror('Team not found', 16, 1);
	Else
		Begin
			Select Avg(Age) as 'Average age' from Person
			Join Person_Team on Person.idPerson = Person_Team.Person_idPerson
			Where Person_Team.Team_idTeam = @idTeam and role = 'Player' and leftDate IS NULL
		End
End;
				
go 

--Functions
Alter Function ShowAverageAgeAllFunc()
Returns @table TABLE (Name nvarchar(40), Age int)
As 
Begin 
Declare curs Cursor for Select IdTeam from Team 
Declare @idTeam int
	Open curs 
	Fetch next from Curs into @idTeam
		While @@Fetch_Status = 0
			Begin
				Insert into @table (Name, Age) Values ((Select name from Team
					Where IdTeam = @idTeam),
				(Select Avg(Age) from Person
					Join Person_Team on Person.idPerson = Person_Team.Person_idPerson
					Join Team on Person_Team.Team_idTeam = Team.idTeam 
					Where Person_Team.Team_idTeam = @idTeam and role = 'Player' and leftDate IS NULL))
				Fetch next from Curs into @idTeam 
			End
	Close curs
	Deallocate curs
	Return 
End; 

go 

Alter Function ShowAgeDifference(@idTeam int)
Returns int
As
	Begin
		Declare @difference int, @maxAge int, @minAge int
		Select @maxAge = (Select Max(Age) from Person
		Join Person_Team on Person.idPerson = Person_Team.Person_idPerson
		Join Team on Person_Team.Team_idTeam = Team.idTeam 
		Where idTeam = @idTeam and role = 'Player')
		Select @minAge = (Select Min(Age) from Person
		Join Person_Team on Person.idPerson = Person_Team.Person_idPerson
		Join Team on Person_Team.Team_idTeam = Team.idTeam 
		Where idTeam = @idTeam and role = 'Player')
		Select @difference = @maxAge - @minAge 
	Return @difference
End; 















	

	
