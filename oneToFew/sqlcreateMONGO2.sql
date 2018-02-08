set serveroutput on
set verify off
-- The 'spool' command redirects output to a text file.  Don't forget to turn it off at the end.
-- Also, it will still get the program text, so edit it before using it.

spool "Z:\Databases_YEAR_3\titanicInserts.js"
declare -- The purpose of this program is to produce a script for mongodb:
--
/*
cursor customers is
  select name, sex, age, survived from titanic;
v_mod customers%rowtype; -- This will hold the current customer code that is registered in the ticket
v_no_mods integer;  -- This holds the number of customers a ticket has.
  
cursor tickets is
 select ticket, fare, cabin, homedest from titanic where name = v_mod.name;
v_student tickets%rowtype;-- This will hold the current ticket
  */
  
--  Set up a cursor to loop through all of the tickets
cursor tickets is
 select distinct ticket, pclass, fare, cabin, homedest from titanic;
v_student tickets%rowtype;-- This will hold the current ticket
--
-- Set up a cursor to loop through the customers that have the same ticket
cursor customers is
  select name, sex, age, survived from titanic where ticket = v_student.ticket;
v_mod customers%rowtype; -- This will hold the current customer code that is registered in the ticket
v_no_mods integer;  -- This holds the number of customers a ticket has.*/
begin

-- This program generates a script for entering into MongoDB
--  The structure of the mongodb script is:
--  titanicOneToFew
--     _id
--     ticketno
--     pclass
--     fare
--     cabin
--     homedest
--     customers[
--                name
--                age
--                sex
--                survived
--              ]


  OPEN tickets;
  LOOP
  FETCH tickets INTO V_STUDENT;
  EXIT WHEN tickets%NOTFOUND;
  -- Start the insert statement for the tickets
      dbms_output.PUT('db.titanicOneToFew.insert({"ticketno": "'||v_student.ticket || '", "pclass": '|| v_student.pclass||', "fare": '||
     v_student.fare||', "cabin": "'||
     v_student.cabin||'", "homedest": "'||
     v_student.homedest || '"');
  -- Check to see if there are any customers; if so, set up the array structure
     select count(*) into v_no_mods from titanic where ticket = v_student.ticket;
     if v_no_mods > 0 then
       dbms_output.put(', "customers": [');
       open customers;
       FOR i in 1..v_no_mods LOOP 
         FETCH customers INTO V_mod;
         if v_mod.name like '%"%' then
           v_mod.name := REPLACE(v_mod.name, '"', ' ');
          end if;
         dbms_output.put('{"name":"'||v_mod.name||'",' || '"age":"'||v_mod.age||'",' || '"sex":"'||v_mod.sex||'",' || '"survived":'||v_mod.survived||'}');
         if i < v_no_mods then -- we only want commas if there's another code after this one.
           dbms_output.put(', ');
         end if;
      end loop;
      dbms_output.put(']');-- Close the array structure
      close customers; -- Finished with this customer - when the cursor opens again, it'll be for a new customer.
     end if;
     dbms_output.PUT_line('})'); -- Finish the insert instruction for this ticket.
  end loop;

  close tickets;
  end;
/
spool off -- turn off spooling to the file

