set serveroutput on
set verify off
-- The 'spool' command redirects output to a text file.  Don't forget to turn it off at the end.
-- Also, it will still get the program text, so edit it before using it.
spool "C:\users\patricia.obyrne\desktop\students2.js"
declare
-- The purpose of this program is to produce a script for mongodb:
--
--  Set up a cursor to loop through all of the students
cursor customers is
  select name, sex, age, survived from titanic;
v_student customers%rowtype;-- This will hold the current student
--
-- Set up a cursor to loop through the module codes the current student is taking
 cursor tickets is
 select ticket, fare, cabin, homedest from titanic where name = v_student.name;
v_mod titanic.tickets%type; -- This will hold the current module code that the current student is taking.
v_no_mods integer;  -- This holds the number of modules a student is taking.
begin
-- This program generates a script for entering into MongoDB
--  The structure of the mongodb script is:
--  Student
--     StudentNo as _id
--     StudentName
--     Prog_code
--     Stage_code
--     If the student has sat any modules, an array of module codes, with commas between them, enclosed with []
--
--
  OPEN customers;
  LOOP
  FETCH customers INTO V_STUDENT;
  EXIT WHEN customers%NOTFOUND;
  -- Start the insert statement for the student
      dbms_output.PUT('db.titanicDesign2.insert({name: "'||v_student.name||'", sex: "'||
     v_student.sex||'", age: "'||
     v_student.age||'", survived: '||
     v_student.survived);
  -- Check to see if there are any modules; if so, set up the array structure
     select count(*) into v_no_mods from titanic where name = v_student.name;
     if v_no_mods > 0 then
       dbms_output.put(', ticket: [');
       open tickets;
       FOR i in 1..v_no_mods LOOP 
         FETCH tickets INTO V_mod;
         dbms_output.put('"'||v_mod||'" ');
         if i < v_no_mods then -- we only want commas if there's another code after this one.
           dbms_output.put(', ');
         end if;
      end loop;
      dbms_output.put(']');-- Close the array structure
      close tickets; -- Finished with this student - when the cursor opens again, it'll be for a new student.
     end if;
     dbms_output.PUT_line('})'); -- Finish the insert instruction for this student.
  end loop;

  close customers;
  end;

spool off;-- turn off spooling to the file