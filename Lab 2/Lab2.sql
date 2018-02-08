/*
Advanced Databases Lab 2 3/Q2.
Eryk Szlachetka   C14386641   DT282
Create the normalized tables with sql developer and move data into the new tables.
*/

DROP TABLE GPA;
DROP TABLE PRIOR_SCHOOL;
DROP TABLE REFERENCE_STATEMENT;
DROP TABLE REFERENCES;
DROP TABLE THE_ADDRESS;
DROP TABLE THE_APPLICATIONS;
DROP TABLE THE_STUDENT;


CREATE TABLE THE_STUDENT (
	StudentID            INTEGER NOT NULL,
	StudentName          VARCHAR(50) NULL,
    CONSTRAINT Student_PK PRIMARY KEY (StudentID)
);

CREATE TABLE THE_APPLICATIONS (
	App_No               INTEGER NOT NULL,
	App_Year             INTEGER NULL,
    StudentID            INTEGER NOT NULL,
    CONSTRAINT Application_student_FK FOREIGN KEY (StudentId) REFERENCES STUDENT(StudentID),
    CONSTRAINT Application_PK PRIMARY KEY (App_No, App_Year),
    CONSTRAINT onestudentperyear UNIQUE(App_Year,StudentId)
);

CREATE TABLE THE_ADDRESS (
	Street               VARCHAR(100) NOT NULL,
	State                VARCHAR(30) NULL,
	ZipCode              VARCHAR(7) NULL,
    StudID               INTEGER NULL,
    CONSTRAINT Address_Student_FK FOREIGN KEY (StuDID) REFERENCES STUDENT(StudentID),
    CONSTRAINT Adress_PK PRIMARY KEY (StudID,Street,state)

);

CREATE TABLE REFERENCES (
    ReferenceName        VARCHAR(100) NULL,
	RefInstitution       VARCHAR(100) NULL,
    CONSTRAINT Reference_PK PRIMARY KEY (ReferenceName, RefInstitution)
);

CREATE TABLE REFERENCE_STATEMENT (
    App_No               INTEGER NOT NULL,
	App_Year             INTEGER NULL,
    ReferenceName        VARCHAR(100) NULL,
	RefInstitution       VARCHAR(100) NULL,
    ReferenceStatement   VARCHAR(500) NOT NULL,
    StudentID            INTEGER NOT NULL,
    CONSTRAINT RefStatement_References_FK FOREIGN KEY (ReferenceName,RefInstitution) REFERENCES REFERENCES(ReferenceName, RefInstitution),
    CONSTRAINT RefStatement_Application_FK FOREIGN KEY (App_No,App_Year) REFERENCES APPLICATIONS(App_no,App_Year)
);

CREATE TABLE PRIOR_SCHOOL (
	PriorSchoolId        INTEGER NOT NULL,
	PriorSchoolAddr      VARCHAR2(100) NULL,
    CONSTRAINT PriorSchool_PK PRIMARY KEY (PriorSchoolId)
);

CREATE TABLE GPA (
    App_No               INTEGER NOT NULL,
	App_Year             INTEGER NULL,
	PriorSchoolId        INTEGER NOT NULL,
	PriorSchoolAddr      VARCHAR2(100) NULL,
	GPA                  NUMBER(2) NULL,
    StudentID            INTEGER NOT NULL,
    CONSTRAINT PriorSchool_FK FOREIGN KEY (PriorSchoolId) REFERENCES PRIORSCHOOL (PriorSchoolId),
    CONSTRAINT PS_Application_FK FOREIGN KEY (App_no,App_Year) REFERENCES APPLICATIONS(App_no,App_Year)
);
insert into THE_STUDENT values(1,'Mark');
insert into THE_STUDENT values(2,'Sarah');
insert into THE_STUDENT values(3,'Paul');
insert into THE_STUDENT values(4,'Jack');
insert into THE_STUDENT values(5,'Mary');
insert into THE_STUDENT values(6,'Susan');

insert into THE_APPLICATIONS values (1,2003,1);
insert into THE_APPLICATIONS values (1,2004,1);
insert into THE_APPLICATIONS values (2,2007,1);
insert into THE_APPLICATIONS values (3,2012,1);
insert into THE_APPLICATIONS values (2,2010,2);
insert into THE_APPLICATIONS values (2,2011,2);
insert into THE_APPLICATIONS values (2,2012,2);
insert into THE_APPLICATIONS values (1,2012,3);
insert into THE_APPLICATIONS values (3,2008,3);
insert into THE_APPLICATIONS values (1,2009,4);
insert into THE_APPLICATIONS values (2,2009,5);
insert into THE_APPLICATIONS values (1,2005,5);
insert into THE_APPLICATIONS values (3,2011,6);

