set serveroutput on
set verify off
-- The 'spool' command redirects output to a text file.  Don't forget to turn it off at the end.
-- Also, it will still get the program text, so edit it before using it.
spool "C:\users\patricia.obyrne\desktop\students2.js"
declare
-- The purpose of this program is to produce a script for mongodb in a file:
--
--  Set up a cursor to loop through all of the students
cursor students is
  select studentno, studentname, prog_code, stage_code from student;
v_student students%rowtype;-- This will hold the current student
--
begin
-- This program generates a script for entering into MongoDB
--  The structure of the mongodb script is:
--  Student
--     StudentNo as _id
--     StudentName
--     Prog_code
--     Stage_code
--
  OPEN STUDENTS;
  LOOP
  FETCH STUDENTS INTO V_STUDENT;
  EXIT WHEN STUDENTS%NOTFOUND;
  -- Start the insert statement for the student
      dbms_output.PUT('db.student.insert({_id: "'||v_student.studentno||'", studentname: "'||
     v_student.studentname||'", prog_code: "'||
     v_student.prog_code||'", stage_code: '||
     v_student.stage_code);
     dbms_output.PUT_line('})');--Finish the insert instruction for this student.
  end loop;

  close students;
  --dbms_output.FCLOSE(out_file);
  end;
/
spool off;