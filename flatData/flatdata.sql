set serveroutput on
set verify off

select * from titanic where fare is null;
-- The 'spool' command redirects output to a text file.  Don't forget to turn it off at the end.
-- Also, it will still get the program text, so edit it before using it.
spool "Z:\Databases_YEAR_3\titanicInserts.js"
declare
-- The purpose of this program is to produce a script for mongodb in a file:
--
--  Set up a cursor to loop through all of the students
cursor students is
  select * from titanic;
  --select studentno, studentname, prog_code, stage_code from student;
v_student students%rowtype;-- This will hold the current student
--
begin
-- This program generates a script for entering into MongoDB
--  The structure of the mongodb script is:
--  titanicOneToFew
--     _id
--     ticketno
--     fare
--     cabin
--     homedest
--     customers
--     name
--     age
--     sex
--     survived
--   
  OPEN STUDENTS;
  LOOP
  FETCH STUDENTS INTO V_STUDENT;
  EXIT WHEN STUDENTS%NOTFOUND;
  -- Start the insert statement for the student
     if v_student.name like '%"%' then
        v_student.name := REPLACE(v_student.name, '"', ' ');
     end if;
     dbms_output.PUT('db.titanicFlat.insert({"pclass": ' || v_student.pclass ||', "survived": ' ||
     v_student.survived ||', "name": "' ||
     v_student.name ||'", "sex": "' ||
     v_student.sex ||'", "age": "'||
     v_student.age ||'", "ticket": "'||
     v_student.ticket ||'", "fare": '||
     v_student.fare ||', "cabin": "'||
     v_student.age ||'", "homedest": "'||
     v_student.homedest || '"' );
     dbms_output.PUT_line('})');--Finish the insert instruction for this student.
  end loop;

  close students;
  --dbms_output.FCLOSE(out_file);
  end;
/
spool off;