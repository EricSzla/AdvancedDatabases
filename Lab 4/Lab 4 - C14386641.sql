DROP SEQUENCE matchID_sequence;
DROP TABLE LOGTEAM;
DROP TABLE EUROLEAGUE;
DROP TABLE MATCHES;
DROP TABLE TEAMS;

CREATE TABLE TEAMS(
    TeamName      VARCHAR2(30) Primary Key,
    TeamCountry   VARCHAR2(10) NOT NULL,
    -- C) Country is either Spain or England
    CONSTRAINT chk_country CHECK (TeamCountry IN ('Spain', 'England'))
);

CREATE TABLE MATCHES(
  MatchID         NUMBER PRIMARY KEY,
  TeamA_Name      VARCHAR2(10) NOT NULL,
  TeamB_Name      VARCHAR2(10) NOT NULL,
  Goal_A          VARCHAR2(10) NOT NULL,
  Goal_B          VARCHAR2(10) NOT NULL,
  Competition     VARCHAR2(20) NOT NULL,
  
  -- B) Competition is either Champions League, Europa Leauge, Premier League or La Liga .
  CONSTRAINT chk_competition CHECK (Competition IN ('Champions League', 'Europa Leauge', 'Premier League', 'La Liga')),
  -- D) Goals in the table MATCHES is a number >=0.
  CONSTRAINT chk_goal_A CHECK (Goal_A >= 0 AND Goal_B >= 0),
  FOREIGN KEY (TeamA_Name) REFERENCES TEAMS(TeamName), 
  FOREIGN KEY (TeamB_Name) REFERENCES TEAMS(TeamName)
);


CREATE TABLE EUROLEAGUE(
  TeamName        VARCHAR2(30) PRIMARY KEY,
  Points          int NOT NULL,
  Goals_Scored    int NOT NULL,
  Goals_Conceded  int NOT NULL,
  Difference      int NOT NULL
);

CREATE TABLE LOGTEAM(
  TeamName        VARCHAR2(10) PRIMARY KEY,
  LogTime         TIMESTAMP NOT NULL
);

-- A) MatchIDis an auto increment key. Use a sequence to define it. 

CREATE SEQUENCE matchID_sequence
  START WITH 1
  INCREMENT BY 1;
  
CREATE OR REPLACE TRIGGER matchID_trigger
  BEFORE INSERT ON MATCHES
  FOR EACH ROW
  BEGIN
    SELECT matchID_sequence.nextval INTO :new.MatchID FROM dual;
  END;
  /
  
  
-- Triggers:
-- a)Using a trigger, log into a table LOGTEAM the timestamps of all the insertions in the table TEAMS. 
CREATE OR REPLACE TRIGGER log_trigger
  AFTER INSERT ON TEAMS
  FOR EACH ROW
  
  DECLARE 
  
  teamNamee VARCHAR(30);
  theTime TIMESTAMP;
  anyRowsFound NUMBER;
  
  BEGIN
    teamNamee := :OLD.TeamName;
    theTime := CURRENT_TIMESTAMP;
    INSERT INTO LOGTEAM(TeamName, LogTime) VALUES(teamNamee,theTime);
    
    
    -- b)Create a trigger that, every time a new team is inserted in the table TEAMS, 
    -- inserts the name of theteam in the EUROLEAGUE 
    -- table if the team is not already there. Set points and goals to zero. 
    SELECT count(*) INTO anyRowsFound from EUROLEAGUE where EUROLEAGUE.TeamName in teamNamee;
    
    if anyRowsFound > 0 then
      INSERT INTO EUROLEAGUE VALUES(teamNamee,0,0,0,0);
    end if;
    
  END;
/