insert into THE_ADDRESS values('Grafton Street','New York','NY234',1);
insert into THE_ADDRESS values('White Street','Florida','Flo435',1);
insert into THE_ADDRESS values('Green Road','California','Cal123',2);
insert into THE_ADDRESS values('Red Crescent','Carolina','Ca455',3);
insert into THE_ADDRESS values('Yellow Park','Mexico','Mex1',3);
insert into THE_ADDRESS values('Dartry Road','Ohio','Oh34',4);
insert into THE_ADDRESS values('Malahide Road','Ireland','IRE',5);
insert into THE_ADDRESS values('Black Bay','Kansas','Kan45',5);
insert into THE_ADDRESS values('River Road','Kansas','Kan45',6);

insert into REFERENCES values ('Dr. Jones','Trinity College');
insert into REFERENCES values ('Dr. Jones','U Limerick');
insert into REFERENCES values ('Dr. Byrne','DIT');
insert into REFERENCES values ('Dr. Byrne','UCD');
insert into REFERENCES values ('Prof. Cahill','UCC');
insert into REFERENCES values ('Prof. Lillis','DIT');

insert into REFERENCE_STATEMENT values (1,2003,'Dr. Jones','Trinity College','Good guy',1);
insert into REFERENCE_STATEMENT values (1,2004,'Dr. Jones','Trinity College','Good guy',1);
insert into REFERENCE_STATEMENT values (2,2007,'Dr. Jones','Trinity College','Good guy',1);
insert into REFERENCE_STATEMENT values (3,2012,'Dr. Jones','U Limerick','Very Good guy',1);
insert into REFERENCE_STATEMENT values (2,2010,'Dr. Byrne','DIT','Perfect',2);
insert into REFERENCE_STATEMENT values (2,2011,'Dr. Byrne','DIT','Perfect',2);
insert into REFERENCE_STATEMENT values (2,2012,'Dr. Byrne','UCD','Average',2);
insert into REFERENCE_STATEMENT values (1,2012,'Dr. Jones','Trinity College','Poor',3);
insert into REFERENCE_STATEMENT values (3,2008,'Prof. Cahill','UCC','Excellent',3);
insert into REFERENCE_STATEMENT values (1,2009,'Prof. Lillis','DIT','Fair',4);
insert into REFERENCE_STATEMENT values (2,2009,'Prof. Lillis','DIT','Good girl',5);
insert into REFERENCE_STATEMENT values (1,2005,'Dr. Byrne','DIT','Perfect',5);
insert into REFERENCE_STATEMENT values (3,2011,'Prof. Cahill','UCC','Messy',6);

insert into PRIOR_SCHOOL values(1,'Castleknock');
insert into PRIOR_SCHOOL values(2,'Loreto College');
insert into PRIOR_SCHOOL values(3,'St. Patrick');
insert into PRIOR_SCHOOL values(4,'DBS');
insert into PRIOR_SCHOOL values(5,'Harvard');
    
insert into GPA values (1,2003,1,'Castleknock',65,1);
insert into GPA values (2,2007,2,'Loreto College',87,1);
insert into GPA values (2,2010,1,'Castleknock',90,2);
insert into GPA values (2,2010,3,'St. Patrick',76,2);
insert into GPA values (2,2012,4,'DBS',66,2);
insert into GPA values (2,2012,5,'Harvard',45,2);
insert into GPA values (1,2012,1,'Castleknock',45,3);
insert into GPA values (3,2012,3,'St. Patrick',67,3);
insert into GPA values (3,2012,4,'DBS',23,3);
insert into GPA values (3,2012,5,'Harvard',67,3);
insert into GPA values (1,2009,3,'St. Patrick',29,4);
insert into GPA values (1,2009,4,'DBS',88,4);
insert into GPA values (1,2009,5,'Harvard',66,4);
insert into GPA values (2,2009,3,'St. Patrick',44,5);
insert into GPA values (2,2009,4,'DBS',55,5);
insert into GPA values (2,2009,5,'Harvard',66,5);
insert into GPA values (2,2009,1,'Castleknock',74,5);
insert into GPA values (1,2005,3,'St. Patrick',44,5);
insert into GPA values (1,2005,4,'DBS',55,5);
insert into GPA values (1,2005,5,'Harvard',66,5);
insert into GPA values (3,2011,1,'Castleknock',88,6);
insert into GPA values (3,2011,3,'St. Patrick',77,6);
insert into GPA values (3,2011,4,'DBS',56,6);
insert into GPA values (3,2011,2,'Loreto College',45,6);
