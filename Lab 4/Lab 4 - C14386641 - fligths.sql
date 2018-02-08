drop table reservations;
drop table flights;
drop sequence flight_id_seq;
drop sequence res_id_seq;

CREATE TABLE flights(
fl_id int not null primary key,
from_city varchar(100),
to_city varchar(100),
fl_date date,
tot_seats number not null,
free_seats number
);

CREATE TABLE RESERVATIONS(
res_id int not null primary key,
fl_id int not null,
num_seats number, --number of seats booked
cust_name varchar(100),
foreign key (fl_id) references flights(fl_id)
);


-- TRIGGERS
-- EX1: Using triggers, make the fl_id and res_id auto increment

-- flight id
    CREATE SEQUENCE flight_id_seq
      START WITH 1
      INCREMENT BY 1;
      
  CREATE OR REPLACE TRIGGER trigger_fl_id
  BEFORE INSERT ON flights 
  FOR EACH ROW
  Begin
      SELECT flight_id_seq.nextval into :new.fl_id from dual;
  END;
  /

-- reservation id
    CREATE SEQUENCE res_id_seq
      START WITH 1
      INCREMENT BY 1;
      
  CREATE OR REPLACE TRIGGER trigger_res_id
  BEFORE INSERT ON reservations 
  FOR EACH ROW
  Begin
      SELECT res_id_seq.nextval into :new.res_id from dual;
  END;
  /


-- When EX1 has been completed, execute the following:

INSERT into flights(from_city,to_city,fl_date,tot_seats,free_seats) values ('Rome','Paris',to_date('2012-02-02','yyyy-mm-dd'),300,300);
INSERT into flights(from_city,to_city,fl_date,tot_seats,free_seats) values ('Dublin','Paris',to_date('2013-02-02','yyyy-mm-dd'),300,300);
INSERT into flights(from_city,to_city,fl_date,tot_seats,free_seats) values ('Madrid','Moscow',to_date('2014-02-02','yyyy-mm-dd'),300,300);
INSERT into flights(from_city,to_city,fl_date,tot_seats,free_seats) values ('NY','Dublin',to_date('2014-03-02','yyyy-mm-dd'),300,300);

select * from flights;

-- EX2: Write a trigger for the table reservations that, when a booking is inserted, modified or delete, update the number of free seats. 
-- If there are not enough seats, an exception is raised

  CREATE OR REPLACE TRIGGER booking
  BEFORE INSERT OR DELETE OR UPDATE ON reservations 
  -- check if there are enough seats
  FOR EACH ROW
DECLARE
	free NUMBER;
BEGIN

  IF Inserting THEN
    select free_seats into free from flights where flights.fl_id = :new.fl_id; -- get the numnber of free seats
    IF free < :new.num_seats THEN
        Raise_application_error(-20000,'Not enough Seats!');
    ELSE
      --enough seat, update
      UPDATE flights set free_seats = free_seats - :new.num_seats where flights.fl_id = :new.fl_id; 
    END IF;  
  ELSE
    IF deleting THEN
       --deleting
       UPDATE flights set free_seats = free_seats + :old.num_seats where flights.fl_id = :old.fl_id; 
    ELSE
      -- updating
      --check if new seats are added or some seats are deleted
        select free_seats into free from flights where flights.fl_id = :new.fl_id; -- get the numnber of free seats
        IF free < :new.num_seats - :old.num_seats THEN  --negative if some seats are cancelled, always verified
           Raise_application_error(-20000,'Not enough Seats!');
        ELSE
            --enough seat, update, add the old seats, subtract the new seats
            UPDATE flights set free_seats = free_seats - :new.num_seats + :old.num_seats where flights.fl_id = :new.fl_id; 
        END IF; 
    END IF;
  END IF;
END;
/

insert into reservations(fl_id,num_seats,cust_name) values (1,100,'mary');
select * from reservations;

--free swats  is now 200
select * from flights where fl_id = 1;

insert into reservations(fl_id,num_seats,cust_name) values (1,150,'john');
--free seats  is now 50
select * from flights where fl_id = 1;

-- this should raise an exception
insert into reservations(fl_id,num_seats,cust_name) values (1,100,'mark');

select * from reservations;

-- deleting the first reservtion (100 free seats more)
delete from reservations where cust_name='john';
--free seats  is now back to 150
select * from flights where fl_id = 1;

select * from reservations;

-- updating mary's reservation, number of seats from 150 to 190
-- now free seats should be 110
update reservations set num_seats = 115 where cust_name = 'mary';