DELETE FROM TEAMS;
-- INSERT DATA TO CHECK IF THE TRIGGERS WORK FINE
INSERT INTO TEAMS(TeamName, TeamCountry) VALUES ('Arsenal','England');
INSERT INTO TEAMS(TeamName, TeamCountry) VALUES ('Manchester United', 'England');
INSERT INTO TEAMS(TeamName, TeamCountry) VALUES ('Chelsea', 'England');
INSERT INTO TEAMS(TeamName, TeamCountry) VALUES ('Everton', 'England');
INSERT INTO TEAMS(TeamName, TeamCountry) VALUES ('Barcelona' ,'Spain');
INSERT INTO TEAMS(TeamName, TeamCountry) VALUES ('Real Madrid', 'Spain');
INSERT INTO TEAMS(TeamName, TeamCountry) VALUES ('Atletico Madrid' ,'Spain');
INSERT INTO TEAMS(TeamName, TeamCountry) VALUES ('Sevilla', 'Spain');

SELECT * FROM TEAMS;


-- C)
-- Using a trigger, check that, if a match has Premier League or La Liga for competition, the country 
-- of the two teams is correct (both England for Premier League and both Spain for La Liga).
-- If  not,  the match cannot be inserted into the table MATCHES. 

CREATE OR REPLACE TRIGGER matchCompetition_trigger
BEFORE INSERT ON MATCHES 
FOR EACH ROW

DECLARE
  competitionName VARCHAR(20);
  teamA VARCHAR2(30);
  teamB VARCHAR2(30);
  teamCheckVar VARCHAR(30);
  team2CheckVar VARCHAR(30);
  
BEGIN
  IF Inserting then
    SELECT :new.Competition INTO competitionName FROM dual;
    SELECT :new.TeamA_Name INTO teamA FROM dual;
    SELECT :new.TeamB_Name INTO teamB FROM dual;
    
    IF competitionName IN ('Premier League') then
        SELECT TeamCountry INTO teamCheckVar FROM TEAMS WHERE TeamName = teamA;
        SELECT TeamCountry INTO team2CheckVar FROM TEAMS WHERE TeamName = teamB;
        IF teamCheckVar not in ('England') or team2CheckVar not in ('England') then
          Raise_application_error(-20000,'Only English teams are allowed in Premier League!');
        END IF;
    END IF;
    
    IF competitionName in ('La Liga') then
    SELECT TeamCountry INTO teamCheckVar FROM TEAMS WHERE TeamName = teamA;
        SELECT TeamCountry INTO team2CheckVar FROM TEAMS WHERE TeamName = teamB;
        IF teamCheckVar not in ('Spain') or team2CheckVar not in ('Spain') then
          Raise_application_error(-20000,'Only Spanish teams are allowed in La Liga!');
        END IF;
    END IF;
    
    
  END IF;
END;
/





-- D) Using a trigger, check that a team has no more than 4 matches in the table MATCHES. 
-- E) -- Using a trigger (you can extend trigger d ), update the EUROLEAGUE table by 
-- adding three points to  the  winning  team,  
-- 1  point to  each  team  in  case  of  a  draw,  
-- and  by  updating goals  scored,  conceded and the goal difference.
-- Note that the league table is for all the teams and competitions 

CREATE OR REPLACE TRIGGER team_no_matches_trigger
BEFORE INSERT ON MATCHES
FOR EACH ROW

DECLARE
no_of_matches number;
no_of_matches2 number;
theTeamAName VARCHAR(30);
theTeamBName VARCHAR(30);
noOfGoalsA int;
noOfGoalsB int;
difference int;
team_a_exists_in_a int;
team_a_exist_in_b int;
team_b_exists_in_a int;
team_b_exists_in_b int;

