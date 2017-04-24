CREATE OR REPLACE PROCEDURE DELETE_CASCADE(
  p_table_name VARCHAR2, 
  p_id NUMBER, 
  p_history VARCHAR2) AS 
  
  v_sql VARCHAR2(2000);
BEGIN
  IF instr(p_history, p_table_name) > 0 THEN
    RETURN;
  END IF;
  
  FOR i IN (SELECT a.table_name, a.column_name,       -- referenced pk
                 c_pk.table_name r_table_name, c_pk_c.column_name r_column_name
              FROM all_cons_columns a
              JOIN all_constraints c ON a.owner = c.owner
                                    AND a.constraint_name = c.constraint_name
              JOIN all_constraints c_pk ON c.r_owner = c_pk.owner
                                       AND c.r_constraint_name = c_pk.constraint_name
              JOIN all_cons_columns c_pk_c ON c_pk_c.owner = c_pk.owner
                                          AND c_pk_c.constraint_name = c_pk.constraint_name
             WHERE c.constraint_type = 'R'
               AND c_pk.table_name = p_table_name) LOOP
      v_sql := '
      BEGIN
        FOR k IN (SELECT id FROM ' || i.table_name || ' WHERE ' || i.column_name || ' = ' || p_id || ') LOOP
          delete_cascade(''' || i.table_name || ''', k.id , ''' || p_history || p_table_name || '|'');
        END LOOP;
      END;';
      --dbms_output.put_line(v_sql);
      EXECUTE IMMEDIATE v_sql;
  END LOOP;
  
  dbms_output.put_line('DELETE FROM ' || p_table_name || ' WHERE id = ' || p_id);
  
  FOR i IN (SELECT a.table_name, a.column_name,       -- referenced pk
                 c_pk.table_name r_table_name, c_pk_c.column_name r_column_name
              FROM all_cons_columns a
              JOIN all_constraints c ON a.owner = c.owner
                                    AND a.constraint_name = c.constraint_name
              JOIN all_constraints c_pk ON c.r_owner = c_pk.owner
                                       AND c.r_constraint_name = c_pk.constraint_name
              JOIN all_cons_columns c_pk_c ON c_pk_c.owner = c_pk.owner
                                          AND c_pk_c.constraint_name = c_pk.constraint_name
             WHERE c.constraint_type = 'R'
               AND c.table_name = p_table_name) LOOP
      v_sql := '
      BEGIN
        FOR k IN (SELECT ' || i.column_name || ' AS fk_id FROM ' || i.table_name || ' WHERE id = ' || p_id || ') LOOP
          delete_cascade(''' || i.r_table_name || ''', k.fk_id , ''' || p_history || p_table_name || '|'');
        END LOOP;
      END;';
      --dbms_output.put_line(v_sql);
      EXECUTE IMMEDIATE v_sql;
  END LOOP;
  
END DELETE_CASCADE;