BEGIN
    -- Select Values Into Variables
    SELECT :new.TeamA_Name INTO theTeamAName FROM dual;
    SELECT :new.TeamB_Name INTO theTeamBName FROM dual;
    SELECT :new.Goal_A INTO noOfGoalsA FROM dual;
    SELECT :new.Goal_B INTO noOfGoalsB FROM dual;
    SELECT count(*) INTO team_a_exists_in_a FROM MATCHES where TeamA_Name = theTeamAName;
    SELECT count(*) INTO team_a_exists_in_b FROM MATCHES where TeamB_Name = theTeamAName;
    SELECT count(*) INTO team_b_exists_in_a FROM MATCHES where TeamA_Name = theTeamBName;
    SELECT count(*) INTO team_b_exists_in_b FROM MATCHES where TeamB_Name = theTeamBName;
    
    no_of_matches := team_a_exists_in_a + team_a_exists_in_b;
    no_of_matches2 := team_b_exists_in_a + team_b_exists_in_b;
    
    -- Check if the team has more than 4 matches, if so raise an exception
    IF no_of_matches > 4 or no_of_matches2 > 4 then
        RAISE_APPLICATION_ERROR(-19999, 'Team cannot have more than 4 matches scheduled!');
    END IF;
    
    -- There was a draw so each team gets one point.
    IF noOfGoalsA = noOfGoalsB then
        INSERT INTO EUROLEAGUE VALUES(theTeamAName, 1, noOfGoalsA, noOfGoalsB, 0);
        INSERT INTO EUROLEAGUE VALUES(theTeamBname, 1, noOfGoalsB, noOfGoalsA, 0);
    END IF;
    -- Check if Team A has won, if so give it 3 points.
    IF noOfGoalsA > noOfGoalsB then
        difference := noOfGoalsA - noOfGoalsB;
        INSERT INTO EUROLEAGUE VALUES(theTeamAName, 3, noOfGoalsA, noOfGoalsB, difference);
    END IF;
    -- Check if Team B has won, if so give it 3 points.
    IF noOfGoalsB > noOfGoalsA then
        difference := noOfGoalsB - noOfGoalsA;
        INSERT INTO EUROLEAGUE VALUES(theTeamBName, 3, noOfGoalsB, noOfGoalsA, difference);
    END IF;
END;
/ 


-- Check your constraints and triggers by inserting some match data
/*
  MatchID         NUMBER PRIMARY KEY,
  TeamA_Name      VARCHAR2(10) NOT NULL,
  TeamB_Name      VARCHAR2(10) NOT NULL,
  Goal_A          VARCHAR2(10) NOT NULL,
  Goal_B          VARCHAR2(10) NOT NULL,
  Competition     VARCHAR2(20) NOT NULL,
*/

-- This insert should raise an exception, because user is trying to insert Spanish team with English team.
INSERT INTO MATCHES(TeamA_Name, TeamB_Name, Goal_A, Goal_B, Competition) VALUES ('Arsenal', 'Barcelona',1,1,'La Liga');
-- Those inserts should work fine.
-- This insert shuould insert a draw in EuroLeague
INSERT INTO MATCHES(TeamA_Name, TeamB_Name, Goal_A, Goal_B, Competition) VALUES ('Arsenal', 'Manchester United',1,1,'Premiere League');
-- This insert should insert a winning points for Arsenal in EuroLeague
INSERT INTO MATCHES(TeamA_Name, TeamB_Name, Goal_A, Goal_B, Competition) VALUES ('Arsenal', 'Chelsea',2,1,'Premiere League');
-- This insert should insert a winning points for Arsenal in EuroLeague
INSERT INTO MATCHES(TeamA_Name, TeamB_Name, Goal_A, Goal_B, Competition) VALUES ('Arsenal', 'Everton',2,1,'Premiere League');
-- This insert should insert a winning points for Everton in EuroLeague
INSERT INTO MATCHES(TeamA_Name, TeamB_Name, Goal_A, Goal_B, Competition) VALUES ('Arsenal', 'Everton',1,2,'Premiere League');
-- This insert should raise an exception, because a team cannot play more than 4 matches.
INSERT INTO MATCHES(TeamA_Name, TeamB_Name, Goal_A, Goal_B, Competition) VALUES ('Arsenal', 'Everton',2,2,'Premiere League');